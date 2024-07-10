function model = func_algorithm_LCP_COU2(data, varargin)
% Linearly constrained programming with coupling constraints for Beta
% Here, Vm2 instead of Vm used.
%
% Ref. Y.Liu, B.Xu, A.Botterud, N.Zhang, and C.Kang,"Bounding regression errors 
% in data-driven power grid steady-state models,” IEEE Transactions on 
% Power Systems, vol. 36, no. 2, pp. 1023–1033, 2020.

%% Start

% Specify the algorithm
model.algorithm = 'LCP_COU2';  

% Finalize options based on the default options of this method and the inputted options
opt = func_finalize_opt_method(model.algorithm, varargin{:});

% Transfer mpc from data to opt for convenience
opt.mpc = data.mpc;

% Set warning off if requested
func_warning_switch_singleCPU(opt.warning.switch)

% Mandatory predictor and response for output; but they will have indices as they are not messed up
model.predictorList = 'Fixed: Va, Vm2';
model.responseList  = 'Fixed: PF, PT, QF, QT';

% Predictor and response indices
model.predictorIdx.Va = opt.mpc.bus(:, 1);
model.predictorIdx.Vm = opt.mpc.bus(:, 1);
model.responseIdx.PF  = 1:size(opt.mpc.branch, 1);
model.responseIdx.PT  = 1:size(opt.mpc.branch, 1);
model.responseIdx.QF  = 1:size(opt.mpc.branch, 1);
model.responseIdx.QT  = 1:size(opt.mpc.branch, 1);

% Get training dataset; we need struct data to do this
PF_train = data.train.PF;
PT_train = data.train.PT;
QF_train = data.train.QF;
QT_train = data.train.QT;
X_train  = [data.train.Va, data.train.Vm2];

% Get testing dataset; we need struct data to do this
PF_test = data.test.PF;
PT_test = data.test.PT;
QF_test = data.test.QF;
QT_test = data.test.QT;
X_test  = [data.test.Va, data.test.Vm2];

% Add intercept manually as struct data don't have that inside; no need to
% add intercept for X_train here, because this will be done in
% func_solve_LCP_CoupleNo 
X_test = [ones(size(X_test, 1), 1), X_test];

% Solve the LCP with coupling constraints; the first row refers to the
% constant row, i.e., BranchFlow = [1, X] * Beta
[BetaPF, PF_cvx_status] = func_solve_LCP_Couple(X_train, PF_train, opt);
[BetaPT, PT_cvx_status] = func_solve_LCP_Couple(X_train, PT_train, opt);
[BetaQF, QF_cvx_status] = func_solve_LCP_Couple(X_train, QF_train, opt);
[BetaQT, QT_cvx_status] = func_solve_LCP_Couple(X_train, QT_train, opt);

 % Test the model
model.error.PF = abs(X_test * BetaPF - PF_test) ./ abs(PF_test);
model.error.PT = abs(X_test * BetaPT - PT_test) ./ abs(PT_test);
model.error.QF = abs(X_test * BetaQF - QF_test) ./ abs(QF_test);
model.error.QT = abs(X_test * BetaQT - QT_test) ./ abs(QT_test);
model.error.all = [model.error.PF, model.error.PT, model.error.QF, model.error.QT];

% Store the model
model.Beta   = [BetaPF, BetaPT, BetaQF, BetaQT];
model.BetaPF = BetaPF;
model.BetaPT = BetaPT;
model.BetaQF = BetaQF;
model.BetaQT = BetaQT;

% Store the prediction
model.yPrediction.PF = X_test * BetaPF;
model.yPrediction.PT = X_test * BetaPT;
model.yPrediction.QF = X_test * BetaQF;
model.yPrediction.QT = X_test * BetaQT;

% Store the true value
model.yTrue.PF = PF_test;
model.yTrue.PT = PT_test;
model.yTrue.QF = QF_test;
model.yTrue.QT = QT_test;

% Specify the type of the model
model.type = 1;

% Test the results if all succeed
if strcmp(PF_cvx_status, 'Solved') && strcmp(PT_cvx_status, 'Solved')  && ...
        strcmp(QF_cvx_status, 'Solved') && strcmp(QT_cvx_status, 'Solved')
    % Store the status
    model.success = 1;
else
    % Store the status
    model.success = 0;
end

% display
disp([model.algorithm, ' training & testing are done!'])

