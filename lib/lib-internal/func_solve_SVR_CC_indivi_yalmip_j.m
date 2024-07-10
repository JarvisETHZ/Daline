function [beta_j, status] = func_solve_SVR_CC_indivi_yalmip_j(X, Yj, Nx, Ns, epsilon, bigM, probThreshold, solver, display)
    
% Define decision variables
beta_j = sdpvar(Nx, 1);
z_j = binvar(Ns, 1);

% Objective function
Objective = 0.5 * (beta_j' * beta_j);

% Constraints
Constraints = [];
for i = 1:Ns
    Constraints = [Constraints,  Yj(i) - X(i, :) * beta_j <= epsilon * z_j(i) + bigM * (1 - z_j(i))];
    Constraints = [Constraints, -Yj(i) + X(i, :) * beta_j <= epsilon * z_j(i) + bigM * (1 - z_j(i))];
end
Constraints = [Constraints, sum(z_j) >= probThreshold * Ns / 100];

% Set up and solve the optimization problem
options = sdpsettings('solver', solver, 'verbose', display); 
sol = optimize(Constraints, Objective, options);

% output
beta_j = value(beta_j);
% Check for errors and retrieve the result
if sol.problem == 0
   status = 1;
else
   status = 0;
end

