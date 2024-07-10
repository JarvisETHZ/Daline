function value = func_get_namedValue(targetName, varargin)
    % Initialize the default value or a flag indicating the value is not found
    value = []; 

    % Iterate through the varargin inputs
    for k = 1:2:length(varargin)
        % Check if the current argument matches the target name
        if strcmp(varargin{k}, targetName)
            % If found, assign its value to 'value'
            value = varargin{k + 1};
            break;  % Exit the loop as we found the value
        end
    end

    % Check if value was found and handle accordingly
    if isempty(value)
        value = [];
    end
end