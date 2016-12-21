function f = TGV_fT5g(h5g, frac_CO2, frac_H2O, frac_O2, frac_N2, T)

f = h5g - hf_Fumee(frac_CO2, frac_H2O, frac_O2, frac_N2, T);

end

