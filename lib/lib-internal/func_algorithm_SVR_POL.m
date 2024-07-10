function model = func_algorithm_SVR_POL(data, varargin)
% func_algorithm_SVR - Perform linear regression using Support Vector
% Regression (SVR) with polynomial kernel

%% Start

% Specify the algorithm
model.algorithm = 'SVR_POL';

% Get prepared for options, predictors, responses, and their lists, indices
[opt, X_train, X_test, Y_train, Y_test, numY, ...
 model.predictorList, model.responseList, model.predictorIdx, model.responseIdx] ... 
 = func_opts_predictor_response_multiCPU(model.algorithm, data, varargin{:});

% get numbers
num_Y_var = size(Y_train,  2);

% Initialize containers
error = zeros(size(Y_test));         
Y_prediction = zeros(size(Y_test));

% train and test the result
if opt.SVR.parallel 
    % Parallel computation
    disp('Parallel computation starts for SVR_POL')
    if opt.SVR.tune
        % Display
        disp('Pallelization starts to tune epsilon in SVR_POL')
        % Tune & train & test
        parfor n = 1 : num_Y_var
            % Train and test the SVR model using optimized tuning for epsilon
            model_temp = fitrsvm(X_train, Y_train(:, n), 'KernelFunction', 'polynomial', 'OptimizeHyperparameters', 'epsilon', 'HyperparameterOptimizationOptions', struct('KFold', opt.SVR.KFold, 'ShowPlots', false, 'Verbose', 0));
            Y_prediction(:, n) = predict(model_temp, X_test);
            error(:, n) = abs(Y_prediction(:, n) - Y_test(:, n)) ./ abs(Y_test(:, n));
        end
    elseif opt.SVR.default
        % Use default epsilon
        parfor n = 1 : num_Y_var
            % Train and test the SVR model using default epsilon
            model_temp = fitrsvm(X_train, Y_train(:, n), 'KernelFunction', 'polynomial');
            Y_prediction(:, n) = predict(model_temp, X_test);
            error(:, n) = abs(Y_prediction(:, n) - Y_test(:, n)) ./ abs(Y_test(:, n));
        end
    else
        % Use given epsilon
        parfor n = 1 : num_Y_var
            % Train and test the SVR model using the user-defined epsilon
            model_temp = fitrsvm(X_train, Y_train(:, n), 'KernelFunction', 'polynomial', 'Epsilon', opt.SVR.epsilon);
            Y_prediction(:, n) = predict(model_temp, X_test);
            error(:, n) = abs(Y_prediction(:, n) - Y_test(:, n)) ./ abs(Y_test(:, n));
        end
    end
else
    % Sequential computation
    backspaces = '';
    if opt.SVR.tune
        % Display
        disp('Start to tune epsilon in SVR_POL')
        % Tune & train & test
        for n = 1 : num_Y_var
            % Train and test the SVR model using optimized tuning for epsilon
            model_temp = fitrsvm(X_train, Y_train(:, n), 'KernelFunction', 'polynomial', 'OptimizeHyperparameters', 'epsilon', 'HyperparameterOptimizationOptions', struct('KFold', opt.SVR.KFold, 'ShowPlots', false, 'Verbose', 0));
            Y_prediction(:, n) = predict(model_temp, X_test);
            error(:, n) = abs(Y_prediction(:, n) - Y_test(:, n)) ./ abs(Y_test(:, n));
            % Display progress
            backspaces = func_display_progress(model.algorithm, backspaces, 100 * n / num_Y_var);
        end
    elseif opt.SVR.default
        % Use default epsilon
        for n = 1 : num_Y_var
            % Train and test the SVR model using default epsilon
            model_temp = fitrsvm(X_train, Y_train(:, n), 'KernelFunction', 'polynomial');
            Y_prediction(:, n) = predict(model_temp, X_test);
            error(:, n) = abs(Y_prediction(:, n) - Y_test(:, n)) ./ abs(Y_test(:, n));
            % Display progress
            backspaces = func_display_progress(model.algorithm, backspaces, 100 * n / num_Y_var);
        end
    else
        % Use given epsilon
        for n = 1 : num_Y_var
            % Train and test the SVR model using the user-defined epsilon
            model_temp = fitrsvm(X_train, Y_train(:, n), 'KernelFunction', 'polynomial', 'Epsilon', opt.SVR.epsilon);
            Y_prediction(:, n) = predict(model_temp, X_test);
            error(:, n) = abs(Y_prediction(:, n) - Y_test(:, n)) ./ abs(Y_test(:, n));
            % Display progress
            backspaces = func_display_progress(model.algorithm, backspaces, 100 * n / num_Y_var);
        end
    end
    fprintf('\n');
end

% Get the trained model => no Beta actually because of the polynomial fitting
model.Beta = [];

% Summarize error/y_pred/y_test/model type based on the options
[model.error, model.yPrediction, model.yTrue, model.type, model.note] ...
    = func_summarize_result(model.Beta, error, numY, Y_prediction, Y_test, opt);

% display
disp([model.algorithm, ' training & testing are done!'])
