function model = func_algorithm_SVR_RR(data, varargin)
% func_algorithm_SVR - Perform linear regression using the ordinary Support
% Vector Regression (SVR) with linear kernel, combined with ridge
% regression. PCA is used here to reduce the collinearity as well,
% according to the reference paper. 
%
%  Ref.: P. Li, W. Wu, X. Wan, and B. Xu, “A data-driven linear optimal 
%  power flow model for distribution networks,” IEEE Transactions on Power 
%  Systems, 2022.


%% Start

% Specify the algorithm
model.algorithm = 'SVR_RR';

% Get prepared for options, predictors, responses, and their lists, indices
[opt, X_train, X_test, Y_train, Y_test, numY, ...
 model.predictorList, model.responseList, model.predictorIdx, model.responseIdx] ... 
 = func_opts_predictor_response_multiCPU(model.algorithm, data, varargin{:});

% PCA decomposition (if requested)
if opt.SVR.PCA
    [X_train, D] = func_decompose_PCA(X_train, opt.SVR.numComponentRatio);
else
    D = eye(size(X_train, 2));
end

% train the result
[model.Beta, model.success] = func_solve_SVR_RR(X_train, Y_train, opt);

% test the result
model.Beta = D * model.Beta;
Y_prediction = X_test * model.Beta;
error = abs(Y_prediction - Y_test) ./ abs(Y_test);

% Summarize error/y_pred/y_test/model type based on the options
[model.error, model.yPrediction, model.yTrue, model.type, model.note] ...
    = func_summarize_result(model.Beta, error, numY, Y_prediction, Y_test, opt);

% display
disp([model.algorithm, ' training & testing are done!'])
