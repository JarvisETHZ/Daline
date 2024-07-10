function model = func_algorithm_DRC_XM(data, varargin)
% Distributionally robust chance-constrained
% programming, only consider X as random variable, moment-based
% ambiguity set
%
% Very slow! Try DRC_XYD
%
% Ref. Y. Liu, Z. Li and J. Zhao, "Robust Data-Driven Linear Power Flow 
% Model With Probability Constrained Worst-Case Errors," in IEEE 
% Transactions on Power Systems, vol. 37, no. 5, pp. 4113-4116, Sept. 2022, 
% doi: 10.1109/TPWRS.2022.3189543.

%% Start

% Specify the algorithm
model.algorithm = 'DRC_XM';  

% Get prepared for options, predictors, responses, and their lists, indices
[opt, X_train, X_test, Y_train, Y_test, numY, ...
 model.predictorList, model.responseList, model.predictorIdx, model.responseIdx] ... 
 = func_opts_predictor_response_multiCPU(model.algorithm, data, varargin{:});

% Train the model
[model.Beta, model.success] = func_solve_DRCC_randX_moment(X_train, Y_train, opt);

% test the result
Y_prediction = X_test * model.Beta;
error = abs(Y_prediction - Y_test) ./ abs(Y_test);

% Summarize error/y_pred/y_test/model type based on the options
[model.error, model.yPrediction, model.yTrue, model.type, model.note] ...
    = func_summarize_result(model.Beta, error, numY, Y_prediction, Y_test, opt);

% display
disp([model.algorithm, ' training & testing are done!'])