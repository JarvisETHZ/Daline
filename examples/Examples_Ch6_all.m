%% IMPORTANT: Please don't directly run the whole script; otherwise the following codes will create a lot of figures :p

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
model = daline.all('case118', 'outlier.switchTrain', 1, 'outlier.percentage', 0.001, 'filOut.switchTrain', 1);
model = daline.all('case118', 'outlier.switchTest', 1, 'outlier.percentage', 0.001, 'filOut.switchTest', 1, 'filOut.method', 'median');

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

