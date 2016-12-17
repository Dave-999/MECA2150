%function [] = TG(power, fuel, eta_piC, eta_piT, k_mec, T3, k_cc, lambda)
function [] = TG()
%A faire varier:

P_e=230*10^3;%[kW]
%fuel = 'diesel' %A changer selon le carburant voulu
fuel = 'methane';
eta_piC=0.9;
eta_piT=0.9;
k_mec=0.015;
T3=1050+273.15; %valeur max
k_cc=0.95;

if strcmp(fuel,'methane')
    methane=true;
    diesel=false;
else
    diesel=true;
    methane=false;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%
%Propri�t�s invariantes%
%%%%%%%%%%%%%%%%%%%%%%%%

R=8.314472;
R_a=287.1;
x_O2_molar=0.21;
x_O2_massic=x_O2_molar*32/(x_O2_molar*32+(1-x_O2_molar)*28); %Fraction massique d'O2 dans l'air =cst
gamma=1.4;
r=10;
T1=15+273.15;
T_ref=T1 %T de r�f�rence pour h, s et e
p1=10^5; %[Pa]
p2=p1*r;
p3=p2*k_cc;
p4=p3/k_cc/r; %pg 118

%%%%%%%%%%%%%%%%%%%%%%%%
%Calculs pour l'�tape 1%
%%%%%%%%%%%%%%%%%%%%%%%%

h1=0; %Reference state
s1=0;

%%%%%%%%%%%%%%%%%%%%%%%%
%Calculs pour l'�tape 2%
%%%%%%%%%%%%%%%%%%%%%%%%

T2= fzero(@(T2) TG_fT2(p1,p2,T1,T2,eta_piT,x_O2_massic,R_a),700) %pg 120
h2=h1+(x_O2_massic*janaf('c','O2',300)+(1-x_O2_massic)*janaf('c','N2',300))*(300-T1)+integral(@(t) x_O2_massic*janaf('c','O2',t)+(1-x_O2_massic)*janaf('c','N2',t),300,T2)%(other way to get the same result)
s2=s1+(integral(@(t) (x_O2_massic*janaf('c','O2',300)+(1-x_O2_massic)*janaf('c','N2',300))./t,T1,300)+integral(@(t) (x_O2_massic*janaf('c','O2',t)+(1-x_O2_massic)*janaf('c','N2',t))./t,300,T2))*(1-eta_piC)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Calculs du lambda, des �tats 3 et 4%
%et des d�bits massiques            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if methane
    LHV_massic=5.0150*10^4; %[kJ/kg] pg66
    m_a1=2*2/x_O2_massic %CH4 + 2 O2 = CO2 + 2 H2O
    lambda=(LHV_massic-44/16*(janaf('h','CO2',T3)-janaf('h','CO2',T2))-2*18/16*(janaf('h','H2O',T3)-janaf('h','H2O',T2))+m_a1*x_O2_massic*(janaf('h','O2',T3)-janaf('h','O2',T2))) / (m_a1*x_O2_massic*(janaf('h','O2',T3)-janaf('h','O2',T2))+m_a1*(1-x_O2_massic)*(janaf('h','N2',T3)-janaf('h','N2',T2)))
    
    flue_gas_molar_mass=(16+lambda*m_a1*16)/(1+2+lambda*m_a1*(1-x_O2_massic)*16/28+lambda*m_a1*x_O2_massic*16/32-2)/1000 %[kg/mol]
    R_g=R/flue_gas_molar_mass
    
    T4= fzero(@(T4) TG_fT4_methane(p3,p4,T3,T4,eta_piT,x_O2_massic,R_g,lambda,m_a1),700) %pg 121
    
    h3=h2+integral(@(t) (janaf('c','CO2',t)/16*44+janaf('c','H2O',t)/8*18+lambda*m_a1*(1-x_O2_massic)*janaf('c','N2',t)+(lambda*m_a1*x_O2_massic-m_a1*x_O2_massic)*janaf('c','O2',t))/(1+lambda*m_a1),T2,T3)
    s3=s2+integral(@(t) (janaf('c','CO2',t)/16*44+janaf('c','H2O',t)/8*18+lambda*m_a1*(1-x_O2_massic)*janaf('c','N2',t)+(lambda*m_a1*x_O2_massic-m_a1*x_O2_massic)*janaf('c','O2',t))./t/(1+lambda*m_a1),T2,T3)-R_g*log(p3/p2)/1000
    h4=integral(@(t) (janaf('c','CO2',t)/16*44+janaf('c','H2O',t)/8*18+lambda*m_a1*(1-x_O2_massic)*janaf('c','N2',t)+(lambda*m_a1*x_O2_massic-m_a1*x_O2_massic)*janaf('c','O2',t))/(1+lambda*m_a1),300,T4)
    s4=s3-(1-eta_piT)/eta_piT*integral(@(t) (janaf('c','CO2',t)/16*44+janaf('c','H2O',t)/8*18+lambda*m_a1*(1-x_O2_massic)*janaf('c','N2',t)+(lambda*m_a1*x_O2_massic-m_a1*x_O2_massic)*janaf('c','O2',t))./t/(1+lambda*m_a1),T3,T4)
    
    W_mT=h3-h4
    W_mC=h2-h1
    
    syms ma mc
    [m_a, m_c] = vpasolve([lambda*m_a1 == ma/mc,... eq 3.7
        P_e == (ma+mc)*(h3-h4)*(1-k_mec)... 
        -  ma*(h2-h1)*(1+k_mec)... %Eq 3.1
        ],[ma, mc])
    
    m_g=m_a+m_c;
    ec=52205;
    
