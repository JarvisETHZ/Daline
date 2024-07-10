function [Beta, success_all] = func_solve_SVR_CC_indivi_yalmip(X, Y, opt)

% Get numbers
Ns = size(Y, 1); % Number of samples
Ny = size(Y, 2); % Number of responses in Y
Nx = size(X, 2); % Number of predictors in X

% Get hyperparameters
epsilon  = opt.SVRCC.epsilon;
bigM     = opt.SVRCC.bigM;
pTh      = opt.SVRCC.probThreshold;
solver   = opt.SVRCC.solver;
display  = opt.SVRCC.yalDisplay;

% Define containers
Beta = zeros(Nx, Ny);       % Initialize the overall Beta matrix
success  = zeros(Ny, 1);

% Solve the problem individually for each response in Y.
if opt.SVRCC.parallel
    % parallelly solving
    disp('Parallel computing starts for SVR_CCP')
    parfor j = 1 : Ny
        % Solve it using yalmip
        [beta_j, status] = func_solve_SVR_CC_indivi_yalmip_j(X, Y(:, j), Nx, Ns, epsilon, bigM, pTh, solver, display);
        % Test if the program has been solved successfully
        if status == 1
            % Store the results
            success(j) = 1;
            Beta(:, j) = beta_j;
        else
            % Store the results
            success(j) = 0;
            Beta(:, j) = beta_j;
        end
    end
else
    % Sequential solving
    backspaces = '';
    for j = 1 : Ny
        % Solve it using yalmip
        [beta_j, status] = func_solve_SVR_CC_indivi_yalmip_j(X, Y(:, j), Nx, Ns, epsilon, bigM, pTh, solver, display);
        % Test if the program has been solved successfully
        if status == 1
            % Store the results
            success(j) = 1;
            Beta(:, j) = beta_j;
        else
            % Store the results
            success(j) = 0;
            Beta(:, j) = beta_j;
        end
        % Display progress
        pro_str = sprintf('SVR_CCP complete percentage: %3.1f', 100 * j / Ny);
        fprintf([backspaces, pro_str]);
        backspaces = repmat(sprintf('\b'), 1, length(pro_str)); % Subtract 1 to account for the newline character
    end
    fprintf('\n');
end
% Test if the program has been solved successfully
if mean(success) == 1
    success_all = 1;
else
    success_all = 0;
end