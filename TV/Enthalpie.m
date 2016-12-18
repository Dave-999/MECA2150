function [h] = Enthalpie(Ti, Tf, espece)
%Renvoie l'enthalpie relative d'une espece à la temperature Tf

%CelsiusToKelvin
Ti = Ti + 273.15;
Tf = Tf + 273.15;

Cp = janaf('c',espece,300);

if Tf < 300
    h = Cp*(Tf-Ti);
else
    Tf = max(Tf,300); 
    Tf = min(Tf,5000);
    h = Cp*(300-Ti) + (janaf('h',espece,Tf) - janaf('h',espece,300));
    %h = Cp*(300-Ti) + integral((@(T) (janaf('c',espece,T))),300,Tf);
end

end