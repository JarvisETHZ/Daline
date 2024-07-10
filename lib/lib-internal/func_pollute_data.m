function data = func_pollute_data(data, opt)

% Add outliers to training data (if requested)
if opt.outlier.switchTrain 
    % Add outliers to training data only
    data.train = func_addStruct_outlier(data.train, opt.outlier.percentage, opt.outlier.factor, opt.data.fixRand, opt.data.fixSeed);
    % Interaction
    disp('Outliers added to the training dataset');
end

% Add outliers to testing data (if requested)
if opt.outlier.switchTest
    % Add outliers to testing data only
    data.test = func_addStruct_outlier(data.test, opt.outlier.percentage, opt.outlier.factor, opt.data.fixRand, opt.data.fixSeed);
    % Interaction
    disp('Outliers added to the testing dataset');
end

% Add white Gaussian noise to training data (if requested)
if opt.noise.switchTrain 
    % Add noise to training data
    data.train  = func_addStruct_wgNoise(data.train, opt.noise.SNR_dB, opt.data.fixRand, opt.data.fixSeed);
    % Interaction
    disp('White Gaussian noise added to the training dataset');
end

% Add white Gaussian noise to testing data (if requested)
if opt.noise.switchTest 
    % Add noise to testing data
    data.test  = func_addStruct_wgNoise(data.test, opt.noise.SNR_dB, opt.data.fixRand, opt.data.fixSeed);
    % Interaction
    disp('White Gaussian noise added to the testing dataset');
end
