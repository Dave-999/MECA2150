function [] = TV()
%Turbine a vapeur - main function

%%

%%%%%%%%%%%%%%
% Parametres %
%%%%%%%%%%%%%%

if nargin  == 0
    
    P_e = 35*10^3; %puissance effective [kW]
    dT_cond = 10; %ecart entre T4 et la riviere
    eta_siT = 0.88; %rendement isentropique turbine
    eta_siC = 0.88; %rendement isentropique pompe
    eta_mec = 0.98; %rendement mecanique
    lambda = 1.05; %coefficient d'exces d'air
    fuel = 'CH4'; %combustible
    t_ech = 120; %temperature des fumees a l'echappement [�C]
    t_a = 15; %tempreature de l'air ambiant [�C]
    p_calo = 0.01; %perte par d�perditions calorifiques = 1% du PCI
    dT_prechauf = 0; %pas de prechauffe du combustible et de l'air
    
    t3 = 525; %temperature maximale en sortie de chaudiere [�C]
    p3 = 200; %pression de vapeur vive en sortie de chaudiere [bar]
    t_sf = 15; %temperature source froide (riviere) [�C]
    t4 = t_sf + dT_cond; %temperature en sortie de turbine [�C]

end

%Limites en fin de d�tente : on doit verifier ?
p_ech_min = 0.04; 
x_ech_min = 0.88;

%%

%%%%%%%%%%%%%%%%%%%%
% Calcul des etats %
%%%%%%%%%%%%%%%%%%%%

%etat 3
etat3 = struct;
etat3.p = p3; %[bar]
etat3.t = t3; %[�C]
etat3.x = NaN;
etat3.h = XSteam('h_pt',etat3.p,etat3.t); %[kJ/kg]
etat3.s = XSteam('s_pt',etat3.p,etat3.t); %[kJ/kgK]
etat3.e = Exergie(etat3.h,etat3.s); %[kJ/kg]

%etat 4
etat4 = struct;
etat4.p = XSteam('psat_T',t4); 
etat4.t = t4;
[etat4.x,etat4.h,etat4.s] = Detente(etat3.h,etat3.s,etat4.p,eta_siT);
etat4.e = Exergie(etat4.h,etat4.s);

%etat 1
etat1 = struct;
etat1.p = etat4.p; %condensation isobare
etat1.t = etat4.t; %condensation isobare
etat1.x = 0; %liquide sature
etat1.h = XSteam('h_px',etat1.p,etat1.x);
etat1.s = XSteam('s_ph',etat1.p,etat1.h);
etat1.e = Exergie(etat1.h,etat1.s);

%etat 2
etat2 = struct;
etat2.p = etat3.p; %apport de chaleur isobare
[etat2.t,etat2.h,etat2.s] = Etat_compression(etat1.h,etat1.s,etat2.p,eta_siC);
etat2.x = NaN;
etat2.e = Exergie(etat2.h,etat2.s);

%%

%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculs des rendements %
%%%%%%%%%%%%%%%%%%%%%%%%%%

%Point de vue energetique

[PCI_massique, e_c, Cp, m_a1, fracR_c, fracR_O2, fracR_N2, fracP_CO2, fracP_H2O, fracP_O2, fracP_N2, p_part_H2O] = Combustion(fuel,lambda);

T_R = DewPoint(p_part_H2O) %point de rosee

h_f_ech = Enthalpie_Fumee(0, t_ech, fracP_CO2, fracP_H2O, fracP_O2, fracP_N2);
h_a = fracR_O2*Enthalpie(0, t_a, 'O2') + fracR_N2*Enthalpie(0, t_a, 'N2');
p_ech = ((lambda*m_a1+1)*h_f_ech - lambda*m_a1*h_a)/PCI_massique;

eta_cyclen = ((etat3.h-etat4.h)-(etat2.h-etat1.h))/(etat3.h-etat2.h)

eta_gen = 1 - p_calo - p_ech

eta_toten = eta_gen*eta_cyclen*eta_mec

m_v = P_e/eta_mec/((etat3.h-etat4.h)-(etat2.h-etat1.h)) %debit de vapeur [kg/s]
m_c = P_e/eta_toten/PCI_massique %debit de combustible [kg/s]
m_a = lambda*m_a1*m_c

P_prim_en = m_c*PCI_massique;
p_gen = P_prim_en*(1-eta_gen);
p_cyclen = (P_prim_en-p_gen)*(1-eta_cyclen);
p_mec_en = (P_prim_en-p_gen-p_cyclen)*(1-eta_mec);

data_en = [P_e p_mec_en p_cyclen p_gen];

%Point de vue exergetique

[m_f, e_f, e_ech, e_r] = Fumee(PCI_massique, e_c, Cp, m_a1, fracR_c, fracR_O2, fracR_N2, fracP_CO2, fracP_H2O, fracP_O2, fracP_N2, lambda, t_ech, m_c, dT_prechauf);

