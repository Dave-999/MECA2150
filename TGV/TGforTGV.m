%TG(230,1,0.9,0.9,0.015,1050,0.95,10)
function A = TG(P_e, fuel_number, eta_piC, eta_piT, k_mec, T3, k_cc, r)
close all
%%%%%%%%%%%%
%Parametres%
%%%%%%%%%%%%

if nargin == 0
P_e=230;%[MW]
fuel_number = 1;
eta_piC=0.9;
eta_piT=0.9;
k_mec=0.015;
T3=1050; %[�C] valeur max
k_cc=0.95;
r=10;
end
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
%%%%%%%%%%%%%%%%%%%%%%%%
%Propri�t�s invariantes%
%%%%%%%%%%%%%%%%%%%%%%%%

P_e=P_e*10^3 %[kW]
T3=T3+273.15 %[K]
R=8.314472;
R_a=287.1;
x_O2_molar=0.21;
x_O2_massic=x_O2_molar*32/(x_O2_molar*32+(1-x_O2_molar)*28); %Fraction massique d'O2 dans l'air = cst
gamma=1.4;
T1=15+273.15;
T_ref=0+273.15; %T de r�f�rence pour h, s et e
p1=10^5; %[Pa]
p2=p1*r;
p3=p2*k_cc;
p4=p3/k_cc/r; %pg 118

%%%%%%%%%%%%%%%%%%%%%%%%
%Calculs pour l'�tape 1%
%%%%%%%%%%%%%%%%%%%%%%%%

h1=(x_O2_massic*janaf('c','O2',300)+(1-x_O2_massic)*janaf('c','N2',300))*(T1-T_ref); %Reference state
s1=integral(@(t) (x_O2_massic*janaf('c','O2',300)+(1-x_O2_massic)*janaf('c','N2',300))./t,T_ref,T1);

%%%%%%%%%%%%%%%%%%%%%%%%
%Calculs pour l'�tape 2%
%%%%%%%%%%%%%%%%%%%%%%%%

T2= fzero(@(T2) TG_fT2(p1,p2,T1,T2,eta_piT,x_O2_massic,R_a),700); %pg 120
h2=h1+(x_O2_massic*janaf('c','O2',300)+(1-x_O2_massic)*janaf('c','N2',300))*(300-T1)+integral(@(t) x_O2_massic*janaf('c','O2',t)+(1-x_O2_massic)*janaf('c','N2',t),300,T2);%(other way to get the same result)
s2=s1+(integral(@(t) (x_O2_massic*janaf('c','O2',300)+(1-x_O2_massic)*janaf('c','N2',300))./t,T1,300)+integral(@(t) (x_O2_massic*janaf('c','O2',t)+(1-x_O2_massic)*janaf('c','N2',t))./t,300,T2))*(1-eta_piC)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Calculs du lambda, de T_rosee, et des etats 3 et 4 et des debits massiques%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%lambda%
syms l
[PCI_massique, ec, m_a1,fracP_CO2, fracP_H2O, fracP_O2, fracP_N2, n_CO2, n_H2O, n_O2, n_N2,M, p_part_H2O] = TGCombustion(fuel,l);

lambda=solve(@(l) PCI_massique==(fracP_CO2*(janaf('h','CO2',T3)-janaf('h','CO2',T2))+fracP_H2O*(janaf('h','H2O',T3)-janaf('h','H2O',T2))+fracP_O2*(janaf('h','O2',T3)-janaf('h','O2',T2))+fracP_N2*(janaf('h','N2',T3)-janaf('h','N2',T2)))*(1+m_a1*l),l);
lambda=double(lambda);
[PCI_massique, ec, m_a1,frac_CO2, frac_H2O, frac_O2, frac_N2, n_CO2, n_H2O, n_O2, n_N2,M, p_part_H2O] = TGCombustion(fuel,lambda);

%T_rosee%
T_rosee=DewPoint(p_part_H2O)

