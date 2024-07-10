function normFactor = func_normalize_factor(data)
%% Introduction
%
%  Normalizing factor from unit energy normalization
%  Manner: iterate through the fields in a struct and compute the factor for each feature in the fields. 
%  Input: struct data, where each field is a num_sample-by-num_variable matrix
%  Output: struct normFactor, where each field is a row vector of 1-by-num_variable
%  Note that here we use data.train to generate the normFactor and use it
%  for testing data as well


% Get the field names of the struct
fields = fieldnames(data);

% Iterate through the fields and compute the normalizing factor for each
% column (variable)
for i = 1 : numel(fields)
    
    % Square the values
    data_square = data.(fields{i}).^2;
    
    % Sum the values of each column
    data_square_sum = sum(data_square, 1); 
    
    % Compute the sqrt of row data_square_sum => the normalizing_factor
    % for each variable (column)
    normFactor.(fields{i}) = sqrt(data_square_sum);
end
