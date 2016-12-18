function [] = TV()
%main function

%%

%%%%%%%%%%%%%%
% Parametres %
%%%%%%%%%%%%%%

if nargin  == 0
    
    P_e = 35*10^3; %puissance effective [kW]
    deltaT = 10; %ecart entre T4 et la riviere
    eta_si_T = 0.88; %rendement isentropique turbine
    eta_si_C = 0.88; %rendement isentropique pompe
    eta_mec = 0.98; %rendement mecanique
    lambda = 1.05; %coefficient d'exces d'air
    fuel = 'CH4'; %combustible
    t_ech = 120; %temperature des fumees a l'echappement [�C]
    t_a = 15; %tempreature de l'air ambiant [�C]
    p_calo = 0.01; %perte par d�perditions calorifiques = 1% du PCI
    dT_prechauf = 0; %pas de prechauffe du combustible et de l'air

end

%%%%%%%%%%%
% Donnees %
%%%%%%%%%%%

t3 = 525; %[�C]
p3 = 40; %[bar] (200)
t_c = 15; %[�C]
t4 = t_c + deltaT; %[�C]

t0 = 15; %temperature de reference pour l'exergie [�C]
p0 = 1; %pression de reference [bar]
h0 = XSteam('h_pt',p0,t0);
s0 = XSteam('s_pt',p0,t0);

%On doit verifier ?
p_ech_min = 0.04; 
x_ech_min = 0.88;

%%

%%%%%%%%%%%%%%%%%%%%
% Calcul des etats %
%%%%%%%%%%%%%%%%%%%%

%etat 3
x3 = NaN;
h3 = XSteam('h_pt',p3,t3); %[kJ/kg]
s3 = XSteam('s_pt',p3,t3); %[kJ/kg.�C]
e3 = (h3-h0) - (t0+273.15)*(s3-s0);

%etat 4
p4 = XSteam('psat_T',t4); %[bar]
[x4,h4,s4] = Etat_detente(h3,s3,p4,eta_si_T);
e4 = (h4-h0) - (t0+273.15)*(s4-s0)

%etat 1
p1 = p4; %refroidissement isobare
t1 = t4; %car isobare
x1 = 0; %etat 1 sur la courbe x=0
h1 = XSteam('h_px',p1,x1);
s1 = XSteam('s_ph',p1,h1);
e1 = (h1-h0) - (t0+273.15)*(s1-s0);

%etat 2
p2 = p3; %apport de chaleur isobare
[t2,h2,s2] = Etat_compression(h1,s1,p2,eta_si_C);
x2 = NaN;
e2 = (h2-h0) - (t0+273.15)*(s2-s0);

%%

%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculs des rendements %
%%%%%%%%%%%%%%%%%%%%%%%%%%

%Point de vue energetique

eta_cyclen = ((h3-h4)-(h2-h1))/(h3-h2)

[PCI_massique, e_c, Cp, m_a1, fracR_c, fracR_O2, fracR_N2, fracP_CO2, fracP_H2O, fracP_O2, fracP_N2, p_part_H2O] = Combustion(fuel,lambda);

T_R = DewPoint(p_part_H2O) %point de rosee

h_f_ech = Enthalpie_Fumee(0, t_ech, fracP_CO2, fracP_H2O, fracP_O2, fracP_N2);
h_a = fracR_O2*Enthalpie(0, t_a, 'O2') + fracR_N2*Enthalpie(0, t_a, 'N2');
p_ech = ((lambda*m_a1+1)*h_f_ech - lambda*m_a1*h_a)/PCI_massique;

eta_gen = 1 - p_calo - p_ech

eta_toten = eta_gen*eta_cyclen*eta_mec

m_v = P_e/eta_mec/((h3-h4)-(h2-h1)) %debit de vapeur [kg/s]
m_c = P_e/eta_toten/PCI_massique %debit de combustible [kg/s]
m_a = lambda*m_a1*m_c

P_prim_en = m_c*PCI_massique;
p_gen = P_prim_en*(1-eta_gen);
p_cyclen = (P_prim_en-p_gen)*(1-eta_cyclen);
p_mec_en = (P_prim_en-p_gen-p_cyclen)*(1-eta_mec);

data_en = [P_e p_mec_en p_cyclen p_gen];

%Point de vue exergetique

[m_f, e_f, e_ech, e_r] = Fumee(PCI_massique, e_c, Cp, m_a1, fracR_c, fracR_O2, fracR_N2, fracP_CO2, fracP_H2O, fracP_O2, fracP_N2, lambda, t_ech, m_c, dT_prechauf);

eta_cyclex = ((e3-e4)-(e2-e1))/(e3-e2)
eta_rotex = ((h3-h4)-(h2-h1))/((e3-e4)-(e2-e1))

eta_combex = m_f*(e_f - e_r)/(m_c*e_c)
eta_chemex = m_f*(e_f - e_ech)/(m_f*(e_f - e_r))
eta_transex = m_v*(e3 - e2)/(m_f*(e_f - e_ech))
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

p = [p1;p2;p3;p4];
t = [t1;t2;t3;t4];
x = [x1;x2;x3;x4];
h = [h1;h2;h3;h4];
s = [s1;s2;s3;s4];
e = [e1;e2;e3;e4];
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