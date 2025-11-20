function PE = permutation_entropy(signal, m, tau)
    N = length(signal);
   
    % Generate m-length embedding sequences
    num_permutations = factorial(m); % Number of possible orderings
    counts = zeros(num_permutations, 1); % Store counts for each pattern
   
    % Loop over time series
    for i = 1:N - (m - 1)*tau
        % Extract m values and get their ranking (permutation)
        [~, perm] = sort(signal(i:tau:i + (m - 1)*tau));
        idx = perm_to_index(perm, m); % Convert permutation to index
        counts(idx) = counts(idx) + 1; % Count occurrences
    end
   
    % Compute probability distribution
    P = counts / sum(counts);
    P(P == 0) = []; % Remove zero probabilities to avoid log(0)

    % Compute Permutation Entropy
    PE = -sum(P .* log2(P)) / log2(num_permutations);
end

% Helper function to convert permutation to unique index
function index = perm_to_index(perm, m)
    persistent perm_table;
    if isempty(perm_table)
        perm_table = perms(1:m);
    end
    [~, index] = ismember(perm, perm_table, 'rows');
end
