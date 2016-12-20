function [x4,h4,s4] = Detente(h3,s3,p4,eta)
%calcule l'etat en sortie de detente
%s3 = s4s
%eta = rendement isentropique

%On suppose que la transformation est isentropique
x4s = XSteam('x_ps',p4,s3);
h4s = XSteam('h_px',p4,x4s);
%On calcule h4 avec le rendement isentropique
h4 = (h4s - h3)*eta + h3;
x4 = XSteam('x_ph',p4,h4);
s4 = XSteam('s_ph',p4,h4);

end