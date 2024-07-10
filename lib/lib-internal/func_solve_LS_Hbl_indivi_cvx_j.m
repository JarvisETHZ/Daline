%% Introduction
%  Training algorithm: ordinary least squares with Huber loss function for
%  one dependent variable, by converting the problem to an equivalent 
%  quadratic convex problem first, and then use CVX to solve. 
%
%  You need to specify the threshold delta. You can also choose a different 
%  starting point for the search of the optimal solution. Here, the initial
%  point for Beta is zero by default. 
%
%  Function func_fit_Hbl_cvx_all can fit all dependent variables at one
%  shot, yet there is a risk that MATLAB might collapse. I suggest to do
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

function [Beta, exitflag] = func_solve_LS_Hbl_indivi_cvx_j(X, y, opt)

% Get numbers
num_sample = length(y);        % Number of data points
delta = opt.HBL.delta;   % Threshold

% Start
cvx_begin

    % Primary variable
    variable b(size(X,2))

    % Auxiliary variables
    variables z(num_sample) w(num_sample)
    
    % Aquivalent convex problem
    minimize(0.5 * sum(z.^2) + delta * sum(w))
    subject to
        -z - w <= y - X * b <= z + w;
        0 <= z <= delta;
        w >= 0;
        
cvx_end

% Check if the problem was solved successfully and output exitflag
if strcmp(cvx_status, 'Solved')
    exitflag = 1;
else
    exitflag = 0;
end

% Output Beta
Beta = b;