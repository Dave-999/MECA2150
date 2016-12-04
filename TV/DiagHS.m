function [] = DiagHS()
%dessine le diagramme (h,s) d'une centrale TV

%cloche TS
T_0 = 1e-2; %[°C]

S = linspace(XSteam('sL_T',T_0),XSteam('sV_T',T_0),200);
P = arrayfun(@(s) XSteam('psat_s',s), S);
H = arrayfun(@(p,s) XSteam('h_ps',p,s), P, S);
figure;
plot(S,H,'k');
xlabel('s [kJ/kg K]');
ylabel('h [kJ/kg]');
title('Diagramme (h,s) d''une centrale TV');
hold on;

%


end