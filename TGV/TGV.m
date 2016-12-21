function [] = TGV(P_eTG, fuel_number, eta_piC, eta_piT, k_mec, T3, k_cc, r , eta_isP, eta_isT, eta_mec, p2, p3, delta_Ta, t_cond, pinch_cond, pinch_HP, pinch_BP)

if nargin == 0
P_eTG=300;%[MW]
fuel_number = 1;
eta_piC = 0.9;
eta_piT = 0.9;
k_mec = 0.015;
T3 = 1050; %[°C] valeur max
k_cc = 0.95;
r = 10;

eta_isP = 0.9;
eta_isT=0.9;
eta_mec = 0.95;
p2 = 5.8;
p3 = 78;
t_cond = 15;
delta_Ta =15;
pinch_cond = 10;
pinch_HP=10;
pinch_BP=10;

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Calculs de la turbine à gaz%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

A = TGforTGV(P_eTG, fuel_number, eta_piC, eta_piT, k_mec, T3, k_cc, r);

%Etats de la TG%
p1g = double(A(1,1));
p2g = double(A(2,1));
p3g = double(A(3,1));
p4g = double(A(4,1));
t1g = double(A(1,2));
t2g = double(A(2,2));
t3g = double(A(3,2));
t4g = double(A(4,2));
h1g = double(A(1,3));
h2g = double(A(2,3));
h3g = double(A(3,3));
h4g = double(A(4,3));
s1g = double(A(1,4));
s2g = double(A(2,4));
s3g = double(A(3,4));
s4g = double(A(4,4));
e1g = double(A(1,5));
e2g = double(A(2,5));
e3g = double(A(3,5));
e4g = double(A(4,5));

%Débits%
m_a = double(A(1,6));
m_c = double(A(1,7));

%Données combustion%
fuel = char(A(1,8))
PCI_massique = double(A(1,9));
e_c = double(A(1,10));
lambda = double(A(1,11));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Calculs de la turbine à vapeur%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Etat de reference
T0 = 15; %[°C]
h0 = XSteam('h_pT', 1, T0);
s0 = XSteam('s_pT', 1, T0);

%Etat 1%

etat1 = struct;
etat1.t = t_cond+pinch_cond;
etat1.p = XSteam('psat_T',etat1.t);
etat1.h = XSteam('hL_T',etat1.t);
etat1.s = XSteam('sL_T',etat1.t);
etat1.e = Exergie(etat1.h,etat1.s);
etat1.x = NaN;

%Etat 2%

etat2 = struct;
etat2.p = p2;

dp = (etat2.p-etat1.p)*100;% On multiplie dp par 100 pour passer de bar à kPa 
v_12 =  XSteam('v_ph',etat1.p,etat1.h); % volume supposé constant durant la compression
etat2.h =  etat1.h + dp*v_12/eta_isP;
etat2.t = XSteam('T_ph',etat2.p,etat2.h);
etat2.s = XSteam('s_ph',etat2.p,etat2.h);
etat2.e = Exergie(etat2.h,etat2.s);
etat2.x = NaN;

%Etat 3%

etat3 = struct;
etat3.t = t4g-delta_Ta;
etat3.p = p3;
etat3.h = XSteam('h_pT',etat3.p,etat3.t);
etat3.s = XSteam('s_pT',etat3.p,etat3.t);
etat3.e = Exergie(etat3.h,etat3.s);
etat3.x = NaN;


%Etat 4%
etat4 = struct;
etat4.p = p2;
etat4.h = etat3.h+(XSteam('h_ps',etat4.p,etat3.s)-etat3.h)*eta_isT;

etat4.t = XSteam('T_ph',etat4.p,etat4.h);
etat4.s = XSteam('s_ph',etat4.p,etat4.h);
etat4.e = Exergie(etat4.h,etat4.s);
etat4.x = NaN;

%Etat 5%
etat5 = struct;
etat5.p = XSteam('psat_T', t_cond+pinch_cond);
etat5.h = etat4.h+(XSteam('h_ps',etat5.p,etat4.s)-etat4.h)*eta_isT;

