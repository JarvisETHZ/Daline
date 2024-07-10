function model = func_algorithm_LS_WEI(data, varargin)
% Solve the least squares problem using programming, without weights
%
% Ref. H. Xu, A. D. Dom ́ınguez-Garc ́ıa, V. V. Veeravalli, and P. W.
% Sauer, “Data-driven voltage regulation in radial power distribution
% systems,” IEEE Transactions on Power Systems, vol. 35, no. 3, pp.
% 2133–2143,   

%% Start

% Specify the algorithm
model.algorithm = 'LS_WEI';

% Get prepared for options, predictors, responses, and their lists, indices
% Here func_opts_predictor_response_multiCPU is used, because LS_WEI
% supports parallel computing for yalmip plus indivi
[opt, X_train, X_test, Y_train, Y_test, numY, ...
 model.predictorList, model.responseList, model.predictorIdx, model.responseIdx] ... 
 = func_opts_predictor_response_multiCPU(model.algorithm, data, varargin{:});

% train the result
[model.Beta, model.success] = func_solve_LS_Weight(X_train, Y_train, opt);

% test the result
Y_prediction = X_test * model.Beta;
error = abs(Y_prediction - Y_test) ./ abs(Y_test);

% Summarize error/y_pred/y_test/model type based on the options
[model.error, model.yPrediction, model.yTrue, model.type, model.note] ...
    = func_summarize_result(model.Beta, error, numY, Y_prediction, Y_test, opt);

% display
disp([model.algorithm, ' training & testing are done!'])
