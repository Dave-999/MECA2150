function [] = TV()
%main function

%%

%%%%%%%%%%%%%%%%%%%%%%%%%
% Donnees et hypotheses %
%%%%%%%%%%%%%%%%%%%%%%%%%

P_e = 35*10^3; %puissance effective [kW]

t3 = 525; %[°C] (525)
p3 = 200; %[bar] (200)
t_c = 15; %[°C]
deltaT = 10; % (10)
t4 = t_c + deltaT; %[°C]
eta_si_T = 0.88;
eta_si_C = 0.88; 
eta_mec = 0.98;

lambda = 1.05;
fuel = 'CH4';
t_ech = 120; %temperature des fumees a l'echappement [°C]
t_a = 15; %tempreature de l'air ambiant [°C]
p_calo = 0.01; %pertes calorifiques

t0 = 15; %temperature de reference [°C]
p0 = 1; %pression de reference [bar]
h0 = XSteam('h_pt',p0,t0);
s0 = XSteam('s_pt',p0,t0);

%%

%%%%%%%%%%%%%%%%%%%%
% Calcul des etats %
%%%%%%%%%%%%%%%%%%%%

%etat 3
x3 = NaN;
h3 = XSteam('h_pt',p3,t3); %[kJ/kg]
s3 = XSteam('s_pt',p3,t3); %[kJ/kg.°C]
e3 = (h3-h0) - (t0+273.15)*(s3-s0);

%etat 4
p4 = XSteam('psat_T',t4); %[bar]
[x4,h4,s4] = Etat_detente(h3,s3,p4,eta_si_T);
e4 = (h4-h0) - (t0+273.15)*(s4-s0);

%etat 1
p1 = p4; %refroidissement isobare
t1 = t4; %car isobare
x1 = 0; %etat 1 sur la courbe x=0
h1 = XSteam('h_px',p1,x1);
s1 = XSteam('s_ph',p1,h1);
e1 = (h1-h0) - (t0+273.15)*(s1-s0);

%etat 2
p2 = p3; %apport de chaleur isobare
[t2,h2,s2] = Etat_compression(h1,s1,p2,eta_si_C);
x2 = NaN;
e2 = (h2-h0) - (t0+273.15)*(s2-s0);

%%

%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculs des rendements %
%%%%%%%%%%%%%%%%%%%%%%%%%%

%Point de vue energetique

eta_cyclen = ((h3-h4)-(h2-h1))/(h3-h2)

[PCI_massique, e_c, m_a1, frac_CO2, frac_H2O, frac_O2, frac_N2] = Combustion(fuel,lambda);

% c_pf = Cpf_m(0, t_ech, frac_CO2, frac_H2O, frac_O2, frac_N2);
% c_pa = Cpa_m(0, t_a, frac_O2, frac_N2);
% p_ech = ((lambda*m_a1+1)*c_pf*t_ech - lambda*m_a1*c_pa*t_a)/PCI_massique;
h_f = frac_CO2*Enthalpie(0, t_ech, 'CO2') + frac_H2O*Enthalpie(0, t_ech, 'H2O')...
       + frac_O2*Enthalpie(0, t_ech, 'O2') + frac_N2*Enthalpie(0, t_ech, 'N2');
h_a = frac_O2*Enthalpie(0, t_a, 'O2') + frac_N2*Enthalpie(0, t_a, 'N2');
p_ech = ((lambda*m_a1+1)*h_f - lambda*m_a1*h_a)/PCI_massique;

eta_gen = 1 - p_calo - p_ech

eta_toten = eta_gen*eta_cyclen*eta_mec

m_v = P_e/eta_mec/((h3-h4)-(h2-h1)) %debit de vapeur [kg/s]

m_c = P_e/eta_toten/PCI_massique %debit de combustible [kg/s]

P_prim = m_c*PCI_massique;
p_gen = P_prim*(1-eta_gen);
p_cond = m_v*(h3-h2)*(1-eta_cyclen);
p_mec = m_v*((h3-h4)-(h2-h1))*(1-eta_mec);

data = [P_e p_gen p_cond p_mec];

%Point de vue exergetique



%%

%%%%%%%%%%%%%%%%%
% Tableau etats %
%%%%%%%%%%%%%%%%%

p = [p1;p2;p3;p4];
t = [t1;t2;t3;t4];
x = [x1;x2;x3;x4];
h = [h1;h2;h3;h4];
s = [s1;s2;s3;s4];
e = [e1;e2;e3;e4];
Etats = {'1';'2';'3';'4'};
Table = table(p,t,x,h,s,e,'RowNames',Etats)
 
%%

%%%%%%%%%%%%%
% Pie Chart %
%%%%%%%%%%%%%

label = {sprintf('Puissance effective \n %1.1f MW ',data(1)/1e3)...
         sprintf('Pertes au générateur de vapeur \n %1.1f MW ',p_gen/1e3)...
         sprintf('Pertes au condenseur \n %1.1f MW ',p_cond/1e3)...
         sprintf('Pertes mécaniques \n %1.1f MW ',p_mec/1e3)};

figure;
pie(data,label);
titre = title(sprintf('Flux énergétique primaire %1.1f MW',P_prim/1e3));
pos = get(titre,'position');
set(titre,'position',pos+[0 0.08 0]);

%% 

%%%%%%%%%%%%%%%%%%%%%%
% Graphes T-s et h-s %
%%%%%%%%%%%%%%%%%%%%%%

%plot (T,s)
%DiagTS([s1,T1],[s2,T2],[s3,T3],[s4,T4]);

% length=10;
% T_12=linspace(T1,T2,length);
% T_23=linspace(T2,T3,length);
% T_34=linspace(T3,T4,length);
% T_41=linspace(T4,T1,length);
% 
% s_12=zeros(1,length);
% s_23=zeros(1,length);
% s_34=zeros(1,length);
% s_41=zeros(1,length);
% 
% h_12=zeros(1,length);
% h_23=zeros(1,length);
% h_34=zeros(1,length);
% h_41=zeros(1,length);

end