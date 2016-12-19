%TG(230,'CH4',0.9,0.9,0.015,1050,0.95,10)
function A = TG(P_e, fuel, eta_piC, eta_piT, k_mec, T3, k_cc, r)
%A faire varier:

if nargin ==0
P_e=230;%[MW]
fuel = 'CH4';
eta_piC=0.9;
eta_piT=0.9;
k_mec=0.015;
T3=1050; %[°C] valeur max
k_cc=0.95;
r=10;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%
%Propriétés invariantes%
%%%%%%%%%%%%%%%%%%%%%%%%
P_e=P_e*10^3 %[kW]
T3=T3+273.15 %[K]
R=8.314472;
R_a=287.1;
x_O2_molar=0.21;
x_O2_massic=x_O2_molar*32/(x_O2_molar*32+(1-x_O2_molar)*28); %Fraction massique d'O2 dans l'air =cst
gamma=1.4;
T1=15+273.15;
T_ref=0+273.15; %T de référence pour h, s et e
p1=10^5; %[Pa]
p2=p1*r;
p3=p2*k_cc;
p4=p3/k_cc/r; %pg 118

%%%%%%%%%%%%%%%%%%%%%%%%
%Calculs pour l'étape 1%
%%%%%%%%%%%%%%%%%%%%%%%%

h1=(x_O2_massic*janaf('c','O2',300)+(1-x_O2_massic)*janaf('c','N2',300))*(T1-T_ref); %Reference state
s1=integral(@(t) (x_O2_massic*janaf('c','O2',300)+(1-x_O2_massic)*janaf('c','N2',300))./t,T_ref,T1);

%%%%%%%%%%%%%%%%%%%%%%%%
%Calculs pour l'étape 2%
%%%%%%%%%%%%%%%%%%%%%%%%

T2= fzero(@(T2) TG_fT2(p1,p2,T1,T2,eta_piT,x_O2_massic,R_a),700); %pg 120
h2=h1+(x_O2_massic*janaf('c','O2',300)+(1-x_O2_massic)*janaf('c','N2',300))*(300-T1)+integral(@(t) x_O2_massic*janaf('c','O2',t)+(1-x_O2_massic)*janaf('c','N2',t),300,T2);%(other way to get the same result)
s2=s1+(integral(@(t) (x_O2_massic*janaf('c','O2',300)+(1-x_O2_massic)*janaf('c','N2',300))./t,T1,300)+integral(@(t) (x_O2_massic*janaf('c','O2',t)+(1-x_O2_massic)*janaf('c','N2',t))./t,300,T2))*(1-eta_piC)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Calculs du lambda, des états 3 et 4%
%et des débits massiques            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

syms l
[PCI_massique, ec, m_a1,fracP_CO2, fracP_H2O, fracP_O2, fracP_N2, n_CO2, n_H2O, n_O2, n_N2,M] = Combustion(fuel,l);

lambda=solve(@(l) PCI_massique==(fracP_CO2*(janaf('h','CO2',T3)-janaf('h','CO2',T2))+fracP_H2O*(janaf('h','H2O',T3)-janaf('h','H2O',T2))+fracP_O2*(janaf('h','O2',T3)-janaf('h','O2',T2))+fracP_N2*(janaf('h','N2',T3)-janaf('h','N2',T2)))*(1+m_a1*l),l);
lambda=double(lambda);
[PCI_massique, ec, m_a1,frac_CO2, frac_H2O, frac_O2, frac_N2, n_CO2, n_H2O, n_O2, n_N2,M] = Combustion(fuel,lambda);
flue_gas_molar_mass=(M+M*m_a1*lambda)/(n_CO2+ n_H2O+ n_O2+ n_N2)/1000;
R_g=R/flue_gas_molar_mass;
T4= fzero(@(T4) TG_fT4(p3,p4,T3,T4,eta_piT,x_O2_massic,R_g,lambda,m_a1,frac_CO2,frac_H2O,frac_O2,frac_N2),700); %pg 121

