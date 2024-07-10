function Beta = func_tune_Hbw_cv(X_train, Y_train, parallel, const)

% get numbers
num_Y_var = size(Y_train,  2);
num_X_var = size(X_train,  2);

% Initialize beta
Beta = zeros(num_X_var, num_Y_var);  

% Training
if parallel
    % Parallel computation
    parfor n = 1:num_Y_var
        % Train
        Beta(:, n)  = robustfit(X_train, Y_train(:, n), 'huber', const, 'off');  % Turn off intercept because the data already have that 
    end
else
    % Sequential computation
    for n = 1 : num_Y_var
        % Train
        Beta(:, n)  = robustfit(X_train, Y_train(:, n), 'huber', const, 'off');  % Turn off intercept because the data already have that
    end
end