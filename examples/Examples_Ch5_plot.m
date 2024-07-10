%% IMPORTANT: Please don't directly run the whole script; otherwise the following codes will create a lot of figures :p

%% Get data and model
data = daline.data('case.name', 'case9');
model  = daline.fit(data, 'method.name', 'PLS_SIM');

%% Test
daline.plot(model);
daline.plot(model, 'PLOT.response', {'Vm'}, 'PLOT.style', 'light');
daline.plot(model, 'PLOT.response', {'Vm', 'PF'}, 'PLOT.theme', 'academic','PLOT.style', 'light', 'PLOT.pattern', 'joint');
failure = daline.plot(model, 'PLOT.response', {'Vm', 'PF', 'Va'}, 'PLOT.switch', 0);
opt = daline.setopt('PLOT.response', {'Vm', 'PF'}, 'PLOT.theme', 'academic', 'PLOT.pattern', 'indivi');
failure = daline.plot(model, opt);