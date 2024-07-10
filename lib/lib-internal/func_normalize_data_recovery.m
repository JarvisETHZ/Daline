function data_recover = func_normalize_data_recovery(data, normFactor)
%% Introduction
%
%  Normalization recovery: unit energy normalization recovery
%  Manner: iterate through the fields in a struct and recover each feature in the fields. 
%  Input: data, struct, each field contains the normalized data
%  Input: normFactor, struct, each field contains normalizing factors 
%  Output: data_recover, struct, each field contains the recovered data

% Get the field names of the struct
fields = fieldnames(data);

% Iterate through the fields and recover each feature inside the
% matrix
for i = 1 : numel(fields)
    % Training data
    data_recover.(fields{i}) = data.(fields{i}) .* normFactor.(fields{i});
end
