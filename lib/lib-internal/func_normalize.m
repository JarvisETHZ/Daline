function data = func_normalize(data, varargin)

% Check if the data follows the standard format  
if ~func_check_dataFormat(data)
    error('The imported data doesn follow the standard format')
end

% Get default options
opt = func_get_option('normalize data');

% Finalize options based on the options specified by users
opt = func_finalize_opt_category(opt, varargin{:});

% opt.norm.switch = 1 is mandatory 
opt.norm.switch = 1;

% Normalize training and testing data
data = func_normalize_data(data, opt);