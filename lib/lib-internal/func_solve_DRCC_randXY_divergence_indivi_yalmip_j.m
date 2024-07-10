function [beta_j, status] = func_solve_DRCC_randXY_divergence_indivi_yalmip_j(X, Yj, x_star, y_star_j, Nx, Ns, alpha, opt)
% Define decision variables
beta_j = sdpvar(Nx, 1);
z_j = binvar(Ns, 1);

% Set up YALMIP options
options = sdpsettings('solver', opt.DRC.solverD, 'verbose', opt.DRC.yalDisplay);

% Objective function
objective = (y_star_j - x_star * beta_j)^2;

% Constraints
constraints = [];
for i = 1 : Ns
    constraints = [constraints,  Yj(i) - X(i, :) * beta_j <= opt.DRC.epsilon * z_j(i) + opt.DRC.bigM * (1 - z_j(i))];
    constraints = [constraints, -Yj(i) + X(i, :) * beta_j <= opt.DRC.epsilon * z_j(i) + opt.DRC.bigM * (1 - z_j(i))];
end
constraints = [constraints, sum(z_j) >= (1 - alpha) * Ns];

% Solve the problem
sol = optimize(constraints, objective, options);

% Test if the program has been solved successfully
if sol.problem == 0
    % Store the results
    status = 1;
    beta_j = value(beta_j);
else
    % Store the results
    status = 0;
    beta_j = value(beta_j);
end