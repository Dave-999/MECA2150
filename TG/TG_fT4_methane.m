function f = TG_fT4_methane(p3,p4,T3,T4,eta_piT,x_O2_massic,R_g,lambda,m_a1)
if T4>300
cp_mean=integral(@(t) (janaf('c','CO2',t)/16*44+janaf('c','H2O',t)/8*18+lambda*m_a1*(1-x_O2_massic)*janaf('c','N2',t)+(lambda*m_a1*x_O2_massic-m_a1*x_O2_massic)*janaf('c','O2',t))/(1+lambda*m_a1),T3,T4)/(T4-T3);
else
    cp_mean=(janaf('c','CO2',300)/16*44+janaf('c','H2O',300)/8*18+lambda*m_a1*(1-x_O2_massic)*janaf('c','N2',300)+(lambda*m_a1*x_O2_massic-m_a1*x_O2_massic)*janaf('c','O2',300))/(1+lambda*m_a1);
end
    f=(p4/p3)^(eta_piT*(R_g/1000)/cp_mean)-T4/T3;
end
