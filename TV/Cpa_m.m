function Cpa = Cpa_m(Ti, Tf, frac_O2, frac_N2)
% Air ambiant
% Renvoie la capacite calorifique moyenne ("barre verticale",formule p.31)
%
% Arguments :
% T0 : borne min d'integration [°C]
% Tf : borne max d'integration [°C]
% frac_O2 : fraction massique de O2 dans les fumees
% frac_N2 : fraction massique de N2 dans les fumees


%CelsiusToKelvin
Ti = Ti + 273.15;
Ti = max(Ti, 300);
Tf = Tf + 273.15;
Tf = max(Tf, 300);
if Tf == 300
    Cpa = 0;
else

fun = (@(T) (janaf('c','O2',T)*frac_O2 + janaf('c','N2',T)*frac_N2));
Cpa = integral(fun,Ti,Tf)/(Tf-Ti); %formule p.31

end