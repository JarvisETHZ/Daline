function data_with_outliers = func_addMatrix_outlier(data, percentage, factor, fixRand, fixSeed)
%  Add outliers to the measurements of each feature in a matrix.
%  Manner: iterate through each feature (column) and add outliers, because
%  measurement mistakes should happen at the same time in the same sample.
%  Input: data, double matrix, num_sample-by-num_feature
%  Input: percentage, scalar in %, the percentage of outliers for each feature measurement
%  Input: factor, scalar the factor that will be multiplied with the original measurement to create
%  outliers.
%  Output: data with outliers, double matrix, num_sample-by-num_feature

% Get the size of the data matrix
[num_sample, num_feature] = size(data);

% Number of outliers for each feature
num_outliers = round(num_sample * percentage / 100);

% Initialize the output matrix
data_with_outliers = data;

% Iterate through each feature (column) and add outliers (measurement mistake)
for i = 1:num_feature
    % Fix randomness
    if fixRand
        rng(fixSeed)
    end

    % Randomly select points to be outliers
    outlier_indices = randperm(num_sample, num_outliers);

    % Modify the selected points
    data_with_outliers(outlier_indices, i) = data(outlier_indices, i) * factor; 
end
