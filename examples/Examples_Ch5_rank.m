%% IMPORTANT: Please don't directly run the whole script; otherwise the following codes will create a lot of figures :p

%% Test probability distribution
data = daline.data('case.name', 'case118', 'data.baseType', 'TimeSeriesRand', 'load.upperRangeTime', 1.05, 'load.lowerRangeTime', 0.95, 'load.distribution', 'normal', 'voltage.distribution', 'normal', 'voltage.varyIndicator', 0, 'data.parallel', 1, 'data.fixRand', 1);
methodList = {'PLS_CLS'; 'RR_KPC'; 'LS_PCA'; 'LS_LIFX'; 'PLS_RECW'; 'DLPF_C'; 'RR_WEI'; 'RR_VCS'; 'PTDF'; 'DC'; 'DLPF'; 'DC_LS'; 'TAY'};
opt = daline.setopt('variable.response', {'PF', 'Vm'}, 'PLOT.switch', 1, 'PLOT.response', {'PF'}, 'PLOT.type', 'probability', 'PLOT.style', 'light', 'PLS.clusNumInterval', 8, 'RR.clusNumInterval', 12, 'RR.etaInterval', 1000, 'PCA.PerComponent', 90, 'PLS.omega', 0.8, 'RR.tauInterval', 0.4, 'RR.lambdaInterval', 1e-10);
models = daline.rank(data, methodList, opt); 

%% Test moment distribution
data = daline.data('case.name', 'case9');
methodList = {'LS'; 'PLS_SIMRX'; 'LS_COD'; 'LS_LIFX'; 'LS_CLS'; 'RR'; 'RR_KPC'; 'RR_WEI'; 'LS_PIN'; 'LS_PCA'; 'PLS_NIP'; 'PLS_CLS'; 'TAY'; 'DC'; 'PTDF'; 'DLPF'; 'DLPF_C'; 'DC_LS'};
daline.rank(data, methodList, 'variable.response', {'Vm', 'PF'}, 'PLOT.response', {'Vm', 'PF'}); 
daline.rank(data, methodList, 'variable.response', {'Vm', 'PF'}, 'variable.liftType', 'gauss', 'TAY.point0 ', 'end', 'PLOT.response', {'PF'}, 'PLOT.style', 'light'); 
[models, failedMethod] = daline.rank(data, methodList, 'PLOT.response', {'Vm', 'PF'}, 'PLOT.theme', 'academic', 'PLOT.pattern', 'joint');
opt = daline.setopt('variable.response', {'Vm', 'PF'}, 'PLOT.response', {'Vm', 'PF'}, 'PLOT.theme', 'academic', 'PLOT.pattern', 'indivi'); % 'joint' enforces to use the 'academic' theme, which only has a 'light' style
[models, failedMethod] = daline.rank(data, methodList, opt);


%% More examples regarding how to adjust the parameters specific to particular methods when comparing them
% More examples regarding how to adjust the parameters specific to particular methods when comparing them. Users only need to put the name-value pair parameters from the third argument of daline.rank. For the parameters of methods, no mandatory orders or mapping constraints are enforced. 
data = daline.data('case.name', 'case9');
daline.rank(data, {'DLPF_C', 'RR', 'PLS_REC'}, 'RR.lambdaInterval', 1e-5, 'RR.cvNumFold', 4, 'PLS.recursivePercentage', 40);

% More examples regarding how to adjust the parameters specific to particular methods when comparing them. Users can also use opt parameter structure, which can be used as the third argument of daline.rank
data = daline.data('case.name', 'case9');
opt = daline.setopt('RR.lambdaInterval', 1e-5, 'RR.cvNumFold', 4, 'PLS.recursivePercentage', 40);
daline.rank(data, {'DLPF_C', 'RR', 'PLS_REC'}, opt);

% More examples regarding how to adjust the parameters specific to particular methods when comparing them. Certainly, different methods can always be collected into a set, e.g., 
data = daline.data('case.name', 'case9');
method = {'DLPF_C', 'RR', 'PLS_REC'};
opt = daline.setopt('RR.lambdaInterval', 1e-5, 'RR.cvNumFold', 4, 'PLS.recursivePercentage', 40);
daline.rank(data, method, opt);




