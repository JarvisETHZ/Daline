function model = func_algorithm_PTDF(data, varargin)
% Training algorithm: classic DC-based PTDF model, on the basis of MATPOWER

%% Start

% Specify the algorithm
model.algorithm = 'PTDF';  

% Finalize options based on the default options of this method and the inputted options
opt = func_finalize_opt_method(model.algorithm, varargin{:});

% Transfer mpc from data to opt for convenience
opt.mpc = data.mpc;

% get bus index lists of each type of bus
[ref, ~, ~] = bustypes(opt.mpc.bus, opt.mpc.gen);

% Set warning off if requested
func_warning_switch_singleCPU(opt.warning.switch)

% Mandatory predictor and response for output; but they will have indices as they are not messed up
model.predictorList = 'Fixed: P';
model.responseList  = 'Fixed: PF';

% Predictor and response indices
model.predictorIdx.P = opt.mpc.bus(:, 1);
model.predictorIdx.P(ref) = []; % remove the power injection of the ref bus;
model.responseIdx.PF = 1:size(opt.mpc.branch, 1);

% Get testing data; no need training
X_test = data.test.P; 
X_test(:, ref) = [];  % remove the power injection of the ref bus; X_test indexed using the internal ordering
Y_test = data.test.PF;

% Get the PTDF matrix as Beta
model.Beta = makePTDF(data.mpc);
model.Beta = data.mpc.baseMVA * model.Beta';
model.Beta(ref, :) = [];  % remove the coeff for the power injection of the ref bus, which are all zero

% Testing
Y_pred = X_test * model.Beta;   % Y_pred_Va sorted by [pv; pq], back to degree
model.error.PF  = abs(Y_pred - Y_test) ./ abs(Y_test);
model.error.all = model.error.PF;

% Store the prediction
model.yPrediction.PF = Y_pred;

% Store the true value
model.yTrue.PF = Y_test;

% Specify the type of the model
model.type = 1;

% display
disp([model.algorithm, ' testing is done!'])