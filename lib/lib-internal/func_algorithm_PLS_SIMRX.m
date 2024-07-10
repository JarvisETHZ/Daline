function model = func_algorithm_PLS_SIMRX(data, varargin)
%  Training algorithm: ordinary partial least squares, solved by SIMPLS.
%  The number of component is set as the rank of X_train, which should be a
%  common choice, but ends up with not very good result. As a comparison
%  with func_algorithm_PLS_SIM. 

%% Start

% Specify the algorithm
model.algorithm = 'PLS_SIMRX';

% Get prepared for options, predictors, responses, and their lists, indices
[opt, X_train, X_test, Y_train, Y_test, numY, ...
 model.predictorList, model.responseList, model.predictorIdx, model.responseIdx] ... 
 = func_opts_predictor_response_singleCPU(model.algorithm, data, varargin{:});

% We remove the all-one column in X_train manually
X_train(:, 1) = [];    

% train the result
[~, ~, ~, ~, model.Beta ] = plsregress(X_train, Y_train, rank(X_train)); 

% test the result
Y_prediction = X_test * model.Beta;
error = abs(Y_prediction - Y_test) ./ abs(Y_test);

% Summarize error/y_pred/y_test/model type based on the options
[model.error, model.yPrediction, model.yTrue, model.type, model.note] ...
    = func_summarize_result(model.Beta, error, numY, Y_prediction, Y_test, opt);

% display
disp([model.algorithm, ' training & testing are done!'])