function [beta_j, status] = func_solve_LS_Weight_indivi_yalmip_j(X, Yj, Nx, Omega, options)
% Define decision variables for the j-th response
beta_j = sdpvar(Nx, 1); 

% Objective function
Objective = sum((Omega .* (Yj - X * beta_j)).^2);

% Solve the problem
sol = optimize([], Objective, options);

% Get results
beta_j = value(beta_j);

% Test if the program has been solved successfully
if sol.problem == 0
    % Problem solved successfully
    status = 1;
else
    % Problem not solved successfully
    status = 1;
end