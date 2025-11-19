function [PLI,wPLI,PLV] = calculo_PLI_PLV(signal)
%   Calculates Phase Lag Index, weigthed Phase Lag Index, and Phase Locking value

%   - signal: Input signal nSamples X nChannels

%   - PLI: Phase Lag Index between each pair of channels (nChannels X
%   nChannels) 
%       Measure: Nolte, 2007, Human Brain Mapping, DOI: 10.1016/j.clinph.2004.04.029
%       Implementation: Based on research group knowledge
%   - wPLI: Weigthed Phase Lag Index between each pair of channels
%   (nChannels X nChannels) 
%       Measure: Vinck, 2011, NeuroImage, DOI: 10.1016/j.neuroimage.2011.01.055
%       Implementation: 
%           Method 1: Paper: Ortiz, 2012, Computational and Mathematical Methods in Medicine, DOI: 10.1155/2012/186353
%           Method 2: Paper: Lau, 2012, Journal of NeuroEngineering and Rehabilitation, DOI: 10.1186/1743-0003-9-47
%           Bothe methods achieve (almost) the same values
%   - PLV: Phase Locking Value between each pair of channels (nChannels X
%   nChannels) 
%       Measure: Mormann, 2000, Physica D: Nonlinear Phenomena, DOI: 10.1016/S0167-2789(00)00087-7
%       Implementation: https://www.researchgate.net/post/How-to-calculate-the-instantaneous-Phase-locking-Value-with-EEG-data

numChannels = size(signal,2);
phaseSignal = angle(hilbert(signal));

% Saúl's optimization
angles1 = reshape(repmat(phaseSignal,numChannels,1),size(phaseSignal,1),numChannels*numChannels);
angles2 = repmat(phaseSignal,1,numChannels);

PLI_vector = abs(mean(sign(sin(angles1-angles2))));
PLI = reshape(PLI_vector, [numChannels,numChannels]);

ImZ = sin(angles1-angles2);
wPLI_vector = abs(mean(abs(ImZ).*sign(ImZ))) ./ mean(abs(ImZ)); % Method 1
% wPLI_vector = abs(mean(abs(ImZ)./ImZ)); % Method 2
wPLI = reshape(wPLI_vector, [numChannels,numChannels]);

PLV_vector =  abs(sum(exp(1i*(angles1-angles2))))/size(signal,1);
PLV = reshape(PLV_vector, [numChannels,numChannels]);

end