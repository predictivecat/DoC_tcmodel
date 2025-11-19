% use displayDistributionPlots and friedman and signrank, etc

%%
options.bandNames = {' '};
options.groupNames = {'AEC-pairwise' 'AEC-symmetric' 'PLI' 'PLV'};
options.measureName = 'Correlation';
options.comparisonType = 1;
options.normalize = 0;
displayDistributionPlots(options,maxV_r_pair, maxV_r_sym, maxV_r_pli, maxV_r_plv);

%%
friedman([max_r_pair.', max_r_sym.', max_r_pli.', max_r_plv.']);
[p,h,stats] = signrank(nuab,full)
mafdr(p,'BHFDR',true)

%%
options.bandNames = {'empirical' 'simulation'};
options.groupNames = {'HC' 'MCS' 'UWS'};
options.measureName = 'Chi-square';
options.comparisonType = 2;
options.normalize = 0;
[pvalue,pcorrect]=displayDistributionPlots(options,[lpz_eeg_hc.',lpz_simu_hc.'],[lpz_eeg_mcs.',lpz_simu_mcs.'],[lpz_eeg_uws.',lpz_simu_uws.']);

[p,h,stats] = ranksum(chipowerhc,chipoweruws)
mafdr(p,'BHFDR',true)

eeg = [lpz_real_hc.';lpz_real_mcs.';lpz_real_uws.'];
simu = [lpz_simu_hc.';lpz_simu_mcs.';lpz_simu_uws.'];
[p,h,states]=signrank(lpz_real_uws,lpz_simu_uws)
mafdr(p,'BHFDR',true)


full = [chisq_full_hc; chisq_full_mcs; chisq_full_uws];
nuab = [chipowerhc.'; chipowermcs.'; chipoweruws.'];
time = [chisq_time_HC.'; chisq_time_MCS.'; chisq_time_UWS.'];
[p,h,stats] = signrank(nuab,full)
mafdr(p,'BHFDR',true)
ranksum()

%%
for i = 1:9
    hc = fit_param(:,i);
    mcs = fit_param_mcs(:,i);
    uws = fit_param_uws(:,i);
    [p_hc_mcs(i),~,stats(i)]=ranksum(hc,mcs);
    [p_hc_uws(i),~,stats(i)]=ranksum(hc,uws);
    [p_uws_mcs(i),~,stats(i)]=ranksum(uws,mcs);
    mafdr(p_hc_mcs,'BHFDR',true)
mafdr(p_hc_uws,'BHFDR',true)
mafdr(p_uws_mcs,'BHFDR',true)

end