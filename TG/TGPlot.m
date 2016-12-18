function [] = TGPlot()
T3=1000;
length=100;
r=linspace(2,100,length);
TGy=zeros(1,length);
Maximums=zeros(1,4);
for i=1:length
     TGy(1,i)=TG(r(i),T3);
end
Maximums(1)=max(TGy)
plot(r,TGy)
hold on
j=1
while TGy(j)<Maximums(1)
   j=j+1;
end
plot(j,Maximums(1),'MarkerSize',10)

T3=1200;
for i=1:length
     TGy(1,i)=TG(r(i),T3)
end
Maximums(2)=max(TGy)
plot(r,TGy)
j=1
while TGy(j)<Maximums(2)
   j=j+1;
end
plot(j,Maximums(2),'MarkerSize',10)


T3=1400;
for i=1:length
     TGy(1,i)=TG(r(i),T3)
end
Maximums(3)=max(TGy)
plot(r,TGy)
j=1
while TGy(j)<Maximums(3)
   j=j+1;
end
plot(j,Maximums(3),'MarkerSize',10)


T3=1600;
for i=1:length
     TGy(1,i)=TG(r(i),T3)
end
Maximums(4)=max(TGy)
plot(r,TGy)
j=1
while TGy(j)<Maximums(4)
   j=j+1;
end
plot(j,Maximums(4),'MarkerSize',10)

legend('t3=1000°C','t3=1200°C','t3=1400°C','t3=1600°C')
xlabel('r [/]')
ylabel('Wm [kJ/kg]')
end

