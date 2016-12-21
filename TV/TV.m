function [] = TV(P_e, fuel_number, n_souti, n_resurch, t3, p3, rapport_HP, t_sf, dT_cond, eta_siT, eta_siP, eta_mec, lambda, t_ech, t_a, p_calo, dT_prechauf, phi_air_in, t_air_in)

%Turbine a vapeur - main function

%%

%%%%%%%%%%%%%%
% Parametres %
%%%%%%%%%%%%%%

if nargin  == 0
    
    P_e = 288*10^3; %puissance effective  /!\ [kW] /!\
    
    n_souti = 8; %nombre de soutirage
    n_resurch = 1; %nombre de resurchauffe 
    
    t3 = 525; %temperature de vapeur vive apres le generateur de vapeur [°C]
    p3 = 200; %pression de vapeur vive apres le generateur de vapeur [bar]
    rapport_HP = 0.15; %rapport de détente dans le corps HP 
    t_sf = 15; %temperature source froide (riviere) [°C]
    dT_cond = 10; %ecart de temperature entre le condenseur et la riviere
    eta_siT = 0.88; %rendement isentropique turbine
    eta_siP = 0.88; %rendement isentropique pompe
    eta_mec = 0.98; %rendement mecanique
    lambda = 1.05; %coefficient d'exces d'air
    fuel_number = 1; %combustible
    t_ech = 120; %temperature des fumees a l'echappement [°C]
    p_calo = 0.01; %perte par déperditions calorifiques = 1% du PCI
    dT_prechauf = 0; %prechauffe du combustible et du comburant
    
    %tour de refroidissement
    t_air_in = 15; %temperature de l'air a l'entree de la tour
    phi_air_in = 0.8; %humidite relative de l'air a l'entree de la tour
   
end

t6 = t_sf + dT_cond; %temperature a l'entree du condenseur [°C]
t_a = 15; %temperature de l'air ambiant [°C]
t_sf_out = t6; %temperature de l'eau de refroidissement après le condenseur
p_air = 1; %pression de l'air de la tour [bar]
t_air_out = t_sf_out; %temperature de l'air a la sortie de la tour
phi_air_out = 1; %humidite relative de l'air a la sortie de la tour

if fuel_number == 1
fuel='CH4'
elseif fuel_number ==2
fuel='C12H23'
elseif fuel_number == 3
fuel='C'
elseif fuel_number == 4
fuel='CH1.8'
elseif fuel_number == 5
fuel='C3H8'
elseif fuel_number == 6
fuel='H2'
elseif fuel_number == 7
fuel='CO'
end

%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calcul des etats et des fractions soutirées %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%etat 3
etat3 = Etat3(p3,t3);

%etat 4
etat4 = Etat4(n_resurch,etat3,rapport_HP,eta_siT);

%etat 5
etat5 = Etat5(n_resurch,etat3,etat4);

%etat 6
etat6 = Etat6(etat5,t6,eta_siT);

%etats 6n
etat6_n = Etat6_n(n_souti,n_resurch,etat4,etat5,etat6,eta_siT);

%etat 7
etat7 = Etat7(etat6);

if n_souti > 3 %la bache alimentaire n'existe que s'il y a plus de 3 soutirages
    t_9_3 = XSteam('Tsat_p',etat6_n(3).p);
    p_bache = XSteam('psat_T',t_9_3+20);
else
    p_bache = 0;
end

p1 = 50; 

if n_souti == 0 %pas de soutirage
    
    etat7_n = Etat7_n(n_souti,etat6_n,p_bache);
    etat8 = Etat8(n_souti,etat7,p_bache,p1,eta_siP);
    etat9_n = Etat9_n(n_souti,etat6_n,etat7_n,etat8,p_bache,p1,eta_siP);
    
    etat1 = etat8;
    etat2 = Etat2(etat1,p3,eta_siP);
    
    X = 0;
    
