function [B, success] = func_solve_DRCC_randX_moment_whole_cvx(X, Y, opt)
% Only treat X as random variable. Use Y^star, the selected operating
% point, when formulating the SDP constraints. 

% Ref. Y. Liu, Z. Li and J. Zhao, "Robust Data-Driven Linear Power Flow 
% Model With Probability Constrained Worst-Case Errors," in IEEE 
% Transactions on Power Systems, vol. 37, no. 5, pp. 4113-4116, Sept. 2022, 
% doi: 10.1109/TPWRS.2022.3189543.
%
% Ref. Y. Zhang, S. Shen, and J. L. Mathieu, “Distributionally robust chance-
% constrained optimal power flow with uncertain renewables and uncertain
% reserves provided by loads,” IEEE Trans. Power Syst., vol. 32, no. 2,
% pp. 1378–1388, Mar. 2017.  

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

% Compute moments
Mu = mean(X)';
Sigma = cov(X);

% Get the selected point
y_star = Y(idx_star, :);
x_star = X(idx_star, :);

% Set up cvx
if opt.DRC.cvxQuiet
    cvx_quiet(true);          % Suppress CVX output
    disp('cvx starts to solve DRC_XM.')
else
    cvx_quiet(false); 
end
func_cvx_solver(opt.DRC.solverM)  % set solver


% Solve the problem 
cvx_begin

    % Define decision variables
    variable B(Nx,  Ny)      % Beta
    variable G(Nx,  Nx,  Ny) % G(:, :, j) refers to Hj
    variable H(Nx,  Nx,  Ny) % H(:, :, j) refers to Hj
    variable p(Nx,  Ny)      % p(:, j) refers to pj
    variable q(1,   Ny)      % q(j) refers to qj
    variable r(1,   Ny)      % r(j) refers to rj
    variable lambda(1,   Ny) % lambda(j) refers to lambdaj

    % Objective function
    minimize((y_star - x_star * B)*(y_star - x_star * B)')

    % Constraints
    subject to
        % For each response in Y, we have two DRCC:
        %   (1) inf Prob[  yj - beta_j' * x <=   epsilon] >= probTh
        %   (2) inf Prob[- yj + beta_j' * x <=   epsilon] >= probTh
        % Hence, there are two sets of SDP constraints. The only change lies in b:
        %   For (1), A = -B(:, j), b =   epsilon - yj^star
        %   For (2), A = +B(:, j), b =   epsilon + yj^star
        for j = 1 : Ny
            % Define the unchanged constraints for each j
            gamma2 * trace(Sigma * G(:, :, j)) + 1 - r(j) + trace(Sigma * H(:, :, j)) + gamma1 * q(j) <= probTh * lambda(j);
            0 <= lambda(j);
            % Define the unchanged SDP constraints for each j
            [G(:, :, j), -p(:, j); -p(:, j)', 1 - r(j)] == semidefinite(Nx + 1);
            [H(:, :, j),  p(:, j);  p(:, j)',     q(j)] == semidefinite(Nx + 1);
            % Define the SDP constraints particularly for (1) for each j
            [G(:, :, j), -p(:, j); -p(:, j)', 1 - r(j)] - [zeros(Nx, Nx), 0.5 * (-B(:, j)); 0.5 * (-B(:, j))', lambda(j) + (-B(:, j))' * Mu - epsilon + y_star(j)] == semidefinite(Nx + 1);
            % Define the SDP constraints particularly for (2) for each j
            [G(:, :, j), -p(:, j); -p(:, j)', 1 - r(j)] - [zeros(Nx, Nx), 0.5 * ( B(:, j)); 0.5 * ( B(:, j))', lambda(j) + ( B(:, j))' * Mu - epsilon - y_star(j)] == semidefinite(Nx + 1);
        end
cvx_end

% Test if the program has been solved successfully
if strcmp(cvx_status, 'Solved')
    % Store the results
    success = 1;
else
    success = 0;
end


