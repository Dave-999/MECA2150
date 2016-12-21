function [etat2] = Etat2(etat1,p2,eta_siP)
%Calcule les caractéristiques de l'etat 2

etat2.p = p2;
v =  XSteam('v_ph',etat1.p,etat1.h); %hypothese : volume constant
dp = etat2.p - etat1.p;
h2 = (v*dp*100)/eta_siP + etat1.h;
etat2.t = XSteam('T_ph',etat2.p,h2);
etat2.h = h2;
etat2.s = XSteam('s_ph',etat2.p,etat2.h);
etat2.e = Exergie(etat2.h,etat2.s);
if etat2.t == XSteam('Tsat_p',etat2.p); %si on est dans la cloche
    etat2.x = XSteam('x_ph',etat2.p,etat2.h);
else
    etat2.x = NaN;
end

end