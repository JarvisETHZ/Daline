function model = func_algorithm_SVD(data, varargin)
%  Training algorithm: dirtec use SVD to get Beta = SVD(X)\Y, no least
%  squares anymore (i.e., no X'X\X'Y) 

%% Start

% Specify the algorithm
model.algorithm = 'SVD';

% Get prepared for options, predictors, responses, and their lists, indices
[opt, X_train, X_test, Y_train, Y_test, numY, ...
 model.predictorList, model.responseList, model.predictorIdx, model.responseIdx] ... 
 = func_opts_predictor_response_singleCPU(model.algorithm, data, varargin{:});

% Perform singular value decomposition for X_train = U * S * V'
[U, S, V] = svd(X_train);

% Obtain the regression model Beta 
model.Beta = (U * S * V') \ Y_train;

% test the result
Y_prediction = X_test * model.Beta;
error = abs(Y_prediction - Y_test) ./ abs(Y_test);

% Summarize error/y_pred/y_test/model type based on the options
[model.error, model.yPrediction, model.yTrue, model.type, model.note] ...
    = func_summarize_result(model.Beta, error, numY, Y_prediction, Y_test, opt);

% display
disp([model.algorithm, ' training & testing are done!'])