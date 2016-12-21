function [] = GUI_2(cycle)
close all
%%%%%%%%%%%%%%%%
%Cycle à vapeur%
%%%%%%%%%%%%%%%%

if cycle==1
    fig = figure('units','normalized','outerposition',[0.33 0.2 0.33 0.8],'name','Interface de la simulation de turbine à vapeur')
    text1 = uicontrol( fig , 'style' , 'text' , 'position' , [125,670,340,30] ,...
        'string' , 'Turbine à vapeur' , 'fontsize' , 15 )
    text2 = uicontrol( fig , 'style' , 'text' , 'position' , [50,620,500,30] ,...
        'string' , 'Veuillez donner une valeur aux  paramètres' , 'fontsize' , 15 )
    
    text2bis = uicontrol( fig , 'style' , 'text' , 'position' , [35,150,500,30] ,...
        'string' , 'Tour de refroidissement' , 'fontsize' , 10 )
    
    text3 = uicontrol ( fig , 'style' , ' edit' , 'position', [170,540,50,15] , 'Max' , 1 , 'string' , '288' );
    ui3 = uicontrol ( fig , 'style' , ' text' , 'position', [10,540,150,15] , 'string' , 'Puissance effective' );
    unit3 = uicontrol ( fig , 'style' , ' text' , 'position', [230,540,30,15] , 'string' , '[MW]' );
    
    text4 = uicontrol ( gcf , 'Style' , 'popup' , 'String' , 'CH4|C12H23|C|CH1.8|C3H8|H2|CO' , 'Position' , [440 542 100 15] )
    ui4 = uicontrol ( fig , 'style' , ' text' , 'position', [280, 538 ,150,15] , 'string' , 'Carburant' )

    text5 = uicontrol ( fig , 'style' , ' edit' , 'position', [170,500,50,15] , 'Max' , 1 , 'string' , '8');
    ui5 = uicontrol ( fig , 'style' , ' text' , 'position', [10,475,150,45] , 'string' , 'Nombre de soutirages' );
    unit5 = uicontrol ( fig , 'style' , ' text' , 'position', [230,500,30,15] , 'string' , '[/]' );
    
    text6 = uicontrol ( fig , 'style' , ' edit' , 'position', [440,500,50,15] , 'Max' , 1 , 'string' , '1' )
    ui6 = uicontrol ( fig , 'style' , ' text' , 'position', [280,492,150,30] , 'string' , 'Nombre de resurchauffes (0 ou 1)' )
    unit6 = uicontrol ( fig , 'style' , ' text' , 'position', [500,500,30,15] , 'string' , '[/]' )
    
    text7 = uicontrol ( fig , 'style' , ' edit' , 'position', [170,447,50,20] , 'Max' , 1 , 'string' , '0.88' );
    ui7 = uicontrol ( fig , 'style' , ' text' , 'position', [10,442,150,30] , 'string' , 'Rendement isentropique des turbines(eta_siT)' );
    unit7 = uicontrol ( fig , 'style' , ' text' , 'position', [230,450,30,15] , 'string' , '[/]' );
    
    text8 = uicontrol ( fig , 'style' , ' edit' , 'position', [440,447,50,20] , 'Max' , 1 , 'string' , '0.88' );
    ui8 = uicontrol ( fig , 'style' , ' text' , 'position', [280,442 ,150,30] , 'string' , 'Rendement isentropique de la pompe (eta_siP)' );
    unit8 = uicontrol ( fig , 'style' , ' text' , 'position', [500,450,30,15] , 'string' , '[/]' );
    
    text9 = uicontrol ( fig , 'style' , ' edit' , 'position', [170,408,50,15] , 'Max' , 1 , 'string' , '0.98' );
    ui9 = uicontrol ( fig , 'style' , ' text' , 'position', [10,400,150,30] , 'string' , 'Rendement mécanique (eta_mec)' );
    unit9 = uicontrol ( fig , 'style' , ' text' , 'position', [230,408,30,15] , 'string' , '[/]' );
    
    text10 = uicontrol ( fig , 'style' , ' edit' , 'position', [440,408,50,15] , 'Max' , 1 , 'string' , '1.05' );
    ui10 = uicontrol ( fig , 'style' , ' text' , 'position', [280,400,150,30] , 'string' , 'Excès d''air (lambda)' )
    unit10 = uicontrol ( fig , 'style' , ' text' , 'position', [500,408,30,15] , 'string' , '[/]' );
    
    
    
    
    
    
    text11 = uicontrol ( fig , 'style' , ' edit' , 'position', [170,368,50,15] , 'Max' , 1 , 'string' , '525' );
    ui11 = uicontrol ( fig , 'style' , ' text' , 'position', [10,360,150,30] , 'string' , 'Température de vapeur après le générateur de vapeur (t3)' );
    unit11 = uicontrol ( fig , 'style' , ' text' , 'position', [230,368,30,15] , 'string' , '[°C]' );
    
    text12 = uicontrol ( fig , 'style' , ' edit' , 'position', [440,368,50,15] , 'Max' , 1 , 'string' , '200' );
    ui12 = uicontrol ( fig , 'style' , ' text' , 'position', [280,360,150,30] , 'string' , 'Pression de vapeur après le générateur de vapeur (p3)');