etat5.t = XSteam('T_ph',etat5.p,etat5.h);
etat5.s = XSteam('s_ph',etat5.p,etat5.h);
etat5.e = Exergie(etat5.h,etat5.s);
etat5.x = XSteam('x_ph',etat5.p,etat5.h);
if etat5.x>1 || etat5.x<0
    etat5.x = NaN;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Calcul des débits (et des états avant et après la pompe)%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

T_HP = XSteam('Tsat_p',etat3.p);
T_cBP = XSteam('Tsat_p',etat4.p);

[PCI_massique, e_c, Cp, m_a1, fracR_c, fracR_O2, fracR_N2, frac_CO2, frac_H2O, frac_O2, frac_N2,p_part_H2O] = TVCombustion(fuel,lambda);
%T_rosée
T_rosee=DewPoint(p_part_H2O);

hf_HP=hf_Fumee(frac_CO2, frac_H2O, frac_O2, frac_N2, T_HP + pinch_HP +273.15);
hf_BP=hf_Fumee(frac_CO2, frac_H2O, frac_O2, frac_N2, T_cBP + pinch_BP +273.15);
%HP%
h_HP_liq = XSteam('hL_p',etat3.p);
m3=(m_a+m_c)*(h4g - hf_HP)/(etat3.h - h_HP_liq);

%BP
h_BP_liq = XSteam('hL_p',etat4.p);
h_BP_vap = XSteam('hV_p',etat4.p);

%Etat entre le ballon BP et la pompe
Etat_p1 = struct;
Etat_p1.p = etat4.p;
Etat_p1.h = h_BP_liq;
Etat_p1.t = XSteam('T_ph',Etat_p1.p,Etat_p1.h);
Etat_p1.s = XSteam('s_ph',Etat_p1.p,Etat_p1.h);
Etat_p1.e = (Etat_p1.h-h0)-(T0+273.15)*(Etat_p1.s-s0);

%Etat entre la pompe et l'échangeur
Etat_p2 = struct;
Etat_p2.p = etat3.p; 

Etat_p2.h = Etat_p1.h + dp*v_12/eta_isP;
Etat_p2.t = XSteam('T_ph',Etat_p2.p,Etat_p2.h);
Etat_p2.s = XSteam('s_ph',Etat_p2.p,Etat_p2.h);
Etat_p2.e = (Etat_p2.h-h0)-(T0+273.15)*(Etat_p2.s-s0);

m4 = ((m_a+m_c)*(hf_HP-hf_BP)- m3*(h_HP_liq-Etat_p2.h))/(etat4.h-h_BP_liq);

%%%%%%%%%%%%%%%%%%%%%
%Calcul de l'état 5g%
%%%%%%%%%%%%%%%%%%%%%

p5g=100
h5g=hf_BP-(m3+m4)*(Etat_p1.h-etat2.h)/(m_a+m_c);
t5g= fzero(@(t) TGV_fT5g(h5g, frac_CO2, frac_H2O, frac_O2, frac_N2, t +273.15),100);
s5g= sf_Fumee(frac_CO2, frac_H2O, frac_O2, frac_N2, t5g+273.15)
e5g= h5g- hf_Fumee(frac_CO2, frac_H2O, frac_O2, frac_N2, 288.15) - 273.15*(s5g- sf_Fumee(frac_CO2, frac_H2O, frac_O2, frac_N2, 288.15))

%%%%%%%%%%%%%%%%%%%%%%%%%%
%Rendements et puissances%
%%%%%%%%%%%%%%%%%%%%%%%%%%

P_prim_en = m_c*PCI_massique;
P_prim_ex = m_c*e_c;
P_m = (m3+m4)*(etat4.h-etat5.h)+m3*(etat3.h-etat4.h); %Pour la TV
P_eTV = P_m*eta_mec;
P_fmec = P_m*(1-eta_mec)+P_eTG*k_mec/(1-k_mec);

P_cond_en = (m3+m4)*(etat5.h-etat1.h);
P_echap_en = m_a*(h5g-h1g);

P_irr_comb = P_prim_ex-((m_a+m_c)*e3g-m_a*e2g);
P_cond_ex = (m3+m4)*(etat5.e-etat1.e);
P_gen_vap = (m_a+m_c)*(e4g-e5g)-(m3*(etat3.e-etat2.e)+m4*(etat4.e-etat2.e));
P_echap_ex = (m_a+m_c)*e5g