else
    
    boolean = 1;
    while boolean
        p_bache = p_bache + 0.1;
        etat7_n = Etat7_n(n_souti,etat6_n,p_bache);
        etat8 = Etat8(n_souti,etat7,p_bache,p1,eta_siP);
        etat9_n = Etat9_n(n_souti,etat6_n,etat7_n,etat8,p_bache,p1,eta_siP);
        
        while XSteam('Tsat_p',etat9_n(n_souti).p) < etat9_n(n_souti).t
            p1 = p1 + 10;
            etat7_n = Etat7_n(n_souti,etat6_n,p_bache);
            etat8 = Etat8(n_souti,etat7,p_bache,p1,eta_siP);
            etat9_n = Etat9_n(n_souti,etat6_n,etat7_n,etat8,p_bache,p1,eta_siP);
        end
        
        etat1 = etat9_n(n_souti);
        etat2 = Etat2(etat1,p3,eta_siP);
        
        %calcul des fractions soutirees
        iter = (etat8.h + etat9_n(1).h)/2; %entre le sous-refroidisseur et le 1er rechauffeur
        h9_0 = fsolve(@(h9_0) Soutirage_Verif(n_souti,etat6_n,etat7,etat7_n,etat8,etat9_n,h9_0),iter);
        X = Soutirage_X(n_souti,etat6_n,etat7,etat7_n,etat8,etat9_n,h9_0);
        
        boolean = 0;
        for i = 1:length(X)
            if X(i) < 0
                boolean = 1;
            end
        end 
    end %fin boucle while boolean
    
end %fin boucle if

%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculs des rendements et des debits %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

W_pompe = (etat2.h-etat1.h) + (etat8.h-etat7.h);
W_turbine = (etat3.h-etat4.h) + (etat5.h-etat6.h);

for i = 1:(n_souti-n_resurch)
    W_turbine = W_turbine + X(i)*(etat5.h-etat6_n(i).h);
end

for i = 1:n_souti
    W_turbine = W_turbine + X(i)*(etat3.h-etat4.h);
    W_pompe = W_pompe + X(i)*(etat2.h-etat1.h);
end

if n_souti >= 4
    for i = 1:3
        W_pompe = W_pompe + X(i)*(etat8.h-etat7.h);
    end
    for i = 1:n_souti
        W_pompe = W_pompe + X(i)*(etat9_n(4).h-etat7_n(4).h);
    end
else
    for i = 1:n_souti
        W_pompe = W_pompe + X(i)*(etat8.h-etat7.h);
    end
end

m_vC = P_e/((W_turbine - W_pompe)*eta_mec); %debit au condenseur
m_vG = m_vC*(1+sum(X)); %debit au generateur de vapeur
m_vS = m_vC*X; %debit total soutiré
m_v5 = m_vC*(1+sum(X(1:n_souti-1))); %debit apres resurchauffe

if n_souti < 4
    m_L7 = m_vG; %debit d'eau après le condenseur
else
    m_L7 = m_vC*(1+sum(X(1:3)));
end

[PCI_massique, e_c, Cp, m_a1, fracR_c, fracR_O2, fracR_N2, fracP_CO2, fracP_H2O, fracP_O2, fracP_N2, p_part_H2O] = Combustion(fuel,lambda); 

h_f_ech = Enthalpie_Fumee(0, t_ech, fracP_CO2, fracP_H2O, fracP_O2, fracP_N2);
h_a = fracR_O2*Enthalpie(0, t_a, 'O2') + fracR_N2*Enthalpie(0, t_a, 'N2');
p_ech = ((lambda*m_a1+1)*h_f_ech - lambda*m_a1*h_a)/PCI_massique;
eta_gen = 1 - p_calo - p_ech; %eta_gen

%le débit de combustible varie s'il y a resurchauffe ou pas
if n_resurch == 0
    m_c = m_vG*(etat3.h-etat2.h)/eta_gen/PCI_massique;
else
    m_c = (m_vG*(etat3.h-etat2.h) + m_v5*(etat5.h-etat4.h))/eta_gen/PCI_massique;
end

m_a = lambda*m_a1*m_c; %debit d'air

[m_f, e_f, e_ech, e_r] = Fumee(PCI_massique, e_c, Cp, m_a1, fracR_c, fracR_O2, fracR_N2, fracP_CO2, fracP_H2O, fracP_O2, fracP_N2, lambda, t_ech, m_c, dT_prechauf);

eta_combex = m_f*(e_f - e_r)/(m_c*e_c);
eta_chemex = m_f*(e_f - e_ech)/(m_f*(e_f - e_r));
if n_resurch == 0
    eta_transex = m_vG*(etat3.e-etat2.e)/(m_f*(e_f - e_ech));
