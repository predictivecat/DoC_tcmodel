% Load FIF file
addpath('D:\ProgramFiles\MATLAB\eeglab_current\eeglab2024.2');
addpath('D:\liege\matlab_script\Lin_connectivity\Basic functions');
% add fieldtrip manually D:\ProgramFiles\MATLAB\eeglab_current\fieldtrip-20250114
folderPath = 'E:\finished_suj';
cd(folderPath);
fileList = dir(fullfile(folderPath, '**', '*.fif'));
fileList = dir('*.mat');
% for the control group need to filter files without ._
% fileList = fileList(~startsWith({fileList.name}, '._'));
%% lpz
bandpass_filter = designfilt('bandpassfir','DesignMethod','window','Window','hamming','FilterOrder',60,...
    'CutoffFrequency1',1,'CutoffFrequency2',40,'SampleRate',250);

nChannels_fz = 9;
nChannels_inner = 183;
for k = 1:length(fileList)
    EEG = pop_fileio([fileList(k).folder '\' fileList(k).name], 'dataformat','auto');
    EEG = eeg_checkset(EEG);
    EEG_save = EEG.data(inner,:,:); % channels x frames x epochs
    nEpochs=size(EEG.data,3);
    
    lpz_eeg = [];
    
    for epochN = 1:nEpochs
        for channelN = 1:nChannels_inner
            EEG_filt = filtfilt(bandpass_filter,double(squeeze(EEG_save(channelN,:,epochN))));
            lpz_eeg(channelN,epochN) = calculoLZC(EEG_filt);
        end
    end
    lpz_fz_new(k)=mean(lpz_eeg(around_Fz,:),"all");
    lpz_pz_new(k)=mean(lpz_eeg(around_Pz,:),'all');
    lpz_inner_new(k)=mean(lpz_eeg(:,:),'all');

end
% save('9_parameters_patient.mat','full_param_pz','full_param_fz','full_param_inner');
% save('lpz_result_filter.mat','lpz_inner_new','lpz_pz_new','lpz_fz_new');
% lpz_pz(331) = [];
% 需要把pz从1-347重算一边，index搞错了
% 从520开始继续算
%%
options.bandNames = {''};
options.groupNames = {'control','mcs','uws'};
options.comparisonType = 2;save('pe2.mat','pe_inner','pe_pz','pe_fz')

options.normalize = 0;
options.measureName = {'lpz-all'}
[p,p_c]=displayDistributionPlots(options,lpz_inner_control',lpz_inner(mcs_index)',lpz_inner(uws_index)');

[top10_values, top10_indices] = maxk(lpz_pz(mcs_index), 10);


%%
lpz_pz_patient = lpz_pz_new(38:end);
lpz_fz_patient = lpz_fz_new(38:end);
lpz_inner_patient = lpz_inner_new(38:end);


lpz_pz_control = lpz_pz_new(1:37);
lpz_fz_control = lpz_fz_new(1:37);
lpz_inner_control = lpz_inner_new(1:37);

lpz_fz_patient(331)=[];
lpz_pz_patient(331)=[];
lpz_inner_patient(331)=[];

save('lpz_paris.mat','lpz_inner_patient','lpz_pz_patient','lpz_fz_patient','lpz_inner_control','lpz_fz_control','lpz_pz_control','lpz_simu_fz','lpz_simu_fz_control','lpz_simu_pz','lpz_simu_pz_control')

lpz_fz_selected = lpz_pz_patient(uws_index < 308);
lpz_simu_selected = lpz_simu_pz(uws_index < 308);

% Compute correlation
[a, b] = corr(lpz_fz_selected', lpz_simu_selected')