P_cTG_ex = m_a*((h2g-h1g)-(e2g-e1g)) %Compresseur TG
P_tTG_ex = (m_a+m_c)*(h3g-h4g)*(1-(h3g-h4g)/(e3g-e4g)) %Turbine TG
P_tTV_ex = m3*(etat3.h-etat4.h)*(1-(etat3.h-etat4.h)/(etat3.e-etat4.e))+m4*(etat4.h-etat5.h)*(1-(etat4.h-etat5.h)/(etat4.e-etat5.e)) %Turbine TV
P_pTV_ex = (m3+m4)*((etat2.h-etat1.h)-(etat2.e-etat1.e))+m3*((Etat_p2.h-Etat_p1.h)-(Etat_p2.e-Etat_p1.e)) %Pompe TV
P_rotex=P_cTG_ex+P_tTG_ex+P_tTV_ex+P_pTV_ex;
P_irr_therm = P_prim_ex - P_irr_comb- P_cond_ex - P_gen_vap - P_echap_ex - P_fmec - P_eTV - P_eTG*1000 - P_rotex;

%%%%%%%
%Plots%
%%%%%%%%%%%
%T-s & H-s%
%%%%%%%%%%%
%T-s%

length = 10;

T_12=zeros(1,length);
T_cBP=zeros(1,length);
T_vBP=zeros(1,length);
T_cHP=zeros(1,length);
T_sBP=zeros(1,length);
T_vHP=zeros(1,length);
T_sHP=zeros(1,length);
T_34=zeros(1,length);
T_45=zeros(1,length);
T_51=zeros(1,length);

p_12=linspace(etat1.p,etat2.p,length);

s_12=zeros(1,length);
s_cBP=zeros(1,length);
s_vBP=zeros(1,length);
s_cHP=zeros(1,length);
s_sBP=zeros(1,length);
s_vHP=zeros(1,length);
s_sHP=zeros(1,length);
s_34=zeros(1,length);
s_45=zeros(1,length);
s_51=zeros(1,length);


h_12=zeros(1,length);
h_cBP=linspace(etat2.h,XSteam('hL_p',etat2.p),length);
h_vBP=linspace(XSteam('hL_p',etat2.p),XSteam('hV_p',etat3.p),length);
h_cHP=linspace(Etat_p2.h,XSteam('hV_p',etat2.p),length);
h_sBP=linspace(etat4.h, XSteam('hV_p',etat2.p),length);
h_vHP=linspace(XSteam('hL_p',etat3.p),XSteam('hV_p',etat3.p),length);
h_sHP=linspace(etat3.h, XSteam('hV_p',etat3.p),length);
h_34=linspace(etat3.h,etat4.h,length);
h_45=linspace(etat4.h,etat5.h,length);
h_51=linspace(etat5.h,etat1.h,length);

%Compression:
for i=1:length
   dp = (p_12(i)-etat1.p)*100;% On multiplie dp par 100 pour passer de bar à kPa 
h_12(i) =  etat1.h + dp*v_12/eta_isP;
T_12(i) = XSteam('T_ph',etat2.p,etat2.h);
s_12(i) = XSteam('s_ph',etat2.p,etat2.h); 
end

%Chauffage à BP:
for i= 1:length
  s_cBP(i)=XSteam('s_ph',etat2.p,h_cBP(i));
  T_cBP(i)=XSteam('T_ph',etat2.p,h_cBP(i));
end

%Vaporisation à BP:
for i= 1:length
   s_vBP(i) = XSteam('s_ph',etat2.p,h_vBP(i));
   T_vBP(i) = XSteam('T_ph',etat2.p,h_vBP(i));
end

%Chauffage à HP:
for i= 1:length
  s_cHP(i)=XSteam('s_ph',etat3.p,h_cHP(i));
  T_cHP(i)=XSteam('T_ph',etat3.p,h_cHP(i));
end

%Surchauffe à BP:
for i= 1:length
  s_sBP(i)=XSteam('s_ph',etat2.p,h_sBP(i));
  T_sBP(i)=XSteam('T_ph',etat2.p,h_sBP(i));
end

