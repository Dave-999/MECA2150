function [e] = Exergie(h,s)
%Renvoie l'exergie d'un etat dont on connait h et s
%
%INPUT
%h : enthalpie sensible
%s = entropie

t0 = 15; %temperature de reference pour l'exergie [°C]
T0 = t0 + 273.15; %temperature de reference pour l'exergie [K]
p0 = 1; %pression de reference [bar]
h0 = XSteam('h_pt',p0,t0);
s0 = XSteam('s_pt',p0,t0);

e = (h-h0) - T0*(s-s0);

end

