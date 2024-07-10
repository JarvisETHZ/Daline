function model = func_algorithm_RR_WEI(data, varargin)
% func_algorithm_RR: Locally weighted ridge regression
%
% Ref. J. Zhang, Z. Wang, X. Zheng, L. Guan, and C. Chung, “Locally 
% weighted ridge regression for power system online sensitivity 
% identification considering data collinearity,” IEEE Transactions on 
% Power Systems, vol. 33, no. 2, pp. 1624–1634, 2017.

%% Start

% Specify the algorithm
model.algorithm = 'RR_WEI';

% Get prepared for options, predictors, responses, and their lists, indices
[opt, X_train, X_test, Y_train, Y_test, numY, ...
 model.predictorList, model.responseList, model.predictorIdx, model.responseIdx] ... 
 = func_opts_predictor_response_singleCPU(model.algorithm, data, varargin{:});

% Remove the intercept just like the ref. paper did, i.e., no intercept
X_train(:, 1) = [];
X_test(:, 1)  = [];

% get numbers
num_tau = length(opt.RR.tauInterval);
num_X_var = size(X_train, 2);

% error container for tuning
error_temp = zeros(num_tau, 1);
lambda_temp = zeros(num_tau, 1);

% Interact
backspaces = '';

% tune tau & lambda. Note: very time consuming
for n = 1:num_tau
    % select a value of tau
    tau = opt.RR.tauInterval(n);
    % generate the weight
    W = func_generate_localWeight(X_train, tau);
    % use cross-validation to tune and get the best lambda
    [lambda_temp(n), error_temp(n)] = func_tune_RR(X_train, Y_train, W, opt, 0);
    % Display progress
    pro_str = sprintf('Locally weighted ridge regression tuning complete percentage: %3.1f', 100 * n / num_tau);
    fprintf([backspaces, pro_str]);
    backspaces = repmat(sprintf('\b'), 1, length(pro_str)); % Subtract 1 to account for the newline character
end
lambda_tuned = lambda_temp(min(error_temp) == error_temp);
tau_tuned = opt.RR.tauInterval(min(error_temp) == error_temp);
W_tuned = func_generate_localWeight(X_train, tau_tuned);
fprintf('\n');

% Retrain the model using the tuned hyperparameters
model.Beta = (X_train' * W_tuned * X_train + lambda_tuned * eye(num_X_var)) \ (X_train' * W_tuned * Y_train);

% test the result
Y_prediction = X_test * model.Beta;
error = abs(Y_prediction - Y_test) ./ abs(Y_test);

% Summarize error/y_pred/y_test/model type based on the options
[model.error, model.yPrediction, model.yTrue, model.type, model.note] ...
    = func_summarize_result(model.Beta, error, numY, Y_prediction, Y_test, opt);

% display
disp([model.algorithm, ' training & testing are done!'])