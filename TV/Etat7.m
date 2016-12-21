function [etat7] = Etat7(etat6)
%Calcule les caractéristiques de l'etat 7

etat7 = struct;
etat7.p = etat6.p;
etat7.t = etat6.t;
etat7.h = XSteam('hL_T',etat7.t);
etat7.s = XSteam('sL_T',etat7.t);
etat7.e = Exergie(etat7.h,etat7.s);
etat7.x = XSteam('x_ph',etat7.p,etat7.h);

% if etat7.t == XSteam('Tsat_p',etat7.p); %si on est dans la cloche
%     etat7.x = XSteam('x_ph',etat7.p,etat7.h);
% else
%     etat7.x = NaN;
% end

end