function data_plusNoise = func_addStruct_wgNoise(data, SNR_dB, fixRand, fixSeed)
%  Add white Gaussian noise for a given data struct
%  Input: data, struct, each field is a double matrix with num_sample-by-num_feature
%  Input: SNR_dB, double scalar, Signal-to-Noise Ratio (SNR) in decibels (dB)
%  Output: data_plusNoise, struct, each field is a double noisy matrix with num_sample-by-num_feature
%  Note: the noise for each column of each field satisfies the given SNR_dB

% Get the field names of the struct
fields = fieldnames(data);

% Iterate through the fields and add noise to the data
for i = 1 : numel(fields)
    data_plusNoise.(fields{i}) = func_addMatrix_wgNoise(data.(fields{i}), SNR_dB, fixRand, fixSeed);
end