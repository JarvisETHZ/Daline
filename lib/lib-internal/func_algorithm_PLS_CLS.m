function model = func_algorithm_PLS_CLS(data, varargin)
% func_algorithm_PLS_cluster - Perform piecewise linear regression using
% K-means clustering and PLS. 

%% Start

% Specify the algorithm
model.algorithm = 'PLS_CLS';

% Get prepared for options, predictors, responses, and their lists, indices
[opt, X_train, X_test, Y_train, Y_test, numY, ...
 model.predictorList, model.responseList, model.predictorIdx, model.responseIdx] ... 
 = func_opts_predictor_response_multiCPU(model.algorithm, data, varargin{:});

% We remove the all-one column in X_train manually
X_train(:, 1) = [];

% Tune the number of clusters if requested
if length(opt.PLS.clusNumInterval)>1
    if opt.PLS.parallel
        cluster = func_tune_PLS_cluster_parallel(X_train, Y_train, opt);
    else
        cluster = func_tune_PLS_cluster(X_train, Y_train, opt);
    end
else
    cluster = opt.PLS.clusNumInterval;
end

% Perform K-means clustering on X_train using the tuned number of clusters
if opt.PLS.fixKmeans
    rng(opt.PLS.fixSeed)   % fix the random number used in kmeans so that the clustering result will stay the same for the same dataset
end
[idx, model.center] = kmeans(X_train, cluster);
model.center = [ones(size(model.center, 1), 1), model.center]; % Manually add the intercept

% Initialize Beta cell array
model.Beta = cell(cluster, 1);

% Perform ordinary least squares regression for each cluster
for k = 1:cluster
    clusterIdx = idx == k;
    X_cluster = X_train(clusterIdx, :);
    Y_cluster = Y_train(clusterIdx, :);
    model.Beta{k} = func_pls_SIMPLS(X_cluster, Y_cluster);
end

% Test the model
[error, Y_prediction] = func_test_piecewise(X_test, Y_test, model);

% Summarize error/y_pred/y_test/model type based on the options
[model.error, model.yPrediction, model.yTrue, model.type, model.note] ...
    = func_summarize_result(model.Beta, error, numY, Y_prediction, Y_test, opt);

% display
disp([model.algorithm, ' training & testing are done!'])
