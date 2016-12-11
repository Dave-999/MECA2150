function f= TG_fT2(p1,p2,T1,T2,eta_piC,x_O2_massic,R_a)
if T2>300
cp_mean=((x_O2_massic*janaf('c','O2',300)+(1-x_O2_massic)*janaf('c','N2',300))*(300-T1)+integral(@(t) x_O2_massic*janaf('c','O2',t)+(1-x_O2_massic)*janaf('c','N2',t),300,T2))/(T2-T1);
else 
    cp_mean=x_O2_massic*janaf('c','O2',300)+(1-x_O2_massic)*janaf('c','N2',300);
end

f=(p2/p1)^(1/eta_piC*(R_a/1000)/cp_mean)-T2/T1;
end
