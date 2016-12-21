function [etat9_n] = Etat9_n(n_souti,etat6_n,etat7_n,etat8,p_bache,p1,eta_siP)
%Calcule les caractéristiques des etats 9_i

if n_souti == 0 %si pas de soutirage, les etats 9_i n'existent pas
    
    etat9_n = etat8;
    
else
    
%     etat9_n = zeros(n_souti);
    
    if n_souti >= 4 %avec bache
        
        for i = 1:3 %les rechauffeurs avant la bache
            etat9_n(i).p = p_bache;
            etat9_n(i).t = XSteam('Tsat_p',etat6_n(i).p);
            etat9_n(i).h = XSteam('h_pt',etat9_n(i).p,etat9_n(i).t);
            etat9_n(i).s = XSteam('s_pt',etat9_n(i).p,etat9_n(i).t);
            etat9_n(i).e = Exergie(etat9_n(i).h,etat9_n(i).s);
            if etat9_n(i).t == XSteam('Tsat_p',etat9_n(i).p); %si on est dans la cloche
                etat9_n(i).x = XSteam('x_ph',etat9_n(i).p,etat9_n(i).h);
            else
                etat9_n(i).x = NaN;
            end
        end
        
        %le rechauffeur au 4e soutirage
        etat9_n(4).p = p1;
        v =  XSteam('v_ph',etat7_n(4).p,etat7_n(4).h); %hypothese : volume constant
        dp = etat9_n(4).p - etat7_n(4).p;
        h9_n4 = (v*dp*100)/eta_siP + etat7_n(4).h;
        etat9_n(4).t = XSteam('T_ph',etat9_n(4).p,h9_n4);
        etat9_n(4).h = h9_n4;
        etat9_n(4).s = XSteam('s_ph',etat9_n(4).p,etat9_n(4).h);
        etat9_n(4).e = Exergie(etat9_n(4).h,etat9_n(4).s);
        if etat9_n(4).t == XSteam('Tsat_p',etat9_n(4).p); %si on est dans la cloche
            etat9_n(4).x = XSteam('x_ph',etat9_n(4).p,etat9_n(4).h);
        else
            etat9_n(4).x = NaN;
        end
        
        for i = 5 : n_souti %les rechauffeurs apres la bache
            etat9_n(i).p = p1;
            etat9_n(i).t = XSteam('Tsat_p',etat6_n(i).p);
            etat9_n(i).h = XSteam('h_pt',etat9_n(i).p,etat9_n(i).t);
            etat9_n(i).s = XSteam('s_pt',etat9_n(i).p,etat9_n(i).t);
            etat9_n(i).e = Exergie(etat9_n(i).h,etat9_n(i).s);
            if etat9_n(i).t == XSteam('Tsat_p',etat9_n(i).p); %si on est dans la cloche
                etat9_n(i).x = XSteam('x_ph',etat9_n(i).p,etat9_n(i).h);
            else
                etat9_n(i).x = NaN;
            end
        end
        
    else %sans bache
        
        for i = 1:n_souti
            etat9_n(i).p = p1;
            etat9_n(i).t = XSteam('Tsat_p',etat6_n(i).p);
            etat9_n(i).h = XSteam('h_pt',etat9_n(i).p,etat9_n(i).t);
            etat9_n(i).s = XSteam('s_pt',etat9_n(i).p,etat9_n(i).t);
            etat9_n(i).e = Exergie(etat9_n(i).h,etat9_n(i).s);
            if etat9_n(i).t == XSteam('Tsat_p',etat9_n(i).p); %si on est dans la cloche
                etat9_n(i).x = XSteam('x_ph',etat9_n(i).p,etat9_n(i).h);
            else
                etat9_n(i).x = NaN;
            end
        end
        
    end %fin boucle if secondaire
    
end %fin boucle if principale

end