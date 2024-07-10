function best_PerComponent = func_tune_PCA_parallel(X_train, Y_train, PerComponentCandidates, numFold, fixCV, fixSeed)
% This function performs cross-validation to select the best percentage of principal components.
% Inputs:
% - X_train: training input data
% - Y_train: training output data
% - PerComponentCandidates: vector of candidates for the number of principal components
% - numFold: the number of folds for cross-validation
% Output:
% - best_PerComponent: the best percentage of principal components based on cross-validation

% Initialize variables
numCandidates = length(PerComponentCandidates);
errors = zeros(1, numCandidates);

% Create a cross-validation partition
if fixCV
    rng(fixSeed)
end
c = cvpartition(size(X_train, 1), 'KFold', numFold);

% Parallel loop over all candidate numbers of principal components
parfor idx = 1:numCandidates
    numComponent = PerComponentCandidates(idx);
    
    % Compute the number of principal components
    Nx = size(X_train, 2);
    Np = round(Nx * numComponent / 100);
    
    % Initialize error for this number of components
    error_sum = 0;
    
    % Perform k-fold cross-validation
    for i = 1:c.NumTestSets
        % Separate data into training and validation sets
        train_idx = training(c, i);
        val_idx = test(c, i);
        
        % PCA on the training set
        D0 = pca(X_train(train_idx, :));
        D  = D0(:, 1:Np);
        
        % Regression model on the training set
        Beta_PCA = (X_train(train_idx, :) * D) \ Y_train(train_idx, :);
        
        % Prediction and error on the validation set
        Y_pred = X_train(val_idx, :) * D * Beta_PCA;
        relative_error = abs(Y_pred - Y_train(val_idx, :)) ./ abs(Y_train(val_idx, :));
        
        % Sum the error for this fold
        error_sum = error_sum + mean(mean(relative_error));
    end
    
    % Average error for this number of components
    errors(idx) = error_sum / c.NumTestSets;
end

% Identify the best numComponent
[~, best_idx] = min(errors);
best_PerComponent = PerComponentCandidates(best_idx);
