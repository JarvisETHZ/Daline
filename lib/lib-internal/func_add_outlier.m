function data = func_add_outlier(data, varargin)

% Check if the data follows the standard format  
if ~func_check_dataFormat(data)
    error('The imported data doesn follow the standard format')
end

% Get default options
opt = func_get_option('add outlier');

% Finalize options based on the options specified by users
opt = func_finalize_opt_category(opt, varargin{:});

% If adding outliers hasn't been turned on, adding outliers to training data
if ~opt.outlier.switchTrain && ~opt.outlier.switchTest
    opt.outlier.switchTrain = 1;
    warning('Outlier switches for training and testing are both off! Hence, the switch for adding outliers to training data is now turned on.');
end

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

