function error = func_test_piecewise_parallel(X_test, Y_test, Beta, center)

% Get numbers
num_cluster = length(Beta);
[num_test, num_response] = size(Y_test);

% Define containers
loss = zeros(num_test, num_cluster);
error = zeros(num_test, num_response);

% Allocate X_test into clusters first
for k = 1:num_cluster
    loss(:, k) = sum( (X_test - center(k, :)).^2,  2 );
end
[~, idx] = min(loss, [], 2);  % find the minimum value of each row (each observation) in loss => cluster index of this observation

% Test the result
for k = 1:num_cluster
    error(idx == k, :) = abs(X_test(idx == k, :) * Beta{k} - Y_test(idx == k, :)) ./ abs(Y_test(idx == k, :));
end