function [] = TGV(TGP_e, fuel_number, eta_piC, eta_piT, k_mec, T3, k_cc, r,PincementCondenseur ,T_condenseur,eta_is_pump,pressure2,delta_Ta,pressure3,eta_is_turbine,pincementBallon2,pincementBallon1,rendementMec)

if nargin == 0
TGP_e=230;%[MW]
fuel_number = 1;
eta_piC = 0.9;
eta_piT = 0.9;
k_mec = 0.015;
T3 = 1050; %[°C] valeur max
k_cc = 0.95;
r = 10;

%Ordre, noms (et valeurs?) à changer... :p
PincementCondenseur = 8
T_condenseur = 15
eta_is_pump = 0.9
pressure2 = 5.8
delta_Ta =15
pressure3 = 78
eta_is_turbine=0.9
pincementBallon2=10
pincementBallon1=10
rendementMec = 0.95
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Calculs de la turbine à gaz%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

A = TGforTGV(TGP_e, fuel_number, eta_piC, eta_piT, k_mec, T3, k_cc, r);

%Etat 4 de la TG%
p4g = double(A(1));
t4g = double(A(2));
h4g = double(A(3));
s4g = double(A(4));
e4g = double(A(5));

%Débits%
m_a = double(A(6));
m_c = double(A(7));

%Données combustion%
fuel = A(8);
PCI_massique = double(A(9));
ec = double(A(10));
lambda = double(A(11));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Calculs de la turbine à vapeur%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Etat de reference
T0 = 15; %[°C]
h0 = XSteam('h_pT', 1, T0);
s0 = XSteam('s_pT', 1, T0);

%Etat 1%

Etat1 = struct;
Etat1.p = XSteam('psat_T',T_condenseur);
Etat1.t = T_condenseur;
Etat1.h = XSteam('hL_T',T_condenseur);
Etat1.s = XSteam('sL_T',T_condenseur);
Etat1.e = (Etat1.h-h0)-(T0+273.15)*(Etat1.s-s0);
Etat1.x = NaN;

%Etat 2%

Etat2 = struct;
Etat2.p = pressure2;

dp = (Etat2.p-Etat1.p)*100;% On multiplie dp par 100 pour passer de bar à kPa 
v_12 =  XSteam('v_ph',Etat1.p,Etat1.h); % Invariant
Etat2.h =  Etat1.h + dp*v_12/eta_is_pump;
Etat2.t = XSteam('T_ph',Etat2.p,Etat2.h);
Etat2.s = XSteam('s_ph',Etat2.p,Etat2.h);
Etat2.e = (Etat2.h-h0)-(T0+273.15)*(Etat2.s-s0);
Etat2.x = NaN;

%Etat 3%

Etat3 = struct;
Etat3.t = t4g-delta_Ta;
Etat3.p = pressure3;
Etat3.h = XSteam('h_pT',Etat3.p,Etat3.t);
Etat3.s = XSteam('s_pT',Etat3.p,Etat3.t);
Etat3.e = (Etat3.h-h0)-(T0+273.15)*(Etat3.s-s0);

if Etat3.t == XSteam('Tsat_p',Etat3.p); %Si on est dans la cloche
        Etat3.x = XSteam('x_ph',Etat3.p,Etat3.h)
else
    Etat3.x = NaN
end

%Etat 4%
Etat4=struct;
Etat4.p=pressure2;
Etat4.h=Etat3.h+(XSteam('h_ps',Etat4.p,Etat3.s)-Etat3.h)*eta_is_turbine;

Etat4.t=XSteam('T_ph',Etat4.p,Etat4.h);
Etat4.s=XSteam('s_ph',Etat4.p,Etat4.h);
Etat4.e = (Etat4.h-h0)-(T0+273.15)*(Etat4.s-s0);

if Etat4.t == XSteam('Tsat_p',Etat4.p); %Si on est dans la cloche
        Etat4.x = XSteam('x_ph',Etat4.p,Etat4.h)
