function model = func_algorithm_LS_TOL(data, varargin)
% func_algorithm_LS_total - Perform linear regression using the ordinary
% total least squares method => replace inv(V_yy) with pinv(V_yy) when
% det(V_yy) == 0.

%% Start

% Specify the algorithm
model.algorithm = 'LS_TOL';

% Get prepared for options, predictors, responses, and their lists, indices
[opt, X_train, X_test, Y_train, Y_test, numY, ...
 model.predictorList, model.responseList, model.predictorIdx, model.responseIdx] ... 
 = func_opts_predictor_response_singleCPU(model.algorithm, data, varargin{:});

% get numbers
num_X_var = size(X_train,  2);

% Build XY
XY = [X_train, Y_train];

% Perform singular value decomposition for XY
[~, ~, V] = svd(XY);

% Get Vxy and Vyy from V
V_xy = V(1:num_X_var,     num_X_var+1:end);
V_yy = V(num_X_var+1:end, num_X_var+1:end);

% Training the model and get beta
model.det_Vyy = det(V_yy); 
if model.det_Vyy == 0
    model.Beta = -1 * V_xy * pinv(V_yy);
else
    model.Beta = -1 * V_xy / V_yy;
end

% test the result
Y_prediction = X_test * model.Beta;
error = abs(Y_prediction - Y_test) ./ abs(Y_test);

% Summarize error/y_pred/y_test/model type based on the options
[model.error, model.yPrediction, model.yTrue, model.type, model.note] ...
    = func_summarize_result(model.Beta, error, numY, Y_prediction, Y_test, opt);

% display
disp([model.algorithm, ' training & testing are done!'])
