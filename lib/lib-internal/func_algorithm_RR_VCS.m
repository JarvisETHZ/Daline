function model = func_algorithm_RR_VCS(data, varargin)
% Ridge regression with coordinate transformation: transforms data into V^2, VmiVmjcos(Vai-Vaj), and
% VmiVmjsin(Vai-Vaj), then using ridge regression to train the model
%
% Ref. Y. Chen, C. Wu, and J. Qi, “Data-driven power flow method based on 
% exact linear regression equations,” Journal of Modern Power Systems and 
% Clean Energy, 2021.

%% Start

% Specify the algorithm
model.algorithm = 'RR_VCS';

% Finalize options based on the default options of this method and the inputted options
opt = func_finalize_opt_method(model.algorithm, varargin{:});

% Get predictor and response lists; no index because of the reorganization
model.predictorList = 'Fixed: Vm2, P, Q';
model.responseList  = 'Fixed: Vm2, VmiVmjCosij, VmiVmjSinij';

% Get mpc from data
opt.mpc = data.mpc;

% Set warning off if requested
func_warning_switch_singleCPU(opt.warning.switch)

% Get indices
fbus = opt.mpc.branch(:, opt.idx.F_BUS);
tbus = opt.mpc.branch(:, opt.idx.T_BUS);
[ref, pv, pq] = bustypes(opt.mpc.bus, opt.mpc.gen);
pvq = [pv; pq];

% Build C and S data; note the unit for original angles is degree
C_train = data.train.Vm(:, fbus) .* data.train.Vm(:, tbus) .* cosd(data.train.Va(:, fbus) - data.train.Va(:, tbus));
S_train = data.train.Vm(:, fbus) .* data.train.Vm(:, tbus) .* sind(data.train.Va(:, fbus) - data.train.Va(:, tbus));

% Form VCS data, for training and testing. Note that Y.test refers to the
% original test data rather than the transformed data
% Note: no intercept, just like the ref. paper
X_train = [data.train.Vm(:, pv).^2,  data.train.P(:, pvq), data.train.Q(:, pq)];
Y_train = [data.train.Vm(:, pvq).^2, C_train, S_train];
X_test  = [data.test.Vm(:, pv).^2,  data.test.P(:, pvq), data.test.Q(:, pq)];
Y_test  = [data.test.Vm(:, pq), data.test.PF, data.test.PT, data.test.QF, data.test.QT];
% Y_test  = [data.test.Vm(:, pq), data.test.Va(:, pvq), data.test.PF, data.test.PT, data.test.QF, data.test.QT];

% get numbers
num_branch = length(fbus);
[num_train_sample, num_X_var] = size(X_train);
num_test_sample = size(X_test, 1);
num_pvq = length(pvq);
num_pq = length(pq);
num_pv = length(pv);

% Tune lambda using cross-validation
W = eye(num_train_sample);  % No weights
[lambda, ~] = func_tune_RR(X_train, Y_train, W, opt, 1);

% train the result
model.Beta = (X_train' * W * X_train + lambda * eye(num_X_var)) \ (X_train' * Y_train);

% Get the initial prediction
Y_pred_V2CS = X_test * model.Beta;

% get the prediction for unknown Vm
Y_pred_Vm_unknown = sqrt(Y_pred_V2CS(:, num_pv+1:num_pvq));

% fill in the value for all Vm
Y_pred_Vm_all = zeros(num_test_sample, num_pvq + length(ref));
Y_pred_Vm_all(:, pq) = Y_pred_Vm_unknown;
Y_pred_Vm_all(:, ref) = data.test.Vm(:, ref);
Y_pred_Vm_all(:, pv) = data.test.Vm(:, pv);

% get the prediction for C and S
Y_pred_C  = Y_pred_V2CS(:, num_pvq+1:num_pvq+num_branch);
Y_pred_S  = Y_pred_V2CS(:, num_pvq+num_branch+1:end);

% % Resolve the cos and sin value from C and S
% cosDiff = Y_pred_C ./ (Y_pred_Vm_all(:, fbus) .* Y_pred_Vm_all(:, tbus));
% sinDiff = Y_pred_S ./ (Y_pred_Vm_all(:, fbus) .* Y_pred_Vm_all(:, tbus));
% 
% % Derive all Va from cosDiff and sinDiff
% Y_pred_Va_all = func_compute_angles(sinDiff, cosDiff, num_pvq+1, ref, data.test.Va(:, ref), fbus, tbus);
% 
% % Get the unknown Va
% Y_pred_Va_unknown = Y_pred_Va_all(:, pvq);

% Compute the branch flows using Y_pred_VCS and the linear model w.r.t.
% line flows
Y_pred_Vall2CS = [Y_pred_Vm_all.^2, Y_pred_C, Y_pred_S];
[Y_pred_PF, Y_pred_PT, Y_pred_QF, Y_pred_QT, model.Beta_Vall2CS_Flow] = func_compute_flowVCS(opt, Y_pred_Vall2CS);

% Get the final prediction; remove Va cause Va doesn't matter when branch
% flows are computable
Y_pred = [Y_pred_Vm_unknown, Y_pred_PF, Y_pred_PT, Y_pred_QF, Y_pred_QT];
% Y_pred = [Y_pred_Vm_unknown, Y_pred_Va_unknown, Y_pred_PF, Y_pred_PT, Y_pred_QF, Y_pred_QT];

% Test the error
error = abs(Y_pred - Y_test) ./ abs(Y_test);
model.error.Vm = error(:, 1:num_pq);
model.error.PF = error(:, num_pq+1:num_pq+num_branch);
model.error.PT = error(:, num_pq+num_branch+1:num_pq+2*num_branch);
model.error.QF = error(:, num_pq+2*num_branch+1:num_pq+3*num_branch);
model.error.QT = error(:, num_pq+3*num_branch+1:end);
model.error.all = [model.error.Vm, model.error.PF, model.error.PT, model.error.QF, model.error.QT];

% Get predictions
model.yPrediction.Vm = Y_pred_Vm_unknown;
model.yPrediction.PF = Y_pred_PF;
model.yPrediction.PT = Y_pred_PT;
model.yPrediction.QF = Y_pred_QF;
model.yPrediction.QT = Y_pred_QT;
model.yTrue.Vm = data.test.Vm(:, pq);
model.yTrue.PF = data.test.PF;
model.yTrue.PT = data.test.PT;
model.yTrue.QF = data.test.QF;
model.yTrue.QT = data.test.QT;

% Specify the type of the model
model.type = 3;

% display
disp([model.algorithm, ' training & testing are done!'])
