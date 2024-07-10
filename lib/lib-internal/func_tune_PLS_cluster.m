function cluster = func_tune_PLS_cluster(X, Y, opt)
% func_tune_PLS_cluster - tune the number of clusters for
% PLS with K-means clustering
%
% Note that kmeans will generate different results because of the random
% initial points it uses. If this is not what you want, give rng a fixed
% seed. 

%% Start

% Get intervals
clusters = opt.PLS.clusNumInterval;

% Get numbers
num_clusterCandidate = length(clusters);

% Define containers
error = zeros(num_clusterCandidate, 1);

% create a cross-validation partition
if opt.PLS.fixCV
    rng(opt.PLS.fixSeed)   % fix the random number used in kmeans so that the clustering result will stay the same for the same dataset
end
c = cvpartition(size(X, 1), 'KFold', opt.PLS.cvNumFold);

% Interact
backspaces = '';
count = 0;

% Evaluate hyperparameters
for nc = 1:num_clusterCandidate
    
    % Specify the number of clusters
    cluster = clusters(nc);
    
    % For every fold
    for k = 1:opt.PLS.cvNumFold
        
        % Get the training and testing/validation data
        X_train = X(training(c, k), :); 
        Y_train = Y(training(c, k), :);
        X_test = X(test(c, k), :); 
        Y_test = Y(test(c, k), :);
        
        % Add the intercept back
        X_test = [ones(size(X_test, 1), 1), X_test];
        
        % Perform K-means clustering on X_train
        if opt.PLS.fixKmeans
            rng(opt.PLS.fixSeed)   % fix the random number used in kmeans so that the clustering result will stay the same for the same dataset
        end
        [idx, result.center] = kmeans(X_train, cluster);
        result.center = [ones(size(result.center, 1), 1), result.center]; % Manually add the intercept

        % Initialize Beta cell array
        result.Beta = cell(cluster, 1);

        % Perform ordinary least squares regression for each cluster
        for i = 1:cluster
            clusterIdx = idx == i;
            X_cluster = X_train(clusterIdx, :);
            Y_cluster = Y_train(clusterIdx, :);
            result.Beta{i} = func_pls_SIMPLS(X_cluster, Y_cluster);
        end

        % Test the model
        error_temp = func_test_piecewise(X_test, Y_test, result);

        % Store the mean error for this set of hyperparameters                
        error(nc) = mean(error_temp(:));
    end

    % Display progress
    count = count + 1;
    pro_str = sprintf('PLS with k-means clustering tuning complete percentage: %3.1f', 100 * count / num_clusterCandidate);
    fprintf([backspaces, pro_str]);
    backspaces = repmat(sprintf('\b'), 1, length(pro_str)); % Subtract 1 to account for the newline character
end

% Locate the linear index with the least error
[~, cluster_idx] = min(error);

% Derive the hyperparamters with the least error
cluster = clusters(cluster_idx);

% Interact
fprintf('\n');