unit12 = uicontrol ( fig , 'style' , ' text' , 'position', [500,368,30,15] , 'string' , '[bar]' );

    text13 = uicontrol ( fig , 'style' , ' edit' , 'position', [170,328,50,15] , 'Max' , 1 , 'string' , '0.15');
    ui13 = uicontrol ( fig , 'style' , ' text' , 'position', [10,300,150,45] , 'string' , 'Rapport de détente dans le corps HP' );
    unit13 = uicontrol ( fig , 'style' , ' text' , 'position', [230,328,30,15] , 'string' , '[/]' );
    
    text14= uicontrol ( fig , 'style' , ' edit' , 'position', [440,328,50,15] , 'Max' , 1 , 'string' , '15' )
    ui14 = uicontrol ( fig , 'style' , ' text' , 'position', [280,320,150,30] , 'string' , 'Température de la source froide (rivière) (t_sf)' )
    unit14 = uicontrol ( fig , 'style' , ' text' , 'position', [500,328,30,15] , 'string' , '[°C]' )
    
    text15 = uicontrol ( fig , 'style' , ' edit' , 'position', [170,288,50,20] , 'Max' , 1 , 'string' , '10' );
    ui15 = uicontrol ( fig , 'style' , ' text' , 'position', [10,282,150,30] , 'string' , 'Ecart de température entre le condenseur et la rivière (dT_cond)' );
    unit15 = uicontrol ( fig , 'style' , ' text' , 'position', [230,300,30,15] , 'string' , '[/]' );
    
    text16 = uicontrol ( fig , 'style' , ' edit' , 'position', [440,288,50,20] , 'Max' , 1 , 'string' , '120' );
    ui16 = uicontrol ( fig , 'style' , ' text' , 'position', [280,278 ,150,30] , 'string' , 'Température des fumées à l''échappement' );
    unit16 = uicontrol ( fig , 'style' , ' text' , 'position', [500,290,30,15] , 'string' , '[°C]' );
    
    text17 = uicontrol ( fig , 'style' , ' edit' , 'position', [170,248,50,15] , 'Max' , 1 , 'string' , '15' );
    ui17 = uicontrol ( fig , 'style' , ' text' , 'position', [10,240,150,30] , 'string' , 'Température de l''air ambiant' );
    unit17 = uicontrol ( fig , 'style' , ' text' , 'position', [230,248,30,15] , 'string' , '[°C]' );
    
    text18 = uicontrol ( fig , 'style' , ' edit' , 'position', [440,248,50,15] , 'Max' , 1 , 'string' , '0.01' );
    ui18 = uicontrol ( fig , 'style' , ' text' , 'position', [280,240,150,30] , 'string' , 'Pertes par déperditions calorifiques (en fraction du PCI)' )
    unit18 = uicontrol ( fig , 'style' , ' text' , 'position', [500,248,30,15] , 'string' , '[%]' );
    
    text19 = uicontrol ( fig , 'style' , ' edit' , 'position', [170,208,50,15] , 'Max' , 1 , 'string' , '0' );
    ui19 = uicontrol ( fig , 'style' , ' text' , 'position', [10,200,150,30] , 'string' , 'Préchauffe du combustible et de l''air (dT_prechauf)' )
    unit19 = uicontrol ( fig , 'style' , ' text' , 'position', [230,208,30,15] , 'string' , '[°C]' );
    
    text20 = uicontrol ( fig , 'style' , ' edit' , 'position', [170,128,50,15] , 'Max' , 1 , 'string' , '25');
    ui20 = uicontrol ( fig , 'style' , ' text' , 'position', [10,103,150,45] , 'string' , 'Température de l''air à l''entrée de la tour' );
    unit20 = uicontrol ( fig , 'style' , ' text' , 'position', [230,128,30,15] , 'string' , '[°C]' );
    
    text21= uicontrol ( fig , 'style' , ' edit' , 'position', [440,128,50,15] , 'Max' , 1 , 'string' , '15' )
    ui21 = uicontrol ( fig , 'style' , ' text' , 'position', [280,116,150,30] , 'string' , 'Humidité relative de l''air à l''entrée de la tourHumidité relative de l''air à la sortie de la tour' )
    unit21 = uicontrol ( fig , 'style' , ' text' , 'position', [500,128,30,15] , 'string' , '[°C]' )

    
