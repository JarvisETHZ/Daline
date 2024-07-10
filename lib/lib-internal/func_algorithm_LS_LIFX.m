function model = func_algorithm_LS_LIFX(data, varargin)
%  Training algorithm: ordinary least squares with lifting dimension and
%  Moore-Penrose inverse (collinearity). 
%
% Ref. L. Guo, Y. Zhang, X. Li, Z. Wang, Y. Liu, L. Bai, and C. Wang,
% “Data-driven power flow calculation method: A lifting dimension linear
% regression approach,” IEEE Transactions on Power Systems, 2021. 
%
% Korda, M. and Mezić, I., 2018. Linear predictors for nonlinear dynamical
% systems: Koopman operator meets model predictive control. Automatica,
% 93, pp.149-160. open source code https://github.com/MilanKorda/KoopmanMPC/raw/master/KoopmanMPC.zip

%% Start

% Specify the algorithm
model.algorithm = 'LS_LIFX';

% Get prepared for options, predictors, responses, and their lists, indices
[opt, X_train, X_test, Y_train, Y_test, numY, ...
 model.predictorList, model.responseList, model.predictorIdx, model.responseIdx] ... 
 = func_opts_predictor_response_singleCPU(model.algorithm, data, varargin{:});

% train the result
model.Beta = pinv(X_train' * X_train) * X_train' * Y_train;

% test the result
Y_prediction = X_test * model.Beta;
error = abs(Y_prediction - Y_test) ./ abs(Y_test);

% Record the det of XTX
model.det_XTX = det(X_train' * X_train);

% Summarize error/y_pred/y_test/model type based on the options
[model.error, model.yPrediction, model.yTrue, model.type, model.note] ...
    = func_summarize_result(model.Beta, error, numY, Y_prediction, Y_test, opt);

% display
disp([model.algorithm, ' training & testing are done!'])