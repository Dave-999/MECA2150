function [etat6_i] = Detente_6n(h,etat5,eta_siT)
% Calcule la detente pour les etats 6_n

etat6_i = struct;
h6_i_s = etat5.h + (h-etat5.h)/eta_siT;
etat6_i.p = XSteam('p_hs',h6_i_s,etat5.s);
etat6_i.t = XSteam('T_ph',etat6_i.p,h);
etat6_i.h = h;
etat6_i.s = XSteam('s_ph',etat6_i.p,etat6_i.h);
etat6_i.e = Exergie(etat6_i.h,etat6_i.s);
if etat6_i.t == XSteam('Tsat_p',etat6_i.p); %si on est dans la cloche
    etat6_i.x = XSteam('x_ph',etat6_i.p,etat6_i.h);
else
    etat6_i.x = NaN;
end

end