bp1 = uicontrol ( fig , 'style' , 'push' , 'position' , [420 10 60 30 ] ,...
        'string' , 'Démarrer' , 'callback' , @(bp1,eventdata) TV(str2double(get(text3,'String'))*1000,get(text4,'Value'), str2double(get(text5,'String')), str2double(get(text6,'String')), str2double(get(text11,'String')), str2double(get(text12,'String')), str2double(get(text13,'String')), str2double(get(text14,'String')), str2double(get(text15,'String')), str2double(get(text7,'String')), str2double(get(text8,'String')), str2double(get(text9,'String')), str2double(get(text10,'String')), str2double(get(text16,'String')), str2double(get(text17,'String')), str2double(get(text18,'String')), str2double(get(text19,'String')),  str2double(get(text21,'String')),  str2double(get(text20,'String'))))
end


%%%%%%%%%%%%%
%Cycle à gaz%
%%%%%%%%%%%%%

if cycle == 2
    fig = figure('name','Interface de la simulation de turbine à gaz')
      
    text1 = uicontrol( fig , 'style' , 'text' , 'position' , [200,350,170,30] ,...
        'string' , 'Turbine à gaz' , 'fontsize' , 15 )
   
    text2 = uicontrol( fig , 'style' , 'text' , 'position' , [50,300,500,30] ,...
        'string' , 'Veuillez donner une valeur aux paramètres' , 'fontsize' , 15 )
    
    text3 = uicontrol ( fig , 'style' , ' edit' , 'position', [170,240,50,15] , 'Max' , 1 , 'string' , '230' );
    ui3 = uicontrol ( fig , 'style' , ' text' , 'position', [10,240,150,15] , 'string' , 'Puissance effective' );
    unit3 = uicontrol ( fig , 'style' , ' text' , 'position', [230,240,30,15] , 'string' , '[MW]' );
    
    text4 = uicontrol ( gcf , 'Style' , 'popup' , 'String' , 'CH4|C12H23|C|CH1.8|C3H8|H2|CO' , 'Position' , [440 242 100 15] )
    ui4 = uicontrol ( fig , 'style' , ' text' , 'position', [280, 238 ,150,15] , 'string' , 'Carburant' )

    text5 = uicontrol ( fig , 'style' , ' edit' , 'position', [170,200,50,15] , 'Max' , 1 , 'string' , '0.95');
    ui5 = uicontrol ( fig , 'style' , ' text' , 'position', [10,185,150,45] , 'string' , 'Coefficient de perfection aérodynamique de la combustion (k_cc)' );
    unit5 = uicontrol ( fig , 'style' , ' text' , 'position', [230,200,30,15] , 'string' , '[/]' );
    
    text6 = uicontrol ( fig , 'style' , ' edit' , 'position', [440,200,50,15] , 'Max' , 1 , 'string' , '1050' )
    ui6 = uicontrol ( fig , 'style' , ' text' , 'position', [280,192,150,30] , 'string' , 'Temperature de sortie de combustion (doit être =< 1150)' )
    unit6 = uicontrol ( fig , 'style' , ' text' , 'position', [500,200,30,15] , 'string' , '[C]' )
    
    text7 = uicontrol ( fig , 'style' , ' edit' , 'position', [170,147,50,20] , 'Max' , 1 , 'string' , '0.90' );
    ui7 = uicontrol ( fig , 'style' , ' text' , 'position', [10,142,150,30] , 'string' , 'Rendement polytropique du compresseur (eta_piC)' );
    unit7 = uicontrol ( fig , 'style' , ' text' , 'position', [230,150,30,15] , 'string' , '[/]' );
    
    text8 = uicontrol ( fig , 'style' , ' edit' , 'position', [440,147,50,20] , 'Max' , 1 , 'string' , '0.90' );
    ui8 = uicontrol ( fig , 'style' , ' text' , 'position', [280,142 ,150,30] , 'string' , 'Rendement polytropique de la turbine (eta_piT)' );
    unit8 = uicontrol ( fig , 'style' , ' text' , 'position', [500,150,30,15] , 'string' , '[/]' );
    
    text9 = uicontrol ( fig , 'style' , ' edit' , 'position', [170,108,50,15] , 'Max' , 1 , 'string' , '0.015' );
    ui9 = uicontrol ( fig , 'style' , ' text' , 'position', [10,100,150,30] , 'string' , 'Coefficient de pertes mécaniques(k_mec)' );
    unit9 = uicontrol ( fig , 'style' , ' text' , 'position', [230,108,30,15] , 'string' , '[/]' );
    
    text10 = uicontrol ( fig , 'style' , ' edit' , 'position', [440,108,50,15] , 'Max' , 1 , 'string' , '10' );
    ui10 = uicontrol ( fig , 'style' , ' text' , 'position', [280,100,150,30] , 'string' , 'Rapport de compression (normalement égal à 10)' )
    unit10 = uicontrol ( fig , 'style' , ' text' , 'position', [500,108,30,15] , 'string' , '[/]' );
    
    
    bp1 = uicontrol ( fig , 'style' , 'push' , 'position' , [420 50 60 30 ] ,...
        'string' , 'Démarrer' , 'callback' , @(bp1,eventdata) TG(str2double(get(text3,'String')), get(text4,'Value'), str2double(get(text7,'String')), str2double(get(text8,'String')), str2double(get(text9,'String')), str2double(get(text6,'String')), str2double(get(text5,'String')), str2double(get(text10,'String'))))
