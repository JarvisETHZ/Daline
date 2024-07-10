function model = func_algorithm_LS_CLS(data, varargin)
% func_algorithm_LS_cluster - Perform piecewise linear regression using
% K-means clustering and OLS

%% Start

% Specify the algorithm
model.algorithm = 'LS_CLS';

% Get prepared for options, predictors, responses, and their lists, indices
[opt, X_train, X_test, Y_train, Y_test, numY, ...
 model.predictorList, model.responseList, model.predictorIdx, model.responseIdx] ... 
 = func_opts_predictor_response_multiCPU(model.algorithm, data, varargin{:});

% Tune the number of clusters
if opt.LSC.parallel
    cluster = func_tune_LS_cluster_parallel(X_train, Y_train, opt);
else
    cluster = func_tune_LS_cluster(X_train, Y_train, opt);
end

% Perform K-means clustering on X_train using the tuned number of clusters
if opt.LSC.fixKmeans
    rng(opt.LSC.fixSeed)   % fix the random number used in kmeans so that the clustering result will stay the same for the same dataset
end
[idx, model.center] = kmeans(X_train, cluster);

% Initialize Beta and det cell array
model.Beta = cell(cluster, 1);
model.det = cell(cluster, 1);

% Perform ordinary least squares regression for each cluster
for k = 1:cluster
    clusterIdx = idx == k;
    X_cluster = X_train(clusterIdx, :);
    Y_cluster = Y_train(clusterIdx, :);
    model.Beta{k} = (X_cluster' * X_cluster) \ (X_cluster' * Y_cluster);
    model.det{k} = det(X_cluster' * X_cluster);
end

% Test the model
[error, Y_prediction] = func_test_piecewise(X_test, Y_test, model);

% Summarize error/y_pred/y_test/model type based on the options
[model.error, model.yPrediction, model.yTrue, model.type, model.note] ...
    = func_summarize_result(model.Beta, error, numY, Y_prediction, Y_test, opt);

% display
disp([model.algorithm, ' training & testing are done!'])