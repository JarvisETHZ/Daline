function model = func_algorithm_LS_HBLD(data, varargin)
%% Introduction
%  Training algorithm: ordinary least squares with Huber loss function
%
%  Ref.: Y. Liu, Z. Li, and Y. Zhou, “Data-driven-aided linear three-phase 
%  power flow model for distribution power systems,” IEEE Transactions on 
%  Power Systems, 2021.

%% Define the function

% Specify the algorithm
model.algorithm = 'LS_HBLD';   % Huber loss function

% Get prepared for options, predictors, responses, and their lists, indices
[opt, X_train, X_test, Y_train, Y_test, numY, ...
 model.predictorList, model.responseList, model.predictorIdx, model.responseIdx] ... 
 = func_opts_predictor_response_multiCPU(model.algorithm, data, varargin{:});

% Tune the best delta
model.delta = func_determine_Hbl_direct_const(X_train, Y_train, model.algorithm, opt);

% Training
[model.Beta, model.exitflag] = func_solve_Hbl_direct(X_train, Y_train, opt.HBL.parallel, model.delta, opt.HBL.initialGuess, opt.HBL.directOptions, model.algorithm);

% test the result; similar to PLS
Y_prediction = X_test * model.Beta;
error = abs(Y_prediction - Y_test) ./ abs(Y_test);

% Summarize error/y_pred/y_test/model type based on the options
[model.error, model.yPrediction, model.yTrue, model.type, model.note] ...
    = func_summarize_result(model.Beta, error, numY, Y_prediction, Y_test, opt);

% display
disp([model.algorithm, ' training & testing are done!'])