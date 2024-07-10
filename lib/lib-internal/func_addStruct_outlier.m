function data_with_outliers = func_addStruct_outlier(data, percentage, factor, fixRand, fixSeed)
%  Add outliers for a given data struct
%  Manner: iterate through field of the struct, adding each feature (column) some outliers
%  Input: data, struct, each field is a num_sample-by-num_feature matrix
%  Input: percentage, scalar in %, the percentage of outliers for each feature measurement
%  Input: factor, scalar the factor that will be multiplied with the original measurement to create
%  outliers.
%  Output: data_with_outliers, struct, each field is a matrix of
%  num_sample-by-num_feature with outliers

% Get the field names of the struct
fields = fieldnames(data);

% Iterate through the fields and add noise to the data
for i = 1 : numel(fields)
    data_with_outliers.(fields{i}) = func_addMatrix_outlier(data.(fields{i}), percentage, factor, fixRand, fixSeed);
end