else
    Etat4.x = NaN
end

%Etat 5%

Etat5=struct;
Etat5.p=XSteam('psat_T', T_condenseur+PincementCondenseur);
Etat5.h=Etat4.h+(XSteam('h_ps',Etat5.p,Etat4.s)-Etat4.h)*eta_is_turbine;

Etat5.t=XSteam('T_ph',Etat5.p,Etat5.h);
Etat5.s=XSteam('s_ph',Etat5.p,Etat5.h);
Etat5.e = (Etat5.h-h0)-(T0+273.15)*(Etat5.s-s0);

if Etat5.t == XSteam('Tsat_p',Etat5.p); %Si on est dans la cloche
        Etat5.x = XSteam('x_ph',Etat5.p,Etat5.h)
else
    Etat5.x = NaN
end

%%%%%%%%%%%%%%%%%%%
%Calcul des débits%
%%%%%%%%%%%%%%%%%%%

T_sat_HP = XSteam('Tsat_p',Etat3.p);
T_sat_BP = XSteam('Tsat_p',Etat4.p);

%combustible->frac molaire
%->frac molaire->fumée->hf
[PCI_massique, e_c, Cp, m_a1, fracR_c, fracR_O2, fracR_N2, fracP_CO2, fracP_H2O, fracP_O2, fracP_N2] = Combustion(fuel,lambda)
hf_HP=Fumee(PCI_massique, e_c, Cp, m_a1, fracR_c, fracR_O2, fracR_N2, fracP_CO2, fracP_H2O, fracP_O2, fracP_N2, lambda, T_satHP + pincementBallon2)
hf_BP=Fumee(PCI_massique, e_c, Cp, m_a1, fracR_c, fracR_O2, fracR_N2, fracP_CO2, fracP_H2O, fracP_O2, fracP_N2, lambda, T_satBP + pincementBallon1)

%HP%
h_HP_liq = XSteam('hL_p',state_3.p);
h_HP_vap = XSteam('hV_p',state_3.p);
m3=(m_a+m_c)*(h4g - hf_HP)/(state_3.h-h_HP_liq);

% Enthalpie au ballon basse pression (liquide saturee)
h_satBPliq = XSteam('hL_p',state_4.p);
h_satBPvap = XSteam('hV_p',state_4.p);

stateBeforePump = struct;
stateBeforePump.p = state_4.p;
stateBeforePump.h = h_satBPliq;
state = pump(state_3.p,eta_is,stateBeforePump);
h_pumpBP = state.h;

m4 = (mf*(hg_satHP-hg_satBP)- m3*(h_HP_liq-h_pumpBP))/(state_4.h-h_satBPliq);

end



%%%%%%%%%%%
%Affichage%
%%%%%%%%%%%

