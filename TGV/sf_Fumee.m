function s_f = sf_Fumee(frac_CO2, frac_H2O, frac_O2, frac_N2, T)
if T>300
    s_f=integral(@(t) (janaf('c','CO2',300)*frac_CO2+janaf('c','H2O',300)*frac_H2O+janaf('c','N2',300)*frac_N2+janaf('c','O2',300)*frac_O2)./t,273.15,300)+integral(@(t) (janaf('c','CO2',t)*frac_CO2+janaf('c','H2O',t)*frac_H2O+janaf('c','N2',t)*frac_N2+janaf('c','O2',t)*frac_O2)./t,300,T);
else
    h_f=integral(@(t) (janaf('c','CO2',300)*frac_CO2+janaf('c','H2O',300)*frac_H2O+janaf('c','N2',300)*frac_N2+janaf('c','O2',300)*frac_O2)./t,273.15,T);
end