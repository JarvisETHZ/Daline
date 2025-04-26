function [Beta, success] = func_solve_OI_enhanced(X_train, Y_train, opt)
% func_solve_MILP_enhanced solves the MILP (model (5) in the paper) using an 
% enhanced continuous relaxation-rounding algorithm.
%
% This enhanced version implements an extra step: if no free sample’s relaxed 
% z value exceeds the threshold (theta) in an iteration, then the algorithm 
% force-fixes the free samples with the highest z values until the allowed 
% number of outliers is reached.
%
% Inputs:
%   X_train           - m x n predictor matrix (first column is constant 1's).
%   Y_train           - m x numY response matrix.
%   opt               - options structure with fields:
%         opt.OI.bigM         : Big-M constant.
%         opt.OI.outlierRatio : Allowed fraction p of outliers.
%         opt.OI.theta        : Rounding threshold (e.g., 0.9).
%         opt.OI.maxIter      : Maximum number of iterations.
%         opt.YALMIP_options  : YALMIP solver options.
%
% Outputs:
%   Beta    - Estimated regression coefficients (n x numY).
%   success - Boolean flag indicating whether the optimization succeeded.

    [m, n] = size(X_train);
    [~, numY] = size(Y_train);

    % Allowed number of outliers.
    max_outliers = floor(opt.OI.outlierRatio * m);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Define YALMIP decision variables.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Beta_var = sdpvar(n, numY, 'full');
    z       = sdpvar(m, 1);
    u       = sdpvar(m, numY, 'full');
    d       = sdpvar(m, numY, 'full');

    % Initialize constraints and objective.
    Constraints = [];
    Objective = 0;

    % z is relaxed: each z(i) is between 0 and 1.
    Constraints = [Constraints, 0 <= z <= 1];
    % Total outlier constraint.
    Constraints = [Constraints, sum(z) <= max_outliers];

    % Build the constraints for each sample and each response.
    for i = 1:m
        for j = 1:numY
            residual = Y_train(i,j) - X_train(i,:) * Beta_var(:,j);
            % Constraint that allows violation only if z(i) is near 1.
            Constraints = [Constraints, -opt.OI.bigM * z(i) <= u(i,j) + residual <= opt.OI.bigM * z(i)];
            % Ensure d(i,j) is at least as large as the absolute value of u(i,j).
            Constraints = [Constraints, -d(i,j) <= u(i,j) <= d(i,j)];
        end
    end

    % Objective: minimize the total L1-norm of the residuals.
    Objective = sum(sum(d));

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Enhanced continuous relaxation-rounding process:
    % At each iteration, fix samples whose z value exceeds theta. If no free sample 
    % meets theta, force fix the free samples with the highest z values until 
    % the allowed number of outliers is reached.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fixed_idx = false(m, 1);   % Logical vector indicating samples fixed as outliers.
    iteration = 1;
    maxIter = opt.OI.maxIter;

    while iteration <= maxIter && sum(fixed_idx) < max_outliers
        % Add constraints for samples already fixed as outliers.
        FixedConstraints = [];
        for i = 1:m
            if fixed_idx(i)
                FixedConstraints = [FixedConstraints, z(i) == 1];
            end
        end

        % Solve the relaxed LP.
        sol = optimize([Constraints, FixedConstraints], Objective, opt.YALMIP_options);
        if sol.problem ~= 0
            success = false;
            disp('Solver failed during an iteration.');
            Beta = [];
            return;
        end

        % Retrieve the current solution for z.
        z_val = value(z);

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Identify new free samples whose z value >= theta.
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        new_fixed = (z_val >= opt.OI.theta) & (~fixed_idx);
        if any(new_fixed)
            % If any free sample has a z value at least theta, fix it.
            fixed_idx = fixed_idx | new_fixed;
        else
            % --- Enhanced Force-Fixing Step ---
            % No free sample meets the threshold. In order to ensure progress,
            % select the free samples with the highest z values and fix them.
            free_indices = find(~fixed_idx); % Get indices of unfixed samples.
            if ~isempty(free_indices)
                % Sort the free samples based on their z value in descending order.
                [~, sort_order] = sort(z_val(free_indices), 'descend');
                num_fixed = sum(fixed_idx);  % Count how many are fixed so far.
                needed = max_outliers - num_fixed; % How many more need to be fixed.
                if needed > 0 && needed <= length(free_indices)
                    % Force-fix the top 'needed' free samples.
                    indices_to_fix = free_indices(sort_order(1:needed));
                    fixed_idx(indices_to_fix) = true;
                end
            end
        end

        % Stop if we have reached the allowed number of outliers.
        if sum(fixed_idx) >= max_outliers
            break;
        end

        iteration = iteration + 1;
    end

    % Final rounding: for fixed samples set z = 1, for others set z = 0.
    FinalFixConstraints = [];
    for i = 1:m
        if fixed_idx(i)
            FinalFixConstraints = [FinalFixConstraints, z(i) == 1];
        else
            FinalFixConstraints = [FinalFixConstraints, z(i) == 0];
        end
    end

    sol_final = optimize([Constraints, FinalFixConstraints], Objective, opt.YALMIP_options);
    if sol_final.problem ~= 0
        success = false;
        disp('Final solve failed.');
        Beta = [];
        return;
    end

    % Retrieve the estimated regression coefficients.
    Beta = value(Beta_var);
    success = true;
end
