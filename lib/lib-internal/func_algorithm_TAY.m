function model = func_algorithm_TAY(data, varargin)
% func_algorithm_LCP_Taylor: 1st order Taylor approximation
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
% as Beta to compute power flows. 
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
% Ref. many!

%% Start

% Specify the algorithm
model.algorithm = 'TAY';   % Linearly constrained programming with box (bound) constraints for Beta.

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
[num_sampleTest,  ~] = size(X_test);

% Get the admittance matrix for generating the Jacobian matrix
[Ybus, ~, ~] = makeYbus(opt.mpc.baseMVA, opt.mpc.bus, opt.mpc.branch);

% Get the idx of the given operating point
idx_point0 = opt.TAY.point0;
if strcmp(idx_point0, 'end')
   idx_point0 = size(X_train, 1);  % If opt.TAY.point0 = 'end', take the last sample in X_train as the given operating point
end

% Get the given operating point
Va0 = data.train.Va(idx_point0, :)';    % Va must be unnormed degree value, becasue sind and cosd is used for V
Vm0 = data.train.Vm(idx_point0, :)';
V0  = Vm0 .* cosd(Va0) + 1j * Vm0 .* sind(Va0); % Polar coordinates
y0  = Y_train(idx_point0, :)';
x0  = X_train(idx_point0, :)';

% Compute J0 w.r.t. the given unknown voltage magnitudes and angles
J0 = func_generate_Jacobian(Ybus, V0, Vm0, opt);

% Compute Beta by [(y0' - x0' * inv(J0)'); inv(J0)']; the invertibility of J0 can be theoretically guaranteed
model.Beta = [(y0' - x0' * inv(J0)'); inv(J0)'];
% result.Beta = inv(J0)';  % will lead to huge error

% Add the intercept manually
X_test  = [ones(num_sampleTest, 1),  X_test];

% Test
Y_prediction = X_test * model.Beta;
error = abs(Y_prediction - Y_test) ./ abs(Y_test);

% Summarize error/y_pred/y_test/model type based on the options
[model.error, model.yPrediction, model.yTrue, model.type, model.note] ...
    = func_summarize_result(model.Beta, error, numY, Y_prediction, Y_test, opt);

% display
disp([model.algorithm, ' training & testing are done!'])
