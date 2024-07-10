function [Beta, exitflag] = func_solve_LS_Hbl_whole_yalmip(X, Y, opt)

% Get numbers
num_sample = size(Y, 1);         % Number of data points
num_response = size(Y, 2);       % Number of response variables
num_predictor = size(X, 2);      % Number of response variables
delta = opt.HBL.delta;     % Threshold

% Define decision variables
b = sdpvar(num_predictor, num_response);
z = sdpvar(num_sample, num_response);
w = sdpvar(num_sample, num_response);

% Display
disp('yalmip starts to solve LS_HBLE')

% Objective function
Objective = 0.5 * sum(sum(z.^2)) + delta * sum(sum(w));

% Constraints
Constraints = [];
for col = 1:num_response
    Constraints = [Constraints, -z(:, col) - w(:, col) <= Y(:, col) - X * b(:, col) <= z(:, col) + w(:, col), ...
                                0 <= z(:, col) <= delta, ...
                                w(:, col) >= 0];
end

% Set up and solve the optimization problem
options = sdpsettings('solver', opt.HBL.solver, 'verbose', opt.HBL.yalDisplay);
sol = optimize(Constraints, Objective, options);

% Get results
Beta = value(b);

% Check for errors and retrieve the result
if sol.problem == 0
    exitflag = 1;
else
    exitflag = 0;
end