% fig1=figure('units','normalized','outerposition',[0 0 1 1]);
% 
% text1 = uicontrol( fig1 , 'style' , 'text' , 'position' , [600,740,300,40] ,...
%     'string' , 'Résulats' , 'fontsize' , 30 )
% 
% subplot ( 'Position' , [ .38 .6 .2 .3 ] ) ;
% plot(s_12,h_12,'blue')
% hold on;
% plot(s_23,h_23,'blue')
% plot(s_34,h_34,'blue')
% plot(s_41,h_41,'--blue')
% text(s1,h1,'\leftarrowEtat 1')
% text(s2,h2,'\leftarrowEtat 2')
% text(s3,h3,'\leftarrowEtat 3')
% text(s4,h4,'\leftarrowEtat 4')
% title('Graphe h-s')
% xlabel('Entropie [J/kgK]')
% ylabel('Enthalpie [kJ/kg]')
% subplot ( 'Position' , [ .38 .1 .2 .3 ] ) ;
% 
% plot(s_12,T_12,'blue')
% hold on;
% plot(s_23,T_23,'blue')
% plot(s_34,T_34,'blue')
% plot(s_41,T_41,'--blue')
% text(s1,T1,'\leftarrowEtat 1')
% text(s2,T2,'\leftarrowEtat 2')
% text(s3,T3,'\leftarrowEtat 3')
% text(s4,T4,'\leftarrowEtat 4')
% title('Graphe T-s')
% xlabel('Entropie [J/kgK]')
% ylabel('Température [K]')
% 
% %%%%%%%%%%%%
% %Pie Chart%
% %%%%%%%%%%%%
% 
% %Energetique%
% 
% P_prim_en=m_c*PCI_massique;
% P_echap_en = (h4-e1)*m_g;
% P=[double(P_e) double(P_fmec) double(P_echap_en)];
% 
% label={sprintf('Puissance effective \n %0.1f MW ',P_e/1e3)...
%     sprintf('Pertes mécaniques \n %0.1f MW ',P_fmec/1e3)...
%     sprintf('Pertes à l''échappement: \n %0.1f MW ',P_echap_en/1e3)};
% subplot ( 'Position' , [ .61 .52 .3 .45 ] ) ;
% pie(P,label);
% title(sprintf('Distribution du flux énergétique avec puissance primaire de %0.1f  MW',P_prim_en/1e3 ));
% 
% %Exergetique%
% 
% P_prim_ex=ec*m_c;
% P_irr_comb = P_prim_ex*(1-eta_combex);
% P_echap_ex = (e4-e1)*m_g;
% P_irr_tc = (e3-e4)*m_g - (e2-e1)*m_a- (h3-h4)*m_g + (h2-h1)*m_a;
% P=[double(P_e) double(P_fmec) double(P_irr_tc) double(P_echap_ex) double(P_irr_comb)];
% 
% label={sprintf('Puissance effective \n %0.1f MW ',P_e/1e3)...
%     sprintf('Pertes mécaniques \n %0.1f MW ',P_fmec/1e3)...
%     sprintf('Irréversibilités à la turbine et au compresseur \n %0.1f MW ',P_irr_tc/1e3)...
%     sprintf('Pertes à l''échappement: \n %0.1f MW ',P_echap_ex/1e3)...
%     sprintf('Irréversibilités de la combustion: \n %0.1f MW ',P_irr_comb/1e3)};
% 
% subplot ( 'Position' , [ .61 0.02 .3 .45 ] ) ;
% pie(P,label);
% title(sprintf('Distribution du flux exergétique avec puissance primaire de %0.1f  MW',P_prim_ex/1e3 ));
% 
% %%%%%%%%%%%%%%%%%%%%%%%
% %Tableaux des résulats%
% %%%%%%%%%%%%%%%%%%%%%%%
% %Caractéristiques des états$
% p=[p1;p2;p3;p4]./1000;
% T=[T1;T2;T3;T4]-273.15;
% h=[h1;h2;h3;h4];
% s=[s1;s2;s3;s4];
% e=[e1;e2;e3;e4];
% Etats={'1';'2';'3';'4'};
% 
% Table = table(p,T,h,s,e,'RowNames',Etats)
% 
% 
% text1 = uicontrol( fig1 , 'style' , 'text' , 'position' , [170,720,300,40] ,...
%     'string' , 'Caractéristiques des états' , 'fontsize' , 15 )
% t1 = uitable(fig1);
% t1.Data = table2cell(Table);
% t1.Position = [140 615 338 108];
% t1.ColumnName = {'p [kPa]','T [°C]','h [kJ/kg]','s [kJ/kgK]','e [kJ/kg]'};
% 
% %Rendements$
% text2 = uicontrol( fig1 , 'style' , 'text' , 'position' , [170,550,300,40] ,...
%     'string' , 'Rendements' , 'fontsize' , 15 )
% ETAt=[double(eta_cyclen); double(eta_mec); double(eta_toten); double(eta_rotex); double(eta_cyclex); double(eta_combex); double(eta_totex)]
% ETA=table(ETAt,'RowNames',{'eta_cyclen'; 'eta_mec'; 'eta_toten'; 'eta_rotex'; 'eta_cyclex'; 'eta_combex'; 'eta_totex'})
% t2 = uitable(fig1);
% t2.Data = table2cell(ETA)%{eta_cyclen; eta_mec; eta_toten; eta_rotex; eta_cyclex; eta_combex; eta_totex}
% t2.Position = [210 390 200 160];
% t2.RowName = {'eta_cyclen','eta_mec','eta_toten','eta_rotex','eta_cyclex','eta_combex','eta_totex'};
% t2.ColumnName= {''}
% 
% %Puissances$
% text3 = uicontrol( fig1 , 'style' , 'text' , 'position' , [40,320,300,40] ,...
%     'string' , 'Puissances [MW]' , 'fontsize' , 15 )
% PUISSANCEt=[double(P_mT); double(P_mC); double(P_fmec); double(P_prim_en); double(P_echap_en); double(P_prim_ex); double(P_irr_comb);double(P_echap_ex);double(P_irr_tc)]/1000
% PUISSANCE=table(PUISSANCEt,'RowNames',{'P_mT'; 'P_mC'; 'P_fmec'; 'P_prim_en'; 'P_echap_en'; 'P_prim_ex'; 'P_irr_comb';'P_echap_ex';'P_irr_tc'})
% t3 = uitable(fig1);
% t3.Data = table2cell(PUISSANCE)%{eta_cyclen; eta_mec; eta_toten; eta_rotex; eta_cyclex; eta_combex; eta_totex}
% t3.Position = [80 115 205 195];
% t3.RowName = {'P_mT'; 'P_mC'; 'P_fmec'; 'P_prim_en'; 'P_echap_en'; 'P_prim_ex'; 'P_irr_comb';'P_echap_ex';'P_irr_tc'};
% t3.ColumnName= {''}
% 
% %Débits$
% text4 = uicontrol( fig1 , 'style' , 'text' , 'position' , [270,320,300,40] ,...
%     'string' , 'Débits [kg/s]' , 'fontsize' , 15 )
% DEBITSt=[double(m_a); double(m_c)]
% DEBITS=table(DEBITSt,'RowNames',{'Air'; 'Carburant'})
% t4 = uitable(fig1);
% t4.Data = table2cell(DEBITS)%{eta_cyclen; eta_mec; eta_toten; eta_rotex; eta_cyclex; eta_combex; eta_totex}
% t4.Position = [315 240 190 70];
% t4.RowName = {'Air'; 'Carburant'};
% t4.ColumnName= {''}
% 
% text5 = uicontrol( fig1 , 'style' , 'text' , 'position' , [320,180,200,40] ,...
%     'string' , 'Temp. de rosée [°C]' , 'fontsize' , 15 )
% ROSEE=table(T_rosee,'RowNames',{'T_rosee'})
% t5 = uitable(fig1);
% t5.Data = table2cell(ROSEE)%{eta_cyclen; eta_mec; eta_toten; eta_rotex; eta_cyclex; eta_combex; eta_totex}
% t5.Position = [335 140 150 48];
% t5.RowName = {'T_rosee'};
% t5.ColumnName= {''}
% 
% %Boutons%
% bp1 = uicontrol ( fig1 , 'style' , 'push' , 'position' , [70 50 200 30 ] ,...
%     'string' , 'Nouvelle Turbine à gaz' , 'callback' , @(bp1,eventdata)GUI_2(2))
% 
% bp2 = uicontrol ( fig1 , 'style' , 'push' , 'position' , [300 50 200 30 ] ,...
%     'string' , 'Retour au menu principal' , 'callback' , @(bp2,eventdata)GUI())
% 

end

