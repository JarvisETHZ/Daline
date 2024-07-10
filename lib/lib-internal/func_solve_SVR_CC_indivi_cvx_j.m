function [beta_j, cvx_status] = func_solve_SVR_CC_indivi_cvx_j(X, Yj, Nx, Ns, epsilon, bigM, probThreshold)
% Solve
cvx_begin
    % Define decision variables
    variable beta_j(Nx, 1)
    variable z_j(Ns, 1) binary

    % Objective function
    minimize(0.5 * beta_j' * beta_j)

    % Constraints
    subject to
        for i = 1 : Ns
             Yj(i) - X(i, :) * beta_j <= epsilon * z_j(i) + bigM * (1 - z_j(i));
            -Yj(i) + X(i, :) * beta_j <= epsilon * z_j(i) + bigM * (1 - z_j(i));
        end
        sum(z_j) >= probThreshold * Ns / 100;
cvx_end