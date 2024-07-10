%% Section 2.3

% Example 1: data generation (see Table 3.1, 3.2, 3.3, 3.4, 3.5 and 3.6 for all the adjustable parameters for daline.data)
% (See Section 3.1.2 for the details about the output data)
data = daline.data('case.name', 'case118', 'data.program', 'acpf', 'data.baseType', 'TimeSeriesRand');

% Example 2: data generation (see Table 3.1, 3.2, 3.3, 3.4, 3.5 and 3.6 for all the adjustable parameters for daline.data)
opt = daline.setopt('case.name', 'case57', 'data.program', 'acpf', 'data.baseType', 'TimeSeriesRand');
data = daline.data(opt);

% Example 3: data generation plus model training and testing via method RR --- using name-value pairs to set up parameters
model = daline.all('case118', 'data.baseType', 'TimeSeriesRand', 'method.name', 'RR');
model = daline.all('case118', 'data.baseType', 'TimeSeriesRand', 'method.name', 'RR', 'variable.response', {'Vm2'});
model = daline.all('case118', 'data.baseType', 'TimeSeriesRand', 'method.name', 'RR', 'variable.Vm22Vm', 0, 'variable.response', {'Vm2'});

% Example 4: data generation plus model training and testing via method RR --- using opt structure to set up parameters
opt = daline.setopt('data.baseType', 'TimeSeriesRand', 'method.name', 'RR');
model = daline.all('case118', opt);

% Example 5: data generation plus model training and testing via method RR --- using opt structure to set up parameters
opt = daline.setopt('data.baseType', 'TimeSeriesRand', 'method.name', 'RR', 'variable.Vm22Vm', 0, 'variable.response', {'Vm2'});
model = daline.all('case118', opt);

%% Section 2.4

% Example 1: get the list of adjustable parameters for two categories: 'generate data' and 'add outlier'
% (see Table 2.3 for all the categories of parameters for daline.getopt)
opt = daline.getopt('generate data', 'add outlier');

% Example 2: get the list of adjustable parameters for different categories
% (see Table 2.3 for all the categories of parameters for daline.getopt)
opt = daline.getopt('RR_KPC');
opt = daline.getopt('LS');
opt = daline.getopt('generate data', 'RR_KPC'); 

% Ex3 - incorrect demo
% opt = daline.getopt('generate data', 'RR_KPC', 'RR'); 
% opt = daline.getopt('RR_KPC', 'RR');

%% Section 3.1

% Example 1: data generation (see Table 3.1 for all the adjustable parameters for daline.generate)
data = daline.generate('case.name', 'case118', 'data.program', 'acpf', 'data.baseType', 'TimeSeriesRand');

% Example 2: data generation (see Table 3.1 for all the adjustable parameters for daline.generate)
% Using the opt structure way to set up parameters
opt = daline.setopt('case.name', 'case39', 'num.trainSample', 500, 'num.testSample', 300, 'data.fixRand', 1);
data = daline.generate(opt);

% Example 3: data generation (see Table 3.1 for all the adjustable parameters for daline.generate) 
% Assume mpc is an external power system case from users that satisfies the MATPOWER case format 
mpc = ext2int(loadcase('case39')); % Assume this is the system uploaded by users
data = daline.generate('case.mpc', mpc, 'load.upperRange', 1.1, 'load.lowerRange', 0.9);

% Example 4: data generation (see Table 3.1 for all the adjustable parameters for daline.generate) 
% Assume mpc is an external power system case from users that satisfies the MATPOWER case format 
% Use opt structure to set up parameters
mpc = ext2int(loadcase('case118')); % Assume this is the system uploaded by users
opt = daline.setopt('case.mpc', mpc, 'data.baseType', 'TimeSeriesRand', 'load.timeStart', '7:00', 'load.timeEnd',  '9:30');
data = daline.generate(opt);

%% Section 3.2.2

% Example 1: data generation and adding noise to data (see Table 3.2 for all the adjustable parameters for daline.noise) 
data = daline.generate('case.name', 'case118', 'data.program', 'acpf', 'data.baseType', 'TimeSeriesRand');
data = daline.noise(data, 'noise.switchTrain', 1, 'noise.SNR_dB', 46);
data = daline.noise(data, 'noise.switchTest', 1, 'noise.SNR_dB', 46);
data = daline.noise(data, 'data.fixRand', 1, 'noise.switchTest', 1, 'noise.SNR_dB', 45);

% Example 2: data generation and adding noise to data (see Table 3.2 for all the adjustable parameters for daline.noise) 
% Use opt structure to set up parameters
data = daline.generate('case.name', 'case118', 'data.program', 'acpf', 'data.baseType', 'TimeSeriesRand');
opt  = daline.setopt('noise.switchTrain', 1, 'noise.switchTest', 1, 'noise.SNR_dB', 45);
data = daline.noise(data, opt);

%% Section 3.2.3

% Example 1: data generation and adding outlier to data (see Table 3.3 for all the adjustable parameters for daline.outlier) 
data = daline.generate('case.name', 'case118', 'data.program', 'acpf', 'data.baseType', 'TimeSeriesRand');
data = daline.outlier(data, 'outlier.switchTrain', 1, 'outlier.percentage', 2.5);

% Example 2: data generation and adding outlier to data (see Table 3.3 for all the adjustable parameters for daline.outlier) 
% Use opt structure to set up parameters
data = daline.generate('case.name', 'case118', 'data.program', 'acpf', 'data.baseType', 'TimeSeriesRand');
opt  = daline.setopt('outlier.switchTrain', 1, 'outlier.switchTest', 1, 'outlier.factor', 3);
data = daline.outlier(data, opt);

%% Section 3.2.4

% Example 1: data generation, adding noise, and filter noise (see Table 3.4 for all the adjustable parameters for daline.denoise) 
data = daline.generate('case.name', 'case118', 'data.program', 'acpf', 'data.baseType', 'TimeSeriesRand');
data = daline.noise(data, 'data.fixRand', 1, 'noise.switchTest', 1, 'noise.SNR_dB', 45);
data = daline.denoise(data, 'filNoi.switchTrain', 1, 'filNoi.useARModel', false);

% Example 2: data generation, adding noise, and filter noise (see Table 3.4 for all the adjustable parameters for daline.denoise) 
% Use opt structure to set up parameters
data = daline.generate('case.name', 'case118', 'data.program', 'acpf', 'data.baseType', 'TimeSeriesRand');
data = daline.noise(data, 'data.fixRand', 1, 'noise.switchTest', 1, 'noise.SNR_dB', 45);
opt  = daline.setopt('filNoi.switchTrain', 1, 'filNoi.useARModel', false, 'filNoi.zeroInitial', 0);
data = daline.denoise(data, opt);

%% Section 3.2.5

% Example 1: data generation, adding outliers, and filter outliers (see Table 3.5 for all the adjustable parameters for daline.deoutlier) 
data = daline.generate('case.name', 'case118', 'data.program', 'acpf', 'data.baseType', 'TimeSeriesRand');
data = daline.outlier(data, 'outlier.switchTrain', 1, 'outlier.factor', 2, 'outlier.percentage', 0.5);
data = daline.deoutlier(data, 'filOut.switchTrain', 1, 'filOut.method', 'quartiles', 'filOut.tol', 100);

% Example 2: data generation, adding outliers, and filter outliers (see Table 3.5 for all the adjustable parameters for daline.deoutlier) 
% Use opt structure to set up parameters
data = daline.generate('case.name', 'case118', 'data.program', 'acpf', 'data.baseType', 'TimeSeriesRand');
data = daline.outlier(data, 'outlier.switchTrain', 1, 'outlier.factor', 2, 'outlier.percentage', 0.5);
opt  = daline.setopt('filOut.switchTrain', 1, 'filOut.method', 'quartiles', 'filOut.tol', 100);
data = daline.deoutlier(data, opt);

%% Section 3.2.6

% Example 1: data generation and data normalization (see Table 3.6 for all the adjustable parameters for daline.normalize) 
data = daline.generate('case.name', 'case118', 'data.program', 'acpf', 'data.baseType', 'TimeSeriesRand');
data = daline.normalize(data, 'norm.switch', 1);

% Example 1: data generation and data normalization (see Table 3.6 for all the adjustable parameters for daline.normalize) 
% Use opt structure to set up parameters
data = daline.generate('case.name', 'case118', 'data.program', 'acpf', 'data.baseType', 'TimeSeriesRand');
opt  = daline.setopt('norm.switch', 1);
data = daline.normalize(data, opt);


%% Section 3.3

% Example 1: data generation and processing (see Table 3.1, 3.2, 3.3, 3.4, 3.5 and 3.6 for all the adjustable parameters for daline.data)
data = daline.data('case.name', 'case118', 'num.trainSample', 500, 'num.testSample', 300, 'data.program', 'acpf', 'data.baseType', 'TimeSeriesRand', 'noise.switchTrain', 1, 'outlier.switchTrain', 1, 'norm.switch', 1);

% Example 2: data generation and processing (see Table 3.1, 3.2, 3.3, 3.4, 3.5 and 3.6 for all the adjustable parameters for daline.data)
% Use opt structure to set up parameters 
% (See Section 3.3 for the details about X and Y)
opt  = daline.setopt('case.name', 'case118', 'num.trainSample', 500, 'num.testSample', 300, 'data.program', 'acpf', 'data.baseType', 'TimeSeriesRand', 'noise.switchTrain', 1, 'outlier.switchTrain', 1, 'norm.switch', 1);
[data, X, Y] = daline.data(opt);

%% all-zero column => normalize

% Example 1: if the dataset contains all-zero columns, after the unit
% energy normalization, the corresponding data points will become NaN
% case39 => Va_ref = 0 => normalize => all-zero => NaN
data = daline.data('case.name', 'case39', 'voltage.refAngle', 0, 'norm.switch', 1);


%% Section 4.1 daline.fit 

% (see Table 4.2 for the details of model)
% (see Table 4.3 for the parameters for daline.fit)
model = daline.fit(data);
model_A = daline.fit(data, 'method.name', 'RR', 'variable.predictor', {'P' , 'Vm2'}, 'RR.lambdaInterval', [0:1e-3:0.02]);
opt = daline.setopt('method.name', 'RR', 'variable.predictor', {'P', 'Vm2' }, 'RR.lambdaInterval', 0:1e-3:0.02);
model_B = daline.fit(data, opt);
model_A = func_algorithm_LS(data);
model_B = daline.fit(data, 'method.name', 'LS');

