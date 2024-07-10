function result = func_algorithm_LS_Hbw2(X, Y, opt)
%% Introduction
%  Training algorithm: ordinary least squares with Huber weighting function

% Specify the algorithm
result.algorithm = 'LS_Hbw2';   % Huber weighting

% specify input and output
X_train = X.train.all2;
Y_train = Y.train.all2;
X_test = X.test.all2;
Y_test = Y.test.all2;

% PCA decomposition (if requested)
if opt.HBW.PCA
    [X_train, D] = func_decompose_PCA(X_train, opt.HBW.numComponentRatio);
else
    D = eye(size(X_train, 2)); 
end

% Tuning the tuning constant
result.const = func_determine_Hbw_const(X_train, Y_train, D, result.algorithm, opt);

% Train the model
result.Beta = func_solve_Hbw(X_train, Y_train, D, opt.HBW.parallel, result.const, result.algorithm);

% test the result; similar to PLS
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