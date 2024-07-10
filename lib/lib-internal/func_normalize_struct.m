function data_norm = func_normalize_struct(data, normFactor)
%% Introduction
%
%  Normalization: unit energy normalization
%  Manner: iterate through the fields in a struct and normalize each feature in the fields. 
%  Input: data, struct, each field contains the original data
%  Input: normFactor, struct, each field contains normalizing factors 
%  Output: data_norm, struct, each field contains the normalized data

% Get the field names of the struct
fields = fieldnames(data);

% Iterate through the fields and normalize each feature inside the
% matrix
for i = 1 : numel(fields)
    % Training data
    data_norm.(fields{i}) = data.(fields{i}) ./ normFactor.(fields{i});
end
    
