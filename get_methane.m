function out = get_methane(prop,T)
%T in [K]
%Under perfect gas hypothesis
%Normal reference conditions: 25°C and 1 bar
m=[-0.703029, 108.4773, -42.52157 , 5.862788 , 0.678565, -76.84376, 158.7163, -74.87310]/16;
R=8.314472;
%R_star=R/16;
%p_ref=10^5;
if strcmp(prop, 'cp')
    out=m(1)+m(2)*T/1000+m(3)*(T/1000)^2+m(4)*(T/1000)^3+m(5)*(T/1000)^-2;
elseif strcmp(prop, 'h')
    out=m(1)*(T/1000)+m(2)/2*(T/1000)^2+m(3)/3*(T/1000)^3+m(4)/4*(T/1000)^4-m(5)*(T/1000)^-1+m(6)-m(8);
elseif strcmp(prop, 's')
    out=m(1)*log(T/1000)+m(2)*(T/1000)+m(3)/2*(T/1000)^2+m(4)/3*(T/1000)^3-m(5)/(2*(T/1000)^2)+m(7)  %+  R_star*log(p/p_ref);
end