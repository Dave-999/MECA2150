function [] = HS(n_souti,n_resurch,etat1,etat2,etat3,etat4,etat5,etat6,etat6_n,etat7,etat7_n,etat8,etat9_n,eta_siT)
%Dessine le diagramme (h,s) de la TV

n = 200;

%cloche
T_0 = 1e-4; %[°C]

S = linspace(XSteam('sL_T',T_0),XSteam('sV_T',T_0),200);
P = arrayfun(@(s) XSteam('psat_s',s), S);
H = arrayfun(@(p,s) XSteam('h_ps',p,s), P, S);
plot(S,H,'k');
xlabel('s [kJ/kg K]');
ylabel('h [kJ/kg]');
title('Diagramme (h,s) d''une centrale TV');
hold on;

%1->2 on neglige cette transformation

%2->3

h23 = linspace(etat2.h,etat3.h,n);
S23 = zeros(1,n);
for i = 1:n
    S23(i) = XSteam('s_ph',etat3.p,h23(i));
end
plot(S23,h23,'b');
hold on;

%3->4

h34 = linspace(etat3.h,etat4.h,n);
S34 = zeros(n,1);
for i=1:n
    struct = Detente(h34(i),etat3,eta_siT);
    S34(i) = struct.s;
end
plot(S34,h34,'b')
hold on;

%4->5

if n_resurch > 0
    h45 = linspace(etat4.h,etat5.h,n);
    S45 = zeros(1,n);
    for i = 1:n
        S45(i) = XSteam('s_ph',etat4.p,h45(i));
    end
    plot(S45,h45,'b')
    hold on
end

%5->6

h56 = linspace(etat5.h,etat6.h,n);
S56 = zeros(n,1);
for i=1:n
    struct = Detente(h56(i),etat5,eta_siT);
    S56(i) = struct.s;
end
plot(S56,h56,'b')
hold on;

%6->7

h67 = zeros(n,1);
S67 = linspace(etat6.s,etat7.s,n);
for i = 1:n
    h67(i) = XSteam('h_ps',etat6.p,S67(i));
end
plot(S67,h67,'b')
hold on;

%6n->7

for i = 1:n_souti
    S6n7 = linspace(etat6_n(i).s,etat7.s,n);
    h6n7 = zeros(n,1);
    for j = 1:n
        h6n7(j) = XSteam('h_ps',etat6_n(i).p,S6n7(j));
    end
    plot(S6n7,h6n7,'r')
    plot(S6n7(1),h6n7(1),'.r')
    hold on;
end

%7->8 on neglige cette transformation

%8->fin
if n_souti > 3
    
    %8->7_4
    h87_4 = linspace(etat8.h,etat7_n(4).h,n);
    S87_4 = zeros(1,n);
    for i = 1:n
        S87_4(i) = XSteam('s_ph',etat8.p,h87_4(i));
    end
    plot(S87_4,h87_4,'b');
    hold on;
    
    %9_4->1
    h9_41 = linspace(etat9_n(4).h,etat1.h,n);
    S9_41 = zeros(1,n);
    for i = 1:n
        S9_41(i) = XSteam('s_ph',etat1.p,h9_41(i));
    end
    plot(S9_41,h9_41,'b');
    hold on;
    
else
    
    %8->1
    H81 = linspace(etat8.h,etat1.h,n);
    S81 = zeros(1,n);
    for i = 1:n
        S81(i) = XSteam('s_ph',etat1.p,H81(i));
    end
    plot(S81,H81,'b');
    hold off;
    
end

end