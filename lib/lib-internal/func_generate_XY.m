function [X, Y, varargout] = func_generate_XY(data)
%% Introduction
% 
%  Generate datasets for inputs and outputs (independent and dependent) 
%  Each field is num_sample-by-num_variable

% Identify bus types
[ref, pv, pq] = bustypes(data.mpc.bus, data.mpc.gen);
pvq = [pv; pq];
pvr = [pv; ref];

% Initialize predictor and response indices
predictorIdx = struct();
responseIdx = struct();

%% Training data X, Y
X.train = struct();
Y.train = struct();

% Assign known to X for the training data
[X.train.P, predictorIdx] = safeAssign(data.train, 'P', pvq, predictorIdx, 'P');
[X.train.Q, predictorIdx] = safeAssign(data.train, 'Q', pq, predictorIdx, 'Q');
[X.train.Vm, predictorIdx] = safeAssign(data.train, 'Vm', pvr, predictorIdx, 'Vm');
[X.train.Vm2, predictorIdx] = safeAssign(data.train, 'Vm2', pvr, predictorIdx, 'Vm2');
[X.train.Va, predictorIdx] = safeAssign(data.train, 'Va', ref, predictorIdx, 'Va');

[Y.train.Vm, responseIdx] = safeAssign(data.train, 'Vm', pq, responseIdx, 'Vm');
[Y.train.Vm2, responseIdx] = safeAssign(data.train, 'Vm2', pq, responseIdx, 'Vm2');
[Y.train.Va, responseIdx] = safeAssign(data.train, 'Va', pvq, responseIdx, 'Va');
[Y.train.PF, responseIdx] = safeAssign(data.train, 'PF', 1:size(data.mpc.branch, 1), responseIdx, 'PF');
[Y.train.PT, responseIdx] = safeAssign(data.train, 'PT', 1:size(data.mpc.branch, 1), responseIdx, 'PT');
[Y.train.QF, responseIdx] = safeAssign(data.train, 'QF', 1:size(data.mpc.branch, 1), responseIdx, 'QF');
[Y.train.QT, responseIdx] = safeAssign(data.train, 'QT', 1:size(data.mpc.branch, 1), responseIdx, 'QT');
[Y.train.P, responseIdx] = safeAssign(data.train, 'P', ref, responseIdx, 'P');
[Y.train.Q, responseIdx] = safeAssign(data.train, 'Q', pvr, responseIdx, 'Q');

% Combine all fields
X.train.all = concatenateFields(X.train);
Y.train.all = concatenateFields(Y.train);

%% Testing data X, Y
X.test = struct();
Y.test = struct();

[X.test.P, predictorIdx] = safeAssign(data.test, 'P', pvq, predictorIdx, 'P');
[X.test.Q, predictorIdx] = safeAssign(data.test, 'Q', pq, predictorIdx, 'Q');
[X.test.Vm, predictorIdx] = safeAssign(data.test, 'Vm', pvr, predictorIdx, 'Vm');
[X.test.Vm2, predictorIdx] = safeAssign(data.test, 'Vm2', pvr, predictorIdx, 'Vm2');
[X.test.Va, predictorIdx] = safeAssign(data.test, 'Va', ref, predictorIdx, 'Va');

[Y.test.Vm, responseIdx] = safeAssign(data.test, 'Vm', pq, responseIdx, 'Vm');
[Y.test.Vm2, responseIdx] = safeAssign(data.test, 'Vm2', pq, responseIdx, 'Vm2');
[Y.test.Va, responseIdx] = safeAssign(data.test, 'Va', pvq, responseIdx, 'Va');
[Y.test.PF, responseIdx] = safeAssign(data.test, 'PF', 1:size(data.mpc.branch, 1), responseIdx, 'PF');
[Y.test.PT, responseIdx] = safeAssign(data.test, 'PT', 1:size(data.mpc.branch, 1), responseIdx, 'PT');
[Y.test.QF, responseIdx] = safeAssign(data.test, 'QF', 1:size(data.mpc.branch, 1), responseIdx, 'QF');
[Y.test.QT, responseIdx] = safeAssign(data.test, 'QT', 1:size(data.mpc.branch, 1), responseIdx, 'QT');
[Y.test.P, responseIdx] = safeAssign(data.test, 'P', ref, responseIdx, 'P');
[Y.test.Q, responseIdx] = safeAssign(data.test, 'Q', pvr, responseIdx, 'Q');

% Combine all fields
X.test.all = concatenateFields(X.test);
Y.test.all = concatenateFields(Y.test);

%% Output predictor and response indices if requested
if nargout > 2
    varargout{1} = predictorIdx;
end
if nargout > 3
    varargout{2} = responseIdx;
end

end

%% Helper function: Safely assign fields and update indices
function [output, idxStruct] = safeAssign(input, field, idx, idxStruct, idxName)
    if isfield(input, field)
        output = input.(field)(:, idx);
        idxStruct.(idxName) = idx;
    else
        output = [];
    end
end

%% Helper function: Concatenate fields
function combined = concatenateFields(structData)
    fields = fieldnames(structData);
    combined = [];
    for i = 1:length(fields)
        combined = [combined, structData.(fields{i})]; %#ok<AGROW>
    end
end
