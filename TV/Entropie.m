function [S] = Entropie(Ti, Tf, espece)
%Renvoie l'entropie d'une espece
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
    S = janaf('c',espece,300)*integral((@(T) 1./T),Ti,Tf);
else
    Tf = min(Tf,5000); %donnees dans janaf jusque 5000K
    S = janaf('c',espece,300)*integral((@(T) 1./T),Ti,300) + (janaf('s',espece,Tf) - janaf('s',espece,300));
end

end