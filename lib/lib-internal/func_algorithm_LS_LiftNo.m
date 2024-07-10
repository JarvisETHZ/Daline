function result = func_algorithm_LS_LiftNo(X, Y)
%% Introduction
%  Training algorithm: ordinary least squares with Moore-Penrose inverse (collinearity). 
%  
%  As a comparison with func_algorithm_LS_Lift, where both the dimension
%  lifting and pseudoinverse are used. 

% Specify the algorithm
result.algorithm = 'LS_NoLift';

% specify input and output
X_train = X.train.all;
Y_train = Y.train.all;
X_test = X.test.all;
Y_test = Y.test.all;

% train the result
result.Beta = pinv(X_train' * X_train) * X_train' * Y_train;

% test the result
Y_prediction = X_test * result.Beta;
error = abs(Y_prediction - Y_test) ./ abs(Y_test);

% separate the error into different categories
result.error = func_split_error(Y, error);

% Record the det of XTX
result.det_XTX = det(X_train' * X_train);

% display
disp([result.algorithm, ' training/testing is done!'])