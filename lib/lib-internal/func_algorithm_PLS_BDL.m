function model = func_algorithm_PLS_BDL(data, varargin)
%  Training algorithm: partial least squares by bundling known and unknown 
%  variables. Aim is to handle bus-type variations. This code is developed
%  based on the reference paper, not using the open source code. Because the open
%  source code can only test the error of Vm and Va. Also, the open source
%  code doesn't completely match the reference paper, e.g., it only use
%  known P and Q as predictors, inconsistent with Eqn (8-9) in the
%  reference paper. Besides, this re-developed code seems neater. Note that
%  this code uses SIMPLS, aligned with the reference paper.
%
%  Ref.: Y. Liu, N. Zhang, Y. Wang, J. Yang, and C. Kang, “Data-driven 
%  power flow linearization: A regression approach,” IEEE Transactions on 
%  Smart Grid, vol. 10, no. 3, pp. 2569–2580, 2018.

%% Start

% Specify the algorithm
model.algorithm = 'PLS_BDL';

% Finalize options based on the default options of this method and the inputted options
opt = func_finalize_opt_method(model.algorithm, varargin{:});

% Get predictor and response lists; no index because of the reorganization
model.predictorList = 'Fixed: Vm, P, Q';
model.responseList  = 'Fixed: Vm, Va, P, Q, PF, PT, QF, QT';

% Divide the data into predictor X and response Y, for training and testing
[X, Y, ~, ~] = func_generate_XY(data);

% Allocate data into X1, X2, Y1, Y2
X1_train = [X.train.P, X.train.Q]; 
X2_train = X.train.Vm; 
Y1_train = [Y.train.Va, Y.train.P, Y.train.Vm, Y.train.PF, Y.train.PT, Y.train.QF, Y.train.QT];
Y2_train = Y.train.Q;
X1_test  = [X.test.P, X.test.Q]; 
X2_test  = X.test.Vm; 
Y1_test  = [Y.test.Va, Y.test.P, Y.test.Vm, Y.test.PF, Y.test.PT, Y.test.QF, Y.test.QT];
Y2_test  = Y.test.Q;

% Manually add an all-one column to the left of X1_test
X1_test = [ones(size(X1_test, 1), 1), X1_test];

% Train the original regression model. Note: Beta contains the intercept,
% i.e., potentially, there will be an all-one column at the left of 
% [X1_train, Y2_train], or say, at the left of X1_train. Hence, when
% testing, we need to add an all-one column to the left of X1_test. Also,
% whne separating Beta, the dimension of X1_train should increase 1. 
Beta = func_pls_SIMPLS([X1_train, Y2_train], [Y1_train, X2_train]);

% Separate Beta into beta11, beta12, beta21, beta22 (Note the dimension of X1)
num_col_x1 = size(X1_train, 2) + 1;
num_col_y1 = size(Y1_train, 2);
beta_11 = Beta(1:num_col_x1, 1:num_col_y1);
beta_12 = Beta(1:num_col_x1, num_col_y1+1:end);
beta_21 = Beta(num_col_x1+1:end, 1:num_col_y1);
beta_22 = Beta(num_col_x1+1:end, num_col_y1+1:end);

% Save regression result
model.Beta = Beta;   
model.beta_11 = beta_11;   
model.beta_12 = beta_12;   
model.beta_21 = beta_21;   
model.beta_22 = beta_22;   
model.det_22 = det(beta_22);   % The singularity of beta_22 is the key

% Test the regression model (Note the intercept in X1)
Y2_prediction = (X2_test - X1_test * beta_12) / beta_22;
Y1_prediction = X1_test * beta_11 + Y2_prediction * beta_21;
error_Y1 = abs(Y1_prediction - Y1_test) ./ abs(Y1_test);
error_Y2 = abs(Y2_prediction - Y2_test) ./ abs(Y2_test);
error = [error_Y1, error_Y2];

% Separate and save the error
[model.error, model.yPrediction, model.yTrue] = func_split_error_BDL(Y, error, [Y1_prediction, Y2_prediction], [Y1_test, Y2_test]);

% Specify the type of the model
model.type = 1;

% display
disp([model.algorithm, ' training & testing are done!'])