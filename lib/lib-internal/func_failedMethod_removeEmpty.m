function failedMethod = func_failedMethod_removeEmpty(failedMethod)
    % Initialize an empty array to hold the indices of rows to remove
    rowsToRemove = [];

    % Iterate over each row of the cell array
    for i = 1:size(failedMethod, 1)
        % Check if all elements in the row are empty using cellfun and all
        if all(cellfun(@isempty, failedMethod(i, :)))
            % Add the index of the row to rowsToRemove
            rowsToRemove = [rowsToRemove, i];
        end
    end

    % Remove the empty rows
    failedMethod(rowsToRemove, :) = [];
end