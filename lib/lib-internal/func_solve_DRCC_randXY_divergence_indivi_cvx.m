function [Beta, success_all] = func_solve_DRCC_randXY_divergence_indivi_cvx(X, Y, opt, alpha)

% Get numbers
Ns = size(Y, 1); % Number of samples
Ny = size(Y, 2); % Number of responses in Y
Nx = size(X, 2); % Number of predictors in X

% Get idx of star
idx_star = opt.DRC.starIDX;
if strcmp(idx_star, 'end')
   idx_star = size(X, 1);  % If opt.DRC.starIDX = 'end', take the last sample in X as the star sample
end

% Get the selected point
y_star = Y(idx_star, :);
x_star = X(idx_star, :);

% Define containers
Beta = zeros(Nx, Ny);       % Initialize the overall Beta matrix
success  = zeros(Ny, 1);

% Interact
backspaces = '';

% Set up cvx
if opt.DRC.cvxQuiet
    cvx_quiet(true);             % Suppress CVX output
    disp('cvx starts to solve DRC_XYD')
else
    cvx_quiet(false); 
end
func_cvx_solver(opt.DRC.solverD)  % set solver

% Solve the problem individually for each response in Y.
for j = 1 : Ny
    
    % Start CVX 
    cvx_begin
        % Define decision variables
        variable beta_j(Nx, 1)
        variable z_j(Ns, 1) binary

        % Objective function. Note that y_star(j) - x_star * beta_j is a
        % scalar value => still using norms may lead to infeasibility from
        % the perspective of cvx, though the problem is feasible.
        minimize((y_star(j) - x_star * beta_j)^2)

        % Constraints
        subject to
            for i = 1 : Ns
                 Y(i, j) - X(i, :) * beta_j <= opt.DRC.epsilon * z_j(i) + opt.DRC.bigM * (1 - z_j(i));
                -Y(i, j) + X(i, :) * beta_j <= opt.DRC.epsilon * z_j(i) + opt.DRC.bigM * (1 - z_j(i));
            end
            sum(z_j) >= (1 - alpha) * Ns;
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
    pro_str = sprintf('DRC_XYD complete percentage: %3.1f', 100 * j / Ny);
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