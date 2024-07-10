function model = func_algorithm_RR(data, varargin)
% func_algorithm_RR: ordinary ridge regression
% 
% Ref. Y. Chen, C. Wu, and J. Qi, “Data-driven power flow method based on 
% exact linear regression equations,” Journal of Modern Power Systems and 
% Clean Energy, 2021.

%% Start

% Specify the algorithm
model.algorithm = 'RR';

% Get prepared for options, predictors, responses, and their lists, indices
[opt, X_train, X_test, Y_train, Y_test, numY, ...
 model.predictorList, model.responseList, model.predictorIdx, model.responseIdx] ... 
 = func_opts_predictor_response_singleCPU(model.algorithm, data, varargin{:});

% Remove the intercept just like the ref. paper did, i.e., no intercept
X_train(:, 1) = [];
X_test(:, 1)  = [];

% get numbers
[num_sample, num_X_var] = size(X_train);

% Tune lambda using cross-validation
W = eye(num_sample);  % No weights
[lambda, ~] = func_tune_RR(X_train, Y_train, W, opt, 1);

% train the result
model.Beta = (X_train' * W * X_train + lambda * eye(num_X_var)) \ (X_train' * Y_train);

% test the result
Y_prediction = X_test * model.Beta;
error = abs(Y_prediction - Y_test) ./ abs(Y_test);

% Summarize error/y_pred/y_test/model type based on the options
[model.error, model.yPrediction, model.yTrue, model.type, model.note] ...
    = func_summarize_result(model.Beta, error, numY, Y_prediction, Y_test, opt);

% display
disp([model.algorithm, ' training & testing are done!'])