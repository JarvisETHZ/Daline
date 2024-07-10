function model = func_algorithm_LS_REP(data, varargin)
% Repeated least squares, as a comparison with func_algorithm_LS_Rec
%
% Ref. Y. Liu, Z. Li and S. Sun, "A Data-Driven Method for Online
% Constructing Linear Power Flow Model," in IEEE Transactions on Industry
% Applications, doi: 10.1109/TIA.2023.3287152.  
%
% Ref. M. Badoni, A. Singh and B. Singh, "Variable Forgetting Factor
% Recursive Least Square Control Algorithm for DSTATCOM," IEEE Trans. Power
% Del., vol. 30, no. 5, pp. 2353-2361, Oct. 2015.  

% Specify the algorithm
model.algorithm = 'LS_REP';

% Get prepared for options, predictors, responses, and their lists, indices
[opt, X_train, X_test, Y_train, Y_test, numY, ...
 model.predictorList, model.responseList, model.predictorIdx, model.responseIdx] ... 
 = func_opts_predictor_response_singleCPU(model.algorithm, data, varargin{:});

% Get numbers
[num_sample, ~] = size(X_train);
percentage = opt.LSR.recursivePercentage;
num_new = round(num_sample * percentage / 100);
num_old = num_sample - num_new;

% Separate the training dataset into old and new parts
X_train_old = X_train(1:num_old, :);
Y_train_old = Y_train(1:num_old, :);
X_train_new = X_train(num_old+1:end, :);
Y_train_new = Y_train(num_old+1:end, :);

% Get the final Beta result after recursive update
[model.Beta, model.trainTime] = func_solve_LS_Rep(X_train_old, Y_train_old, X_train_new, Y_train_new);

% test the result
Y_prediction = X_test * model.Beta;
error = abs(Y_prediction - Y_test) ./ abs(Y_test);

% Summarize error/y_pred/y_test/model type based on the options
[model.error, model.yPrediction, model.yTrue, model.type, model.note] ...
    = func_summarize_result(model.Beta, error, numY, Y_prediction, Y_test, opt);

% display
disp([model.algorithm, ' training & testing are done!'])