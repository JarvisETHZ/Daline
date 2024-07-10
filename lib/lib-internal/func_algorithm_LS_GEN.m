function model = func_algorithm_LS_GEN(data, varargin)
%% Introduction
%  Training algorithm: generalized least squares
%
%  Ref.: C. Mugnier, K. Christakou, J. Jaton, M. De Vivo, M. Carpita, and 
%  M. Paolone, “Model-less/measurement-based computation of voltage 
%  sensitivities in unbalanced electrical distribution networks,” 
%  in 2016 Power Systems Computation Conference (PSCC). IEEE, 2016, 
%  pp. 1–7.
%
%  Ref.: https://www.mathworks.com/help/econ/fgls.html#buicqm5-17

%% Define the function

% Specify the algorithm
model.algorithm = 'LS_GEN';   

% Get prepared for options, predictors, responses, and their lists, indices
[opt, X_train, X_test, Y_train, Y_test, numY, ...
 model.predictorList, model.responseList, model.predictorIdx, model.responseIdx] ... 
 = func_opts_predictor_response_multiCPU(model.algorithm, data, varargin{:});

% get numbers
Ny = size(Y_train,  2);
Nx = size(X_train,  2);

% Initialize beta
Beta = zeros(Nx, Ny);  

% Solve
if opt.LSG.parallel 
    % Parallel computation
    disp(['Parallel computation starts for ', model.algorithm])
    for n = 1:Ny
        % Train
        Beta(:, n) = fgls(X_train, Y_train(:, n), 'intercept', false, 'InnovMdl', opt.LSG.InnovMdl);    
    end
else
    % Sequential computation
    backspaces = '';
    for n = 1:Ny
        % Train
        Beta(:, n) = fgls(X_train, Y_train(:, n), 'intercept', false, 'InnovMdl', opt.LSG.InnovMdl);    
        % Display progress
        backspaces = func_display_progress(model.algorithm, backspaces, 100 * n / Ny);
    end
    fprintf('\n');
end

% Get results
model.Beta = Beta;

% Test the result; similar to PLS. X_test has a column of 1s already.
Y_prediction = X_test * model.Beta;
error = abs(Y_prediction - Y_test) ./ abs(Y_test);

% Summarize error/y_pred/y_test/model type based on the options
[model.error, model.yPrediction, model.yTrue, model.type, model.note] ...
    = func_summarize_result(model.Beta, error, numY, Y_prediction, Y_test, opt);

% display
disp([model.algorithm, ' training & testing are done!'])