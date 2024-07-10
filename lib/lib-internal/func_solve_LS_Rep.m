function [Beta_final, time_update] = func_solve_LS_Rep(X_old, Y_old, X_new, Y_new)
% Repeated least squares
%
% Ref. Y. Liu, Z. Li and S. Sun, "A Data-Driven Method for Online
% Constructing Linear Power Flow Model," in IEEE Transactions on Industry
% Applications, doi: 10.1109/TIA.2023.3287152.  
%
% Ref. M. Badoni, A. Singh and B. Singh, "Variable Forgetting Factor
% Recursive Least Square Control Algorithm for DSTATCOM," IEEE Trans. Power
% Del., vol. 30, no. 5, pp. 2353-2361, Oct. 2015.  

%% Start

% Initial LS solution for Beta
Beta = (X_old' * X_old) \ (X_old' * Y_old);

% Number of new observations
num_new_obs = size(X_new, 1);

% Interact
backspaces = '';

% Timing
tic

% Update Beta using RLS for each new observation in X_new and Y_new
for i = 1:num_new_obs
    
    % get the new data points
    X_old = [X_old; X_new(i, :)];
    Y_old = [Y_old; Y_new(i, :)];

    % Update Beta
    Beta = (X_old' * X_old) \ (X_old' * Y_old);

    % Display progress
    pro_str = sprintf('LS_Rep complete percentage: %3.1f', 100 * i / num_new_obs);
    fprintf([backspaces, pro_str]);
    backspaces = repmat(sprintf('\b'), 1, length(pro_str)); % Subtract 1 to account for the newline character
end

% Return the final Beta
time_update = toc;
Beta_final = Beta;

% Interact
fprintf('\n');
