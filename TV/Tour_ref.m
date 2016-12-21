function [m_eau,m_vap,m_air,x_air_in,x_air_out] = Tour_ref(etat6,etat7,m_vC,t_sf,t_sf_out,p_air,t_air_in,t_air_out,phi_air_in,phi_air_out)
%Simulation tour de refroidissement
%
% INPUT
% etat6 : etat 6 du cycle
% etat7 : etat 7 du cycle
% m_vC : debit au condenseur
% t_sf  : temperature de l'eau de refroidissement (riviere)
% t_sf_out : temperature de l'eau apres passage dans le condenseur
% p_air : pression de l'air de la tour de refroidissement
% t_air_in : temperature de l'air a l'entrée de la tour
% t_air_out : temperature de l'air a la sortie de la tour
% phi_air_in : humidite relative de l'air a l'entree de la tour
%  phi_air_out : humidite relative de l'air a la sortie de la tour
%
% OUTPUT
% m_eau : debit d'eau necessaire dans le circuit de refroidissement
% m_vap : debit d'eau qui s'evapore dans la tour de refroidissement
% m_air : debit d'air necessaire dans la tour de refroidissement
% x_air_in : humidité absolue de l'air a l'entree de la tour
% x_air_out : humidite absolue de l'air a la sortie de la tour


Cpa = 1.009; %[kJ/kgK]
Cpv = 1.854; %[kJ/kgK]
Cpl = 4.1868; %[kJ/kgK]
h_lv = 2501.6; %[kJ/kg]

x_air_in = 0.622*phi_air_in*XSteam('psat_T',t_air_in)/(p_air - phi_air_in*XSteam('psat_T',t_air_in));
x_air_out = 0.622*phi_air_out*XSteam('psat_T',t_air_out)/(p_air - phi_air_out*XSteam('psat_T',t_air_out));

h_air_in = Cpa*t_air_in + x_air_in*(h_lv + Cpv*t_air_in);
h_air_out = Cpa*t_air_in + x_air_out*(h_lv + Cpv*t_air_out);

m_eau = m_vC*(etat6.h-etat7.h)/Cpl/(t_sf_out - t_sf);
m_air  = m_eau*Cpl*(t_sf_out - t_sf)/(h_air_out - h_air_in);
m_vap = m_air*(x_air_out - x_air_in);

end