function opt = func_finalize_opt_method(algorithm, varargin)
% If varargin is empty
if isempty(varargin)
    % Use default options of this method
    opt = func_get_option(algorithm);
    % Get the method name
    opt.method.name = algorithm;
else
    % If varargin{1} is a structure, i.e., opt structure
    if isstruct(varargin{1})
        % Get the opt structure specified by users
        opt_user = varargin{1};
    % If varargin{1} is a char, i.e., name-value pair
    elseif ischar(varargin{1})
        % Get name-value options specified by users
        opt_user = func_set_option(varargin{:});
    else
        error('The options for the functions in Daline must be either an opt structure or name-value pairs. They cannot accept both the opt structure and name-value pairs simultaneously.');
    end
    % If opt.check.optName exists and is 1 => opt checked already and passed in func_fit => skip check. Otherise, check the name of the user-specified options
    if ~(isfield(opt_user, 'check') && isfield(opt_user.check, 'optName') && (opt_user.check.optName == 1))
        % Check the names of user-specified options and sub-options, ensuring that they match the options supported by the toolbox.
        func_check_optName(opt_user)
    end
    % Get default options of this method
    opt_default = func_get_option(algorithm);
    % Get the method name
    opt_default.method.name = algorithm;
    % Update options by integrating user's option
    opt = func_update_option(opt_default, opt_user);
end