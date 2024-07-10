function data_filtered = func_filStruct_wgNoise(datafield, opt)
% Create an empty struct to store the filtered data
data_filtered = struct();

% Filter noise for every feature in every subfield in 'datafield'
nameList = fieldnames(datafield);
for i = 1:length(nameList)
    % Get the field
    field_name = nameList{i};
    % For each field, filter noise for each feature
    [Ns, Nf] = size(datafield.(field_name));
    % If use zero as the initial value, then in the filtered output, the first row will be all zero and will be removed 
    if opt.filNoi.zeroInitial
        data_filtered.(field_name) = zeros(Ns-1, Nf);
    else
        data_filtered.(field_name) = zeros(Ns, Nf);
    end
    % Filter
    for j = 1:Nf
        data_filtered.(field_name)(:, j) = func_filMatrix_wgNoise(datafield.(field_name)(:, j), opt.filNoi.est_dB, opt.filNoi.useARModel, opt.filNoi.orderNum, opt.filNoi.proNoiseLevel, opt.filNoi.zeroInitial);
    end
end


