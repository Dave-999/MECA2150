function [etat6] = Etat6(etat5,t6,eta_siT)
%Calcule les caractéristiques de l'etat 6

etat6 = struct;
etat6.p = XSteam('psat_T',t6);
etat6.t = t6;
h6s = XSteam('h_ps',etat6.p,etat5.s); %on suppose une transformation isentropique
etat6.h = (h6s - etat5.h)*eta_siT + etat5.h; %on calcule h6 avec le rendement isentropique
etat6.s = XSteam('s_ph',etat6.p,etat6.h);
etat6.e = Exergie(etat6.h,etat6.s);
etat6.x = XSteam('x_ph',etat6.p,etat6.h);

% if etat6.t == XSteam('Tsat_p',etat6.p); %si on est dans la cloche
%     etat6.x = XSteam('x_ph',etat6.p,etat6.h);
% else
%     etat6.x = NaN;
% end

end