function [opt, X_train, X_test, Y_train, Y_test, numY, pList, rList, pIdx, rIdx] = func_opts_predictor_response_singleCPU(method, data, varargin)
% It does three things:
% 1. Finalize options based on the default options of this method and the inputted options
% 2. Set warning off if requested
% 3. Specify and transform predictors and responses; also get their list and indices

% Finalize options based on the default options of this method and the inputted options
opt = func_finalize_opt_method(method, varargin{:});

% Set warning off if requested
func_warning_switch_singleCPU(opt.warning.switch)

% Specify and transform input and output
[X_train, X_test, Y_train, Y_test, numY, pList, rList, pIdx, rIdx] = func_generate_predictor_response(data, opt);