elseif diesel
    LHV_massic=43.4*10^3; %Diesel(gazole) [kJ/kg]
    m_a1=(71/4)*(32/167)/x_O2_massic %4 C12H23 + 71 O2 = 48 CO2 + 46 H2O
    lambda=(LHV_massic-(48/4)*(44/(12^2+23))*(janaf('h','CO2',T3)-janaf('h','CO2',T2))-(46/4)*(18/(12^2+23))*(janaf('h','H2O',T3)-janaf('h','H2O',T2))+m_a1*x_O2_massic*(janaf('h','O2',T3)-janaf('h','O2',T2))) / (m_a1*x_O2_massic*(janaf('h','O2',T3)-janaf('h','O2',T2))+m_a1*(1-x_O2_massic)*(janaf('h','N2',T3)-janaf('h','N2',T2)))
    flue_gas_molar_mass=(4*(12^2+23)+lambda*m_a1*4*(12^2+23))/(48+46+lambda*m_a1*(1-x_O2_massic)*4*(12^2+23)/28+lambda*m_a1*x_O2_massic*4*(12^2+23)/32-71)/1000 %[kg/mol]
    R_g=R/flue_gas_molar_mass
    
    T4= fzero(@(T4) TG_fT4_diesel(p3,p4,T3,T4,eta_piT,x_O2_massic,R_g,lambda,m_a1),700)
    h3=h2+integral(@(t) (janaf('c','CO2',t)*44/(12^2+23)*48/4+janaf('c','H2O',t)*18/(12^2+23)*46/4+lambda*m_a1*(1-x_O2_massic)*janaf('c','N2',t)+(lambda*m_a1*x_O2_massic-m_a1*x_O2_massic)*janaf('c','O2',t))/(1+lambda*m_a1),T2,T3)
    s3=s2+integral(@(t) (janaf('c','CO2',t)*44/(12^2+23)*48/4+janaf('c','H2O',t)*18/(12^2+23)*46/4+lambda*m_a1*(1-x_O2_massic)*janaf('c','N2',t)+(lambda*m_a1*x_O2_massic-m_a1*x_O2_massic)*janaf('c','O2',t))/(1+lambda*m_a1)./t,T2,T3)-R_g*log(p3/p2)/1000
    h4=h3+integral(@(t) (janaf('c','CO2',t)*44/(12^2+23)*48/4+janaf('c','H2O',t)*18/(12^2+23)*46/4+lambda*m_a1*(1-x_O2_massic)*janaf('c','N2',t)+(lambda*m_a1*x_O2_massic-m_a1*x_O2_massic)*janaf('c','O2',t))/(1+lambda*m_a1),T3,T4)
    s4=s3-(1-eta_piT)/eta_piT*integral(@(t) (janaf('c','CO2',t)*44/(12^2+23)*48/4+janaf('c','H2O',t)*18/(12^2+23)*46/4+lambda*m_a1*(1-x_O2_massic)*janaf('c','N2',t)+(lambda*m_a1*x_O2_massic-m_a1*x_O2_massic)*janaf('c','O2',t))/(1+lambda*m_a1)./t,T3,T4)
    
    syms ma mc
    [m_a, m_c] = vpasolve([lambda*m_a1 == ma/mc,...
        P_e == (ma+mc)*(h3-h4)*(1-k_mec)...
        ],[ma, mc])
    
    m_g=m_a+m_c;
    ec= 45800 ; %http://feerc.ornl.gov/pdfs/Chris_Edwards.pdf
