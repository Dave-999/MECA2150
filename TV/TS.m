function [] = TS(n_souti,n_resurch,etat1,etat2,etat3,etat4,etat5,etat6,etat6_n,etat7,etat7_n,etat8,etat9_n,eta_siT)
%Dessine le diagramme (T,s) de la TV

n = 200;

%cloche
T_0 = 1e-4; %[°C] car XSteam ne trouve rien pour T=0°C

S = linspace(0,XSteam('sV_T',T_0),n); %vecteur s dans la cloche
T = arrayfun(@(s) XSteam('Tsat_s',s), S);
plot(S,T,'k');
xlabel('s [kJ/kg K]');
ylabel('T [°C]');
title('Diagramme (T,s) d''une centrale TV');
hold on;

%1->2 on neglige cette transformation 

%2->3

T23 = linspace(etat2.t,etat3.t,n);
S23 = zeros(1,n);
for i = 1:n
    S23(i) = XSteam('s_pt',etat3.p,T23(i));
end
plot(S23,T23,'b');
hold on;

%3->4

T34 = zeros(n,1);
S34 = zeros(n,1);
h34 = linspace(etat3.h,etat4.h,n);
for i = 1:n
    struct = Detente(h34(i),etat3,eta_siT);
    S34(i) = struct.s;
    T34(i) = struct.t;
end
plot(S34,T34,'b');
hold on;

%4->5

if n_resurch > 0
    T45 = linspace(etat4.t,etat5.t,n);
    S45 = zeros(1,n);
    for i = 1:n
        S45(i) = XSteam('s_pt',etat4.p,T45(i));
    end
    plot(S45,T45,'b');
    hold on;
end

%5->6

T56 = zeros(n,1);
S56 = zeros(n,1);
h56 = linspace(etat5.h,etat6.h,n);
for i=1:n
    struct = Detente( h56(i),etat5,eta_siT);
    S56(i) = struct.s;
    T56(i) = struct.t;
end
plot(S56,T56,'b');
hold on;

%6->7

T67 = zeros(n,1);
S67 = linspace(etat6.s,etat7.s,n);
for i=1:n
    T67(i) = XSteam('T_ps',etat6.p,S67(i));
end
plot(S67,T67,'b');
hold on;

%6n->7

for i = 1:n_souti
    T6n7 = zeros(n,1);
    S6n7 = linspace(etat6_n(i).s,etat7.s,n);
    for j = 1:n
        T6n7(j) = XSteam('T_ps',etat6_n(i).p,S6n7(j));
    end
    plot(S6n7,T6n7,'r');
    plot(S6n7(1),T6n7(1),'.r');
    hold on;
end

%7->8 on neglige cette transformation

%8->fin
if n_souti > 3
    
    %8->7_4
    T87_4 = linspace(etat8.t,etat7_n(4).t,n);
    S87_4 = zeros(1,n);
    for i = 1:n
        S87_4(i) = XSteam('s_pt',etat8.p,T87_4(i));
    end
    plot(S87_4,T87_4,'b');
    hold on;
    
    %9_4->1
    T9_41 = linspace(etat9_n(4).t,etat1.t,n);
    S9_41 = zeros(1,n);
    for i = 1:n
        S9_41(i) = XSteam('s_pt',etat1.p,T9_41(i));
    end
    plot(S9_41,T9_41,'b');
    hold on;
    
else
    
    %8->1
    T81 = linspace(etat8.t,etat1.t,n);
    S81 = zeros(1,n);
    for i = 1:n
        S81(i) = XSteam('s_pt',etat1.p,T81(i));
    end
    plot(S81,T81,'b');
    hold off;
    
end

end