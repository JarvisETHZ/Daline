function result = func_algorithm_DCno_LS(X, Y, opt)
% Training algorithm: LS regression without DC model, as a comparison with
% func_algorithm_DC_LS. But the predictor and response selections follow
% the DC model. 
%
% Note: You should use the unnormalized data
%
% While multiplying with alpha already, (X_train' * X_train) is still very
% close to singularity (det=0). However, the accuracy of this method is
% much better than func_algorithm_DC. Yet, the accuracy is still worse than
% other very accurate method. The main reason might be that the reference
% paper only uses LS rather than other more accurate regression method. 
%
% Ref. X. Li and K. Hedman, “Data driven linearized ac power flow model
% with regression analysis,” arXiv preprint arXiv:1811.09727, 2018.  

%% Start

% Specify the algorithm
result.algorithm = 'DCno_LS';  

% Get training and testing data
Y_train = Y.train.Va;
Y_test  = Y.test.Va;
X_train = X.train.P;
X_test  = X.test.P;

% train the result
% result.Beta = pinv(X_train' * X_train) * X_train' * Y_train;
[~, ~, ~, ~, ~, ~, result.Beta] = func_pls_NIPALS(X_train, Y_train, opt);
result.det = det((X_train' * X_train));

% test the result
Y_prediction = X_test * result.Beta;
result.error.Va = abs(Y_prediction - Y_test) ./ abs(Y_test);
result.error.all  = result.error.Va;

% display
disp([result.algorithm, ' training/testing is done!'])