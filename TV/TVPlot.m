function [] = TVPlot()

    P_e = 288*10^3; %puissance effective  /!\ [kW] /!\
    
    
    n_resurch = 1; %nombre de resurchauffe 
    t3 = 525; %temperature de vapeur vive apres le generateur de vapeur [°C]
    p3 = 200; %pression de vapeur vive apres le generateur de vapeur [bar]
    rapport_HP = 0.15; %rapport de détente dans le corps HP 
    t_sf = 15; %temperature source froide (riviere) [°C]
    dT_cond = 10; %ecart de temperature entre le condenseur et la riviere
    eta_siT = 0.88; %rendement isentropique turbine
    eta_siP = 0.88; %rendement isentropique pompe
    eta_mec = 0.98; %rendement mecanique
    lambda = 1.05; %coefficient d'exces d'air
    fuel_number = 1; %combustible
    t_ech = 120; %temperature des fumees a l'echappement [°C]
    t_a = 15; %temperature de l'air ambiant [°C]
    p_calo = 0.01; %perte par déperditions calorifiques = 1% du PCI
    dT_prechauf = 0; %pas de prechauffe du combustible et de l'air
    
    %tour de refroidissement
    phi_air_in = 0.8; %humidite relative de l'air a l'entree de la tour
    t_air_in = 15; %temperature de l'air a l'entree de la tour
    
figure;
n_max=15;
length=n_max+1
n_sout=linspace(0,n_max,length)
eta_cyclen=zeros(1,length);

for i=1:length
    eta_cyclen(i)=TV(P_e, fuel_number, n_sout(i), n_resurch, t3, p3, rapport_HP, t_sf, dT_cond, eta_siT, eta_siP, eta_mec, lambda, t_ech, t_a, p_calo, dT_prechauf, phi_air_in, t_air_in);
end

