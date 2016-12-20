function [PCI_massique, e_c, m_a1, fracP_CO2, fracP_H2O, fracP_O2, fracP_N2, n_CO2, n_H2O, n_O2, n_N2, M, p_part_H2O] = TGCombustion(fuel,lambda)
% Reaction de combustion pour differents combustibles

% INPUT
% fuel = type de combustible
% lambda = coefficient d'exces d'air

% HYPOTHESES
% Air 21%O2 79%N2 a T ambiante
% Combustion complete avec exces d'air (coefficient lambda)
% CzHyOx + a1 O2 + a2 N2 = a3 CO2 + a4 H2O + a5 O2 + a6 N2
% a1 = lambda*(z+y/4-x/2)
% a2 = lambda*(z+y/4-x/2)*0.79/0.21
% a3 = z
% a4 = y/2
% a5 = (lambda-1)*(z+y/4-x/2)
% a6 = lambda*(z+y/4-x/2)*0.79/0.21


M_CO2 = 44; %masse molaire [kg/kmol]
M_H2O = 18; %masse molaire [kg/kmol]
M_O2 = 32; %masse molaire [kg/kmol]
M_N2 = 28; %masse molaire [kg/kmol]

x_molaire_O2 = 0.21;
x_massique_O2 = x_molaire_O2*32/(x_molaire_O2*32+(1-x_molaire_O2)*28);


if nargin == 0  
    fuel = 'CH4';
    lambda = 1.05;
end

if strcmp(fuel,'C')
    
    z = 1;
    y = 0;
    x = 0;
    M = z*12 + y*1 + x*16; %masse molaire du combustible [kg/kmol]
    PCI_massique = 32780; %PCI du combustible [kJ/kg]
    e_c = 34160; %exergie du combustible [kJ/kg]
    Cp = 10.4/M; %capacite calorifique moyenne (273K-288K) du combustible [kJ/kgK]

elseif strcmp(fuel,'CH1.8')
    
    z = 1;
    y = 1.8;
    x = 0;
    M = z*12 + y*1 + x*16; %masse molaire du combustible [kg/kmol]
    PCI_massique = 42900; %PCI [kJ/kg]
    e_c = 45710; %exergie combustible [kJ/kg]
    Cp = 14.4/M; %capacite calorifique moyenne (273K-288K) du combustible [kJ/kgK]
    
elseif strcmp(fuel,'CH4')
    
    z = 1;
    y = 4;
    x = 0;
    M = z*12 + y*1 + x*16; %masse molaire du combustible [kg/kmol]
    PCI_massique = 50150; %PCI [kJ/kg]
    e_c = 52215; %exergie combustible [kJ/kg]
    Cp = 35.3/M; %capacite calorifique moyenne (273K-288K) du combustible [kJ/kgK]
    
elseif strcmp(fuel,'C3H8')
    
    z = 3;
    y = 8;
    x = 0;
    M = z*12 + y*1 + x*16; %masse molaire du combustible [kg/kmol]
    PCI_massique = 46465; %PCI [kJ/kg]
    e_c = 49045; %exergie combustible [kJ/kg]
    Cp = 70.9/M; %capacite calorifique moyenne (273K-288K) du combustible [kJ/kgK]
        
elseif strcmp(fuel,'H2')
    
    z = 0;
    y = 2;
    x = 0;
    M = z*12 + y*1 + x*16; %masse molaire du combustible [kg/kmol]
    PCI_massique = 120900; %PCI [kJ/kg]
    e_c = 118790; %exergie combustible [kJ/kg]
    Cp = 28.7/M; %capacite calorifique moyenne (273K-288K) du combustible [kJ/kgK]
            
elseif strcmp(fuel,'CO')
    
    z = 1;
    y = 0;
    x = 1;
    M = z*12 + y*1 + x*16; %masse molaire du combustible [kg/kmol]
    PCI_massique = 10085; %PCI [kJ/kg]
    e_c = 9845; %exergie combustible [kJ/kg]
    Cp = 29.1/M; %capacite calorifique moyenne (273K-288K) du combustible [kJ/kgK]
    
elseif strcmp(fuel,'C12H23')
    
    z = 12;
    y = 23;
    x = 0;
    M = z*12 + y*1 + x*16; %masse molaire du combustible [kg/kmol]
    PCI_massique = 43400; %PCI [kJ/kg]
    e_c = 45800; %exergie combustible [kJ/kg]
    Cp = 1.75; %capacite calorifique moyenne (273K-288K) du combustible [kJ/kgK]
    
end

%CzHyOx + lambda*a1 O2 + lambda*a2 N2 = a3 CO2 + a4 H2O + a5 O2 + a6 N2
a1 = (z+y/4-x/2);
a2 = a1*(1-x_molaire_O2)/x_molaire_O2;
a3 = z;
a4 = y/2;
a5 = (lambda-1)*a1;
a6 = lambda*a2;

n_CO2=a3;
n_H2O=a4;
n_O2=a5;
n_N2=a6;

%Pouvoir comburivore massique (pour 1kg de combustible)
m_a1 = 1/M*a1*M_O2/x_massique_O2;

%Fractions massiques des reactifs
m_reactifs = 1*M + lambda*a1*M_O2 + lambda*a2*M_N2;
fracR_c = 1*M/m_reactifs;
fracR_O2 = lambda*a1*M_O2/m_reactifs;
fracR_N2 = lambda*a2*M_N2/m_reactifs;

%Fractions massiques des produits
m_produits = a3*M_CO2 + a4*M_H2O + a5*M_O2 + a6*M_N2;
fracP_CO2 = a3*M_CO2/m_produits;
fracP_H2O = a4*M_H2O/m_produits;
fracP_O2 = a5*M_O2/m_produits;
fracP_N2 = a6*M_N2/m_produits;

%Point de rosee
frac_mol_H2O = a4/(a3+a4+a5+a6); %fraction molaire de H2O
p_part_H2O = frac_mol_H2O*1e3; %pression partielle de H2O [Pa]

end