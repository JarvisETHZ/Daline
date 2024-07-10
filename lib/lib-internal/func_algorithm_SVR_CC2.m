function result = func_algorithm_SVR_CC2(X, Y, opt)
% func_algorithm_SVR - Perform linear regression using the ordinary Support
% Vector Regression (SVR) using chance-constrained programming
%
% % Note: This function doesn't include the physical constraints for Beta in
% the chance-constrained programming. This is because the physical
% constraints in the reference paper are only valid when fitting a
% linear model for branch flows using Va/Vm as predictors. Such a model has
% a very limited application scope, and cannot compare with other methods
% in a fair way. Since the effect of integrating physical constraints has
% already been taken into account (e.g., Jacobian guidance constraints,
% coupling constraints, box constraints, etc), here we only implement the
% SVR using chance-constrained programming, as a comparison with the
% traditional SVR and other classic methods. 
%
% Note: here we use all the known as predictors, and all unknown as
% responses to maximize the application scope of this method. In this case,
% there are no physical constraints can apply, as all the physical
% constraints (e.g., Jacobian guidance constraints,
% coupling constraints, box constraints, etc) have very limited
% applicability, requiring the predictors and responses have particular
% physical meaning, arranging in a particular order. 
%
% In the case of outliers, when setting epsilon as 1e-4, this method
% performs much better than the original SVR using the built-in function of
% matlab. Also, this method is slightly better than other very accurate
% method, e.g., PLS with SIMPLS. The mean error for the former is 0.0830,
% and the mean error for the later is 0.0989 (in the case of outliers). 
%
% Although this method avoid tuning omega, it introduces another
% hyperparameter, the probability threshold. Hence, essentially it doesn't
% reduce the hyperparameter setting burden. 
%
% We suggest using the individual model for each response in Y, as the
% overall CC-SVR model cannot find a solution within an acceptable time. 
%
% You can only get a relatively good result when epsilon is tiny. However, 
% in this case solving the CC-SVR would be very time consuming even though
% the problem is already formulated in an individual manner. Note that
% you have to repeatedly solve the CC-SVR for each response in Y => more
% computational burden. 
%
% In the case without outliers, very difficult to find a solution when epsilon is small (e.g., 1e-4, but
% 1e-3 is okay), though being small can improve the accuracy. This is also
% admitted in the reference paper: when the problem becomes infeasible,
% improve epsilon! However, the same small epsilon can work for the classic
% SVR. Also, the classic SVR (programming) is more accurate and much faster (no binary
% variables), in the case without outliers. 
%
%
% A comparsion to func_algorithm_SVR. The only difference is Vm is now
% replaced with Vm^2 (but not in Y_test as we use Vm for error evaluation)
%
% Ref. Z. Shao, Q. Zhai, Z. Han, and X. Guan, “A linear ac unit commitment 
% formulation: An application of data-driven linear power flow model,” 
% International Journal of Electrical Power & Energy Systems, vol. 145, p. 108673, 2023.

%% Start

% Specify the algorithm
result.algorithm = 'SVR_CC2';

% specify input and output
X_train = X.train.all2;
Y_train = Y.train.all2;
X_test = X.test.all2;
Y_test = Y.test.all;

% Train the model using chance-constrained programming for SVR
[result.Beta, result.success] = func_solve_SVR_CC(X_train, Y_train, opt);

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



