function [beta_j, status] = func_solve_SVR_indivi_yalmip_j(X, Yj, Nx, Ns, omega, epsilon, lambda, options)

% Define decision variables for the j-th response
beta_j = sdpvar(Nx, 1); 
zi_j = sdpvar(Ns, 1);
zi_j_star = sdpvar(Ns, 1);

% Objective function
J_j = (0.5 + lambda) * sum(beta_j.^2) + omega * sum(zi_j + zi_j_star);
Objective = J_j;

% Constraints for the j-th response
Constraints = [Yj - X * beta_j <= epsilon + zi_j; 
               X * beta_j - Yj <= epsilon + zi_j_star;
               zi_j >= 0;
               zi_j_star >= 0];

% Solve the problem
sol = optimize(Constraints, Objective, options);

% Test if the program has been solved successfully
if sol.problem == 0
    % Problem solved successfully
    status = 1;
    beta_j = value(beta_j);
else
    % Problem not solved successfully
    status = 0;
    beta_j = value(beta_j);
end