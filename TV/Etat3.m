function [etat3] = Etat3(p3,t3)
%Calcule les caractéristiques de l'etat 3

etat3 = struct;
etat3.p = p3; %[bar]
etat3.t = t3; %[°C]
etat3.h = XSteam('h_pt',etat3.p,etat3.t); %[kJ/kg]
etat3.s = XSteam('s_pt',etat3.p,etat3.t); %[kJ/kgK]
etat3.e = Exergie(etat3.h,etat3.s); %[kJ/kg]
if etat3.t == XSteam('Tsat_p',etat3.p); %si on est dans la cloche
    etat3.x = XSteam('x_ph',etat3.p,etat3.h);
else
    etat3.x = NaN;
end

end