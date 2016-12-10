function [] = TV()
%main function
close all; clc;

%%donnees
T3 = 525; %[°C]
p3 = 200; %[bar]
deltaT = 15; %HYPOTHESE
T4 = 15 + deltaT; %eau riviere à 15°
eta_si_34 = 0.88; %HYPOTHESE
eta_si_12 = 0.88; %HYPOTHESE
P_e=35*10^3; %[kW]
fuel='methane';
%fuel='diesel'
T_ref=15+273.15%[K]
lambda=1.05;
k_cal_loss=0.01;
eta_mec=0.98;
x_O2_molar=0.21;
x_O2_massic=x_O2_molar*32/(x_O2_molar*32+(1-x_O2_molar)*28)
t_ech=120+273.15%[K] vrai uniquement pour le méthane normalement (pg66)

if strcmp(fuel,'methane')
    methane=true;
    diesel=false;
    LHV_massic=5.0150*10^4; %[kJ/kg]
    %LHV_molar=LHV_massic*16/1000; %[kJ/mol]
    m_a1=2*2/x_O2_massic %CH4 + 2 O2 = CO2 + 2 H2O
    t_ech=120+273.15%[K]
    c_pf_integral=(janaf('c','CO2',300)/16*44+janaf('c','H2O',300)/8*18+lambda*m_a1*(1-x_O2_massic)*janaf('c','N2',300)+(lambda*m_a1*x_O2_massic-m_a1*x_O2_massic)*janaf('c','O2',300))/(1+lambda*m_a1)*(300-273.15)+ integral(@(t) (janaf('c','CO2',t)/16*44+janaf('c','H2O',t)/8*18+lambda*m_a1*(1-x_O2_massic)*janaf('c','N2',t)+(lambda*m_a1*x_O2_massic-m_a1*x_O2_massic)*janaf('c','O2',t))/(1+lambda*m_a1),300,t_ech);
    c_pa_integral=(x_O2_massic*janaf('c','O2',300)+(1-x_O2_massic)*janaf('c','N2',300))*(300-T_ref);
    p_ech=((lambda*m_a1+1)*c_pf_integral-lambda*m_a1*c_pa_integral)/LHV_massic
    ec=52205;
elseif strcmp(fuel,'diesel')
    diesel=true;
    methane=false;
    LHV_massic=43.4*10^3; %Diesel(gazole) [kJ/kg]
    %LHV_molar=LHV_massic*167/1000;
    m_a1=(71/4)*(32/167)/x_O2_massic %4 C12H23 + 71 O2 = 48 CO2 + 46 H2O
    %t_ech= A CALCULER
    %Idem pour p_ech pg66
    ec= 45800 ; %http://feerc.ornl.gov/pdfs/Chris_Edwards.pdf
end

%%etats

%etat 3
etat3 = struct;
etat3.p = p3;
etat3.T = T3;
etat3.x = -1;
etat3.h = XSteam('h_pt',etat3.p,etat3.T); %[kJ/kg]
etat3.s = XSteam('s_pt',etat3.p,etat3.T); %[kJ/kg.°C]

%etat 4
etat4 = struct;
etat4.p = XSteam('psat_T',T4); %[bar]
etat4.T = T4;
[x4,h4,s4] = Etat_detente(etat3.h,etat3.s,etat4.p,eta_si_34);
etat4.x = x4;
etat4.h = h4;
etat4.s = s4;

%etat 1
etat1 = struct;
etat1.p = etat4.p; %refroidissement isobare
etat1.T = etat4.T; %car isobare
etat1.x = 0; %etat 1 sur la courbe x=0
etat1.h = XSteam('h_px',etat1.p,etat1.x);
etat1.s = XSteam('s_ph',etat1.p,etat1.h);

%etat 2
etat2.p = etat3.p; %apport de chaleur isobare
[T2,h2,s2] = Etat_compression(etat1.h,etat1.s,etat2.p,eta_si_12);
etat2.T = T2;
etat2.x = -1;
etat2.h = h2;
etat2.s= s2;

%%%%%%%%%%%%%%%%%%%%
%Power calculations%
%%%%%%%%%%%%%%%%%%%%

if methane
    eta_cyclen=((etat3.h-etat4.h)-(etat2.h-etat1.h))/(etat3.h-etat2.h)
    eta_gen=1-k_cal_loss-p_ech
    eta_toten=eta_mec*eta_cyclen*eta_gen
    m_v=P_e/eta_mec/((etat3.h-etat4.h)-(etat2.h-etat1.h))
    %m_v=3.2*P_e/3600 %pg 67
    m_c=m_v*(etat3.h-etat2.h)/eta_gen/LHV_massic
elseif diesel
    %...
end


%rendement thermique
w_m = abs(etat4.h-etat3.h) - abs(etat2.h-etat1.h);
qI = abs(etat3.h-h2);
eta_th = w_m/qI;
fprintf('Rendement thermique = %f \n',eta_th);

%%%%%%%%%%%%
%Pie Chart%
%%%%%%%%%%%%

%Energetic%
P_prim=m_c*LHV_massic;
P_mec=P_e*(1-eta_mec)
P_gen=P_prim*(1-eta_gen)
P_cond=P_prim-P_e-P_mec-P_gen
P=[P_e P_mec P_cond P_gen];
 
label={sprintf('Effective power \n %0.1f MW ',P_e/1e3)...
        sprintf('Mecanic losses \n %0.1f MW ',P_mec/1e3)...
            sprintf('Condensor losses \n %0.1f MW ',P_cond/1e3)...
                sprintf('Vapor generator losses: \n %0.1f MW ',P_gen/1e3)};

figure;
pie(P,label);
 title(sprintf('Energetic flux distribution with Primary Power of  %0.1f  MW',P_prim/1e3 ));

%Exergetic$
eta_totex=P_e/(m_c*ec)
%eta_gex=m_v*(state3.e-state2.e)/m_c*ec
%... 
%

% %piecharts
% X = [w_m (qI-w_m)];
% piechart(X);

%plot (T,s)
%DiagTS([s1,T1],[s2,T2],[s3,T3],[s4,T4]);



end