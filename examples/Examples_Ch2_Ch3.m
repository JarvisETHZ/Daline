%% IMPORTANT: Please don't directly run the whole script; otherwise the following codes will create a lot of figures :p

%% Chap. 2.3

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

%% Chap. 2.4

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

%% Chap. 3.1

% Example 0: data generation (see Table 3.1 for all the adjustable parameters for daline.generate)
data = daline.generate('case.name', 'case118', 'data.program', 'acpf', 'data.baseType', 'TimeSeriesRand', 'load.distribution', 'normal');

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

%% Chap. 3.2.2

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

%% Chap. 3.2.3

% Example 1: data generation and adding outlier to data (see Table 3.3 for all the adjustable parameters for daline.outlier) 
data = daline.generate('case.name', 'case118', 'data.program', 'acpf', 'data.baseType', 'TimeSeriesRand');
data = daline.outlier(data, 'outlier.switchTrain', 1, 'outlier.percentage', 2.5);

% Example 2: data generation and adding outlier to data (see Table 3.3 for all the adjustable parameters for daline.outlier) 
% Use opt structure to set up parameters
data = daline.generate('case.name', 'case118', 'data.program', 'acpf', 'data.baseType', 'TimeSeriesRand');
opt  = daline.setopt('outlier.switchTrain', 1, 'outlier.switchTest', 1, 'outlier.factor', 3);
data = daline.outlier(data, opt);

%% Chap. 3.2.4

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

%% Chap. 3.2.5

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

%% Chap. 3.2.6

% Example 1: data generation and data normalization (see Table 3.6 for all the adjustable parameters for daline.normalize) 
data = daline.generate('case.name', 'case118', 'data.program', 'acpf', 'data.baseType', 'TimeSeriesRand');
data = daline.normalize(data, 'norm.switch', 1);

% Example 1: data generation and data normalization (see Table 3.6 for all the adjustable parameters for daline.normalize) 
% Use opt structure to set up parameters
data = daline.generate('case.name', 'case118', 'data.program', 'acpf', 'data.baseType', 'TimeSeriesRand');
opt  = daline.setopt('norm.switch', 1);
data = daline.normalize(data, opt);


%% Chap. 3.3

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

