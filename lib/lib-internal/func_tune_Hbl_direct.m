function best_delta = func_tune_Hbl_direct(X_train, Y_train, algorithm, parallel, deltaCandidates, initialGuess, directOptions, numFold, fixCV, fixSeed)
% This function performs cross-validation to select the best TuningConst of LS_Hbw

% Initialize variables
numCandidates = length(deltaCandidates);
errors = zeros(1, numCandidates);

% Create a cross-validation partition
if fixCV
    rng(fixSeed)
end
c = cvpartition(size(X_train, 1), 'KFold', numFold);

% Parallel loop over all candidate numbers of principal components
for idx = 1:numCandidates
    
    % Get a tuning constant => goes into func_solve_Hbl_direct
    delta = deltaCandidates(idx);
    
    % Initialize error for this number of components
    error_sum = 0;
    
    % Perform k-fold cross-validation
    for i = 1:c.NumTestSets
        
        % Separate data into training and validation sets
        train_idx = training(c, i);
        val_idx = test(c, i);
        
        % Get training data and validation data
        X_t = X_train(train_idx, :);
        Y_t = Y_train(train_idx, :);
        X_v = X_train(val_idx, :);
        Y_v = Y_train(val_idx, :);
        
        % Regression model on the training set
        [Beta, ~] = func_solve_Hbl_direct_forTuning(X_t, Y_t, parallel, delta, initialGuess, directOptions, algorithm);
        
        % Prediction and error on the validation set
        Y_pred = X_v * Beta;
        relative_error = abs(Y_pred - Y_v) ./ abs(Y_v);
        
        % Sum the error for this fold
        error_sum = error_sum + mean(mean(relative_error));
    end
    
    % Average error for this number of components
    errors(idx) = error_sum / c.NumTestSets;
end

% Identify the best numComponent
[~, best_idx] = min(errors);
best_delta = deltaCandidates(best_idx);
