
clc,clear

load('DatosEjemplo.mat');

figure('position',[500 100 700 700]);
%%%%% Violin-plot
L={'Healthy controls','Migraine patients'};
distributionPlot([RP_HC;RP_MP],'groups',[ones(1,39),2*ones(1,87)]','xnames',L,'addBoxes',1,'histOpt',1,'color',[.8 .8 .8],'showMM',0,'variableWidth',1,'addSpread',1,'invert',0,'xyOri','normal');
[p,H,stats]=ranksum(RP_HC,RP_MP)
% Making it cool
h = findobj(gca,'Tag','Box');
patch(get(h(2),'XData'),get(h(2),'YData'),'y','facecolor',[ 52 148 186]./255,'FaceAlpha',.5);
patch(get(h(1),'XData'),get(h(1),'YData'),'y','facecolor',[255 50  10]./255,'FaceAlpha',.5);
ylim([0 .45])
ylabel('Relative power in B1','FontWeight','bold','FontSize',14)
set(gca,'fontsize',16);
set(gca,'linewidth',3);
box off;


