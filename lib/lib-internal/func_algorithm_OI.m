function model = func_algorithm_OI(data, varargin)
% Outlier-Immune method based on the continuous relaxation-rounding algorithm
%
% Ref. G. Yan and Z. Li, "Construction of an Outlier-Immune Data-Driven
% Power Flow Model for Model-Absent Distribution Systems," in IEEE
% Transactions on Power Systems, vol. 39, no. 6, pp. 7449-7452, Nov. 2024,
% doi: 10.1109/TPWRS.2024.3455785.    

%% Start

% Specify the algorithm
model.algorithm = 'OI';  

% Get prepared for options, predictors, responses, and their lists, indices
[opt, X_train, X_test, Y_train, Y_test, numY, ...
 model.predictorList, model.responseList, model.predictorIdx, model.responseIdx] ... 
 = func_opts_predictor_response_singleCPU(model.algorithm, data, varargin{:});

% Train the model
[model.Beta, model.success] = func_solve_OI(X_train, Y_train, opt);

% test the result
Y_prediction = X_test * model.Beta;
error = abs(Y_prediction - Y_test) ./ abs(Y_test);

% Summarize error/y_pred/y_test/model type based on the options
[model.error, model.yPrediction, model.yTrue, model.type, model.note] ...
    = func_summarize_result(model.Beta, error, numY, Y_prediction, Y_test, opt);

% display
disp([model.algorithm, ' training & testing are done!'])