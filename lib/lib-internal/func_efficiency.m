function [case_list, time_list] = func_efficiency(data, methodList, varargin)

% Check if data is a structure, i.e., only one data set is given
if isstruct(data)
    % if so, turn it into a cell, for the convenience of the following code
    dataCell{1} = data;
    data = dataCell;
end

% Check if the methodList is a cell; if it is not a cell but a string =>
% users probably input only one method in its string name => convert it
% into a cell
if ~iscell(methodList)
    methodList = {methodList};
end

% Get number
num_method = length(methodList);
num_data   = length(data);

% Check if all the data follows the standard format  
for n = 1:num_data
    if ~func_check_dataFormat(data{n})
        error('The first argument of daline.time must be either a data structure that follows the standard format of Daline, or a cell where each element is a data structure. If you do not have your own data, you can generate (and process) data by using daline.data.');
    end
end

% The warning is turned off because varargin may contain parameters
% belonging to different methods, and for every particular method may
% consider other parameters as invalid parameters => giving warning. To
% avoid this, the warning is turned off here
warning off

% Update options only for plot based on user input
opt_plot = func_get_option('PLOT');
opt_plot = func_finalize_opt_category(opt_plot, varargin{:});

% Collect user settings into opt_fit for the following training
if isempty(varargin)
    % If varargin is empty, give it to func_set_option; it knows how to handle that
    opt_fit = func_set_option(varargin{:});
else
    % If varargin{1} is a structure, i.e., opt structure
    if isstruct(varargin{1}) 
        if length(varargin) == 1
            % Get the opt structure specified by users
            opt_fit = varargin{1}; 
        elseif isstruct(varargin{2}) 
            % In this case, users input more than one opts => throw an error
            error('The function daline.time accepts only a single opt structure. However, you are providing multiple opt structures. Please use daline.setopt to merge all the settings into one opt structure, and then pass the resulting opt structure into daline.time.');
        else
            error('The options for daline.time must be either an opt structure or name-value pairs. It cannot accept both the opt structure and name-value pairs simultaneously. Please merge them into one opt structure, and then pass the resulting opt structure into daline.time.');
        end
    % If varargin{1} is a char, i.e., name-value pair    
    elseif ischar(varargin{1})
        % Get options specified by users
        opt_fit = func_set_option(varargin{:});
    else
        error('The options for daline.time must be either an opt structure or name-value pairs. It cannot accept both the opt structure and name-value pairs simultaneously. Please merge them into one opt structure, and then pass the resulting opt structure into daline.time.');
    end
end

% Define containers
model_list = cell(num_method,  1);
time_list  = zeros(num_method, num_data);
case_list  = zeros(1, num_data);

% Start evaluation
for i = 1:num_data
    
    % Get data
    data_eval = data{i};
    case_list(i) = size(data_eval.mpc.bus, 1);
    
    % Repeatedly train & test
    for n = 1:num_method
        % Set the method name to opt_fit (opt_fit contains user settings)
        opt_fit.method.name = methodList{n};
        % Repeat the training for opt.PLOT.repeat times to compute the
        % average computional time
        tic
        for j = 1:opt_plot.PLOT.repeat
            % training & testing
            model_list{n} = func_fit(data_eval, opt_fit);
            % Display
            disp(['For dataset ', num2str(i), ' (number of datasets: ', num2str(num_data), ')', ', repeated training & testing for ', methodList{n}, ' completes ', num2str(100*j/opt_plot.PLOT.repeat), '%'])
        end
        time_list(n, i) = toc/opt_plot.PLOT.repeat;
    end   
end

% Plot the computational burden (if requested)
if opt_plot.PLOT.switch
    % When there are multiple data sets, draw the efficiency curve
    if num_data > 1
        warning off % Because there could be some settings don't belong to the plot settings, which would trigger warnings 
        func_plot_Performance_style(methodList, case_list, time_list, opt_plot.PLOT.style)
    % When there is only one data set, draw the computational bar
    else
        func_plot_PerformanceBar_style(methodList, case_list, time_list', opt_plot.PLOT.style)
    end
end