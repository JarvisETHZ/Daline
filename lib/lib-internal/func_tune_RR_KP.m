function [cluster, lambda, eta] = func_tune_RR_KP(X, Y, opt)

% Get intervals
clusters = opt.RR.clusNumInterval;
lambdas  = opt.RR.lambdaInterval;
etas     = opt.RR.etaInterval;

% Get numbers
num_cluster = length(clusters);
num_lambda  = length(lambdas);
num_eta     = length(etas);

% Define containers
error = zeros(num_cluster, num_lambda, num_eta);

% create a cross-validation partition
if opt.RR.fixCV
    rng(opt.RR.fixSeed)   % fix the random number used in kmeans so that the clustering result will stay the same for the same dataset
end
c = cvpartition(size(X, 1), 'KFold', opt.RR.cvNumFold);

% Interact
backspaces = '';
count = 0;

% Evaluate hyperparameters
for nc = 1:num_cluster
    
    % Specify the number of clusters
    cluster = clusters(nc);
    
    for nl = 1:num_lambda
        
        % Specify lambda
        lambda = lambdas(nl);
        
        for ne = 1:num_eta
            
            % Specify lambda
            eta = etas(ne);
            
            % For every fold
            for k = 1:opt.RR.cvNumFold
                % Get the training and testing/validation data
                X_train = X(training(c, k), :); 
                Y_train = Y(training(c, k), :);
                X_test = X(test(c, k), :); 
                Y_test = Y(test(c, k), :);
            
                % Train the model use the given hyperparameters
                [result.Beta, result.center, result.success] = func_RR_kPlane(X_train, Y_train, cluster, eta, lambda, opt.RR.kplaneMaxIter, opt.RR.fixKmeans, opt.RR.fixSeed);

                % Test the model
                error_temp = func_test_piecewise(X_test, Y_test, result);
                
                % Store the mean error for this set of hyperparameters                
                error(nc, nl, ne) = mean(error_temp(:));
            end
            
            % Display progress
            count = count + 1;
            pro_str = sprintf('Ridge regression with K-plane clustering tuning complete percentage: %3.1f', 100 * count / (num_cluster*num_lambda*num_eta));
            fprintf([backspaces, pro_str]);
            backspaces = repmat(sprintf('\b'), 1, length(pro_str)); % Subtract 1 to account for the newline character
        end
    end
end

% Locate the linear index with the least error
[~, linearIdx] = min(error(:));

% Convert the linear index to 3D indices
[cluster_idx, lambda_idx, eta_idx] = ind2sub(size(error), linearIdx);

% Derive the hyperparamters with the least error
cluster = clusters(cluster_idx);
lambda  = lambdas(lambda_idx);
eta     = etas(eta_idx);

% Interact
fprintf('\n');
