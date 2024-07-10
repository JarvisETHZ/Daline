%% IMPORTANT: Please don't directly run the whole script; otherwise the following codes will create a lot of figures :p

%% Preparation

% Single dataset
data = daline.data('case.name', 'case39');  

% Multiple datasets
caselist = {'case9', 'case14', 'case33bw', 'case39'};
datalist = cell(length(caselist), 1);
for n = 1:length(caselist)
    datalist{n} = daline.data('case.name', caselist{n});
end

% Define a method list
method = {'LS'; 'LS_SVD'; 'LS_COD'; 'LS_TOL'; 'LS_CLS'; 'LS_LIFX'; 'LS_LIFXi'; 'LS_REC'; 'PLS_SIMRX'; 'PLS_BDL'; 'PLS_BDLY2'; 'PLS_REC'; 'PLS_RECW'; 'RR'; 'RR_KPC'; 'RR_WEI'; 'LS_PIN'; 'LS_PCA'; 'PLS_NIP'; 'PLS_CLS'; 'TAY'; 'DC'; 'PTDF'; 'DLPF'; 'DLPF_C'; 'DC_LS'};

%% Test single dataset; no 'PLOT.theme', 'commercial'
time_list = daline.time(data, {'LS', 'LS_SVD', 'RR'});
time_list = daline.time(data, {'LS', 'LS_SVD', 'RR'}, 'PLOT.repeat', 5);
time_list = daline.time(data, {'LS', 'LS_SVD', 'RR'}, 'PLOT.style', 'light');
time_list = daline.time(data, {'LS', 'LS_SVD', 'RR'}, 'PLOT.style', 'dark');
time_list = daline.time(data, method);
time_list = daline.time(data, method, 'PLOT.style', 'light');
opt = daline.setopt('PLOT.repeat', 5, 'PLOT.style', 'light');
time_list = daline.time(data, method, opt);

% Users can put the parameters of any methods into daline.time
opt = daline.setopt('variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'RR.lambdaInterval', [0:5e-3:0.1], 'PLOT.repeat', 5, 'PLOT.style', 'light');
time_list = daline.time(data, {'LS', 'LS_SVD', 'RR'}, opt);
opt = daline.setopt('variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'PLOT.repeat', 5, 'PLOT.style', 'light');
time_list = daline.time(data, {'LS', 'LS_SVD', 'RR'}, opt);

%% Test multiple datasets; no 'PLOT.theme', 'commercial'
time_list = daline.time(datalist, {'LS', 'LS_SVD', 'RR'});
time_list = daline.time(datalist, {'LS', 'LS_SVD', 'RR'}, 'PLOT.style', 'light');
opt = daline.setopt('PLOT.repeat', 5, 'PLOT.style', 'light');
time_list = daline.time(datalist, {'LS', 'LS_SVD', 'RR'}, opt);
opt = daline.setopt('PLOT.repeat', 5, 'PLOT.style', 'dark');
time_list = daline.time(datalist, method, opt);