end

%%%%%%%%%%%%%%%%%%%%%%%
%Calculs de puissances%
%%%%%%%%%%%%%%%%%%%%%%%

W_mT=h3-h4
P_mT=m_g*W_mT

W_mC=h2-h1
P_mC=m_a*W_mC

P_fmec=k_mec*(P_mT+P_mC)%=P_e-P_m
P_m=P_e+P_fmec;

%%%%%%%%%%%%%%%%%%%%%%%%%
%Rendements �nerg�tiques%
%%%%%%%%%%%%%%%%%%%%%%%%%

eta_cyclen=P_e/(m_c*LHV_massic)
eta_mec=P_e/P_m
eta_toten=eta_cyclen*eta_mec


%%%%%%%%%%%%%%%%%%%%%%%%%
%Rendements exerg�tiques%
%%%%%%%%%%%%%%%%%%%%%%%%%

h0=0;
s0=0;
e1=h1-h0-T_ref*(s1-s0);
e2=h2-h0-T_ref*(s2-s0);
e3=h3-h0-T_ref*(s3-s0);
e4=h4-h0-T_ref*(s4-s0);

eta_totex=P_e/(m_c*ec)
eta_rotex=(m_g*(h3-h4)-m_a*(h2-h1))/(m_g*(e3-e4)-m_a*(e2-e1))
eta_cyclex=(m_g*(e3-e4)-m_a*(e2-e1))/(m_g*e3-m_a*e2)
eta_combex=(m_g*e3-m_a*e2)/(m_c*ec)

%%%%%%%
%Plots%
%%%%%%%%%%%
%T-s & H-s%
%%%%%%%%%%%
length=10;
T_12=linspace(T1,T2,length);
T_23=linspace(T2,T3,length);
T_34=linspace(T3,T4,length);
T_41=linspace(T4,T1,length);

p_23=linspace(p2,p3,length);

s_12=zeros(1,length);
s_23=zeros(1,length);
s_34=zeros(1,length);
s_41=zeros(1,length);

h_12=zeros(1,length);
h_23=zeros(1,length);
h_34=zeros(1,length);
h_41=zeros(1,length);

%Compresseur:
h_300=(x_O2_massic*janaf('c','O2',300)+(1-x_O2_massic)*janaf('c','N2',300))*(300-T1);
s_300=integral(@(t) (x_O2_massic*janaf('c','O2',300)+(1-x_O2_massic)*janaf('c','N2',300))./t,T1,300);
for i= 1:length
    if T_12(i)<300
        h_12(i)=h1+(x_O2_massic*janaf('c','O2',300)+(1-x_O2_massic)*janaf('c','N2',300))*(T_12(i)-T1);
        s_12(i)=s1+integral(@(t) (x_O2_massic*janaf('c','O2',300)+(1-x_O2_massic)*janaf('c','N2',300))./t,T1,T_12(i));
    else
        h_12(i)=h1+h_300+integral(@(t) x_O2_massic*janaf('c','O2',t)+(1-x_O2_massic)*janaf('c','N2',t),300,T_12(i));
        s_12(i)=s1+(1-eta_piC)*(s_300+integral(@(t) (x_O2_massic*janaf('c','O2',t)+(1-x_O2_massic)*janaf('c','N2',t))./t,300,T_12(i)));
    end
    
    %s_12(i)=x_O2_massic*janaf('s','O2',T_12(i))+(1-x_O2_massic)*janaf('s','N2',T_12(i))-s1;
    
end

