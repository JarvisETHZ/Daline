function model = func_algorithm_LCP_BOX(data, varargin)
% func_algorithm_LCP_box: Linearly constrained programming with box (bound)
% constraints for Beta.
%
% Since the details are not given in the paper, we show the details below.
% Briefly, we know that the Jacobian matrix
% 
%                         J = dx/dy 
%
% where x refers to the power injections and y refers to voltages. 
% We also know that around an operating point 0, 
% 
%                     J0 = (dx/dy)|0 ≈ (x-x0)/(y-y0)
%
% Hence, within the neighborhood of point 0, we have
%
%                       J0*(y-y0) ≈ (x-x0)
% 
% which is the basis of the Taylor approximation, i.e.,
%
%                y ≈ inv(J0)*x + y0 - inv(J0)*x0 
%
% Transpose y and x to match the data structure in this code, we have:
%
%                y' = [1, x'] * [(y0' - x0'*inv(J0)'); inv(J0)']
%                y' ≈ [1, x'] * Beta
%
% for each data point 0. Hence, we can use [(y0' - x0' * inv(J0)'); inv(J0)'] 
% to constrain the max/min of Beta when estimating Beta in a data-driven manner, 
% i.e.,
%
% [(y0' - x0' * inv(J0)'); inv(J0)']_min <= Beta <= [(y0' - x0' * inv(J0)'); inv(J0)']_max
% 
% yielding the linearly constrained programming with box (bound) constraints 
% for Beta, using massive samples of the operating point 0. 
%
% In this code, we use the training datasets X and Y as different operating 
% points 0, to find the max/min values of [(y0' - x0' * inv(J0)'); inv(J0)']. 
%
% Besides, the Jacobian matrix here satisfies
%
%                          dx = J * dy
%                    [dP; dQ] = J * [dVa; dVm]
%
% where dP is sorted aligned with indices [pv;pq], dQ sorted with [pq], dVa
% sorted with [pv;pq], and dVm with [pq]. This order is aligned with the 
% generated data X.train.P, X.train.Q, Y.train.Va, and Y.train.Vm.
%
% Ref. Y.Liu,B.Xu,A.Botterud,N.Zhang,and C.Kang,“Bounding regression errors 
% in data-driven power grid steady-state models,” IEEE Transactions on 
% Power Systems, vol. 36, no. 2, pp. 1023–1033, 2020.

%% Start

% Specify the algorithm
model.algorithm = 'LCP_BOX';   % Linearly constrained programming with box (bound) constraints for Beta.

% Finalize options based on the default options of this method and the inputted options
opt = func_finalize_opt_method(model.algorithm, varargin{:});

% Set warning off if requested
func_warning_switch_singleCPU(opt.warning.switch)

% Mandatory predictor and response for input
opt.variable.predictor = {'P',  'Q'};  
opt.variable.response  = {'Va', 'Vm'}; 

% Mandatory predictor and response for output; but they will have indices as they are not messed up
model.predictorList = 'Fixed: P, Q';
model.responseList  = 'Fixed: Va, Vm';

% Specify and transform input and output
[X_train, X_test, Y_train, Y_test, numY, ~, ~, model.predictorIdx, model.responseIdx] = func_generate_predictor_response(data, opt);

% Manually remove the intercept because of the estimation of J
X_train(:, 1) = [];
X_test(:, 1) = [];

% Transfer mpc from data to opt for convenience
opt.mpc = data.mpc;

% Get numbers
[num_sampleTrain, num_X_var] = size(X_train);
[~,               num_Y_var] = size(Y_train);
[num_sampleTest,  ~        ] = size(X_test);

% Interact
backspaces = '';

% Get the admittance matrix for generating the Jacobian matrix
[Ybus, ~, ~] = makeYbus(opt.mpc.baseMVA, opt.mpc.bus, opt.mpc.branch);

% Define containers for the min/max element-wise values, include the intercept
Beta_min = zeros(num_X_var+1, num_Y_var);
Beta_max = zeros(num_X_var+1, num_Y_var);

% Find the min/max for Beta using the training data
for n = 1:num_sampleTrain
    
    % Get an operating point
    Va = data.train.Va(n, :)';                 % Va must be degree value, because sind and cosd is used for V (but no difference after normalization)
    Vm = data.train.Vm(n, :)';
    V  = Vm .* cosd(Va) + 1j * Vm .* sind(Va); % Polar coordinates

    % Compute J0 w.r.t. the given unknown voltage magnitudes and angles
    J0 = func_generate_Jacobian(Ybus, V, Vm, opt);
    
    % Compute the potential value of Beta by [(y0' - x0' * inv(J0)'); inv(J0)']
    % The invertibility of J0 can be theoretically guaranteed
    y0 = Y_train(n, :)';
    x0 = X_train(n, :)';
    Beta_box = [(y0' - x0' * inv(J0)'); inv(J0)'];
    
    % Store the min and max values for each element
    Beta_min = min(Beta_min, Beta_box);
    Beta_max = max(Beta_max, Beta_box);
    
    % Display progress
    pro_str = sprintf('Evaluate Jacobian matrix complete percentage: %3.1f', 100 * n / num_sampleTrain);
    fprintf([backspaces, pro_str]);
    backspaces = repmat(sprintf('\b'), 1, length(pro_str)); % Subtract 1 to account for the newline character
end

% Interact
fprintf('\n');

% Add the intercept back manually
X_train = [ones(num_sampleTrain, 1), X_train];
X_test  = [ones(num_sampleTest, 1),  X_test ];

% Start CVX to solve the linearly constrained programming with box (bound) 
% constraints for Beta
if opt.LCP.cvxQuiet
    cvx_quiet(true);          % Suppress CVX output
    disp('cvx starts to solve LCP_BOX')
else
    cvx_quiet(false); 
end
func_cvx_solver(opt.LCP.solver)  % set solver
cvx_begin
    % Define Beta as a variable
    variable B(num_X_var+1, num_Y_var)
    
    % Define the objective function
    minimize(sum(sum((Y_train - X_train*B).^2)))
    
    % Add constraints
    subject to
        Beta_min <= B <= Beta_max
cvx_end

% Test the model
model.Beta = B;
Y_prediction = X_test * model.Beta;
error  = abs(Y_prediction - Y_test) ./ abs(Y_test);

% Summarize error/y_pred/y_test/model type based on the options
[model.error, model.yPrediction, model.yTrue, model.type, model.note] ...
    = func_summarize_result(model.Beta, error, numY, Y_prediction, Y_test, opt);

% Test the results if succeed
if strcmp(cvx_status, 'Solved')
    % Store the status
    model.success = 1;
else
    % Store the status
    model.success = 0;
end


% display
disp([model.algorithm, ' training & testing are done!'])

