clear;
clc;
close all;
global NumSpecies mu lambda gamma D eta kappa;
NumSpecies=20;
mu0=0.5;
mu=mu0*ones(NumSpecies,1);
D=0.2;
gamma=0.95;
eta=0.2;
kappa=0.005;

initialHGT=0*ones(NumSpecies^2+NumSpecies,1);
for i=1:NumSpecies
    initialHGT(i)=1/NumSpecies;
    initialHGT(NumSpecies+(i-1)*NumSpecies+i)=initialHGT(i);
end

initial=0*ones(NumSpecies,1);
for i=1:NumSpecies
    initial(i)=1/NumSpecies;
end

cycles=30;
durations=15+15*rand(cycles,1);
time=[];
label=[];
Abund=[];
AbundHGT=[];
for i=1:cycles
    i
    mu=mu.*(0.95+0.1*rand(NumSpecies,1));
    lambda=mu/mu0-1;
    timespan=0:0.1:durations(i);
    if i==1
        time=[time timespan];     
    else
        time=[time max(time)+timespan];
    end
    label=[label 0*timespan];
    label(end)=1;
    [t1,y1]=ode45(@MultiSpecies,timespan,initial);
    Abund=[Abund;y1(:,1:NumSpecies)];
    initial=y1(end,:);
    [t2,y2]=ode45(@MultiSpeciesHGT,timespan,initialHGT);
    AbundHGT=[AbundHGT;y2(:,1:NumSpecies)];
    initialHGT=y2(end,:);
end

figure(1);
data=Abund;
diversity=0*ones(size(data,1),1);
for i=1:size(data,1)
    temp=data(i,:);
    temp=temp(temp>0);
    temp=temp/sum(temp);
    diversity(i)=exp(-sum(temp.*log(temp)));
end
plot(time,diversity);hold on;

data=AbundHGT;
diversityHGT=0*ones(size(data,1),1);
for i=1:size(data,1)
    temp=data(i,:);
    temp=temp(temp>0);
    temp=temp/sum(temp);
    diversityHGT(i)=exp(-sum(temp.*log(temp)));
end
plot(time,diversityHGT);hold on;
set(gca,'fontsize',16);
xlabel('time','fontsize',20);
ylabel('diversity','fontsize',20);
set(gcf,'position',[100 100 350 350]);
saveas(gcf,'Mutations_1.fig');
saveas(gcf,'Mutations_1.pdf');


figure(2);
subplot(1,2,1);
bar(Abund./sum(Abund,2),1,'stacked','edgecolor','none');
colormap('parula');
set(gca,'fontsize',16);
axis([0.5 length(time)+0.5 0 1]);
xlabel('time','fontsize',20);
ylabel('diversity','fontsize',20);
subplot(1,2,2);
bar(AbundHGT./sum(AbundHGT,2),1,'stacked','edgecolor','none');
colormap('parula');
set(gca,'fontsize',16);
axis([0.5 length(time)+0.5 0 1]);
set(gcf,'position',[100 100 700 350]);
saveas(gcf,'Mutations_2.fig');
saveas(gcf,'Mutations_2.pdf');



function dydt=MultiSpecies(t,y)
    global NumSpecies mu gamma D;
    dydt(NumSpecies,1)=0;
    for i=1:NumSpecies
        summ=0;
        for j=1:NumSpecies
            if i==j
                summ=summ+y(j);
            else
                summ=summ+gamma*y(j);
            end
        end
        dydt(i,1)=mu(i)*y(i)*(1-summ)-D*y(i);
    end
end

function dydt=MultiSpeciesHGT(t,y)
    global NumSpecies mu lambda gamma D eta kappa;
    dydt(NumSpecies*(1+NumSpecies),1)=0;
    thresh=0;
    for i=1:NumSpecies
            ss=1;
            sumy=0;
            for j=1:NumSpecies
                if i~=j
                    ss=ss*(1+lambda(j)*y(NumSpecies+(i-1)*NumSpecies+j)/y(i));
                end
                sumy=sumy+y(j);
            end
            dydt(i,1)=mu(i)*y(i)*ss*(1-(gamma*sumy-gamma*y(i)+y(i)))-D*y(i);
        for j=1:NumSpecies
                if j==i
                    dydt(NumSpecies+(i-1)*NumSpecies+j,1)=dydt(i,1);
                else
                    ss=1;
                    for k=1:NumSpecies
                        if k~=i&&k~=j
                            ss=ss*(1+lambda(k)*y(NumSpecies+(i-1)*NumSpecies+k)/y(i));
                        end
                    end
                    donor=0;
                    for k=1:NumSpecies
                        donor=donor+y(NumSpecies+(k-1)*NumSpecies+j);
                    end
                    dydt(NumSpecies+(i-1)*NumSpecies+j,1)=mu(i)*y(NumSpecies+(i-1)*NumSpecies+j)*ss*(1+lambda(j))*(1-(gamma*sumy-gamma*y(i)+y(i)))+eta*(y(i)-y(NumSpecies+(i-1)*NumSpecies+j))*donor-(kappa+D)*y(NumSpecies+(i-1)*NumSpecies+j);
                end
        end
    end

end