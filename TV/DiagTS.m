function [] = DiagTS()
%Dessine le diagramme (T,s) d'une TV

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


end