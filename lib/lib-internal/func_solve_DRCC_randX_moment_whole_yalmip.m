function [Beta, success] = func_solve_DRCC_randX_moment_whole_yalmip(X, Y, opt)

%% Start

% Get numbers
Ny = size(Y, 2); % Number of responses in Y
Nx = size(X, 2); % Number of predictors in X

% Deal hyperparameters
gamma1  = opt.DRC.gamma1;
gamma2  = opt.DRC.gamma2;
epsilon = opt.DRC.epsilon;           % epsilon remains unchanged among responses
probTh  = 1 - opt.DRC.probThreshold/100; % use the smaller value here; remains unchanged among responses
idx_star = opt.DRC.starIDX;
if strcmp(idx_star, 'end')
   idx_star = size(X, 1);  % If opt.DRC.starIDX = 'end', take the last sample in X as the star sample
end
solver = opt.DRC.solverM;
yalDisplay = opt.DRC.yalDisplay;

% Compute moments
Mu = mean(X)';
Sigma = cov(X);

% Get the selected point
y_star = Y(idx_star, :);
x_star = X(idx_star, :);

% display
if strcmp('whole', opt.DRC.programType)
    % only display when use the whole model to solve
    disp('yalmip starts to solve DRC_XM.')
end

% Define decision variables
B = sdpvar(Nx, Ny);     % Beta
G = sdpvar(Nx, Nx, Ny, 'symmetric'); % G(:, :, j) refers to Gj
H = sdpvar(Nx, Nx, Ny, 'symmetric'); % H(:, :, j) refers to Hj
p = sdpvar(Nx, Ny);    % p(:, j) refers to pj
q = sdpvar(1, Ny);      % q(j) refers to qj
r = sdpvar(1, Ny);      % r(j) refers to rj
lambda = sdpvar(1, Ny); % lambda(j) refers to lambdaj

% Objective function
Objective = (y_star - x_star * B)*(y_star - x_star * B)';

% Constraints
Constraints = [];
for j = 1:Ny
    % Define the unchanged constraints for each j
    Constraints = [Constraints, gamma2 * trace(Sigma * G(:,:,j)) + 1 - r(j) + trace(Sigma * H(:,:,j)) + gamma1 * q(j) <= probTh * lambda(j)];
    Constraints = [Constraints, lambda(j) >= 0];
    % Define the unchanged SDP constraints for each j
    Constraints = [Constraints, [G(:,:,j), -p(:,j); -p(:,j)', 1 - r(j)] >= 0];
    Constraints = [Constraints, [H(:,:,j),  p(:,j);  p(:,j)',     q(j)] >= 0];
    % Define the SDP constraints particularly for (1) for each j
    Constraints = [Constraints, [G(:,:,j), -p(:,j); -p(:,j)', 1 - r(j)] - [zeros(Nx), 0.5 * (-B(:,j)); 0.5 * (-B(:,j))', lambda(j) + (-B(:,j))' * Mu - epsilon + y_star(j)] >= 0];
    % Define the SDP constraints particularly for (2) for each j
    Constraints = [Constraints, [G(:,:,j), -p(:,j); -p(:,j)', 1 - r(j)] - [zeros(Nx), 0.5 * ( B(:,j)); 0.5 * ( B(:,j))', lambda(j) + ( B(:,j))' * Mu - epsilon - y_star(j)] >= 0];
end

% Solve the problem
options = sdpsettings('solver', solver, 'verbose', yalDisplay); % Set solver and suppress output
sol = optimize(Constraints, Objective, options);

% Test if the program has been solved successfully
if sol.problem == 0
    % Store the results
    success = 1;
    Beta = value(B);
else
    Beta = value(B);
    success = 0;
end