end

%%%%%
%TGV%
%%%%%
if cycle == 3
    fig = figure('units','normalized','outerposition',[0.33 0.2 0.33 0.8],'name','Interface de la simulation de turbine à gaz')
  
    text1 = uicontrol( fig , 'style' , 'text' , 'position' , [125,670,340,30] ,...
        'string' , 'Installation à cycles combinés (TGV)' , 'fontsize' , 15 )
   
    text2 = uicontrol( fig , 'style' , 'text' , 'position' , [50,620,500,30] ,...
        'string' , 'Veuillez donner une valeur aux paramètres' , 'fontsize' , 15 )
    
    text2bis = uicontrol( fig , 'style' , 'text' , 'position' , [38,575,500,30] ,...
        'string' , 'Turbine à gaz:' , 'fontsize' , 15 )
    
    text2bisbis = uicontrol( fig , 'style' , 'text' , 'position' , [38,335,500,30] ,...
        'string' , 'Turbine à vapeur:' , 'fontsize' , 15 )
    
    text3 = uicontrol ( fig , 'style' , ' edit' , 'position', [170,540,50,15] , 'Max' , 1 , 'string' , '300' );
    ui3 = uicontrol ( fig , 'style' , ' text' , 'position', [10,540,150,15] , 'string' , 'Puissance effective' );
    unit3 = uicontrol ( fig , 'style' , ' text' , 'position', [230,540,30,15] , 'string' , '[MW]' );
    
    text4 = uicontrol ( gcf , 'Style' , 'popup' , 'String' , 'CH4|C12H23|C|CH1.8|C3H8|H2|CO' , 'Position' , [440 542 100 15] )
    ui4 = uicontrol ( fig , 'style' , ' text' , 'position', [280, 538 ,150,15] , 'string' , 'Carburant' )

    text5 = uicontrol ( fig , 'style' , ' edit' , 'position', [170,500,50,15] , 'Max' , 1 , 'string' , '0.95');
    ui5 = uicontrol ( fig , 'style' , ' text' , 'position', [10,485,150,45] , 'string' , 'Coefficient de perfection aérodynamique de la combustion (k_cc)' );
    unit5 = uicontrol ( fig , 'style' , ' text' , 'position', [230,500,30,15] , 'string' , '[/]' );
    
    text6 = uicontrol ( fig , 'style' , ' edit' , 'position', [440,500,50,15] , 'Max' , 1 , 'string' , '1050' )
    ui6 = uicontrol ( fig , 'style' , ' text' , 'position', [280,492,150,30] , 'string' , 'Temperature de sortie de combustion (doit être =< 1150)' )
    unit6 = uicontrol ( fig , 'style' , ' text' , 'position', [500,500,30,15] , 'string' , '[C]' )
    
    text7 = uicontrol ( fig , 'style' , ' edit' , 'position', [170,447,50,20] , 'Max' , 1 , 'string' , '0.90' );
    ui7 = uicontrol ( fig , 'style' , ' text' , 'position', [10,442,150,30] , 'string' , 'Rendement polytropique du compresseur (eta_piC)' );
    unit7 = uicontrol ( fig , 'style' , ' text' , 'position', [230,450,30,15] , 'string' , '[/]' );
    
    text8 = uicontrol ( fig , 'style' , ' edit' , 'position', [440,447,50,20] , 'Max' , 1 , 'string' , '0.90' );
    ui8 = uicontrol ( fig , 'style' , ' text' , 'position', [280,442 ,150,30] , 'string' , 'Rendement polytropique de la turbine (eta_piT)' );
    unit8 = uicontrol ( fig , 'style' , ' text' , 'position', [500,450,30,15] , 'string' , '[/]' );
    
    text9 = uicontrol ( fig , 'style' , ' edit' , 'position', [170,408,50,15] , 'Max' , 1 , 'string' , '0.015' );
    ui9 = uicontrol ( fig , 'style' , ' text' , 'position', [10,400,150,30] , 'string' , 'Coefficient de pertes mécaniques(k_mec)' );
    unit9 = uicontrol ( fig , 'style' , ' text' , 'position', [230,408,30,15] , 'string' , '[/]' );
    
    text10 = uicontrol ( fig , 'style' , ' edit' , 'position', [440,408,50,15] , 'Max' , 1 , 'string' , '10' );
    ui10 = uicontrol ( fig , 'style' , ' text' , 'position', [280,400,150,30] , 'string' , 'Rapport de compression (normalement égal à 10)' )
    unit10 = uicontrol ( fig , 'style' , ' text' , 'position', [500,408,30,15] , 'string' , '[/]' );
    
    
    
    
    
    
    text11 = uicontrol ( fig , 'style' , ' edit' , 'position', [170,300,50,15] , 'Max' , 1 , 'string' , '5.8' );
    ui11 = uicontrol ( fig , 'style' , ' text' , 'position', [10,300,150,15] , 'string' , 'Pression de vapeur à BP (p2)' );
    unit11 = uicontrol ( fig , 'style' , ' text' , 'position', [230,300,30,15] , 'string' , '[bar]' );
    
    text12 = uicontrol ( fig , 'style' , ' edit' , 'position', [440,300,50,15] , 'Max' , 1 , 'string' , '78' );
    ui12 = uicontrol ( fig , 'style' , ' text' , 'position', [280,300,150,15] , 'string' , 'Pression de vapeur HP (p3)');
