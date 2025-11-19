function handles = parisliegefig2(param_name, liege1, liege0, paris1, paris0)


% Colors to be used (4 for now, can add more)
p=[0.4940, 0.1840, 0.5560]; % Purple
b=[0, 0.4470, 0.7410]; % Blue
colorVector = [b; p; b; p];
alphaBackground = [0.3;0.3;0.3;0.3];
alpha = [0.5;0.5;0.5;0.5];
% Create group and value vector for plot
group = [ones(1,size(liege1,2)), 2*ones(1,size(liege0,2)), 3, 4*ones(1,size(paris1,2)), 5*ones(1,size(paris0,2))]

values = [liege1, liege0, NaN, paris1, paris0];

figure('rend','painters','pos',[10 10 600 300])
hold on
distributionPlot(values.','groups', group,'Color', [0.8 0.8 0.8],'addBoxes',1,'showMM',0,'addSpread',0)


% Color the violin plots.
h = findobj(gca,'Type','Patch');
for j=1:length(h)
    patch(get(h(j),'XData'),get(h(j),'YData'),colorVector(j,:),'FaceAlpha',alphaBackground(j),'EdgeColor','none');
end

h = findobj(gca,'Tag','Box');
for j=1:length(h)
    if j >3
        jdex = j-1;
    else
        jdex = j;
    end
    patch(get(h(j),'XData'),get(h(j),'YData'),colorVector(jdex,:),'FaceAlpha',alpha(jdex));
end


c = get(gca, 'Children');
set(gca,'xtick',[1.5, 4.5])
set(gca,'xticklabel',{' ',' '})
set(gca,'fontsize',14)
ylabel(param_name,  'Rotation', 90, 'FontSize', 12); 
hleg1 = legend(c(1:2), {'TSO > 1 year','TSO < 1 year'}, 'Location','Best');
legend('boxoff')
end