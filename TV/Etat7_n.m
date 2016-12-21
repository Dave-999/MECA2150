function [etat7_n] = Etat7_n(n_souti,etat6_n,p_bache)
%Calcule les caractéristiques des etats 7_i

if n_souti == 0 %si pas de soutirage, les etats 7_i n'existent pas

    etat7_n = struct;
    etat7_n.p = 0;
    etat7_n.t = 0;
    etat7_n.h = 0;
    etat7_n.s = 0;
    etat7_n.e = 0;
    etat7_n.x = 0;
    
else
    
%     etat7_n = zeros(n_souti);
    
    for i = 1:n_souti
        if i == 4
            
            etat7_n(i).p = p_bache;
            etat7_n(i).t = XSteam('Tsat_p',etat7_n(i).p);
            etat7_n(i).h = XSteam('hL_p',etat7_n(i).p);
            etat7_n(i).s = XSteam('sL_p',etat7_n(i).p);
            etat7_n(i).e = Exergie(etat7_n(i).h,etat7_n(i).s);
            if etat7_n(i).t == XSteam('Tsat_p',etat7_n(i).p); %si on est dans la cloche
                etat7_n(i).x = XSteam('x_ph',etat7_n(i).p,etat7_n(i).h);
            else
                etat7_n(i).x = NaN;
            end
            
        else
            
            etat7_n(i).p = etat6_n(i).p;
            etat7_n(i).t = XSteam('Tsat_p',etat7_n(i).p);
            etat7_n(i).h = XSteam('hL_p',etat7_n(i).p);
            etat7_n(i).s = XSteam('sL_p',etat7_n(i).p);
            etat7_n(i).e = Exergie(etat7_n(i).h,etat7_n(i).s);
            if etat7_n(i).t == XSteam('Tsat_p',etat7_n(i).p); %si on est dans la cloche
                etat7_n(i).x = XSteam('x_ph',etat7_n(i).p,etat7_n(i).h);
            else
                etat7_n(i).x = NaN;
            end
            
        end
    end
    
end %fin boucle if

end