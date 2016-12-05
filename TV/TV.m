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

%%

%rendement thermique
w_m = abs(etat4.h-etat3.h) - abs(etat2.h-etat1.h);
qI = abs(etat3.h-h2);
eta_th = w_m/qI;
fprintf('Rendement thermique = %f \n',eta_th);

%piecharts
X = [w_m (qI-w_m)];
piechart(X);

%plot (T,s)
%DiagTS([s1,T1],[s2,T2],[s3,T3],[s4,T4]);



end