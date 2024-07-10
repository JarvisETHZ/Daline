function model = func_algorithm_COD(data, varargin)
%  Training algorithm: directly use complete orthogonal

%% Start

% Specify the algorithm
model.algorithm = 'COD';

% Get prepared for options, predictors, responses, and their lists, indices
[opt, X_train, X_test, Y_train, Y_test, numY, ...
 model.predictorList, model.responseList, model.predictorIdx, model.responseIdx] ... 
 = func_opts_predictor_response_singleCPU(model.algorithm, data, varargin{:});

% Perform complete orthogonal decomposition for X
[Q, R, ZT] = func_fit_cod(X_train);          

% Obtain the regression model Beta; again use left divide (QR)
num_temp_row = size(X_train, 1) - size(R, 1);
num_temp_col = size(X_train, 2) - size(R, 2);
augmented_R = blkdiag(R, zeros(num_temp_row, num_temp_col));
model.Beta = (Q * augmented_R * ZT) \ Y_train;

% We can also obtain the regression model by inverse; the result
% would be extremely similar, but worse than left divide
% augmented_R_inv = blkdiag(inv(R), zeros(num_temp_col, num_temp_row));
% result.Beta = (ZT' * augmented_R_inv * Q') * Y_train;

% test the result
Y_prediction = X_test * model.Beta;
error = abs(Y_prediction - Y_test) ./ abs(Y_test);

% Summarize error/y_pred/y_test/model type based on the options
[model.error, model.yPrediction, model.yTrue, model.type, model.note] ...
    = func_summarize_result(model.Beta, error, numY, Y_prediction, Y_test, opt);

% display
disp([model.algorithm, ' training & testing are done!'])

% Compare the approach with built in functions decomposition
% dX = decomposition(X_train, 'cod');
% Beta = dX \ Y_train;
% Y_prediction = X_test * Beta;
% error_test1 = abs(Y_prediction - Y_test) ./ abs(Y_test);
% max(max(abs(error-error_test1)))

% Compare the approach with built in functions lsqminnorm
% Beta = lsqminnorm(X_train, Y_train);
% Y_prediction = X_test * Beta;
% error_test2 = abs(Y_prediction - Y_test) ./ abs(Y_test);
% max(max(abs(error-error_test2)))