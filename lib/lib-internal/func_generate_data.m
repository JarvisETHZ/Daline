function data = func_generate_data(opt)  
%  Training/testing data generation based on the inputted user settings.
%  Each field of the output data is num_sample-by-num_variable

%% Start

% Data generation
switch opt.data.baseType
    case 'Random'
        % Generate the training/testing data randomly
        if opt.data.parallel
            % Parallel generation
            [data, count] = func_generate_dataRandom_parallel(opt);
        else
            % Sequential generation
            [data, count] = func_generate_dataRandom(opt);
        end
    case 'TimeSeries'
        % Generate the time series training/testing data
        if opt.data.parallel
            % Parallel generation
            [data, count] = func_generate_dataTimeSeries_parallel(opt);
        else
            % Sequential generation
            [data, count] = func_generate_dataTimeSeries(opt);
        end
    case 'TimeSeriesRand'
        % Generate the time series training/testing data with randomness
        if opt.data.parallel
            % Parallel generation
            [data, count] = func_generate_dataTimeSeriesRandom_parallel(opt);
        else
            % Sequential generation
            [data, count] = func_generate_dataTimeSeriesRandom(opt);
        end
end

% tell users whether the expected number of data points was achieved
if count >= opt.num.trainSample + opt.num.testSample
    % display
    disp('Data generation got the expected number of data points')
    disp(['Number of training data points: ', num2str(size(data.train.P, 1))]);
    disp(['Number of testing data points: ',  num2str(size(data.test.P, 1))]);
else
    % display
    disp('Data generation did not get the expected number of data points because of ACPF or ACOPF failures!')
    disp(['Number of training data points: ', num2str(size(data.train.P, 1))]);
    disp(['Number of testing data points: ',  num2str(size(data.test.P, 1))]);
end

% Finally, attach mpc to data => after data generation, the following
% command will read mpc from data.mpc if needed, not from opt.mpc, just in
% case the mismatch when users are calling some functions but accidentally
% use the default case, which might not match the data they generated.
data.mpc = opt.mpc;