unit12 = uicontrol ( fig , 'style' , ' text' , 'position', [500,300,30,15] , 'string' , '[bar]' );

    text13 = uicontrol ( fig , 'style' , ' edit' , 'position', [170,260,50,15] , 'Max' , 1 , 'string' , '0.9');
    ui13 = uicontrol ( fig , 'style' , ' text' , 'position', [10,245,150,45] , 'string' , 'Rendement isentropique des turbines (eta_isT)' );
    unit13 = uicontrol ( fig , 'style' , ' text' , 'position', [230,260,30,15] , 'string' , '[/]' );
    
    text14= uicontrol ( fig , 'style' , ' edit' , 'position', [440,260,50,15] , 'Max' , 1 , 'string' , '0.9' )
    ui14 = uicontrol ( fig , 'style' , ' text' , 'position', [280,252,150,30] , 'string' , 'Rendement isentropique de la pompe (eta_isP)' )
    unit14 = uicontrol ( fig , 'style' , ' text' , 'position', [500,260,30,15] , 'string' , '[/]' )
    
    text15 = uicontrol ( fig , 'style' , ' edit' , 'position', [170,207,50,20] , 'Max' , 1 , 'string' , '0.95' );
    ui15 = uicontrol ( fig , 'style' , ' text' , 'position', [10,202,150,30] , 'string' , 'Rendement mécanique (eta_mec)' );
    unit15 = uicontrol ( fig , 'style' , ' text' , 'position', [230,210,30,15] , 'string' , '[/]' );
    
    text16 = uicontrol ( fig , 'style' , ' edit' , 'position', [440,207,50,20] , 'Max' , 1 , 'string' , '15' );
    ui16 = uicontrol ( fig , 'style' , ' text' , 'position', [280,197 ,150,30] , 'string' , 'Approche (delta_ta=t4g-t3)' );
    unit16 = uicontrol ( fig , 'style' , ' text' , 'position', [500,210,30,15] , 'string' , '[°C]' );
    
    text17 = uicontrol ( fig , 'style' , ' edit' , 'position', [170,168,50,15] , 'Max' , 1 , 'string' , '15' );
    ui17 = uicontrol ( fig , 'style' , ' text' , 'position', [10,154,150,30] , 'string' , 'Température au condenseur' );
    unit17 = uicontrol ( fig , 'style' , ' text' , 'position', [230,168,30,15] , 'string' , '[°C]' );
    
    text18 = uicontrol ( fig , 'style' , ' edit' , 'position', [440,168,50,15] , 'Max' , 1 , 'string' , '15' );
    ui18 = uicontrol ( fig , 'style' , ' text' , 'position', [280,160,150,30] , 'string' , 'Pincement au condenseur' )
    unit18 = uicontrol ( fig , 'style' , ' text' , 'position', [500,168,30,15] , 'string' , '[°C]' );
    
    text19 = uicontrol ( fig , 'style' , ' edit' , 'position', [170,129,50,15] , 'Max' , 1 , 'string' , '10' );
    ui19 = uicontrol ( fig , 'style' , ' text' , 'position', [10,118,150,30] , 'string' , 'Pincement au ballon HP' )
    unit19 = uicontrol ( fig , 'style' , ' text' , 'position', [230,126,30,15] , 'string' , '[°C]' );
    
    text20 = uicontrol ( fig , 'style' , ' edit' , 'position', [440,129,50,15] , 'Max' , 1 , 'string' , '10' );
    ui20 = uicontrol ( fig , 'style' , ' text' , 'position', [280,118,150,30] , 'string' , 'Pincement au ballon BP' )
    unit20 = uicontrol ( fig , 'style' , ' text' , 'position', [500,126,30,15] , 'string' , '[°C]' );
    
    bp1 = uicontrol ( fig , 'style' , 'push' , 'position' , [420 50 60 30 ] ,...
        'string' , 'Démarrer' , 'callback' , @(bp1,eventdata) TGV(str2double(get(text3,'String')), get(text4,'Value'), str2double(get(text7,'String')), str2double(get(text8,'String')), str2double(get(text9,'String')), str2double(get(text6,'String')), str2double(get(text5,'String')), str2double(get(text10,'String')), str2double(get(text14,'String')), str2double(get(text13,'String')),str2double(get(text15,'String')),str2double(get(text11,'String')),str2double(get(text12,'String')),str2double(get(text16,'String')),str2double(get(text17,'String')),str2double(get(text18,'String')),str2double(get(text19,'String')),str2double(get(text20,'String'))))
end