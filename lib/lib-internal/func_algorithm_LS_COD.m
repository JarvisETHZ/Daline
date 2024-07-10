function model = func_algorithm_LS_COD(data, varargin)
%  Training algorithm: Least squares with complete orthogonal decomposition
%
%  Ref.: Z. Shao, Q. Zhai, J. Wu, and X. Guan, “Data based linear power 
%  flow model: Investigation of a least-squares based approximation,” 
%  IEEE Transactions on Power Systems, vol. 36, no. 5, pp. 4246–4258, 2021.

%% Start

% Specify the algorithm
model.algorithm = 'LS_COD';

% Get prepared for options, predictors, responses, and their lists, indices
[opt, X_train, X_test, Y_train, Y_test, numY, ...
 model.predictorList, model.responseList, model.predictorIdx, model.responseIdx] ... 
 = func_opts_predictor_response_singleCPU(model.algorithm, data, varargin{:});

% Define auxiliary matrices A and B: A = X'X and B = X'Y
A = X_train' * X_train;
B = X_train' * Y_train;

% Perform complete orthogonal decomposition for A = X'X
[Q, R, ZT] = func_fit_cod(A);  % ZT here represent Z' in the paper

% Obtain the regression model Beta
num_temp_row = size(A, 1) - size(R, 1);
num_temp_col = size(A, 2) - size(R, 2);
augmented_R_inv = blkdiag(inv(R), zeros(num_temp_row, num_temp_col));
model.Beta = ZT' * augmented_R_inv * Q' * B;

% test the result
Y_prediction = X_test * model.Beta;
error = abs(Y_prediction - Y_test) ./ abs(Y_test);

% Summarize error/y_pred/y_test/model type based on the options
[model.error, model.yPrediction, model.yTrue, model.type, model.note] ...
    = func_summarize_result(model.Beta, error, numY, Y_prediction, Y_test, opt);

% display
disp([model.algorithm, ' training & testing are done!'])