%Vaporisation à HP:
for i = 1:length
    s_vHP(i) = XSteam('s_ph',etat3.p,h_vHP(i));
    T_vHP(i) = XSteam('T_ph',etat3.p,h_vHP(i));
end

%Surchauffe à HP
for i= 1:length
  s_sHP(i)=XSteam('s_ph',etat3.p,h_sHP(i));
  T_sHP(i)=XSteam('T_ph',etat3.p,h_sHP(i));
end

%Détente HP
for i= 1:length
    p=XSteam('P_hs',etat3.h+(h_34(i)-etat3.h)/eta_isT,etat3.s);
    s_34(i)=XSteam('s_ph',p,h_34(i));
    T_34(i)=XSteam('T_ph',p,h_34(i));
end

%Détente BP
for i=1:length
    p=XSteam('P_hs',etat4.h+(h_45(i)-etat4.h)/eta_isT,etat4.s);
    s_45(i)=XSteam('s_ph',p,h_45(i));
    T_45(i)=XSteam('T_ph',p,h_45(i));
end

%Condensation
for i= 1:length
    s_51(i) = XSteam('s_ph',etat5.p,h_51(i));
    T_51(i) = XSteam('T_ph',etat5.p,h_51(i));
end

%%%%%%%%%%%
%Affichage%
%%%%%%%%%%%

fig1=figure('units','normalized','outerposition',[0 0 1 1]);

text1 = uicontrol( fig1 , 'style' , 'text' , 'position' , [175,880,300,40] ,...
    'string' , 'Résulats' , 'fontsize' , 30 )

%Graphe T-s%
subplot ( 'Position' , [ .40 .6 .2 .3 ] ) ;
%Cloche%
T_0 = 1e-4; %[°C] car XSteam ne trouve rien pour T=0°C

S = linspace(0,XSteam('sV_T',T_0),200); %vecteur s dans la cloche
T = arrayfun(@(s) XSteam('Tsat_s',s), S);
plot(S,T,'k');
hold on;
plot(s_12,T_12,'blue')
plot(s_cBP,T_cBP,'blue')
plot(s_vBP,T_vBP,'blue')
plot(s_cHP,T_cHP,'blue')
plot(s_sBP,T_sBP,'blue')
plot(s_vHP,T_vHP,'blue')
plot(s_sHP,T_sHP,'blue')
plot(s_34,T_34,'blue')
plot(s_45,T_45,'blue')
plot(s_51,T_51,'blue')

text(etat1.s,etat1.t,'\leftarrowEtat 1~2')
text(etat3.s,etat3.t,'\leftarrowEtat 3')
text(etat4.s,etat4.t,'\leftarrowEtat 4')
title('Graphe T-s')
xlabel('Entropie [J/kgK]')
ylabel('Température [K]')

%Graphe h-s%
subplot ( 'Position' , [ .40 .13 .2 .3 ] ) ;
%dessine le diagramme (h,s) d'une centrale TV

%cloche TS
T_0 = 1e-2; %[°C]

S = linspace(XSteam('sL_T',T_0),XSteam('sV_T',T_0),200);
P = arrayfun(@(s) XSteam('psat_s',s), S);
H = arrayfun(@(p,s) XSteam('h_ps',p,s), P, S);

plot(S,H,'k');
hold on;
plot(s_12,h_12,'blue')
plot(s_cBP,h_cBP,'blue')
plot(s_vBP,h_vBP,'blue')
plot(s_cHP,h_cHP,'blue')
plot(s_sBP,h_sBP,'blue')
plot(s_vHP,h_vHP,'blue')
plot(s_sHP,h_sHP,'blue')
plot(s_34,h_34,'blue')
plot(s_45,h_45,'blue')
plot(s_51,h_51,'blue')

text(etat1.s,etat1.h,'\leftarrowEtat 1~2')
text(etat3.s,etat3.h,'\leftarrowEtat 3')
text(etat4.s,etat4.h,'\leftarrowEtat 4')
title('Graphe h-s')
xlabel('Entropie [J/kgK]')
ylabel('Enthalpie [kJ/kg]')


%%%%%%%%%%%
%Pie Chart%
%%%%%%%%%%%

%Energetique%

