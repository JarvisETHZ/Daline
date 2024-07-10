function [suberror, subYpred, subYtest, type, note] = func_summarize_result(beta, error, num, Y_pred, Y_test, opt)
% Separate error/y_pred/y_test based on the selection of opt.variable.response
% And, if Vm2 is in the opt.variable.response, and opt.variable.Vm22Vm = 1,
% change the error/y_pred/y_test from Vm2 to Vm 
    
% Initialize empty structures
suberror = struct();
subYpred = struct();
subYtest = struct();

% Initialize a variable to keep track of the current column index in the error matrix
current_col = 1;

% Initialize a note
note = '';

% Loop through each field in the opt.variable.response cell array
for i = 1:length(opt.variable.response)
    % Get the field name
    field_name = opt.variable.response{i};

    % Check if the field name is in the num structure
    if isfield(num, field_name)
        
        % Get the number of columns for this field
        num_cols = num.(field_name);

        % Extract the relevant columns from the error/Y_pred matrix
        suberror.(field_name) = error(:,  current_col:current_col + num_cols - 1);
        subYpred.(field_name) = Y_pred(:, current_col:current_col + num_cols - 1);
        subYtest.(field_name) = Y_test(:, current_col:current_col + num_cols - 1); 
        
        % If field_name = Vm2, and opt.variable.Vm22Vm = 1, change the error/pred/test from Vm2 to Vm,
        % also update the field name to Vm.
        if strcmp(field_name, 'Vm2') && opt.variable.Vm22Vm
            % Add field Vm
            subYpred.Vm = sqrt(subYpred.Vm2);
            subYtest.Vm = sqrt(subYtest.Vm2);
            suberror.Vm = abs(subYpred.Vm - subYtest.Vm)./abs(subYtest.Vm);
            % Remove field Vm2
            subYpred = rmfield(subYpred, 'Vm2'); 
            subYtest = rmfield(subYtest, 'Vm2');
            suberror = rmfield(suberror, 'Vm2'); 
            % Take a note for the back transformation 
            note = 'Vm2 => Vm in error/pred/true.';
        end

        % Update the current column index for the next iteration
        current_col = current_col + num_cols;
    else
        error('Field name %s is not present in num structure.', field_name);
    end
end

% Get all the error in one matrix, for the convenience of computing mean error for all kinds
suberror.all = error;

% Check empty or not
if isempty(beta)
    emptyBeta = 1;
else
    emptyBeta = 0;
end

% Check clustered or not
if iscell(beta)
    clustered = 1;
else
    clustered = 0;
end

% Check transformed or not
transMethod = func_get_transformedMethod;
if ismember(opt.method.name, transMethod) || opt.variable.lift
    transformed = 1;
else
    transformed = 0;
end

% Get model type. 1: single; 2: piecewise; 3: transformed; 4: transformed piecewise
if clustered && transformed
    type = 4;
elseif (transformed && ~clustered) || emptyBeta
    type = 3;
elseif clustered && ~transformed
    type = 2;
else
    type = 1;
end

