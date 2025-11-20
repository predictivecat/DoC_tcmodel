addpath('D:\liege\matlab_script\Lin_connectivity\ctmcode\braintrak');
addpath('D:\liege\matlab_script\Lin_connectivity\ctmcode\corticothalamic-model');
addpath('D:\liege\matlab_script\Lin_connectivity');
addpath('D:\liege\matlab_script\Lin_connectivity\ctmcode\nftsim');
addpath('D:\liege\matlab_script\distributionPlot_width');
%%
% before running this code, run the python code to get psds from fif
% in command: 
% python compute_psd_array.py "E:\CONTROL_LOCAL_GLOBAL\derivatives\nice_epochs" "E:\current_suj"
folderPath = 'E:\result';
cd(folderPath);
fileList = dir('*.mat');
dataInfo = struct('Subject', {}, 'Session', {}, 'Task', {}, 'Filename', {});

% get the data file including session, subject, task
for i = 1:length(fileList)
    fileName = fileList(i).name;
    tokens = regexp(fileName, 'sub-(\w+)_ses-(\d+)_task-([a-z]+)', 'tokens');
    
    if ~isempty(tokens)
        tokens = tokens{1};
        dataInfo(i).Subject = tokens{1};
        dataInfo(i).Session = tokens{2};
        dataInfo(i).Task = tokens{3};
        dataInfo(i).Filename = fileName;
    end
end


%%
around_Fz=[6 7 8 14 15 16 21 22 23];
around_Pz=[100 110 118 101 119 126 127 128 129];
%around_Pz=[94 101 106 95 107 111 112 113 114];%Liege index

% Channels to delete (face, neck, etc.)
outer1 = [237, 233, 229, 216, 208, 199, 187, 174, 165, 145, 133, 120, 111, 102, 91, 256, 251, 247];
outer2 = [240, 236, 232, 228, 217, 209, 200, 188, 175, 166, 156, 146, 134, 121, 112, 103, 92, 82, 255, 250, 246, 243];
outer3 = [239, 235, 231, 227, 218, 201, 189, 176, 167, 157, 147, 135, 122, 113, 104, 93, 73, 254, 249, 245, 242];
face = [238, 234, 230, 226, 225, 219, 67, 253, 252, 248, 244, 241];
exclude = unique([outer1, outer2, outer3, face]);
all_numbers = 1:256;
inner = setdiff(all_numbers, exclude);

 
% full_param_name = {'Gee','Gei','Ges','Gse','Gsr', 'Gre', 'Grs', 'Alpha','Beta','t0','EMGa'};
% bt_fz.plot;