%Combustion:
for i= 1:length
    if methane
        h_23(i)=h2+integral(@(t) (janaf('c','CO2',t)/16*44+janaf('c','H2O',t)/8*18+lambda*m_a1*(1-x_O2_massic)*janaf('c','N2',t)+(lambda*m_a1*x_O2_massic-m_a1*x_O2_massic)*janaf('c','O2',t))/(1+lambda*m_a1),T2,T_23(i));
        %h_23(i)=(janaf('h','CO2',T_23(i))*1000/16*44+janaf('h','H2O',T_23(i))*1000/8*18+lambda*m_a1*(1-x_O2_massic)*janaf('h','N2',T_23(i))*1000+(lambda*m_a1*x_O2_massic-m_a1*x_O2_massic)*janaf('h','O2',T_23(i))*1000)/(1+lambda*m_a1);
        s_23(i)=s2+integral(@(t) (janaf('c','CO2',t)/16*44+janaf('c','H2O',t)/8*18+lambda*m_a1*(1-x_O2_massic)*janaf('c','N2',t)+(lambda*m_a1*x_O2_massic-m_a1*x_O2_massic)*janaf('c','O2',t))./t/(1+lambda*m_a1),T2,T_23(i))-R_g*log(p_23(i)/p2)/1000;
        
        %s_12(i)=s2+integral(@(t) (x_O2_massic*janaf('c','O2',t)+(1-x_O2_massic)*janaf('c','N2',t))./t*(1-eta_piC),T1,T_12(i));
        %s_23(i)=s2+(janaf('s','CO2',T_23(i))/16*44+janaf('s','H2O',T_23(i))/8*18+lambda*m_a1*(1-x_O2_massic)*janaf('s','N2',T_23(i))+(lambda*m_a1*x_O2_massic-m_a1*x_O2_massic)*janaf('s','O2',T_23(i)))/(1+lambda*m_a1)-R_g*log(p_23(i)/p2);
    elseif diesel
        h_23(i)=h2+integral(@(t) (janaf('c','CO2',t)*44/(12^2+23)*48/4+janaf('c','H2O',t)*18/(12^2+23)*46/4+lambda*m_a1*(1-x_O2_massic)*janaf('c','N2',t)+(lambda*m_a1*x_O2_massic-m_a1*x_O2_massic)*janaf('c','O2',t))/(1+lambda*m_a1),T2,T_23(i));
        s_23(i)=s2+integral(@(t) (janaf('c','CO2',t)*44/(12^2+23)*48/4+janaf('c','H2O',t)*18/(12^2+23)*46/4+lambda*m_a1*(1-x_O2_massic)*janaf('c','N2',t)+(lambda*m_a1*x_O2_massic-m_a1*x_O2_massic)*janaf('c','O2',t))/(1+lambda*m_a1)./t,T2,T_23(i))-R_g*log(p_23(i)/p2)/1000;
    end
end

%Turbine:
for i= 1:length
    if methane
        h_34(i)=h3+integral(@(t) (janaf('c','CO2',t)/16*44+janaf('c','H2O',t)/8*18+lambda*m_a1*(1-x_O2_massic)*janaf('c','N2',t)+(lambda*m_a1*x_O2_massic-m_a1*x_O2_massic)*janaf('c','O2',t))/(1+lambda*m_a1),T3,T_34(i));
        s_34(i)=s3-(1-eta_piT)/eta_piT*integral(@(t) (janaf('c','CO2',t)/16*44+janaf('c','H2O',t)/8*18+lambda*m_a1*(1-x_O2_massic)*janaf('c','N2',t)+(lambda*m_a1*x_O2_massic-m_a1*x_O2_massic)*janaf('c','O2',t))./t/(1+lambda*m_a1),T3,T_34(i));
        
        %s_34(i)=(janaf('s','CO2',T_34(i))/16*44+janaf('s','H2O',T_34(i))/8*18+lambda*m_a1*(1-x_O2_massic)*janaf('s','N2',T_34(i))+(lambda*m_a1*x_O2_massic-m_a1*x_O2_massic)*janaf('s','O2',T_34(i)))/(1+lambda*m_a1)-R_g*log(p_34(i)/p3);
    elseif diesel
        h_34(i)=h3+integral(@(t) (janaf('c','CO2',t)*44/(12^2+23)*48/4+janaf('c','H2O',t)*18/(12^2+23)*46/4+lambda*m_a1*(1-x_O2_massic)*janaf('c','N2',t)+(lambda*m_a1*x_O2_massic-m_a1*x_O2_massic)*janaf('c','O2',t))/(1+lambda*m_a1),T3,T_34(i));
        s_34(i)=s3-(1-eta_piT)/eta_piT*integral(@(t) (janaf('c','CO2',t)*44/(12^2+23)*48/4+janaf('c','H2O',t)*18/(12^2+23)*46/4+lambda*m_a1*(1-x_O2_massic)*janaf('c','N2',t)+(lambda*m_a1*x_O2_massic-m_a1*x_O2_massic)*janaf('c','O2',t))/(1+lambda*m_a1)./t,T3,T_34(i));
    end
