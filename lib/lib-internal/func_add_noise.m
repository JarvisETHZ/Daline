function data = func_add_noise(data, varargin)

% Check if the data follows the standard format  
if ~func_check_dataFormat(data)
    error('The imported data doesn follow the standard format')
end

% Get default options
opt = func_get_option('add noise');

% Finalize options based on the options specified by users
opt = func_finalize_opt_category(opt, varargin{:});

% If adding noise hasn't been turned on, adding noise to training data
if ~opt.noise.switchTrain && ~opt.noise.switchTest
    opt.noise.switchTrain = 1;
    warning('Noise switches for training and testing are both off! Hence, the switch for adding noise to training data is now turned on.');
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

