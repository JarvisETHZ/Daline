function [data, X, Y] = func_data_pipeline(varargin)

% Get default options
opt = func_get_option('system', 'generate data', 'mpc index', 'warning', 'add noise', 'add outlier', 'filter noise', 'filter outlier', 'normalize data');

% Finalize options based on the options specified by users
opt = func_finalize_opt_category(opt, varargin{:});

% Set warning off if requested
if opt.data.parallel
    func_warning_switch_multiCPU(opt.warning.switch)
else
    func_warning_switch_singleCPU(opt.warning.switch)
end

% produce training and testing data, including generation, pollution, clean, and normalization
[data, X, Y] = func_data(opt);