end

%Transformation virtuelle 4->1
ds1=(s4+(integral(@(t) (janaf('c','CO2',t)/16*44+janaf('c','H2O',t)/8*18+lambda*m_a1*(1-x_O2_massic)*janaf('c','N2',t)+(lambda*m_a1*x_O2_massic-m_a1*x_O2_massic)*janaf('c','O2',t))./t/(1+lambda*m_a1),T4,300))+(integral(@(t) (janaf('c','CO2',300)/16*44+janaf('c','H2O',300)/8*18+lambda*m_a1*(1-x_O2_massic)*janaf('c','N2',300)+(lambda*m_a1*x_O2_massic-m_a1*x_O2_massic)*janaf('c','O2',300))./t/(1+lambda*m_a1),300,T1)))-s1;%Correction terms for CH4
dh1=h1-(h4+integral(@(t) (janaf('c','CO2',t)/16*44+janaf('c','H2O',t)/8*18+lambda*m_a1*(1-x_O2_massic)*janaf('c','N2',t)+(lambda*m_a1*x_O2_massic-m_a1*x_O2_massic)*janaf('c','O2',t))/(1+lambda*m_a1),T4,300)+(janaf('c','CO2',300)/16*44+janaf('c','H2O',300)/8*18+lambda*m_a1*(1-x_O2_massic)*janaf('c','N2',300)+(lambda*m_a1*x_O2_massic-m_a1*x_O2_massic)*janaf('c','O2',300))/(1+lambda*m_a1)*(T1-300));

ds2=(s4+integral(@(t) (janaf('c','CO2',t)*44/(12^2+23)*48/4+janaf('c','H2O',t)*18/(12^2+23)*46/4+lambda*m_a1*(1-x_O2_massic)*janaf('c','N2',t)+(lambda*m_a1*x_O2_massic-m_a1*x_O2_massic)*janaf('c','O2',t))/(1+lambda*m_a1)./t,T4,300)+(integral(@(t) (janaf('c','CO2',300)*44/(12^2+23)*48/4+janaf('c','H2O',300)*18/(12^2+23)*46/4+lambda*m_a1*(1-x_O2_massic)*janaf('c','N2',300)+(lambda*m_a1*x_O2_massic-m_a1*x_O2_massic)*janaf('c','O2',300))/(1+lambda*m_a1)./t,300,T1)))-s1; %Correction terms for C12H23
dh2=h1-(h4+integral(@(t) (janaf('c','CO2',t)*44/(12^2+23)*48/4+janaf('c','H2O',t)*18/(12^2+23)*46/4+lambda*m_a1*(1-x_O2_massic)*janaf('c','N2',t)+(lambda*m_a1*x_O2_massic-m_a1*x_O2_massic)*janaf('c','O2',t))/(1+lambda*m_a1),T4,300)+(janaf('c','CO2',300)*44/(12^2+23)*48/4+janaf('c','H2O',300)*18/(12^2+23)*46/4+lambda*m_a1*(1-x_O2_massic)*janaf('c','N2',300)+(lambda*m_a1*x_O2_massic-m_a1*x_O2_massic)*janaf('c','O2',300))/(1+lambda*m_a1)*(T1-300));


