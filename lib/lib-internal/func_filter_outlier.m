function data = func_filter_outlier(data, varargin)

% Check if the data follows the standard format  
if ~func_check_dataFormat(data)
    error('The imported data doesn follow the standard format')
end

% Get default options
opt = func_get_option('filter outlier');

% Finalize options based on the options specified by users
opt = func_finalize_opt_category(opt, varargin{:});

% If filtering outlier hasn't been turned on, turn opt.filOut.switchTrain on
if ~opt.filOut.switchTrain && ~opt.filOut.switchTest
    opt.filOut.switchTrain = 1;
    warning('Filtering outlier switches for training and testing are both off! Hence, the switch for filtering training data is now turned on.');
end

% Do outlier filter - training data (if requested)
if opt.filOut.switchTrain
    % When users want to filter outliers
    data.train = func_filStruct_outlier(data.train, opt);
    % Interact
    num_remain = size(data.train.P, 1);
    disp(['After outlier filter, number of remaining training data points: ', num2str(num_remain)]);
end

% Do outlier filter - testing data (if requested)
if opt.filOut.switchTest
    % When users want to filter outliers
    data.test = func_filStruct_outlier(data.test, opt);
    % Interact
    num_remain = size(data.test.P, 1);
    disp(['After outlier filter, number of remaining testing data points: ', num2str(num_remain)]);
end
