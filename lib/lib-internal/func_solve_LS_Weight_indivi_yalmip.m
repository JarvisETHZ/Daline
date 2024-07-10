function [Beta, success_all] = func_solve_LS_Weight_indivi_yalmip(X, Y, omega, Display, solver, parallel)

% Get numbers
[Ns, Ny] = size(Y); % Number of samples and responses in Y
Nx = size(X, 2);    % Number of predictors in X

% Define containers
Beta = zeros(Nx, Ny);       % Initialize the overall Beta matrix
success  = zeros(Ny, 1);

% Form the weight vector; Ns-by-1
Omega = zeros(Ns, 1);
for n = 1:Ns
    Omega(n) = omega^(Ns-n);
end

% Set up YALMIP and solver options
options = sdpsettings('solver', solver, 'verbose', Display); % Set solver and suppress output

% Solve the problem individually for each response in Y.
if parallel
    % parallelly solving
    disp('Parallel computing starts to solve LS_WEI')
    parfor j = 1 : Ny
        % Solve it using yalmip
        [beta_j, status] = func_solve_LS_Weight_indivi_yalmip_j(X, Y(:, j), Nx, Omega, options);
        % Test if the program has been solved successfully
        if status == 1
            % Store the results
            success(j) = 1;
            Beta(:, j) = beta_j;
        else
            % Store the results
            success(j) = 0;
            Beta(:, j) = beta_j;
        end
    end
else
    % Sequential solving
    backspaces = '';
    for j = 1 : Ny
        % Solve it using yalmip
        [beta_j, status] = func_solve_LS_Weight_indivi_yalmip_j(X, Y(:, j), Nx, Omega, options);
        % Test if the program has been solved successfully
        if status == 1
            % Store the results
            success(j) = 1;
            Beta(:, j) = beta_j;
        else
            % Store the results
            success(j) = 0;
            Beta(:, j) = beta_j;
        end
        % Display progress
        pro_str = sprintf('LS_weight complete percentage: %3.1f', 100 * j / Ny);
        fprintf([backspaces, pro_str]);
        backspaces = repmat(sprintf('\b'), 1, length(pro_str)); % Subtract 1 to account for the newline character
    end
    fprintf('\n');
end

% Test if the program has been solved successfully
if mean(success) == 1
    success_all = 1;
else
    success_all = 0;
end