eta_cyclex = ((etat3.e-etat4.e)-(etat2.e-etat1.e))/(etat3.e-etat2.e)
eta_rotex = ((etat3.h-etat4.h)-(etat2.h-etat1.h))/((etat3.e-etat4.e)-(etat2.e-etat1.e))

eta_combex = m_f*(e_f - e_r)/(m_c*e_c)
eta_chemex = m_f*(e_f - e_ech)/(m_f*(e_f - e_r))
eta_transex = m_v*(etat3.e - etat2.e)/(m_f*(e_f - e_ech))
eta_gex = eta_combex*eta_chemex*eta_transex

eta_totex = eta_gex*eta_cyclex*eta_mec

P_prim_ex = m_c*e_c;
p_combex = P_prim_ex*(1-eta_combex);
p_chemex = (P_prim_ex-p_combex)*(1-eta_chemex);
p_transex = (P_prim_ex-p_combex-p_chemex)*(1-eta_transex);
p_cyclex = (P_prim_ex-p_combex-p_chemex-p_transex)*(1-eta_cyclex); %definition du livre p.68
p_rotex = (P_prim_ex-p_combex-p_chemex-p_transex-p_cyclex)*(1-eta_rotex);
p_mec_ex = (P_prim_ex-p_combex-p_chemex-p_transex-p_cyclex-p_rotex)*(1-eta_mec);

data_ex = [P_e p_mec_ex p_rotex p_cyclex p_transex p_chemex p_combex];

%%

%%%%%%%%%%%%%%%%%
% Tableau etats %
%%%%%%%%%%%%%%%%%

p = [etat1.p;etat2.p;etat3.p;etat4.p];
t = [etat1.t;etat2.t;etat3.t;etat4.t];
x = [etat1.x;etat2.x;etat3.x;etat4.x];
h = [etat1.h;etat2.h;etat3.h;etat4.h];
s = [etat1.s;etat2.s;etat3.s;etat4.s];
e = [etat1.e;etat2.e;etat3.e;etat4.e];
Etats = {'1';'2';'3';'4'};
Table = table(p,t,x,h,s,e,'RowNames',Etats)
 
%%

%%%%%%%%%%%%%
% Pie Chart %
%%%%%%%%%%%%%

%energetique

label_en = {sprintf('Puissance effective \n %1.1f MW ',data_en(1)/1e3)...
            sprintf('Pertes m�caniques \n %1.1f MW ',data_en(2)/1e3)...
            sprintf('Pertes au condenseur \n %1.1f MW ',data_en(3)/1e3)...
            sprintf('Pertes au g�n�rateur de vapeur \n %1.1f MW ',data_en(4)/1e3)};
   
figure;
pie(data_en,label_en);
titre = title(sprintf('Flux �nerg�tique primaire %1.1f MW',P_prim_en/1e3));
pos = get(titre,'position');
set(titre,'position',pos+[0 0.08 0]);

%exergetique

label_ex = {sprintf('Puissance effective \n %1.1f MW ',data_ex(1)/1e3)...
         sprintf('Pertes m�caniques \n %1.1f MW ',data_ex(2)/1e3)...
         sprintf('Irr�versibilit�s � la turbine et aux pompes \n %1.1f MW ',data_ex(3)/1e3)...
         sprintf('Pertes au condenseur \n %1.1f MW ',data_ex(4)/1e3)...
         sprintf('Irr�versibilit�s du transfert de chaleur au g�n�rateur de vapeur \n %1.1f MW ',data_ex(5)/1e3)...
         sprintf('Pertes � la chemin�e \n %1.1f MW ',data_ex(6)/1e3)...
         sprintf('Irr�versibilit�s de la combustion \n %1.1f MW ',data_ex(7)/1e3)};
         
figure;
pie(data_ex,label_ex);
titre = title(sprintf('Flux �nerg�tique primaire %1.1f MW',P_prim_ex/1e3));
pos = get(titre,'position');
set(titre,'position',pos+[0 0.08 0]);

%% 

%%%%%%%%%%%%%%%%%%%%%%
% Graphes T-s et h-s %
%%%%%%%%%%%%%%%%%%%%%%

%plot (T,s)
%DiagTS([s1,T1],[s2,T2],[s3,T3],[s4,T4]);

% length=10;
% T_12=linspace(T1,T2,length);
% T_23=linspace(T2,T3,length);
% T_34=linspace(T3,T4,length);
% T_41=linspace(T4,T1,length);
% 
% s_12=zeros(1,length);
% s_23=zeros(1,length);
% s_34=zeros(1,length);
% s_41=zeros(1,length);
% 
% h_12=zeros(1,length);
% h_23=zeros(1,length);
% h_34=zeros(1,length);
% h_41=zeros(1,length);

end