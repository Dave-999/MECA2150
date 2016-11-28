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
lambda=1.04; %Exces d'air

if strcmp(fuel,'methane')
    methane=true;
else
    diesel=true;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%

%Propri�t�s invariantes
R=8.314472;
%R_a=287.1;
x_O2=0.2312; %Fraction massique d'O2 dans l'air =cst
if methane
    LHV=50.01*10^6; %Pour m�thane [J/kg]
    %m_a1=4*m_c/x_O2; %Vrai uniquement pour le m�thane
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
h1=(x_O2*janaf('h','O2',T1)+(1-x_O2)*janaf('h','N2',T1))*1000 %[J/kg]
%Trouver T2 et T4
T2=T1*r^((gamma-1)/gamma/eta_piC);
T4=T3*(p3/p4)^(-eta_piT*(gamma-1)/gamma)

m_12=(1-((gamma-1)/gamma/eta_piC))^-1; %Polytropic coefficients
m_34=(1-((gamma-1)/gamma*eta_piT))^-1;

h2=(x_O2*janaf('h','O2',T2)+(1-x_O2)*janaf('h','N2',T2))*1000 %[J/kg]

if methane
    x_H2O=2*(18/48)/(1+(2*18/48))
else
    
end

if methane
    m_a1=2*2/x_O2; %CH4 + 2 O2 = CO2 + 2 H2O
    
    syms ma mc
    h3=(ma*(1-x_O2)/(ma+mc) * janaf('h','N2',T3)  +  (ma*x_O2+mc)/(ma+mc)*(x_H2O*janaf('h','H2O',T3)+(1-x_H2O)*janaf('h','CO2',T3)))*1000
    h4=(ma*(1-x_O2)/(ma+mc) * janaf('h','N2',T4)  +  (ma*x_O2+mc)/(ma+mc)*(x_H2O*janaf('h','H2O',T4)+(1-x_H2O)*janaf('h','CO2',T4)))*1000
    [m_a, m_c] = vpasolve([lambda*m_a1 == ma/mc,...
        P_e == (ma+mc)*(h3-h4)*(1-k_mec)...
         -  ma*(h2-h1)*(1+k_mec)...
        %mc*LHV== (ma+mc)*h3-ma*h2... %autre �quation possible � la place
                                      %de celle de P_e
        ],[ma, mc]) %Eq 3.1
    
    m_g=m_a+m_c;
    
    h3=(m_a*(1-x_O2)/(m_g) * janaf('h','N2',T3)  +  (m_a*x_O2+m_c)/(m_g)*(x_H2O*janaf('h','H2O',T3)+(1-x_H2O)*janaf('h','CO2',T3)))*1000
    h4=(m_a*(1-x_O2)/(m_g) * janaf('h','N2',T4)  +  (m_a*x_O2+m_c)/(m_g)*(x_H2O*janaf('h','H2O',T4)+(1-x_H2O)*janaf('h','CO2',T4)))*1000
    
else
    m_a1=(71/4)*(32/167)/x_O2; %4 C12H23 + 71 O2 = 48 CO2 + 46 H2O
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
length_T=100;
T_12=linspace(T1,T2,length_T);
T_23=linspace(T2,T3,length_T);
T_34=linspace(T3,T4,length_T);
T_41=linspace(T4,T1,length_T);

p_12=zeros(1,length_T);
p_23=zeros(1,length_T);
p_34=zeros(1,length_T);
p_41=10^5;

s_12=zeros(1,length_T);
s_23=zeros(1,length_T);
s_34=zeros(1,length_T);
s_41=zeros(1,length_T);

h_12=zeros(1,length_T);
h_23=zeros(1,length_T);
h_34=zeros(1,length_T);
h_41=zeros(1,length_T);


for i= 1:length_T
    p_12(i)=(T_12(i)/T1)^(m_12/m_12-1)*p1;
    %s_12(i)=(x_O2*(janaf('s','O2',T_12(i)+R/32*log(p_12(i)/p1)))+(1-x_O2)*janaf('s','N2',T_12(i)+R/14*log(p_12(i)/p1)));
end
for i= 1:length_T
    p_23(i)=p2*i/length_T*k_cc;
    %s_23(i)=(m_a*(x_O2*(janaf('s','O2',T_23(i)+R/32*log(p_23(i)/p2)))+(1-x_O2)*janaf('s','N2',T_23(i)+R/14*log(p_23(i)/p2))) + m_c*get_methane('s',T_23(i),p_23(i)))/m_g;
end
for i= 1:length_T
    p_34(i)=(T_34(i)/T3)^(m_34/m_34-1)*p3;
    %s_34(i)=(m_a*(x_O2*(janaf('s','O2',T_34(i)+R/32*log(p_34(i)/p3)))+(1-x_O2)*janaf('s','N2',T_34(i)+R/14*log(p_34(i)/p3))) + m_c*get_methane('s',T_34(i),p_34(i)))/m_g;
end
for i= 1:length_T
    %s_41(i)=(m_a*(x_O2*(janaf('s','O2',T_41(i)+R/32*log(p_41/p4)))+(1-x_O2)*janaf('s','N2',T_41(i)+R/14*log(p_41/p4))) + m_c*get_methane('s',T_41(i),p_41))/m_g;
end
% plot(s_12,T_12)
% hold on;
% plot(s_23,T_23)
% plot(s_34,T_34)
% plot(s_41,T_41)


%Energetic efficiency
m_c*LHV
m_g*h3-m_a*h2
%P_m/(m_c*LHV)
eta_cyclen=P_e/(m_c*LHV)
%eta_cyclen=1-((1+1/(lambda*m_a1))*h4-h1)/((1+1/(lambda*m_a1))*h3-h2)
eta_mec=P_e/P_m
eta_toten=eta_cyclen*eta_mec
end

