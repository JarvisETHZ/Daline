function model = func_algorithm_PCA(data, varargin)
%  Training algorithm: directly use principal component analysis to get
%  Beta = PCA(X)\Y, i.e., PCA plus QR decomposition

%% Start

% Specify the algorithm
model.algorithm = 'PCA';

% Get prepared for options, predictors, responses, and their lists, indices
[opt, X_train, X_test, Y_train, Y_test, numY, ...
 model.predictorList, model.responseList, model.predictorIdx, model.responseIdx] ... 
 = func_opts_predictor_response_multiCPU(model.algorithm, data, varargin{:});

% Determine the best number of components of PCA according to user
% settings, e.g., rank, given value, or cross-validation for tuning
Np = func_determine_PCA_numComponent(X_train, Y_train, opt);
model.Np = Np;

% Principal component analysis for X_train; no dimension reduction here
D0 = pca(X_train);
D  = D0(:, 1:Np);

% Obtain the regression model Beta_PCA
Beta_PCA = (X_train * D) \ Y_train;

% Obtain the regression model Beta
model.Beta = D * Beta_PCA;

% test the result
Y_prediction = X_test * model.Beta;
error = abs(Y_prediction - Y_test) ./ abs(Y_test);

% Summarize error/y_pred/y_test/model type based on the options
[model.error, model.yPrediction, model.yTrue, model.type, model.note] ...
    = func_summarize_result(model.Beta, error, numY, Y_prediction, Y_test, opt);

% display
disp([model.algorithm, ' training & testing are done!'])