%% Section 4.2.1 Ordinary least squares --- abbreviation: LS
model = daline.fit(data, 'method.name', 'LS');
model = daline.fit(data, 'method.name', 'LS', 'variable.predictor', {'P'}, 'variable.response', {'PF', 'Vm'});
opt = daline.setopt('method.name', 'LS', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF'});
model = daline.fit(data, opt);
model = func_algorithm_LS(data, 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'QF'});
opt = daline.setopt('variable.predictor', {'P', 'Q'}, 'variable.response', {'PF'});
model = func_algorithm_LS(data, opt);

%% Section 4.2.2 Ordinary least squares with generalized inverse  --- abbreviation: LS_PIN
model = daline.fit(data, 'method.name', 'LS_PIN');
model = daline.fit(data, 'method.name', 'LS_PIN', 'variable.predictor', {'P'}, 'variable.response', {'PF', 'Vm'});
opt = daline.setopt('method.name', 'LS_PIN', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF'});
model = daline.fit(data, opt);
model = func_algorithm_LS_PIN(data, 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'QF'});
opt = daline.setopt('variable.predictor', {'P', 'Q'}, 'variable.response', {'PF'});
model = func_algorithm_LS_PIN(data, opt);

%% Section 4.2.3 Least squares with singular value decomposition --- abbreviation: LS_SVD
model = daline.fit(data, 'method.name', 'LS_SVD');
model = daline.fit(data, 'method.name', 'LS_SVD', 'variable.predictor', {'P'}, 'variable.response', {'PF', 'Vm'});
opt = daline.setopt('method.name', 'LS_SVD', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF'});
model = daline.fit(data, opt);
model = func_algorithm_LS_SVD(data, 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'QF'});
opt = daline.setopt('variable.predictor', {'P', 'Q'}, 'variable.response', {'PF'});
model = func_algorithm_LS_SVD(data, opt);

%% Section 4.2.4 Least squares with complete orthogonal decomposition --- abbreviation: LS_COD
model = daline.fit(data, 'method.name', 'LS_COD');
model = daline.fit(data, 'method.name', 'LS_COD', 'variable.predictor', {'P'}, 'variable.response', {'PF', 'Vm'});
opt = daline.setopt('method.name', 'LS_COD', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF'});
model = daline.fit(data, opt);
model = func_algorithm_LS_COD(data, 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'QF'});
opt = daline.setopt('variable.predictor', {'P', 'Q'}, 'variable.response', {'PF'});
model = func_algorithm_LS_COD(data, opt);

%% Section 4.2.5 Least squares with principal component analysis --- abbreviation: LS_PCA
% (see Table 4.4 for parameters of LS_PCA)
model = daline.fit(data, 'method.name', 'LS_PCA');
model = daline.fit(data, 'method.name', 'LS_PCA', 'variable.predictor', {'P'}, 'variable.response', {'PF', 'Vm'}, 'PCA.parallel', 0, 'PCA.PerComponent', [30:10:90], 'PCA.numFold', 5);
opt = daline.setopt('method.name', 'LS_PCA', 'variable.predictor', {'P'}, 'variable.response', {'PF', 'Vm'}, 'PCA.PerComponent', [30:10:90], 'PCA.numFold', 5);
model = daline.fit(data, opt);
model = func_algorithm_LS_PCA(data, 'variable.predictor', {'P'}, 'variable.response', {'PF', 'Vm'}, 'PCA.PerComponent', [30:10:90], 'PCA.numFold', 5);
opt = daline.setopt('variable.predictor', {'P'}, 'variable.response', {'PF', 'Vm'}, 'PCA.PerComponent', [30:10:90], 'PCA.numFold', 5);
model = func_algorithm_LS_PCA(data, opt);

