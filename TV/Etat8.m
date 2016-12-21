function [etat8] = Etat8(n_souti,etat7,p_bache,p1,eta_siP)
%Calcule les caractéristiques de l'etat 8

etat8 = struct;

if n_souti >= 4
    etat8.p = p_bache;  
else
    etat8.p = p1;
end
    
v =  XSteam('v_ph',etat7.p,etat7.h); %hypothese : volume constant
dp = etat8.p - etat7.p;
h8 = (v*dp*100)/eta_siP + etat7.h;
etat8.t = XSteam('T_ph',etat8.p,h8);
etat8.h = h8;
etat8.s = XSteam('s_ph',etat8.p,etat8.h);
etat8.e = Exergie(etat8.h,etat8.s);
if etat8.t == XSteam('Tsat_p',etat8.p); %si on est dans la cloche
    etat8.x = XSteam('x_ph',etat8.p,etat8.h);
else
    etat8.x = NaN;
end

end