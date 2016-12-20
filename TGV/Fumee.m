function [hf] = Fumee(PCI_massique, e_c, Cp, m_a1, fracR_c, fracR_O2, fracR_N2, fracP_CO2, fracP_H2O, fracP_O2, fracP_N2, lambda, t_ech)
%Renvoie les caracteristiques des fumees pour calculer les rendements
%exergetiques

t0 = 15; %temperature de reference pour l'exergie [°C]
t_c = t0 + dT_prechauf; %temperature du combustible (avec préchauffage dT_prechauf)
h_c = Cp*(t_c - 0);
h_a = fracR_O2*Enthalpie(0, t_c, 'O2') + fracR_N2*Enthalpie(0, t_c, 'N2');
h_f = (PCI_massique + h_c + lambda*m_a1*h_a)/(lambda*m_a1 + 1); %definition p.31

% fun = (@(t_f) (Enthalpie_Fumee(0, t_f, fracP_CO2, fracP_H2O, fracP_O2, fracP_N2) - h_f)); 
% t_f = fzero(fun,2000); %temperature des fumees
% 
% m_f = (lambda*m_a1 + 1)*m_c;  %debit des fumees
% 
% e_f = Enthalpie_Fumee(t0, t_f, fracP_CO2, fracP_H2O, fracP_O2, fracP_N2)...
%       -(t0+273.15)*Entropie_Fumee(t0, t_f, fracP_CO2, fracP_H2O, fracP_O2, fracP_N2); %exergie des fumees
%   
% e_ech = Enthalpie_Fumee(t0, t_ech, fracP_CO2, fracP_H2O, fracP_O2, fracP_N2)...
%         -(t0+273.15)*Entropie_Fumee(t0, t_ech, fracP_CO2, fracP_H2O, fracP_O2, fracP_N2); %exergie des fumees a la cheminee
%     
% e_a = fracR_O2*Enthalpie(t0, t_c, 'O2') + fracR_N2*Enthalpie(t0, t_c, 'N2')...
%       -(t0+273.15)*(fracR_O2*Entropie(t0, t_c, 'O2') + fracR_N2*Entropie(t0, t_c, 'N2'));
%   
% e_cr = Cp*(t_c-t0) - (t0+273.15)*Cp*log((t_c+273.15)/(t0+273.15));
%   
% e_r = e_a*lambda*m_a1/(lambda*m_a1 + 1) + e_cr/(lambda*m_a1 + 1); %exergie des reactifs, = 0 si pas de de prechauffe
%   
end