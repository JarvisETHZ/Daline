function data = func_generate(varargin)  
%  Training/testing data generation based on the inputted user settings.
%  Each field of the output data is num_sample-by-num_variable

%% Start

% Get default options for data generation
opt = func_get_option('system', 'generate data', 'mpc index', 'warning');

% Finalize options based on the options specified by users
opt = func_finalize_opt_category(opt, varargin{:});

% Set warning off if requested
if opt.data.parallel
    func_warning_switch_multiCPU(opt.warning.switch)
else
    func_warning_switch_singleCPU(opt.warning.switch)
end

% Generate training and testing data
data = func_generate_data(opt);  