for i= 1:length
    if methane
        if T_41(i)<300
            h_41(i)=h4+integral(@(t) (janaf('c','CO2',t)/16*44+janaf('c','H2O',t)/8*18+lambda*m_a1*(1-x_O2_massic)*janaf('c','N2',t)+(lambda*m_a1*x_O2_massic-m_a1*x_O2_massic)*janaf('c','O2',t))/(1+lambda*m_a1),T4,300)+(janaf('c','CO2',300)/16*44+janaf('c','H2O',300)/8*18+lambda*m_a1*(1-x_O2_massic)*janaf('c','N2',300)+(lambda*m_a1*x_O2_massic-m_a1*x_O2_massic)*janaf('c','O2',300))/(1+lambda*m_a1)*(T_41(i)-300) +dh1*(i-1)/(length-1);
            s_41(i)=(s4+(integral(@(t) (janaf('c','CO2',t)/16*44+janaf('c','H2O',t)/8*18+lambda*m_a1*(1-x_O2_massic)*janaf('c','N2',t)+(lambda*m_a1*x_O2_massic-m_a1*x_O2_massic)*janaf('c','O2',t))./t/(1+lambda*m_a1),T4,300))+(integral(@(t) (janaf('c','CO2',300)/16*44+janaf('c','H2O',300)/8*18+lambda*m_a1*(1-x_O2_massic)*janaf('c','N2',300)+(lambda*m_a1*x_O2_massic-m_a1*x_O2_massic)*janaf('c','O2',300))./t/(1+lambda*m_a1),300,T_41(i))))-ds1*(i-1)/(length-1);
        else
            h_41(i)=h4+integral(@(t) (janaf('c','CO2',t)/16*44+janaf('c','H2O',t)/8*18+lambda*m_a1*(1-x_O2_massic)*janaf('c','N2',t)+(lambda*m_a1*x_O2_massic-m_a1*x_O2_massic)*janaf('c','O2',t))/(1+lambda*m_a1),T4,T_41(i)) +dh1*(i-1)/(length-1);
            s_41(i)=(s4+(integral(@(t) (janaf('c','CO2',t)/16*44+janaf('c','H2O',t)/8*18+lambda*m_a1*(1-x_O2_massic)*janaf('c','N2',t)+(lambda*m_a1*x_O2_massic-m_a1*x_O2_massic)*janaf('c','O2',t))./t/(1+lambda*m_a1),T4,T_41(i))))-ds1*(i-1)/(length-1);
        end
        %s_41(i)=(m_a*(x_O2*(janaf('s','O2',T_41(i)+R/32*log(p_41/p4)))+(1-x_O2)*janaf('s','N2',T_41(i)+R/14*log(p_41/p4))) + m_c*get_methane('s',T_41(i),p_41))/m_g;
    elseif diesel
        if T_41(i)<300
            h_41(i)=h4+integral(@(t) (janaf('c','CO2',t)*44/(12^2+23)*48/4+janaf('c','H2O',t)*18/(12^2+23)*46/4+lambda*m_a1*(1-x_O2_massic)*janaf('c','N2',t)+(lambda*m_a1*x_O2_massic-m_a1*x_O2_massic)*janaf('c','O2',t))/(1+lambda*m_a1),T4,300)+ (janaf('c','CO2',300)*44/(12^2+23)*48/4+janaf('c','H2O',300)*18/(12^2+23)*46/4+lambda*m_a1*(1-x_O2_massic)*janaf('c','N2',300)+(lambda*m_a1*x_O2_massic-m_a1*x_O2_massic)*janaf('c','O2',300))/(1+lambda*m_a1)*(T_41(i)-300) +dh2*(i-1)/(length-1);
            s_41(i)=s4+integral(@(t) (janaf('c','CO2',t)*44/(12^2+23)*48/4+janaf('c','H2O',t)*18/(12^2+23)*46/4+lambda*m_a1*(1-x_O2_massic)*janaf('c','N2',t)+(lambda*m_a1*x_O2_massic-m_a1*x_O2_massic)*janaf('c','O2',t))/(1+lambda*m_a1)./t,T4,300)+ integral(@(t) (janaf('c','CO2',300)*44/(12^2+23)*48/4+janaf('c','H2O',300)*18/(12^2+23)*46/4+lambda*m_a1*(1-x_O2_massic)*janaf('c','N2',300)+(lambda*m_a1*x_O2_massic-m_a1*x_O2_massic)*janaf('c','O2',300))/(1+lambda*m_a1)./t,300,T_41(i))-ds2*(i-1)/(length-1);
        else
            h_41(i)=h4+integral(@(t) (janaf('c','CO2',t)*44/(12^2+23)*48/4+janaf('c','H2O',t)*18/(12^2+23)*46/4+lambda*m_a1*(1-x_O2_massic)*janaf('c','N2',t)+(lambda*m_a1*x_O2_massic-m_a1*x_O2_massic)*janaf('c','O2',t))/(1+lambda*m_a1),T4,T_41(i)) +dh2*(i-1)/(length-1);
            s_41(i)=s4+integral(@(t) (janaf('c','CO2',t)*44/(12^2+23)*48/4+janaf('c','H2O',t)*18/(12^2+23)*46/4+lambda*m_a1*(1-x_O2_massic)*janaf('c','N2',t)+(lambda*m_a1*x_O2_massic-m_a1*x_O2_massic)*janaf('c','O2',t))/(1+lambda*m_a1)./t,T4,T_41(i)) -ds2*(i-1)/(length-1);
        end
    end
