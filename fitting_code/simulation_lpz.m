% read output and generate simulation
% lpz_simu_paris_control = cell(1, 2);
addpath('D:\liege\matlab_script\Lin_connectivity\Basic functions');
foldername={'outputs_paris_fz','outputs_paris_pz','paris_inner'};
for j = 3
    folderpath=['D:\nftsim-master\nftsim-master\outputs\' foldername{j} '\'];
    files = dir([folderpath '*.output']);
    cd(folderpath);
    nChannels = 144;

    for ii = 1:length(files)
        filename = files(ii).name;
        nf_obj = nf.read(filename);
        simulation = nf_obj.data{3};
        lenepo = epochlength(ii);
        nEpochs = floor(size(simulation,1)/lenepo); % 551 samples in one epoch
        lpz_eeg = zeros(nChannels,nEpochs);
        for channelN = 1:nChannels
            for epochN = 1:nEpochs
                lpz_eeg(channelN,epochN) = calculoLZC(simulation((lenepo*(epochN-1)+1):lenepo*epochN,channelN));
            end
        end
        lpz_simu_paris_control{j}(ii)=mean(lpz_eeg,'all');
    end
end
% cd('D:\nftsim-master\nftsim-master\outputs');
save('lpz_simu_paris_control.mat','lpz_simu_paris_control');
%%
%remove two bad recordings
uws_index([175,215]) = [];

figure;
scatter(lpz_paris_real{1}(3,:),lpz_paris_simu{1}(3,:), 'MarkerEdgeColor', [0.5882, 0.7176, 0.4000], 'LineWidth', 1.5);hold on;
scatter(lpz_paris_real{2}(3,:),lpz_paris_simu{2}(3,:), 'MarkerEdgeColor', [0.8863, 0.7294, 0.3569], 'LineWidth', 1.5);hold on;
scatter(lpz_paris_real{3}(3,:),lpz_paris_simu{3}(3,:),'MarkerEdgeColor', [0.7059, 0.3294, 0.3882],'LineWidth', 1.5);
scatter(lpz_paris_real{1}(3,:),lpz_paris_simu{1}(3,:), 'MarkerEdgeColor', [0.5882, 0.7176, 0.4000], 'LineWidth', 1.5);
% legend('HC','MCS', 'UWS');
ylabel('Simulation LZC','FontSize',14);
xlabel('Empirical LZC','FontSize',14);
set(gca, 'Box', 'on', 'FontSize',12);
[r,p]=corr(SE_real_paris{3}',se_simu_paris{3}')
[r,p]=corr(lpz_fz_control',lpz_example')
[r,p]=corr(lpz_simu_fz',lpz_simu_pz')






%% order: all, fz, pz
% reshaped_matrix = reshape(lpz_simu_uws, 34, 3)';
% lpz_simu_uws = reshaped_matrix;
lpz_real_mcs = zeros(3,87);
files = dir('*.mat');
for ii=1:length(files)
    lpz_real_mcs(1,ii)=load(files(ii).name,'lpz_inner_new').lpz_inner_new;%inner
    lpz_real_mcs(2,ii)=load(files(ii).name,'lpz_fz_new').lpz_fz_new;%fz
    lpz_real_mcs(3,ii)=load(files(ii).name,'lpz_pz_new').lpz_pz_new;%pz

end
lpz_real_mcs(:,6)=[];
lpz_simu_liege{1} = reshape({1}, 3, 37);

[r,p]=corr(lpz_real_uws(3,:)',lpz_simu_liege{3}(3,:)')
[r,p]=corr(lpz_pz_control',lpz_simu_paris_control{2}(1:37)')


lpz_simu_liege{3}=reshape(lpz_simu_liege{3}(:), 34, 3).';

%%
% Read the file as a cell array of lines
fileList=dir('*.conf');
new_line = 'Output: Node: All Start: 5 Interval: 0.4e-2';

for ii = 1:length(fileList)
filename = fileList(ii).name;

% Read the file
fid = fopen(filename, 'r');
if fid == -1
    error('Cannot open the file.');
end
lines = textscan(fid, '%s', 'Delimiter', '\n', 'Whitespace', '');
fclose(fid);
lines = lines{1}; % Extract cell array of lines

if length(lines) >= 84
    lines{84} = new_line;
else
    error('File does not have 84 lines.');
end

% Write back the modified content
fid = fopen(filename, 'w');
if fid == -1
    error('Cannot open the file for writing.');
end
fprintf(fid, '%s\n', lines{:});
fclose(fid);
end

%%
epochlength = zeros(578,1); % Preallocate with zeros

for ii = 1:578
    if strcmp(dataInfo(ii).Task, 'lg')
        epochlength(ii) = 386;
    elseif strcmp(dataInfo(ii).Task, 'rs')
        epochlength(ii) = 201;
    end
end

%%
y_name = {'All channels', 'Fz', 'Pz'};

options.bandNames = {'Empirical data','Simulation'};
options.groupNames = {'HC','MCS','UWS'};
options.comparisonType = 2;
options.normalize = 0;

% all figure
for j=1:3
    options.measureName = y_name{j};
    [~,p(j,:)]=displayDistributionPlots(options,[lpz_real_hc(j,:)', lpz_simu_liege{1}(j,:)'] ...
                                               ,[lpz_real_mcs(j,:)', lpz_simu_liege{2}(j,:)'] ...
                                               ,[lpz_real_uws(j,:)', lpz_simu_liege{3}(j,:)'])
end


%%
foldername={'paris_control_fz','paris_control_pz','paris_control_inner'};
for j = 1:3
    folderpath=['/media/congyu.lin/CORSAIR/' foldername{j} '/'];
    files = dir([folderpath '*.output']);
    cd(folderpath);
    nChannels = 144; 

    for ii = 1:length(files)
        filename = files(ii).name;
        nf_obj = nf.read(filename);
        simulation = nf_obj.data{3};
        lenepo = 201%epochlength(ii);
        nEpochs = floor(size(simulation,1)/lenepo); % 551 samples in one epoch
        pe_eeg = zeros(nChannels,nEpochs);
        for channelN = 1:nChannels
            for epochN = 1:nEpochs
                EEG_filt = filtfilt(bandpass_filter,simulation((lenepo*(epochN-1)+1):lenepo*epochN,channelN));
                pe_eeg(channelN,epochN) = permutation_entropy(EEG_filt',3,8);
            end
        end
        pe_simu_paris_control{j}(ii)=mean(pe_eeg,'all');
    end
end
save('pe_simu_paris_control.mat','pe_simu_paris_control')
