function [etat6_n] = Etat6_n(n_souti,n_resurch,etat4,etat5,etat6,eta_siT)
%Calcule les caractéristiques des etats 6_i

if n_souti == 0 %si pas de soutirage, les etats 6_i n'existent pas
    
    etat6_n = struct;
    etat6_n.p = 0;
    etat6_n.t = 0;
    etat6_n.h = 0;
    etat6_n.s = 0;
    etat6_n.e = 0;
    etat6_n.x = 0;
    
else
    
    n_diff = n_souti - n_resurch;    
    if n_diff > 0
        for i = 1:n_diff
            h6_n(i) = etat6.h + i*(etat5.h-etat6.h)/(n_diff+1);
            etat6_n(i) = Detente(h6_n(i),etat5,eta_siT);
        end
    end
    
    if n_resurch == 1
        etat6_n(n_souti) = etat4;
    end  
    
end

end