end
figure
plot(s_12,h_12,'blue')
hold on;
plot(s_23,h_23,'blue')
plot(s_34,h_34,'blue')
plot(s_41,h_41,'--blue')
text(s1,h1,'\leftarrowEtat 1')
text(s2,h2,'\leftarrowEtat 2')
text(s3,h3,'\leftarrowEtat 3')
text(s4,h4,'\leftarrowEtat 4')
title('Graphe h-s')
xlabel('Entropie [J/kgK]')
ylabel('Enthalpie [kJ/kg]')

figure
plot(s_12,T_12,'blue')
hold on;
plot(s_23,T_23,'blue')
plot(s_34,T_34,'blue')
plot(s_41,T_41,'--blue')
text(s1,T1,'\leftarrowEtat 1')
text(s2,T2,'\leftarrowEtat 2')
text(s3,T3,'\leftarrowEtat 3')
text(s4,T4,'\leftarrowEtat 4')
title('Graphe T-s')
xlabel('Entropie [J/kgK]')
ylabel('Temp�rature [K]')
%%%%%%%%%%%%%%%
%Tableau des r�sulats%
%%%%%%%%%%%%%%%

p=[p1;p2;p3;p4];
T=[T1;T2;T3;T4];
h=[h1;h2;h3;h4];
s=[s1;s2;s3;s4];
Etats={'1';'2';'3';'4'};

Table = table(p,T,h,s,'RowNames',Etats)

%%%%%%%%%%%%
%Pie Chart%
%%%%%%%%%%%%

%Energetique%

P_prim_en=m_c*LHV_massic
P_echap_en = (h4-e1)*m_g
P=[double(P_e) double(P_fmec) double(P_echap_en)];

label={sprintf('Puissance effective \n %0.1f MW ',P_e/1e3)...
    sprintf('Pertes m�caniques \n %0.1f MW ',P_fmec/1e3)...
    sprintf('Pertes � l''�chappement: \n %0.1f MW ',P_echap_en/1e3)};
figure;
pie(P,label);
title(sprintf('Distribution du flux �nerg�tique avec puissance primaire de %0.1f  MW',P_prim_en/1e3 ));

%Exergetique%
P_prim_ex=ec*m_c
P_irr_comb = P_prim_ex*(1-eta_combex)
P_echap = (e4-e1)*m_g
P_irr_tc = (e3-e4)*m_g - (e2-e1)*m_a- (h3-h4)*m_g + (h2-h1)*m_a
P=[double(P_e) double(P_fmec) double(P_irr_tc) double(P_echap) double(P_irr_comb)];

label={sprintf('Puissance effective \n %0.1f MW ',P_e/1e3)...
    sprintf('Pertes m�caniques \n %0.1f MW ',P_fmec/1e3)...
    sprintf('Irr�versibilit�s � la turbine et au compresseur \n %0.1f MW ',P_irr_tc/1e3)...
    sprintf('Pertes � l''�chappement: \n %0.1f MW ',P_echap/1e3)...
    sprintf('Irr�versibilit�s de la combustion: \n %0.1f MW ',P_irr_comb/1e3)};

figure;
pie(P,label);
title(sprintf('Distribution du flux exerg�tique avec puissance primaire de %0.1f  MW',P_prim_ex/1e3 ));

end