%Etat3%
h3=h2+integral(@(t) janaf('c','CO2',t)*frac_CO2+janaf('c','H2O',t)*frac_H2O+janaf('c','N2',t)*frac_N2+janaf('c','O2',t)*frac_O2,T2,T3);
s3=s2+integral(@(t) (janaf('c','CO2',t)*frac_CO2+janaf('c','H2O',t)*frac_H2O+janaf('c','N2',t)*frac_N2+janaf('c','O2',t)*frac_O2)./t,T2,T3)-R_g*log(p3/p2)/1000;

%Etat4%
h4=h3+integral(@(t) janaf('c','CO2',t)*frac_CO2+janaf('c','H2O',t)*frac_H2O+janaf('c','N2',t)*frac_N2+janaf('c','O2',t)*frac_O2,T3,T4);
s4=s3-(1-eta_piT)/eta_piT*integral(@(t) (janaf('c','CO2',t)*frac_CO2+janaf('c','H2O',t)*frac_H2O+janaf('c','N2',t)*frac_N2+janaf('c','O2',t)*frac_O2)./t,T3,T4);

%Débits%
    syms ma mc
    [m_a, m_c] = vpasolve([lambda*m_a1 == ma/mc,... eq 3.7
        P_e == (ma+mc)*(h3-h4)*(1-k_mec)... 
        -  ma*(h2-h1)*(1+k_mec)... %Eq 3.1
        ],[ma, mc]);
    
    m_g=m_a+m_c;

%%%%%%%%%%%%%%%%%%%%%%%
%Calculs de puissances%
%%%%%%%%%%%%%%%%%%%%%%%

W_mT=h3-h4;
P_mT=m_g*W_mT;

W_mC=h2-h1;
P_mC=m_a*W_mC;

W_m=(1+1/m_a1/lambda)*W_mT-W_mC;

P_fmec=k_mec*(P_mT+P_mC);%=P_e-P_m
P_m=P_e+P_fmec;

%%%%%%%%%%%%%%%%%%%%%%%%%
%Rendements énergétiques%
%%%%%%%%%%%%%%%%%%%%%%%%%

eta_cyclen=P_e/(m_c*PCI_massique);
eta_mec=P_e/P_m;
eta_toten=eta_cyclen*eta_mec;

%%%%%%%%%%%%%%%%%%%%%%%%%
%Rendements exergétiques%
%%%%%%%%%%%%%%%%%%%%%%%%%

h0=h1;
s0=s1;
e1=h1-h0-T_ref*(s1-s0);
e2=h2-h0-T_ref*(s2-s0);
e3=h3-h0-T_ref*(s3-s0);
e4=h4-h0-T_ref*(s4-s0);

eta_totex=P_e/(m_c*ec);
eta_rotex=(m_g*(h3-h4)-m_a*(h2-h1))/(m_g*(e3-e4)-m_a*(e2-e1));
eta_cyclex=(m_g*(e3-e4)-m_a*(e2-e1))/(m_g*e3-m_a*e2);
eta_combex=(m_g*e3-m_a*e2)/(m_c*ec);

A=[W_m eta_cyclen eta_toten eta_cyclex eta_totex];

%%%%%%%
%Plots%
%%%%%%%%%%%
%T-s & H-s%
%%%%%%%%%%%
length=10;
T_12=linspace(T1,T2,length);
T_23=linspace(T2,T3,length);
T_34=linspace(T3,T4,length);
T_41=linspace(T4,T1,length);

p_23=linspace(p2,p3,length);

s_12=zeros(1,length);
s_23=zeros(1,length);
s_34=zeros(1,length);
s_41=zeros(1,length);

h_12=zeros(1,length);
h_23=zeros(1,length);
h_34=zeros(1,length);
h_41=zeros(1,length);

