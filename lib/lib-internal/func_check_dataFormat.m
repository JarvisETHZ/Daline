function isValid = func_check_dataFormat(data)
% The standard Daline format requires the following structure:
% 1. The data structure should have three primary fields: 'train', 'test', and 'mpc'.
%
% 2. Both 'train' and 'test' fields should adhere to the following specifications:
%    a. All fields within 'train' or 'test' must have the same number of rows.
%    b. The fields in 'train' and 'test' should be the same, even though they 
%       can have a different number of rows.
%
% 3. The 'mpc' field should be a structure containing at least the following fields:
%    a. 'bus'
%    b. 'gen'
%    c. 'branch'
%
% Note: Additional fields or variations may need to be accounted for based on further
% specific use-case needs or adaptations of the Daline format.


% Define the mandatory fields
mpcFields = {'bus', 'gen', 'branch'};
trainFields = fieldnames(data.train);
testFields = fieldnames(data.test);

% Initialize isValid variable
isValid = true;

% Check if data_check has 'train', 'test', and 'mpc' fields
if ~isfield(data, 'train') || ~isfield(data, 'test') || ~isfield(data, 'mpc')
    isValid = false;
    error('The structure does not have train, test, or mpc fields.\n');
    return;
end

% Check if 'mpc' field contains the required fields
for i = 1:length(mpcFields)
    if ~isfield(data.mpc, mpcFields{i})
        isValid = false;
        error('The mpc field does not contain the required field: %s.\n', mpcFields{i});
        return;
    end
end

% Check if train and test fields are the same
if ~isequal(sort(trainFields), sort(testFields))
    isValid = false;
    error('Train and test fields are not the same.\n');
    return;
end

% Check if all fields in either train or test have the same number of rows
trainFieldLengths = cellfun(@(x) size(data.train.(x), 1), trainFields);
testFieldLengths = cellfun(@(x) size(data.test.(x), 1), testFields);

if length(unique(trainFieldLengths)) > 1 || length(unique(testFieldLengths)) > 1
    isValid = false;
    error('Not all fields within train or test have the same number of rows.\n');
end

