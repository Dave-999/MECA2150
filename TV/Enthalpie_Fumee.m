function [h_f] = Enthalpie_Fumee(Ti, Tf, fracP_CO2, fracP_H2O, fracP_O2, fracP_N2)
%Renvoie l'enthalpie des fumees h_f
%
% INPUT
% Ti : borne min d'integration [°C]
% Tf : borne max d'integration [°C]
% fracP_CO2 : fraction massique de CO2 dans les fumees
% fracP_H2O : fraction massique de H2O dans les fumees
% fracP_O2 : fraction massique de O2 dans les fumees
% fracP_N2 : fraction massique de N2 dans les fumees

h_f = fracP_CO2*Enthalpie(Ti, Tf, 'CO2') + fracP_H2O*Enthalpie(Ti, Tf, 'H2O')...
      + fracP_O2*Enthalpie(Ti, Tf, 'O2') + fracP_N2*Enthalpie(Ti, Tf, 'N2');
  
end