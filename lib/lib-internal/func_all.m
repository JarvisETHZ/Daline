% Full cycle functions
function [model, data, failure] = func_all(systemcase, varargin)

% Mandatory warning off, because the options specified here are much more
% than the default options inside training algorithms => when merging a
% larger option set into a smaller one, the toolbox will make warnings. 
warning off


% If varargin is empty => use the default parameters
if isempty(varargin)
    % Give it to func_set_option cuz it knows how to handle this
    opt_user = func_set_option(varargin{:});
% If varargin is not empty => collect users' settings
else
    % If varargin{1} is a structure, i.e., opt structure
    if isstruct(varargin{1}) 
        if length(varargin) == 1
            % Get the opt structure specified by users
            opt_user = varargin{1}; 
        elseif isstruct(varargin{2}) 
            % In this case, users input more than one opts => throw an error
            error('The function daline.all accepts only a single opt structure. However, you are providing multiple opt structures. Please use daline.setopt to merge all the settings into one opt structure, and then pass the resulting opt structure into daline.all.');
        else
            error('The options for daline.all must be either an opt structure or name-value pairs. It cannot accept both the opt structure and name-value pairs simultaneously.');
        end
    % If varargin{1} is a char, i.e., name-value pair
    elseif ischar(varargin{1})
        % Get name-value pairs specified by users
        opt_user = func_set_option(varargin{:});
    else
        error('The options for daline.all must be either an opt structure or name-value pairs. It cannot accept both the opt structure and name-value pairs simultaneously. Please merge them into one opt structure, and then pass the resulting opt structure into daline.all.');
    end
end

% Check the names of user-specified options and sub-options, ensuring that they match the options supported by the toolbox.
func_check_optName(opt_user)

% Integerate the given system information into opt_user
% If systemcase is a structure, i.e., a mpc
if isstruct(systemcase)
    % Finalize case.mpc based on the mpc specified by users
    opt_user.case.mpc = systemcase;
% If systemcase is a case name, e.g., 'case39'
elseif ischar(systemcase)
    % Finalize case.name based on the name specified by users
    opt_user.case.name = systemcase;
% Error
else
    error('The first argument of daline.all must be either a case name such as ''case118'', or a mpc structure for a power system.')
end

% Pipeline for data generation, pollution, clean, and normalization
[data, ~, ~] = func_data_pipeline(opt_user);

% Training and testing the model
model = func_fit(data, opt_user);

% Plot results
failure = func_plot(model, opt_user);

