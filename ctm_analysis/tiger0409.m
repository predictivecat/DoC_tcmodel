% main ctm fitting, generate configuration files

clear all
close all
clc

addpath('D:\liege\matlab_script\Lin_connectivity\ctmcode\braintrak');
addpath('D:\liege\matlab_script\Lin_connectivity\ctmcode\corticothalamic-model');
addpath('D:\liege\matlab_script\Lin_connectivity');
addpath('D:\liege\matlab_script\Lin_connectivity\ctmcode\nftsim');

%% load EEG
fs_eeg = 250;
window_length = fs_eeg * 5;
bandpass_filter = designfilt('bandpassfir','DesignMethod','window','Window','hamming','FilterOrder',1000,...
    'CutoffFrequency1',0.5,'CutoffFrequency2',45,'SampleRate',fs_eeg);

files = dir('*.mat');
no_root = {};

%% read eeg and fit and output conf
for j = 35:length(files)
%  for j = 1:10

    filename = files(j).name;
    load(filename); % load EEG_mat
    EEG_fil = filtfilt(bandpass_filter, EEG_mat.');
    signal_average = []; matrix_ref = [];
    signal_average = nanmean(EEG_fil,1); % Dimension 1 is the channels so the data has to be in the (channels, time) format
    matrix_ref = EEG_fil - repmat(signal_average,size(EEG_fil,1),1);
    [pxx_real, f_real] = pwelch(matrix_ref, window_length, [], [1:0.1:40],250);
    pxx_real_ave = mean(pxx_real,2);
    pxx_real_ave_norm = pxx_real_ave / mean(pxx_real_ave, 'all');
%     b = bt.fit(bt.model.full_nuab_emg, f_real, pxx_real_ave_norm);
    a1 = bt.fit(bt.model.full, f_real, pxx_real_ave_norm);
%     a2 = bt.fit(bt.model.lin, f_real, pxx_real_ave_norm);
%     complete the parameters in model
    b.model.p.alpha = b.fit_data.fitted_params(9)* ones(1,8);
    b.model.p.beta = b.fit_data.fitted_params(10)* ones(1,8);
    b.model.p.t0 = b.fit_data.fitted_params(11);
    b.model.p.taues = b.fit_data.fitted_params(11)/2;
    b.model.p.tause = b.fit_data.fitted_params(11)/2;
    b.model.p.nus = b.fit_data.fitted_params([1:8]);
    b.model.p.emg_a = b.fit_data.fitted_params(12);
    complete_gab(b.model.p);
    liber(j,:)= [b.model.p.nus b.model.p.gab b.model.p.gabcd b.model.p.t0 b.model.p.emg_a b.model.p.xyz b.fit_data.fitted_chisq];
    fit(j,:)=b.fit_data.fitted_P;
    target(j,:)=b.fit_data.target_P;
    % detect whether there is nus and phi values

%     try
%         out = nftsim(b.model.p, filename);
%     catch
%     end


% end
end


%%
y_list = [ 0  -40    0   -40     -5   10  100  0.075   0  0   -1   0   0;...
          20    0   40    0     0   100  800  0.14   1  1   1   1   5];
y_name = {'Gee' 'Gei' 'Gese' 'Gesre' 'Gsrs' 'alpha' 'beta' 'cortico-thalamic delay' 'EMG' 'X' 'Y' 'Z' 'chi-square'};
for j = 1
    figure;
    scatter(1,fit_param(:,j), 'o', 'MarkerEdgeColor',[0 0.4470 0.7410]); hold on;
    scatter(2,fit_param_mcs(:,j), 'o', 'MarkerEdgeColor',[0 0.4470 0.7410]); 
    scatter(3,fit_param_uws(:,j), 'o', 'MarkerEdgeColor',[0 0.4470 0.7410]); 
    mean1 = mean(fit_param(:,j));
    std1 = std(fit_param(:,j));
    mean2 = mean(fit_param_mcs(:,j));
    std2 = std(fit_param_mcs(:,j));
    mean3 = mean(fit_param_uws(:,j));
    std3 = std(fit_param_uws(:,j));
    errorbar([1,2,3],[mean1,mean2,mean3],[std1,std2,std3], 'LineWidth', 1, 'color', 'k')    
    hold off;
%     scatter(1, root4(j,:), 'bo'); hold on;
%     scatter(1, root4(j,find(root4(11,:)==0)), 'ro'); 
%     scatter(2, root3(j,:), 'bo'); 
%     scatter(3, root11(j,:), 'bo');
%     scatter(3, root11(j,find(root11(11,:)==0)), 'ro'); hold off;
%     ylim(y_list(:,j));

    ylabel(y_name{j});
    xlim([0 4]);
    xticks([1, 2, 3]);
    xticklabels({'HC', 'MCS', 'UWS'});
end
%%
cd('D:\liege\matlab_script\Lin_connectivity\ctmcode\nftsim\outputs')
for j = 1 %6:10
    files = dir('*.output');
    nf_obj = nf.read(files(j).name);
    [f, P] = nf.spectrum(nf_obj, {'Propagator.1.phi'});
    indices = find(f >= 1 & f <= 40);
    P_normed = P(indices) / mean(P(indices));
    f_fitted = new_freqs;
    p_target = target(j,:);
    p_fitted = fit(j,:);
    figure; 
    h1=loglog(f(indices),P_normed, 'LineWidth', 0.8, 'Color',[0.643,0.749,0.373]);hold on 
    h2=loglog(f_fitted,p_fitted, 'LineWidth', 1, 'Color', [0.941,0.639,0.11]);
    h3=loglog(f_fitted,p_target, 'LineWidth', 1, 'Color', [0.678, 0.373, 0.749]);
    full_fit = a1.fit_data.fitted_P;
    h4=loglog(f_fitted,full_fit, 'LineWidth', 1, 'Color',  [0.373, 0.749, 0.749]);
    hold off;
    xlim([0 40]);
    xlabel('Frequency (Hz)'); 
    ylabel('Power (V^2)'); 
    legend([h3, h4, h2, h1], { 'Empirical data','Combined parameter','Separate parameter', 'Time series' }, 'Location', 'best');

end
%%
simu_timeser = nf_obj.data{3};
duration = 5; % sec
sampling_length = duration*200; %sampling rate
x_time = linspace(0,duration,sampling_length);
y_series = simu_timeser(100:(100+sampling_length-1),1);
figure; plot(x_time,y_series);
xlabel('Time (seconds)', 'FontSize', 12); % Increase the font size for the x-label
ylabel('Neural Population Activity', 'FontSize', 12); % Increase the font size for the y-label
title('Simulation', 'FontSize', 18); % Increase the font size for the title
set(gca, 'FontSize', 12); % Increase the font size for the axes

%%
param(1,:)=[b.fit_data.fitted_params b.fit_data.xyz];
param(2,:)=[b.fit_data.fitted_params b.fit_data.xyz];

save('fitnu_MCS.mat','liber','fit','target')
save('fit_param.mat','fit_param','fit_param_mcs','fit_param_uws')


%%
files = dir('*.mat');

for j = 1:87
%  for j = 1:10

    filename = files(j).name;
    load(filename); % load EEG_mat
    EEG_fil = filtfilt(bandpass_filter, EEG_mat.');
    signal_average = []; matrix_ref = [];
    signal_average = nanmean(EEG_fil,1); % Dimension 1 is the channels so the data has to be in the (channels, time) format
    matrix_ref = EEG_fil - repmat(signal_average,size(EEG_fil,1),1);
    [pxx_real, f_real] = pwelch(matrix_ref, window_length, [], [1:0.1:40],250);
    pxx_real_ave = mean(pxx_real,2);
    pxx_real_ave_norm = pxx_real_ave / mean(pxx_real_ave, 'all');
    b = bt.fit(bt.model.lin, f_real, pxx_real_ave_norm);

    b.model.p.alpha = b.fit_data.fitted_params(8)* ones(1,8);
    b.model.p.beta = b.fit_data.fitted_params(9)* ones(1,8);
    b.model.p.t0 = b.fit_data.fitted_params(10);
    b.model.p.taues = b.fit_data.fitted_params(10)/2;
    b.model.p.tause = b.fit_data.fitted_params(10)/2;
    b.model.p.gab = [b.fit_data.fitted_params([1:5]), 1/b.fit_data.fitted_params(3), b.fit_data.fitted_params([6:7])];
    b.model.p.emg_a = b.fit_data.fitted_params(11);
    complete_nuab(b.model.p);
%     complete the parameters in model
    fitlin(j,:)=b.fit_data.fitted_P;
    target(j,:)=b.fit_data.target_P;
    % detect whether there is nus and phi values

    try
        out = nftsim(b.model.p, filename);
    catch
    end


% end
end
%%
figure;
for j = 9
    subplot(2, 5, j);  % Create a subplot in a 2x5 grid
    loglog(f_real, target(j, :), 'LineWidth', 1.5); hold on;
    loglog(f_real, fitlin(j, :), 'LineWidth', 1.5);
    legend('Real', 'Fit');
end

%%
nf_obj=nf.read('D:\nftsim-master\nftsim-master\outputs\outputs_liege_hc\eirs-model_95all_BenFatma_20100216_psds.mat_.output');

simu_timeser = nf_obj.data{3};
duration = 2.2040; % sec
sampling_length = duration*250; %sampling rate
x_time = linspace(0,duration,sampling_length);
y_series = simu_timeser(100:(100+sampling_length-1),1);
figure; plot(x_time,y_series,'LineWidth',2);
