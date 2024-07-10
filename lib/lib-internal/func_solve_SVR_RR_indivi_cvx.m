function [Beta, success_all] = func_solve_SVR_RR_indivi_cvx(X, Y, opt)

% Get numbers
Ns = size(Y, 1); % Number of responses in Y
Ny = size(Y, 2); % Number of responses in Y
Nx = size(X, 2); % Number of predictors in X

% Define containers
Beta = zeros(Nx, Ny);       % Initialize the overall Beta matrix
success  = zeros(Ny, 1);

% Interact
backspaces = '';

% Set up cvx
if opt.SVR.cvxQuiet
    cvx_quiet(true);          % Suppress CVX output
    disp('cvx starts to solve SVR_RR')
else
    cvx_quiet(false); 
end
func_cvx_solver(opt.SVR.solver)  % set solver

% Solve the problem individually for each response in Y.
for j = 1 : Ny
    
    % Start CVX 
    cvx_begin
         % Define decision variables for the j-th response
        variable beta_j(Nx, 1)
        variable zi_j(Ns, 1) nonnegative
        variable zi_j_star(Ns, 1) nonnegative

        % Objective function
        J_j = (0.5 + opt.SVR.lambda) * sum(beta_j.^2) + opt.SVR.omega * sum(zi_j + zi_j_star);
        minimize(J_j)

        % Constraints for the j-th response
        subject to
            Y(:, j) - X * beta_j <= opt.SVR.epsilon + zi_j;
            X * beta_j - Y(:, j) <= opt.SVR.epsilon + zi_j_star;
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
    pro_str = sprintf('SVR_RR programming complete percentage: %3.1f', 100 * j / Ny);
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