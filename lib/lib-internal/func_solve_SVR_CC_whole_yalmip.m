function [B, success] = func_solve_SVR_CC_whole_yalmip(X, Y, opt)

% Start
Ns = size(Y, 1); % Number of samples
Ny = size(Y, 2); % Number of responses in Y
Nx = size(X, 2); % Number of predictors in X

% Define decision variables
B = sdpvar(Nx, Ny);
z = binvar(Ns, Ny);

% Display
disp('yalmip starts to solve SVR_CCP')

% Objective function
Objective = sum(sum(B.^2));

% Constraints
Constraints = [];
for i = 1:Ns
    for j = 1:Ny
        Constraints = [Constraints,  Y(i, j) - X(i, :) * B(:, j) <= opt.SVRCC.epsilon + opt.SVRCC.bigM * (1 - z(i,j))];
        Constraints = [Constraints, -Y(i, j) + X(i, :) * B(:, j) <= opt.SVRCC.epsilon + opt.SVRCC.bigM * (1 - z(i,j))];
    end
end
for j = 1:Ny
    Constraints = [Constraints, sum(z(:, j)) >= opt.SVRCC.probThreshold * Ns / 100];
end

% Set up and solve the optimization problem
options = sdpsettings('solver', opt.SVRCC.solver, 'verbose', opt.SVRCC.yalDisplay); 
sol = optimize(Constraints, Objective, options);

% Check for errors and retrieve the result
B = value(B);
if sol.problem == 0
    % Extract and display the result
    success = 1;
else
    success = 0;
end
