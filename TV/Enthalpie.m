function [h] = Enthalpie(Ti, Tf, espece)
%Renvoie l'enthalpie sensible d'une espece
%
% INPUT
% Ti : borne min d'integration [°C]
% Tf : borne max d'integration [°C]
% espece

%CelsiusToKelvin
Ti = Ti + 273.15;
Tf = Tf + 273.15;

%on considere que la capacite calorifique est constante jusque 300K
if Tf < 300
    h = janaf('c',espece,300)*(Tf-Ti);
else
    Tf = min(Tf,5000); %donnees dans janaf jusque 5000K
    h = janaf('c',espece,300)*(300-Ti) + (janaf('h',espece,Tf) - janaf('h',espece,300));
    %h = janaf('c',espece,300)*(300-Ti) + integral((@(T) (janaf('c',espece,T))),300,Tf);
end

end