function [Beta, success] = func_solve_DRCC_randX_moment_indivi_cvx(X, Y, opt)

% Get numbers
Ny = size(Y, 2); % Number of responses in Y
Nx = size(X, 2); % Number of predictors in X

% Define containers
Beta = zeros(Nx, Ny);
success = zeros(1, Ny);

% Set up cvx
if opt.DRC.cvxQuiet
    cvx_quiet(true);          % Suppress CVX output
    disp('cvx starts to solve DRC_XM.')
else
    cvx_quiet(false); 
end
func_cvx_solver(opt.DRC.solverM)  % set solver

% Interact
backspaces = '';

for j = 1 : Ny
    % Training
    [Beta(:, j), success(j)] = func_solve_DRCC_randX_moment_whole_cvx_nodisplay(X, Y(:, j), opt);
    % Display progress
    pro_str = sprintf('DRC_XM complete percentage: %3.1f', 100 * j / Ny);
    fprintf([backspaces, pro_str]);
    backspaces = repmat(sprintf('\b'), 1, length(pro_str)); % Subtract 1 to account for the newline character
%     fprintf('\n');
end

% Interact
fprintf('\n');