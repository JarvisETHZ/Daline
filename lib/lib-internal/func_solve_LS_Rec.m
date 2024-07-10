function [Beta_final, time_update] = func_solve_LS_Rec(X_old, Y_old, X_new, Y_new, lambda, initialize, largeValue)
% Recursive least squares
%
% Ref. Y. Liu, Z. Li and S. Sun, "A Data-Driven Method for Online
% Constructing Linear Power Flow Model," in IEEE Transactions on Industry
% Applications, doi: 10.1109/TIA.2023.3287152.  
%
% Ref. M. Badoni, A. Singh and B. Singh, "Variable Forgetting Factor
% Recursive Least Square Control Algorithm for DSTATCOM," IEEE Trans. Power
% Del., vol. 30, no. 5, pp. 2353-2361, Oct. 2015.  

%% Start

% Check if lambda (forgetting factor) is provided
if nargin < 5
    lambda = 1; % Default forgetting factor
end

% Initial LS solution for Beta
Beta = (X_old' * X_old) \ (X_old' * Y_old);

% Initialize P
if initialize
    % with a large value
    Nx = size(X_old, 2);
    P = largeValue * eye(Nx);
else
% with the inverse of the covariance matrix of X_old
    P = inv(X_old' * X_old);
end

% Number of new observations
num_new_obs = size(X_new, 1);

% Interact
backspaces = '';

% Timing
tic

% Update Beta using RLS for each new observation in X_new and Y_new
for i = 1:num_new_obs
    % get the new data points
    x_i = X_new(i, :)';
    y_i = Y_new(i, :);

    % Prediction
    y_hat = x_i' * Beta;

    % Update the Gain Vector
    K = (P * x_i) / (lambda + x_i' * P * x_i);

    % Update Beta
    Beta = Beta + K * (y_i - y_hat);

    % Update P
    P = (1/lambda) * (P - K * x_i' * P);
    
    % Display progress
    pro_str = sprintf('LS_REC complete percentage: %3.1f', 100 * i / num_new_obs);
    fprintf([backspaces, pro_str]);
    backspaces = repmat(sprintf('\b'), 1, length(pro_str)); % Subtract 1 to account for the newline character
end

% Return the final Beta
time_update = toc;
Beta_final = Beta;

% Interact
fprintf('\n');
