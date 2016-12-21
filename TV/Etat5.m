function [etat5] = Etat5(n_resurch,etat3,etat4)
%Calcule les caractéristiques de l'etat 5

if n_resurch == 0
    etat5 = etat3;
else

    etat5 = struct;
    etat5.p = etat4.p;
    etat5.t = etat3.t; %donnée
    etat5.h = XSteam('h_pT',etat5.p,etat5.t);
    etat5.s = XSteam('s_pT',etat5.p,etat5.t);
    etat5.e = Exergie(etat5.h,etat5.s);
    if etat5.t == XSteam('Tsat_p',etat5.p); %si on est dans la cloche
        etat5.x = XSteam('x_ph',etat5.p,etat5.h);
    else
        etat5.x = NaN;
    end
    
end

end