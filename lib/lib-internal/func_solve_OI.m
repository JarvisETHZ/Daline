function [Beta, success] = func_solve_OI(X_train, Y_train, opt)
% func_solve_MILP solves the problem via the outlier-Immune method based on the continuous relaxation-rounding algorithm
% 
% Ref. G. Yan and Z. Li, "Construction of an Outlier-Immune Data-Driven
% Power Flow Model for Model-Absent Distribution Systems," in IEEE
% Transactions on Power Systems, vol. 39, no. 6, pp. 7449-7452, Nov. 2024,
% doi: 10.1109/TPWRS.2024.3455785.   
%
% Inputs:
%   X_train           - m x n predictor matrix (first column is constant 1's).
%   Y_train           - m x numY response matrix.
%   opt               - options structure with fields:
%         opt.OI.bigM         : Big-M constant.
%         opt.OI.outlierRatio : Allowed fraction p of outliers.
%         opt.OI.theta        : Rounding threshold (e.g., 0.9).
%         opt.OI.maxIter      : Maximum number of iterations.
%         opt.OI.solver       : solver option.
%         opt.OI.verbose      : verbose option.
%
% Outputs:
%   Beta    - Estimated regression coefficients (n x numY).
%   success - Boolean flag indicating whether the optimization succeeded.

    [m, n] = size(X_train);
    [~, numY] = size(Y_train);

    % Allowed number of outliers.
    max_outliers = floor(opt.OI.outlierRatio * m);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Define YALMIP decision variables:
    % Beta_var: regression coefficients.
    % z: relaxed indicator for each sample (to be later rounded to binary).
    % u: auxiliary variables for each sample and each response.
    % d: auxiliary variables to linearize the absolute value (|u|).
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Beta_var = sdpvar(n, numY, 'full');
    z       = sdpvar(m, 1);
    u       = sdpvar(m, numY, 'full');
    d       = sdpvar(m, numY, 'full');

    % Initialize constraints and the objective.
    Constraints = [];
    Objective = 0;

    % z must be between 0 and 1 (relaxed).
    Constraints = [Constraints, 0 <= z <= 1];
    
    % The total number of outliers cannot exceed the allowed number.
    Constraints = [Constraints, sum(z) <= max_outliers];

    % Build constraints across all samples (i) and responses (j).
    for i = 1:m
        for j = 1:numY
            % Compute the residual for sample i and response j.
            residual = Y_train(i,j) - X_train(i,:) * Beta_var(:,j);
            % Constraint: residual correction u must satisfy:
            %    -bigM * z(i) <= u(i,j) + residual <= bigM * z(i)
            Constraints = [Constraints, -opt.OI.bigM * z(i) <= u(i,j) + residual <= opt.OI.bigM * z(i)];
            % Link u and d so that d(i,j) >= |u(i,j)|; here, -d <= u <= d.
            Constraints = [Constraints, -d(i,j) <= u(i,j) <= d(i,j)];
        end
    end

    % The objective is to minimize the sum of d, which represents the L1-norm
    % of the residuals on the samples that are not eliminated.
    Objective = sum(sum(d));

    % Set up YALMIP options
    YALMIP_options = sdpsettings('solver', opt.OI.solver, 'verbose', opt.OI.verbose);

    %------------------------------------------------------------------
    % Continuous relaxation-rounding process (paper version):
    % Iteratively solve the LP and fix samples whose z value exceeds theta.
    % If no additional sample exceeds the threshold, the iteration is stopped.
    %------------------------------------------------------------------
    fixed_idx = false(m, 1);   % Boolean array to track samples fixed as outliers.
    iteration = 1;
    maxIter = opt.OI.maxIter;

    % Iteration for solving the problem with the continuous relaxation-rounding algorithm
    while iteration <= maxIter && sum(fixed_idx) < max_outliers
        
        % Add relaxed constraints with the current fixed status.
        FixedConstraints = [];
        for i = 1:m
            if fixed_idx(i)
                FixedConstraints = [FixedConstraints, z(i) == 1];
            end
        end

        % Solve the linear problem
        sol = optimize([Constraints, FixedConstraints], Objective, YALMIP_options);
        if sol.problem ~= 0
            success = false;
            disp('Solver failed during an iteration.');
            Beta = [];
            return;
        end

        % Get the current solution for z.
        z_val = value(z);

        % Identify new free samples (not yet fixed) whose z value is at least theta.
        new_fixed = (z_val >= opt.OI.theta) & (~fixed_idx);
        if any(new_fixed)
            % If any free sample has a z value at least theta, fix it.
            fixed_idx = fixed_idx | new_fixed;
        else
            % If no additional sample meets the threshold, break out of the loop.
            % => the ratio of outliers will be met.
            break;
        end
        
        
        %------------------------------------------------------------------
        % Process indicator: Every 10 iterations, print the current iteration,
        % maximum iterations, and percentage progress towards the fixed outlier target.
        %------------------------------------------------------------------
        if mod(iteration, 1) == 0
            fixedCount = sum(fixed_idx);
            pct = (fixedCount / max_outliers) * 100;
            fprintf('Iteration %d/%d: Fixed %d out of %d outliers (%.2f%% complete).\n', iteration, maxIter, fixedCount, max_outliers, pct);
        end
        
        % Update iteration count
        iteration = iteration + 1;
    end

    %------------------------------------------------------------------
    % Check if we have fixed the allowed number of outliers.
    % If not, print a warning and mark success as false.
    %------------------------------------------------------------------
    if sum(fixed_idx) < max_outliers
        fprintf('Warning: Only %d outliers were fixed, which is less than the allowed %d.\n', sum(fixed_idx), max_outliers);
        success = false;
    else
        success = true;  % finally, success = true only if here success is true and sol_final.problem = 0.
    end

    %------------------------------------------------------------------
    % Final rounding: fix z(i)==1 for fixed samples and z(i)==0 otherwise.
    %------------------------------------------------------------------
    FinalFixConstraints = [];
    for i = 1:m
        if fixed_idx(i)
            FinalFixConstraints = [FinalFixConstraints, z(i) == 1];
        else
            FinalFixConstraints = [FinalFixConstraints, z(i) == 0];
        end
    end

    % Solve the final LP with all z values fixed.
    sol_final = optimize([Constraints, FinalFixConstraints], Objective, YALMIP_options);
    if sol_final.problem ~= 0
        success = false;
        disp('Final solve failed.');
        Beta = [];
        return;
    end

    % Retrieve the estimated regression coefficients.
    Beta = value(Beta_var);

end
