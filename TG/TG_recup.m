function eta_cyclen = TG_recup(P_e, fuel, eta_piC, eta_piT, k_mec, T3, k_cc, r,NTU)

%%%%%%%%%%%%
%Parametres%
%%%%%%%%%%%%

if nargin == 0
P_e=230*10^3;%[kW]
fuel = 'CH4';
eta_piC=0.9;
eta_piT=0.9;
k_mec=0.015;
T3=1050; %[°C] valeur max
k_cc=0.95;
r=10;
NTU=4
end

%%%%%%%%%%%%%%%%%%%%%%%%
%Propriétés invariantes%
%%%%%%%%%%%%%%%%%%%%%%%%

T3=T3+273.15; %[K]
R=8.314472;
R_a=287.1;
x_O2_molar=0.21;
x_O2_massic=x_O2_molar*32/(x_O2_molar*32+(1-x_O2_molar)*28); %Fraction massique d'O2 dans l'air =cst
gamma=1.4;
T1=15+273.15;
T_ref=0+273.15; %T de référence pour h, s et e
p1=10^5; %[Pa]
p2=p1*r;
p3=p2*k_cc;
p4=p3/k_cc/r; %pg 118

%%%%%%%%%%%%%%%%%%%%%%%%
%Calculs pour l'étape 1%
%%%%%%%%%%%%%%%%%%%%%%%%

h1=(x_O2_massic*janaf('c','O2',300)+(1-x_O2_massic)*janaf('c','N2',300))*(T1-T_ref); %Reference state
s1=integral(@(t) (x_O2_massic*janaf('c','O2',300)+(1-x_O2_massic)*janaf('c','N2',300))./t,T_ref,T1);

%%%%%%%%%%%%%%%%%%%%%%%%
%Calculs pour l'étape 2%
%%%%%%%%%%%%%%%%%%%%%%%%

T2= fzero(@(T2) TG_fT2(p1,p2,T1,T2,eta_piT,x_O2_massic,R_a),700); %pg 120
h2=h1+(x_O2_massic*janaf('c','O2',300)+(1-x_O2_massic)*janaf('c','N2',300))*(300-T1)+integral(@(t) x_O2_massic*janaf('c','O2',t)+(1-x_O2_massic)*janaf('c','N2',t),300,T2);%(other way to get the same result)
s2=s1+(integral(@(t) (x_O2_massic*janaf('c','O2',300)+(1-x_O2_massic)*janaf('c','N2',300))./t,T1,300)+integral(@(t) (x_O2_massic*janaf('c','O2',t)+(1-x_O2_massic)*janaf('c','N2',t))./t,300,T2))*(1-eta_piC);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Calculs du lambda, des etats 3 et 4 et des debits massiques%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

syms l
[PCI_massique, ec, m_a1,fracP_CO2, fracP_H2O, fracP_O2, fracP_N2, n_CO2, n_H2O, n_O2, n_N2,M] = Combustion(fuel,l);

lambda=solve(@(l) PCI_massique==(fracP_CO2*(janaf('h','CO2',T3)-janaf('h','CO2',T2))+fracP_H2O*(janaf('h','H2O',T3)-janaf('h','H2O',T2))+fracP_O2*(janaf('h','O2',T3)-janaf('h','O2',T2))+fracP_N2*(janaf('h','N2',T3)-janaf('h','N2',T2)))*(1+m_a1*l),l);
lambda=double(lambda);
[PCI_massique, ec, m_a1,frac_CO2, frac_H2O, frac_O2, frac_N2, n_CO2, n_H2O, n_O2, n_N2,M] = Combustion(fuel,lambda);
flue_gas_molar_mass=(M+M*m_a1*lambda)/(n_CO2+ n_H2O+ n_O2+ n_N2)/1000;
R_g=R/flue_gas_molar_mass;
T4= fzero(@(T4) TG_fT4(p3,p4,T3,T4,eta_piT,x_O2_massic,R_g,lambda,m_a1,frac_CO2,frac_H2O,frac_O2,frac_N2),700); %pg 121

T2R=T2+NTU/(1+NTU)*(T4-T2);
h2R=h2+integral(@(t) x_O2_massic*janaf('c','O2',t)+(1-x_O2_massic)*janaf('c','N2',t),T2,T2R);

%Etat3%
h3=h2+integral(@(t) janaf('c','CO2',t)*frac_CO2+janaf('c','H2O',t)*frac_H2O+janaf('c','N2',t)*frac_N2+janaf('c','O2',t)*frac_O2,T2,T3);
s3=s2+integral(@(t) (janaf('c','CO2',t)*frac_CO2+janaf('c','H2O',t)*frac_H2O+janaf('c','N2',t)*frac_N2+janaf('c','O2',t)*frac_O2)./t,T2,T3)-R_g*log(p3/p2)/1000;

%Etat4%
h4=h3+integral(@(t) janaf('c','CO2',t)*frac_CO2+janaf('c','H2O',t)*frac_H2O+janaf('c','N2',t)*frac_N2+janaf('c','O2',t)*frac_O2,T3,T4);
s4=s3-(1-eta_piT)/eta_piT*integral(@(t) (janaf('c','CO2',t)*frac_CO2+janaf('c','H2O',t)*frac_H2O+janaf('c','N2',t)*frac_N2+janaf('c','O2',t)*frac_O2)./t,T3,T4);

%Débits%
    syms ma mc
    [m_a, m_c] = vpasolve([lambda*m_a1 == ma/mc,... %Eq 3.7
        P_e == (ma+mc)*(h3-h4)*(1-k_mec)... 
        -  ma*(h2-h1)*(1+k_mec)... %Eq 3.1
        ],[ma, mc]);
    
    m_g=m_a+m_c;

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
%Rendements énergétiques%
%%%%%%%%%%%%%%%%%%%%%%%%%

eta_cyclen=((1+1/(lambda*m_a1))*(h3-h4)-(h2-h1))/((1+1/(lambda*m_a1))*h3-h2R)

end