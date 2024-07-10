function Beta = func_solve_Hbw(X_train, Y_train, D, parallel, const, algorithm)

% get numbers
num_Y_var = size(Y_train,  2);
num_X_var = size(X_train,  2);

% Initialize beta
Beta = zeros(num_X_var, num_Y_var);  

% Training
if parallel
    % Parallel computation
    disp(['Parallel computation starts for ', algorithm])
    parfor n = 1:num_Y_var
        % Train
        Beta(:, n)  = robustfit(X_train, Y_train(:, n), 'huber', const, 'off');  % Turn off intercept because the data already have that 
    end
else
    % Sequential computation
    backspaces = '';
    for n = 1 : num_Y_var
        % Train
        Beta(:, n)  = robustfit(X_train, Y_train(:, n), 'huber', const, 'off');  % Turn off intercept because the data already have that
        % Display progress
        backspaces = func_display_progress(algorithm, backspaces, 100 * n / num_Y_var);
    end
    fprintf('\n');
end

% Combine with D from PCA
Beta = D * Beta;