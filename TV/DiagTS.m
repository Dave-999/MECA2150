function [] = DiagTS(etat1,etat2,etat3,etat4)
%dessine le diagramme (T,s) d'une centrale TV

%cloche
T_0 = 1e-4; %[°C] car XSteam ne trouve rien pour T=0°C

S = linspace(0,XSteam('sV_T',T_0),200); %vecteur s dans la cloche
T = arrayfun(@(s) XSteam('Tsat_s',s), S);
figure;
plot(S,T,'k');
xlabel('s [kJ/kg K]');
ylabel('T [°C]');
title('Diagramme (T,s) d''une centrale TV');
hold on;

%transfo 1-2
S12 = arrayfun(@(s) XSteam('Tsat_s',s), S);
T12 = arrayfun(@(s) XSteam('Tsat_s',s), S);
plot(S12,T12,'b');
hold on;

%transfo 2-3
S23 = arrayfun(@(s) XSteam('Tsat_s',s), S);
T23 = arrayfun(@(s) XSteam('Tsat_s',s), S);
plot(S23,T23,'b');
hold on;

%transfo 3-4
S34 = arrayfun(@(s) XSteam('Tsat_s',s), S);
T34 = arrayfun(@(s) XSteam('Tsat_s',s), S);
plot(S34,T34,'b');
hold on;

%transfo 4-1
S41 = arrayfun(@(s) XSteam('Tsat_s',s), S);
T41 = arrayfun(@(s) XSteam('Tsat_s',s), S);
plot(S41,T41,'b');
hold off;


end