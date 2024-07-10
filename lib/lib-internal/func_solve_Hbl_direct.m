function [Beta, exitflag] = func_solve_Hbl_direct(X_train, Y_train, parallel, delta, initialGuess, directOptions, algorithm)

% get numbers
num_Y_var = size(Y_train,  2);
num_X_var = size(X_train,  2);

% Initialize containers
Beta = zeros(num_X_var, num_Y_var);  % because of the column of 1s
exitflag = zeros(num_Y_var, 1); 

% Solve
if parallel
    % Parallel computation
    disp(['Parallel computation starts for ', algorithm])
    parfor n = 1:num_Y_var
        % Train
        [Beta(:, n), exitflag(n)] = func_fit_Hbl_direct(X_train, Y_train(:, n), delta, initialGuess, directOptions);  
    end
else
    % Sequential computation
    backspaces = '';
    for n = 1 : num_Y_var
        % Train
        [Beta(:, n), exitflag(n)] = func_fit_Hbl_direct(X_train, Y_train(:, n), delta, initialGuess, directOptions);  
        % Display progress
        backspaces = func_display_progress(algorithm, backspaces, 100 * n / num_Y_var);
    end
    fprintf('\n');
end