%chi square computation for all three types of curves

[pxx, f] = pwelch(EEG_mat.', [], [], [1:0.1:40],250);
pxx_ave = mean(pxx,2);
pxx_smooth = smooth(pxx_ave);

% Define frequency bands for coloring
freqBands = [1 4; 4 8; 8 13; 13 30; 30 40];
colors = [0.514 0.635 0.514; 0.624 0.718 0.624 ;0.733 0.8 0.733 ;0.843 0.882 0.843 ;0.917 0.934 0.917]; % Different shades of gray

% Plot the colored regions
figure;
hold on;
for i = 1:size(freqBands, 1)
    patch([freqBands(i,1) freqBands(i,2) freqBands(i,2) freqBands(i,1)], ...
          [0 0 1.1*max(pxx_smooth) 1.1*max(pxx_smooth)], ...
          colors(i, :), 'EdgeColor', 'none');
end

% Plot the smoothed average PSD
plot(f, pxx_smooth, 'k', 'LineWidth', 1.2); % 'b' specifies blue color for the line

xlabel('Frequency (Hz)','Fontsize',14);
ylabel('Power/Frequency (\muV^2/Hz)','Fontsize',14);
title('UWS','Fontsize',18);
xlim([1 40]);
ylim([0 1.1*max(pxx_smooth)]);

%%
% load chi-square full
chi_full_hc=load('fit_param.mat', 'fit_param');
chi_full_hc=chi_full_hc.fit_param;
chi_full_mcs=load('fit_param.mat', 'fit_param_mcs');
chi_full_mcs=chi_full_mcs.fit_param_mcs;
chi_full_uws=load('fit_param.mat', 'fit_param_uws');
chi_full_uws=chi_full_uws.fit_param_uws;

chisq_full_hc = chi_full_hc(:,13);
chisq_full_mcs = chi_full_mcs(:,13);
chisq_full_uws = chi_full_uws(:,13);

%load chi-square nuab
chi_nuab_hc=load('fitnu_HC.mat', 'liber');
chi_nuab_hc=chi_nuab_hc.liber;
chi_nuab_mcs=load('fitnu_MCS.mat', 'liber');
chi_nuab_mcs=chi_nuab_mcs.liber;
chi_nuab_uws=load('fitnu_UWS.mat', 'liber');
chi_nuab_uws=chi_nuab_uws.liber;

chisq_nuab_hc = chi_nuab_hc(:,27);
chisq_nuab_mcs = chi_nuab_mcs(:,27);
chisq_nuab_uws = chi_nuab_uws(:,27);

%% get the index of usable time series
mcslist = dir('D:\liege\matlab_script\Lin_connectivity\ctmcode\nftsim\obj\MCSEMG');
mcsall = {mcslist(~[mcslist.isdir]).name}.';
mcslistts = dir('D:\liege\matlab_script\Lin_connectivity\ctmcode\nftsim\obj\MCS0525');
mcssome = {mcslistts(~[mcslistts.isdir]).name}.';
[~, indicesmcs] = ismember(mcssome, mcsall);

%% compute chi-square timeseries
    files = dir('*.output');
for i = 1:57
    findex = indicesmcs(i);
    matObj = matfile('D:\liege\data\All epochs per group\mcs_linmodel_powerspectrum.mat');
    target = matObj.target(findex, :).';
    spec = matObj.fitlin(findex,:);
    nf_obj = nf.read(files(i).name);
    [f, P] = nf.spectrum(nf_obj, {'Propagator.1.phi'});
    indices = find(f >= 1 & f <= 40);
    P_normed = P(indices) / mean(P(indices));
    fit = interp1(f(indices), P_normed, f_real, 'linear');
    fit(1)=P_normed(1); fit(391)=P_normed(391);
    target(target == 0) = eps; % eps is a very small number in MATLAB
    sqdiff_time = (abs(fit-target)./target).^2;
    chitimemcs(i) = sum(sqdiff_time(:).*weight(:));
    % power pectrum
    sqdiff_power = (abs(spec.'-target)./target).^2;
    chipowermcs(i) = sum(sqdiff_power(:).*weight(:));
end



% chipowermcs([15 52 55])=[];
% chisq_full_mcs([15 52 55])=[];
% chisq_nuab_mcs([15 52 55])=[];
% chisq_time_UWS(25)=[];
% chisq_full_uws(25)=[];
% chipoweruws(25)=[];

%% 
for i = 1:37
    matObj = matfile('D:\liege\data\All epochs per group\hc_linmodel_powerspectrum.mat');
    target = matObj.target(i, :).';
    spec = matObj.fitlin(i,:);
    sqdiff_power = (abs(spec.'-target)./target).^2;
    chipowerhc(i) = sum(sqdiff_power(:).*weight(:));
end

%%
options.bandNames = {'Combined parameter','Separate parameter'};
options.groupNames = {'HC', 'MCS', 'UWS'};
options.measureName = 'Chi-square';
options.comparisonType = 2;
options.normalize = 0;
displayDistributionPlots(options,[chisq_full_hc,chipowerhc.'],...
    [chisq_full_mcs,chipowermcs.'], [chisq_full_uws,chipoweruws.'])


%%
options.bandNames = {' '};
options.groupNames = {'HC', 'MCS', 'UWS'};
options.measureName = 'Chi-square';
options.comparisonType = 2;
options.normalize = 0;
displayDistributionPlots(options, chitimehc', chitimemcs.', chitimeuws.');

%% lpz
