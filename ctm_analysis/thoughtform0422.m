% lempelziv for real and simulation

%% timeseries
nf_obj1 = nf.read('D:\liege\matlab_script\Lin_connectivity\ctmcode\nftsim\obj\UWS\eirs-model_66arra_20110714.mat_.output');
simulation = nf_obj.data{3};
fs = 1/nf_obj.deltat;

% window the data, get power spectral density
n_window = 8; % overlap = 0.5*window length, n+1 partitions, with 2 partitions in each window
part_len = floor(length(simulation)/(n_window+1));
win_index = [(0:(n_window-1))*part_len+1;(2:(n_window+1))*part_len];
NFFT = win_index(2,1); % window length?
freq_bin_width = fs / NFFT;
y1 = 0:freq_bin_width:(fs/2);
for index =1:n_window
    y=simulation(win_index(1,index):win_index(2,index),:);
    Y = fft(y, NFFT) / NFFT;    
    Y = Y(1:(floor(NFFT / 2) + 1), :); 
    P = abs(Y).^2;
end
P = mean(P, 2);
P = P ./ freq_bin_width; % Divide by frequency bin size to get power spectral density
indices = find(y1 >= 1 & y1 <= 40);
plot(y1(indices),P(indices)); % filter the frequency?

%% lempelziv EEG
files = dir('*.mat');
nChannels = 183;
for i = 53 :length(files)
    filename = files(i).name;
    load(filename); % load EEG_mat
    EEG_fil = filtfilt(bandpass_filter, EEG_mat.');
    signal_average = []; matrix_ref = [];
    signal_average = nanmean(EEG_fil,1); % Dimension 1 is the channels so the data has to be in the (channels, time) format
    matrix_ref = EEG_fil - repmat(signal_average,size(EEG_fil,1),1);
    nEpochs = floor(size(matrix_ref,1)/551); % 551 samples in one epoch,
    lpz_eeg = zeros(nChannels,nEpochs);
    for channelN = 1:nChannels
        for epochN = 1:nEpochs
            lpz_eeg(channelN,epochN) = calculoLZC(matrix_ref((551*(epochN-1)+1):551*epochN,channelN));
        end
    end
    lpz_eeg_mcs(i)=mean(lpz_eeg,'all');
end
% comparison = lpz_eeg_uws;
% figure; plot(matrix_ref(:,1));

%% lempelziv simulation
files = dir('*.output');
nChannels = 144;

for i = 1:length(files)
    filename = files(i).name;
    nf_obj = nf.read(filename);
    simulation = nf_obj.data{3};
    nEpochs = floor(size(simulation,1)/2000); % 551 samples in one epoch
    lpz_eeg = zeros(nChannels,nEpochs);
    for channelN = 1:nChannels
        for epochN = 1:nEpochs
            lpz_eeg(channelN,epochN) = calculoLZC(simulation((2000*(epochN-1)+1):2000*epochN,channelN));
        end
    end
    lpz_simu_uws(i)=mean(lpz_eeg,'all');    
end
% [lpzr,lpzp]=corr(lpz_eeg_uws.',lpz_simu_uws.');
% 
% lpz_eeg_uws(25)=[]; lpz_simu_uws(25)=[];
% figure_handles = nf.plot_timeseries(nf_obj1, {'Propagator.1.phi'}, {1:4:144});

%%
% relist the lzc
indiceshc = [1:35,37];
lpz_real_hc = lpz_eeg_hc(indiceshc);
lpz_real_mcs = lpz_eeg_mcs(indicesmcs);
lpz_fake_uws = [lpz_eeg_uws(1:24), 0, lpz_eeg_uws(25:33)];
lpz_real_uws = lpz_fake_uws(indicesuws);

figure;
scatter(lpz_pz_control, lpz_simu_pz_control, 'MarkerEdgeColor', [0.5882, 0.7176, 0.4000], 'LineWidth', 1.5); hold on;
scatter(lpz_pz_patient(mcs_index), lpz_simu_pz(mcs_index), 'MarkerEdgeColor', [0.8863, 0.7294, 0.3569], 'LineWidth', 1.5);
scatter(lpz_pz_patient(uws_index), lpz_simu_pz(uws_index), 'MarkerEdgeColor', [0.7059, 0.3294, 0.3882],'LineWidth', 1.5);
legend('HC', 'MCS', 'UWS', 'FontSize', 14);
ylabel('Simulation LZC', 'FontSize', 14);
xlabel('Empirical LZC', 'FontSize', 14);
set(gca, 'FontSize', 14,'Box', 'on');

options.bandNames = {'Empirical data' 'Simulation'};
options.groupNames = {'HC', 'MCS', 'UWS'};
options.measureName = 'LZC';
options.comparisonType = 2;
options.normalize = 0;
displayDistributionPlots(options,[lpz_real_hc',lpz_simu_hc'],[lpz_real_mcs',lpz_simu_mcs'],[lpz_real_uws',lpz_simu_uws']);

%%
figure; scatter(1,lpz_eeg_mcs); hold on
scatter(2,lpz_eeg_uws); hold off
xlim([0 3]);

a_vector = lpz_eeg(:);
figure;
histogram(a_vector);

meanchan = mean(lpz_eeg,2);
figure; histogram(meanchan);

%%    
for i = 1:183
    series = EEG_mat(i,:);
    max_lag = length(series) - 1; % Maximum lag is one less than the vector length
    [autocorrelation(i,:), lags] = autocorr(series.', 'NumLags', max_lag);
end

figure; hold on;
for i = 1:100
    plot(autocorrelation(i,[1:50]));
end
hold off;

nf_obj = nf.read('D:\liege\matlab_script\Lin_connectivity\ctmcode\nftsim\obj\HC\eirs-model_66lanche_20100713.mat_.output');
simulation = nf_obj.data{3};
for i = 1:144
    series = simulation(:,i);
    max_lag = length(series) - 1; % Maximum lag is one less than the vector length
    [autocorrelation1(i,:), lags1] = autocorr(series.', 'NumLags', max_lag);
end

figure; hold on;
for i = 1:100
    plot(autocorrelation1(i,[1:50]));
end
hold off;


autoco_eeg = mean(autocorrelation,1);
autoco_simu = mean(autocorrelation1,1);
figure;hold on;
plot(autoco_eeg([1:50]));
plot(autoco_simu([1:50]));
legend('real data', 'simulation');

corr(autoco_eeg([1:50]).', autoco_simu([1:50]).')
%%
for i = [1:8 22 23]
    para=liber(:,i);
    effect(i)=corr(para,lpz_simu_hc.');
    figure; scatter(liber(:,i),lpz_simu_hc); hold on
    scatter(liber([4 6 10],i),lpz_simu_hc([4,6,10]), 'r');
end

%%
sampling_rate = 250; % Hz
duration = 2; % seconds
num_samples = duration * sampling_rate; % Number of samples to plot

time = (0:num_samples-1) / sampling_rate; % Time vector in seconds

figure;
plot(time, simulation(1:num_samples, 1),'linewidth',1); % Plot first 2 seconds of all channels
xlabel('Time (s)');
ylabel('Amplitude');
title('Time-series Data for First 2 Seconds');
