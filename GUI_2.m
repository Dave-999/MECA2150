function [] = GUI_2(cycle)
close all
%%%%%%%%%%%%%%%%
%Cycle à vapeur%
%%%%%%%%%%%%%%%%

if cycle==1
    fig = figure('color',[0.2 0.5 0.8],'name','Steam power plant simulator initerface')
    text3 = uicontrol( fig , 'style' , 'text' , 'position' , [170,300,230,30] ,...
        'string' , 'Steam power plant' , 'fontsize' , 15 )
    text4 = uicontrol( fig , 'style' , 'text' , 'position' , [50,200,500,30] ,...
        'string' , 'Please set the parameters value' , 'fontsize' , 15 )
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
    
    %TG(power, fuel, eta_piC, eta_piT, k_mec, T3, k_cc, lambda)
end

end