%T4%
flue_gas_molar_mass=(M+M*m_a1*lambda)/(n_CO2+ n_H2O+ n_O2+ n_N2)/1000;
R_g=R/flue_gas_molar_mass;
T4= fzero(@(T4) TG_fT4(p3,p4,T3,T4,eta_piT,x_O2_massic,R_g,lambda,m_a1,frac_CO2,frac_H2O,frac_O2,frac_N2),700); %pg 121

%Etat3%
h3=h2+integral(@(t) janaf('c','CO2',t)*frac_CO2+janaf('c','H2O',t)*frac_H2O+janaf('c','N2',t)*frac_N2+janaf('c','O2',t)*frac_O2,T2,T3);
s3=s2+integral(@(t) (janaf('c','CO2',t)*frac_CO2+janaf('c','H2O',t)*frac_H2O+janaf('c','N2',t)*frac_N2+janaf('c','O2',t)*frac_O2)./t,T2,T3)-R_g*log(p3/p2)/1000;

%Etat4%
h4=h3+integral(@(t) janaf('c','CO2',t)*frac_CO2+janaf('c','H2O',t)*frac_H2O+janaf('c','N2',t)*frac_N2+janaf('c','O2',t)*frac_O2,T3,T4);
s4=s3-(1-eta_piT)/eta_piT*integral(@(t) (janaf('c','CO2',t)*frac_CO2+janaf('c','H2O',t)*frac_H2O+janaf('c','N2',t)*frac_N2+janaf('c','O2',t)*frac_O2)./t,T3,T4);

%D�bits%
    syms ma mc
    [m_a, m_c] = vpasolve([lambda*m_a1 == ma/mc,... %Eq 3.7
        P_e == (ma+mc)*(h3-h4)*(1-k_mec)... 
        -  ma*(h2-h1)*(1+k_mec)... %Eq 3.1
        ],[ma, mc]);
    
    m_g = m_a + m_c;

%%%%%%%%%%%%%%%%%%%%%%%
%Calculs de puissances%
%%%%%%%%%%%%%%%%%%%%%%%

W_mT=h3-h4;
P_mT=m_g*W_mT;

W_mC=h2-h1;
P_mC=m_a*W_mC;

W_m=(1+1/m_a1/lambda)*W_mT-W_mC;

P_fmec=k_mec*(P_mT+P_mC);%=P_e-P_m
P_m=P_e+P_fmec;

%%%%%%%%%%%%%%%%%%%%%%%%%
%Rendements �nerg�tiques%
%%%%%%%%%%%%%%%%%%%%%%%%%

eta_cyclen=P_e/(m_c*PCI_massique);
eta_mec=P_e/P_m;
eta_toten=eta_cyclen*eta_mec;

%%%%%%%%%%%%%%%%%%%%%%%%%
%Rendements exerg�tiques%
%%%%%%%%%%%%%%%%%%%%%%%%%

h0=h1;
s0=s1;
e1=h1-h0-T_ref*(s1-s0);
e2=h2-h0-T_ref*(s2-s0);
e3=h3-h0-T_ref*(s3-s0);
e4=h4-h0-T_ref*(s4-s0);

eta_totex=P_e/(m_c*ec);
eta_rotex=(m_g*(h3-h4)-m_a*(h2-h1))/(m_g*(e3-e4)-m_a*(e2-e1));
eta_cyclex=(m_g*(e3-e4)-m_a*(e2-e1))/(m_g*e3-m_a*e2);
eta_combex=(m_g*e3-m_a*e2)/(m_c*ec);

p=[p1;p2;p3;p4]./1000;
T=[T1;T2;T3;T4]-273.15;
h=[h1;h2;h3;h4];
s=[s1;s2;s3;s4];
e=[e1;e2;e3;e4];
A=[p T h s e m_a m_c fuel PCI_massique ec lambda]

end