P=[double(P_eTG)*1000 double(P_eTV) double(P_fmec) double(P_cond_en) double(P_echap_en)]

label={sprintf('Puissance effective TG \n %0.1f MW ',P_eTG)...
    sprintf('Puissance effective TV \n %0.1f MW ',P_eTV/1e3)...
    sprintf('Pertes mécaniques \n %0.1f MW ',P_fmec/1e3)...
    sprintf('Pertes au condenseur: \n %0.1f MW ',P_cond_en/1e3)...
    sprintf('Pertes à l''échappement: \n %0.1f MW ',P_echap_en/1e3)};
subplot ( 'Position' , [ .66 .515 .3 .45 ] ) ;
pie(P,label);
title(sprintf('Distribution du flux énergétique avec puissance primaire de %0.1f  MW',P_prim_en/1e3 ));

%Exergetique%

P=[double(P_eTG)*1000 double(P_eTV)  double(P_fmec) double(P_cond_ex) double(P_rotex) double(P_echap_ex) double(P_irr_therm) double(P_irr_comb)]

label={sprintf('Puissance effective TG \n %0.1f MW ',P_eTG)...
    sprintf('Puissance effective TV \n %0.1f MW ',P_eTV/1e3)...
    sprintf('Pertes mécaniques \n %0.1f MW ',P_fmec/1e3)...
    sprintf('Pertes au condenseur: \n %0.1f MW ',P_cond_ex/1e3)...
    sprintf('Irréversibilités au complexe rotorique: \n %0.1f MW ',P_rotex/1e3)...
    sprintf('Pertes à l''échappement: \n %0.1f MW ',P_echap_ex/1e3)...
    sprintf('Irréversibilité du transfert thermique \n %0.1f MW ',P_irr_therm/1e3)...    
    sprintf('Irréversibilités de la combustion: \n %0.1f MW ',P_irr_comb/1e3)};

subplot ( 'Position' , [ .66 0.02 .3 .45 ] ) ;
pie(P,label);
title(sprintf('Distribution du flux exergétique avec puissance primaire de %0.1f  MW',P_prim_ex/1e3 ));

%%%%%%%%%%%%%%%%%%%%%%%
%Tableaux des résulats%
%%%%%%%%%%%%%%%%%%%%%9%
%Caractéristiques des états$
%Pour la TG
pg=[p1g;p2g;p3g;p4g;p5g];
tg=[t1g;t2g;t3g;t4g;t5g];
hg=[h1g;h2g;h3g;h4g;h5g];
sg=[s1g;s2g;s3g;s4g;s5g];
eg=[e1g;e2g;e3g;e4g;e5g];
Etatsg={'1g';'2g';'3g';'4g';'5g'};

Table = table(pg,tg,hg,sg,eg,'RowNames',Etatsg)


text1 = uicontrol( fig1 , 'style' , 'text' , 'position' , [170,686,330,40] ,...
    'string' , 'Caractéristiques des états de la TG' , 'fontsize' , 15 )
t1 = uitable(fig1);
t1.Data = table2cell(Table);
t1.Position = [110 561 425 132];
t1.ColumnName = {'p [kPa]','T [°C]','h [kJ/kg]','s [kJ/kgK]','e [kJ/kg]'};

%Pour la TV

p=[etat1.p;etat2.p;etat3.p;etat4.p;etat5.p];
t=[etat1.t;etat2.t;etat3.t;etat4.t;etat5.t];
x=[etat1.x;etat2.x;etat3.x;etat4.x;etat5.x];
h=[etat1.h;etat2.h;etat3.h;etat4.h;etat5.h];
s=[etat1.s;etat2.s;etat3.s;etat4.s;etat5.s];
e=[etat1.e;etat2.e;etat3.e;etat4.e;etat5.e];
Etats={'1';'2';'3';'4';'5'};

Table = table(p,t,x,h,s,e,'RowNames',Etats)


text1 = uicontrol( fig1 , 'style' , 'text' , 'position' , [170,500,330,40] ,...
    'string' , 'Caractéristiques des états de la TV' , 'fontsize' , 15 )