plot(n_sout,eta_cyclen)
title('Rendement énergétique du cycle en fonction du nombre de soutirages')
xlabel('nb_{sout} [/]')
ylabel('eta_{cyclen} [/]')
% MaximumsWm(1)=max(TGWm(1,:))
% j1Wm=1
% while TGWm(1,j1Wm)<MaximumsWm(1)
%    j1Wm=j1Wm+1;
% end
% 
% Maximumsetacyclen(1)=max(TGetacyclen(1,:))
% j1etacyclen=1
% while TGetacyclen(1,j1etacyclen)<Maximumsetacyclen(1)
%    j1etacyclen=j1etacyclen+1;
% end
% 
% Maximumsetatoten(1)=max(TGetatoten(1,:))
% j1etatoten=1
% while TGetatoten(1,j1etatoten)<Maximumsetatoten(1)
%    j1etatoten=j1etatoten+1;
% end
% 
% Maximumsetacyclex(1)=max(TGetacyclex(1,:))
% j1etacyclex=1
% while TGetacyclex(1,j1etacyclex)<Maximumsetacyclex(1)
%    j1etacyclex=j1etacyclex+1;
% end
% 
% Maximumsetatotex(1)=max(TGetatotex(1,:))
% j1etatotex=1
% while TGetatotex(1,j1etatotex)<Maximumsetatotex(1)
%    j1etatotex=j1etatotex+1;
% end
% 
% 
% 
% 
% T3=1200;
% for i=1:length
%      A=TG(230,1,0.9,0.9,0.015,T3,0.95,r(i));
%      TGWm(2,i)=A(1,1);
%      TGetacyclen(2,i)=A(1,2);
%     TGetatoten(2,i)=A(3);
%     TGetacyclex(2,i)=A(4);
%     TGetatotex(2,i)=A(5);
% end
% MaximumsWm(2)=max(TGWm(2,:))
% j2Wm=1
% while TGWm(2,j2Wm)<MaximumsWm(2)
%    j2Wm=j2Wm+1;
% end
% 
% Maximumsetacyclen(2)=max(TGetacyclen(2,:))
% j2etacyclen=1
% while TGetacyclen(2,j2etacyclen)<Maximumsetacyclen(2)
%    j2etacyclen=j2etacyclen+1;
% end
% 
% Maximumsetatoten(2)=max(TGetatoten(2,:))
% j2etatoten=1
% while TGetatoten(2,j2etatoten)<Maximumsetatoten(2)
%    j2etatoten=j2etatoten+1;
% end
% 
% Maximumsetacyclex(2)=max(TGetacyclex(2,:))
% j2etacyclex=1
% while TGetacyclex(2,j2etacyclex)<Maximumsetacyclex(2)
%    j2etacyclex=j2etacyclex+1;
% end
% 
% Maximumsetatotex(2)=max(TGetatotex(2,:))
% j2etatotex=1
% while TGetatotex(2,j2etatotex)<Maximumsetatotex(2)
%    j2etatotex=j2etatotex+1;
% end
% 
% 
% 
% 
% T3=1400;
% for i=1:length
%      A=TG(230,1,0.9,0.9,0.015,T3,0.95,r(i));
%      TGWm(3,i)=A(1,1);
%      TGetacyclen(3,i)=A(1,2);
%      TGetatoten(3,i)=A(1,3);
%      TGetacyclex(3,i)=A(1,4);
%      TGetatotex(3,i)=A(1,5);
% end
% MaximumsWm(3)=max(TGWm(3,:))
% j3Wm=1
% while TGWm(3,j3Wm)<MaximumsWm(3)
%    j3Wm=j3Wm+1;
% end
% 
% Maximumsetacyclen(3)=max(TGetacyclen(3,:))
% j3etacyclen=1
% while TGetacyclen(3,j3etacyclen)<Maximumsetacyclen(3)
%    j3etacyclen=j3etacyclen+1;
% end
% 
% Maximumsetatoten(3)=max(TGetatoten(3,:))
% j3etatoten=1
% while TGetatoten(3,j3etatoten)<Maximumsetatoten(3)
%    j3etatoten=j3etatoten+1;
% end
% 
% Maximumsetacyclex(3)=max(TGetacyclex(3,:))
% j3etacyclex=1
% while TGetacyclex(3,j3etacyclex)<Maximumsetacyclex(3)
%    j3etacyclex=j3etacyclex+1;
% end
% 
% Maximumsetatotex(3)=max(TGetatotex(3,:))
% j3etatotex=1
% while TGetatotex(3,j3etatotex)<Maximumsetatotex(3)
%    j3etatotex=j3etatotex+1;
% end
% 
% 
% T3=1600;
% for i=1:length
%      A=TG(230,1,0.9,0.9,0.015,T3,0.95,r(i));
%      TGWm(4,i)=A(1,1)
%      TGetacyclen(4,i)=A(1,2);
%      TGetatoten(4,i)=A(1,3);
%      TGetacyclex(4,i)=A(1,4);
%      TGetatotex(4,i)=A(1,5);
% end
% MaximumsWm(4)=max(TGWm(4,:));
% j4Wm=1;
% while TGWm(4,j4Wm)<MaximumsWm(4)
% TGWm(j4Wm)
%    j4Wm=j4Wm+1
% end
% 
% Maximumsetacyclen(4)=max(TGetacyclen(4,:));
% j4etacyclen=1;
% while TGetacyclen(4,j4etacyclen)<Maximumsetacyclen(4)
% Maximumsetacyclen(4)
%    j4etacyclen=j4etacyclen+1;
% end
% 
% Maximumsetatoten(4)=max(TGetatoten(4,:))
% j4etatoten=1
% while TGetatoten(4,j4etatoten)<Maximumsetatoten(4)
%    j4etatoten=j4etatoten+1;
% end
% 
% Maximumsetacyclex(4)=max(TGetacyclex(4,:))
% j4etacyclex=1
% while TGetacyclex(4,j4etacyclex)<Maximumsetacyclex(4)
%    j4etacyclex=j4etacyclex+1;
% end
% 
% Maximumsetatotex(4)=max(TGetatotex(4,:))
% j4etatotex=1
% while TGetatotex(4,j4etatotex)<Maximumsetatotex(4)
%    j4etatotex=j4etatotex+1;
% end
% 
% 
% 
% figure
% 
% plot(r,TGWm)
% hold on
% plot(r(j4Wm),MaximumsWm(4),'o','MarkerSize',10)
% plot(r(j3Wm),MaximumsWm(3),'o','MarkerSize',10)
% plot(r(j2Wm),MaximumsWm(2),'o','MarkerSize',10)
% plot(r(j1Wm),MaximumsWm(1),'o','MarkerSize',10)
% 
% legend('t3=1000°C','t3=1200°C','t3=1400°C','t3=1600°C')
% title('Travail moteur selon T3 et r')
% xlabel('r [/]')
% ylabel('W_m [kJ/kg]')
% 
% figure
% 
% plot(r,TGetacyclen)
% hold on
% plot(r(j4etacyclen),Maximumsetacyclen(4),'o','MarkerSize',10)
% plot(r(j3etacyclen),Maximumsetacyclen(3),'o','MarkerSize',10)
% plot(r(j2etacyclen),Maximumsetacyclen(2),'o','MarkerSize',10)
% plot(r(j1etacyclen),Maximumsetacyclen(1),'o','MarkerSize',10)
% 
% legend('t3=1000°C','t3=1200°C','t3=1400°C','t3=1600°C')
% 
% title('Rendement énergétique du cycle selon T3 et r')
% xlabel('r [/]')
% ylabel('eta_{cyclen} [/]')
% 
% figure
% plot(r,TGetatoten)
% hold on
% plot(r(j4etatoten),Maximumsetatoten(4),'o','MarkerSize',10)
% plot(r(j3etatoten),Maximumsetatoten(3),'o','MarkerSize',10)
% plot(r(j2etatoten),Maximumsetatoten(2),'o','MarkerSize',10)
% plot(r(j1etatoten),Maximumsetatoten(1),'o','MarkerSize',10)
% 
% legend('t3=1000°C','t3=1200°C','t3=1400°C','t3=1600°C')
% 
% title('Rendement énergétique total selon T3 et r')
% xlabel('r [/]')
% ylabel('eta_{toten} [/]')
% 
% figure
% plot(r,TGetacyclex)
% hold on
% plot(r(j4etacyclex),Maximumsetacyclex(4),'o','MarkerSize',10)
% plot(r(j3etacyclex),Maximumsetacyclex(3),'o','MarkerSize',10)
% plot(r(j2etacyclex),Maximumsetacyclex(2),'o','MarkerSize',10)
% plot(r(j1etacyclex),Maximumsetacyclex(1),'o','MarkerSize',10)
% 
% legend('t3=1000°C','t3=1200°C','t3=1400°C','t3=1600°C')
% 
% title('Rendement exergétique du cycle selon T3 et r')
% xlabel('r [/]')
% ylabel('eta_{cyclex} [/]')
% 
% figure
% plot(r,TGetatotex)
% hold on
% plot(r(j4etatotex),Maximumsetatotex(4),'o','MarkerSize',10)
% plot(r(j3etatotex),Maximumsetatotex(3),'o','MarkerSize',10)
% plot(r(j2etatotex),Maximumsetatotex(2),'o','MarkerSize',10)
% plot(r(j1etatotex),Maximumsetatotex(1),'o','MarkerSize',10)
% 
% legend('t3=1000°C','t3=1200°C','t3=1400°C','t3=1600°C')
% 
% title('Rendement exergétique total selon T3 et r')
% xlabel('r [/]')
% ylabel('eta_{toten} [/]')
% 
% 
% figure
% plot(TGWm(1,:),TGetacyclen(1,:));
% hold on
% plot(TGWm(2,:),TGetacyclen(2,:));
% plot(TGWm(3,:),TGetacyclen(3,:));
% plot(TGWm(4,:),TGetacyclen(4,:));
% legend('t3=1000°C','t3=1200°C','t3=1400°C','t3=1600°C')
% title('Rendement énergétique du cycle selon le travail moteur')
% xlabel('W_m [kJ/Kg]')
% ylabel('eta_{cyclen} [/]')
% r_max_Wm=[r(j1Wm) r(j2Wm) r(j3Wm) r(j4Wm)]
% r_max_etacyclen=[r(j1etacyclen) r(j2etacyclen) r(j3etacyclen) r(j4etacyclen)]

end