%%
for j = 1:length(fileList)
    filePath = fullfile('D:\liege\Liege PSDs for Braintrak\UWS\', fileList(j).name);
    data = load(filePath);
    psds = data.psds;
    % freqs = data.freqs;
%compute the psd for fz and pz channels
    ave_psds_chan = squeeze(mean(psds,1));
    % psds_fz = ave_psds_chan(around_Fz,:);
    % ave_psds_fz = squeeze(mean(ave_psds_chan,1));
    % psds_pz = ave_psds_chan(around_Pz,:);
    % ave_psds_pz = squeeze(mean(ave_psds_chan,1));
    psds_inner = ave_psds_chan(:,:);
    ave_psds_inner = squeeze(mean(ave_psds_chan,1));
    
%fit the model to two regions seperately
    new_freqs = [1:0.1:40];
    % resampled_psds_fz = interp1(freqs, ave_psds_fz, new_freqs, 'linear', 'extrap');
    % resampled_psds_pz = interp1(freqs, ave_psds_pz, new_freqs, 'linear', 'extrap');
    resampled_psds_inner = interp1(freqs, ave_psds_inner, new_freqs, 'linear', 'extrap');
 
    % bt_fz = bt.fit(bt.model.full_nuab_emg, new_freqs', resampled_psds_fz');
    % bt_pz = bt.fit(bt.model.full_nuab_emg, new_freqs', resampled_psds_pz');
    bt_inner = bt.fit(bt.model.full, new_freqs', resampled_psds_inner');
    % fz_chi(j) = bt_fz.fit_data.fitted_chisq;
    % pz_chi(j) = bt_pz.fit_data.fitted_chisq;
    inner_chi_uws_liege(j) = bt_inner.fit_data.fitted_chisq;
    param_uws_liege(j,:)=bt_inner.fit_data.fitted_params;
    % all_param_fz(i,:)= [bt_fz.fit_data.fitted_params];
    % all_param_pz(i,:)= [bt_pz.fit_data.fitted_params];
    % all_param_inner(i,:)= [bt_inner.fit_data.fitted_params];
    % bt_fz.model.p.alpha = bt_fz.fit_data.fitted_params(9)* ones(1,8);
    % bt_fz.model.p.beta = bt_fz.fit_data.fitted_params(10)* ones(1,8);
    % bt_fz.model.p.t0 = bt_fz.fit_data.fitted_params(11);
    % bt_fz.model.p.taues = bt_fz.fit_data.fitted_params(11)/2;
    % bt_fz.model.p.tause = bt_fz.fit_data.fitted_params(11)/2;
    % bt_fz.model.p.nus = bt_fz.fit_data.fitted_params([1:8]);
    % bt_fz.model.p.emg_a = bt_fz.fit_data.fitted_params(12);
    % complete_gab(bt_fz.model.p);
    % liber_fz(i,:)= [bt_fz.model.p.nus bt_fz.model.p.gab bt_fz.model.p.gabcd bt_fz.model.p.t0 bt_fz.model.p.emg_a bt_fz.model.p.xyz bt_fz.fit_data.fitted_chisq];
    % fit_inner(i,:)=bt_inner.fit_data.fitted_P;
    % target_inner(i,:)=bt_inner.fit_data.target_P;
    % fit_inner(i,:)=bt_inner.fit_data.fitted_P;
    % target_inner(i,:)=bt_inner.fit_data.target_P;
    % fit_inner(i,:)=bt_inner.fit_data.fitted_P;
    % target_inner(i,:)=bt_inner.fit_data.target_P;

    % detect whether there is nus and phi values
    % 
    % try
    %     out = nftsim(bt_fz.model.p, fileList(i).name);
    % catch
    % end
end
%%
for j = [mcs_index uws_index]
    filePath = fullfile('E:\result\', fileList(j).name);
    data = load(filePath);
    psds = data.psds;
    freqs = data.freqs;
%compute the psd for fz and pz channels
    ave_psds_chan = squeeze(mean(psds,1));
    % psds_fz = ave_psds_chan(around_Fz,:);
    % ave_psds_fz = squeeze(mean(ave_psds_chan,1));
    % psds_pz = ave_psds_chan(around_Pz,:);
    % ave_psds_pz = squeeze(mean(ave_psds_chan,1));
    psds_inner = ave_psds_chan(inner,:);
    ave_psds_inner = squeeze(mean(ave_psds_chan,1));
    
%fit the model to two regions seperately
    new_freqs = [1:0.1:40];
    % resampled_psds_fz = interp1(freqs, ave_psds_fz, new_freqs, 'linear', 'extrap');
    % resampled_psds_pz = interp1(freqs, ave_psds_pz, new_freqs, 'linear', 'extrap');
    resampled_psds_inner = interp1(freqs, ave_psds_inner, new_freqs, 'linear', 'extrap');
 
    bt_inner = bt.fit(bt.model.full, new_freqs', resampled_psds_inner');
    inner_chi(j) = bt_inner.fit_data.fitted_chisq;
    param(j,:)=bt_inner.fit_data.fitted_params;
    
end
inner_chi_mcs_9=inner_chi(mcs_index);
param_mcs_9=param(mcs_index,:);

inner_chi_uws_9=inner_chi(uws_index);
param_uws_9=param(uws_index,:);
% 
save('chi.mat','inner_chi_hc','inner_chi_uws_12','inner_chi_mcs_12','param_hc','param_mcs_12','param_uws_12','inner_chi_mcs_9','param_mcs_9','inner_chi_uws_9','param_uws_9')
%%
save('full_param_inner.mat', 'all_param_inner');
save('full_param_fz.mat', 'full_param_fz');
save('full_param_pz.mat', 'full_param_pz');
save('datainfo.mat','dataInfo');
% result from 1-212, then 219-328


%% read .output
addpath('D:\ProgramFiles\MATLAB\eeglab_current\eeglab2024.2');
cd('D:\nftsim-master\nftsim-master\outputs')
for i = 409 %6:10
    files = dir('*.output');
    nf_obj = nf.read(files(i).name);
    [f, P] = nf.spectrum(nf_obj, {'Propagator.1.phi'});
    indices = find(f >= 1 & f <= 40);
    P_normed = P(indices) / mean(P(indices));
    f_fitted = new_freqs;
    p_target = target_pz(i,:)/mean(target_pz(i,:));
    p_fitted = fit_pz(i,:)/mean(fit_pz(i,:));
    figure; 
    h1=loglog(f(indices),P_normed, 'LineWidth', 0.8, 'Color',[0.643,0.749,0.373]);hold on 
    h2=loglog(f_fitted,p_fitted, 'LineWidth', 1, 'Color', [0.941,0.639,0.11]);
    h3=loglog(f_fitted,p_target, 'LineWidth', 1, 'Color', [0.678, 0.373, 0.749]);
    hold off;
    xlim([0 40]);
    xlabel('Frequency (Hz)'); 
    ylabel('Power (V^2)'); 
    legend([h3, h2, h1], { 'Empirical data','Separate parameter', 'Time series' }, 'Location', 'best');

end

%%
patient_fz=[full_param_fz; all_param_fz(38:48,:)];
patient_pz=[full_param_pz; all_param_pz(38:48,:)];
patient_inner=[full_param_inner; all_param_inner(38:48,:)];
control_fz=all_param_fz(1:37,:);
control_pz=all_param_pz(1:37,:);
control_inner=all_param_inner(1:37,:);

save('parameter_comparison.mat','patient_inner','patient_pz','patient_fz','control_inner',"control_pz","control_fz")

%%
mcs_lg(1,:) = lpz_fz_patient(intersect(lg_index, mcs_index));
mcs_rs(1,:) = lpz_fz_patient(intersect(rs_index, mcs_index));

for j = 1:3
    [p(j),~,stat] = ranksum(mcs_rs(j,:),mcs_lg(j,:));
    rank(j)=stat.ranksum;
end
p_cor = mafdr(p, 'BHFDR', true);

[r,p]=corr(lpz_simu_fz(intersect(lg_index,uws_index))',lpz_fz_patient(intersect(lg_index, uws_index))')