%% Section 4.2.6 Least squares with Huber loss function: a direct solution --- abbreviation: LS_HBLD (solver: fminunc) 
% (see Table 4.5 for parameters of LS_HBLD)
model = daline.fit(data, 'method.name', 'LS_HBLD');
model = daline.fit(data, 'method.name', 'LS_HBLD', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'HBL.delta', [0.04:0.005:0.06]);
model = daline.fit(data, 'method.name', 'LS_HBLD', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'HBL.delta', 0.04);
model = daline.fit(data, 'method.name', 'LS_HBLD', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'HBL.parallel', 0, 'HBL.delta', 0.04);
model = daline.fit(data, 'method.name', 'LS_HBLD', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'HBL.parallel', 0, 'HBL.delta', 0.01);
model = daline.fit(data, 'method.name', 'LS_HBLD', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'HBL.parallel', 0, 'HBL.delta', [0.04:0.005:0.06]);
opt = daline.setopt('method.name', 'LS_HBLD', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'HBL.delta', [0.04:0.005:0.06]);
model = daline.fit(data, opt);
model = func_algorithm_LS_HBLD(data, 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'HBL.delta', [0.04:0.005:0.06]);
opt = daline.setopt('variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'HBL.delta', [0.04:0.005:0.06]);
model = func_algorithm_LS_HBLD(data, opt);

%% Section 4.2.7 Least squares with Huber loss function: an equivalent solution --- abbreviation: LS_HBLE (solvers: fmincon, Mosek, Gurobi, recommend: yalmip+fmincon+indivi)
% (see Table 4.6 for parameters of LS_HBLE)
model = daline.fit(data, 'method.name', 'LS_HBLE');
model = daline.fit(data, 'method.name', 'LS_HBLE', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'HBL.language', 'yalmip', 'HBL.solver', 'Mosek');
model = daline.fit(data, 'method.name', 'LS_HBLE', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'HBL.language', 'cvx', 'HBL.solver', 'quadprog');
model = daline.fit(data, 'method.name', 'LS_HBLE', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'HBL.language', 'yalmip', 'HBL.solver', 'quadprog', 'HBL.programType', 'whole');
model = daline.fit(data, 'method.name', 'LS_HBLE', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'HBL.language', 'yalmip', 'HBL.solver', 'fmincon', 'HBL.delta', 0.01);
model = daline.fit(data, 'method.name', 'LS_HBLE', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'HBL.language', 'cvx', 'HBL.solver', 'quadprog');
model = daline.fit(data, 'method.name', 'LS_HBLE', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'HBL.language', 'yalmip', 'HBL.solver', 'Gurobi');
model = daline.fit(data, 'method.name', 'LS_HBLE', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'HBL.language', 'cvx', 'HBL.solver', 'Gurobi');
opt = daline.setopt('method.name', 'LS_HBLE', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'HBL.parallel', 0, 'HBL.language', 'yalmip', 'HBL.solver', 'Mosek');
model = daline.fit(data, opt);
model = func_algorithm_LS_HBLE(data, 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'HBL.language', 'yalmip', 'HBL.solver', 'Mosek');
opt = daline.setopt('variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'HBL.language', 'yalmip', 'HBL.solver', 'Mosek');
model = func_algorithm_LS_HBLE(data, opt);

%% Section 4.2.8 Least squares with Huber weighting function --- abbreviation: LS_HBW
% (see Table 4.7 for parameters of LS_HBW)
model = daline.fit(data, 'method.name', 'LS_HBW');
model = daline.fit(data, 'method.name', 'LS_HBW', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'HBW.TuningConst', [0.8:0.1:1.5], 'HBW.PCA', 0);
model = daline.fit(data, 'method.name', 'LS_HBW', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'HBW.TuningConst', [0.8:0.1:1.5], 'HBW.PCA', 0);
model = daline.fit(data, 'method.name', 'LS_HBW', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'HBW.TuningConst', [0.8:0.1:1.5], 'HBW.PCA', 0);
model = daline.fit(data, 'method.name', 'LS_HBW', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'HBW.TuningConst', [0.8:0.1:1.5], 'HBW.PCA', 0);
model = daline.fit(data, 'method.name', 'LS_HBW', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'HBW.TuningConst', [0.8:0.1:1.5], 'HBW.PCA', 0);
model = daline.fit(data, 'method.name', 'LS_HBW', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'HBW.TuningConst', [0.8:0.1:1.5], 'HBW.PCA', 0);
opt = daline.setopt('method.name', 'LS_HBW', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'HBW.TuningConst', [0.8:0.1:1.5], 'HBW.PCA', 0);
model = daline.fit(data, opt);
model = func_algorithm_LS_HBW(data, 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'HBW.TuningConst', [0.8:0.1:1.5], 'HBW.PCA', 0);
opt = daline.setopt('variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'HBW.TuningConst', [0.8:0.1:1.5], 'HBW.PCA', 0);
model = func_algorithm_LS_HBW(data, opt);

%% Section 4.2.9 Generalized least squares --- abbreviation: LS_GEN
% (see Table 4.8 for parameters of LS_GEN)
model = daline.fit(data, 'method.name', 'LS_GEN');
model = daline.fit(data, 'method.name', 'LS_GEN', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'LSG.InnovMdl', 'AR');
opt = daline.setopt('method.name', 'LS_GEN', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'LSG.InnovMdl', 'AR');
model = daline.fit(data, opt);
model = func_algorithm_LS_GEN(data, 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'LSG.InnovMdl', 'AR');
opt = daline.setopt('variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'LSG.InnovMdl', 'AR');
model = func_algorithm_LS_GEN(data, opt);

%% Section 4.2.10 Total least squares --- abbreviation: LS_TOL
model = daline.fit(data, 'method.name', 'LS_TOL');
model = daline.fit(data, 'method.name', 'LS_TOL', 'variable.predictor', {'P'}, 'variable.response', {'PF', 'Vm'});
opt = daline.setopt('method.name', 'LS_TOL', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF'});
model = daline.fit(data, opt);
model = func_algorithm_LS_TOL(data, 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'QF'});
opt = daline.setopt('variable.predictor', {'P', 'Q'}, 'variable.response', {'PF'});
model = func_algorithm_LS_TOL(data, opt);

%% Section 4.2.11 Least squares with clustering --- abbreviation: LS_CLS
% (see Table 4.9 for parameters of LS_CLS)
model = daline.fit(data, 'method.name', 'LS_CLS');
model = daline.fit(data, 'method.name', 'LS_CLS', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'LSC.fixKmeans', 0, 'LSC.clusNumInterval', [6:2:12], 'LSC.cvNumFold', 5);
opt = daline.setopt('method.name', 'LS_CLS', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'LSC.fixKmeans', 0, 'LSC.clusNumInterval', [6:2:12], 'LSC.cvNumFold', 5);
model = daline.fit(data, opt);
model = func_algorithm_LS_CLS(data, 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'LSC.fixKmeans', 0, 'LSC.clusNumInterval', [6:2:12], 'LSC.cvNumFold', 5);
opt = daline.setopt('variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'LSC.fixKmeans', 0, 'LSC.clusNumInterval', [6:2:12], 'LSC.cvNumFold', 5);
model = func_algorithm_LS_CLS(data, opt);

%% Section 4.2.12 Least squares with lifting dimension: lifting the whole x jointly --- abbreviation: LS_LIFX
% (see Table 4.10 for parameters of LS_LIFX)
% (see Table 4.11 for the supported lifting functions)
model = daline.fit(data, 'method.name', 'LS_LIFX');
model = daline.fit(data, 'method.name', 'LS_LIFX', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'variable.liftType', 'polyharmonic', 'variable.liftK', 2);
opt = daline.setopt('method.name', 'LS_LIFX', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'variable.liftType', 'polyharmonic', 'variable.liftK', 2);
model = daline.fit(data, opt);
model = func_algorithm_LS_LIFX(data, 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'variable.liftType', 'polyharmonic', 'variable.liftK', 2);
opt = daline.setopt('variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'variable.liftType', 'polyharmonic', 'variable.liftK', 2);
model = func_algorithm_LS_LIFX(data, opt);

%% Section 4.2.13 Least squares with lifting dimension: lifting the elements of x individually --- abbreviation: LS_LIFXi
% (see Table 4.12 for parameters of LS_LIFXi)
% (see Table 4.11 for the supported lifting functions)
model = daline.fit(data, 'method.name', 'LS_LIFXi');
model = daline.fit(data, 'method.name', 'LS_LIFXi', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'variable.liftType', 'polyharmonic', 'variable.liftK', 2);
opt = daline.setopt('method.name', 'LS_LIFXi', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'variable.liftType', 'polyharmonic', 'variable.liftK', 2); 
model = daline.fit(data, opt);
model = func_algorithm_LS_LIFXi(data, 'variable.predictor', {'P', 'Q' }, 'variable.response', {'PF', 'Vm'}, 'variable.liftType', 'polyharmonic', 'variable.liftK', 2);
opt = daline.setopt('variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'variable.liftType', 'polyharmonic', 'variable.liftK', 2);
model = func_algorithm_LS_LIFXi(data, opt);

%% Section 4.2.14 Weighed least squares --- abbreviation: LS_WEI (solvers: quadprog, Mosek, Gurobi, SDPT3, SeDuMi, recommend: cvx+SeDuMi+whole)
% (see Table 4.13 for parameters of LS_WEI)
model = daline.fit(data, 'method.name', 'LS_WEI');
model = daline.fit(data, 'method.name', 'LS_WEI', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'LSW.omega', 0.95, 'LSW.programType', 'whole', 'LSW.solver', 'Mosek', 'LSW.language', 'cvx');
model = daline.fit(data, 'method.name', 'LS_WEI', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'LSW.omega', 0.95, 'LSW.programType', 'whole', 'LSW.solver', 'Mosek', 'LSW.language', 'yalmip');
model = daline.fit(data, 'method.name', 'LS_WEI', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'LSW.omega', 0.95, 'LSW.programType', 'whole', 'LSW.solver', 'Mosek', 'LSW.language', 'yalmip', 'LSW.programType', 'indivi');
model = daline.fit(data, 'method.name', 'LS_WEI', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'LSW.omega', 0.95, 'LSW.programType', 'whole', 'LSW.solver', 'SDPT3', 'LSW.language', 'cvx', 'LSW.programType', 'whole');
model = daline.fit(data, 'method.name', 'LS_WEI', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'LSW.omega', 0.95, 'LSW.programType', 'whole', 'LSW.solver', 'Gurobi', 'LSW.language', 'cvx', 'LSW.programType', 'whole');
model = daline.fit(data, 'method.name', 'LS_WEI', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'LSW.omega', 0.95, 'LSW.programType', 'whole', 'LSW.solver', 'quadprog', 'LSW.language', 'cvx', 'LSW.programType', 'whole');
model = daline.fit(data, 'method.name', 'LS_WEI', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'LSW.omega', 0.95, 'LSW.programType', 'whole', 'LSW.solver', 'SeDuMi', 'LSW.language', 'cvx', 'LSW.programType', 'whole');
opt = daline.setopt('method.name', 'LS_WEI', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'LSW.omega', 0.95, 'LSW.programType', 'whole', 'LSW.solver', 'Mosek');
model = daline.fit(data, opt);
model = func_algorithm_LS_WEI(data, 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'LSW.omega', 0.95, 'LSW.programType', 'whole', 'LSW.solver', 'Mosek');
opt = daline.setopt('variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'LSW.omega', 0.95, 'LSW.programType', 'whole', 'LSW.solver', 'Mosek');
model = func_algorithm_LS_WEI(data, opt);

%% Section 4.2.15 Recursive least squares  --- abbreviation: LS_REC
% (see Table 4.14 for parameters of LS_REC)
model = daline.fit(data, 'method.name', 'LS_REC');
model = daline.fit(data, 'method.name', 'LS_REC', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'LSR.recursivePercentage', 30, 'LSR.initializeP', 0);
opt = daline.setopt('method.name', 'LS_REC', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'LSR.recursivePercentage', 30, 'LSR.initializeP', 0);
model = daline.fit(data, opt);
model = func_algorithm_LS_REC(data, 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'LSR.recursivePercentage', 30, 'LSR.initializeP', 0);
opt = daline.setopt('variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'LSR.recursivePercentage', 30, 'LSR.initializeP', 0);
model = func_algorithm_LS_REC(data, opt);

%% Section 4.2.16 Repeated least squares --- abbreviation: LS_REP
% (see Table 4.15 for parameters of LS_REP)
model = daline.fit(data, 'method.name', 'LS_REP');
model = daline.fit(data, 'method.name', 'LS_REP', 'variable.predictor', { 'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'LSR.recursivePercentage', 75);
opt = daline.setopt('method.name', 'LS_REP', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'LSR.recursivePercentage', 75);
model = daline.fit(data, opt);
model = func_algorithm_LS_REP(data, 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'LSR.recursivePercentage', 75);
opt = daline.setopt('variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'LSR.recursivePercentage', 75);
model = func_algorithm_LS_REP(data, opt);

%% Section 4.3.1 Ordinary partial least squares with SIMPLS --- abbreviation: PLS_SIM
model = daline.fit(data, 'method.name', 'PLS_SIM');
model = daline.fit(data, 'method.name', 'PLS_SIM', 'variable.predictor', {'P'}, 'variable.response', {'PF', 'Vm'});
opt = daline.setopt('method.name', 'PLS_SIM', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF'});
model = daline.fit(data, opt);
model = func_algorithm_PLS_SIM(data, 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'QF'});
opt = daline.setopt('variable.predictor', {'P', 'Q'}, 'variable.response', {'PF'});
model = func_algorithm_PLS_SIM(data, opt);

%% Section 4.3.2 Ordinary partial least squares with SIMPLS using rank of X --- abbreviation: PLS_SIMRX
model = daline.fit(data, 'method.name', 'PLS_SIMRX');
model = daline.fit(data, 'method.name', 'PLS_SIMRX', 'variable.predictor' , {'P'}, 'variable.response', {'PF', 'Vm'});
opt = daline.setopt('method.name', 'PLS_SIMRX', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF'});
model = daline.fit(data, opt);
model = func_algorithm_PLS_SIMRX(data, 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'QF'});
opt = daline.setopt('variable.predictor', {'P', 'Q'}, 'variable.response', {'PF'});
model = func_algorithm_PLS_SIMRX(data, opt);

%% Section 4.3.3 Ordinary partial least squares with NIPALS --- abbreviation: PLS_NIP
% (see Table 4.16 for parameters of PLS_NIP)
model = daline.fit(data, 'method.name', 'PLS_NIP');
model = daline.fit(data, 'method.name', 'PLS_NIP', 'variable.predictor', {'P'}, 'variable.response', {'PF', 'Vm'}, 'PLS.innerTol', 1e-10);
opt = daline.setopt('method.name', 'PLS_NIP', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF'}, 'PLS.innerTol', 1e-10);
model = daline.fit(data, opt);
model = func_algorithm_PLS_NIP(data, 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'QF'}, 'PLS.innerTol', 1e-10);
opt = daline.setopt('variable.predictor', {'P', 'Q'}, 'variable.response', {'PF'}, 'PLS.innerTol', 1e-10);
model = func_algorithm_PLS_NIP(data, opt);

%% Section 4.3.4 Partial least squares bundling known/unknown variables and replacing slack bus’s power injection --- abbreviation: PLS_BDL
model = daline.fit(data, 'method.name', 'PLS_BDL');
opt = daline.setopt('method.name', 'PLS_BDL'); 
model = daline.fit(data, opt);
model = func_algorithm_PLS_BDL(data);

%% Section 4.3.5 Partial least squares bundling known/unknown variables --- abbreviation: PLS_BDLY2
model = daline.fit(data, 'method.name', 'PLS_BDLY2');
opt = daline.setopt('method.name', 'PLS_BDLY2'); 
model = daline.fit(data, opt);
model = func_algorithm_PLS_BDLY2(data);

%% Section 4.3.6 Partial least squares bundling known/unknown variables: the open-source version --- abbreviation: PLS_BDLopen
model = daline.fit(data, 'method.name', 'PLS_BDLopen');
model = func_algorithm_PLS_BDLopen(data);
opt = daline.setopt('method.name', 'PLS_BDLopen'); 
model = daline.fit(data, opt);

%% Section 4.3.7 Recursive partial least squares with NIPALS --- abbreviation: PLS_REC
% (see Table 4.17 for parameters of PLS_REC)
model = daline.fit(data, 'method.name', 'PLS_REC');
model = daline.fit(data, 'method.name', 'PLS_REC', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'PLS.recursivePercentage', 50, 'PLS.innerTol', 1e-10);
opt = daline.setopt('method.name', 'PLS_REC', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'PLS.recursivePercentage', 50, 'PLS.innerTol', 1e-10);
model = daline.fit(data, opt);
model = func_algorithm_PLS_REC(data, 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'PLS.recursivePercentage', 50, 'PLS.innerTol', 1e-10);
opt = daline.setopt('variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'PLS.recursivePercentage', 50, 'PLS.innerTol', 1e-10);
model = func_algorithm_PLS_REC(data, opt);

%% Section 4.3.8 Recursive partial least squares with NIPALS, using forgetting factors for observations --- abbreviation: PLS_RECW
% (see Table 4.18 for parameters of PLS_RECW)
model = daline.fit(data, 'method.name', 'PLS_RECW');
model = daline.fit(data, 'method.name', 'PLS_RECW', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'PLS.omega', 0.95, 'PLS.recursivePercentage', 30);
opt = daline.setopt('method.name', 'PLS_RECW', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'PLS.omega', 0.95, 'PLS.recursivePercentage', 30);
model = daline.fit(data, opt);
model = func_algorithm_PLS_RECW(data, 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'PLS.omega', 0.95, 'PLS.recursivePercentage', 30);
opt = daline.setopt('variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'PLS.omega', 0.95, 'PLS.recursivePercentage', 30);
model = func_algorithm_PLS_RECW(data, opt);

%% Section 4.3.9 Repeated partial least squares with NIPALS --- abbreviation: PLS_REP
% (see Table 4.19 for parameters of PLS_REP)
model = daline.fit(data, 'method.name', 'PLS_REP');
model = daline.fit(data, 'method.name', 'PLS_REP', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'PLS.recursivePercentage', 50, 'PLS.innerTol', 1e-10);
opt = daline.setopt('method.name', 'PLS_REP', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'PLS.recursivePercentage', 50, 'PLS.innerTol', 1e-10);
model = daline.fit(data, opt);
model = func_algorithm_PLS_REP(data, 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'PLS.recursivePercentage', 50, 'PLS.innerTol', 1e-10);
opt = daline.setopt('variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'PLS.recursivePercentage', 50, 'PLS.innerTol', 1e-10);
model = func_algorithm_PLS_REP(data, opt);

%% Section 4.3.10 Partial least squares with clustering --- abbreviation: PLS_CLS
% (see Table 4.20 for parameters of PLS_CLS)
model = daline.fit(data, 'method.name', 'PLS_CLS');
model = daline.fit(data, 'method.name', 'PLS_CLS', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'PLS.fixKmeans', 0, 'PLS.clusNumInterval', [6:2:12], 'PLS.cvNumFold', 5);
opt = daline.setopt('method.name', 'PLS_CLS', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'PLS.fixKmeans', 0, 'PLS.clusNumInterval', [6:2:12], 'PLS.cvNumFold', 5);
model = daline.fit(data, opt);
model = func_algorithm_PLS_CLS(data, 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'PLS.fixKmeans', 0, 'PLS.clusNumInterval', [6:2:12], 'PLS.cvNumFold', 5);
opt = daline.setopt('variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'PLS.fixKmeans', 0, 'PLS.clusNumInterval', [6:2:12], 'PLS.cvNumFold', 5);
model = func_algorithm_PLS_CLS(data, opt);

%% Section 4.4.1 Ordinary ridge regression --- abbreviation: RR
% (see Table 4.21 for parameters of RR)
model = daline.fit(data, 'method.name', 'RR');
model = daline.fit(data, 'method.name', 'RR', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'RR.lambdaInterval', [0:5e-3:0.1]);
opt = daline.setopt('method.name', 'RR', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'RR.lambdaInterval', [0:5e-3:0.1]);
model = daline.fit(data, opt);
model = func_algorithm_RR(data, 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'RR.lambdaInterval', [0:5e-3:0.1]);
opt = daline.setopt('variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'RR.lambdaInterval', [0:5e-3:0.1]);
model = func_algorithm_RR(data, opt);

%% Section 4.4.2 Ordinary ridge regression with the voltage-angle coupling --- abbreviation: RR_VCS
% (see Table 4.21 for parameters of RR_VCS)
model = daline.fit(data, 'method.name', 'RR_VCS');
model = daline.fit(data, 'method.name', 'RR_VCS', 'RR.lambdaInterval', [0:5e-3:0.1]);
opt = daline.setopt('method.name', 'RR_VCS', 'RR.lambdaInterval', [0:5e-3:0.1]);
model = daline.fit(data, opt);
model = func_algorithm_RR_VCS(data, 'RR.lambdaInterval', [0:5e-3:0.1]);
opt = daline.setopt('RR.lambdaInterval', [0:5e-3:0.1]); 
model = func_algorithm_RR_VCS(data, opt);

%% Section 4.4.3 Ordinary ridge regression with K-plane clustering --- abbreviation: RR_KPC
% (see Table 4.21 for parameters of RR_KPC)
model = daline.fit(data, 'method.name', 'RR_KPC');
model = daline.fit(data, 'method.name', 'RR_KPC', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'RR.lambdaInterval', [0:5e-2:0.1], 'RR.etaInterval', logspace(-3, 3, 7), 'RR.clusNumInterval', [2:2:10]);
opt = daline.setopt('method.name', 'RR_KPC', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'RR.lambdaInterval', [0:5e-2:0.1],'RR.etaInterval', logspace(-3, 3, 7), 'RR.clusNumInterval', [2:2:10]); 
model = daline.fit(data, opt);
model = func_algorithm_RR_KPC(data, 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'RR.lambdaInterval', [0:5e-2:0.1], 'RR.etaInterval', logspace(-3, 3, 7), 'RR.clusNumInterval', [2:2:10]);
opt = daline.setopt('variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'RR.lambdaInterval', [0:5e-2:0.1], 'RR.etaInterval', logspace(-3, 3, 7), 'RR.clusNumInterval', [2:2:10]); 
model = func_algorithm_RR_KPC(data, opt);

%% Section 4.4.4 Locally weighted ridge regression --- abbreviation: RR_WEI
% (see Table 4.21 for parameters of RR_WEI)
model = daline.fit(data, 'method.name', 'RR_WEI');
model = daline.fit(data, 'method.name', 'RR_WEI', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'RR.lambdaInterval', [0:5e-3:0.1], 'RR.tauInterval', [0.1:1e-2:0.3]);
opt = daline.setopt('method.name', 'RR_WEI', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'RR.lambdaInterval', [0:5e-3:0.1], 'RR.tauInterval', [0.1:1e-2:0.3]); 
model = daline.fit(data, opt);
model = func_algorithm_RR_WEI(data, 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'RR.lambdaInterval', [0:5e-3:0.1], 'RR.tauInterval', [0.1:1e-2:0.3]);
opt = daline.setopt('variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'RR.lambdaInterval', [0:5e-3:0.1], 'RR.tauInterval', [0.1:1e-2:0.3]);
model = func_algorithm_RR_WEI(data, opt);

%% Section 4.5.1 Ordinary support vector regression: a direct solution --- abbreviation: SVR (solvers: quadprog, Mosek, Gurobi, recommend: yalmip+quadprog+indivi)
% (see Table 4.25 for parameters of SVR)
model = daline.fit(data, 'method.name', 'SVR');
model = daline.fit(data, 'method.name', 'SVR', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'SVR.omega', 25, 'SVR.yalDisplay', 1);
model = daline.fit(data, 'method.name', 'SVR', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'SVR.omega', 25, 'SVR.language', 'cvx', 'SVR.programType', 'indivi', 'SVR.solver', 'Gurobi');
model = daline.fit(data, 'method.name', 'SVR', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'SVR.omega', 25, 'SVR.language', 'yalmip', 'SVR.programType', 'indivi', 'SVR.solver', 'Gurobi');
model = daline.fit(data, 'method.name', 'SVR', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'SVR.omega', 25, 'SVR.language', 'yalmip', 'SVR.programType', 'indivi', 'SVR.solver', 'quadprog');
model = daline.fit(data, 'method.name', 'SVR', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'SVR.omega', 25, 'SVR.language', 'yalmip', 'SVR.programType', 'indivi', 'SVR.solver', 'Mosek');
opt = daline.setopt('method.name', 'SVR', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'SVR.omega', 25, 'SVR.yalDisplay', 1);
model = daline.fit(data, opt);
model = func_algorithm_SVR(data, 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'SVR.omega', 25, 'SVR.yalDisplay', 1);
opt = daline.setopt('variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'SVR.omega', 25, 'SVR.yalDisplay', 1);
model = func_algorithm_SVR(data, opt);

%% Section 4.5.2 Support vector regression with polynomial kernel --- abbreviation: SVR_POL
% (see Table 4.26 for parameters of SVR_POL)
model = daline.fit(data, 'method.name', 'SVR_POL');
model = daline.fit(data, 'method.name', 'SVR_POL', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'SVR.default', 0, 'SVR.epsilon', 0.05);
opt = daline.setopt('method.name', 'SVR_POL', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'SVR.default', 0, 'SVR.epsilon', 0.05);
model = daline.fit(data, opt);
model = func_algorithm_SVR_POL(data, 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'SVR.default', 0, 'SVR.epsilon', 0.05);
opt = daline.setopt('variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'SVR.default', 0, 'SVR.epsilon', 0.05);
model = func_algorithm_SVR_POL(data, opt);

%% Section 4.5.3 Support vector regression with ridge regression --- abbreviation: SVR_RR (solvers: quadprog, Mosek, Gurobi, recommend: yalmip+quadprog+indivi)
% (see Table 4.25 for parameters of SVR_RR)
model = daline.fit(data, 'method.name', 'SVR_RR');
model = daline.fit(data, 'method.name', 'SVR_RR', 'SVR.parallel', 0);
model = daline.fit(data, 'method.name', 'SVR_RR', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'SVR.lambda', -0.4999, 'SVR.PCA', 0);
model = daline.fit(data, 'method.name', 'SVR_RR', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'SVR.lambda', -0.4999, 'SVR.PCA', 0, 'SVR.language', 'yalmip', 'SVR.programType', 'indivi', 'SVR.solver', 'Gurobi');
model = daline.fit(data, 'method.name', 'SVR_RR', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'SVR.lambda', -0.4999, 'SVR.PCA', 0, 'SVR.language', 'cvx', 'SVR.programType', 'indivi', 'SVR.solver', 'Gurobi');
model = daline.fit(data, 'method.name', 'SVR_RR', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'SVR.lambda', -0.4999, 'SVR.PCA', 0, 'SVR.language', 'yalmip', 'SVR.programType', 'indivi', 'SVR.solver', 'quadprog');
model = daline.fit(data, 'method.name', 'SVR_RR', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'SVR.lambda', -0.4999, 'SVR.PCA', 0, 'SVR.language', 'yalmip', 'SVR.programType', 'indivi', 'SVR.solver', 'Mosek');
opt = daline.setopt('method.name', 'SVR_RR', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'SVR.lambda', -0.4999, 'SVR.PCA', 0);
model = daline.fit(data, opt);
model = func_algorithm_SVR_RR(data, 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'SVR.lambda', -0.4999, 'SVR.PCA', 0);
opt = daline.setopt('variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'SVR.lambda', -0.4999, 'SVR.PCA', 0);
model = func_algorithm_SVR_RR(data, opt);

%% Section 4.5.4 Support vector regression with chance-constrained programming --- abbreviation: SVR_CCP (solver: Gurobi, recommend: yalmip+Gurobi+indivi)
% (see Table 4.25 for parameters of SVR_CCP)
model = daline.fit(data, 'method.name', 'SVR_CCP');
model = daline.fit(data, 'method.name', 'SVR_CCP', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'SVRCC.epsilon', 1e-3, 'SVRCC.probThreshold', 0.95);
model = daline.fit(data, 'method.name', 'SVR_CCP', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'SVRCC.epsilon', 1e-3, 'SVRCC.probThreshold', 0.95, 'SVRCC.language', 'yalmip', 'SVRCC.programType', 'indivi', 'SVRCC.solver', 'Gurobi');
opt = daline.setopt('method.name', 'SVR_CCP', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'SVRCC.epsilon', 1e-3, 'SVRCC.probThreshold', 0.95);
model = daline.fit(data, opt);
model = func_algorithm_SVR_CCP(data, 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'SVRCC.epsilon', 1e-3, 'SVRCC.probThreshold', 0.95);
opt = daline.setopt('variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'SVRCC.epsilon', 1e-3, 'SVRCC.probThreshold', 0.95);
model = func_algorithm_SVR_CCP(data, opt);

%% Section 4.6.1 Linearly constrained programming with box constraints --- abbreviation: LCP_BOX (solvers: quadprog, Mosek, Gurobi, SDPT3, SeDuMi, recommend: SeDuMi)
% (see Table 4.29 for parameters of LCP_BOX)
model = daline.fit(data, 'method.name', 'LCP_BOX');
model = daline.fit(data, 'method.name', 'LCP_BOX', 'LCP.solver', 'Gurobi', 'LCP.cvxQuiet', 0);
model = daline.fit(data, 'method.name', 'LCP_BOX', 'LCP.solver', 'Gurobi', 'LCP.cvxQuiet', 1);
model = daline.fit(data, 'method.name', 'LCP_BOX', 'LCP.solver', 'Mosek', 'LCP.cvxQuiet', 1);
model = daline.fit(data, 'method.name', 'LCP_BOX', 'LCP.solver', 'quadprog', 'LCP.cvxQuiet', 1);
model = daline.fit(data, 'method.name', 'LCP_BOX', 'LCP.solver', 'SDPT3', 'LCP.cvxQuiet', 1);
model = daline.fit(data, 'method.name', 'LCP_BOX', 'LCP.solver', 'SeDuMi', 'LCP.cvxQuiet', 1);
opt = daline.setopt('method.name', 'LCP_BOX', 'LCP.solver', 'Gurobi', 'LCP.cvxQuiet', 0);
model = daline.fit(data, opt);
model = func_algorithm_LCP_BOX(data, 'LCP.solver', 'Gurobi', 'LCP.cvxQuiet', 0);
opt = daline.setopt('LCP.solver', 'Gurobi', 'LCP.cvxQuiet', 0); 
model = func_algorithm_LCP_BOX(data, opt);


%% Section 4.6.2 Linearly constrained programming without box constraints --- abbreviation: LCP_BOX (solvers: quadprog, Mosek, Gurobi, SDPT3, SeDuMi, recommend: SeDuMi)
% (see Table 4.29 for parameters of LCP_BOXN)
model = daline.fit(data, 'method.name', 'LCP_BOXN');
model = daline.fit(data, 'method.name', 'LCP_BOXN', 'LCP.solver', 'Gurobi' , 'LCP.cvxQuiet', 0);
model = daline.fit(data, 'method.name', 'LCP_BOXN', 'LCP.solver', 'Gurobi' , 'LCP.cvxQuiet', 1);
model = daline.fit(data, 'method.name', 'LCP_BOXN', 'LCP.solver', 'Mosek' , 'LCP.cvxQuiet', 1);
model = daline.fit(data, 'method.name', 'LCP_BOXN', 'LCP.solver', 'quadprog' , 'LCP.cvxQuiet', 1);
model = daline.fit(data, 'method.name', 'LCP_BOXN', 'LCP.solver', 'SDPT3' , 'LCP.cvxQuiet', 1);
model = daline.fit(data, 'method.name', 'LCP_BOXN', 'LCP.solver', 'SeDuMi' , 'LCP.cvxQuiet', 1);
opt = daline.setopt('method.name', 'LCP_BOXN', 'LCP.solver', 'Gurobi', 'LCP.cvxQuiet', 0);
model = daline.fit(data, opt);
model = func_algorithm_LCP_BOXN(data, 'LCP.solver', 'Gurobi', 'LCP.cvxQuiet', 0);
opt = daline.setopt('LCP.solver', 'Gurobi', 'LCP.cvxQuiet', 0); 
model = func_algorithm_LCP_BOXN(data, opt);

%% Section 4.6.3 Linearly constrained programming with Jacobian guidance constraints --- abbreviation: LCP_JGD
% (see Table 4.29 for parameters of LCP_JGD)
model = daline.fit(data, 'method.name', 'LCP_JGD');
model = daline.fit(data, 'method.name', 'LCP_JGD', 'LCP.cvxQuiet', 0);
opt = daline.setopt('method.name', 'LCP_JGD', 'LCP.cvxQuiet', 0);
model = daline.fit(data, opt);
model = func_algorithm_LCP_JGD(data, 'LCP.cvxQuiet', 0);
opt = daline.setopt('LCP.cvxQuiet', 0);
model = func_algorithm_LCP_JGD(data, opt);

%% Section 4.6.4 Linearly constrained programming without Jacobian guidance constraints --- abbreviation: LCP_JGDN
% (see Table 4.29 for parameters of LCP_JGDN)
model = daline.fit(data, 'method.name', 'LCP_JGDN');
model = daline.fit(data, 'method.name', 'LCP_JGDN', 'LCP.cvxQuiet', 0);
model = func_algorithm_LCP_JGDN(data, 'LCP.cvxQuiet', 0);
opt = daline.setopt('method.name', 'LCP_JGDN', 'LCP.cvxQuiet', 0); 
model = daline.fit(data, opt);
opt = daline.setopt('LCP.cvxQuiet', 0);
model = func_algorithm_LCP_JGDN(data, opt);

%% Section 4.6.5 Linearly constrained programming with coupling constraints --- abbreviation: LCP_COU (solvers: quadprog, Mosek, Gurobi, SDPT3, SeDuMi, recommend: quadprog)
% (see Table 4.29 and Table 4.30 for parameters of LCP_COU)
model = daline.fit(data, 'method.name', 'LCP_COU');
model = daline.fit(data, 'method.name', 'LCP_COU', 'LCP.coupleDelta', 1e-3, 'LCP.solver', 'Mosek');
model = daline.fit(data, 'method.name', 'LCP_COU', 'LCP.coupleDelta', 1e-3, 'LCP.solver', 'Gurobi');
model = daline.fit(data, 'method.name', 'LCP_COU', 'LCP.coupleDelta', 1e-3, 'LCP.solver', 'quadprog');
model = daline.fit(data, 'method.name', 'LCP_COU', 'LCP.coupleDelta', 1e-3, 'LCP.solver', 'SDPT3');
model = daline.fit(data, 'method.name', 'LCP_COU', 'LCP.coupleDelta', 1e-3, 'LCP.solver', 'SeDuMi');
opt = daline.setopt('method.name', 'LCP_COU', 'LCP.coupleDelta', 1e-3, 'LCP.solver', 'Mosek');
model = daline.fit(data, opt);
model = func_algorithm_LCP_COU(data, 'LCP.coupleDelta', 1e-3, 'LCP.solver', 'Mosek');
opt = daline.setopt('LCP.coupleDelta', 1e-3, 'LCP.solver', 'Mosek'); 
model = func_algorithm_LCP_COU(data, opt);

%% Section 4.6.6 Linearly constrained programming without coupling constraints --- abbreviation: LCP_COUN (solvers: quadprog, Mosek, Gurobi, SDPT3, SeDuMi, recommend: quadprog)
% (see Table 4.29 and Table 4.31 for parameters of LCP_COUN)
model = daline.fit(data, 'method.name', 'LCP_COUN');
model = daline.fit(data, 'method.name', 'LCP_COUN', 'LCP.solver', 'Mosek');
model = daline.fit(data, 'method.name', 'LCP_COUN', 'LCP.solver', 'Gurobi');
model = daline.fit(data, 'method.name', 'LCP_COUN', 'LCP.solver', 'quadprog');
model = daline.fit(data, 'method.name', 'LCP_COUN', 'LCP.solver', 'SDPT3');
model = daline.fit(data, 'method.name', 'LCP_COUN', 'LCP.solver', 'SeDuMi');
opt = daline.setopt('method.name', 'LCP_COUN', 'LCP.solver', 'Mosek'); 
model = daline.fit(data, opt);
model = func_algorithm_LCP_COUN(data, 'LCP.solver', 'Mosek');
opt = daline.setopt('LCP.solver', 'Mosek'); 
model = func_algorithm_LCP_COUN(data, opt);

%% Section 4.7.1 Moment-based distributionally robust chance-constrained programming with X as random variable --- abbreviation: DRC_XM (solvers: Mosek, SDPT3, SeDuMi, recommend: cvx+SeDuMi+whole for small cases, cvx+SeDuMi+indivi for large cases)
% (see Table 4.32 and Table 4.33 for parameters of DRC_XM)
dataN = daline.normalize(data);
model = daline.fit(dataN, 'method.name', 'DRC_XM');
model = daline.fit(dataN, 'method.name', 'DRC_XM', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF'}, 'DRC.epsilon', 1e-3, 'DRC.language' , 'cvx', 'DRC.solverM', 'SeDuMi');
model = daline.fit(dataN, 'method.name', 'DRC_XM', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF'}, 'DRC.epsilon', 1e-3, 'DRC.language' , 'cvx', 'DRC.solverM', 'SeDuMi', 'DRC.programType', 'indivi');
model = daline.fit(dataN, 'method.name', 'DRC_XM', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF'}, 'DRC.epsilon', 1e-3, 'DRC.language' , 'cvx', 'DRC.solverM', 'SeDuMi', 'DRC.programType', 'whole');
model = daline.fit(dataN, 'method.name', 'DRC_XM', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF'}, 'DRC.epsilon', 1e-3, 'DRC.language' , 'yalmip', 'DRC.solverM', 'SeDuMi', 'DRC.programType', 'whole');
model = daline.fit(dataN, 'method.name', 'DRC_XM', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF'}, 'DRC.epsilon', 1e-3, 'DRC.language' , 'yalmip', 'DRC.solverM', 'SeDuMi', 'DRC.programType', 'indivi');
model = daline.fit(dataN, 'method.name', 'DRC_XM', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF'}, 'DRC.epsilon', 1e-3, 'DRC.language' , 'cvx', 'DRC.solverM', 'SeDuMi', 'DRC.programType', 'whole');
model = daline.fit(dataN, 'method.name', 'DRC_XM', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF'}, 'DRC.epsilon', 1e-3, 'DRC.language' , 'cvx', 'DRC.solverM', 'Mosek', 'DRC.programType', 'whole');
model = daline.fit(dataN, 'method.name', 'DRC_XM', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF'}, 'DRC.epsilon', 1e-3, 'DRC.language' , 'cvx', 'DRC.solverM', 'SDPT3', 'DRC.programType', 'whole');
model = daline.fit(dataN, 'method.name', 'DRC_XM', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF'}, 'DRC.epsilon', 1e-3, 'DRC.language' , 'cvx', 'DRC.solverM', 'SeDuMi', 'DRC.programType', 'whole');
model = daline.fit(dataN, 'method.name', 'DRC_XM', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF'}, 'DRC.epsilon', 1e-3, 'DRC.language' , 'cvx', 'DRC.solverM', 'SeDuMi', 'DRC.programType', 'indivi');
opt = daline.setopt('method.name', 'DRC_XM', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF'}, 'DRC.epsilon', 1e-3, 'DRC.language', 'cvx', 'DRC.solverM', 'SeDuMi');
model = daline.fit(dataN, opt);
model = func_algorithm_DRC_XM(dataN, 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF'}, 'DRC.epsilon', 1e-3, 'DRC.language', 'cvx', 'DRC.solverM', 'SeDuMi');
opt = daline.setopt('variable.predictor', {'P', 'Q'}, 'variable.response', {'PF'}, 'DRC.epsilon', 1e-3, 'DRC.language', 'cvx', 'DRC.solverM', 'SeDuMi');
model = func_algorithm_DRC_XM(dataN, opt);

%% Section 4.7.2 Moment-based distributionally robust chance-constrained programming with X and Y as random variables --- abbreviation: DRC_XM (solvers: Mosek, SDPT3, SeDuMi, recommend: cvx+SeDuMi+whole for small cases, cvx+SeDuMi+indivi for large cases)
% (see Table 4.32 and Table 4.33 for parameters of DRC_XYM)
dataN = daline.normalize(data);
model = daline.fit(dataN, 'method.name', 'DRC_XYM');
model = daline.fit(dataN, 'method.name', 'DRC_XYM', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF'}, 'DRC.language' , 'cvx', 'DRC.probThreshold', 90, 'DRC.gamma2', 0.5);
model = daline.fit(dataN, 'method.name', 'DRC_XYM', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF'}, 'DRC.language' , 'cvx', 'DRC.probThreshold', 90, 'DRC.gamma2', 0.5, 'DRC.solverM', 'quadprog', 'DRC.programType', 'whole');
model = daline.fit(dataN, 'method.name', 'DRC_XYM', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF'}, 'DRC.probThreshold', 90, 'DRC.gamma2', 0.5, 'DRC.language', 'cvx', 'DRC.solverM', 'quadprog', 'DRC.programType', 'indivi');
model = daline.fit(dataN, 'method.name', 'DRC_XYM', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF'}, 'DRC.probThreshold', 90, 'DRC.gamma2', 0.5, 'DRC.language', 'yalmip', 'DRC.solverM', 'quadprog', 'DRC.programType', 'indivi');
model = daline.fit(dataN, 'method.name', 'DRC_XYM', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF'}, 'DRC.probThreshold', 90, 'DRC.gamma2', 0.5, 'DRC.language', 'yalmip', 'DRC.solverM', 'quadprog', 'DRC.programType', 'whole');
model = daline.fit(dataN, 'method.name', 'DRC_XYM', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF'}, 'DRC.probThreshold', 90, 'DRC.gamma2', 0.5, 'DRC.language', 'cvx', 'DRC.solverM', 'Mosek', 'DRC.programType', 'whole');
model = daline.fit(dataN, 'method.name', 'DRC_XYM', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF'}, 'DRC.probThreshold', 90, 'DRC.gamma2', 0.5, 'DRC.language', 'cvx', 'DRC.solverM', 'SDPT3', 'DRC.programType', 'whole');
model = daline.fit(dataN, 'method.name', 'DRC_XYM', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF'}, 'DRC.probThreshold', 90, 'DRC.gamma2', 0.5, 'DRC.language', 'cvx', 'DRC.solverM', 'SeDuMi', 'DRC.programType', 'whole');
opt = daline.setopt('method.name', 'DRC_XYM', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF'}, 'DRC.probThreshold', 90, 'DRC.gamma2', 0.5);
model = daline.fit(dataN, opt);
model = func_algorithm_DRC_XYM(dataN, 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF'}, 'DRC.probThreshold', 90, 'DRC.gamma2', 0.5);
opt = daline.setopt('variable.predictor', {'P', 'Q'}, 'variable.response', {'PF'}, 'DRC.probThreshold', 90, 'DRC.gamma2', 0.5);
model = func_algorithm_DRC_XYM(dataN, opt);

%% Section 4.7.3 Divergence-based distributionally robust chance-constrained programming with X and Y as random variables --- abbreviation: DRC_XYD (solvers: Mosek, Gurobi, recommend: yalmip+Gurobi)
% (see Table 4.32 and Table 4.34 for parameters of DRC_XYD)
dataN = daline.normalize(data);
model = daline.fit(dataN, 'method.name', 'DRC_XYD');
model = daline.fit(dataN, 'method.name', 'DRC_XYD', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF'}, 'DRC.infMethod', 'bisec', 'DRC.bisecTol', 1e-8);
model = daline.fit(dataN, 'method.name', 'DRC_XYD', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF'}, 'DRC.infMethod', 'bisec', 'DRC.bisecTol', 1e-8, 'DRC.language', 'cvx', 'DRC.solverD', 'Mosek', 'DRC.programType', 'indivi');
model = daline.fit(dataN, 'method.name', 'DRC_XYD', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF'}, 'DRC.infMethod', 'bisec', 'DRC.bisecTol', 1e-8, 'DRC.language', 'yalmip', 'DRC.solverD', 'Mosek', 'DRC.programType', 'indivi');
model = daline.fit(dataN, 'method.name', 'DRC_XYD', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF'}, 'DRC.infMethod', 'bisec', 'DRC.bisecTol', 1e-8, 'DRC.language', 'yalmip', 'DRC.solverD', 'Gurobi', 'DRC.programType', 'indivi');
opt = daline.setopt('method.name', 'DRC_XYD', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF'}, 'DRC.infMethod', 'bisec', 'DRC.bisecTol' , 1e-8);
model = daline.fit(dataN, opt);
model = func_algorithm_DRC_XYD(dataN, 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF'}, 'DRC.infMethod', 'bisec', 'DRC.bisecTol', 1e-8);
opt = daline.setopt('variable.predictor', {'P', 'Q'}, 'variable.response', {'PF'}, 'DRC.infMethod', 'bisec', 'DRC.bisecTol', 1e-8);
model = func_algorithm_DRC_XYD(dataN, opt);

%% Section 4.8.1 DCPF --- abbreviation: DC
model = daline.fit(data, 'method.name', 'DC'); 
model = func_algorithm_DC(data);

%% Section 4.8.2 DCPF with ordinary least squares --- abbreviation: DC_LS
model = daline.fit(data, 'method.name', 'DC_LS'); 
model = func_algorithm_DC_LS(data);

%% Section 4.8.3 Decoupled linearized power flow (DLPF) --- abbreviation: DLPF
model = daline.fit(data, 'method.name', 'DLPF');
model = func_algorithm_DLPF(data);

%% Section 4.8.4 DLPF corrected in a data-driven manner --- abbreviation: DLPF_C
model = daline.fit(data, 'method.name', 'DLPF_C'); 
model = func_algorithm_DLPF_C(data);

%% Section 4.8.5 Power transfer distribution factor (PTDF)  --- abbreviation: PTDF
model = daline.fit(data, 'method.name', 'PTDF'); 
model = func_algorithm_PTDF(data);

%% Section 4.8.6 First-order Taylor approximation --- abbreviation: TAY
% (see Table 4.36 for parameters of TAY)
model = daline.fit(data, 'method.name', 'TAY');
model = daline.fit(data, 'method.name', 'TAY', 'TAY.point0', 1);
model = func_algorithm_TAY(data, 'TAY.point0', 1);
opt = daline.setopt('method.name', 'TAY', 'TAY.point0', 1); 
model = daline.fit(data, opt);
opt = daline.setopt('TAY.point0', 1); 
model = func_algorithm_TAY(data, opt);

%% Section 4.9.1 Direct QR decomposition --- abbreviation: QR
model = daline.fit(data, 'method.name', 'QR');
model = daline.fit(data, 'method.name', 'QR', 'variable.predictor', {'P'}, 'variable.response', {'PF', 'Vm'});
opt = daline.setopt('method.name', 'QR', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF'});
model = daline.fit(data, opt);
model = func_algorithm_QR(data, 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'QF'});
opt = daline.setopt('variable.predictor', {'P', 'Q'}, 'variable.response', {'PF'});
model = func_algorithm_QR(data, opt);

%% Section 4.9.2 Direct left division --- abbreviation: LD
model = daline.fit(data, 'method.name', 'LD');
model = daline.fit(data, 'method.name', 'LD', 'variable.predictor', {'P'}, 'variable.response', {'PF', 'Vm'});
opt = daline.setopt('method.name', 'LD', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF'});
model = daline.fit(data, opt);
model = func_algorithm_LD(data, 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'QF'});
opt = daline.setopt('variable.predictor', {'P', 'Q'}, 'variable.response', {'PF'});
model = func_algorithm_LD(data, opt);

%% Section 4.9.3 Direct generalized inverse --- abbreviation: PIN
model = daline.fit(data, 'method.name', 'PIN');
model = daline.fit(data, 'method.name', 'PIN', 'variable.predictor', {'P'}, 'variable.response', {'PF', 'Vm'});
opt = daline.setopt('method.name', 'PIN', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF'});
model = daline.fit(data, opt);
model = func_algorithm_PIN(data, 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'QF'});
opt = daline.setopt('variable.predictor', {'P', 'Q'}, 'variable.response', {'PF'});
model = func_algorithm_PIN(data, opt);

%% Section 4.9.4 Direct singular value decomposition --- abbreviation: SVD
model = daline.fit(data, 'method.name', 'SVD');
model = daline.fit(data, 'method.name', 'SVD', 'variable.predictor', {'P'}, 'variable.response', {'PF', 'Vm'});
opt = daline.setopt('method.name', 'SVD', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF'});
model = daline.fit(data, opt);
model = func_algorithm_SVD(data, 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'QF'});
opt = daline.setopt('variable.predictor', {'P', 'Q'}, 'variable.response', {'PF'});
model = func_algorithm_SVD(data, opt);

%% Section 4.9.5 Direct complete orthogonal decomposition --- abbreviation: COD
model = daline.fit(data, 'method.name', 'COD');
model = daline.fit(data, 'method.name', 'COD', 'variable.predictor', {'P'}, 'variable.response', {'PF', 'Vm'});
opt = daline.setopt('method.name', 'COD', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF'});
model = daline.fit(data, opt);
model = func_algorithm_COD(data, 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'QF'});
opt = daline.setopt('variable.predictor', {'P', 'Q'}, 'variable.response', {'PF'});
model = func_algorithm_COD(data, opt);

%% Section 4.9.6 Direct principal component analysis --- abbreviation: PCA
model = daline.fit(data, 'method.name', 'PCA');
model = daline.fit(data, 'method.name', 'PCA', 'variable.predictor', {'P'}, 'variable.response', {'PF', 'Vm'}, 'PCA.parallel', 1, 'PCA.PerComponent', [30:10:90], 'PCA.numFold', 5);
opt = daline.setopt('method.name', 'PCA', 'variable.predictor', {'P'}, 'variable.response', {'PF', 'Vm'}, 'PCA.PerComponent', [30:10:90], 'PCA.numFold', 5);
model = daline.fit(data, opt);
model = func_algorithm_PCA(data, 'variable.predictor', {'P'}, 'variable.response', {'PF', 'Vm'}, 'PCA.PerComponent', [30:10:90], 'PCA.numFold', 5);
opt = daline.setopt('variable.predictor', {'P'}, 'variable.response', {'PF', 'Vm'}, 'PCA.PerComponent', [30:10:90], 'PCA.numFold', 5);
model = func_algorithm_PCA(data, opt);


%% Section 5.1.1 Accuracy summary of a single method --- daline.plot

% Get data and model
data = daline.data('case.name', 'case9');
model  = daline.fit(data, 'method.name', 'PLS_SIM');

% Test daline.plot using different parameters
% (see Table 5.1 for the parameters of daline.plot)
daline.plot(model);  
daline.plot(model, 'PLOT.response', {'Vm'});  
daline.plot(model, 'PLOT.response', {'Vm', 'PF'}, 'PLOT.theme', 'academic', 'PLOT.style', 'light', 'PLOT.pattern', 'joint');  % Plot the method ranking for every error field
daline.plot(model, 'PLOT.response', {'Vm'}, 'PLOT.style', 'light');  

% Test daline.plot using different parameters via opt structure for parameter settings
% (see Table 5.1 for the parameters of daline.plot)
% failedMethod: the indicator of failure. The indicator determines if the method 'PLS_SIM' encounters any failures while employing the linear model it generated to compute 'Vm' or 'PF'. Any failure details are methodically organized in the output labeled 'failure'. If there are no failures, this output will remain empty.
opt = daline.setopt('PLOT.response', {'Vm', 'PF'}, 'PLOT.theme', 'academic', 'PLOT.pattern', 'indivi');
failedMethod = daline.plot(model, opt);

% Test daline.plot using different parameters 
% (see Table 5.1 for the parameters of daline.plot)
% failedMethod: the indicator of failure. The indicator determines if the method 'PLS_SIM' encounters any failures while employing the linear model it generated to compute 'Vm' or 'PF'. Any failure details are methodically organized in the output labeled 'failure'. If there are no failures, this output will remain empty.
daline.plot(model, 'PLOT.response', {'Vm'}, 'PLOT.style', 'light', 'PLOT.print', 1);  
daline.plot(model, 'PLOT.response', {'Vm'}, 'PLOT.caseName', 'case9', 'PLOT.print', 1);  
failedMethod = daline.plot(model, 'PLOT.response', {'Vm', 'PF', 'Va'}, 'PLOT.switch', 0); 


%% Section 5.1.2 Accuracy rankings of multiple methods --- daline.rank


% Multiple methods rank: round 1 
% (see Table 5.1 for the parameters of daline.rank)
data = daline.data('case.name', 'case9');
daline.rank(data, {'LS_COD'}, 'variable.response', {'Vm'}, 'PLOT.response', {'Vm', 'PF'}); % Will only plot 'Vm' and leave 'PF' as a failure
daline.rank(data, {'TAY', 'QR'}, 'PLOT.response', {'Vm'});
model = daline.rank(data, {'TAY', 'QR'}, 'PLOT.response', {'Vm', 'PF'});
[model, failedMethod] = daline.rank(data, {'TAY', 'QR'}, 'PLOT.response', {'Vm', 'PF', 'Va'}, 'PLOT.switch', 0);

% Multiple methods rank: round 2, using opt to set up parameters 
% (see Table 5.1 for the parameters of daline.rank)
data = daline.data('case.name', 'case9');
opt = daline.setopt('PLOT.response', {'Vm', 'PF', 'Va'}, 'PLOT.switch', 0);
[model, failedMethod] = daline.rank(data, {'TAY', 'QR'}, opt);

% Multiple methods rank: round 3, using opt to set up parameters 
% (see Table 5.1 for the parameters of daline.rank)
data = daline.data('case.name', 'case9');
opt = daline.setopt('variable.response', {'Vm'}, 'PLOT.response', {'Vm', 'PF'});
[model, failedMethod] = daline.rank(data, {'TAY', 'QR'}, opt);

% Multiple methods rank: round 4 testing all approaches in method using different parameters
% (see Table 5.1 for the parameters of daline.rank)
data = daline.data('case.name', 'case9');
method = {'LS'; 'LS_SVD'; 'LS_COD'; 'LS_TOL'; 'LS_CLS'; 'LS_LIFX'; 'LS_LIFXi'; 'LS_REC'; 'PLS_SIMRX'; 'PLS_BDL'; 'PLS_BDLY2'; 'PLS_REC'; 'PLS_RECW'; 'RR'; 'RR_KPC'; 'RR_WEI'; 'LS_PIN'; 'LS_PCA'; 'PLS_NIP'; 'PLS_CLS'; 'TAY'; 'DC'; 'PTDF'; 'DLPF'; 'DLPF_C'; 'DC_LS'};
daline.rank(data, method)
daline.rank(data, method, 'PLOT.response', {'Vm', 'PF'});
daline.rank(data, method, 'variable.response', {'Vm'}, 'PLOT.response', {'Vm', 'PF'});     % Will only plot 'Vm' and leave 'PF' as a failure; yet, some methods will still generate 'PF' because their responses are fixed
daline.rank(data, method, 'variable.response', {'Vm', 'PF'}, 'PLOT.response', {'PF'});
model = daline.rank(data, method, 'variable.response', {'Vm', 'PF'}, 'PLOT.response', {'PF'}, 'PLOT.switch', 0);  % Only output model, containing the model structs of all methods
[model, failedMethod] = daline.rank(data, method, 'variable.response', {'Vm', 'PF'}, 'PLOT.response', {'PF', 'QF'}, 'PLOT.switch', 0);  % Output model and the list of failed method(s). Note whether the methods are failed are determined by whether they have valid outputs for the responses in 'PLOT.response'
[model, failedMethod] = daline.rank(data, method, 'variable.response', {'Vm', 'PF'}, 'PLOT.response', {'PF', 'QF'});  % Output model and the list of failed method(s). Note whether the methods are failed are determined by whether they have valid outputs for the responses in 'PLOT.response'

% Multiple methods rank: round 5 testing all approaches in method using
% different parameters via opt structure to set up parameters
% (see Table 5.1 for the parameters of daline.rank)
data = daline.data('case.name', 'case9');
method = {'LS'; 'LS_SVD'; 'LS_COD'; 'LS_TOL'; 'LS_CLS'; 'LS_LIFX'; 'LS_LIFXi'; 'LS_REC'; 'PLS_SIMRX'; 'PLS_BDL'; 'PLS_BDLY2'; 'PLS_REC'; 'PLS_RECW'; 'RR'; 'RR_KPC'; 'RR_WEI'; 'LS_PIN'; 'LS_PCA'; 'PLS_NIP'; 'PLS_CLS'; 'TAY'; 'DC'; 'PTDF'; 'DLPF'; 'DLPF_C'; 'DC_LS'};
opt = daline.setopt('variable.response', {'Vm', 'PF'}, 'PLOT.response', {'PF', 'QF'});
[model, failedMethod] = daline.rank(data, method, opt);

% Multiple methods rank: round 6 using different parameters (focusing on themes) 
% (see Table 5.1 for the parameters of daline.rank)
data = daline.data('case.name', 'case9');
method = {'LS'; 'LS_SVD'; 'LS_COD'; 'LS_TOL'; 'LS_CLS'; 'LS_LIFX'; 'LS_LIFXi'; 'LS_REC'; 'PLS_SIMRX'; 'PLS_BDL'; 'PLS_BDLY2'; 'PLS_REC'; 'PLS_RECW'; 'RR'; 'RR_KPC'; 'RR_WEI'; 'LS_PIN'; 'LS_PCA'; 'PLS_NIP'; 'PLS_CLS'; 'TAY'; 'DC'; 'PTDF'; 'DLPF'; 'DLPF_C'; 'DC_LS'};
[model, failedMethod] = daline.rank(data, {'TAY', 'QR'}, 'PLOT.response', {'Vm', 'PF', 'Va'}, 'PLOT.theme', 'commercial');
[model, failedMethod] = daline.rank(data, {'TAY', 'QR'}, 'PLOT.response', {'Vm', 'PF', 'Va'}, 'PLOT.theme', 'commercial', 'PLOT.style', 'light');
[model, failedMethod] = daline.rank(data, {'TAY', 'QR'}, 'PLOT.response', {'Vm', 'PF', 'Va'}, 'PLOT.theme', 'commercial', 'PLOT.style', 'light', 'PLOT.pattern', 'joint');
[model, failedMethod] = daline.rank(data, {'TAY', 'QR'}, 'PLOT.response', {'Vm', 'PF', 'Va'}, 'PLOT.theme', 'commercial', 'PLOT.style', 'dark', 'PLOT.pattern', 'joint');  % 'joint' enforces to use the 'academic' theme, which only has a 'light' style
[model, failedMethod] = daline.rank(data, {'TAY', 'QR'}, 'PLOT.response', {'Vm', 'PF', 'Va'}, 'PLOT.theme', 'academic');  
[model, failedMethod] = daline.rank(data, {'TAY', 'QR'}, 'PLOT.response', {'Vm', 'PF', 'Va'}, 'PLOT.theme', 'academic', 'PLOT.style', 'dark');  % 'academic' theme only has a 'light' style, so 'dark' here is meaningless
[model, failedMethod] = daline.rank(data, {'TAY', 'QR'}, 'PLOT.response', {'Vm', 'PF', 'Va'}, 'PLOT.theme', 'academic', 'PLOT.pattern', 'joint'); 
[model, failedMethod] = daline.rank(data, method, 'variable.response', {'Vm', 'PF'}, 'PLOT.response', {'PF'}, 'PLOT.theme', 'academic', 'PLOT.pattern', 'indivi');
[model, failedMethod] = daline.rank(data, method, 'variable.response', {'Vm', 'PF'}, 'PLOT.response', {'PF'}, 'PLOT.theme', 'commercial', 'PLOT.style', 'light');

% Multiple methods rank: round 7 testing all approaches in method (focusing on themes) 
% (see Table 5.1 for the parameters of daline.rank)
% Note: in 'academic' theme, failure means the method failed all the responses in 'PLOT.response'
data = daline.data('case.name', 'case9');
method = {'LS'; 'LS_SVD'; 'LS_COD'; 'LS_TOL'; 'LS_CLS'; 'LS_LIFX'; 'LS_LIFXi'; 'LS_REC'; 'PLS_SIMRX'; 'PLS_BDL'; 'PLS_BDLY2'; 'PLS_REC'; 'PLS_RECW'; 'RR'; 'RR_KPC'; 'RR_WEI'; 'LS_PIN'; 'LS_PCA'; 'PLS_NIP'; 'PLS_CLS'; 'TAY'; 'DC'; 'PTDF'; 'DLPF'; 'DLPF_C'; 'DC_LS'};
opt = daline.setopt('variable.response', {'Vm', 'PF'}, 'PLOT.response', {'Vm', 'PF', 'Va'}, 'PLOT.theme', 'commercial', 'PLOT.style', 'light', 'PLOT.pattern', 'joint'); % 'joint' enforces to use the 'academic' theme, which only has a 'light' style
[model, failedMethod] = daline.rank(data, method, opt);

%% Section 5.2.1 Computational time rankings of multiple methods --- daline.time

% (see Table 5.2 for the parameters of daline.time)
data = daline.data('case.name', 'case39');  
time_list = daline.time(data, {'LS', 'LS_SVD', 'RR'});
time_list = daline.time(data, {'LS', 'LS_SVD', 'RR'}, 'PLOT.repeat', 5);
time_list = daline.time(data, {'LS', 'LS_SVD', 'RR'}, 'PLOT.style', 'light');
time_list = daline.time(data, {'LS', 'LS_SVD', 'RR'}, 'PLOT.style', 'dark');
time_list = daline.time(data, method);
time_list = daline.time(data, method, 'PLOT.style', 'light');
opt = daline.setopt('PLOT.repeat', 5, 'PLOT.style', 'light');
time_list = daline.time(data, method, opt);

% Users can put the parameters of any methods into daline.time
% (see Table 5.2 for the parameters of daline.time)
opt = daline.setopt('variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'RR.lambdaInterval', [0:5e-3:0.1], 'PLOT.repeat', 5, 'PLOT.style', 'light');
time_list = daline.time(data, {'LS', 'LS_SVD', 'RR'}, opt);
opt = daline.setopt('variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'PLOT.repeat', 5, 'PLOT.style', 'light');
time_list = daline.time(data, {'LS', 'LS_SVD', 'RR'}, opt);


%% Section 5.2.2 Computational time evolution curves of multiple methods --- daline.time

% Test multiple datasets using different parameters and different manners to set up parameters 
% (see Table 5.2 for the parameters of daline.time)
caselist = {'case9', 'case14', 'case33bw', 'case39'};
datalist = cell(length(caselist), 1);
for n = 1:length(caselist)
    datalist{n} = daline.data('case.name', caselist{n});
end
method = {'LS'; 'LS_SVD'; 'LS_COD'; 'LS_TOL'; 'LS_CLS'; 'LS_LIFX'; 'LS_LIFXi'; 'LS_REC'; 'PLS_SIMRX'; 'PLS_BDL'; 'PLS_BDLY2'; 'PLS_REC'; 'PLS_RECW'; 'RR'; 'RR_KPC'; 'RR_WEI'; 'LS_PIN'; 'LS_PCA'; 'PLS_NIP'; 'PLS_CLS'; 'TAY'; 'DC'; 'PTDF'; 'DLPF'; 'DLPF_C'; 'DC_LS'};
time_list = daline.time(datalist, {'LS', 'LS_SVD', 'RR'});
time_list = daline.time(datalist, {'LS', 'LS_SVD', 'RR'}, 'PLOT.style', 'light');
opt = daline.setopt('PLOT.repeat', 5, 'PLOT.style', 'light');
time_list = daline.time(datalist, {'LS', 'LS_SVD', 'RR'}, opt);
opt = daline.setopt('PLOT.repeat', 5, 'PLOT.style', 'dark');
time_list = daline.time(datalist, method, opt);

%% Section 6 --- daline.all

% Test the minimal input
model = daline.all('case118');

% Test the minimal input
mpc = ext2int(loadcase('case118'));
model = daline.all('case118');

% Test data generation
model = daline.all('case118', 'num.trainSample', 150, 'num.testSample', 200, 'data.parallel', 0, 'data.curvePlot', 1);

% Test adding outliers
model = daline.all('case118', 'num.trainSample', 150, 'num.testSample', 200, 'outlier.switchTrain', 1);
model = daline.all('case118', 'num.trainSample', 150, 'num.testSample', 200, 'outlier.switchTrain', 1, 'outlier.switchTest', 1);

% Test adding noise
model = daline.all('case118', 'noise.switchTrain', 1, 'noise.SNR_dB', 30);
model = daline.all('case118', 'noise.switchTest', 1, 'noise.SNR_dB', 30);

% Test filtering outliers
model = daline.all('case118', 'outlier.switchTrain', 1, 'outlier.percentage', 0.01, 'filOut.switchTrain', 1);
model = daline.all('case118', 'outlier.switchTest', 1, 'outlier.percentage', 0.01, 'filOut.switchTest', 1, 'filOut.method', 'median');

% Test filtering noise
model = daline.all('case118', 'noise.switchTrain', 1, 'noise.SNR_dB', 30, 'filNoi.switchTrain', 1);
model = daline.all('case118', 'noise.switchTrain', 1, 'noise.SNR_dB', 30, 'filNoi.switchTrain', 1, 'filNoi.est_dB', 31);

% Test normalizing data
[model, data] = daline.all('case118', 'norm.switch', 1);

% Test methods
[model, data, failure] = daline.all('case118', 'method.name', 'RR');
[model, data, failure] = daline.all('case118', 'method.name', 'RR_KPC', 'RR.lambdaInterval', [0.1:0.01:0.2], 'PLOT.switch', 0);
[model, data, failure] = daline.all('case118', 'method.name', 'RR_KPC', 'RR.clusNumInterval', 10, 'RR.etaInterval', 1000, 'PLOT.switch', 0);
[model, data, failure] = daline.all('case118', 'method.name', 'RR_VCS');
[model, data, failure] = daline.all('case118', 'method.name', 'RR_VCS', 'RR.lambdaInterval', [0.1:0.01:0.2]);

% Test plot
[model, data, failure] = daline.all('case118', 'method.name', 'RR_VCS', 'PLOT.switch', 0);
[model, data, failure] = daline.all('case118', 'method.name', 'RR_VCS', 'PLOT.response', {'Vm', 'PF'}, 'PLOT.theme', 'academic', 'PLOT.pattern', 'indivi');

% Test opt
opt = daline.setopt('method.name', 'RR_VCS', 'PLOT.response', {'Vm', 'PF'}, 'PLOT.theme', 'academic', 'PLOT.pattern', 'indivi');
[model, data, failure] = daline.all('case118', opt);