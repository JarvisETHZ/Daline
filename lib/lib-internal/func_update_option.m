function opt_updated = func_update_option(opt_default, opt_input)

% Ensure both inputs are structures
if ~isstruct(opt_default) || ~isstruct(opt_input)
    error('Both inputs must be structures');
end

% Get field names of both structures
defaultFields = fieldnames(opt_default);
inputFields = fieldnames(opt_input);

% Iterate over input fields and update default options where necessary
for i = 1:length(inputFields)
    field = inputFields{i};
    if ismember(field, defaultFields)
        % If the field is a structure, call func_updateOption recursively
        if isstruct(opt_input.(field))
            opt_default.(field) = func_update_option(opt_default.(field), opt_input.(field));
        else
            opt_default.(field) = opt_input.(field);
        end
    else
        warning(['Inputted parameter type ''', field, ''' you input does not exist amongst the default options and will be ignored. Note that the built-in names of parameters are case-sensitive, i.e., this warning maybe be caused by capitalization']);
    end
end

% Get the updated opt
opt_updated = opt_default;



