%% IMPORTANT: Please don't directly run the whole script; otherwise the following codes will create a lot of figures :p

%% Preparation

% Single dataset
data = daline.data('case.name', 'case39');  

% Multiple datasets
caseList = {'case9', 'case14', 'case33bw', 'case39'};
dataList = cell(length(caseList), 1);
for n = 1:length(caseList)
    dataList{n} = daline.data('case.name', caseList{n});
end

% Define a method list
method = {'LS'; 'PLS_SIMRX'; 'LS_COD'; 'LS_LIFX'; 'LS_CLS'; 'RR'; 'RR_KPC'; 'RR_WEI'; 'LS_PIN'; 'LS_PCA'; 'PLS_NIP'; 'PLS_CLS'; 'TAY'; 'DC'; 'PTDF'; 'DLPF'; 'DLPF_C'; 'DC_LS'};

%% Test the computational time ranking
daline.time(data, method);
timeList = daline.time(data, method, 'PLOT.repeat', 5, 'PLOT.style', 'light');
opt = daline.setopt('PLOT.repeat', 3, 'PLOT.style', 'dark');
timeList = daline.time(data, method, opt);

%% Test the computational evolution curve
timeList = daline.time(dataList, method);
opt = daline.setopt('variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'RR.lambdaInterval', [0:5e-2:0.1], 'PLOT.repeat', 5, 'PLOT.style', 'light');
time_list = daline.time(dataList, method, opt);