%% Introduction
%  Training algorithm: ordinary partial least squares, solved by SIMPLS
% 
%  Note: 
%   [XL,YL,XS,YS,BETA] = PLSREGRESS(X,Y,NCOMP,...) returns the PLS regression
%   coefficients BETA. BETA is a (P+1)-by-M matrix, containing intercept
%   terms in the first row, i.e., Y = [ONES(N,1) X]*BETA + Yresiduals (the
%   first column). Hence, for the training we should remove the all-one
%   column in X_train manually. But for X_test, we can keep the all-one
%   column. 
%
%   Use the rank of X0 (centered predictors) will significantly improve
%   accuracy (error: from 1e-5 to 1e-10, TimeSeries), compared to using the
%   rank of X. 
%
%   Remove all-one from X and add it back later will significantly improve
%   accuracy (error: from incredibly large to 1e-5, Random).
%
%   PLS with SIMPLS and PLS with NIPALS are not exactly equivalent. The
%   difference lies in not only the final regression coefficients, but also
%   in T, etc. See "SIMPLS: an alternative approach to partial least 
%   squares regression". However, their differences for the final
%   regression coefficients are slight. 
%
%   The difference between SIMPLS and NIPALS also lies in the number of
%   components selected. NIPALS automatically uses the rank of X as the
%   number of components. SIMPLS, however, uses the rank of X0 (centered
%   predictors) as the number of components. When X is rank-deficient,
%   SIMPLS and NIPALS would use different number of components, thereby
%   leading to some differences in the final result. When X is full rank
%   (e.g., when X is noisy), SIMPLS and NIPALS automatically would the same
%   number of components, thereby leading to the same results. Note that
%   When X is rank-deficient, NIPALS can give a better accuracy; error
%   level: 1e-11, whereas SIMPLS's error level: 1e-8. This means that when
%   rank-deficient, a better choice of number of components may still exist
%   which is different from the rank of X0 and from the rank of X (see
%   PLS_SIM_bad). In this case, NIPALS still uses the rank of X. Why this
%   happens? This indicates that when X is rank-deficient, even though
%   using the same number of components, NIPALS can still generate a
%   different (better) model compared to SIMPLS. Need further
%   investigation!
%
%   When X is full rank, i.e., when the number of components is equal to the
%   number of col in X, SIMPLS boils down to OLS. So does NIPALS.
%   Interestingly, X is noisy often = X is full rank. Hence, when X is
%   noisy, SIMPLS boils down to OLS. So does NIPALS. 
%
%   A comparison with func_algorithm_PLS_SIM; use Vm^2 here
%
%  Use Vm^2: mean error is 2.9008e-07 (no noise, no outlier, TSR, norm)
%  Use Vm  : mean error is 2.0857e-07 (no noise, no outlier, TSR, norm)

%% Define the function
function result = func_algorithm_PLS_SIM2(X, Y)

% Specify the algorithm
result.algorithm = 'PLS_SIM2';

% specify input and output
X_train = X.train.all2;
Y_train = Y.train.all2;
X_test = X.test.all2;
Y_test = Y.test.all2;
X_train(:, 1) = [];    % We remove the all-one column in X_train manually

% train the result
result.Beta  = func_pls_SIMPLS(X_train, Y_train); 

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