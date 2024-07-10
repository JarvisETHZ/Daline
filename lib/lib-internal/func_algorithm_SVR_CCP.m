function model = func_algorithm_SVR_CCP(data, varargin)
% func_algorithm_SVR - Perform linear regression using the ordinary Support
% Vector Regression (SVR) using chance-constrained programming
%
% Ref. Z. Shao, Q. Zhai, Z. Han, and X. Guan, “A linear ac unit commitment 
% formulation: An application of data-driven linear power flow model,” 
% International Journal of Electrical Power & Energy Systems, vol. 145, p. 108673, 2023.

%% Start

% Specify the algorithm
model.algorithm = 'SVR_CCP';

% Get prepared for options, predictors, responses, and their lists, indices
[opt, X_train, X_test, Y_train, Y_test, numY, ...
 model.predictorList, model.responseList, model.predictorIdx, model.responseIdx] ... 
 = func_opts_predictor_response_multiCPU(model.algorithm, data, varargin{:});

% Train the model using chance-constrained programming for SVR
[model.Beta, model.success] = func_solve_SVR_CC(X_train, Y_train, opt);

% test the result
Y_prediction = X_test * model.Beta;
error = abs(Y_prediction - Y_test) ./ abs(Y_test);

% Summarize error/y_pred/y_test/model type based on the options
[model.error, model.yPrediction, model.yTrue, model.type, model.note] ...
    = func_summarize_result(model.Beta, error, numY, Y_prediction, Y_test, opt);

% display
disp([model.algorithm, ' training & testing are done!'])
