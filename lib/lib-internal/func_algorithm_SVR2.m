function result = func_algorithm_SVR2(X, Y, opt)
% func_algorithm_SVR - Perform linear regression using the ordinary Support
% Vector Regression (SVR) with linear kernel
%
%  A comparison to func_algorithm_SVR; use Vm^2 here
%
%  Use Vm^2: mean error is 0.0246 (no noise, no outlier, TSR, unnorm)
%  Use Vm  : mean error is 0.0123 (no noise, no outlier, TSR, norm/unnorm)
%
%   Cannot work in the case of all-zero inputs
%   fitrsvm works better than fitrlinear, although fitrlinear is faster
%   The overall perfermance is quite bad, whether optimizing the hyperparameters or not
%   Ordinary SVR with linear Kernel performs very bad, but polynomial Kernel is much better
%
%   Although the built-in fitrsvm can also do SVR, but the generated result
%   is very inaccurate (see: func_algorithm_SVR_builtIN). We suggest solve
%   the programing directly using func_solve_SVR_individual, which will
%   give more accurate model when there are outliers. 
%
%   This method is more accurate than, e.g., PLS with SIMPLS, but much less
%   accurate than LS with Huber weights, when outliers exist. 

%% Start

% Specify the algorithm
result.algorithm = 'SVR2';

% specify input and output
X_train = X.train.all2;
Y_train = Y.train.all2;
X_test = X.test.all2;
Y_test = Y.test.all2;

% train the result
[result.Beta, result.success] = func_solve_SVR(X_train, Y_train, opt);

% test the result
Y_prediction = X_test * result.Beta;
error = abs(Y_prediction - Y_test) ./ abs(Y_test);

% Get error of Vm from Vm^2; the first Npq cols in error correspond to Vm;
% tested by comparing the result with a stupid but accurate method.
% Doesn't matter whether the input data are normalized or not, i.e., the
% error formula here remains the same (norm factor will be eliminated
% anyway). Of course, the error will change because the training process is
% influenced by the normalization.
Npq = size(Y.test.Vm2, 2);
error(:, 1:Npq) = abs(sqrt(Y_prediction(:, 1:Npq)./Y_test(:, 1:Npq))-1);

% separate the error into different categories
result.error = func_split_error(Y, error);

% display
disp([result.algorithm, ' training/testing is done!'])
