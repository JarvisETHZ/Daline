function model = func_algorithm_PLS_RECW(data, varargin)
%  Training algorithm: Recursive partial least squares, based on NIPALS,
%  using weight for the update
%
%  Ref.:
%   S. Nowak, Y. C. Chen, and L. Wang, “Measurement-based optimal der 
%   dispatch with a recursively estimated sensitivity model,” IEEE 
%   Transactions on Power Systems, vol. 35, no. 6, pp. 4792–4802, 2020.
%
%   Qin, S.J., 1998. Recursive PLS algorithms for adaptive data modeling. 
%   Computers & Chemical Engineering, 22(4-5), pp.503-514.

%% Start

% Specify the algorithm
model.algorithm = 'PLS_RECW';

% Get prepared for options, predictors, responses, and their lists, indices
[opt, X_train, X_test, Y_train, Y_test, numY, ...
 model.predictorList, model.responseList, model.predictorIdx, model.responseIdx] ... 
 = func_opts_predictor_response_singleCPU(model.algorithm, data, varargin{:});

% Get numbers
[num_sample, ~] = size(X_train);
percentage = opt.PLS.recursivePercentage;
num_new = round(num_sample * percentage / 100);
num_old = num_sample - num_new;

% Separate the training dataset into old and new parts
X_train_old = X_train(1:num_old, :);
Y_train_old = Y_train(1:num_old, :);
X_train_new = X_train(num_old+1:end, :);
Y_train_new = Y_train(num_old+1:end, :);

% Interact
backspaces = '';

% Record time
tic

% Get the initial (old) score and loading matrices, and Gamma
[~, C, ~, R, gamma, ~, Beta] = func_pls_NIPALS(X_train_old, Y_train_old, opt);

% Recursively training to include each new data point
for n = 1:num_new
    % Form the new info by taking one new data point
    X_recursive = [opt.PLS.omega * C'; X_train_new(n, :)];
    Y_recursive = [opt.PLS.omega * gamma * R'; Y_train_new(n, :)];
    % Re-decompose to get new C, R, T, U
    [~, C, ~, R, gamma, ~, Beta] = func_pls_NIPALS(X_recursive, Y_recursive, opt);
    % Display progress
    backspaces = func_display_progress(model.algorithm, backspaces, 100 * n / num_new);
end
fprintf('\n');

% Get the final Beta result
model.Beta = Beta;

% Record time
model.trainTime = toc;

% Test the final Beta result
[~, ~, ~, ~, ~, ~, Beta_test] = func_pls_NIPALS(X_train, Y_train, opt);
model.Beta_test = Beta_test;

% test the result
Y_prediction = X_test * model.Beta;
error = abs(Y_prediction - Y_test) ./ abs(Y_test);

% Summarize error/y_pred/y_test/model type based on the options
[model.error, model.yPrediction, model.yTrue, model.type, model.note] ...
    = func_summarize_result(model.Beta, error, numY, Y_prediction, Y_test, opt);

% display
disp([model.algorithm, ' training & testing are done!'])