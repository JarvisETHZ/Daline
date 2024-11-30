function [result, Idx] = func_combine_fields(X, fullIdx, fieldNames)
% Check if X is a struct
if ~isstruct(X)
    error('Input X must be a struct');
end

% Check if fieldNames is a cell array of strings
if ~iscellstr(fieldNames)
    error('Input fieldNames must be a cell array of strings');
end

% Initialize an empty matrix to store the concatenated result
result = [];
Idx = struct();

% Iterate over the specified field names
for i = 1:length(fieldNames)
    % Check if the field name exists in X
    if ~isfield(X, fieldNames{i})
        error('Field name %s does not exist in X', fieldNames{i});
    end

    % Get the matrix associated with the current field name
    currentMatrix = X.(fieldNames{i});
    Idx.(fieldNames{i}) = fullIdx.(fieldNames{i});
    
    % Check if the currentMatrix is empty
    if isempty(currentMatrix)
        error('Field %s in the training/testing dataset is empty; this may be attributed to the filter approach used, which removed all the samples (change filter approaches or re-check your data is recommended)', fieldNames{i});
    end

    % Check if the matrix is non-empty and has the same number of rows as the result matrix
    if i > 1 && (isempty(currentMatrix) || size(currentMatrix, 1) ~= size(result, 1))
        error('All matrices must have the same number of rows');
    end

    % Concatenate the current matrix to the result matrix
    result = [result, currentMatrix];
end
