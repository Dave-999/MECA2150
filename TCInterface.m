%Fenêtre de choix
function [] = TCInterface1()
fig=figure('color',[0.2 0.5 0.8],'name','Thermal cycles simulator interface')
text1 = uicontrol( fig , 'style' , 'text' , 'position' , [200,300,170,30] ,...
    'string' , 'Hello' , 'fontsize' , 15 )
text2 = uicontrol( fig , 'style' , 'text' , 'position' , [50,200,500,30] ,...
    'string' , 'Please select a thermal cycle' , 'fontsize' , 15 )
choix1 = uicontrol ( gcf , 'Style' , 'popup' , 'String' , 'Steam power plant|Gas turbine|Combined cycle power plant' , 'Position' , [150 50 170 80] );

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
    fig=figure('color',[0.9 0.6 0.3],'name','Gas turbine simulator interface ')
      
    text1 = uicontrol( fig , 'style' , 'text' , 'position' , [200,350,170,30] ,...
        'string' , 'Gas turbine' , 'fontsize' , 15 )
   
    text2 = uicontrol( fig , 'style' , 'text' , 'position' , [50,300,500,30] ,...
        'string' , 'Please set the parameters value' , 'fontsize' , 15 )
    
    text3 = uicontrol ( fig , 'style' , ' edit' , 'position', [170,240,50,15] , 'Max' , 1 , 'string' , '230' );
    ui3=uicontrol ( fig , 'style' , ' text' , 'position', [10,240,150,15] , 'string' , 'Turbine power' );
    unit3=uicontrol ( fig , 'style' , ' text' , 'position', [230,240,30,15] , 'string' , '[MW]' );
    
    text4 = uicontrol ( gcf , 'Style' , 'popup' , 'String' , 'Methane|Kerosene' , 'Position' , [440 242 100 15] );
    ui4=uicontrol ( fig , 'style' , ' text' , 'position', [280, 238 ,150,15] , 'string' , 'Fuel type' );

    text5 = uicontrol ( fig , 'style' , ' edit' , 'position', [170,200,50,15] , 'Max' , 1 , 'string' , '0.95');
    ui5=uicontrol ( fig , 'style' , ' text' , 'position', [10,185,150,45] , 'string' , 'Aerodynamic perfection coefficient of the combution chamber (k_cc)' );
    unit5=uicontrol ( fig , 'style' , ' text' , 'position', [230,200,30,15] , 'string' , '[/]' );
    
    text6 = uicontrol ( fig , 'style' , ' edit' , 'position', [440,200,50,15] , 'Max' , 1 , 'string' , '1323.15' );
    ui6=uicontrol ( fig , 'style' , ' text' , 'position', [280,192,150,30] , 'string' , 'Combustion exit temperature T3 (must be =< 1150)' );
    unit6=uicontrol ( fig , 'style' , ' text' , 'position', [500,200,30,15] , 'string' , '[C]' );
    
    text7 = uicontrol ( fig , 'style' , ' edit' , 'position', [170,147,50,20] , 'Max' , 1 , 'string' , '0.90' );
    ui7=uicontrol ( fig , 'style' , ' text' , 'position', [10,142,150,30] , 'string' , 'Compressor polytropic efficiency (eta_piC)' );
    unit7=uicontrol ( fig , 'style' , ' text' , 'position', [230,150,30,15] , 'string' , '[/]' );
    
    text8 = uicontrol ( fig , 'style' , ' edit' , 'position', [440,147,50,20] , 'Max' , 1 , 'string' , '0.90' );
    ui8=uicontrol ( fig , 'style' , ' text' , 'position', [280,142 ,150,30] , 'string' , 'Turbine polytropic efficiency (eta_piT)' );
    unit8=uicontrol ( fig , 'style' , ' text' , 'position', [500,150,30,15] , 'string' , '[/]' );
    
    text9 = uicontrol ( fig , 'style' , ' edit' , 'position', [170,108,50,15] , 'Max' , 1 , 'string' , '0.015' );
    ui9=uicontrol ( fig , 'style' , ' text' , 'position', [10,100,150,30] , 'string' , 'Mechanical loss coefficient (k_mec)' );
    unit9=uicontrol ( fig , 'style' , ' text' , 'position', [230,108,30,15] , 'string' , '[/]' );
    
    text10 = uicontrol ( fig , 'style' , ' edit' , 'position', [440,108,50,15] , 'Max' , 1 , 'string' , '1' );
    ui10=uicontrol ( fig , 'style' , ' text' , 'position', [280,100,150,30] , 'string' , 'Air excess coefficient (lambda)' )
    unit10=uicontrol ( fig , 'style' , ' text' , 'position', [500,108,30,15] , 'string' , '[/]' );
    
    bp1= uicontrol ( fig , 'style' , 'push' , 'position' , [420 40 60 30 ] ,...
        'string' , 'Start' , 'callback' , @(bp1,eventdata)TCInterface2(bp1,eventdata,get(choix1,'Value')))
    
    %TCGas(power, fuel, eta_piC, eta_piT, k_mec, T3, k_cc, lambda)
end

end

