function [T2,h2,s2] = Etat_compression(h1,s1,p2,eta)
%calcule l'etat en sortie de pompe
%s1 = s2s
%eta = rendement isentropique

%On suppose que la transformation est isentropique
h2s = XSteam('h_ps',p2,s1);
%On calcule h2 avec le rendement isentropique
h2 = (h2s - h1)/eta + h1;
s2 = XSteam('s_ph',p2,h2);
T2 = XSteam('T_ph',p2,h2);

end