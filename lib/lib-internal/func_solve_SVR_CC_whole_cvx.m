function [B, success] = func_solve_SVR_CC_whole_cvx(X, Y, opt)

Ns = size(Y, 1); % Number of samples
Ny = size(Y, 2); % Number of responses in Y
Nx = size(X, 2); % Number of predictors in X

% Define a large positive number M
M = opt.SVRCC.bigM; % This value can be adjusted based on the problem's scale

% Start CVX to solve the linearly constrained programming with Jacobian guidance constraints for Beta
if opt.SVRCC.cvxQuiet
    cvx_quiet(true);          % Suppress CVX output
    disp('cvx starts to solve SVR_CCP')
else
    cvx_quiet(false); 
end
func_cvx_solver(opt.SVRCC.solver)  % set solver
cvx_begin
    % Define decision variables
    variable B(Nx, Ny)
    variable z(Ns, Ny) binary

    % Objective function
    minimize(sum(sum(B.^2)))

    % Constraints
    subject to
        for i = 1 : Ns
            for j = 1 : Ny
                 Y(i, j) - X(i, :) * B(:, j) <= opt.SVRCC.epsilon + M * (1 - z(i,j));
                -Y(i, j) + X(i, :) * B(:, j) <= opt.SVRCC.epsilon + M * (1 - z(i,j));
            end
        end
        for j = 1 : Ny
            sum(z(:, j)) >= opt.SVRCC.probThreshold * Ns / 100;
        end
cvx_end

% Test if the program has been solved successfully
if strcmp(cvx_status, 'Solved')
    success = 1;
else
    success = 0;
end
