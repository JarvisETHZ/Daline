function [Beta, exitflag] = func_solve_LS_Hbl_indivi_cvx_forTuning(X, Y, opt)

% get numbers
Ny = size(Y,  2);
Nx = size(X,  2);

% Interact
backspaces = '';

% Initialize containers
Beta = zeros(Nx, Ny);  % because of the column of 1s
exitflag = zeros(Ny, 1);

% Use cvx to solve an equivalent convex problem
if opt.HBL.cvxQuiet 
    cvx_quiet(true);          % Suppress CVX output
end
func_cvx_solver(opt.HBL.solver)  % set solver

% Solve the problem 
for j = 1 : Ny
    % Train
    [Beta(:, j), exitflag(j)] = func_solve_LS_Hbl_indivi_cvx_j(X, Y(:, j), opt);  
end