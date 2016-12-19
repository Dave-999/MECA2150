function [] = TGPlot_recup()

length=200;
r=linspace(2,100,length);
TGeta_cyclen=zeros(5,length);
Maximums=zeros(1,5);

for i=1:length
    TGeta_cyclen(1,i)=TG_recup(230,'CH4',0.9,0.9,0.015,1400,0.95,r(i),0)
end
Maximums(1)=max(TGeta_cyclen(1,:))
j1=1;
while TGeta_cyclen(1,j1)<Maximums(1)
   j1=j1+1;
end
TGeta_cyclen(2,:)=TGeta_cyclen(1,:)
TGeta_cyclen(3,:)=TGeta_cyclen(1,:)
TGeta_cyclen(4,:)=TGeta_cyclen(1,:)
TGeta_cyclen(5,:)=TGeta_cyclen(1,:)

TGeta_cyclen(2,1)=TG_recup(230,'CH4',0.9,0.9,0.015,1400,0.95,2,1)

for i=2:length
    if TGeta_cyclen(2,i-1)>TGeta_cyclen(1,i-1)
        TGeta_cyclen(2,i)=TG_recup(230,'CH4',0.9,0.9,0.015,1400,0.95,r(i),1)
    else
        break;
    end
    
end
Maximums(2)=max(TGeta_cyclen(2,:))
j2=1;
while TGeta_cyclen(2,j2)<Maximums(2)
   j2=j2+1;
end
TGeta_cyclen(3,1)=TG_recup(230,'CH4',0.9,0.9,0.015,1400,0.95,2,2)

for i=2:length
    if TGeta_cyclen(3,i-1)>TGeta_cyclen(1,i-1)
     TGeta_cyclen(3,i)=TG_recup(230,'CH4',0.9,0.9,0.015,1400,0.95,r(i),2)
    else
        break;
    end
end

Maximums(3)=max(TGeta_cyclen(3,:))
j3=1;
while TGeta_cyclen(3,j3)<Maximums(3)
   j3=j3+1;
end

TGeta_cyclen(4,1)=TG_recup(230,'CH4',0.9,0.9,0.015,1400,0.95,2,4)

for i=2:length
     if TGeta_cyclen(4,i-1)>TGeta_cyclen(1,i-1)
     TGeta_cyclen(4,i)=TG_recup(230,'CH4',0.9,0.9,0.015,1400,0.95,r(i),4)
     else
         break;
     end
end
Maximums(4)=max(TGeta_cyclen(4,:))
j4=1;
while TGeta_cyclen(4,j4)<Maximums(4)
   j4=j4+1;
end

TGeta_cyclen(5,1)=TG_recup(230,'CH4',0.9,0.9,0.015,1400,0.95,2,8)

for i=2:length
    if TGeta_cyclen(5,i-1)>=TGeta_cyclen(1,i-1)
     TGeta_cyclen(5,i)=TG_recup(230,'CH4',0.9,0.9,0.015,1400,0.95,r(i),8)
    else
        break;
    end
end
Maximums(5)=max(TGeta_cyclen(5,:))
j5=1;
while TGeta_cyclen(5,j5)<Maximums(5)
   j5=j5+1;
end

figure

plot(r,TGeta_cyclen)
hold on
plot(r(j5),Maximums(5),'o','MarkerSize',10)
plot(r(j4),Maximums(4),'o','MarkerSize',10)
plot(r(j3),Maximums(3),'o','MarkerSize',10)
plot(r(j2),Maximums(2),'o','MarkerSize',10)
plot(r(j1),Maximums(1),'o','MarkerSize',10)

legend('NTU=0','NTU=1','NTU=2','NTU=4','NTU=8')
title('Rendemdent énergétique du cycle selon r et le NTU')
xlabel('r [/]')
ylabel('eta_{cyclen} [/]')

end

