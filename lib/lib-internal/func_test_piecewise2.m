function error = func_test_piecewise2(X_test, Y_test, result, Npq)
% here compute the error of Vm from Vm^2; NVm2 is the number of variable Vm^2

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

% Test the result
for k = 1:num_cluster
    % Get all errors
    Y_pred = X_test(idx == k, :) * result.Beta{k};
    error(idx == k, :) = abs(Y_pred - Y_test(idx == k, :)) ./ abs(Y_test(idx == k, :));
    
    % Get error of Vm from Vm^2; the first Npq cols in error correspond to Vm;
    % tested by comparing the result with a stupid but accurate method.
    % Doesn't matter whether the input data are normalized or not, i.e., the
    % error formula here remains the same (norm factor will be eliminated
    % anyway). Of course, the error will change because the training process is
    % influenced by the normalization.
    error(idx == k, 1:Npq) = abs(sqrt(Y_pred(:, 1:Npq)./Y_test(idx == k, 1:Npq))-1);
end