function [error, Y_pred] = func_test_piecewise(X_test, Y_test, result)

% Get numbers
num_cluster = length(result.Beta);
[num_test, num_response] = size(Y_test);

% Define containers
loss = zeros(num_test, num_cluster);
error = zeros(num_test, num_response);

% Allocate X_test into clusters first
for k = 1:num_cluster
    loss(:, k) = sum( (X_test - result.center(k, :)).^2,  2 );
end
[~, idx] = min(loss, [], 2);  % find the minimum value of each row (each observation) in loss => cluster index of this observation

% Test the result and get Y_pred
Y_pred = zeros(size(Y_test));
for k = 1:num_cluster
    Y_pred(idx == k, :) = X_test(idx == k, :) * result.Beta{k};
    error(idx == k, :) = abs(Y_pred(idx == k, :) - Y_test(idx == k, :)) ./ abs(Y_test(idx == k, :));
end