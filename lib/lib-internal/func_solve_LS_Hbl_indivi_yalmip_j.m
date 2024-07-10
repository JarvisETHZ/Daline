function [Beta, exitflag] = func_solve_LS_Hbl_indivi_yalmip_j(X, y, opt)

% Get numbers
num_sample = length(y);  % Number of data points
delta = opt.HBL.delta;   % Threshold

% Define decision variables
b = sdpvar(size(X,2), 1);
z = sdpvar(num_sample, 1);
w = sdpvar(num_sample, 1);

% Objective function
Objective = 0.5 * sum(z.^2) + delta * sum(w);

% Constraints
Constraints = [-z - w <= y - X * b <= z + w, 0 <= z <= delta, w >= 0];

% Set up and solve the optimization problem
options = sdpsettings('solver', opt.HBL.solver, 'verbose', opt.HBL.yalDisplay);
sol = optimize(Constraints, Objective, options);

% Get result
Beta = value(b);

% Check for errors and retrieve the result
if sol.problem == 0
    % Extract and display the result
    exitflag = 1;
else
    exitflag = 0;
end
