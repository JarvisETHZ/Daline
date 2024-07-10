%% IMPORTANT: Please don't directly run the whole script; otherwise the following codes will create a lot of figures :p

%% Get data
data = daline.data('case.name', 'case9');

%% Define a method list
method = {'LS'; 'LS_SVD'; 'LS_COD'; 'LS_TOL'; 'LS_CLS'; 'LS_LIFX'; 'LS_LIFXi'; 'LS_REC'; 'PLS_SIMRX'; 'PLS_BDL'; 'PLS_BDLY2'; 'PLS_REC'; 'PLS_RECW'; 'RR'; 'RR_KPC'; 'RR_WEI'; 'LS_PIN'; 'LS_PCA'; 'PLS_NIP'; 'PLS_CLS'; 'TAY'; 'DC'; 'PTDF'; 'DLPF'; 'DLPF_C'; 'DC_LS'};

%% Multiple methods rank: round 1 
daline.rank(data, {'LS_COD'}, 'variable.response', {'Vm'}, 'PLOT.response', {'Vm', 'PF'}); % Will only plot 'Vm' and leave 'PF' as a failure
daline.rank(data, {'TAY', 'QR'}, 'PLOT.response', {'Vm'});
model = daline.rank(data, {'TAY', 'QR'}, 'PLOT.response', {'Vm', 'PF'});
[model, failedMethod] = daline.rank(data, {'TAY', 'QR'}, 'PLOT.response', {'Vm', 'PF', 'Va'}, 'PLOT.switch', 0);

% opt 1
opt = daline.setopt('PLOT.response', {'Vm', 'PF', 'Va'}, 'PLOT.switch', 0);
[model, failedMethod] = daline.rank(data, {'TAY', 'QR'}, opt);

% opt 2
opt = daline.setopt('variable.response', {'Vm'}, 'PLOT.response', {'Vm', 'PF'});
[model, failedMethod] = daline.rank(data, {'TAY', 'QR'}, opt);


%% Multiple methods rank: round 2
daline.rank(data, method)
daline.rank(data, method, 'PLOT.response', {'Vm', 'PF'});
daline.rank(data, method, 'variable.response', {'Vm'}, 'PLOT.response', {'Vm', 'PF'});     % Will only plot 'Vm' and leave 'PF' as a failure; yet, some methods will still generate 'PF' because their responses are fixed
daline.rank(data, method, 'variable.response', {'Vm', 'PF'}, 'PLOT.response', {'PF'});
model = daline.rank(data, method, 'variable.response', {'Vm', 'PF'}, 'PLOT.response', {'PF'}, 'PLOT.switch', 0);  % Only output model, containing the model structs of all methods
[model, failedMethod] = daline.rank(data, method, 'variable.response', {'Vm', 'PF'}, 'PLOT.response', {'PF', 'QF'}, 'PLOT.switch', 0);  % Output model and the list of failed method(s). Note whether the methods are failed are determined by whether they have valid outputs for the responses in 'PLOT.response'
[model, failedMethod] = daline.rank(data, method, 'variable.response', {'Vm', 'PF'}, 'PLOT.response', {'PF', 'QF'});  % Output model and the list of failed method(s). Note whether the methods are failed are determined by whether they have valid outputs for the responses in 'PLOT.response'

% opt 1
opt = daline.setopt('variable.response', {'Vm', 'PF'}, 'PLOT.response', {'PF', 'QF'}); % will plot QF, though many methods don't have it in their outputs, except for very few of them, as QF is their mandatory output by theory
[model, failedMethod] = daline.rank(data, method, opt);

%% Theme test
[model, failedMethod] = daline.rank(data, {'TAY', 'QR'}, 'PLOT.response', {'Vm', 'PF', 'Va'}, 'PLOT.theme', 'commercial');
[model, failedMethod] = daline.rank(data, {'TAY', 'QR'}, 'PLOT.response', {'Vm', 'PF', 'Va'}, 'PLOT.theme', 'commercial', 'PLOT.style', 'light');
[model, failedMethod] = daline.rank(data, {'TAY', 'QR'}, 'PLOT.response', {'Vm', 'PF', 'Va'}, 'PLOT.theme', 'commercial', 'PLOT.style', 'light', 'PLOT.pattern', 'joint');
[model, failedMethod] = daline.rank(data, {'TAY', 'QR'}, 'PLOT.response', {'Vm', 'PF', 'Va'}, 'PLOT.theme', 'commercial', 'PLOT.style', 'dark', 'PLOT.pattern', 'joint');  % 'joint' enforces to use the 'academic' theme, which only has a 'light' style
[model, failedMethod] = daline.rank(data, {'TAY', 'QR'}, 'PLOT.response', {'Vm', 'PF', 'Va'}, 'PLOT.theme', 'academic');  
[model, failedMethod] = daline.rank(data, {'TAY', 'QR'}, 'PLOT.response', {'Vm', 'PF', 'Va'}, 'PLOT.theme', 'academic', 'PLOT.style', 'dark');  % 'academic' theme only has a 'light' style, so 'dark' here is meaningless
[model, failedMethod] = daline.rank(data, {'TAY', 'QR'}, 'PLOT.response', {'Vm', 'PF', 'Va'}, 'PLOT.theme', 'academic', 'PLOT.pattern', 'joint'); 
[model, failedMethod] = daline.rank(data, method, 'variable.response', {'Vm', 'PF'}, 'PLOT.response', {'PF'}, 'PLOT.theme', 'academic', 'PLOT.pattern', 'indivi');
[model, failedMethod] = daline.rank(data, method, 'variable.response', {'Vm', 'PF'}, 'PLOT.response', {'PF'}, 'PLOT.theme', 'commercial', 'PLOT.style', 'light');

% opt 1: in 'academic' theme, failure means the method failed all the responses in 'PLOT.response'
opt = daline.setopt('variable.response', {'Vm', 'PF'}, 'PLOT.response', {'Vm', 'PF', 'Va'}, 'PLOT.theme', 'commercial', 'PLOT.style', 'light', 'PLOT.pattern', 'joint'); % 'joint' enforces to use the 'academic' theme, which only has a 'light' style
[model, failedMethod] = daline.rank(data, method, opt);

% opt 2
opt = daline.setopt('variable.response', {'Vm', 'PF'}, 'PLOT.response', {'Vm', 'PF', 'Va'}, 'PLOT.theme', 'commercial', 'PLOT.style', 'light'); % 'joint' enforces to use the 'academic' theme, which only has a 'light' style
[model, failedMethod] = daline.rank(data, method, opt);

%% Comparing methods' accuracy while adjusting their parameters

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