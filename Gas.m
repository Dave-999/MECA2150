%function [] = GasTurbine(power, fuel, eta_piC, eta_piT, k_mec, T3, k_cc, lambda)
function [] = Gas()
%A faire varier:

P_e=230*10^6;
fuel = 'methane';
eta_piC=0.9;
eta_piT=0.9;
k_mec=0.015;
T3=1050+273.15; %valeur max
k_cc=0.95;
%lambda=1.04; %Exces d'air

if strcmp(fuel,'methane')
    methane=true;
else
    diesel=true;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%

%Propriétés invariantes
R=8.314472;
%R_a=287.1;
x_O2_massic=0.2312; %Fraction massique d'O2 dans l'air =cst
x_O2_molar=0.21;
gamma=1.4;
%m_a=lambda*m_a1*m_c;
%m_g=m_a+m_c;
r=10;
T1=50+273.15;
p1=10^5; %[Pa]
p2=p1*r;
p3=p2*k_cc;
p4=10^5;
h1=(x_O2_massic*janaf('h','O2',T1)+(1-x_O2_massic)*janaf('h','N2',T1))*1000 %[J/kg]
%Trouver T2 et T4
T2=T1*r^((gamma-1)/gamma/eta_piC)
T4=T3*(p3/p4)^(-eta_piT*(gamma-1)/gamma)

m_12=(1-((gamma-1)/gamma/eta_piC))^-1; %Polytropic coefficients
m_34=(1-((gamma-1)/gamma*eta_piT))^-1;

h2=(x_O2_massic*janaf('h','O2',T2)+(1-x_O2_massic)*janaf('h','N2',T2))*1000 %[J/kg]

if methane
    LHV_massic=5*10^7; %[J/kg] http://www.engineeringtoolbox.com/fuels-higher-calorific-values-d_169.html
    LHV_molar=LHV_massic*16/1000 %[J/mol]
    %x_H2O=2*(18/48)/(1+(2*18/48))
    m_a1=2*2/x_O2_massic %CH4 + 2 O2 = CO2 + 2 H2O
    lambda=1/2 * (LHV_molar-(janaf('h','CO2',T3)-janaf('h','CO2',T2))*44+2*(janaf('h','H2O',T3)-janaf('h','H2O',T2))*18+2*(janaf('h','O2',T3)-janaf('h','O2',T2))*32) / ((janaf('h','O2',T3)-janaf('h','O2',T2))*32+3.762*(janaf('h','N2',T3)-janaf('h','N2',T2))*28)
    
    h3=(janaf('h','CO2',T3)*1000/16*44+janaf('h','H2O',T3)*1000/8*18+lambda*m_a1*(1-x_O2_massic)*janaf('h','N2',T3)*1000+(lambda*m_a1*x_O2_massic-m_a1*x_O2_massic)*janaf('h','O2',T3)*1000)/(1+lambda*m_a1)
    h4=(janaf('h','CO2',T4)*1000/16*44+janaf('h','H2O',T4)*1000/8*18+lambda*m_a1*(1-x_O2_massic)*janaf('h','N2',T4)*1000+(lambda*m_a1*x_O2_massic-m_a1*x_O2_massic)*janaf('h','O2',T4)*1000)/(1+lambda*m_a1)
    
    syms ma mc
    [m_a, m_c] = vpasolve([lambda*m_a1 == ma/mc,...
        P_e == (ma+mc)*(h3-h4)*(1-k_mec)...
        -  ma*(h2-h1)*(1+k_mec)... %Eq 3.1
        %mc*LHV== (ma+mc)*h3-ma*h2... %autre équation possible à la place
        %de celle de P_e
        ],[ma, mc])
    
    m_g=m_a+m_c;
    lambda*m_a1*(1-x_O2_massic)/28
    lambda*m_a1*x_O2_massic/32
    flue_gas_molar_mass=(16+lambda*m_a1*16)/(1+2+lambda*m_a1*(1-x_O2_massic)*16/28+lambda*m_a1*x_O2_massic*16/32-2)/1000 %[kg/mol]
    R_g=R/flue_gas_molar_mass
