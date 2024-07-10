function model = func_algorithm_LCP_JGDN(data, varargin)
% Linearly constrained programming without Jacobian guidance constraints, as a comparison with the LCP with Jacobian
% guidance constraints. 
%
% Always exceeds memory...
% 
% Ref. Y. Liu, Y. Wang, N. Zhang, D. Lu, and C. Kang, “A data-driven 
% approach to linearize power flow equations considering measurement noise,” 
% IEEE Transactions on Smart Grid, vol. 11, no. 3, pp. 2576–2587, 2019.

%% Start

% Specify the algorithm
model.algorithm = 'LCP_JGDN';  

% Warning for normalized data
if mean(data.train.Vm(:, 1)) < 0.1   % Original Vm should be around 1; normalized Vm would be very small
    warning('Plenty of solvers cannot find a solution when the data are normalized in this approach')
    warning('We suggest you use unnormalized data instead')
end

% Finalize options based on the default options of this method and the inputted options
opt = func_finalize_opt_method(model.algorithm, varargin{:});

% Transfer mpc from data to opt for convenience
opt.mpc = data.mpc;

% Set warning off if requested
func_warning_switch_singleCPU(opt.warning.switch)

% Mandatory predictor and response for input
opt.variable.predictor = {'P',  'Q'};  
opt.variable.response  = {'Va', 'Vm'}; 

% Mandatory predictor and response for output; but they will have indices as they are not messed up
model.predictorList = 'Fixed: P, Q';
model.responseList  = 'Fixed: Va, Vm';

% Predictor and response indices
model.predictorIdx.P = opt.mpc.bus(:, 1);
model.predictorIdx.Q = opt.mpc.bus(:, 1);
model.responseIdx.Va = opt.mpc.bus(:, 1);
model.responseIdx.Vm = opt.mpc.bus(:, 1);

% Divide the data into predictor X and response Y, for testing
[X, Y, ~, ~] = func_generate_XY(data);

% Sort P, Q, Va, Vm for optimization; we need data struct to do this
Y_train = [data.train.P,  data.train.Q];
X_train = [data.train.Va, data.train.Vm]; % Note: there are both known and unknown in Y_train and X_train

% Get numbers
[num_sample, num_var] = size(Y_train);  % Note: Y_train and X_train have the same dimensions here
num_var_half = num_var / 2;

% Start CVX to solve the linearly constrained programming with Jacobian guidance constraints for Beta
if opt.LCP.cvxQuiet
    cvx_quiet(true);          % Suppress CVX output
    disp('cvx starts to solve LCP_JGDN')
else
    cvx_quiet(false); 
end
% Start CVX
cvx_solver 'SDPT3'  % To make the result comparable, we use the same solver here
cvx_begin

    % Define the decision variables
    variable B(num_var, num_var)
    variable C(1, num_var)

    % Minimize the objective (no transpose for B)
%     minimize(sum(sum((Y_train - X_train * B - repmat(C, num_sample, 1)).^2))) % Doesn't work very well
    objective = sum(norms(Y_train - X_train * B' - repmat(C, num_sample, 1), 2, 2));  
    
    % Minimize the objective
    minimize(objective)
    
cvx_end

% Identify the bus type
[ref, pv, pq] = bustypes(opt.mpc.bus, opt.mpc.gen);

% Get Beta and C to match Eqn (4) in the reference paper; transpose for B
Beta  = B'; 
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
model.Beta = Beta;
model.Beta11 = Beta11;
model.Beta12 = Beta12;
model.Beta21 = Beta21;
model.Beta22 = Beta22;

% Separate the error, back to the dimension where rows are observations
model.error.Va  = error_X1(1:length([pv; pq]),     :)';
model.error.Vm  = error_X1(length([pv; pq])+1:end, :)';
model.error.P   = error_Y2(1:length(ref),          :)';
model.error.Q   = error_Y2(length(ref)+1,          :)';
model.error.all = [model.error.Vm, model.error.Va, model.error.P, model.error.Q];

% Separate the prediction, back to the dimension where rows are observations
model.yPrediction.Va  = X1_pred(1:length([pv; pq]),     :)';
model.yPrediction.Vm  = X1_pred(length([pv; pq])+1:end, :)';
model.yPrediction.P   = Y2_pred(1:length(ref),          :)';
model.yPrediction.Q   = Y2_pred(length(ref)+1,          :)';

% Separate the true value, back to the dimension where rows are observations
model.yTrue.Va  = X1_test(1:length([pv; pq]),     :)';
model.yTrue.Vm  = X1_test(length([pv; pq])+1:end, :)';
model.yTrue.P   = Y2_test(1:length(ref),          :)';
model.yTrue.Q   = Y2_test(length(ref)+1,          :)';

% Test the results if succeed
if strcmp(cvx_status, 'Solved')
    % Store the status
    model.success = 1;
else
    % Store the status
    model.success = 0;
end

% Specify the type of the model
model.type = 1;

% display
disp([model.algorithm, ' training & testing are done!'])

