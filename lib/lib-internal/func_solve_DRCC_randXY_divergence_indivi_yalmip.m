function [Beta, success] = func_solve_DRCC_randXY_divergence_indivi_yalmip(X, Y, opt, alpha)

% Get numbers
Ns = size(Y, 1); % Number of samples
Ny = size(Y, 2); % Number of responses in Y
Nx = size(X, 2); % Number of predictors in X

% Get idx of star
idx_star = opt.DRC.starIDX;
if strcmp(idx_star, 'end')
   idx_star = size(X, 1);  % If opt.DRC.starIDX = 'end', take the last sample in X as the star sample
end

% Get the selected point
y_star = Y(idx_star, :);
x_star = X(idx_star, :);

% Define containers
Beta = zeros(Nx, Ny);       % Initialize the overall Beta matrix
success = zeros(Ny, 1);

% Solve the problem individually for each response in Y.
if opt.DRC.parallel
    % parallelly solving
    disp('Parallel computing starts to solve DRC_XYD')
    parfor j = 1 : Ny
        % Solve it using yalmip
        [beta_j, status] = func_solve_DRCC_randXY_divergence_indivi_yalmip_j(X, Y(:, j), x_star, y_star(j), Nx, Ns, alpha, opt);
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
        [beta_j, status] = func_solve_DRCC_randXY_divergence_indivi_yalmip_j(X, Y(:, j), x_star, y_star(j), Nx, Ns, alpha, opt);
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
        pro_str = sprintf('DRC_XYD complete percentage: %3.1f', 100 * j / Ny);
        fprintf([backspaces, pro_str]);
        backspaces = repmat(sprintf('\b'), 1, length(pro_str)); % Subtract 1 to account for the newline character
    end
    fprintf('\n');
end