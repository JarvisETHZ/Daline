function [Beta, success] = func_solve_DRCC_randXY_moment_whole_yalmip(X, Y, opt)

%% Start

% Get numbers
Ny = size(Y, 2); % Number of responses in Y
Nx = size(X, 2); % Number of predictors in X
Nx1 = Nx + 1;    % Number of the random variables in the union set of Yj and X

% Deal hyperparameters
gamma1  = opt.DRC.gamma1;
gamma2  = opt.DRC.gamma2;
epsilon = opt.DRC.epsilon;           % epsilon remains unchanged among responses
probTh  = 1 - opt.DRC.probThreshold/100; % use the smaller value here; remains unchanged among responses
idx_star = opt.DRC.starIDX;
if strcmp(idx_star, 'end')
   idx_star = size(X, 1);  % If opt.DRC.starIDX = 'end', take the last sample in X as the star sample
end
solverM = opt.DRC.solverM;
yalDisplay = opt.DRC.yalDisplay;
programType = opt.DRC.programType;

% Define containers
Mu = zeros(Nx1, 1);          % col j: Mu of [Yj, X]
Sigma = zeros(Nx1, Nx1, Ny); % submatrix j: Sigma of [Yj, X]

% Collect moments for each [Yj, X] to build ambiguity sets
for j = 1 : Ny
    % Input samples
    Yj = Y(:, j);
    yX = [Yj,  X];    
    % Get moments
    Mu(:, j) = mean(yX)';   
    Sigma(:, :, j) = cov(yX);  
end

% Get the selected point
y_star = Y(idx_star, :);
x_star = X(idx_star, :);

% Get numbers
Ny = size(Y, 2); % Number of responses in Y
Nx = size(X, 2); % Number of predictors in X

% display
if strcmp('whole', programType)
    % only display when use the whole model to solve
    disp('yalmip starts to solve DRC_XYM.')
end

% Set up YALMIP
yalmip('clear')

% Define decision variables
B = sdpvar(Nx, Ny);     % Beta
G = sdpvar(Nx1, Nx1, Ny, 'symmetric'); % G(:, :, j) refers to Gj
H = sdpvar(Nx1, Nx1, Ny, 'symmetric'); % H(:, :, j) refers to Hj
p = sdpvar(Nx1, Ny);    % p(:, j) refers to pj
q = sdpvar(1, Ny);      % q(j) refers to qj
r = sdpvar(1, Ny);      % r(j) refers to rj
lambda = sdpvar(1, Ny); % lambda(j) refers to lambdaj

% Objective function
objective = (y_star - x_star * B)*(y_star - x_star * B)';

% Constraints
constraints = [];
for j = 1:Ny
    % Define the unchanged constraints for each j
    constraints = [constraints, gamma2 * trace(Sigma(:, :, j) * G(:, :, j)) + 1 - r(j) + trace(Sigma(:, :, j) * H(:, :, j)) + gamma1 * q(j) <= probTh * lambda(j)];
    constraints = [constraints, lambda(j) >= 0];
    % Define the unchanged SDP constraints for each j
    constraints = [constraints, [G(:, :, j), -p(:, j); -p(:, j)', 1 - r(j)] >= 0];
    constraints = [constraints, [H(:, :, j),  p(:, j);  p(:, j)',     q(j)] >= 0];
    % Define the SDP constraints particularly for (1) for each j
    constraints = [constraints, [G(:, :, j), -p(:, j); -p(:, j)', 1 - r(j)] - [zeros(Nx1, Nx1), 0.5 * [1;  -B(:, j)]; 0.5 * [ 1; -B(:, j)]', lambda(j) + [1;  -B(:, j)]' * Mu(:, j) - epsilon] >= 0];
    % Define the SDP constraints particularly for (2) for each j
    constraints = [constraints, [G(:, :, j), -p(:, j); -p(:, j)', 1 - r(j)] - [zeros(Nx1, Nx1), 0.5 * [-1;  B(:, j)]; 0.5 * [-1;  B(:, j)]', lambda(j) + [-1;  B(:, j)]' * Mu(:, j) - epsilon] >= 0];
end

% Solve the problem
options = sdpsettings('solver', solverM, 'verbose', yalDisplay, 'warning', 0);
sol = optimize(constraints, objective, options);

% Test if the program has been solved successfully
if sol.problem == 0
    % Store the results
    success = 1;
    Beta = value(B);
else
    Beta = value(B);
    success = 0;
end
