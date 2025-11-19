function AEC_sim_temp = obtainConnectivity(timeseries_EEG_alpha,timeseries_alpha,nWindows_real,nWindows_simul,window_length_EEG,window_length_simul)

% for nWindow = 1:nWindows_real
%     %AEC(nWindow,:,:) = calculo_AEC(timeseries_EEG_alpha((nWindow-1)*window_length_EEG+1:window_length_EEG*(nWindow),:));
%     AEC(nWindow,:,:) = computeConnectivity(timeseries_EEG_alpha((nWindow-1)*window_length_EEG+1:window_length_EEG*(nWindow),:).','AEC');
% end

% Simulation
for nWindow = 1:nWindows_simul
    AEC_sim_temp(nWindow,:,:) = calculo_AEC(timeseries_alpha((nWindow-1)*window_length_simul+1:window_length_simul*(nWindow),:));
end

end