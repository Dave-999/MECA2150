function [] = piechart(data)
%dessine un piechart

labels = {sprintf('Travail utile \n %1.1f kJ/kg',data(1)),sprintf('Pertes calorifiques \n %1.1f kJ/kg',data(2))};
h = pie(data,labels);
for i = 2:2:2*numel(labels)
    h(i).Position = 1.2*h(i).Position;
end
title(sprintf('Travail énergétique primaire : %1.1f kJ/kg',sum(data)));

end