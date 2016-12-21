function [etat4] = Etat4(n_resurch,etat3,rapport_HP,eta_siT)
%Calcule les caractéristiques de l'etat 4

if n_resurch == 0
    etat4 = etat3;
else
    
    etat4 = struct;
    etat4.p = etat3.p*rapport_HP;
    h4s = XSteam('h_ps',etat4.p,etat3.s); %on suppose une transformation isentropique
    h4 = (h4s - etat3.h)*eta_siT + etat3.h; %on calcule h4 avec le rendement isentropique
    etat4.t = XSteam('T_ph',etat4.p,h4);
    etat4.h = h4;
    etat4.s = XSteam('s_ph',etat4.p,etat4.h);
    etat4.e = Exergie(etat4.h,etat4.s);
    if etat4.t == XSteam('Tsat_p',etat4.p); %si on est dans la cloche
        etat4.x = XSteam('x_ph',etat4.p,etat4.h);
    else
        etat4.x = NaN;
    end

end

end