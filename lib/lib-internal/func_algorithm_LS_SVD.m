function model = func_algorithm_LS_SVD(data, varargin)
%  Training algorithm: Least squares with singular value decomposition
% 
%  Ref.: Zhentong Shao et al. “Data Based Linear Power Flow Model: Investigation of a Least-Squares
%        Based Approximation”. In: IEEE Transactions on Power Systems 36.5 (2021), pp. 4246–4258,
%  Ref.: Shao hentong et al. “Data Based Linearization: Least-Squares Based
%        Approximation”. In: arXiv preprint arXiv:2007.02494 (2020 

%% Start

% Specify the algorithm
model.algorithm = 'LS_SVD';

% Get prepared for options, predictors, responses, and their lists, indices
[opt, X_train, X_test, Y_train, Y_test, numY, ...
 model.predictorList, model.responseList, model.predictorIdx, model.responseIdx] ... 
 = func_opts_predictor_response_singleCPU(model.algorithm, data, varargin{:});

% Define auxiliary matrices A and B: A = X'X and B = X'Y
A = X_train' * X_train;
B = X_train' * Y_train;

% Perform singular value decomposition for A = X'X
% inv(A) =  V * inv(S) * U';
[U, S, V] = svd(A);

% Obtain the regression model Beta 
model.Beta = (V * (S \ U')) * B;
% result.Beta = (V * inv(S) * U') * B; % The result is slightly different, because of numerical error

% test the result
Y_prediction = X_test * model.Beta;
error = abs(Y_prediction - Y_test) ./ abs(Y_test);

% Record the det of S
model.det_S = det(S);

% Summarize error/y_pred/y_test/model type based on the options
[model.error, model.yPrediction, model.yTrue, model.type, model.note] ...
    = func_summarize_result(model.Beta, error, numY, Y_prediction, Y_test, opt);

% display
disp([model.algorithm, ' training & testing are done!'])