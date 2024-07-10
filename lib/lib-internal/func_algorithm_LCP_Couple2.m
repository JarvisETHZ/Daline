function result = func_algorithm_LCP_Couple2(data, opt)
% Linearly constrained programming with 
% coupling constraints for Beta.
%
% Note: as done in the reference paper, we train the linear model between 
% branch flows and Vm2, Va. That is, Vm2 and Va are assumed as independent
% variables. Although this is impossible in reality, as the majority of Vm2
% and Va are unknown. However, to implement what the reference paper did,
% we didn't make any change. Note that this method cannot compare with
% others using known quantities as independent variables, as such
% comparison would be unfair. 
%
% Note: although comparison with other using known quantities as
% independent variables would be unfair, this method here still cannot
% outperform these approaches in term of the accuracy of branch flows. 
%
% Note: when the coupling constraints are removed, the accuracy has been
% improved for one order of magnitude. With coupling constraints, the
% average error is 1.8797e-05, without: 4.3252e-05. 
% 
% Note: the coupling constraints are only valid for branch flow model
% taking Va and Vm2 as predictors. 
%
% A comparsion to func_algorithm_LCP_Couple, i.e., here use Vm^2.
%
% Use Vm^2: mean error is 1.8797e-05 (no noise, no outlier, TSR, unnorm)
% Use Vm^2: mean error is 0.002 (no noise, no outlier, TSR, norm)
% Use Vm  : mean error is 0.002 (no noise, no outlier, TSR, norm)
% Use Vm  : mean error is 2.0586e-05 (no noise, no outlier, TSR, unnorm)
%
% Ref. Y.Liu, B.Xu, A.Botterud, N.Zhang, and C.Kang,“Boundingregression errors 
% in data-driven power grid steady-state models,” IEEE Transactions on 
% Power Systems, vol. 36, no. 2, pp. 1023–1033, 2020.

%% Start

% Specify the algorithm
result.algorithm = 'LCP_Couple2';  

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

% Add intercept manually as the struct data don't have that inside
X_test = [ones(size(X_test, 1), 1), X_test];

% Solve the LCP with coupling constraints; the first row refers to the
% constant row, i.e., BranchFlow = [1, X] * Beta
[BetaPF, PF_cvx_status] = func_solve_LCP_Couple(X_train, PF_train, opt);
[BetaPT, PT_cvx_status] = func_solve_LCP_Couple(X_train, PT_train, opt);
[BetaQF, QF_cvx_status] = func_solve_LCP_Couple(X_train, QF_train, opt);
[BetaQT, QT_cvx_status] = func_solve_LCP_Couple(X_train, QT_train, opt);

% Test the model
result.error.PF = abs(X_test * BetaPF - PF_test) ./ abs(PF_test);
result.error.PT = abs(X_test * BetaPT - PT_test) ./ abs(PT_test);
result.error.QF = abs(X_test * BetaQF - QF_test) ./ abs(QF_test);
result.error.QT = abs(X_test * BetaQT - QT_test) ./ abs(QT_test);
result.error.all = [result.error.PF, result.error.PT, result.error.QF, result.error.QT];

% Store the model
result.BetaPF = BetaPF;
result.BetaPT = BetaPT;
result.BetaQF = BetaQF;
result.BetaQT = BetaQT;

% Test the results if all succeed
if strcmp(PF_cvx_status, 'Solved') && strcmp(PT_cvx_status, 'Solved')  && ...
        strcmp(QF_cvx_status, 'Solved') && strcmp(QT_cvx_status, 'Solved')
    
    % Store the status
    result.success = 1;
    
    % Print the success
    disp([result.algorithm, ' training/testing is done!'])
    
else
    % Store the status
    result.success = 0;
    
    % Print the failure
    disp([result.algorithm, ' failed!'])
end

