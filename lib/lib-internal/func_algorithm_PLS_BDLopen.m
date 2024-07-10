function model = func_algorithm_PLS_BDLopen(data, varargin)
%  Training algorithm: partial least squares by bundling known and unknown 
%  variables. Aim is to handle bus-type variations. Note that the following
%  codes are wrapped from the open source code posted by the authors in the
%  reference below. In order to 100% re-implement the proposed method,
%  nothing from the original open source code is changed. Hence, the input
%  is data instead of X and Y. Also note that this method removes the 
%  power injection from the slack bus as well. 
%  
%  Ref.: Y. Liu, N. Zhang, Y. Wang, J. Yang, and C. Kang, “Data-driven 
%  power flow linearization: A regression approach,” IEEE Transactions on 
%  Smart Grid, vol. 10, no. 3, pp. 2569–2580, 2018.


%% Start

% Specify the algorithm
model.algorithm = 'PLS_BDLopen';

% Finalize options based on the default options of this method and the inputted options
opt = func_finalize_opt_method(model.algorithm, varargin{:});

% Get predictor and response lists; no index because of the reorganization
model.predictorList = 'Fixed: P, Q';
model.responseList  = 'Fixed: Vm, Va';

% specify training and testing data
data_train = data.train;
data_test = data.test;

% get numbers 
num_test = size(data_test.P, 1);
num_bus = size(data.mpc.bus, 1);

% get the ref index
[ref, pv, pq] = bustypes(data.mpc.bus, data.mpc.gen);

% train the regression model
[Xva, Xv, ~, ~] = func_pls_bundle(data_train, ref);

% test the regression model => the open source code only tests the errors
% of Vm and Va, so does here (although in func_pls_bundle the open source
% code computes PF and QF) 
model.error = func_test_pls_bundle(num_test, data_test, Xv, Xva, ref, pv, pq, num_bus);

% Transfer the det(X22) from model.error.det_X22 to model.det_X22, and delete
% model.error.det_X22, otherwise it will cause the visualization function invalid
model.det_X22 = model.error.det_X22;
model.error = rmfield(model.error, 'det_X22');

% Specify the type of the model
model.type = 1;

% display
disp([model.algorithm, ' training & testing are done!'])