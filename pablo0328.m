clear all
close all
clc

addpath('D:\liege\matlab_script\Lin_connectivity\ctmcode\braintrak')
addpath('D:\liege\matlab_script\Lin_connectivity\ctmcode\corticothalamic-model')

%% load spectrum
fs_eeg = 250;
window_length = fs_eeg * 5;
bandpass_filter = designfilt('bandpassfir','DesignMethod','window','Window','hamming','FilterOrder',1000,...
    'CutoffFrequency1',0.5,'CutoffFrequency2',40,'SampleRate',fs_eeg);

files = dir('*.mat');
for i = 1%:length(files)
    filename = files(i).name;
    load(filename); % load EEG_mat
    EEG_fil = filtfilt(bandpass_filter, EEG_mat.');
    signal_average = []; matrix_ref = [];
    signal_average = nanmean(EEG_fil,1); % Dimension 1 is the channels so the data has to be in the (channels, time) format
    matrix_ref = EEG_fil - repmat(signal_average,size(EEG_fil,1),1);
    [pxx_real, f_real] = pwelch(matrix_ref, window_length, [], [1:0.1:40],250);
    pxx_real_ave = mean(pxx_real,2);
    pxx_real_ave_norm = pxx_real_ave / mean(pxx_real_ave, 'all');
 
    a = bt.fit(bt.model.lin, f_real, pxx_real_ave_norm);
%     b = bt.fit(bt.model.full, f_real, pxx_real_ave_norm);
%     param1(i,:) = a.fit_data.fitted_params;
%     xyz1(i,:) = a.fit_data.xyz;
end
% a2.plot()
% b.plot()
% load('D:\liege\data\EEG database models\EEG full\Luypaert_2010_full.mat');
% load('D:\liege\data\All epochs per group\UWS\Anger_20160602.mat');

%% plot and statistics for parameters

hc = liber;
uws = liber1;
mcs = param2;
liber1(6,:)=[];
% h = zeros(1, 9);
% p = zeros(1, 9);
% ci = zeros(2, 9);
% stats = struct('tstat', zeros(1, 9), 'df', zeros(1, 9), 'sd', zeros(1, 9));
p_ano = zeros(1,9);
hc(:,25)=hc(:,22)+hc(:,23);
hc(:,26)=hc(:,22)-hc(:,23);
uws(:,25)=uws(:,22)+uws(:,23);
uws(:,26)=uws(:,22)-uws(:,23);
uws([1 31],:)=[];
% range for some parameters
% range = [[0,20];[];[0,40]; [-40,0];[];[];[]; [0.075,0.14]; [-0.1,1]]
for j = [17:21]
figure;
scatter(ones(size(hc(:,j))), hc(:,j), 'o', 'MarkerEdgeColor',[0 0.4470 0.7410]); hold on;
% scatter(2*ones(size(mcs(:,j))), mcs(:,j), 'o', 'MarkerEdgeColor',[0 0.4470 0.7410]);
scatter(3*ones(size(uws(:,j))), uws(:,j), 'o', 'MarkerEdgeColor',[0 0.4470 0.7410]);
mean1 = mean(hc(:,j));
std1 = std(hc(:,j));
mean2 = mean(uws(:,j));
std2 = std(uws(:,j));
% mean3 = mean(mcs(:,j));
% std3 = std(mcs(:,j));
errorbar([1,3],[mean1,mean2],[std1,std2], 'LineWidth', 1)
xlim([0,4]);
xticks([1, 2, 3]);
xticklabels({'HC', 'MCS', 'UWS'});
% ylabel(a2.model.param_names{j});
% ylim(range(j,:));
hold off;
% [h(j), p(j), ci(:,j), stats(j)] = ttest2(hc(:,j),uws(:,j));
% data = [hc(:,j).',mcs(:,j).',uws(:,j).'];
% group = [ones(1, size(hc,1)),2*ones(1, size(mcs,1)),3*ones(1, size(uws,1))];
% p_ano(j) = anova1(data,group,'off');
end

%% figure for xyz
% xyz1(:,4) = xyz1(:,1)-xyz1(:,2);
% xyz1(:,5) = xyz1(:,1)+xyz1(:,2);
xyz2(:,4) = xyz2(:,1)-xyz2(:,2);
% indice = find(xyz(:,4)<0.6);
% figure; scatter(ones(size(xyz(indice,1))), xyz(indice,1), 'o', 'MarkerEdgeColor',[0 0.4470 0.7410]); hold on;
% scatter(2*ones(size(xyz1(indice,1))), xyz1(indice,1), 'o', 'MarkerEdgeColor',[0 0.4470 0.7410]);
% figure; scatter(ones(size(xyz(indice,2))), xyz(indice,2), 'o', 'MarkerEdgeColor',[0 0.4470 0.7410]); hold on;
% scatter(2*ones(size(xyz1(indice,2))), xyz1(indice,2), 'o', 'MarkerEdgeColor',[0 0.4470 0.7410]);

figure; scatter(hc(:,24),hc(:,26),'DisplayName', 'HC'); hold on;
% scatter(xyz2(:,4),xyz2(:,3),'x','MarkerEdgeColor',[0 0 0], 'DisplayName', 'MCS');
scatter(uws(:,24),uws(:,26),'DisplayName', 'UWS'); hold off;
% col 16, grs
legend('Location', 'best');
xlabel('z');
ylabel('x+y');


save('paramHC.mat','param')
save('paramUWS.mat','param1')
save('paramMCS.mat','param2')
save('xyzHC.mat','xyz')
save('xyzUWS.mat','xyz1')
save('xyzMCS.mat','xyz2')
load('paramHC.mat')
