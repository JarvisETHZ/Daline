function model = func_algorithm_RR_KPC(data, varargin)
% func_algorithm_RR_Kplane: ordinary ridge regression with k-plane clustering
%
% Ref. J. Chen, W. Wu, and L. A. Roald, “Data-driven piecewise 
% linearization for distribution three-phase stochastic power flow,” 
% IEEE Transactions on Smart Grid, 2021.

%% Start

% Specify the algorithm
model.algorithm = 'RR_KPC';

% Get prepared for options, predictors, responses, and their lists, indices
% X_train and X_test do have intercept, just like the ref. paper did.
% Although this means that we add penalty to the constant term as well,
% which might be inappropriate. Yet, to exactly reproduce what the ref.
% paper did, we accept it. But you are welcome to modify it!
[opt, X_train, X_test, Y_train, Y_test, numY, ...
 model.predictorList, model.responseList, model.predictorIdx, model.responseIdx] ... 
 = func_opts_predictor_response_singleCPU(model.algorithm, data, varargin{:});

% Tune hyperparameters
[cluster, lambda, eta] = func_tune_RR_KP(X_train, Y_train, opt);

% Train the model with the tuned hyperparameters
[model.Beta, model.center, model.success] = func_RR_kPlane(X_train, Y_train, cluster, eta, lambda, opt.RR.kplaneMaxIter, opt.RR.fixKmeans, opt.RR.fixSeed);

% Test the model
[error, Y_prediction] = func_test_piecewise(X_test, Y_test, model);

% Summarize error/y_pred/y_test/model type based on the options
[model.error, model.yPrediction, model.yTrue, model.type, model.note] ...
    = func_summarize_result(model.Beta, error, numY, Y_prediction, Y_test, opt);

% display
disp([model.algorithm, ' training & testing are done!'])