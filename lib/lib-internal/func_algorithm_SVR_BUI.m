function model = func_algorithm_SVR_BUI(data, varargin)
% func_algorithm_SVR - Perform linear regression using the ordinary Support
% Vector Regression (SVR) with linear kernel

%% Start

% Specify the algorithm
model.algorithm = 'SVR_BUI';

% Get prepared for options, predictors, responses, and their lists, indices
[opt, X_train, X_test, Y_train, Y_test, numY, ...
 model.predictorList, model.responseList, model.predictorIdx, model.responseIdx] ... 
 = func_opts_predictor_response_multiCPU(model.algorithm, data, varargin{:});

% get numbers
num_Y_var = size(Y_train,  2);
num_X_var = size(X_train,  2);

% Initialize containers
Beta = zeros(num_X_var, num_Y_var);  % because of the column of 1s

% train the result
if opt.SVR.parallel 
    % Parallel computation
    disp('Parallel computation starts for SVR_BUI')
    if opt.SVR.tune
        % Display
        disp('Pallelization starts to tune epsilon in SVR_BUI')
        % Tune & train & test
        parfor n = 1 : num_Y_var
            % Train and test the SVR model using optimized tuning for epsilon
            model_temp = fitrsvm(X_train, Y_train(:, n), 'OptimizeHyperparameters', 'epsilon', 'HyperparameterOptimizationOptions', struct('KFold', opt.SVR.KFold, 'ShowPlots', false, 'Verbose', 0));
            Beta(:, n) = model_temp.Beta;            
        end
    elseif opt.SVR.default
        for n = 1 : num_Y_var
            % Train and test the SVR model using default epsilon
            model_temp = fitrsvm(X_train, Y_train(:, n));
            Beta(:, n) = model_temp.Beta;
        end
    else
        for n = 1 : num_Y_var
            % Train and test the SVR model using the user-defined epsilon
            model_temp = fitrsvm(X_train, Y_train(:, n), 'Epsilon', opt.SVR.epsilon);
            Beta(:, n) = model_temp.Beta;
        end
    end
else
    % Sequential computation
    backspaces = '';
    if opt.SVR.tune
        % Display
        disp('Start to tune epsilon in SVR_BUI')
        % Tune & train & test
        for n = 1 : num_Y_var
            % Train and test the SVR model using optimized tuning for epsilon
            model_temp = fitrsvm(X_train, Y_train(:, n), 'OptimizeHyperparameters', 'epsilon', 'HyperparameterOptimizationOptions', struct('KFold', opt.SVR.KFold, 'ShowPlots', false, 'Verbose', 0));
            Beta(:, n) = model_temp.Beta;
            % Display progress
            backspaces = func_display_progress(model.algorithm, backspaces, 100 * n / num_Y_var);
        end
    elseif opt.SVR.default
        for n = 1 : num_Y_var
            % Train and test the SVR model using default epsilon
            model_temp = fitrsvm(X_train, Y_train(:, n));
            Beta(:, n) = model_temp.Beta;
            % Display progress
            backspaces = func_display_progress(model.algorithm, backspaces, 100 * n / num_Y_var);
        end
    else
        for n = 1 : num_Y_var
            % Train and test the SVR model using the user-defined epsilon
            model_temp = fitrsvm(X_train, Y_train(:, n), 'Epsilon', opt.SVR.epsilon);
            Beta(:, n) = model_temp.Beta;
            % Display progress
            backspaces = func_display_progress(model.algorithm, backspaces, 100 * n / num_Y_var);
        end
    end
    fprintf('\n');
end

% Get the trained model
model.Beta = Beta;

% test the result
Y_prediction = X_test * model.Beta;
error = abs(Y_prediction - Y_test) ./ abs(Y_test);

% Summarize error/y_pred/y_test/model type based on the options
[model.error, model.yPrediction, model.yTrue, model.type, model.note] ...
    = func_summarize_result(model.Beta, error, numY, Y_prediction, Y_test, opt);

% display
disp([model.algorithm, ' training & testing are done!'])
