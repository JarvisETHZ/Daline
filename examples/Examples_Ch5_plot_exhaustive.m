%% IMPORTANT: Please don't directly run the whole script; otherwise the following codes will create a lot of figures :p

%% Get data
data = daline.data('case.name', 'case9');

%% Define a method list
method = {'LS'; 'LS_SVD'; 'LS_COD'; 'LS_TOL'; 'LS_CLS'; 'LS_LIFX'; 'LS_LIFXi'; 'LS_REC'; 'PLS_SIMRX'; 'PLS_BDL'; 'PLS_BDLY2'; 'PLS_REC'; 'PLS_RECW'; 'RR'; 'RR_KPC'; 'RR_WEI'; 'LS_PIN'; 'LS_PCA'; 'PLS_NIP'; 'PLS_CLS'; 'TAY'; 'DC'; 'PTDF'; 'DLPF'; 'DLPF_C'; 'DC_LS'};

%% Get models
models = daline.rank(data, method, 'PLOT.switch', 0);  % No figure
model  = daline.fit(data, 'method.name', 'PLS_SIM');

%% Plot: basic test with models
daline.plot(models);  % Plot the method ranking for every error field
daline.plot(models, 'PLOT.response', {'Vm'});  % Only plot the method ranking for the error of 'Vm'
daline.plot(models, 'PLOT.response', {'Vm', 'PF'});   % Plot the method ranking for the errors of 'Vm' and 'PF'
failedMethod = daline.plot(models, 'PLOT.response', {'Vm', 'PF', 'Va'}, 'PLOT.switch', 0);  % Output model and the list of failed method(s). Note whether the methods are failed are determined by whether they have valid outputs for the responses in 'PLOT.response'

opt = daline.setopt('PLOT.response', {'Vm', 'Va'}, 'PLOT.switch', 0);
failedMethod = daline.plot(models, opt);

%% Plot: theme test with models
daline.plot(models, 'PLOT.response', {'Vm', 'PF'}, 'PLOT.theme', 'commercial');
daline.plot(models, 'PLOT.response', {'Vm', 'PF'}, 'PLOT.theme', 'commercial', 'PLOT.type', 'probability');
daline.plot(models, 'PLOT.response', {'Vm', 'PF'}, 'PLOT.theme', 'commercial', 'PLOT.style', 'light');
daline.plot(models, 'PLOT.response', {'Vm', 'PF'}, 'PLOT.theme', 'commercial', 'PLOT.style', 'light', 'PLOT.pattern', 'joint'); % 'joint' enforces to use the 'academic' theme, which only has a 'light' style
daline.plot(models, 'PLOT.response', {'Vm', 'PF'}, 'PLOT.theme', 'academic');
daline.plot(models, 'PLOT.response', {'Vm', 'PF'}, 'PLOT.theme', 'academic', 'PLOT.style', 'dark');  % 'academic' theme only has a 'light' style, so 'dark' here is meaningless
daline.plot(models, 'PLOT.response', {'Vm', 'PF'}, 'PLOT.theme', 'academic', 'PLOT.pattern', 'indivi');

opt = daline.setopt('PLOT.response', {'Vm', 'PF'}, 'PLOT.theme', 'academic', 'PLOT.pattern', 'indivi');
failedMethod = daline.plot(models, opt);
opt = daline.setopt('PLOT.response', {'Vm', 'PF'}, 'PLOT.theme', 'commercial', 'PLOT.style', 'light');
failedMethod = daline.plot(models, opt);

%% Plot: basic and theme tests with model
daline.plot(model);  
daline.plot(model, 'PLOT.response', {'Vm'});  
daline.plot(model, 'PLOT.response', {'Vm', 'PF'}, 'PLOT.theme', 'academic', 'PLOT.style', 'light', 'PLOT.pattern', 'joint');  % Plot the method ranking for every error field
daline.plot(model, 'PLOT.response', {'Vm'}, 'PLOT.style', 'light');  

opt = daline.setopt('PLOT.response', {'Vm', 'PF'}, 'PLOT.theme', 'academic', 'PLOT.pattern', 'indivi');
failedMethod = daline.plot(model, opt);

daline.plot(model, 'PLOT.response', {'Vm'}, 'PLOT.style', 'light', 'PLOT.print', 1);  
daline.plot(model, 'PLOT.response', {'Vm'}, 'PLOT.caseName', 'case9', 'PLOT.print', 1);  
failedMethod = daline.plot(model, 'PLOT.response', {'Vm', 'PF', 'Va'}, 'PLOT.switch', 0); 