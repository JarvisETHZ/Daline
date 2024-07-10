function model = func_algorithm_DC_LS(data, varargin)
% Training algorithm: classic DC model with LS regression to optimize the
% linear model
%
% Ref. X. Li and K. Hedman, “Data driven linearized ac power flow model
% with regression analysis,” arXiv preprint arXiv:1811.09727, 2018.  

%% Start

% Specify the algorithm
model.algorithm = 'DC_LS';  

% Finalize options based on the default options of this method and the inputted options
opt = func_finalize_opt_method(model.algorithm, varargin{:});

% Transfer mpc from data to opt for convenience
opt.mpc = data.mpc;

% Set warning off if requested
func_warning_switch_singleCPU(opt.warning.switch)

% Mandatory predictor and response for output; but they will have indices as they are not messed up
model.predictorList = 'Fixed: P';
model.responseList  = 'Fixed: Va';

% Divide the data into predictor X and response Y, for testing
[X, Y, ~, ~] = func_generate_XY(data);

% Get training and testing data
[X_train_P, ~, ~] = func_prepare_DC(X.train, opt);
[X_test_P, B, pq, pvq, ref, Bf, Pfinj, baseMVA] = func_prepare_DC(X.test, opt);
Y_train = Y.train.Va;

% Predictor and response indices
model.predictorIdx.P = pvq;
model.responseIdx.Va = pvq;

% Get the regression matrix Beta; back to degree
alpha = inv(B(pvq, pvq))' * (180/pi);       

% Get the new X_train, by integrating alpha. 
X_train_P = X_train_P * alpha;   % sorted by [pv; pq]

% train the result
gamma = (X_train_P' * X_train_P) \ X_train_P' * Y_train;
% [~, ~, ~, ~, ~, ~, gamma] = func_pls_NIPALS(X_train, Y_train, opt);

% get the final beta
model.Beta = alpha * gamma;
model.det = det((X_train_P' * X_train_P));

% test the result; in degree
Y_pred_Va = X_test_P * model.Beta;

% Get Va sorted by original index, including Va_ref; aim to compute PF
Y_pred_Va_all = zeros(size(Y.test.Va, 1), size(opt.mpc.bus, 1));
Y_pred_Va_all(:, pvq) = Y_pred_Va * (pi/180);   % convert to radian
Y_pred_Va_all(:, ref) = X.test.Va * (pi/180);   % convert to radian
Y_pred_Va_all = Y_pred_Va_all';

% Get other unknown values based on Va
Y_pred_Vm = ones(size(Y.test.Vm, 1), length(pq));
Y_pred_PF = (Bf * Y_pred_Va_all + Pfinj) * baseMVA;
Y_pred_PF = Y_pred_PF';
Y_pred_PT = - Y_pred_PF;
Y_pred_QF = zeros(size(Y.test.QF));
Y_pred_QT = zeros(size(Y.test.QT));

% test the result
model.error.Va = abs(Y_pred_Va - Y.test.Va) ./ abs(Y.test.Va);
model.error.Vm = abs(Y_pred_Vm - Y.test.Vm) ./ abs(Y.test.Vm);
model.error.PF = abs(Y_pred_PF - Y.test.PF) ./ abs(Y.test.PF);
model.error.PT = abs(Y_pred_PT - Y.test.PT) ./ abs(Y.test.PT);
model.error.QF = abs(Y_pred_QF - Y.test.QF) ./ abs(Y.test.QF);
model.error.QT = abs(Y_pred_QT - Y.test.QT) ./ abs(Y.test.QT);
model.error.all = [model.error.Vm, model.error.Va, model.error.PF, model.error.PT, model.error.QF, model.error.QT];

% Store the prediction
model.yPrediction.Va = Y_pred_Va;
model.yPrediction.Vm = Y_pred_Vm;
model.yPrediction.PF = Y_pred_PF;
model.yPrediction.PT = Y_pred_PT;
model.yPrediction.QF = Y_pred_QF;
model.yPrediction.QT = Y_pred_QT;

% Store the true value
model.yTrue.Va = Y.test.Va;
model.yTrue.Vm = Y.test.Vm;
model.yTrue.PF = Y.test.PF;
model.yTrue.PT = Y.test.PT;
model.yTrue.QF = Y.test.QF;
model.yTrue.QT = Y.test.QT;

% Specify the type of the model
model.type = 1;

% display
disp([model.algorithm, ' training & testing are done!'])