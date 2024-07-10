function [Beta, success_all] = func_solve_LS_Weight_whole_yalmip(X, Y, omega, Display, solver)

% Get numbers
[Ns, Ny] = size(Y); % Number of samples and responses in Y
Nx = size(X, 2); % Number of predictors in X

% Form the weight vector; Ns-by-1
Omega = zeros(Ns, 1);
for n = 1:Ns
    Omega(n) = omega^(Ns-n);
end

% Repeat Omega to get a matrix Ns-by-Ny; convenient for defining the obj later
Omega = repmat(Omega, [1, Ny]);

% Display
disp('yalmip starts to solve LS_WEI')

% Set up YALMIP
B = sdpvar(Nx, Ny); % Define decision variable

% Objective function
Objective = sum(sum((Omega.*(Y - X*B)).^2));

% Set up the solver options
options = sdpsettings('solver', solver, 'verbose', Display); % Set solver and suppress output

% Solve the problem
sol = optimize([], Objective, options);

% Test if the program has been solved successfully
if sol.problem == 0
    % Problem solved successfully
    success_all = 1;
    Beta = value(B);
else
    % Problem not solved successfully
    success_all = 0;
    Beta = value(B);
end
