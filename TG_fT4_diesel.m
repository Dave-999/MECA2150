function f = TG_fT4_diesel(p3,p4,T3,T4,eta_piT,x_O2_massic,R_g,lambda,m_a1)
cp_mean=integral(@(t) (janaf('c','CO2',t)*44/(12^2+23)*48/4+janaf('c','H2O',t)*18/(12^2+23)*46/4+lambda*m_a1*(1-x_O2_massic)*janaf('c','N2',t)+(lambda*m_a1*x_O2_massic-m_a1*x_O2_massic)*janaf('c','O2',t))/(1+lambda*m_a1),T2,T3)/(T4-T3);
f=(p4/p3)^(eta_piT*(R_g/1000)/cp_mean)-T4/T3;
end



