function [Beta, success_all] = func_solve_SVR_CC_indivi_cvx(X, Y, opt)

% Get numbers
Ns = size(Y, 1); % Number of samples
Ny = size(Y, 2); % Number of responses in Y
Nx = size(X, 2); % Number of predictors in X

% Define containers
Beta = zeros(Nx, Ny);       % Initialize the overall Beta matrix
success  = zeros(Ny, 1);

% Interact
backspaces = '';

% Set up cvx
if opt.SVRCC.cvxQuiet
    cvx_quiet(true);          % Suppress CVX output
else
    cvx_quiet(false); 
end
func_cvx_solver(opt.SVRCC.solver)  % set solver

% Solve the problem individually for each response in Y.
for j = 1 : Ny
    
    % Solve
    [beta_j, cvx_status] = func_solve_SVR_CC_indivi_cvx_j(X, Y(:, j), Nx, Ns, opt.SVRCC.epsilon, opt.SVRCC.bigM, opt.SVRCC.probThreshold);
    
    % Test if the program has been solved successfully
    if strcmp(cvx_status, 'Solved')
        % Store the results
        success(j) = 1;
        Beta(:, j) = beta_j;
    else
        % Store the results
        success(j) = 0;
        Beta(:, j) = beta_j;
    end
    
    % Display progress
    pro_str = sprintf('SVR_CCP complete percentage: %3.1f', 100 * j / Ny);
    fprintf([backspaces, pro_str]);
    backspaces = repmat(sprintf('\b'), 1, length(pro_str)); % Subtract 1 to account for the newline character
end

% Test if the program has been solved successfully
if mean(success) == 1
    success_all = 1;
else
    success_all = 0;
end

% Interact
fprintf('\n');