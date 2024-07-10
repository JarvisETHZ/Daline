function data_plusNoise = func_addMatrix_wgNoise(data, SNR_dB, fixRand, fixSeed)
%  Add white Gaussian noise of a given matrix
%  Input: data, double matrix, num_sample-by-num_feature, the original data
%  Input: SNR_dB, double scalar, Signal-to-Noise Ratio (SNR) in decibels (dB)
%  Output: data_plusNoise, double matrix, num_sample-by-num_feature, the noisy data
%  Note: the noise for each column of data satisfies the given SNR_dB

% Get the size of the data
[num_sample, num_feature] = size(data);

% Initialize the noisy data
data_plusNoise = zeros(size(data));

% Iterate through each feature (column) and add noise
for i = 1:num_feature
    
    % Extract the current feature
    feature = data(:, i);

    % Calculate the power of the feature
    signal_power = mean(feature.^2);

    % Convert SNR from dB to linear scale
    SNR_linear = 10^(SNR_dB / 10);

    % Calculate the noise power based on the given SNR
    noise_power = signal_power / SNR_linear;
    
    % Fix randomness
    if fixRand
        rng(fixSeed)
    end

    % Generate white Gaussian noise with the calculated noise power
    noise = sqrt(noise_power) * randn(num_sample, 1);

    % Add the noise to the feature
    data_plusNoise(:, i) = feature + noise;
end


