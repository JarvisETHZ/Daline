function [Beta, center, success] = func_RR_kPlane(X, Y, num_cluster, eta, lambda, num_maxIter, kmeans_fix, fixSeed)
% func_RR_kPlane performs the ridge regression with k plane clustering
% algorithm, under given numCluster (the number of cluster), lambda (the
% regularization constant), and eta (the weight to compromise plane and
% centroid). 
%
% Note that kmeans will generate different results because of the random
% initial points it uses. If this is not what you want, give rng a fixed
% seed. 

%% Start

% Get numbers
[num_sample, num_X_var] = size(X);

% Initialize containers
Beta    = cell(num_cluster, 1);
success = 1;
loss    = zeros(num_sample, num_cluster); 
idx_old = zeros(num_sample, 1);
iter    = 0;

% Use k-means to get the initial start
if kmeans_fix
    rng(fixSeed)   % fix the random number used in kmeans so that the clustering result will stay the same for the same dataset
end
[idx, center] = kmeans(X, num_cluster);

% Perform ordinary ridge regression with K-plane clustering 
while any(idx_old ~= idx)

    % loop for each centroid
    for k = 1:num_cluster
        
        % Get datasets for X and Y belonging to cluster k
        Xk = X(idx == k, :);
        Yk = Y(idx == k, :);

        % Train the model using the ordinary ridge regression
        Beta{k} = (Xk' * Xk + lambda * eye(num_X_var)) \ (Xk' * Yk);

        % Get 'loss' of each observation for cluser k: plane residual
        loss(:, k) = sum( (X * Beta{k} - Y).^2,  2 );
        
        % Plus 'loss' of each observation in cluser k: weighted centroid distance
        loss(:, k) = loss(:, k) + eta * sum( (X - center(k, :)).^2,  2 );
        
    end
    
    % Save the old index for clusters
    idx_old = idx;
    
    % Get new index for clusters
    [~, idx] = min(loss, [], 2);  % find the minimum value of each row (each observation) in loss => new cluster index of this observation
    
    % Get new centroid
    for k = 1:num_cluster
        center(k, :) = mean(X(idx == k, :));
    end

    % Update the number of iteration
    iter = iter + 1;

    % Jump out from inconvergence
    if iter > num_maxIter
        success = 0;
        disp('Ridge regression with K-plane clustering failed to converge.')
        break
    end
end