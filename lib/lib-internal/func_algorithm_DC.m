function model = func_algorithm_DC(data, varargin)
% Training algorithm: classic DC model, on the basis of MATPOWER
% Tested by comparing this function to runpf of MATPOWER when using DCPF
% You can re-test this function by setting the data generation type as acpf
% and change the opt.mpopt in func_generate_dataTimeSeries to DC.
% Consequently, the mean error of this function is 2.7608e-15. 
%
% Note: You should use the unnormalized data

%% Start

% Specify the algorithm
model.algorithm = 'DC';  

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

% Get testing data; no need training
[X_test_P, B, pq, pvq, ref, Bf, Pfinj, baseMVA] = func_prepare_DC(X.test, opt);

% Predictor and response indices
model.predictorIdx.P = pvq;
model.responseIdx.Va = pvq;

% Get the regression matrix Beta; back to degree
model.Beta = inv(B(pvq, pvq))' * (180/pi);       

% Get Va according to Va([pv; pq]) = B([pv; pq], [pv; pq]) \ (Pbus([pv;
% pq]) - B([pv; pq], ref) * Va0(ref)); - B([pv; pq], ref) * Va0(ref) is
% already in X_test.
Y_pred_Va = X_test_P * model.Beta;   % Y_pred_Va sorted by [pv; pq], back to degree

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
disp([model.algorithm, ' testing is done!'])