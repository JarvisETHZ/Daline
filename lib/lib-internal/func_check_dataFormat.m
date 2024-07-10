function isValid = func_check_dataFormat(data)
% The standard Daline format requires the following structure:
% 1. The data structure should have three primary fields: 'train', 'test', and 'mpc'.
%
% 2. Both 'train' and 'test' fields should adhere to the following specifications:
%    a. They must have at least the following mandatory fields: 'P', and 'Q'.
%    b. They should contain at least one of the following optional fields: 
%       'Vm', 'Va', 'PF', 'PT', 'QF', 'QT', 'Vm2'.
%    c. All fields within 'train' or 'test' must have the same number of rows.
%    d. The fields in 'train' and 'test' should be the same, even though they 
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
mandatoryFields = {'P', 'Q'};
optionalFields = {'Vm', 'Va', 'PF', 'PT', 'QF', 'QT', 'Vm2'};
mpcFields = {'bus', 'gen', 'branch'};

% Initialize isValid variable
isValid = true;

% Check if data_check has 'train', 'test', and 'mpc' fields
if ~isfield(data, 'train') || ~isfield(data, 'test') || ~isfield(data, 'mpc')
    isValid = false;
    fprintf('The structure does not have train, test, or mpc fields.\n');
    return;
end

% Check if 'mpc' field contains the required fields
for i = 1:length(mpcFields)
    if ~isfield(data.mpc, mpcFields{i})
        isValid = false;
        fprintf('The mpc field does not contain the required field: %s.\n', mpcFields{i});
        return;
    end
end

% Check if 'train' and 'test' fields contain the mandatory fields and at least one optional field
trainFields = fieldnames(data.train);
testFields = fieldnames(data.test);

for i = 1:length(mandatoryFields)
    if ~ismember(mandatoryFields{i}, trainFields) || ~ismember(mandatoryFields{i}, testFields)
        isValid = false;
        fprintf('Either train or test field does not contain the mandatory field: %s.\n', mandatoryFields{i});
        return;
    end
end

% Check that there is at least one optional field
if ~any(ismember(optionalFields, trainFields)) || ~any(ismember(optionalFields, testFields))
    isValid = false;
    fprintf('Either train or test field does not contain at least one of the optional fields.\n');
    return;
end

% Check if train and test fields are the same
if ~isequal(sort(trainFields), sort(testFields))
    isValid = false;
    fprintf('Train and test fields are not the same.\n');
    return;
end

% Check if all fields in either train or test have the same number of rows
trainFieldLengths = cellfun(@(x) size(data.train.(x), 1), trainFields);
testFieldLengths = cellfun(@(x) size(data.test.(x), 1), testFields);

if length(unique(trainFieldLengths)) > 1 || length(unique(testFieldLengths)) > 1
    isValid = false;
    fprintf('Not all fields within train or test have the same number of rows.\n');
end

