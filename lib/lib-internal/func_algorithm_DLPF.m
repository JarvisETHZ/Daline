function model = func_algorithm_DLPF(data, varargin)
% This function compute the results from the DLPF model
%
% ref. Yang, J., Zhang, N., Kang, C. and Xia, Q., 2016. A state-independent
% linear power flow model with accurate estimation of voltage magnitude.
% IEEE Transactions on Power Systems, 32(5), pp.3607-3617. 

%% Start

% Specify the algorithm
model.algorithm = 'DLPF';   

% Finalize options based on the default options of this method and the inputted options
opt = func_finalize_opt_method(model.algorithm, varargin{:});

% Transfer mpc from data to opt for convenience
opt.mpc = data.mpc;

% Set warning off if requested
func_warning_switch_singleCPU(opt.warning.switch)

% Mandatory predictor and response for output; but they will have indices as they are not messed up
model.predictorList = 'Fixed: Vm, Va, P, Q';
model.responseList  = 'Fixed: Vm, Va, PF, PT';

% get bus index lists of each type of bus
[ref, pv, pq] = bustypes(opt.mpc.bus, opt.mpc.gen);
pvq = [pv; pq];

% Predictor and response indices
model.predictorIdx.P  = pvq;
model.predictorIdx.Q  = pq;
model.predictorIdx.Vm = [ref; pv];
model.predictorIdx.Va = ref;
model.responseIdx.Va  = pvq;
model.responseIdx.Vm  = pq;
model.responseIdx.PF  = 1:size(opt.mpc.branch, 1);
model.responseIdx.PT  = 1:size(opt.mpc.branch, 1);

% Divide the data into predictor X and response Y, for testing
[X, Y, ~, ~] = func_generate_XY(data);

% Set the zero tap ratio as 1 to avoid NaN (no result would change)
opt.mpc.branch(find(opt.mpc.branch(:, opt.idx.TAP)==0), opt.idx.TAP) = 1;

% reorder X.test.Vm to make it match the order required in func_generate_DLPF
X.test.Vm  = [X.test.Vm(:,  end), X.test.Vm(:,  1:end-1)];  % ordered by [ref, pv]

% specify input and output
X_test  = [X.test.P,   X.test.Q,   X.test.Va,  X.test.Vm];
Y_test  = [Y.test.Va,  Y.test.Vm,  Y.test.PF,  Y.test.PT];

% generate the mapping matrix
model.Beta = func_generate_DLPF(opt.mpc, opt.idx);
model.Beta = model.Beta';   % So that Y = X * Beta

% test the model
Y_prediction = X_test * model.Beta;
error = abs(Y_prediction - Y_test) ./ abs(Y_test);

% separate the error
model.error.Va  = error(:, 1:size(Y.test.Va, 2));
model.error.Vm  = error(:, size(Y.test.Va, 2)+1:size(Y.test.Va, 2)+size(Y.test.Vm, 2));
model.error.PF  = error(:, size(Y.test.Va, 2)+size(Y.test.Vm, 2)+1:size(Y.test.Va, 2)+size(Y.test.Vm, 2)+size(Y.test.PF, 2));
model.error.PT  = error(:, size(Y.test.Va, 2)+size(Y.test.Vm, 2)+size(Y.test.PF, 2)+1:end);
model.error.all = error;

% Store the prediction
model.yPrediction.Va  = Y_prediction(:, 1:size(Y.test.Va, 2));
model.yPrediction.Vm  = Y_prediction(:, size(Y.test.Va, 2)+1:size(Y.test.Va, 2)+size(Y.test.Vm, 2));
model.yPrediction.PF  = Y_prediction(:, size(Y.test.Va, 2)+size(Y.test.Vm, 2)+1:size(Y.test.Va, 2)+size(Y.test.Vm, 2)+size(Y.test.PF, 2));
model.yPrediction.PT  = Y_prediction(:, size(Y.test.Va, 2)+size(Y.test.Vm, 2)+size(Y.test.PF, 2)+1:end);

% Store the true value
model.yTrue.Va  = Y_test(:, 1:size(Y.test.Va, 2));
model.yTrue.Vm  = Y_test(:, size(Y.test.Va, 2)+1:size(Y.test.Va, 2)+size(Y.test.Vm, 2));
model.yTrue.PF  = Y_test(:, size(Y.test.Va, 2)+size(Y.test.Vm, 2)+1:size(Y.test.Va, 2)+size(Y.test.Vm, 2)+size(Y.test.PF, 2));
model.yTrue.PT  = Y_test(:, size(Y.test.Va, 2)+size(Y.test.Vm, 2)+size(Y.test.PF, 2)+1:end);

% Specify the type of the model
model.type = 1;

% display
disp([model.algorithm, ' training & testing are done!'])