function func_check_optName(opt_user)
% func_check_optName aims to check the names of user-specified options,
% ensuring that they match the options supported by the toolbox.

% Enumerate all fields of the toolbox
key = {'system', 'generate data', 'add outlier', 'add noise', 'filter outlier', 'filter noise', ...
       'normalize data', 'mpc index', 'method', 'warning', 'variable', 'LS_REC', 'LS_REP', 'LS_GEN', ...
       'LS_PCA', 'PCA', 'LS_LIFX', 'LS_LIFXi', 'LS_HBW', 'LS_HBLD', 'LS_HBLE', 'LS_WEI', 'LS_CLS', ...
       'LS_LIF', 'PLS_NIP', 'PLS_BDL','PLS_BDLY2', 'PLS_BDLopen', 'PLS_REC', 'PLS_REP', 'PLS_RECW', ...
       'PLS_CLS', 'RR', 'RR_WEI', 'RR_KPC', 'RR_VCS', 'SVR', 'SVR_POL', 'SVR_RR', 'SVR_CCP', 'LCP_BOX', ...
       'LCP_BOXN', 'LCP_JGD', 'LCP_JGDN', 'LCP_COU', 'LCP_COUN', 'LCP_COU2', 'LCP_COUN2', 'DRC_XM', ...
       'DRC_XYM', 'DRC_XYD', 'DC', 'DC_LS', 'DLPF', 'DLPF_C', 'PTDF', 'TAY', 'PLOT'};

% Get the name list of the toolbox
opt_benchmark = func_default_option_category(key);

% Add the name of the only implicit option, case.mpc, to opt_benchmark.
opt_benchmark.case.mpc = [];

% Check the names
func_check_structFields(opt_benchmark, opt_user);
