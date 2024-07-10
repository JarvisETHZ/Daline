function [lambda, error_least] = func_tune_RR(X, Y, W, opt, dis_switch)
% func_tune_RR finds the best lambda in ridge regression 
% using cross validation from the given range of lambda. Without loss of
% generality, the weight matrix W is also taken into account. For the
% original ridge regression, the input W should be an identity matrix.
% 
% X: training data for predictor
% Y: training data for response

%% Start 

% create a cross-validation partition
if opt.RR.fixCV
    rng(opt.RR.fixSeed)   % fix the random number used in kmeans so that the clustering result will stay the same for the same dataset
end
c = cvpartition(size(X, 1), 'KFold', opt.RR.cvNumFold);

% get hyperparameter candidates
lambdas = opt.RR.lambdaInterval;

% get numbers
num_X_var = size(X, 2);

% store the average error value given by each hyperparameter value
error_mean = zeros(length(lambdas), 1);

% Interact (if requested)
if dis_switch
    backspaces = '';
end

% cross validation to tune lambda
for n = 1:length(lambdas)
    
    % select a hyperparameter    
    lambda = lambdas(n);
    
    % store the average errors for all folds under the given hyperparameter
    error = zeros(opt.RR.cvNumFold, 1);

    % do cross-validation with each fold
    for k = 1:opt.RR.cvNumFold
        
        % training data of fold k
        X_train = X(training(c, k), :); 
        Y_train = Y(training(c, k), :);
        
        % testing/validation data of fold k
        X_test = X(test(c, k), :); 
        Y_test = Y(test(c, k), :);
        
        % weight matrix for fold k
        W_fold = W(training(c, k), training(c, k));

        % train the model using given hyperparameter within fold k
        Beta = (X_train' * W_fold * X_train + lambda * eye(num_X_var)) \ (X_train' * Y_train);
        
        % test the model and store the average error
        Y_prediction  = X_test * Beta;
        error_temp = abs(Y_prediction - Y_test) ./ abs(Y_test);
        error(k) = mean(error_temp(:));
    end
    
    % store the average error of the given hyperparameter
    error_mean(n) = mean(error);
    
    % Display progress (if requested)
    if dis_switch
        pro_str = sprintf('Ridge regression tuning complete percentage: %3.1f', 100 * n / length(lambdas));
        fprintf([backspaces, pro_str]);
        backspaces = repmat(sprintf('\b'), 1, length(pro_str)); % Subtract 1 to account for the newline character
    end
end

% output the hyperparameter with the least error
lambda = lambdas(min(error_mean) == error_mean);
error_least = min(error_mean);

% if there are some hyperparameters with the same error, output the first one
if length(lambda) > 1
    lambda(2:end) = [];
end

% Interact (if requested)
if dis_switch
    fprintf('\n');
end
