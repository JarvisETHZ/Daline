function data = func_filter_noise(data, varargin)

% Check if the data follows the standard format  
if ~func_check_dataFormat(data)
    error('The imported data doesn follow the standard format')
end

% Get default options
opt = func_get_option('filter noise');

% Finalize options based on the options specified by users
opt = func_finalize_opt_category(opt, varargin{:});

% If filtering noise hasn't been turned on, turn on the switch for filtering training data
if ~opt.filNoi.switchTrain && ~opt.filNoi.switchTest
    opt.filNoi.switchTrain = 1;
    warning('Filtering noise switches for training and testing are both off! Hence, the switch for filtering training data is now turned on.');
end

% Do noise filter - training data (if requested)
if opt.filNoi.switchTrain
    % When users want to filter noise
    data.train = func_filStruct_wgNoise(data.train, opt);
end

% Do noise filter - testing data (if requested)
if opt.filNoi.switchTest
    % When users want to filter noise
    data.test = func_filStruct_wgNoise(data.test, opt);
end
