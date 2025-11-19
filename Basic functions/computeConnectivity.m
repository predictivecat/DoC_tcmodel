function adj_matrix = computeConnectivity(timeseries,measure,nwindow)

% Orthogonalizate the signal (For AEC_ort calculation)
signal_ort = orthogonalise(timeseries);
% signal_ort = symmetric_orthogonalise_alt(timeseries);
%signal_ort= timeseries
num_chann = size(signal_ort,2);

switch measure
    case 'AEC'
        for n_chann = 1:num_chann % For each channel
            % Of note, it is not the same to orthogonalize channel A
            % with respect to B as it is channel B to A. Thus, the
            % matrix will not be symmetrical. To address this issue
            % it is common to average both connectivity measures (A>B
            % and B>A)
            
            % Calculate AEC
            AEC_tmp = (calculo_AEC(squeeze(signal_ort(:, :, n_chann))));
            adj_matrix(:, n_chann) = AEC_tmp(:, n_chann); % Store it in the adjacency matrix
        end
        
        % Average both connectivity measures
        AEC1 = triu(squeeze(adj_matrix(:,:)));
        AEC2 = tril(squeeze(adj_matrix(:,:))).';
        AECglobal = (AEC1+AEC2)/2;
        adj_matrix(:,:) = (triu(AECglobal, 1)+AECglobal.'); % Store it in the adjacency matrix
        
    case 'PLV'
        for n_chann = 1:num_chann % For each channel
            % Of note, it is not the same to orthogonalize channel A
            % with respect to B as it is channel B to A. Thus, the
            % matrix will not be symmetrical. To address this issue
            % it is common to average both connectivity measures (A>B
            % and B>A)
            
            % Calculate PLV
            [~, ~, PLV_tmp] = calculo_PLI_PLV(squeeze(signal_ort(:, :, n_chann)));
            adj_matrix(:, n_chann) = PLV_tmp(:, n_chann); % Store it in the adjacency matrix
        end
        
        % Average both connectivity measures
        PLV1=triu(squeeze(adj_matrix(:,:)));
        PLV2=tril(squeeze(adj_matrix(:,:))).';
        PLVglobal=(PLV1+PLV2)/2;
        adj_matrix(:,:) = abs(triu(PLVglobal, 1)+PLVglobal.'); % Store it in the adjacency matrix
        
    case 'PLI'
        
        [~, PLI_tmp, ~] = calculo_PLI_PLV(squeeze(timeseries.')); % Not necessary to orthogonalize
        adj_matrix = PLI_tmp;
end