t1 = uitable(fig1);
t1.Data = table2cell(Table);
t1.Position = [110 375 425 132];
t1.ColumnName = {'p [bar]','T [°C]','x [-]','h [kJ/kg]','s [kJ/kgK]','e [kJ/kg]'};
% %Rendements$
% text2 = uicontrol( fig1 , 'style' , 'text' , 'position' , [170,300,300,40] ,...
%     'string' , 'Rendements' , 'fontsize' , 15 )
% ETAt=[double(eta_cyclen); double(eta_mec); double(eta_toten); double(eta_rotex); double(eta_cyclex); double(eta_combex); double(eta_totex)]
% ETA=table(ETAt,'RowNames',{'eta_cyclen'; 'eta_mec'; 'eta_toten'; 'eta_rotex'; 'eta_cyclex'; 'eta_combex'; 'eta_totex'})
% t2 = uitable(fig1);
% t2.Data = table2cell(ETA)%{eta_cyclen; eta_mec; eta_toten; eta_rotex; eta_cyclex; eta_combex; eta_totex}
% t2.Position = [210 355 200 160];
% t2.RowName = {'eta_cyclen','eta_mec','eta_toten','eta_rotex','eta_cyclex','eta_combex','eta_totex'};
% t2.ColumnName= {''}
% 
% %Puissances$
% text3 = uicontrol( fig1 , 'style' , 'text' , 'position' , [40,310,300,40] ,...
%     'string' , 'Puissances [MW]' , 'fontsize' , 15 )
% PUISSANCEt=[double(P_mT); double(P_mC); double(P_fmec); double(P_prim_en); double(P_echap_en); double(P_prim_ex); double(P_irr_comb);double(P_echap_ex);double(P_irr_tc)]/1000
% PUISSANCE=table(PUISSANCEt,'RowNames',{'P_mT'; 'P_mC'; 'P_fmec'; 'P_prim_en'; 'P_echap_en'; 'P_prim_ex'; 'P_irr_comb';'P_echap_ex';'P_irr_tc'})
% t3 = uitable(fig1);
% t3.Data = table2cell(PUISSANCE)%{eta_cyclen; eta_mec; eta_toten; eta_rotex; eta_cyclex; eta_combex; eta_totex}
% t3.Position = [80 115 205 195];
% t3.RowName = {'P_mT'; 'P_mC'; 'P_fmec'; 'P_prim_en'; 'P_echap_en'; 'P_prim_ex'; 'P_irr_comb';'P_echap_ex';'P_irr_tc'};
% t3.ColumnName= {''}

%Débits$
text4 = uicontrol( fig1 , 'style' , 'text' , 'position' , [310,320,300,40] ,...
    'string' , 'Débits [kg/s]' , 'fontsize' , 15 )
DEBITSt=[double(m_a); double(m_c); m3; m4]
DEBITS=table(DEBITSt,'RowNames',{'Air'; 'Carburant'; 'Vapeur au point 3'; 'Vapeur au point 4'})
t4 = uitable(fig1);
t4.Data = table2cell(DEBITS)%{eta_cyclen; eta_mec; eta_toten; eta_rotex; eta_cyclex; eta_combex; eta_totex}
t4.Position = [315 210 280 110];
t4.RowName = {'Air'; 'Carburant'; 'Vapeur au point 3'; 'Vapeur au point 4'};
t4.ColumnName= {''}

%Point de rosée%
text5 = uicontrol( fig1 , 'style' , 'text' , 'position' , [360,160,200,40] ,...
    'string' , 'Temp. de rosée [°C]' , 'fontsize' , 15 )
ROSEE=table(T_rosee,'RowNames',{'T_rosee'})
t5 = uitable(fig1);
t5.Data = table2cell(ROSEE);
t5.Position = [375 100 165 58];
t5.RowName = {'T_rosee'};
t5.ColumnName= {''}

%Boutons%
bp1 = uicontrol ( fig1 , 'style' , 'push' , 'position' , [70 50 200 30 ] ,...
    'string' , 'Nouvelle TGV' , 'callback' , @(bp1,eventdata)GUI_2(3))

bp2 = uicontrol ( fig1 , 'style' , 'push' , 'position' , [300 50 200 30 ] ,...
    'string' , 'Retour au menu principal' , 'callback' , @(bp2,eventdata)GUI())

end