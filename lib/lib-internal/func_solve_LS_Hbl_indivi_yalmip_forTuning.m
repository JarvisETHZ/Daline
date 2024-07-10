function [Beta, success] = func_solve_LS_Hbl_indivi_yalmip_forTuning(X, Y, opt)

% get numbers
Ny = size(Y,  2);
Nx = size(X,  2);

% Initialize containers
Beta = zeros(Nx, Ny);  % because of the column of 1s
success = zeros(Ny, 1);

% Solve the problem individually for each response in Y.
if opt.HBL.parallel
    % parallelly tuning
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
    % Sequential tuning
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
    end
end