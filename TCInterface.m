%PARAMETRE = PUISSANCE!

%Fenêtre de choix
function [] = TCInterface1()
fig=figure('color',[0.2 0.5 0.8],'name','Thermal cycles simulator interface')
text1 = uicontrol( fig , 'style' , 'text' , 'position' , [200,300,170,30] ,...
'string' , 'Hello' , 'fontsize' , 15 )
text2 = uicontrol( fig , 'style' , 'text' , 'position' , [50,200,500,30] ,...
'string' , 'Please select a thermal cycle' , 'fontsize' , 15 )
choix1 = uicontrol ( gcf , 'Style' , 'popup' , 'String' , 'Steam power plant|Gas turbine|Combined cycle power plant' , 'Position' , [200 50 100 80] );

bp1= uicontrol ( fig , 'style' , 'push' , 'position' , [330 105 60 30 ] ,...
'string' , 'Confirm' , 'callback' , @(bp1,eventdata)TCInterface2(bp1,eventdata,get(choix1,'Value')))

end

function [] = TCInterface2(bp,eventdata,cycle)

%%%%%%%%%%%%%%%%
%Cycle à vapeur%
%%%%%%%%%%%%%%%%
if cycle==1
fig=figure('color',[0.2 0.5 0.8],'name','Steam power plant simulator initerface')
text3 = uicontrol( fig , 'style' , 'text' , 'position' , [170,300,230,30] ,...
'string' , 'Steam power plant' , 'fontsize' , 15 )
text4 = uicontrol( fig , 'style' , 'text' , 'position' , [50,200,500,30] ,...
'string' , 'Please set the parameters value' , 'fontsize' , 15 )
end


%%%%%%%%%%%%%
%Cycle à gaz%
%%%%%%%%%%%%%

if cycle == 2
    fig=figure('color',[0.2 0.5 0.8],'name','Gas turbine simulator interface ')
text1 = uicontrol( fig , 'style' , 'text' , 'position' , [200,350,170,30] ,...
'string' , 'Gas turbine' , 'fontsize' , 15 )
text2 = uicontrol( fig , 'style' , 'text' , 'position' , [50,300,500,30] ,...
'string' , 'Please set the parameters value' , 'fontsize' , 15 )

text3 = uicontrol ( fig , 'style' , ' edit' , 'position', [170,100,100,20] , 'Max' , 1 , 'string' , '0.90' );
uicontrol ( fig , 'style' , ' text' , 'position', [10,85,150,40] , 'string' , 'Compressor polytropic efficiency (eta_piC)' );

text4 = uicontrol ( fig , 'style' , ' edit' , 'position', [170,140,100,20] , 'Max' , 1 , 'string' , '0.90' );
uicontrol ( fig , 'style' , ' text' , 'position', [10, 125,150,40] , 'string' , 'Turbine polytropic efficiency (eta_piT)' );

text5 = uicontrol ( fig , 'style' , ' edit' , 'position', [170,180,100,20] , 'Max' , 1 , 'string' , '0.95' );
uicontrol ( fig , 'style' , ' text' , 'position', [10,167,150,45] , 'string' , 'Aerodynamic perfection coefficient of the combution chamber (k_cc)' );

text6 = uicontrol ( fig , 'style' , ' edit' , 'position', [170,220,100,20] , 'Max' , 1 , 'string' , '0.015' );
uicontrol ( fig , 'style' , ' text' , 'position', [10,215,150,30] , 'string' , 'Mechanical loss coefficient (k_mec)' );

text7 = uicontrol ( gcf , 'Style' , 'popup' , 'String' , 'Methane|Kerosene' , 'Position' , [390 160 100 80] );
uicontrol ( fig , 'style' , ' text' , 'position', [305, 157 ,80,80] , 'string' , 'Fuel type' );

text8 = uicontrol ( fig , 'style' , ' edit' , 'position', [440,100,100,20] , 'Max' , 1 , 'string' , '0' );
uicontrol ( fig , 'style' , ' text' , 'position', [280, 75,150,40] , 'string' , 'Fuel mass rate m_c [kg/s])' );

text9 = uicontrol ( fig , 'style' , ' edit' , 'position', [440,140,100,20] , 'Max' , 1 , 'string' , '0' );
uicontrol ( fig , 'style' , ' text' , 'position', [280,125,150,40] , 'string' , 'Combustion exit temperature T3 [K] (must be <1323.15) ' );

text10 = uicontrol ( fig , 'style' , ' edit' , 'position', [440,180,100,20] , 'Max' , 1 , 'string' , '0' );
uicontrol ( fig , 'style' , ' text' , 'position', [280,178,150,20] , 'string' , 'Air excess coefficient (lambda)' )

bp1= uicontrol ( fig , 'style' , 'push' , 'position' , [420 40 60 30 ] ,...
'string' , 'Start' , 'callback' , @(bp1,eventdata)TCInterface2(bp1,eventdata,get(choix1,'Value')))

%TCGaz(power, fuel, eta_piC, eta_piT, k_mec, T3, k_cc, lambda)
end

end

