%Fenêtre de choix
function [] = GUI()
close all
fig = figure('color',[0.2 0.5 0.8],'name','Interface du simulateur de cycles thermiques')
text1 = uicontrol( fig , 'style' , 'text' , 'position' , [200,300,170,30] ,...
    'string' , 'Bonjour' , 'fontsize' , 15 )
text2 = uicontrol( fig , 'style' , 'text' , 'position' , [50,200,500,30] ,...
    'string' , 'Veuillez sélectionner un cycle thermique' , 'fontsize' , 15 )
choix1 = uicontrol ( gcf , 'Style' , 'popup' , 'String' , 'Installation motrice à vapeur|Turbine à gaz|Installation à cycles combinés' , 'Position' , [150 50 170 80] );

bp1 = uicontrol ( fig , 'style' , 'push' , 'position' , [330 105 60 30 ] ,...
    'string' , 'Confirmer' , 'callback' , @(bp1,eventdata)GUI_2(get(choix1,'Value')))

end