%Compresseur:
h_300=(x_O2_massic*janaf('c','O2',300)+(1-x_O2_massic)*janaf('c','N2',300))*(300-T1);
s_300=integral(@(t) (x_O2_massic*janaf('c','O2',300)+(1-x_O2_massic)*janaf('c','N2',300))./t,T1,300);
for i= 1:length
    if T_12(i)<300
        h_12(i)=h1+(x_O2_massic*janaf('c','O2',300)+(1-x_O2_massic)*janaf('c','N2',300))*(T_12(i)-T1);
        s_12(i)=s1+integral(@(t) (x_O2_massic*janaf('c','O2',300)+(1-x_O2_massic)*janaf('c','N2',300))./t,T1,T_12(i));
    else
        h_12(i)=h1+h_300+integral(@(t) x_O2_massic*janaf('c','O2',t)+(1-x_O2_massic)*janaf('c','N2',t),300,T_12(i));
        s_12(i)=s1+(1-eta_piC)*(s_300+integral(@(t) (x_O2_massic*janaf('c','O2',t)+(1-x_O2_massic)*janaf('c','N2',t))./t,300,T_12(i)));
    end
end

%Combustion:
for i= 1:length
    h_23(i)=h2+integral(@(t) janaf('c','CO2',t)*frac_CO2+janaf('c','H2O',t)*frac_H2O+janaf('c','N2',t)*frac_N2+janaf('c','O2',t)*frac_O2,T2,T_23(i));
s_23(i)=s2+integral(@(t) (janaf('c','CO2',t)*frac_CO2+janaf('c','H2O',t)*frac_H2O+janaf('c','N2',t)*frac_N2+janaf('c','O2',t)*frac_O2)./t,T2,T_23(i))-R_g*log(p_23(i)/p2)/1000;
end

%Turbine:
for i= 1:length
    h_34(i)=h3+integral(@(t) janaf('c','CO2',t)*frac_CO2+janaf('c','H2O',t)*frac_H2O+janaf('c','N2',t)*frac_N2+janaf('c','O2',t)*frac_O2,T3,T_34(i));
s_34(i)=s3-(1-eta_piT)/eta_piT*integral(@(t) (janaf('c','CO2',t)*frac_CO2+janaf('c','H2O',t)*frac_H2O+janaf('c','N2',t)*frac_N2+janaf('c','O2',t)*frac_O2)./t,T3,T_34(i));
end

%Transformation virtuelle 4->1
ds=(s4+integral(@(t) (janaf('c','CO2',t)*frac_CO2+janaf('c','H2O',t)*frac_H2O+janaf('c','N2',t)*frac_N2+janaf('c','O2',t)*frac_O2)./t,T4,300)+integral(@(t) (janaf('c','CO2',300)*frac_CO2+janaf('c','H2O',300)*frac_H2O+janaf('c','N2',300)*frac_N2+janaf('c','O2',300)*frac_O2)./t,300,T1))-s1;%Terme de correction pour la dilution
dh=(h4+integral(@(t) (janaf('c','CO2',t)*frac_CO2+janaf('c','H2O',t)*frac_H2O+janaf('c','N2',t)*frac_N2+janaf('c','O2',t)*frac_O2),T4,300)+(janaf('c','CO2',300)*frac_CO2+janaf('c','H2O',300)*frac_H2O+janaf('c','N2',300)*frac_N2+janaf('c','O2',300)*frac_O2))*(300-T1)-h1;

for i= 1:length
        if T_41(i)<300
            h_41(i)=(h4+integral(@(t) (janaf('c','CO2',t)*frac_CO2+janaf('c','H2O',t)*frac_H2O+janaf('c','N2',t)*frac_N2+janaf('c','O2',t)*frac_O2),T4,300)+(janaf('c','CO2',300)*frac_CO2+janaf('c','H2O',300)*frac_H2O+janaf('c','N2',300)*frac_N2+janaf('c','O2',300)*frac_O2))*(300-T_41(i))-dh*(i-1)/(length-1);
            s_41(i)=(s4+integral(@(t) (janaf('c','CO2',t)*frac_CO2+janaf('c','H2O',t)*frac_H2O+janaf('c','N2',t)*frac_N2+janaf('c','O2',t)*frac_O2)./t,T4,300)+integral(@(t) (janaf('c','CO2',300)*frac_CO2+janaf('c','H2O',300)*frac_H2O+janaf('c','N2',300)*frac_N2+janaf('c','O2',300)*frac_O2)./t,300,T_41(i)))-ds*(i-1)/(length-1);
        else
            h_41(i)=h4+integral(@(t) (janaf('c','CO2',t)*frac_CO2+janaf('c','H2O',t)*frac_H2O+janaf('c','N2',t)*frac_N2+janaf('c','O2',t)*frac_O2),T4,T_41(i));
            s_41(i)=s4+integral(@(t) (janaf('c','CO2',t)*frac_CO2+janaf('c','H2O',t)*frac_H2O+janaf('c','N2',t)*frac_N2+janaf('c','O2',t)*frac_O2)./t,T4,T_41(i))-ds*(i-1)/(length-1);
        end
        %s_41(i)=(m_a*(x_O2*(janaf('s','O2',T_41(i)+R/32*log(p_41/p4)))+(1-x_O2)*janaf('s','N2',T_41(i)+R/14*log(p_41/p4))) + m_c*get_methane('s',T_41(i),p_41))/m_g;
    
