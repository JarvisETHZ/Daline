function data = func_normalize_data(data, opt)

% Normalize training and testing data
if opt.norm.switch
    % Compute the normalizing factors using the training data
    data.normFactor = func_normalize_factor(data.train);

    % Normalize the training data
    data.train = func_normalize_struct(data.train, data.normFactor);

    % Normalize the testing data --- will not influence the error
    % evaluation when using a relative error indicator, e.g.,
    % (test-predict)/test.
    data.test = func_normalize_struct(data.test, data.normFactor);
    % Just in case: you can recover the normalized data by 
    % e.g., data.train = func_normalize_data_recovery(data.train, data.normFactor)
end