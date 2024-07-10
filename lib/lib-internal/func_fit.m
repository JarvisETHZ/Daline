function model = func_fit(data, varargin)

% Check if the data follows the standard format  
if ~func_check_dataFormat(data)
    error('The first argument of daline.fit must be a data structure that follows the standard format of Daline! If you do not have your own data, you can generate (and process) data by using daline.data.');
end

% If varargin is empty => use the default method
if isempty(varargin)
    % Use the default method
    opt = func_get_option('method');
% If varargin is not empty => collect users' settings
else
    % If varargin{1} is a structure, i.e., opt structure
    if isstruct(varargin{1}) 
        if length(varargin) == 1
            % Get the opt structure specified by users
            opt = varargin{1}; 
        elseif isstruct(varargin{2}) 
            % In this case, users input more than one opts => throw an error
            error('The function daline.fit accepts only a single opt structure. However, you are providing multiple opt structures. Please use daline.setopt to merge all the settings into one opt structure, and then pass the resulting opt structure into daline.fit.');
        else
            error('The options for daline.fit must be either an opt structure or name-value pairs. It cannot accept both the opt structure and name-value pairs simultaneously. Please merge them into one opt structure, and then pass the resulting opt structure into daline.fit.');
        end
    % If varargin{1} is a char, i.e., name-value pair
    elseif ischar(varargin{1})
        % Get name-value pairs specified by users
        opt = func_set_option(varargin{:});
    else
        error('The options for daline.fit must be either an opt structure or name-value pairs. It cannot accept both the opt structure and name-value pairs simultaneously. Please merge them into one opt structure, and then pass the resulting opt structure into daline.fit.');
    end
    % If a method name is not given by the user => use the default method but keep other users' options 
    if ~isfield(opt, 'method') || ~isfield(opt.method, 'name')
        % Use the default method and keep other users' options 
        opt_default = func_get_option('method');
        opt.method.name = opt_default.method.name;
    end
end

% Check the names of user-specified options and sub-options, ensuring that they match the options supported by the toolbox.
func_check_optName(opt)
opt.check.optName = 1;   % If passed the check, give 1 to opt.check.optName, to avoid repetitive check in algorithms

% Get the model; opt will be integrated/updated accordingly within each algorithm function
model = func_algorithm(data, opt);