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
methane=true
else
kerosene=true
end

x_O2=0.2312 %Fraction massique d'O2 dans l'air =cst
if methane
    LHV=50.01*10^6 %Pour méthane [J/kg]
    %m_a1=4*m_c/x_O2; %Vrai uniquement pour le méthane
else
    LHV=43.4*10^6 %Diesel(gazole) [J/kg]
end
%%%%%%%%%%%%%%%%%%%%%%%%%%
gamma=1.4;
%m_a=lambda*m_a1*m_c;
%m_g=m_a+m_c;
r=10;
T1=50+273.15;
p1=10^5; %[Pa]
p2=p1*r;
p3=p2*k_cc;
p4=10^5;
h1=(x_O2*janaf('h','O2',T1)+(1-x_O2)*janaf('h','N2',T1))*1000
%Trouver T2 et T4
T2=T1*r^((gamma-1)/gamma/eta_piC)
T4=T3*(p3/p4)^(-eta_piT*(gamma-1)/gamma)

h2=(x_O2*janaf('h','O2',T2)+(1-x_O2)*janaf('h','N2',T2))*1000

% m_c=11.2
if methane
    m_a1=4/x_O2
else
end
% m_a=lambda*m_a1*m_c

syms ma mc
[m_a, m_c] = vpasolve([lambda*m_a1 == ma/mc, P_e==(ma*(x_O2*janaf('h','O2',T3)*1000+(1-x_O2)*janaf('h','N2',T3)*1000)+mc*get_enthalpy_methane(T3))-(ma*(x_O2*janaf('h','O2',T4)*1000+(1-x_O2)*janaf('h','N2',T4)*1000)+mc*get_enthalpy_methane(T4))*(1-k_mec)-ma*(h2-h1)*(1+k_mec)], [ma, mc])

%if methane
%h3=((x_O2*janaf('h','O2',T2)+(1-x_O2)*janaf('h','N2',T2))*m_a + get_enthalpy_methane(T3)*m_c)/m_g
%end

R_a=287.1;

%Trouver T4 et h4
if methane
%h4=(get_enthalpy_air(T4)*m_a + get_enthalpy_methane(T4)*m_c)/m_g
end
%Rendement énergétique
eta_cyclen=((1+1/(lambda*m_a1))*(h3-h4)-(h2-h1))/((1+1/(lambda*m_a1))*(h3-h2))
end

function h = get_enthalpy_methane(T)

h=integral(@get_cp_methane, 298.15, T);

end

function Cp = get_cp_methane(T) %Shomate (voir http://webbook.nist.gov/cgi/cbook.cgi?ID=C74828&Mask=1)

Cp = (-0.703029 + 108.4773 * T/1000 -42.52157 *(T/1000).^2 + 5.862788 *(T/1000).^3 +0.678565*(T/1000).^-2)/16;

end
