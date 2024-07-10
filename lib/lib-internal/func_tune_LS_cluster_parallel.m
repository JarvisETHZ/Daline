function cluster = func_tune_LS_cluster_parallel(X, Y, opt)
% func_tune_LS_cluster - tune the number of clusters for
% LS with K-means clustering
%
% Note that kmeans will generate different results because of the random
% initial points it uses. If this is not what you want, give rng a fixed
% seed. 

%% Start

% Get intervals
clusters = opt.LSC.clusNumInterval;

% Get numbers
num_clusterCandidate = length(clusters);

% Define containers
error = zeros(num_clusterCandidate, 1);

% create a cross-validation partition
if opt.LSC.fixCV
    rng(opt.LSC.fixSeed)   % fix the random number used in kmeans so that the clustering result will stay the same for the same dataset
end
c = cvpartition(size(X, 1), 'KFold', opt.LSC.cvNumFold);

% display
disp('Pallelization starts to tune the number of clusters for LS_CLS')

% Evaluate hyperparameters
parfor nc = 1:num_clusterCandidate
    
    % Specify the number of clusters
    cluster = clusters(nc);
    
    % For every fold
    for k = 1:opt.LSC.cvNumFold
        
        % Get the training and testing/validation data
        X_train = X(training(c, k), :); 
        Y_train = Y(training(c, k), :);
        X_test = X(test(c, k), :); 
        Y_test = Y(test(c, k), :);
        
        % Perform K-means clustering on X_train
        if opt.LSC.fixKmeans
            rng(opt.LSC.fixSeed)   % fix the random number used in kmeans so that the clustering result will stay the same for the same dataset
        end
        [idx, center] = kmeans(X_train, cluster);

        % Initialize Beta cell array
        Beta = cell(cluster, 1);

        % Perform ordinary least squares regression for each cluster
        for i = 1:cluster
            clusterIdx = idx == i;
            X_cluster = X_train(clusterIdx, :);
            Y_cluster = Y_train(clusterIdx, :);
            Beta{i} = (X_cluster' * X_cluster) \ (X_cluster' * Y_cluster);
        end

        % Test the model
        error_temp = func_test_piecewise_parallel(X_test, Y_test, Beta, center);

        % Store the mean error for this set of hyperparameters                
        error(nc) = mean(error_temp(:));
    end

end

% Locate the linear index with the least error
[~, cluster_idx] = min(error);

% Derive the hyperparamters with the least error
cluster = clusters(cluster_idx);
