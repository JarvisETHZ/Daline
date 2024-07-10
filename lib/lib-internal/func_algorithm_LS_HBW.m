function model = func_algorithm_LS_HBW(data, varargin)
%  Training algorithm: ordinary least squares with Huber weighting function

%% Start

% Specify the algorithm
model.algorithm = 'LS_HBW';   % Huber weighting

% Get prepared for options, predictors, responses, and their lists, indices
[opt, X_train, X_test, Y_train, Y_test, numY, ...
 model.predictorList, model.responseList, model.predictorIdx, model.responseIdx] ... 
 = func_opts_predictor_response_multiCPU(model.algorithm, data, varargin{:});

% PCA decomposition (if requested)
if opt.HBW.PCA
    [X_train, D] = func_decompose_PCA(X_train, opt.HBW.numComponentRatio);
else
    D = eye(size(X_train, 2)); 
end

% Tuning the tuning constant
model.const = func_determine_Hbw_const(X_train, Y_train, D, model.algorithm, opt);

% Train the model
model.Beta = func_solve_Hbw(X_train, Y_train, D, opt.HBW.parallel, model.const, model.algorithm);

% test the result; similar to PLS
Y_prediction = X_test * model.Beta;
error = abs(Y_prediction - Y_test) ./ abs(Y_test);

% Summarize error/y_pred/y_test/model type based on the options
[model.error, model.yPrediction, model.yTrue, model.type, model.note] ...
    = func_summarize_result(model.Beta, error, numY, Y_prediction, Y_test, opt);

% display
disp([model.algorithm, ' training & testing are done!'])