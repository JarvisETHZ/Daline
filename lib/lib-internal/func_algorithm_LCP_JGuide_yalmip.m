function result = func_algorithm_LCP_JGuide_yalmip(data, X, Y, opt)

%% Start

% Specify the algorithm
result.algorithm = 'LCP_JGuide';

% Sort P, Q, Va, Vm for optimization; we need data struct to do this
% Y_train = [data.train.P, data.train.Q];
Y_train = [data.train.P(:, 1), data.train.Q(:, 1)];
X_train = [data.train.Va, data.train.Vm]; % Note: there are both known and unknown in Y_train and X_train

% Get numbers
[num_sample, num_var] = size(Y_train);  % Note: Y_train and X_train have the same dimensions here
num_var_half = num_var / 2;

% Set YALMIP options
options = sdpsettings('verbose', 0, 'solver', 'Gurobi');

% Define the decision variables
B = sdpvar(num_var, num_var);
C = sdpvar(1, num_var);
Bb = sdpvar(num_var_half, num_var_half, 'symmetric');
Bg = sdpvar(num_var_half, num_var_half, 'symmetric');
Bp = sdpvar(num_var_half, num_var_half, 'diagonal');
Bq = sdpvar(num_var_half, num_var_half, 'diagonal');

% Define the objective function; transpose for B
objective = sum(sum((Y_train - X_train * B' - repmat(C, num_sample, 1)).^2));

% Add constraints
constraints = [B == [Bb, -Bg; Bg, Bb] + [-Bq, Bp; Bp, Bq]];

% Solve the problem using YALMIP
sol = optimize(constraints, objective, options);

% Identify the bus type
[ref, pv, pq] = bustypes(opt.mpc.bus, opt.mpc.gen);

% Get Beta and C to match Eqn (4) in the reference paper; no transpose for B
Beta  = value(B); 
Const = value(C);
Const = Const';

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

% Test the results if succeed
if sol.problem == 0
    
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
