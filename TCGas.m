%function [] = TCGaz(power, fuel, eta_piC, eta_piT, k_mec, T3, k_cc, lambda)
function [] = TCGas()
%A faire varier:

P_e=230*10^6;
fuel = 'methane'
eta_piC=0.9;
eta_piT=0.9;
k_mec=0.015;
T3=1050+273.15;%valeur max 
k_cc=0.95;
lambda=1; %Excès d'air

if fuel =='methane'
methane=true;
else
kerosene=true;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%
%Propriétés invariantes

R_a=287.1;
x_O2=0.2312; %Fraction massique d'O2 dans l'air =cst
if methane
    LHV=50.01*10^6; %Pour méthane [J/kg]
    %m_a1=4*m_c/x_O2; %Vrai uniquement pour le méthane
else
    LHV=43.4*10^6; %Diesel(gazole) [J/kg]
end
gamma=1.4;
%m_a=lambda*m_a1*m_c;
%m_g=m_a+m_c;
r=10;
T1=50+273.15;
p1=10^5; %[Pa]
p2=p1*r;
p3=p2*k_cc;
p4=10^5;
h1=(x_O2*janaf('h','O2',T1)+(1-x_O2)*janaf('h','N2',T1)) %[kJ/kg]
%Trouver T2 et T4
T2=T1*r^((gamma-1)/gamma/eta_piC);
T4=T3*(p3/p4)^(-eta_piT*(gamma-1)/gamma);

h2=(x_O2*janaf('h','O2',T2)+(1-x_O2)*janaf('h','N2',T2)) %[kJ/kg]

% m_c=11.2
if methane
    m_a1=4/x_O2
else
end
% m_a=lambda*m_a1*m_c

syms ma mc
[m_a, m_c] = vpasolve([lambda*m_a1 == ma/mc, P_e==(ma*(x_O2*janaf('h','O2',T3)*1000+(1-x_O2)*janaf('h','N2',T3)*1000)+mc*get_methane('h',T3))-(ma*(x_O2*janaf('h','O2',T4)*1000+(1-x_O2)*janaf('h','N2',T4)*1000)+mc*get_methane('h',T4))*(1-k_mec)-ma*(h2-h1)*(1+k_mec)], [ma, mc]);

m_g=m_a+m_c;
(x_O2*janaf('h','O2',T2)+(1-x_O2)*janaf('h','N2',T2))
%get_enthalpy_methane(T3)
if methane
h3=((x_O2*janaf('h','O2',T3)+(1-x_O2)*janaf('h','N2',T3))*m_a + get_methane('h',T3)*m_c)/m_g %[kJ/kg]
h4=((x_O2*janaf('h','O2',T4)+(1-x_O2)*janaf('h','N2',T4))*m_a + get_methane('h',T4)*m_c)/m_g %[kJ/kg]
end

%%%%%%%
%Plots%
%%%%%%%

%Enthalpy
length_T=1000;
T=linspace(T1,T3,length_T);
xfor i= 1:length_T
    

%Energetic efficiency
eta_cyclen=((1+1/(lambda*m_a1))*(h3-h4)-(h2-h1))/((1+1/(lambda*m_a1))*(h3-h2))
end

