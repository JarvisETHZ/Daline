function [Beta, success] = func_solve_DRCC_randX_moment_indivi_yalmip(X, Y, opt)

% Get numbers
Ny = size(Y, 2); % Number of responses in Y
Nx = size(X, 2); % Number of predictors in X

% Define containers
Beta = zeros(Nx, Ny);
success = zeros(1, Ny);

% Solve the problem individually for each response in Y.
if opt.DRC.parallel
    % parallelly solving
    disp('Parallel computing starts for DRC_XM')
    parfor j = 1 : Ny
        % Solve it using yalmip
        [beta_j, status] = func_solve_DRCC_randX_moment_whole_yalmip(X, Y(:, j), opt);
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
        [beta_j, status] = func_solve_DRCC_randX_moment_whole_yalmip(X, Y(:, j), opt);
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
        pro_str = sprintf('DRC_XM complete percentage: %3.1f', 100 * j / Ny);
        fprintf([backspaces, pro_str]);
        backspaces = repmat(sprintf('\b'), 1, length(pro_str)); % Subtract 1 to account for the newline character
    end
    fprintf('\n');
end