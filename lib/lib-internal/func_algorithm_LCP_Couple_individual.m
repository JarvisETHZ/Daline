function result = func_algorithm_LCP_Couple_individual(data, X, Y, opt)
% Linearly constrained programming with coupling constraints for Beta.
%
% In this method, we first train the linear model between each branch flow
% and Vm/Va. Then, we extend this model into an overall linear model
% between branch flows and known power injections, voltages, and angles.
% For the extension, we also need another regression training. 
%
%
% Note:
%
% When trying to solve the problem in one shot, i.e., put all constraints
% together and minimize the sum of all norms of all branch flows, cvx
% cannot find a solution even though the problem is convex. Hence, we
% individually train the model for each line and stitch these models into
% an overall model. This way might be even more efficient. 
%
%
% Ref. Y.Liu,B.Xu,A.Botterud,N.Zhang,andC.Kang,“Boundingregression errors 
% in data-driven power grid steady-state models,” IEEE Transactions on 
% Power Systems, vol. 36, no. 2, pp. 1023–1033, 2020.

%% Start

% Specify the algorithm
result.algorithm = 'LCP_Couple';  

% Get training dataset; we need data struct to do this
PF_train = data.train.PF;
PT_train = data.train.PT;
QF_train = data.train.QF;
QT_train = data.train.QT;
Vm_train = data.train.Vm2;  % Try square
Va_train = data.train.Va;
X_train  = [Va_train, Vm_train];

% Get numbers
[num_sample, num_branch] = size(PF_train);  
[~,           num_X_var] = size(X_train);
num_X_var_half = num_X_var / 2;

% Define containers, the last four rows are the coefficients for Va_F, 
% Va_T, Vm_F, Vm_T, the first row is the constant 
BetaPF = zeros(5, num_branch);
BetaPT = zeros(5, num_branch);
BetaQT = zeros(5, num_branch);
BetaQF = zeros(5, num_branch);

% Define containers, the columns refer to the cvx_status when solving PF,
% PT, QF, QT, respectively. 
success = zeros(num_branch, 4);

% Get the index of From_bus and To_bus
idx.F = opt.mpc.branch(:, opt.idx.F_BUS);
idx.T = opt.mpc.branch(:, opt.idx.T_BUS);

% For line n, in X_train, the indices are:
%     idx.F(n) refers to the row index of Va_F
%     idx.T(n) refers to the row index of Va_T
%     num_X_var_half+idx.F(n) refers to the row index of Vm_F
%     num_X_var_half+idx.T(n) refers to the row index of Vm_T
idx.VaVm = zeros(num_branch, 4);
for n = 1:num_branch
    idx.VaVm(n, :) = [idx.F(n), idx.T(n), num_X_var_half + idx.F(n), num_X_var_half + idx.T(n)];
end

% Interact
backspaces = '';

% Start CVX to solve the linearly constrained programming with Jacobian guidance constraints for Beta
if opt.LCP.cvxQuiet
    cvx_quiet(true);          % Suppress CVX output
    disp('cvx starts to solve LCP_JGD')
else
    cvx_quiet(false); 
end

% Solve the LCP with coupling constraints
for n = 1:num_branch
    % Get inputs for PF
    X_line = X_train(:, idx.VaVm(n, :));
    Y_line = PF_train(:, n);
    [BetaPF(:, n), success(n, 1)] = func_solve_LCP_Couple_individual(X_line, Y_line, opt.LCP.coupleDelta);
    % Get inputs for PT
    X_line = X_train(:, idx.VaVm(n, :));
    Y_line = PT_train(:, n);
    [BetaPT(:, n), success(n, 2)] = func_solve_LCP_Couple_individual(X_line, Y_line, opt.LCP.coupleDelta);
    % Get inputs for QF
    X_line = X_train(:, idx.VaVm(n, :));
    Y_line = QF_train(:, n);
    [BetaQF(:, n), success(n, 3)] = func_solve_LCP_Couple_individual(X_line, Y_line, opt.LCP.coupleDelta);
    % Get inputs for QT
    X_line = X_train(:, idx.VaVm(n, :));
    Y_line = QT_train(:, n);
    [BetaQT(:, n), success(n, 4)] = func_solve_LCP_Couple_individual(X_line, Y_line, opt.LCP.coupleDelta);
    % Display progress
    pro_str = sprintf('Optimization for each branch complete percentage: %3.1f', 100 * n / num_branch);
    fprintf([backspaces, pro_str]);
    backspaces = repmat(sprintf('\b'), 1, length(pro_str)); % Subtract 1 to account for the newline character
end

% Test the results if all succeed
if mean(success(:)) == 1
    
    % Store the status
    result.success = 1;
    
    % Identify the bus type
    [ref, pv, pq] = bustypes(opt.mpc.bus, opt.mpc.gen);
    
    % Get Beta and C to match Eqn (4) in the reference paper
    Beta  = B; 
    Const = C';
    
    % Reorder Beta to match Eqn (4) in the reference paper 
    Beta11 = Beta([pv; pq; num_var_half+pq],                               [pv; pq; num_var_half+pq]);
    Beta12 = Beta([pv; pq; num_var_half+pq],                [ref; num_var_half+pv; num_var_half+ref]);
    Beta21 = Beta([ref; num_var_half+pv; num_var_half+ref],                [pv; pq; num_var_half+pq]);
    Beta22 = Beta([ref; num_var_half+pv; num_var_half+ref], [ref; num_var_half+pv; num_var_half+ref]);
    
    % Reorder Const to match Eqn (4) in the reference paper
    Const1 = Const([pv; pq; num_var_half+pq],                1);
    Const2 = Const([ref; num_var_half+pv; num_var_half+ref], 1);
    
    % Form the testing data to match Eqn (4) in the reference paper
    Y1_test = [X.test.P,  X.test.Q]';     % X.test.P  follows [pv; pq],   X.test.Q  follows pq
    Y2_test = [Y.test.P,  Y.test.Q]';     % Y.test.P  follows ref,        Y.test.Q  follows [pv; ref]
    X1_test = [Y.test.Va, Y.test.Vm]';    % Y.test.Va follows [pv; pq],   Y.test.Vm follows pq
    X2_test = [X.test.Va, X.test.Vm]';    % X.test.Va follows ref,        X.test.Vm follows [pv; ref]
    
    % Test, match Eqn (4) in the reference paper. Note: no theoretical
    % guarantee for the invertibility of Beta11, unlike the Jacobian matrix
    X1_pred = Beta11 \ (Y1_test - Beta12 * X2_test - Const1);
    Y2_pred = Beta21 * X1_pred + Beta22 * X2_test + Const2;
    error_X1 = abs(X1_pred -  X1_test) ./ abs(X1_test);
    error_Y2 = abs(Y2_pred -  Y2_test) ./ abs(Y2_test);
    
    % Store the results
    result.Beta11 = Beta11;
    result.Beta12 = Beta12;
    result.Beta21 = Beta21;
    result.Beta22 = Beta22;

    % Separate the error, back to the dimension where rows are observations
    result.error.Va  = error_X1(1:length([pv; pq]),     :)';
    result.error.Vm  = error_X1(length([pv; pq])+1:end, :)';
    result.error.P   = error_Y2(1:length(ref),          :)';
    result.error.Q   = error_Y2(length(ref)+1,          :)';
    result.error.all = [result.error.Vm, result.error.Va, result.error.P, result.error.Q];
    
    % Print the success
    disp([result.algorithm, ' training/testing is done!'])
    
else
    % Store the status
    result.success = 0;
    
    % Print the failure
    disp('Failed: LCP_JGD')
end

