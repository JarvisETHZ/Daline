function [failedMethod, model_list] = func_rank(data, methodList, varargin)

% Check if the data follows the standard format  
if ~func_check_dataFormat(data)
    error('The first argument of daline.rank must be a data structure that follows the standard format of Daline! If you do not have your own data, you can generate (and process) data by using daline.data.');
end

% Check if the input settings satisfy the format
if ~isempty(varargin)
    if ~isstruct(varargin{1}) && ~ischar(varargin{1})
        error('The options for daline.rank must be either an opt structure or name-value pairs. It cannot accept both the opt structure and name-value pairs simultaneously. Please merge them into one opt structure, and then pass the resulting opt structure into daline.rank.');
    end
end

% Check if the methodList is a cell; if it is not a cell but a string =>
% users probably input only one method in its string name => convert it
% into a cell
if ~iscell(methodList)
    methodList = {methodList};
end

% The warning is turned off because varargin may contain parameters
% belonging to different methods, and for every particular method may
% consider other parameters as invalid parameters => giving warning. To
% avoid this, the warning is turned off here
warning off

% Get number
num_method = length(methodList);

% Define containers
model_list = cell(num_method, 1);

% Get user settings from varargin
if isempty(varargin)
    % If varargin is empty, give it to func_set_option; it knows how to handle that
    opt_user = func_set_option(varargin{:});
else
    % If varargin{1} is a structure, i.e., opt structure
    if isstruct(varargin{1}) 
        if length(varargin) == 1
            % Get the opt structure specified by users
            opt_user = varargin{1}; 
        elseif isstruct(varargin{2}) 
            % In this case, users input more than one opts => throw an error
            error('The function daline.rank accepts only a single opt structure. However, you are providing multiple opt structures. Please use daline.setopt to merge all the settings into one opt structure, and then pass the resulting opt structure into daline.rank.');
        else
            error('The options for daline.rank must be either an opt structure or name-value pairs. It cannot accept both the opt structure and name-value pairs simultaneously. Please merge them into one opt structure, and then pass the resulting opt structure into daline.rank.');
        end
    % If varargin{1} is a char, i.e., name-value pair    
    elseif ischar(varargin{1})
        % Get options specified by users
        opt_user = func_set_option(varargin{:});
    else
        error('The options for daline.rank must be either an opt structure or name-value pairs. It cannot accept both the opt structure and name-value pairs simultaneously. Please merge them into one opt structure, and then pass the resulting opt structure into daline.rank.');
    end
end

% Test methods
for n = 1:num_method
    % Integrate/update the n-th method name into opt_user
    opt_user.method.name = methodList{n};
    % Fit the model using the combined opt_user
    model_list{n} = func_fit(data, opt_user);
end

% Plot and rank
warning off % Because there could be some settings don't belong to the plot settings, which would trigger warnings 
failedMethod = func_plot(model_list, varargin{:}); 


