function model = func_algorithm_PLS_NIP(data, varargin)
%  Training algorithm: Ordinary partial least squares, solved by NIPALS

%% Start

% Specify the algorithm
model.algorithm = 'PLS_NIP';

% Get prepared for options, predictors, responses, and their lists, indices
[opt, X_train, X_test, Y_train, Y_test, numY, ...
 model.predictorList, model.responseList, model.predictorIdx, model.responseIdx] ... 
 = func_opts_predictor_response_singleCPU(model.algorithm, data, varargin{:});

% train the regression model (Automatically, the number of components will be extremely close to the rank of X_train)
[~, ~, ~, ~, ~, ~, model.Beta] = func_pls_NIPALS(X_train, Y_train, opt);

% test the result (here we only test the error of the final Beta, as comparison with other methods)
Y_prediction = X_test * model.Beta;
error = abs(Y_prediction - Y_test) ./ abs(Y_test);

% Summarize error/y_pred/y_test/model type based on the options
[model.error, model.yPrediction, model.yTrue, model.type, model.note] ...
    = func_summarize_result(model.Beta, error, numY, Y_prediction, Y_test, opt);

% display
disp([model.algorithm, ' training & testing are done!'])