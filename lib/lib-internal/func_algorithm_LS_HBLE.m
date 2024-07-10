function model = func_algorithm_LS_HBLE(data, varargin)
%% Introduction
%  Training algorithm: ordinary least squares with Huber loss function
%
%  Ref.: Y. Liu, Z. Li, and Y. Zhou, “Data-driven-aided linear three-phase 
%  power flow model for distribution power systems,” IEEE Transactions on 
%  Power Systems, 2021.

%% Start

% Specify the algorithm
model.algorithm = 'LS_HBLE';   % Huber loss function

% Get prepared for options, predictors, responses, and their lists, indices
[opt, X_train, X_test, Y_train, Y_test, numY, ...
 model.predictorList, model.responseList, model.predictorIdx, model.responseIdx] ... 
 = func_opts_predictor_response_multiCPU(model.algorithm, data, varargin{:});

% Tune delta to find the best value
opt.HBL.delta = func_determine_Hbl_equal_const(X_train, Y_train, opt);
model.delta = opt.HBL.delta;

% Solve the problem 
[model.Beta, model.success] = func_solve_LS_Hbl(X_train, Y_train, opt);

% test the result; similar to PLS
Y_prediction = X_test * model.Beta;
error = abs(Y_prediction - Y_test) ./ abs(Y_test);

% Summarize error/y_pred/y_test/model type based on the options
[model.error, model.yPrediction, model.yTrue, model.type, model.note] ...
    = func_summarize_result(model.Beta, error, numY, Y_prediction, Y_test, opt);

% display
disp([model.algorithm, ' training & testing are done!'])