function result = func_algorithm_DC_temp(X, Y, opt)
% Training algorithm: classic DC model, on the basis of MATPOWER
% Tested by comparing this function to runpf of MATPOWER when using DCPF
% You can re-test this function by setting the data generation type as acpf
% and change the opt.mpopt in func_generate_dataTimeSeries to DC.
% Consequently, the mean error of this function is 2.7608e-15. 
%
% Note: You should use the unnormalized data

%% Start

% Specify the algorithm
result.algorithm = 'DC';  

% Get testing data; no need training
[X_test_P, B, pq, pvq, ref, Bf, Pfinj, baseMVA] = func_prepare_DC(X.test, opt);

% Get the regression matrix Beta; back to degree
result.Beta = inv(B(pvq, pvq))' * (180/pi);       

% Get Va according to Va([pv; pq]) = B([pv; pq], [pv; pq]) \ (Pbus([pv;
% pq]) - B([pv; pq], ref) * Va0(ref)); - B([pv; pq], ref) * Va0(ref) is
% alrealy in X_test.
Y_pred_Va = X_test_P * result.Beta;   % Y_pred_Va sorted by [pv; pq], back to degree

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
result.error.Va = abs(Y_pred_Va - Y.test.Va) ./ abs(Y.test.Va);
result.error.Vm = abs(Y_pred_Vm - Y.test.Vm) ./ abs(Y.test.Vm);
result.error.PF = abs(Y_pred_PF - Y.test.PF) ./ abs(Y.test.PF);
result.error.PT = abs(Y_pred_PT - Y.test.PT) ./ abs(Y.test.PT);
result.error.QF = abs(Y_pred_QF - Y.test.QF) ./ abs(Y.test.QF);
result.error.QT = abs(Y_pred_QT - Y.test.QT) ./ abs(Y.test.QT);
result.error.all = [result.error.Vm, result.error.Va, result.error.PF, result.error.PT, result.error.QF, result.error.QT];

% display
disp([result.algorithm, ' training/testing is done!'])
