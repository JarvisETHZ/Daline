function failedMethod = func_plot(model, varargin)

% Get default options for plot
opt = func_get_option('PLOT'); 

% Finalize options based on the options specified by users
opt = func_finalize_opt_category(opt, varargin{:});

% If users haven't specified any response to plot (opt.PLOT.response is empty by default)
if isempty(opt.PLOT.response)
    opt.PLOT.response = func_get_unionErrorNames(model);
end

% Update: No need to check if 'Vm2' is in opt.PLOT.response. If model has no 'Vm2' field, users will get a failure figure.
% But need to reminder users that when plotting 'Vm2', remember to turn off opt.variable.Vm22Vm during training!
% 
% Check if 'Vm2' is in opt.PLOT.response (only possible from users' settings)
% if any(strcmp(opt.PLOT.response, 'Vm2'))
%     % Check if opt.variable.Vm22Vm is 1
%     if opt.variable.Vm22Vm == 1
%         % Find the index of 'Vm2' in the cell array
%         vm2Index = find(strcmp(opt.PLOT.response, 'Vm2'));
%         % Replace 'Vm2' with 'Vm'
%         opt.PLOT.response{vm2Index} = 'Vm';
%         % Display the message
%         disp('With the Vm2 to Vm conversion active, Vm diagrams are plotted instead of Vm2. To view Vm2 results, set opt.variable.Vm22Vm to 0, rerun the fitting, and then visualize.');
%     end
% end

% Store the response list
responseList = opt.PLOT.response;

% Define failedMethod container individually
failedMethod = cell(length(responseList), 2);

% If plot 2D ranking
if strcmp(opt.PLOT.type, 'moment')
    % If the given PLOT.response contains a single target => plot individually
    if length(responseList) == 1
        if strcmp(opt.PLOT.theme, 'commercial')
            % Plot one error filed using a much cooler theme
            failedMethod{1, 1} = func_visualize_single_error(model, opt);
            % If failedMethod{1, 1} is not empty => method(s) failed for this response 
            if ~isempty(failedMethod{1, 1})
                failedMethod{1, 2} = ['Method(s) that failed when predicting ', opt.PLOT.response{1}];
            end
        elseif strcmp(opt.PLOT.theme, 'academic')
            % Plot one error filed using an average academic theme
            failedMethod = func_visualize_multi_errors(model, opt.PLOT.response, {}, opt.PLOT.switch);
            % If failedMethod{1, 1} is not empty => method(s) failed for this response 
            if ~isempty(failedMethod{1, 1})
                failedMethod{1, 2} = ['Method(s) that failed when predicting ', opt.PLOT.response{1}];
            end
        end
    % If the given PLOT.response contains multiple targets
    else
        % If requested to plot individually
        if strcmp(opt.PLOT.pattern, 'indivi')
            % For each response
            for n = 1:length(responseList)
                % Specify the PLOT.response
                opt.PLOT.response{1} = responseList{n};
                opt.PLOT.response(2:end) = [];
                % Plot the figure
                if strcmp(opt.PLOT.theme, 'commercial')
                    % Plot one error filed using a much cooler theme
                    failedMethod{n, 1} = func_visualize_single_error(model, opt);
                    % If failedMethod{n, 1} is not empty => method(s) failed for this response 
                    if ~isempty(failedMethod{n, 1})
                        failedMethod{n, 2} = ['Method(s) that failed when predicting ', opt.PLOT.response{1}];
                    end
                elseif strcmp(opt.PLOT.theme, 'academic')
                    % Plot one error filed using an average academic theme
                    failedMethod{n, 1} = func_visualize_multi_errors(model, opt.PLOT.response, {}, opt.PLOT.switch);
                    % If failedMethod{n, 1} is not empty => method(s) failed for this response 
                    if ~isempty(failedMethod{n, 1})
                        failedMethod{n, 2} = ['Method(s) that failed when predicting ', opt.PLOT.response{1}];
                    end
                end
            end
        elseif strcmp(opt.PLOT.pattern, 'joint')
            % Plot multiple error fileds using an average academic theme
            failedMethod{1, 1} = func_visualize_multi_errors(model, opt.PLOT.response, {}, opt.PLOT.switch);
             % If failedMethod is not empty => method(s) failed for this response 
             if ~isempty(failedMethod)
                responseStr = strjoin(opt.PLOT.response, ', ');
                failedMethod{1, 2} = ['Method(s) that failed when predicting ', responseStr];
             end
        end
    end
% If plot 3D ranking
elseif strcmp(opt.PLOT.type, 'probability')
    failedMethod = func_plot_ProDistribution3D(model, opt);
end
% Remove the empty row(s) in failedMethod
failedMethod = func_failedMethod_removeEmpty(failedMethod);
