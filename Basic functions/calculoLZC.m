function [LZComplexity] = calculoLZC(serie)

%  Computes the LZC complexity of the input signal
%
%  Author: Daniel Abasolo
%  Modified by: Carlos Gomez Peña
%  Last update: 20 july 2021

% Define parameters
n = length(serie);
b = n/log2(n); % Normalization value

umbral = median(serie);

% Binarize the input signal
for j = 1:n
    if serie(j) >= umbral
   	    serie(j) = 1;
	else
   	    serie(j) = 0;
    end
end

% Initialize the vales
c = 1;	% Initial complexity value
S = serie(1); % Is the accumulated sequence
Q = serie(2); % The current sequence

% Loop that goes through the signal looking for subsequences
for i = 2:n
    % Creates the accumulated sequence, where you find coincidences with
    % the subsequence
    SQ = [S,Q];
	SQ_pi = [SQ(1:(length(SQ)-1))]; % Remove the last value (else it will always coincide with Q)
    
    % Return 0 if Q is not in SQ_pi
	k = findstr(Q,SQ_pi); 

    if length(k)==0
   	    % If the sequence in Q is not in SQ_pi
        
        % Update complexity value 
   	    c = c+1;				
        if (i+1)>n % If the end of "serie" is reached
            break;
        else
            S = [S,Q];			% Add Q (sequence that do not coincide) to S (accumulated sequence)
            Q = serie(i+1);		% New Q value
        end
   else
        % If Q is in Q_pi
        if (i+1)>n % If the end of "serie" is reached
            break;
        else
            % Update Q value 
            Q = [Q,serie(i+1)];	
        end
    end
end

LZComplexity = c/b; % Normalize LZC