else
    eta_transex = (m_vG*(etat3.e-etat2.e) + m_v5*(etat5.e-etat4.e))/(m_f*(e_f - e_ech));
end
eta_gex = eta_combex*eta_chemex*eta_transex;

eta_cyclen_num = m_vG/m_vC*((etat3.h-etat4.h)-(etat2.h-etat1.h)) - m_L7/m_vC*(etat8.h-etat7.h) + (etat5.h-etat6.h);
eta_cyclen_den = m_vG/m_vC*(etat3.h-etat2.h) + m_v5/m_vC*(etat5.h-etat4.h);

for i = 1:(n_souti-n_resurch)
    eta_cyclen_num = eta_cyclen_num + X(i)*(etat5.h-etat6_n(i).h);
end
if n_souti > 3 
    eta_cyclen_num = eta_cyclen_num - m_vG/m_vC*(etat9_n(4).h-etat7_n(4).h);
end

%----------Rendements energetiques----------
eta_gen;
eta_cyclen = eta_cyclen_num/eta_cyclen_den;
eta_mec;
eta_toten = eta_gen*eta_cyclen*eta_mec;
%-------------------------------------------

eta_rotex_num = (etat3.h-etat4.h) + (etat5.h-etat6.h) - (etat2.h-etat1.h);
eta_rotex_den = (etat3.e-etat4.e) + (etat5.e-etat6.e) - (etat2.e-etat1.e);

for i = 1:(n_souti-n_resurch)
    eta_rotex_num = eta_rotex_num + X(i)*(etat5.h-etat6_n(i).h);
    eta_rotex_den = eta_rotex_den + X(i)*(etat5.e-etat6_n(i).e);
end
for i = 1:n_souti
    eta_rotex_num = eta_rotex_num + X(i)*(etat3.h-etat4.h) - X(i)*(etat2.h-etat1.h);
    eta_rotex_den = eta_rotex_den + X(i)*(etat3.e-etat4.e) - X(i)*(etat2.e-etat1.e);
end

eta_cyclex_num = eta_rotex_den;
eta_cyclex_den = m_vG/m_vC*(etat3.e-etat2.e) + m_v5/m_vC*(etat5.e-etat4.e);

%----------Rendements exergetiques----------
eta_gex;
eta_rotex = eta_rotex_num/eta_rotex_den;
eta_cyclex = eta_cyclex_num/eta_cyclex_den*eta_rotex;
eta_mec;
eta_totex = eta_gex*eta_cyclex*eta_mec;
%-------------------------------------------

%%

%%%%%%%%%%%%%%%%%%
% Point de rosée %
%%%%%%%%%%%%%%%%%%

T_R = DewPoint(p_part_H2O); 

%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Tour de refroidissement %
%%%%%%%%%%%%%%%%%%%%%%%%%%%

[m_eau,m_vap,m_air,x_air_in,x_air_out] = Tour_ref(etat6,etat7,m_vC,t_sf,t_sf_out,p_air,t_air_in,t_air_out,phi_air_in,phi_air_out);

%%

%%%%%%%%%%%%%%%%%
% Tableau etats %
%%%%%%%%%%%%%%%%%
fig1=figure('units','normalized','outerposition',[0 0 1 1]);
text1 = uicontrol( fig1 , 'style' , 'text' , 'position' , [175,880,300,40] ,...
    'string' , 'Résulats' , 'fontsize' , 30 )

p = [etat1.p;etat2.p;etat3.p;etat4.p;etat5.p;etat6.p;etat7.p;etat8.p;etat9_n(1).p];
t = [etat1.t;etat2.t;etat3.t;etat4.t;etat5.t;etat6.t;etat7.t;etat8.t;etat9_n(1).t];
x = [etat1.x;etat2.x;etat3.x;etat4.x;etat5.x;etat6.x;etat7.x;etat8.x;etat9_n(1).x];
h = [etat1.h;etat2.h;etat3.h;etat4.h;etat5.h;etat6.h;etat7.h;etat8.h;etat9_n(1).h];
s = [etat1.s;etat2.s;etat3.s;etat4.s;etat5.s;etat6.s;etat7.s;etat8.s;etat9_n(1).s];
e = [etat1.e;etat2.e;etat3.e;etat4.e;etat5.e;etat6.e;etat7.e;etat8.e;etat9_n(1).e];
Etats = {'1';'2';'3';'4';'5';'6';'7';'8';'9'};
Table = table(p,t,x,h,s,e,'RowNames',Etats);

