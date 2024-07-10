function opt = func_finalize_opt_category(opt_category, varargin)

% If varargin is empty
if isempty(varargin)
    opt = opt_category;
% If varargin is not empty
else
    % If varargin{1} is a structure, i.e., opt structure
    if isstruct(varargin{1})
        % Get the opt structure specified by users
        opt_user = func_set_option_struct(varargin{1});
        % Check the names of user-specified options and sub-options, ensuring that they match the options supported by the toolbox.
        func_check_optName(opt_user)
        % Update options by integrating user's option
        opt = func_update_option(opt_category, opt_user);
    % If varargin{1} is a char, i.e., name-value pair
    elseif ischar(varargin{1})
        % Get options specified by users
        opt_user = func_set_option(varargin{:});
        % Check the names of user-specified options and sub-options, ensuring that they match the options supported by the toolbox.
        func_check_optName(opt_user)
        % Update options by integrating user's option
        opt = func_update_option(opt_category, opt_user);
    else
        error('The options for the functions in Daline must be either an opt structure or name-value pairs. They cannot accept both the opt structure and name-value pairs simultaneously. Please merge them into one opt structure, and then pass the resulting opt structure into the functions of Daline.');
    end
end