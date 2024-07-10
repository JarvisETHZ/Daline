function result = func_algorithm_DRCC_randX_divergence(X, Y, opt)
% Distributionally robust chance-constrained
% programming, only consider X as random variable
%
% Note: 
%
% Very very slow!
%
% For random datasets, the approach is awful, and the errors are huge.
% For time series datasets, the accuracy is okay, but much less accurate
% than, e.g., PLS with SIMPLS. The reason is that this approach only aims
% to train a model around the chosen operating point.  Also, the error
% tends to be larger when the testing points are far away from the chosen
% point.   
%
% Haven't consider the randomness of Y, but use Y^star in the constraint.
%
%
% Ref. Y. Liu, Z. Li and J. Zhao, "Robust Data-Driven Linear Power Flow 
% Model With Probability Constrained Worst-Case Errors," in IEEE 
% Transactions on Power Systems, vol. 37, no. 5, pp. 4113-4116, Sept. 2022, 
% doi: 10.1109/TPWRS.2022.3189543.

%% Start

% Specify the algorithm
result.algorithm = 'DRCC_randX';  

% specify input and output
X_train = X.train.all;
eval(['Y_train = Y.train.', opt.DRC.target, ';'])
X_test = X.test.all;
eval(['Y_test = Y.test.', opt.DRC.target, ';'])

% Get numbers
Ny = size(Y_train, 2); % Number of responses in Y
Nx = size(X_train, 2); % Number of predictors in X

% Define containers
result.Beta = zeros(Nx, Ny);
result.success = zeros(1, Ny);

% Interact
backspaces = '';

% Train the model for the selected responses in a total manner
% [result.Beta, result.success] = func_solve_DRCC_randX(X_train, Y_train, opt);

% Train the model for the selected responses individually
for j = 1 : Ny
    % Training
    [result.Beta(:, j), result.success(j)] = func_solve_DRCC_randX(X_train, Y_train(:, j), opt);
    % Display progress
    pro_str = sprintf('DRCC_randX complete percentage: %3.1f', 100 * j / Ny);
    fprintf([backspaces, pro_str]);
    backspaces = repmat(sprintf('\b'), 1, length(pro_str)); % Subtract 1 to account for the newline character
end

% Test if the program has been solved successfully
if mean(result.success) == 1
    % test the result
    Y_prediction = X_test * result.Beta;
    error = abs(Y_prediction - Y_test) ./ abs(Y_test);
    eval(['result.error.', opt.DRC.target, ' = error;'])
    
    % display
    fprintf('\n');
    disp([result.algorithm, ' training/testing is done!'])
else
    % test the result
    Y_prediction = X_test * result.Beta;
    error = abs(Y_prediction - Y_test) ./ abs(Y_test);
    eval(['result.error.', opt.DRC.target, ' = error;'])
    
    % display
    fprintf('\n');
    disp([result.algorithm, ' failed!'])
end

