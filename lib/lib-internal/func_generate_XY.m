function [X, Y, varargout] = func_generate_XY(data)
%% Introduction
% 
%  Generate datasets for inputs and outputs (independent and dependent) 
%  Each field is num_sample-by-num_variable

% Get index

% identify bus types
[ref, pv, pq] = bustypes(data.mpc.bus, data.mpc.gen);
pvq = [pv; pq];
pvr = [pv; ref];

% output index
num_branch = size(data.mpc.branch, 1);
predictorIdx.P   = pvq;
predictorIdx.Q   = pq;
predictorIdx.Vm  = pvr;
predictorIdx.Vm2 = pvr;
predictorIdx.Va  = ref;
responseIdx.Vm   = pq;
responseIdx.Vm2  = pq;
responseIdx.Va   = pvq;
responseIdx.PF   = [1:num_branch]';
responseIdx.PT   = [1:num_branch]';
responseIdx.QF   = [1:num_branch]';
responseIdx.QT   = [1:num_branch]';
responseIdx.P    = ref;
responseIdx.Q    = ref;
if nargout == 3
    varargout{1} = predictorIdx;
elseif nargout == 4
    varargout{1} = predictorIdx;
    varargout{2} = responseIdx;
end

%% Training data X, Y

% build X.train.P: independent variables, known active power injections at pv&pq buses
X.train.P = data.train.P(:, pvq);

% build X.train.Q: independent variables, known reactive power injections at pq buses
X.train.Q = data.train.Q(:, pq);

% build X.train.Vm: independent variables, known voltage magnitudes
X.train.Vm = data.train.Vm(:, pvr);
X.train.Vm2 = data.train.Vm2(:, pvr);

% build X.train.Va: independent variables, known voltage angles
X.train.Va = data.train.Va(:, ref);

% build Y.train.Vm: dependent variables, unknown voltage magnitudes
Y.train.Vm = data.train.Vm(:, pq);
Y.train.Vm2 = data.train.Vm2(:, pq);

% build Y.train.Va: dependent variables, unknown voltage angles
Y.train.Va = data.train.Va(:, pvq);

% build Y.train.PF: dependent variables, unknown F-to-T active flows
Y.train.PF = data.train.PF;

% build Y.train.PT: dependent variables, unknown T-to-F active flows
Y.train.PT = data.train.PT;

% build Y.train.QF: dependent variables, unknown F-to-T reactive flows
Y.train.QF = data.train.QF;

% build Y.train.QT: dependent variables, unknown T-to-F reactive flows
Y.train.QT = data.train.QT;

% build Y.train.P: dependent variables, unknown active power injection at ref bus
Y.train.P = data.train.P(:, ref);

% build Y.train.Q: dependent variables, unknown reactive power injections at ref&pv buses
Y.train.Q = data.train.Q(:, pvr);

% build X.train.all: all independent variables, row number = num.sample
X.train.all = [X.train.P,  ...
               X.train.Q,  ...
               X.train.Vm, ...
               X.train.Va];
X.train.all2 = [X.train.P,  ...   % all2 => replace Vm with Vm^2
                X.train.Q,  ...
                X.train.Vm2, ...
                X.train.Va];
X.train.PQ = [X.train.P,  ...
              X.train.Q];
           
% build Y.train.all: all dependent variables, row number = num.sample
Y.train.all = [Y.train.Vm, ...
               Y.train.Va, ...
               Y.train.PF, ...
               Y.train.PT, ...
               Y.train.QF, ...
               Y.train.QT, ...
               Y.train.P,  ...
               Y.train.Q];
Y.train.all2 = [Y.train.Vm2, ...  % all2 => replace Vm with Vm^2
               Y.train.Va, ...
               Y.train.PF, ...
               Y.train.PT, ...
               Y.train.QF, ...
               Y.train.QT, ...
               Y.train.P,  ...
               Y.train.Q];
Y.train.V   = [Y.train.Vm, ...  % voltages
               Y.train.Va];
Y.train.V2  = [Y.train.Vm2, ...  % V2 => replace Vm with Vm^2
               Y.train.Va];
Y.train.flow =[Y.train.PF, ...  % branch flows
               Y.train.PT, ...
               Y.train.QF, ...
               Y.train.QT];
%% Testing data X, Y

% build X.test.P: independent variables, known active power injections at pv&pq buses
X.test.P = data.test.P(:, pvq);

% build X.test.Q: independent variables, known reactive power injections at pq buses
X.test.Q = data.test.Q(:, pq);

% build X.test.Vm: independent variables, known voltage magnitudes
X.test.Vm  = data.test.Vm(:, pvr);
X.test.Vm2 = data.test.Vm2(:, pvr);

% build X.test.Va: independent variables, known voltage angles
X.test.Va = data.test.Va(:, ref);

% build Y.test.Vm: dependent variables, unknown voltage magnitudes
Y.test.Vm  = data.test.Vm(:, pq);
Y.test.Vm2 = data.test.Vm2(:, pq);

% build Y.test.Va: dependent variables, unknown voltage angles
Y.test.Va = data.test.Va(:, pvq);

% build Y.test.PF: dependent variables, unknown F-to-T active flows
Y.test.PF = data.test.PF;

% build Y.test.PT: dependent variables, unknown T-to-F active flows
Y.test.PT = data.test.PT;

% build Y.test.QF: dependent variables, unknown F-to-T reactive flows
Y.test.QF = data.test.QF;

% build Y.test.QT: dependent variables, unknown T-to-F reactive flows
Y.test.QT = data.test.QT;

% build Y.test.P: dependent variables, unknown active power injection at ref bus
Y.test.P = data.test.P(:, ref);

% build Y.test.Q: dependent variables, unknown reactive power injections at ref&pv buses
Y.test.Q = data.test.Q(:, pvr);

% build X.test.all: all independent variables, row number = num.sample
X.test.all = [ X.test.P,  ...
               X.test.Q,  ...
               X.test.Vm, ...
               X.test.Va];
X.test.all2 = [X.test.P,  ...  % all2 => replace Vm with Vm^2
               X.test.Q,  ...
               X.test.Vm2, ...
               X.test.Va];
X.test.PQ   = [X.test.P,  ...  % Just PQ
               X.test.Q];
           
% build Y.test.all: all dependent variables, row number = num.sample
Y.test.all = [ Y.test.Vm, ...
               Y.test.Va, ...
               Y.test.PF, ...
               Y.test.PT, ...
               Y.test.QF, ...
               Y.test.QT, ...
               Y.test.P,  ...
               Y.test.Q];
Y.test.all2 = [Y.test.Vm2, ...  % all2 => replace Vm with Vm^2
               Y.test.Va, ...
               Y.test.PF, ...
               Y.test.PT, ...
               Y.test.QF, ...
               Y.test.QT, ...
               Y.test.P,  ...
               Y.test.Q];
Y.test.V    = [Y.test.Vm, ...  % all2 => replace Vm with Vm^2
               Y.test.Va];
Y.test.V2   = [Y.test.Vm2, ...  % V2 => replace Vm with Vm^2
               Y.test.Va];
Y.test.PQ   = [Y.test.PF, ...
               Y.test.PT, ...
               Y.test.QF, ...
               Y.test.QT];