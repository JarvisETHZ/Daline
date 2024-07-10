function data_filtered = func_filStruct_outlier(dataStruct, opt)
%
% Note
%
% Unless opt.outlier.percentage is tiny, the majority of observations would
% be recognized as outliers, as the outliers are generated individually for
% each feature. 
%
% In A Data-Driven Method for Online Constructing Linear Power Flow Model,
% the authors haven't removed outliers, but consider them as large noise.
% By increasing the estimated noise level, they filter outliers using
% Kalman filter. I.e., "In this paper, to maintain the measurement
% redundancy, we recover it to an approximately theoretical value instead
% of deleting it directly."   


%% Start
% Create an empty struct to store the filtered data
data_filtered = struct();

% Filter noise for every feature in every subfield in 'datafield'
nameList = fieldnames(dataStruct);

% Put all fields together
dataAll = [];
for i = 1:length(nameList)
    % Get the field
    field_name = nameList{i};
    % Collect the data in the field
    dataAll = [dataAll, dataStruct.(field_name)];
end

% Get th indices for outliers. Outlier detection is done along each column
% (feature) individually. 
idxOutlier = isoutlier(dataAll, opt.filOut.method, "ThresholdFactor", opt.filOut.tol);
[idxOutRow, ~] = find(idxOutlier);

% Remove the rows (observations) with outliers, for each field
for i = 1:length(nameList)
    % Get the field
    field_name = nameList{i};
    % Remove rows with outliers
    data_filtered.(field_name) = dataStruct.(field_name);
    data_filtered.(field_name)(idxOutRow, :) = [];
end