else
    LHV_massic=43.4*10^6; %Diesel(gazole) [J/kg]
    LHV_molar=LHV_massic*167/1000
    m_a1=(71/4)*(32/167)/x_O2_massic; %4 C12H23 + 71 O2 = 48 CO2 + 46 H2O
end

W_mT=h3-h4;
P_mT=m_g*W_mT

W_mC=h2-h1;
P_mC=m_a*W_mC

P_fmec=k_mec*(P_mT+P_mC)%=P_e-P_m
P_m=P_e+P_fmec;



%%%%%%%
%Plots%
%%%%%%%

%T-s
length=100;
T_12=linspace(T1,T2,length);
T_23=linspace(T2,T3,length);
T_34=linspace(T3,T4,length);
T_41=linspace(T4,T1,length);

p_34=linspace(p3,p4,length);
p_23=linspace(p2,p3,length);

s_12=zeros(1,length);
s_23=zeros(1,length);
s_34=zeros(1,length);
s_41=zeros(1,length);

h_12=zeros(1,length);
h_23=zeros(1,length);
h_34=zeros(1,length);
h_41=zeros(1,length);


for i= 1:length
    
    h_12(i)=x_O2_massic*janaf('h','O2',T_12(i))+(1-x_O2_massic)*janaf('h','N2',T_12(i));
    s_12(i)=x_O2_massic*janaf('s','O2',T_12(i))+(1-x_O2_massic)*janaf('s','N2',T_12(i));
    
end
for i= 1:length
    if methane
        
        h_23(i)=(janaf('h','CO2',T_23(i))*1000/16*44+janaf('h','H2O',T_23(i))*1000/8*18+lambda*m_a1*(1-x_O2_massic)*janaf('h','N2',T_23(i))*1000+(lambda*m_a1*x_O2_massic-m_a1*x_O2_massic)*janaf('h','O2',T_23(i))*1000)/(1+lambda*m_a1);
        s_23(i)=(janaf('s','CO2',T_23(i))/16*44+janaf('s','H2O',T_23(i))/8*18+lambda*m_a1*(1-x_O2_massic)*janaf('s','N2',T_23(i))+(lambda*m_a1*x_O2_massic-m_a1*x_O2_massic)*janaf('s','O2',T_23(i)))/(1+lambda*m_a1)-R_g*log(p_23(i)/p2);
    end
end
for i= 1:length
    if methane
        h_34(i)=(janaf('h','CO2',T_34(i))*1000/16*44+janaf('h','H2O',T_34(i))*1000/8*18+lambda*m_a1*(1-x_O2_massic)*janaf('h','N2',T_34(i))*1000+(lambda*m_a1*x_O2_massic-m_a1*x_O2_massic)*janaf('h','O2',T_34(i))*1000)/(1+lambda*m_a1);
        s_34(i)=(janaf('s','CO2',T_34(i))/16*44+janaf('s','H2O',T_34(i))/8*18+lambda*m_a1*(1-x_O2_massic)*janaf('s','N2',T_34(i))+(lambda*m_a1*x_O2_massic-m_a1*x_O2_massic)*janaf('s','O2',T_34(i)))/(1+lambda*m_a1)-R_g*log(p_34(i)/p3);
    end
end
for i= 1:length
    %s_41(i)=(m_a*(x_O2*(janaf('s','O2',T_41(i)+R/32*log(p_41/p4)))+(1-x_O2)*janaf('s','N2',T_41(i)+R/14*log(p_41/p4))) + m_c*get_methane('s',T_41(i),p_41))/m_g;
end
plot(s_12,h_12)
hold on;
plot(s_23,h_23)
plot(s_34,h_34)
plot(s_41,h_41)


%Energetic efficiency
%P_m/(m_c*LHV)
eta_cyclen=P_e/(m_c*LHV_massic)
%eta_cyclen=1-((1+1/(lambda*m_a1))*h4-h1)/((1+1/(lambda*m_a1))*h3-h2)
eta_mec=P_e/P_m
eta_toten=eta_cyclen*eta_mec
end