text1 = uicontrol( fig1 , 'style' , 'text' , 'position' , [170,700,330,40] ,...
    'string' , 'Caractéristiques des états de la TV' , 'fontsize' , 15 )
t1 = uitable(fig1);
t1.Data = table2cell(Table);
t1.Position = [75 500 500 198];
t1.ColumnName = {'p [kPa]','T [°C]','x','h [kJ/kg]','s [kJ/kgK]','e [kJ/kg]'};
 
%%

%%%%%%%%%%%%%
% Pie Chart %
%%%%%%%%%%%%%

P_prim_en = m_c*PCI_massique;
p_gen = P_prim_en*(1-eta_gen);
p_cyclen = (P_prim_en-p_gen)*(1-eta_cyclen);
p_mec_en = (P_prim_en-p_gen-p_cyclen)*(1-eta_mec);

data_en = [P_e p_mec_en p_cyclen p_gen];

P_prim_ex = m_c*e_c;
p_combex = P_prim_ex*(1-eta_combex);
p_chemex = (P_prim_ex-p_combex)*(1-eta_chemex);
p_transex = (P_prim_ex-p_combex-p_chemex)*(1-eta_transex);
p_condensex = m_vC*(etat6.e-etat7.e);
p_echangex = m_vC*etat7.e - m_vG*(etat1.e);
if n_souti > 3
    p_echangex = p_echangex + m_vG*(etat9_n(4).e-etat7_n(4).e);
end
for i = 1:n_souti
    p_echangex = p_echangex + m_vC*X(i)*etat6_n(i).e;
end
p_rotex = (P_prim_ex-p_combex-p_chemex-p_transex-p_condensex-p_echangex)*(1-eta_rotex);
p_mec_ex = (P_prim_ex-p_combex-p_chemex-p_transex-p_condensex-p_echangex-p_rotex)*(1-eta_mec);

data_ex = [P_e p_mec_ex p_condensex p_rotex p_echangex p_transex p_chemex p_combex];

%energetique

label_en = {sprintf('\n %1.1f MW ',data_en(1)/1e3)...
            sprintf('\n %1.1f MW ',data_en(2)/1e3)...
            sprintf('\n %1.1f MW ',data_en(3)/1e3)...
            sprintf('\n %1.1f MW ',data_en(4)/1e3)};
   
subplot ( 'Position' , [ .66 .51 .3 .45 ] ) ;
pie(data_en,label_en);
title(sprintf('Flux énergétique primaire %1.1f MW',P_prim_en/1e3));
legend('Puissance effective','Pertes mécaniques','Perte au condenseur','Pertes au générateur de vapeur');

%exergetique

label_ex = {sprintf('\n %1.1f MW ',data_ex(1)/1e3)...
         sprintf('\n %1.1f MW ',data_ex(2)/1e3)...
         sprintf('\n %1.1f MW ',data_ex(3)/1e3)...
         sprintf('\n %1.1f MW ',data_ex(4)/1e3)...
         sprintf('\n %1.1f MW ',data_ex(5)/1e3)...
         sprintf('\n %1.1f MW ',data_ex(6)/1e3)...
         sprintf('\n %1.1f MW ',data_ex(7)/1e3)...
         sprintf('\n %1.1f MW ',data_ex(8)/1e3)};
     
subplot ( 'Position' , [ .66 0.02 .3 .45 ] ) ;
pie(data_ex,label_ex);
title(sprintf('Flux énergétique primaire %1.1f MW',P_prim_ex/1e3));
legend('Puissance effective','Pertes mécaniques','Perte au condenseur',...
       'Irréversibilités aux turbines et pompes',...
       'Irréversibilité du transfert de chaleur aux réchauffeurs',...
       'Irréversibilité du transfert de chaleur au générateur de vapeur',...
       'Perte à la cheminée','Irréversibilité de la combustion');

%% 

%%%%%%%%%%%%%%%%%%%%%%
% Graphes T-s et h-s %
%%%%%%%%%%%%%%%%%%%%%%

