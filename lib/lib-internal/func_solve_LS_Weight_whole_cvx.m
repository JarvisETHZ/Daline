function [Beta, success_all] = func_solve_LS_Weight_whole_cvx(X, Y, omega, cvxQuiet, solver)

% Get numbers
Ns = size(Y, 1); % Number of responses in Y
Ny = size(Y, 2); % Number of responses in Y
Nx = size(X, 2); % Number of predictors in X

% form the weight vector; Ns-by-1
Omega = zeros(Ns, 1);
for n = 1:Ns
    Omega(n) = omega^(Ns-n);
end

% Repeat Omega to get a matrix Ns-by-Ny; convenient for defining the obj latter
Omega = repmat(Omega, [1, Ny]);

% Set up cvx
if cvxQuiet
    cvx_quiet(true);          % Suppress CVX output
    disp('cvx starts to solve LS_WEI')
else
    cvx_quiet(false); 
end
func_cvx_solver(solver)  % set solver

% Solve the problem in an overall manner
cvx_begin
     % Define decision variables for the j-th response
    variable B(Nx, Ny)      

    % Objective function
    minimize(sum(sum((Omega.*(Y - X*B)).^2)))

cvx_end

% Test if the program has been solved successfully
if strcmp(cvx_status, 'Solved')
    % Store the results
    success_all = 1;
    Beta = B;
else
    % Store the results
    success_all = 0;
    Beta = B;
end