end
figure
plot(s_12,h_12,'blue')
hold on;
plot(s_23,h_23,'blue')
plot(s_34,h_34,'blue')
plot(s_41,h_41,'--blue')
text(s1,h1,'\leftarrowEtat 1')
text(s2,h2,'\leftarrowEtat 2')
text(s3,h3,'\leftarrowEtat 3')
text(s4,h4,'\leftarrowEtat 4')
title('Graphe h-s')
xlabel('Entropie [J/kgK]')
ylabel('Enthalpie [kJ/kg]')

figure
plot(s_12,T_12,'blue')
hold on;
plot(s_23,T_23,'blue')
plot(s_34,T_34,'blue')
plot(s_41,T_41,'--blue')
text(s1,T1,'\leftarrowEtat 1')
text(s2,T2,'\leftarrowEtat 2')
text(s3,T3,'\leftarrowEtat 3')
text(s4,T4,'\leftarrowEtat 4')
title('Graphe T-s')
xlabel('Entropie [J/kgK]')
ylabel('Température [K]')
%%%%%%%%%%%%%%%
%Tableau des résulats%
%%%%%%%%%%%%%%%

p=[p1;p2;p3;p4];
T=[T1;T2;T3;T4];
h=[h1;h2;h3;h4];
s=[s1;s2;s3;s4];
Etats={'1';'2';'3';'4'};

Table = table(p,T,h,s,'RowNames',Etats)

%%%%%%%%%%%%
%Pie Chart%
%%%%%%%%%%%%

%Energetique%

P_prim_en=m_c*PCI_massique;
P_echap_en = (h4-e1)*m_g;
P=[double(P_e) double(P_fmec) double(P_echap_en)];

label={sprintf('Puissance effective \n %0.1f MW ',P_e/1e3)...
    sprintf('Pertes mécaniques \n %0.1f MW ',P_fmec/1e3)...
    sprintf('Pertes à l''échappement: \n %0.1f MW ',P_echap_en/1e3)};
figure;
pie(P,label);
title(sprintf('Distribution du flux énergétique avec puissance primaire de %0.1f  MW',P_prim_en/1e3 ));

%Exergetique%
P_prim_ex=ec*m_c;
P_irr_comb = P_prim_ex*(1-eta_combex);
P_echap = (e4-e1)*m_g;
P_irr_tc = (e3-e4)*m_g - (e2-e1)*m_a- (h3-h4)*m_g + (h2-h1)*m_a;
P=[double(P_e) double(P_fmec) double(P_irr_tc) double(P_echap) double(P_irr_comb)];

label={sprintf('Puissance effective \n %0.1f MW ',P_e/1e3)...
    sprintf('Pertes mécaniques \n %0.1f MW ',P_fmec/1e3)...
    sprintf('Irréversibilités à la turbine et au compresseur \n %0.1f MW ',P_irr_tc/1e3)...
    sprintf('Pertes à l''échappement: \n %0.1f MW ',P_echap/1e3)...
    sprintf('Irréversibilités de la combustion: \n %0.1f MW ',P_irr_comb/1e3)};

figure;
pie(P,label);
title(sprintf('Distribution du flux exergétique avec puissance primaire de %0.1f  MW',P_prim_ex/1e3 ));

end