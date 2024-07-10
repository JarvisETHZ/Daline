function model = func_algorithm_PLS_REP(data, varargin)
%  Training algorithm: Repeated partial least squares, based on NIPALS, as
%  a comparison with the recursive partial least squares

%% Start

% Specify the algorithm
model.algorithm = 'PLS_REP';

% Get prepared for options, predictors, responses, and their lists, indices
[opt, X_train, X_test, Y_train, Y_test, numY, ...
 model.predictorList, model.responseList, model.predictorIdx, model.responseIdx] ... 
 = func_opts_predictor_response_singleCPU(model.algorithm, data, varargin{:});

% Get numbers
[num_sample, ~] = size(X_train);
percentage = opt.PLS.recursivePercentage;
num_new = round(num_sample * percentage / 100);
num_old = num_sample - num_new;

% Interact
backspaces = '';

% Record time
tic

% Repeatedly training to include each new data point, from n=0
for n = 0:num_new
    % Get the dataset for the moment
    X_moment = X_train(1:num_old+n, :);
    Y_moment = Y_train(1:num_old+n, :);
    % Train the regression model
    [~, ~, ~, ~, ~, ~, Beta] = func_pls_NIPALS(X_moment, Y_moment, opt);
    % Display progress
    backspaces = func_display_progress(model.algorithm, backspaces, 100 * n / num_new);
end
fprintf('\n');

% Get the final Beta result (here we only save the final Beta, as comparison with other methods)
model.Beta = Beta;

% Record time
model.trainTime = toc;

% test the result (here we only test the error of the final Beta, as comparison with other methods)
Y_prediction = X_test * model.Beta;
error = abs(Y_prediction - Y_test) ./ abs(Y_test);

% Summarize error/y_pred/y_test/model type based on the options
[model.error, model.yPrediction, model.yTrue, model.type, model.note] ...
    = func_summarize_result(model.Beta, error, numY, Y_prediction, Y_test, opt);

% display
disp([model.algorithm, ' training & testing are done!'])