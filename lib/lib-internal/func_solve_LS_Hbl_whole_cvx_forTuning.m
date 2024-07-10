%% Introduction
%  Training algorithm: ordinary least squares with Huber loss function, 
%  by converting the problem to an equivalent 
%  quadratic convex problem first, and then use CVX to solve. 
%
%  You need to specify the threshold delta. You can also choose a different 
%  starting point for the search of the optimal solution. Here, the initial
%  point for Beta is zero by default. 
%
%  Note that there is a risk that MATLAB might collapse. I suggest to do
%  the training individually for each dependent variable. Of course, the
%  training result will be different compared to the task of the overall
%  training (taking all dependent variables into account in one training),
%  and using the average error of all dependent variables as an indicator 
%  to show the performance of the algorithm might be unfair, as it treats
%  each dependent variable individually. But, using the min/max error for
%  each dependent variable as the performance indicator could be fair
%  enough. 
%
%  Ref.: Boyd, S.P. and Vandenberghe, L., 2004. Convex optimization. 
%  Cambridge university press. P. 204

function [Beta, exitflag] = func_solve_LS_Hbl_whole_cvx_forTuning(X, Y, opt)

% Get numbers
num_sample = size(Y, 1);         % Number of data points
num_response = size(Y, 2);       % Number of response variables
num_predictor = size(X, 2);      % Number of response variables
delta = opt.HBL.delta;     % Threshold

% Use cvx to solve an equivalent convex problem
cvx_clear
if opt.HBL.cvxQuiet 
    cvx_quiet(true);          % Suppress CVX output
else
    cvx_quiet(false); 
end
func_cvx_solver(opt.HBL.solver)  % set solver
cvx_quiet(false); 
cvx_begin

    % Primary variable
    variable b(num_predictor, num_response)

    % Auxiliary variables
    variables z(num_sample, num_response) w(num_sample, num_response)

    % Equivalent convex problem
    minimize(0.5 * sum(sum(z.^2)) + delta * sum(sum(w)))
    subject to
        for col = 1:num_response
            -z(:, col) - w(:, col) <= Y(:, col) - X * b(:, col) <= z(:, col) + w(:, col);
            0 <= z(:, col) <= delta;
            w(:, col) >= 0;
        end

cvx_end

% Check if the problem was solved successfully and output exitflag
if strcmp(cvx_status, 'Solved')
    exitflag = 1;
else
    exitflag = 0;
end

% Output Beta
Beta = b;
