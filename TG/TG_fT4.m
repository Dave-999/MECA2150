function f = TG_fT4(p3,p4,T3,T4,eta_piT,x_O2_massic,R_g,lambda,m_a1,fracP_CO2,fracP_H2O,fracP_O2,fracP_N2)

if T4>300
cp_mean=integral(@(t) janaf('c','CO2',t)*fracP_CO2+janaf('c','H2O',t)*fracP_H2O+janaf('c','N2',t)*fracP_N2+janaf('c','O2',t)*fracP_O2,T4,T3)/(T3-T4);
else
    cp_mean=(janaf('c','CO2',300)*fracP_CO2+janaf('c','H2O',300)*fracP_H2O+janaf('c','N2',300)*fracP_N2+janaf('c','O2',300)*fracP_N2)*(300-T4)+integral(@(t) (janaf('c','CO2',t)*fracP_CO2+janaf('c','H2O',t)*fracP_H2O+janaf('c','N2',t)*fracP_N2+janaf('c','O2',t)*fracP_O2),300,T3)/(T3-T4);
end
    f=(p4/p3)^(eta_piT*(R_g)/1000/cp_mean)-T4/T3;
end

