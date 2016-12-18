function [T] = DewPoint(p)
%Renvoie le point de rosee [°C] pour une pression partielle de vapeur d'eau
%https://en.wikipedia.org/wiki/Dew_point

a = 6.112;
b = 17.67;
c = 243.5;

T = c*log(p/a)/(b - log(p/a));

end