subplot ( 'Position' , [ .42 .13 .2 .3 ] ) ;
TS(n_souti,n_resurch,etat1,etat2,etat3,etat4,etat5,etat6,etat6_n,etat7,etat7_n,etat8,etat9_n,eta_siT);
subplot ( 'Position' , [ .42 .6 .2 .3 ] ) ;
HS(n_souti,n_resurch,etat1,etat2,etat3,etat4,etat5,etat6,etat6_n,etat7,etat7_n,etat8,etat9_n,eta_siT);

%Autres données affichées%
%Débits%
text4 = uicontrol( fig1 , 'style' , 'text' , 'position' , [445,440,300,40] ,...
    'string' , 'Débits [kg/s]' , 'fontsize' , 15 )
DEBITSt=[double(m_eau); double(m_vap); double(m_air); double(m_c)]
DEBITS=table(DEBITSt,'RowNames',{'Eau'; 'Vapeur';'Air';'Carburant'})
t4 = uitable(fig1);
t4.Data = table2cell(DEBITS)%{eta_cyclen; eta_mec; eta_toten; eta_rotex; eta_cyclex; eta_combex; eta_totex}
t4.Position = [480 320 193 110];
t4.RowName = {'Air'; 'Carburant';'Air';'Carburant'};
t4.ColumnName= {''}

%Point de rosée%
text5 = uicontrol( fig1 , 'style' , 'text' , 'position' , [485,240,200,40] ,...
    'string' , 'Temp. de rosée [°C]' , 'fontsize' , 15 )
T_rosee=DewPoint(p_part_H2O);
ROSEE=table(T_rosee,'RowNames',{'T_rosee'})
t5 = uitable(fig1);
t5.Data = table2cell(ROSEE);
t5.Position = [500 180 165 58];
t5.RowName = {'T_rosee'};
t5.ColumnName= {''}

%Rendements%
text2 = uicontrol( fig1 , 'style' , 'text' , 'position' , [0,440,300,40] ,...
    'string' , 'Rendements' , 'fontsize' , 15 )
ETAt=[double(eta_gen); double(eta_cyclen); double(eta_mec); double(eta_toten); double(eta_gex); double(eta_rotex); double(eta_cyclex); double(eta_totex)]
ETA=table(ETAt,'RowNames',{'eta_gen','eta_cyclen','eta_mec','eta_toten','eta_gex','eta_rotex','eta_cyclex','eta_totex'})
t2 = uitable(fig1);
t2.Data = table2cell(ETA)%{eta_cyclen; eta_mec; eta_toten; eta_rotex; eta_cyclex; eta_combex; eta_totex}
t2.Position = [50 250 200 180];
t2.RowName = {'eta_gen','eta_cyclen','eta_mec','eta_toten','eta_gex','eta_rotex','eta_cyclex','eta_totex'};
t2.ColumnName= {''}

%Puissances%
data_en = [P_e; p_mec_en; p_cyclen; p_gen]./1000;
data_ex = [p_condensex;p_rotex; p_echangex; p_transex; p_chemex; p_combex]./1000;

text3 = uicontrol( fig1 , 'style' , 'text' , 'position' , [230,440,300,40] ,...
    'string' , 'Puissances [MW]' , 'fontsize' , 15 )
PUISSANCEt=[data_en;data_ex]
PUISSANCE=table(PUISSANCEt,'RowNames',{'P_e'; 'p_mec_en'; 'p_cyclen'; 'p_gen';'p_condensex';'p_rotex'; 'p_echangex'; 'p_transex'; 'p_chemex'; 'p_combex'})
t3 = uitable(fig1);
t3.Data = table2cell(PUISSANCE)%{eta_cyclen; eta_mec; eta_toten; eta_rotex; eta_cyclex; eta_combex; eta_totex}
t3.Position = [260 210 210 220];
t3.RowName = {'P_e'; 'p_mec_en'; 'p_cyclen'; 'p_gen';'p_condensex';'p_rotex'; 'p_echangex'; 'p_transex'; 'p_chemex'; 'p_combex'};
t3.ColumnName= {''}

%Boutons%
bp1 = uicontrol ( fig1 , 'style' , 'push' , 'position' , [70 50 200 30 ] ,...
    'string' , 'Nouvelle Turbine à vapeur' , 'callback' , @(bp1,eventdata)GUI_2(1))

bp2 = uicontrol ( fig1 , 'style' , 'push' , 'position' , [300 50 200 30 ] ,...
    'string' , 'Retour au menu principal' , 'callback' , @(bp2,eventdata)GUI())

end