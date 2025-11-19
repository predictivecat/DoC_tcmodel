function EntropiaShannon = calculoSE(PSD, f, banda)
% calculoSE computes the Shannon entropy for a power spectral density  
%       function.
%
%		SHANNONENTROPY = COMPUTATIONSE(PSD, F, BANDA), computes the Shannon
%		entropy of the distribution indicated in PSD, indexed by the
%		frequency vector F, in the frequency range introduced in the 
%       two-elements vector BANDA ([min_freq max_freq] Hz).
%
%       SHANNONENTROPY returns the Shannon entropy.

%
% Version: 2.0
%
% Created: May 08, 2006
%
% Last modification: April 29, 2013
%
% Author: Jesús Poza Crespo
%

% Indices of the band of interest
% indbanda = find(f >= banda(1) & f <= banda(2));
% 
% % If the PSD is Nan, so will be the SE
% if isnan(PSD(indbanda(3)))
%     EntropiaShannon = NaN;
% else
%     % Initialize the output variable
%     EntropiaShannon = [];
% 
%     % Total power of the band of interest
%     potenciatotal = sum(PSD(indbanda));
%     % Probability density function in the band of interest
%     fdp = PSD(indbanda)/potenciatotal;
% 
%     % Normalized Shannon Entropy
%     EntropiaShannon = -nansum(fdp(:).*log(fdp(:)))/log(length(fdp(:)));
% end
% 

%%%%%% case for real signal
potenciatotal = sum(PSD, 3);
fdp = PSD ./ potenciatotal;  % Element-wise division, same size as PSD_band
fdp(fdp == 0) = NaN;
entropyMatrix = -nansum(fdp .* log(fdp), 3) ./ log(size(PSD, 3));  
EntropiaShannon = nanmean(entropyMatrix, 1);  % Final size: (1 ¡Á channel)


end
    