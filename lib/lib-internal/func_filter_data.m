function data = func_filter_data(data, opt)
% This function filters outlier and/or noise


%% Start

% Do outlier filter first - coarse filter - training data
if opt.filOut.switchTrain
    % When users want to filter outliers
    data.train = func_filStruct_outlier(data.train, opt);
    % Interact
    num_remain = size(data.train.P, 1);
    disp(['After outlier filter, number of remaining training data points: ', num2str(num_remain)]);
end

% Do outlier filter first - coarse filter - testing data
if opt.filOut.switchTest
    % When users want to filter outliers
    data.test = func_filStruct_outlier(data.test, opt);
    % Interact
    num_remain = size(data.test.P, 1);
    disp(['After outlier filter, number of remaining testing data points: ', num2str(num_remain)]);
end

% Do noise filter later - fine filter - training data
if opt.filNoi.switchTrain
    % When users want to filter noise
    data.train = func_filStruct_wgNoise(data.train, opt);
end

% Do noise filter later - fine filter - testing data
if opt.filNoi.switchTest
    % When users want to filter noise
    data.test = func_filStruct_wgNoise(data.test, opt);
end