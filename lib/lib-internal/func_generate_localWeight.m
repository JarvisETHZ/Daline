function W = func_generate_localWeight(X, tau)
% func_generate_localWeight generates the weight to place greater emphasis 
% (i.e., heavier weight) on data points that are closer to the operating 
% point of interest. Here, the operating point of interest is the last
% point in X, i.e., X(end, :).

%% Start

% Compute the difference between each row and the last row
diffs = X - X(end, :);

% Compute the 2-norm for each row of diffs
distances = vecnorm(diffs', 2)';
distances2 = distances.^2;

% Compute the weight
W = exp( -1 * distances2 ./ (2 * tau^2));
W = diag(W);