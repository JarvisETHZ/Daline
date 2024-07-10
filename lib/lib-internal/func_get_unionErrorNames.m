function unionFieldNames = func_get_unionErrorNames(model)
    % If model is a struct, convert it into a cell
    if isstruct(model)
        model_temp{1} = model;
        model = model_temp;
    end
    
    % Initialize an empty cell array to store all field names
    allFieldNames = {};

    % Iterate through each cell in the model
    for i = 1:length(model)
        % Check if the 'error' field exists in the current cell element
        if isfield(model{i}, 'error')
            % Get field names of the 'error' structure
            fieldNames = fieldnames(model{i}.error);

            % Append these field names to the list of all field names
            allFieldNames = [allFieldNames; fieldNames];
        end
    end

    % Find the union of all field names
    unionFieldNames = unique(allFieldNames);
    unionFieldNames = unionFieldNames';
end
