function [error_matrix, legend_succeed, lengnd_fail] = func_generate_errorMatrix_legend(result, method, target)

% Get legend
legend_succeed = method{1};

% Find empty results
emptyCells = cellfun(@isempty, result);

% Remove empty results and legends
result(emptyCells) = [];
lengnd_fail = legend_succeed(emptyCells);
legend_succeed(emptyCells) = [];

% Create error matrix
error_matrix = [];
for n = 1 : length(legend_succeed)
    eval(['error_matrix = [error_matrix, result{n}.error.', target, '(:)];']);
end

% Find the indices of all-NaN columns
all_nan_columns = all(isnan(error_matrix));

% Get the indices of those columns
indices = find(all_nan_columns);

% Remove all-NaN columns from error_matrix
error_matrix(:, all_nan_columns) = [];

% Record and remove the methods corresponding to all-NaN columns
lengnd_fail = [lengnd_fail, legend_succeed(indices)];
legend_succeed(indices) = [];
