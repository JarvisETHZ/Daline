function [Beta, success] = func_solve_LS_Hbl_indivi_yalmip(X, Y, opt)

% get numbers
Ny = size(Y,  2);
Nx = size(X,  2);

% Initialize containers
Beta = zeros(Nx, Ny);  % because of the column of 1s
success = zeros(Ny, 1);

% Solve the problem individually for each response in Y.
if opt.HBL.parallel
    % parallelly solving
    disp('Parallel computing starts for LS_HBLE')
    parfor j = 1:Ny
        % Solve it using yalmip
        [beta_j, status] = func_solve_LS_Hbl_indivi_yalmip_j(X, Y(:, j), opt);  
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
    for j = 1:Ny
        % Solve it using yalmip
        [beta_j, status] = func_solve_LS_Hbl_indivi_yalmip_j(X, Y(:, j), opt);  
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
        pro_str = sprintf('LS_HBLE complete percentage: %3.1f', 100 * j / Ny);
        fprintf([backspaces, pro_str]);
        backspaces = repmat(sprintf('\b'), 1, length(pro_str)); % Subtract 1 to account for the newline character
    end
    fprintf('\n');
end