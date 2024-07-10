function [failedMethod, model_list] = func_rank_complex(data, methodList, varargin)

% Check if the data follows the standard format  
if ~func_check_dataFormat(data)
    error('The imported data does not follow the standard format')
end

% Check if the input settings satisfy the format
if ~isempty(varargin)
    if ~isstruct(varargin{1}) && ~ischar(varargin{1})
        error('Input options must be either an opt structure or name-value pairs');
    end
end

% Get number
num_method = length(methodList);

% Define containers
model_list = cell(num_method, 1);

% Get user settings from varargin; opt could have no fields 
opt_user = func_set_option(varargin{:});

% Test methods
for n = 1:num_method
    % Integrate/update the n-th method name into opt_user
    opt_user.method.name = methodList{n};
    % Fit the model using the combined opt_user
    model_list{n} = func_fit(data, opt_user);
end

% Check if any particular response is given by the user for plot
givenPlotResponse = func_get_namedValue('PLOT.response', varargin{:});

% Check if any particular response is given by the user for training
givenVariableResponse = func_get_namedValue('variable.response', varargin{:});

% Check if opt.variable.Vm22Vm is given by the user for training
givenVariableVm22Vm = func_get_namedValue('variable.Vm22Vm', varargin{:});

% If no response is given by the user for training, use the default variable response
if isempty(givenVariableResponse)
    % Get default options for plot
    opt_variableDefault = func_get_option('variable');
    responseList = opt_variableDefault.variable.response;
% If response is given by the user for training, use the given variable response
else
    responseList = opt_user.variable.response;
end

% If opt.variable.Vm22Vm is not given, use the default value 
if isempty(givenVariableVm22Vm)
    % Get default options for plot
    opt_variableDefault = func_get_option('variable');
    variableVm22Vm = opt_variableDefault.variable.Vm22Vm;
% If it is given, use the given variable.Vm22Vm
else
    variableVm22Vm = opt_user.variable.Vm22Vm;
end

% Deal with Vm2 => Vm conversion for responseList
if ismember('Vm2', responseList)
    % If opt.variable.Vm22Vm is 1, i.e., Vm2 has been converted to Vm, then
    % replace 'Vm2' with 'Vm'
    if variableVm22Vm
        index = find(strcmp(responseList, 'Vm2'));
        responseList{index} = 'Vm';
    end
end

% Deal with Vm2 => Vm conversion for givenPlotResponse
if ismember('Vm2', givenPlotResponse)
    % If opt.variable.Vm22Vm is 1, i.e., Vm2 has been converted to Vm, then
    % replace 'Vm2' with 'Vm'
    if variableVm22Vm
        index = find(strcmp(givenPlotResponse, 'Vm2'));
        givenPlotResponse{index} = 'Vm';
    end
end

% If no PLOT.response is given, then plot the figures for all responses in responseList
if isempty(givenPlotResponse)
    % Plot and rank
    warning off % Because there could be some settings don't belong to the plot settings, which would trigger warnings 
    failedMethod = func_plot(model_list, varargin{:}, 'PLOT.response', responseList);
% If PLOT.response is given, then plot the figures for all responses in givenPlotResponse    
else
    % Plot and rank
    warning off % Because there could be some settings don't belong to the plot settings, which would trigger warnings 
    failedMethod = func_plot(model_list, varargin{:}); % varargin{:} already contains the given PLOT.response.
end

