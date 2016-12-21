function [etat2] = Detente(h,etat1,eta_siT)
% Calcule une detente jusque h donné

etat2 = struct;
h6_i_s = etat1.h + (h-etat1.h)/eta_siT;
etat2.p = XSteam('p_hs',h6_i_s,etat1.s);
etat2.t = XSteam('T_ph',etat2.p,h);
etat2.h = h;
etat2.s = XSteam('s_ph',etat2.p,etat2.h);
etat2.e = Exergie(etat2.h,etat2.s);
if etat2.t == XSteam('Tsat_p',etat2.p); %si on est dans la cloche
    etat2.x = XSteam('x_ph',etat2.p,etat2.h);
else
    etat2.x = NaN;
end

end