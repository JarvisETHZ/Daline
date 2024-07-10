%% Introduction
%  Training algorithm: ordinary least squares with Huber loss function for
%  one dependent variable, directly solve Huber loss function based
%  optimization
%
%  The problem is a nonlinear unconstrained problem, which can be solved by
%  fminunc, calling quasi-newton algorithm. 
%
%  You need to specify the threshold delta. You can also choose a different 
%  starting point for the search of the optimal solution. Here, the initial
%  point for Beta is zero by default. 
%
%  Note that, although the problem is a convex problem, quasi-newton 
%  algorithm may not be able to find that solution. That's why I recommend
%  to convert the problem to an equivalent quadratic convex problem first, and
%  then use CVX to solve, as done in func_fit_Hbl_cvx. If quasi-newton 
%  algorithm can find the local minimum = global minimum, it will be the
%  same as the solution obtained from func_fit_Hbl_cvx.
%
%  Function func_fit_Hbl_direct_all can fit all dependent variables at one
%  shot, yet the resulting regression errors could be huge as fminunc
%  couldn't find a good solution. I suggest do
%  the training individually for each dependent variable. Of course, the
%  training result will be different compared to the task of the overall
%  training (taking all dependent variables into account in one training),
%  and using the average error of all dependent variables as an indicator 
%  to show the performance of the algorithm might be unfair, as it treats
%  each dependent variable individually. But, using the min/max error for
%  each dependent variable as the performance indicator could be fair
%  enough. 
%
%  Ref.: Y. Liu, Z. Li, and Y. Zhou, “Data-driven-aided linear three-phase 
%  power flow model for distribution power systems,” IEEE Transactions on 
%  Power Systems, 2021.

function [Beta, exitflag] = func_fit_Hbl_direct(X, y, delta, initialGuess, directOptions)

% Define the Huber loss function for all residual, defined as r
huberLoss = @(r) sum((abs(r) <= delta) .* (r.^2) + (abs(r) > delta) .* (delta * 2 * abs(r) - delta^2));

% Objective function to be minimized, i.e., r = y - X * b, where b is Beta
objFun = @(b) huberLoss(y - X * b);

% Initial solution
initialGuess = initialGuess * ones(size(X, 2), 1);

% Use fminunc to minimize the objective function; require the Optimization Toolbox in MATLAB
[Beta, ~, exitflag] = fminunc(objFun, initialGuess, directOptions);

