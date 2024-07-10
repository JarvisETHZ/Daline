function [Beta, success_all] = func_solve_LS_Weight_indivi_cvx(X, Y, omega, cvxQuiet, solver)

% Get numbers
Ns = size(Y, 1); % Number of responses in Y
Ny = size(Y, 2); % Number of responses in Y
Nx = size(X, 2); % Number of predictors in X

% Define containers
Beta = zeros(Nx, Ny);       % Initialize the overall Beta matrix
success  = zeros(Ny, 1);

% form the weight vector; Ns-by-1
Omega = zeros(Ns, 1);
for n = 1:Ns
    Omega(n) = omega^(Ns-n);
end

% Interact
backspaces = '';

% Set up cvx
if cvxQuiet
    cvx_quiet(true);          % Suppress CVX output
    disp('cvx starts to solve LS_WEI')
else
    cvx_quiet(false); 
end
func_cvx_solver(solver)  % set solver

% Solve the problem individually for each response in Y.
for j = 1 : Ny
    
    % Start CVX 
    cvx_begin
         % Define decision variables for the j-th response
        variable beta_j(Nx, 1)      

        % Objective function
        minimize(sum((Omega .* (Y(:, j) - X * beta_j)).^2))

    cvx_end

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
    pro_str = sprintf('LS_weight complete percentage: %3.1f', 100 * j / Ny);
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