%% Introduction
%
%  Iterate through the fields in a struct and transpose each matrix in it.

function data = func_transpose_struct(data)
% Get the field names of the struct
fields = fieldnames(data);

% Iterate through the fields and transpose each matrix
for i = 1:numel(fields)
    data.(fields{i}) = data.(fields{i})';
end
