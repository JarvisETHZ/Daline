function opt = func_default_option_category(key)
% Define default settings for a category according to the input key
% key: e.g., {'SVR'}, {'system', 'data', 'method'}, {'system', 'SVR'}
% Note: while you can input many key words, but among them, there can only
% be one algorithm, e.g., you can use key = {'system', 'SVR'}, but no
% {'case', 'SVR', 'RR'}. This restriction is to avoid confusion of the
% default parameters for training methods.

% Illustrate all the training methods supported now
methodList = ["LS"; "QR"; "LD"; "LS_PIN"; "PIN"; "LS_SVD"; "SVD"; "LS_COD"; "COD"; "LS_PCA"; "PCA"; "LS_HBW"; "LS_HBLD"; "LS_HBLE"; "LS_GEN"; "LS_LIFX"; "LS_LIFXi"; "LS_TOL"; "LS_CLS"; "LS_WEI"; "LS_REC"; "LS_REP"; "PLS_SIM"; "PLS_SIMRX"; "PLS_NIP"; "PLS_BDL"; "PLS_BDLY2"; "PLS_BDLopen"; "PLS_REC"; "PLS_RECW"; "PLS_REP"; "PLS_CLS"; "RR"; "RR_WEI"; "RR_KPC"; "RR_VCS"; "SVR"; "SVR_POL"; "SVR_CCP"; "SVR_RR"; "LCP_BOXN"; "LCP_BOX"; "LCP_JGDN"; "LCP_JGD"; "LCP_COUN"; "LCP_COUN2"; "LCP_COU"; "LCP_COU2"; "DRC_XM"; "DRC_XYM"; "DRC_XYD"; "DC"; "DC_LS"; "DLPF"; "DLPF_C"; "PTDF"; "TAY"; "OI"];
methodNoIndiviOpt = ["LS"; "QR"; "LD"; "LS_PIN"; "PIN"; "LS_SVD"; "SVD"; "LS_COD"; "COD"; "LS_TOL"; "PLS_SIM"; "PLS_SIMRX"];

% Check for methodList element presence in key
methodIsMember = ismember(key, methodList);
methodCount = sum(methodIsMember);

% Check if more than 1 method from methodList exists in key
% But if more than 45 methods are given => unusual => developer aims to check the option names
if methodCount > 1 && methodCount < 45
    error('To avoid confusion, please only input the name of a single training algorithm at one time.');
end

% If exactly 1 method from methodList is in key, add two global options before it
if methodCount == 1
    methodIdx = find(methodIsMember, 1);  % Find the index of the method in key
    % If the method doesn't have individual settings
    if ismember(key{methodIdx}, methodNoIndiviOpt)
        % Add two elements before the method name
        key = [key{1:methodIdx-1}, {'warning', 'variable'}, key{methodIdx:end}];
        % Remove the method, whose position is now methodIdx + 2
        key(methodIdx+2) = [];
    % If the method has individual settings, keep it
    else
        % Add two elements before the method name
        key = [key{1:methodIdx-1}, {'warning', 'variable'}, key{methodIdx:end}];
    end
    
end

% Iterate the key words in key to collect the default options
for n = 1:length(key)
    % Collect default options accroding to key{n}
    switch key{n}
        case 'system'
            % System case default options
            opt.case.name = 'case39';  % Case name, from the built-in cases in matpower
            opt.mpc = ext2int(loadcase(opt.case.name)); % Get mpc from the case name
            % opt.case.mpc = [];       % Implicit option, accepting external mpc models. User can directly use this option via name-value pairs or opt struct, without needing to make this line active. Please keep this implicit option commented out. 
        case 'generate data'
            % Data generation related default options
            opt.num.trainSample       = 300;          % number of training data points
            opt.num.testSample        = 200;          % number of testing data points
            opt.num.redundant         = 50;           % To add some redundant samples, in case in some scenarios acopf/acpf may fail. But, keep it small, especially for TimeSeries, otherwise the data may not exactly follow the given time window.
            opt.data.program          = 'acpf';       % Use 'acopf' or 'acpf' or 'dcopf_acpf' to generate the data; 'dcopf_acpf': first dcopf to get generations, then do acpf
            opt.data.baseType         = 'TimeSeriesRand';     % 'Random' or 'TimeSeries' or 'TimeSeriesRand'. 'Random': totally random generation (not very realistic), 'TimeSeries': observations are correlated in time (realistic), 'TimeSeriesRand': observations are correlated in time, but with randomness (more realistic)
            opt.data.parallel         = 1;            % 1: use parallel computation to speed up, otherwise 0 
            opt.data.curvePlot        = 0;            % 1: plot the load curve when 'TimeSeries' or 'TimeSeriesRand' is selected; 0: don't plot
            opt.data.fixRand          = 0;            % 1: fix the randomness when generate data, otherwise 0.
            opt.data.fixSeed          = 88;           % The seed to fix the randomness;
            opt.load.distribution     = 'uniform';    % 'uniform' or 'normal', distributon of the randomness for the loading; note that for 'normal', the upper and lower bounds cannot be strictly satisfied, although the upper and lower bounds can still influence the magnitude of the variations 
            opt.load.amplifyFactor    = 0.9;          % each nodal load will be multiplied with this factor to regulate the overall load level
            opt.load.smallValue       = 0.05;         % each nodal load will be added with this value to avoid all-zero power injections in all samples
            opt.load.upperRange       = 1.2;          % In 'Random', each nodal load will randomly change within this range; basis is the original load 
            opt.load.lowerRange       = 0.8;          % In 'Random', each nodal load will randomly change within this range; basis is the original load 
            opt.load.upperRangeTime   = 1.05;         % In 'TimeSeriesRand', each nodal load will randomly change within this range; basis is the loadCurve
            opt.load.lowerRangeTime   = 0.95;         % In 'TimeSeriesRand', each nodal load will randomly change within this range; basis is the loadCurve
            opt.load.baseLoadCurve    = [1.0300,0.99440,0.96140,0.93070,0.90230,0.87640,0.85290,0.83180,0.81300,0.79430,0.78060,0.78240,0.78860,0.79310,0.79780,0.81210,0.84070,0.86560,0.88990,0.91780,0.94860,0.97180,0.98990,1.0142,1.0458,1.0703,1.0887,1.1117,1.1421,1.1488,1.1384,1.1256,1.1107,1.0954,1.0800,1.0668,1.0544,1.0504,1.0594,1.0723,1.0808,1.1000,1.1200,1.086,1.0853,1.0797,1.0678,1.0500];   % In 'TimeSeries' or 'TimeSeriesRand', default daily baseLoadCurve with 48 points from 0:00 to 23:30 will be used  => national hourly load curve of French on Aug.16, 2023, see https://www.services-rte.com/en/view-data-published-by-rte/daily-load-curves.html
            opt.load.timeStart        = '19:00';      % In 'TimeSeries' or 'TimeSeriesRand', start for the time window. Resolution: half hour. timeStart can be later than timeEnd, e.g., '23:00 - 2:00'
            opt.load.timeEnd          = '22:00';      % In 'TimeSeries' or 'TimeSeriesRand', end for a time window. Resolution: half hour. 
            opt.voltage.varyIndicator =  0;           % 1 - randomly change voltage magnitudes of PV buses, 0 - no change. Note: in acopf, respect the voltage magnitudes of generators might lead to inconvergeed solution
            opt.voltage.distribution  = 'uniform';    % 'uniform' or 'normal', distributon of the randomness for the voltage magnitude of PV buses; ; note that for 'normal', the upper and lower bounds cannot be strictly satisfied, although the upper and lower bounds can still influence the magnitude of the variations
            opt.voltage.upperRange    =  0.05;        % each voltage magnitude at the pv bus will be added with a random change within this range; basis is the original magnitude;
            opt.voltage.lowerRange    = -0.05;        % each voltage magnitude at the pv bus will be added with a random change within this range; basis is the original magnitude;
            opt.voltage.refAngle      = 10;           % the ref angle of the slack bus will be added with this small value to avoid an all-zero reference angle in all samples
            opt.gen.varyIndicator     = 1;            % in ACPF, 1: changes power generations using the same scale of loading changes; 0: don't change 
            opt.gen.smallValue        = 0.08;         % in ACPF, each generator will be added with this value when simultaneously change generators' outputs with loadings; this value should be greater than opt.load.smallValue, otherwise there still could be all-zero injection
        case 'add outlier'
            % Adding outlier related default options
            opt.data.fixRand          = 0;            % 1: fix the randomness when generate data, otherwise 0.
            opt.data.fixSeed          = 88;           % The seed to fix the randomness;
            opt.outlier.switchTrain   = 0;            % For training data, 0: add no noise; 1: add outliers.
            opt.outlier.switchTest    = 0;            % For testing data, 0: add no noise; 1: add outliers.
            opt.outlier.percentage    = 5;            % percentage of outliers. Unit: %. Add outliers randomly for each feature. So be care. If the ratio is slightly large, basically all observations will contain outliers. BUT: if the rand seed is fixed, the outlier will show up in the same row => 5% individual will be 5% overall. 
            opt.outlier.factor        = 2;            % this factor will be multiplied with original measurements to create outliers
        case 'add noise'
            % Adding noise related default options
            opt.data.fixRand          = 0;            % 1: fix the randomness when generate data, otherwise 0.
            opt.data.fixSeed          = 88;           % The seed to fix the randomness;
            opt.noise.switchTrain     = 0;            % For training data, 0: add no noise; 1: add white Gaussian noise.
            opt.noise.switchTest      = 0;            % For testing data, 0: add no noise; 1: add white Gaussian noise.
            opt.noise.SNR_dB          = 45;           % Unit: dB; 45 is suggested by "Characterizing and Quantifying Noise in PMU data."    
        case 'filter outlier'
            % Filtering outlier related default options
            opt.filOut.switchTrain    = 0;            % For training data, 1: filter outliers when opt.outlier.switch = 1; otherwise no filter
            opt.filOut.switchTest     = 0;            % For testing data, 1: filter outliers when opt.outlier.switch = 1; otherwise no filter
            opt.filOut.method         = 'quartiles';  % Filter methods: 'median', 'mean', 'quartiles', 'grubbs'
            opt.filOut.tol            = 5;            % A larger value leads to a less number of outliers
        case 'filter noise'
            % Filtering noise related default options
            opt.filNoi.switchTrain    = 0;            % For training data, 1: filter outliers when opt.noise.switch = 1; otherwise no filter
            opt.filNoi.switchTest     = 0;            % For testing data, 1: filter outliers when opt.noise.switch = 1; otherwise no filter
            opt.filNoi.orderNum       = 5;            % Number of AR order to estimate the dynamic of observations in Kalman filter
            opt.filNoi.est_dB         = 45;           % Unit: dB; estimation of the noise degree
            opt.filNoi.useARModel     = false;        % True: use ARModel to capture the dynamic of observations, i.e. A; otherwise false, A would be an identity matrix. We suggest false.
            opt.filNoi.proNoiseLevel  = 100;          % Noise level of the process noise => Q would be eye * proNoiseLevel
            opt.filNoi.zeroInitial    = 0;            % 1: initialize X_est as zero in Kalman filter, otherwise 0 => X_est would be the first original observation.
        case 'normalize data'
            % Data normalization related default options
            opt.norm.switch           = 0;            % 0: do not do unit energy normalization; 1: do unit energy normalization
        case 'mpc index'
            % Index definition for system cases
            opt.idx                   = func_define_idx; % Built-in index in matpower
        case 'method'
            % Method selection
            opt.method.name           = 'QR';         % Default method;
            opt.method.entireList     = methodList;   % All training methods currently supported
        case 'warning'
            % Turn warning on/off for all methods 
            opt.warning.switch        = 1;            % 1: warning off for all, including parfor loop workers; 0 otherwise
        case 'variable'
            % Global variable settings for all methods
            opt.variable.predictor      = {'P', 'Q', 'Vm2', 'Va'};   % Selection of predictors, e.g., {'P', 'Q', 'Vm2'}, or {'PQ'}
            opt.variable.response       = {'Vm2', 'Va', 'PF', 'PT', 'QF', 'QT', 'P', 'Q'};      % Selection of responses, e.g., {'Vm', 'Va'}, or {'PF', 'QF'}, or {'flow'}, or {'V'}
            opt.variable.Vm22Vm         = 1;            % 1: Use Vm2 for training, but show the error, prediction, and testing data of Vm rather than Vm2 in the final testing result, otherwise 0.
            opt.variable.lift           = 0;            % 1: lift the dimension of predictors, otherwise 0
            opt.variable.liftX          = 1;            % 1: use the lift method defined in paper "Koopman operator meets model predictive control"; 0: 1: use the lift method defined in paper "Data-driven power flow calculation method: A lifting dimension linear regression approach"
            opt.variable.liftFixC       = 1;            % Dimension lift. 1: fix the randomness of C, otherwise 0
            opt.variable.liftNumDim     = [];           % Dimension lift. []: the number of lifted dimensions would be equal to the dimension of input X; otherwise, input the perferred number. 
            opt.variable.liftEps        = 1;            % Dimension lift. Hyperparameter in the lifting functions 'gauss' and 'invquad'
            opt.variable.liftK          = 1;            % Dimension lift. Hyperparameter in the lifting function 'polyharmonic'
            opt.variable.liftType       = 'gauss';      % Dimension lift. Type of lifting functions: 'gauss', 'invquad_ref', 'invmultquad_ref', 'invquad', 'polyharmonic_ref', 'thinplate', 'invmultquad',  'polyharmonic'
        case 'LS_REC'
            % Recursive least squares
            opt.LSR.recursivePercentage = 40;         % Percentage of new data to the training dataset. Each new data will be learnt recursively.
            opt.LSR.initializeP         = 0;          % 1: initialize P with a large value, otherwise 0
            opt.LSR.largeValueP         = 1e6;        % Large value for initializing P
            opt.LSR.forgetFactor        = 0.99;       % Forgetting factor for recursive LS
        case 'LS_REP'
            % Repeated least squares 
            opt.LSR.recursivePercentage = 40;         % Percentage of new data to the training dataset. Each new data will be learnt recursively.
        case 'LS_GEN'
            % Generalized least squares
            opt.LSG.parallel            = 1;          % 1: use parallel computation to speed up, otherwise 0
            opt.LSG.InnovMdl            = 'AR';       % Model for the innovations covariance estimate, e.g., 'AR', 'CLM', 'HC0', 'HC1', 'HC2', 'HC3', 'HC4', see https://www.mathworks.com/help/econ/fgls.html
        case {'LS_PCA', 'PCA'}
            % Principal component analysis and least squares with principal component analysis
            opt.PCA.parallel     = 1;             % 1: use parallel computation to speed up, otherwise 0
            opt.PCA.rank         = 0;             % 1: use the rank of X as the number of components; 0: tune PerComponent; 
            opt.PCA.PerComponent = [40:10:80];    % Unit: %, i.e., the ratio of the principal component number w.r.t. the predictor number. If is a vector, e.g., [20:10:80], then the toolbox will directly find the best percentage using cross-validation based on parallelization; if is a value, then it will be used directly.
            opt.PCA.numFold      = 5;             % Number of fold for cross validation
            opt.PCA.fixCV        = 1;             % 1: fix the random partition for cross validation, otherwise 0
            opt.PCA.fixSeed      = 88;            % Fixed random seed to fix CV partition
        case 'LS_LIFX'
            % Least squares with lifting function by lifting the whole X
            opt.variable.lift           = 1;            % 1: lift the dimension of predictors, otherwise 0
            opt.variable.liftX          = 1;            % 1: use the lift method defined in paper "Koopman operator meets model predictive control"; 0: 1: use the lift method defined in paper "Data-driven power flow calculation method: A lifting dimension linear regression approach"
            opt.variable.liftFixC       = 1;            % Dimension lift. 1: fix the randomness of C, otherwise 0
            opt.variable.liftNumDim     = [];           % Dimension lift. []: the number of lifted dimensions would be equal to the dimension of input X; otherwise, input the perferred number. 
            opt.variable.liftEps        = 1;            % Dimension lift. Hyperparameter in the lifting functions 'gauss' and 'invquad'
            opt.variable.liftK          = 1;            % Dimension lift. Hyperparameter in the lifting function 'polyharmonic'
            opt.variable.liftType       = 'gauss';      % Dimension lift. Type of lifting functions: 'gauss', 'invquad_ref', 'invmultquad_ref', 'invquad', 'polyharmonic_ref', 'thinplate', 'invmultquad',  'polyharmonic'
        case 'LS_LIFXi'
            % Least squares with lifting function by lifting the i-element of X
            opt.variable.lift           = 1;            % 1: lift the dimension of predictors, otherwise 0
            opt.variable.liftX          = 0;            % 1: use the lift method defined in paper "Koopman operator meets model predictive control"; 0: 1: use the lift method defined in paper "Data-driven power flow calculation method: A lifting dimension linear regression approach"
            opt.variable.liftFixC       = 1;            % Dimension lift. 1: fix the randomness of C, otherwise 0
            opt.variable.liftNumDim     = [];           % Dimension lift. []: the number of lifted dimensions would be equal to the dimension of input X; otherwise, input the perferred number. 
            opt.variable.liftEps        = 1;            % Dimension lift. Hyperparameter in the lifting functions 'gauss' and 'invquad'
            opt.variable.liftK          = 1;            % Dimension lift. Hyperparameter in the lifting function 'polyharmonic'
            opt.variable.liftType       = 'gauss';      % Dimension lift. Type of lifting functions: 'gauss', 'invquad_ref', 'invmultquad_ref', 'invquad', 'polyharmonic_ref', 'thinplate', 'invmultquad',  'polyharmonic'
        case 'LS_HBW'
            % Least squares with Huber weighting function
            opt.HBW.TuningConst       = 1:0.1:1.4;  % 1.345 Tuning constant; if a scalar (suggest 1.345), use it; if a vector: automatic tuning; 
            opt.HBW.parallel          = 1;          % 1: use parallel computation to speed up, otherwise 0
            opt.HBW.PCA               = 1;          % 1: turn PCA to reduce colinearity
            opt.HBW.numComponentRatio = 70;         % Used in PCA (no automatic tuning here) to reduce collinearity; Unit: %, i.e., the ratio of the principal component number w.r.t. the predictor number 
            opt.HBW.numFold           = 5;          % Number of fold for cross validation
            opt.HBW.fixCV             = 1;          % 1: fix the random partition for cross validation, otherwise 0
            opt.HBW.fixSeed           = 88;         % Fixed random seed to fix CV partition
        case 'LS_HBLD'
            % Least squares with Huber loss function, directly solve the problem 
            opt.HBL.parallel      = 1;                        % 1: use parallel computation to speed up, otherwise 0
            opt.HBL.delta         = 0.02;                     % Delta, e.g., 0.02:0.002:0.03 or 0.05; if a vector, automatically find the best one; if a scalar, use it
            opt.HBL.initialGuess  = 0;                        % Initial guess for coefficients (here all 0 by default, you can choose a different starting point)
            opt.HBL.directOptions = optimoptions('fminunc', 'Display', 'off', 'Algorithm', 'quasi-newton');  % Set parameters for calling fminunc to solve the regression problem ('fminunc' is built in the MATLAB Optimization Toolbox)
            opt.HBL.numFold       = 5;                        % Number of fold for cross validation
            opt.HBL.fixCV         = 1;                        % 1: fix the random partition for cross validation, otherwise 0
            opt.HBL.fixSeed       = 88;                       % Fixed random seed to fix CV partition
        case 'LS_HBLE'
            % Least squares with Huber loss function, solve an equivalent problem
            opt.HBL.parallel      = 1;                        % 1: use parallel computation to speed up, otherwise 0
            opt.HBL.programType   = 'indivi';                 % 'whole' or 'indivi'; 'whole': put all responses into one program and solve; 'indivi': put one response into one program and solve
            opt.HBL.language      = 'yalmip';                 % 'cvx' or 'yalmip'; 'cvx'/'yalmip': use cvx/yalmip to formulate the programming problem;   
            opt.HBL.solver        = 'fmincon';                % Solver options, e.g., 'fmincon', 'quadprog', 'Gurobi' ('quadprog' and 'fmincon' are built in the MATLAB Optimization Toolbox; for 'Gurobi', you need to install it manually).
            opt.HBL.delta         = 0.02;                     % Delta, e.g., 0.02:0.002:0.03 or 0.05; if a vector, automatically find the best one; if a scalar, use it
            opt.HBL.cvxQuiet      = 1;                        % 1: Suppress CVX output in the commander window, otherwise 0.
            opt.HBL.yalDisplay    = 0;                        % 0: no yalmip display, 1: yalmip display.
            opt.HBL.numFold       = 5;                        % Number of fold for cross validation
            opt.HBL.fixCV         = 1;                        % 1: fix the random partition for cross validation, otherwise 0
            opt.HBL.fixSeed       = 88;                       % Fixed random seed to fix CV partition
        case 'LS_WEI'
            % Least squares with weights
            opt.LSW.omega         = 0.6;           % Weight value from 0 to 1; 0.6 borrowed from Data-Driven Voltage Regulation in Radial Power Distribution Systems
            opt.LSW.cvxQuiet      = 1;             % 1: Suppress CVX output in the commander window, otherwise 0.
            opt.LSW.solver        = 'SeDuMi';      % Solver options, e.g., 'quadprog', 'Mosek', 'Gurobi', 'SDPT3', 'SeDuMi'   ('SDPT3' and 'SeDuMi' are included in Daline via CVX; 'quadprog' and 'fmincon' are built in the MATLAB Optimization Toolbox; for 'Gurobi', you need to install it manually).
            opt.LSW.parallel      = 1;             % 1: use parallel computation to speed up, otherwise 0
            opt.LSW.programType   = 'whole';       % 'whole' or 'indivi'; 'whole': put all responses into one program and solve; 'indivi': put one response into one program and solve
            opt.LSW.language      = 'cvx';         % 'cvx' or 'yalmip'; 'cvx'/'yalmip': use cvx/yalmip to formulate the programming problem;   
            opt.LSW.yalDisplay    = 0;             % 0: no yalmip display, 1: yalmip display. 
        case 'LS_CLS'
            % Ordinary least squares with clustering
            opt.LSC.parallel            = 1;               % 1: use parallel computation to speed up, otherwise 0
            opt.LSC.fixKmeans           = 1;               % 1: fix the random seed for kmeans so that the clustering result stays the same for the same dataset
            opt.LSC.fixSeed             = 88;              % Seed to fix the randomness
            opt.LSC.fixCV               = 1;               % 1: fix the random partition for cross validation, otherwise 0
            opt.LSC.clusNumInterval     = 2:1:10;          % E.g., 2:1:10, the discrete interval of the number of cluster, used for tuning; if only one integer is given, the cluster number is then fixed as this value
            opt.LSC.cvNumFold           = 5;              % The number of folds for cross-validation to tune hyperparameters. This number must be divisible by the number of training samples
        case 'LS_LIF'
            % Ordinary least squares with dimension lifting; although other methods also have these parameters, here the dimension must be lifted
            opt.variable.lift           = 'Fixed: must be turned on'; % 1: lift the dimension of predictors, otherwise 0
            opt.variable.liftX          = 1;            % 1: use the lift method defined in paper "Koopman operator meets model predictive control"; 0: 1: use the lift method defined in paper "Data-driven power flow calculation method: A lifting dimension linear regression approach"
            opt.variable.liftFixC       = 1;            % Dimension lift. 1: fix the randomness of C, otherwise 0
            opt.variable.liftNumDim     = [];           % Dimension lift. []: the number of lifted dimensions would be equal to the dimension of input X; otherwise, input the perferred number. 
            opt.variable.liftEps        = 1;            % Dimension lift. Hyperparameter in the lifting functions 'gauss' and 'invquad'
            opt.variable.liftK          = 1;            % Dimension lift. Hyperparameter in the lifting function 'polyharmonic'
            opt.variable.liftType       = 'gauss';      % Dimension lift. Type of lifting functions: 'gauss', 'invquad_ref', 'invmultquad_ref', 'invquad', 'polyharmonic_ref', 'thinplate', 'invmultquad',  'polyharmonic'
        case 'PLS_NIP'
            % Ordinary partial least squares, using NIPALS algorithm
            opt.PLS.outerTol            = 1e-12;           % The tolerance for stopping the outer iteration of NIPALS, should be very small
            opt.PLS.innerTol            = 1e-12;           % The tolerance for stopping the inner iteration of NIPALS, should be very small
        case {'PLS_BDL','PLS_BDLY2'}
            % Partial least squares with bundling known and unknown variables
            opt.variable.predictor  = 'Fixed: Vm, P, Q'; % Fixed predictors because of the method
            opt.variable.response   = 'Fixed: Vm, Va, P, Q, PF, PT, QF, QT'; % Fixed responses because of the method
        case 'PLS_BDLopen'
            % Partial least squares with bundling known and unknown variables
            opt.variable.predictor  = 'Fixed: P, Q'; % Fixed predictors because of the method
            opt.variable.response   = 'Fixed: Vm, Va'; % Fixed responses because of the method
        case {'PLS_REC', 'PLS_REP'}
            % Recursive/repeated partial least squares, using NIPALS algorithm
            opt.PLS.recursivePercentage = 40;              % Percentage of new data to the training dataset. Each new data will be learnt recursively.
            opt.PLS.outerTol            = 1e-9;           % The tolerance for stopping the outer iteration of NIPALS, should be very small
            opt.PLS.innerTol            = 1e-9;           % The tolerance for stopping the inner iteration of NIPALS, should be very small
        case 'PLS_RECW'
            % Recursive weighted partial least squares, using NIPALS algorithm
            opt.PLS.omega               = 0.6;            % Weight value; 0.6 is from Measurement-Based Optimal DER Dispatch With a Recursively Estimated Sensitivity Model
            opt.PLS.recursivePercentage = 40;              % Percentage of new data to the training dataset. Each new data will be learnt recursively.
            opt.PLS.outerTol            = 1e-9;           % The tolerance for stopping the outer iteration of NIPALS, should be very small
            opt.PLS.innerTol            = 1e-9;           % The tolerance for stopping the inner iteration of NIPALS, should be very small
        case 'PLS_CLS'
            % Ordinary partial least squares with clustering
            opt.PLS.parallel            = 1;               % 1: use parallel computation to speed up, otherwise 0
            opt.PLS.fixKmeans           = 1;               % 1: fix the random seed for kmeans so that the clustering result stays the same for the same dataset
            opt.PLS.fixCV               = 1;               % 1: fix the random partition for cross validation, otherwise 0
            opt.PLS.fixSeed             = 88;              % Seed to fix the randomness
            opt.PLS.clusNumInterval     = 2:1:10;          % E.g., 2:1:10, the discrete interval of the number of cluster, used for tuning; if only one integer is given, the cluster number is then fixed as this value
            opt.PLS.cvNumFold           = 5;               % The number of folds for cross-validation to tune hyperparameters. This number must be divisible by the number of training samples
        case 'RR'
            % Ordinary ridge regression
            opt.RR.cvNumFold           = 5;                 % The number of folds for cross-validation to tune hyperparameters, e.g., lambda, tau (in RR_LW), etc. This number must be divisible by the number of training samples
            opt.RR.fixCV               = 1;                 % 1: fix the random partition for cross validation, otherwise 0
            opt.RR.fixSeed             = 88;                % Seed to fix the randomness
            opt.RR.lambdaInterval      = 1e-10;             % E.g., 0:1e-3:0.02, the discrete interval of lambda; usually should be very small; just give one scalar value if you want to fix this hyperparameter
        case 'RR_WEI'
            % Locally Weighted ridge regression
            opt.RR.cvNumFold      = 5;                  % The number of folds for cross-validation to tune hyperparameters, e.g., lambda, tau (in RR_LW), etc. This number must be divisible by the number of training samples
            opt.RR.fixCV          = 1;                  % 1: fix the random partition for cross validation, otherwise 0
            opt.RR.fixSeed        = 88;                 % Seed to fix the randomness
            opt.RR.lambdaInterval = 1e-10;              % E.g., 0:1e-3:0.02, the discrete interval of lambda; usually should be very small; just give one scalar value if you want to fix this hyperparameter
            opt.RR.tauInterval    = 0.1:1e-2:0.35;      % The discrete interval of tau, used in the locally weighting ridge regression; just give one scalar value if you want to fix this hyperparameter
        case 'RR_KPC'
            % Ordinary ridge regression with k-plane clustering
            opt.RR.cvNumFold      = 5;                  % The number of folds for cross-validation to tune hyperparameters, e.g., lambda, tau (in RR_LW), etc. This number must be divisible by the number of training samples
            opt.RR.fixCV          = 1;                  % 1: fix the random partition for cross validation, otherwise 0
            opt.RR.fixSeed        = 88;                 % Seed to fix the randomness
            opt.RR.kplaneMaxIter  = 1e5;                % The maximum number of iteration for the ridge regression with k-plane clustering; usually, this method converges within 10 iterations.
            opt.RR.lambdaInterval = 1e-10;              % E.g., 0:1e-3:0.02, the discrete interval of lambda; usually should be very small; just give one scalar value if you want to fix this hyperparameter
            opt.RR.etaInterval    = logspace(2, 5, 4);  % E.g., 1000, logspace(-3, 3, 7), logspace(2, 5, 4), the discrete interval of eta for the ridge regression with k-plane clustering; just give one scalar value if you want to fix this hyperparameter
            opt.RR.fixKmeans      = 1;                  % 1: fix the random seed for kmeans so that the clustering result stays the same for the same dataset
            opt.RR.fixSeed        = 88;                 % Seed to fix the randomness
            opt.RR.clusNumInterval= 2:1:10;             % E.g., 2:1:10, the discrete interval of the number of cluster, used for tuning; if only one integer is given, the cluster number is then fixed as this value
        case 'RR_VCS'
            % Ordinary ridge regression with coordinate transformation: VCS
            opt.idx               = func_define_idx;    % Built-in index in matpower
            opt.RR.cvNumFold      = 5;                  % The number of folds for cross-validation to tune hyperparameters, e.g., lambda, tau (in RR_LW), etc. This number must be divisible by the number of training samples
            opt.RR.fixCV          = 1;                  % 1: fix the random partition for cross validation, otherwise 0
            opt.RR.fixSeed        = 88;                 % Seed to fix the randomness
            opt.RR.lambdaInterval = 1e-10;              % E.g., 0:1e-3:0.02, the discrete interval of lambda; usually should be very small; just give one scalar value if you want to fix this hyperparameter
            opt.variable.predictor  = 'Fixed: Vm2, P, Q'; % Fixed predictors because of the method
            opt.variable.response   = 'Fixed: Vm2, VmiVmjCosij, VmiVmjSinij'; % Fixed responses because of the method
        case 'SVR'
            % Ordinary support vector regression
            opt.SVR.epsilon       = 1e-4;       % A predefined epsilon value
            opt.SVR.omega         = 10;         % Set the regularization parameter omega
            opt.SVR.language      = 'yalmip';   % 'cvx' or 'yalmip'; 'cvx'/'yalmip': use cvx/yalmip to formulate the programming problem;   
            opt.SVR.programType   = 'indivi';   % only support 'indivi' currently; 'whole': put all responses into one program and solve; 'indivi': put one response into one program and solve
            opt.SVR.parallel      = 1;          % 1: use parallel computation to speed up, otherwise 0
            opt.SVR.cvxQuiet      = 1;          % 1: Suppress CVX output in the commander window, otherwise 0.
            opt.SVR.yalDisplay    = 0;          % 0: no yalmip display, 1: yalmip display.
            opt.SVR.solver        = 'quadprog'; % Solver options: 'quadprog', 'Gurobi' ('quadprog' is built in the MATLAB Optimization Toolbox; for 'Gurobi', you need to install it manually).
        case 'SVR_POL'
            % Using built-in solver for ordinary support vector regression with quadratic polynomial kernel
            opt.SVR.parallel      = 1;          % 1: use parallel computation to speed up, otherwise 0
            opt.SVR.tune          = 0;          % 1: automatically tune epsilon using hyperparameter optimization via cross validation, otherwise 0
            opt.SVR.KFold         = 5;          % When opt.SVR.tune = 1, you need to specify the number of folds for cross validation
            opt.SVR.default       = 1;          % 1: use the default epsilon, iqr(y)/1.349, otherwise 0
            opt.SVR.epsilon       = 1e-4;       % A predefined epsilon when opt.SVR.tune and opt.SVR.default are both 0
        case 'SVR_RR'
            % Ordinary support vector regression with ridge regression
            opt.SVR.epsilon       = 1e-4;       % A predefined epsilon value
            opt.SVR.omega         = 10;         % When directly solving the programing, set the regularization parameter omega
            opt.SVR.language      = 'yalmip';   % 'cvx' or 'yalmip'; 'cvx'/'yalmip': use cvx/yalmip to formulate the programming problem;   
            opt.SVR.programType   = 'indivi';   % only support 'indivi' currently; 'whole': put all responses into one program and solve; 'indivi': put one response into one program and solve
            opt.SVR.parallel      = 1;          % 1: use parallel computation to speed up, otherwise 0
            opt.SVR.cvxQuiet      = 1;          % 1: Suppress CVX output in the commander window, otherwise 0.
            opt.SVR.yalDisplay    = 0;          % 0: no yalmip display, 1: yalmip display.
            opt.SVR.solver        = 'quadprog'; % Solver options: 'quadprog', 'Gurobi' ('quadprog' is built in the MATLAB Optimization Toolbox; for 'Gurobi', you need to install it manually).
            opt.SVR.lambda        = 1e-4;       % The regularization factor for the ridge regression part. 
            opt.SVR.PCA           = 1;          % 1: turn PCA to reduce colinearity
            opt.SVR.numComponentRatio = 70;     % Used in PCA (no automatic tuning here) to reduce collinearity; Unit: %, i.e., the ratio of the principal component number w.r.t. the predictor number 
        case 'SVR_CCP'
            % Support vector regression solved by chance-constrained programming
            opt.SVRCC.epsilon       = 1e-4;       % Must be large to find a solution for unnormalized data. 
            opt.SVRCC.omega         = 10;         % When directly solving the programing, set the regularization parameter omega
            opt.SVRCC.language      = 'yalmip';   % Only support 'yalmip', to avoid extra settings of cvx for gurobi;
            opt.SVRCC.programType   = 'indivi';   % Highly recommand 'indivi'; 'whole' or 'indivi'; 'whole': put all responses into one program and solve; 'indivi': put one response into one program and solve
            opt.SVRCC.parallel      = 1;          % 1: use parallel computation to speed up, otherwise 0
            opt.SVRCC.cvxQuiet      = 1;          % 1: Suppress CVX output in the commander window, otherwise 0.
            opt.SVRCC.yalDisplay    = 0;          % 0: no yalmip display, 1: yalmip display.
            opt.SVRCC.solver        = 'Gurobi';   % Solver options: 'Gurobi', for chance-constrained SVR, we suggest Gurobi only (for 'Gurobi', you need to install it manually).
            opt.SVRCC.probThreshold = 95;         % the probability threshold of the chance-contrained programing to solve SVR, unit: %
            opt.SVRCC.bigM          = 1e6;        % the value of big M when using chance-contrained programing to solve SVR
        case 'LCP_BOX'
            % Linearly constrained programming with box constraints
            opt.LCP.cvxQuiet        = 1;                % 1: Suppress CVX output in the commander window, otherwise 0.
            opt.LCP.solver          = 'SeDuMi';         % Solver options: 'quadprog', 'Gurobi', 'SDPT3', 'SeDuMi' ('SDPT3' and 'SeDuMi' are included in Daline via CVX; 'quadprog' is built in the MATLAB Optimization Toolbox; for 'Gurobi', you need to install it manually).
            opt.variable.predictor  = 'Fixed: P, Q';    % Fixed predictors because of the method
            opt.variable.response   = 'Fixed: Vm, Va';  % Fixed responses because of the method
        case 'LCP_BOXN'
            % Linearly constrained programming without box constraints
            opt.LCP.cvxQuiet        = 1;                % 1: Suppress CVX output in the commander window, otherwise 0.
            opt.LCP.solver          = 'SeDuMi';         % Solver options: 'quadprog', 'Gurobi', 'SDPT3', 'SeDuMi' ('SDPT3' and 'SeDuMi' are included in Daline via CVX; 'quadprog' is built in the MATLAB Optimization Toolbox; for 'Gurobi', you need to install it manually).
            opt.variable.predictor  = 'Fixed: P, Q';    % Fixed predictors because of the method
            opt.variable.response   = 'Fixed: Vm, Va';  % Fixed responses because of the method
        case 'LCP_JGD'
            % Linearly constrained programming with Jacobian guide constraints
            opt.LCP.cvxQuiet        = 1;               % 1: Suppress CVX output in the commander window, otherwise 0.
            opt.LCP.solver          = 'Fixed: SDPT3';  % Fixed solver; otherwise cannot find a solution  ('SDPT3' is included in Daline via CVX).
            opt.variable.predictor  = 'Fixed: P, Q';   % Fixed predictors because of the method
            opt.variable.response   = 'Fixed: Vm, Va'; % Fixed responses because of the method
        case 'LCP_JGDN'
            % Linearly constrained programming without Jacobian guide constraints
            opt.LCP.cvxQuiet        = 1;               % 1: Suppress CVX output in the commander window, otherwise 0.
            opt.LCP.solver          = 'Fixed: SDPT3';  % Fixed solver; otherwise cannot find a solution  ('SDPT3' is included in Daline via CVX).
            opt.variable.predictor  = 'Fixed: P, Q';   % Fixed predictors because of the method
            opt.variable.response   = 'Fixed: Vm, Va'; % Fixed responses because of the method
        case 'LCP_COU'
            % Linearly constrained programming with couple constraints
            opt.idx                 = func_define_idx;         % Built-in index in matpower
            opt.LCP.cvxQuiet        = 1;                       % 1: Suppress CVX output in the commander window, otherwise 0.
            opt.LCP.coupleDelta     = 1e-2;                    % Small values to define the coupling constraints
            opt.LCP.solver          = 'quadprog';              % Solver options: 'quadprog', 'Gurobi', 'SDPT3', 'SeDuMi' ('SDPT3' and 'SeDuMi' are included in \LaTeXstyle{Daline} via CVX; 'quadprog' is built in the MATLAB Optimization Toolbox; for 'Gurobi', you need to install it manually) 
            opt.variable.predictor  = 'Fixed: Va, Vm';         % Fixed predictors because of the method
            opt.variable.response   = 'Fixed: PF, PT, QF, QT'; % Fixed responses because of the method
        case 'LCP_COUN'
            % Linearly constrained programming without couple constraints
            opt.idx                 = func_define_idx;         % Built-in index in matpower
            opt.LCP.cvxQuiet        = 1;                       % 1: Suppress CVX output in the commander window, otherwise 0.
            opt.LCP.solver          = 'quadprog';              % Solver options: 'quadprog', 'Gurobi', 'SDPT3', 'SeDuMi' ('SDPT3' and 'SeDuMi' are included in \LaTeXstyle{Daline} via CVX; 'quadprog' is built in the MATLAB Optimization Toolbox; for 'Gurobi', you need to install it manually)
            opt.variable.predictor  = 'Fixed: Va, Vm';         % Fixed predictors because of the method
            opt.variable.response   = 'Fixed: PF, PT, QF, QT'; % Fixed responses because of the method
        case 'LCP_COU2'
            % Linearly constrained programming with couple constraints
            opt.idx                 = func_define_idx;         % Built-in index in matpower
            opt.LCP.cvxQuiet        = 1;                       % 1: Suppress CVX output in the commander window, otherwise 0.
            opt.LCP.coupleDelta     = 1e-2;                    % Small values to define the coupling constraints
            opt.LCP.solver          = 'quadprog';              % Solver options: 'quadprog', 'Gurobi', 'SDPT3', 'SeDuMi' ('SDPT3' and 'SeDuMi' are included in \LaTeXstyle{Daline} via CVX; 'quadprog' is built in the MATLAB Optimization Toolbox; for 'Gurobi', you need to install it manually)
            opt.variable.predictor  = 'Fixed: Va, Vm2';        % Fixed predictors because of the method
            opt.variable.response   = 'Fixed: PF, PT, QF, QT'; % Fixed responses because of the method
        case 'LCP_COUN2'
            % Linearly constrained programming without couple constraints
            opt.idx                 = func_define_idx;         % Built-in index in matpower
            opt.LCP.cvxQuiet        = 1;                       % 1: Suppress CVX output in the commander window, otherwise 0.
            opt.LCP.solver          = 'quadprog';              % Solver options: 'quadprog', 'Gurobi', 'SDPT3', 'SeDuMi' ('SDPT3' and 'SeDuMi' are included in \LaTeXstyle{Daline} via CVX; 'quadprog' is built in the MATLAB Optimization Toolbox; for 'Gurobi', you need to install it manually)
            opt.variable.predictor  = 'Fixed: Va, Vm2';        % Fixed predictors because of the method
            opt.variable.response   = 'Fixed: PF, PT, QF, QT'; % Fixed responses because of the method
        case 'DRC_XM'
            % Distributionally robust chance-constrained programming, moment based, consider X as random variable
            opt.DRC.gamma1        = 0;             % SDP parameter, reflects own risk preference, from "Distributionally robust optimization under moment uncertainty with application to data-driven problems"
            opt.DRC.gamma2        = 1;             % SDP parameter, reflects own risk preference, from "Distributionally robust optimization under moment uncertainty with application to data-driven problems"
            opt.DRC.epsilon       = 1e-4;          % residual threshold; greatly affect the accuracy and feasibility
            opt.DRC.probThreshold = 95;            % unit: %, the probability threshold of the DR chance-contrained programing
            opt.DRC.starIDX       = 'end';         % Index of the operating point in the training datasets; should be less than opt.num.trainSample; if 'end', use the last sample in the training dataset
            opt.DRC.language      = 'cvx';         % 'cvx' or 'yalmip'; 'cvx'/'yalmip': use cvx/yalmip to formulate the programming problem;   
            opt.DRC.programType   = 'indivi';      % 'whole' or 'indivi'; 'whole': put all responses into one program and solve; 'indivi': put one response into one program and solve
            opt.DRC.parallel      = 1;             % 1: use parallel computation to speed up, otherwise 0
            opt.DRC.yalDisplay    = 0;             % When directly solving the programing, 0: no yalmip display, 1: yalmip display.
            opt.DRC.cvxQuiet      = 1;             % 1: Suppress CVX output in the commander window, otherwise 0.
            opt.DRC.solverM       = 'SeDuMi';      % Solver options: 'SDPT3', 'SeDuMi' ('SDPT3' and 'SeDuMi' are included in \LaTeXstyle{Daline} via CVX).
        case 'DRC_XYM'
            % Distributionally robust chance-constrained programming, moment based, consider X and Y as random variables
            opt.DRC.gamma1        = 0;             % SDP parameter, reflects own risk preference, from "Distributionally robust optimization under moment uncertainty with application to data-driven problems"
            opt.DRC.gamma2        = 1;             % SDP parameter, reflects own risk preference, from "Distributionally robust optimization under moment uncertainty with application to data-driven problems"
            opt.DRC.epsilon       = 1e-4;          % residual threshold; greatly affect the accuracy and feasibility
            opt.DRC.probThreshold = 95;            % unit: %, the probability threshold of the DR chance-contrained programing
            opt.DRC.starIDX       = 'end';         % Index of the operating point in the training datasets; should be less than opt.num.trainSample; if 'end', use the last sample in the training dataset
            opt.DRC.language      = 'cvx';         % 'cvx' or 'yalmip'; 'cvx'/'yalmip': use cvx/yalmip to formulate the programming problem;   
            opt.DRC.programType   = 'indivi';      % 'whole' or 'indivi'; 'whole': put all responses into one program and solve; 'indivi': put one response into one program and solve
            opt.DRC.parallel      = 1;             % 1: use parallel computation to speed up, otherwise 0
            opt.DRC.yalDisplay    = 0;             % When directly solving the programing, 0: no yalmip display, 1: yalmip display.
            opt.DRC.cvxQuiet      = 1;             % 1: Suppress CVX output in the commander window, otherwise 0.
            opt.DRC.solverM       = 'SeDuMi';      % Solver options: 'SDPT3', 'SeDuMi' ('SDPT3' and 'SeDuMi' are included in \LaTeXstyle{Daline} via CVX).
        case 'DRC_XYD'
            % Distributionally robust chance-constrained programming, divergence based, consider X and Y as random variables
            opt.DRC.epsilon       = 1e-4;          % residual threshold; greatly affect the accuracy and feasibility
            opt.DRC.probThreshold = 95;            % unit: %, the probability threshold of the DR chance-contrained programing
            opt.DRC.starIDX       = 'end';         % Index of the operating point in the training datasets; should be less than opt.num.trainSample; if 'end', will use the last sample in the training dataset
            opt.DRC.d             = 0.1;           % Tolerance of the distance between the particular density function and the reference one, for divergence-based ambiguity sets, from "Robust Data-Driven Linear Power Flow Model With Probability Constrained Worst-Case Errors"
            opt.DRC.delta         = 1e-10;         % A very small value to form the exclusive interval (0, 1) by (delta, 1-delta)
            opt.DRC.bisecTol      = 1e-9;          % Tolerance of error for the bisection search, should be very small 
            opt.DRC.infMethod     = 'fzero';       % 'fzero' or 'bisec', refers to the methods (built-in fzero and bisection search) of finding the infimum, for divergence-based ambiguity sets. 
            opt.DRC.bigM          = 1e6;           % A big value as the big M 
            opt.DRC.language      = 'yalmip';      % Currently only support 'yalmip' to avoid extra settings needed by cvx when using Gurobi; 'cvx'/'yalmip': use cvx/yalmip to formulate the programming problem;   
            opt.DRC.programType   = 'indivi';      % Only support 'indivi' currently; 'whole': put all responses into one program and solve; 'indivi': put one response into one program and solve
            opt.DRC.parallel      = 1;             % 1: use parallel computation to speed up, otherwise 0
            opt.DRC.yalDisplay    = 0;             % When directly solving the programing, 0: no yalmip display, 1: yalmip display.
            opt.DRC.cvxQuiet      = 1;             % 1: Suppress CVX output in the commander window, otherwise 0.
            opt.DRC.solverD       = 'Gurobi';      % Solver options: 'Gurobi' (for 'Gurobi', you need to install it manually)
        case 'DC'
            % DC model, a physical model
            opt.idx                 = func_define_idx; % Built-in index in matpower
            opt.variable.predictor  = 'Fixed: P'; % Fixed predictors because of the method
            opt.variable.response   = 'Fixed: Va'; % Fixed responses because of the method
        case 'DC_LS'
            % DCPF with ordinary least squares
            opt.idx                 = func_define_idx; % Built-in index in matpower
            opt.variable.predictor  = 'Fixed: P'; % Fixed predictors because of the method
            opt.variable.response   = 'Fixed: Va'; % Fixed responses because of the method
        case 'DLPF' 
            % DLPF model, a physical model
            opt.idx                 = func_define_idx; % Built-in index in matpower
            opt.variable.predictor  = 'Fixed: Vm, Va, P, Q';   % Fixed predictors because of the method
            opt.variable.response   = 'Fixed: Vm, Va, PF, PT'; % Fixed responses because of the method
        case 'DLPF_C'
            % DLPF, corrected by QR decompotion
            opt.idx                 = func_define_idx; % Built-in index in matpower
            opt.variable.predictor  = 'Fixed: Vm, Va, P, Q'; % Fixed predictors because of the method
            opt.variable.response   = 'Fixed: Vm, Va, PF, PT'; % Fixed responses because of the method
        case 'PTDF'
            % DC-based PTDF model, a physical model
            opt.idx                 = func_define_idx; % Built-in index in matpower
            opt.variable.predictor  = 'Fixed: P'; % Fixed predictors because of the method
            opt.variable.response   = 'Fixed: PF'; % Fixed responses because of the method
        case 'TAY'
            % 1st-order Taylor approximation, a physical model
            opt.idx                 = func_define_idx; % Built-in index in matpower
            opt.TAY.point0          = 'end';           % Index of the operating point in the training datasets; should be less than opt.num.trainSample; if 'end', will use the last sample in the training dataset
            opt.variable.predictor  = 'Fixed: P, Q'; % Fixed predictors because of the method
            opt.variable.response   = 'Fixed: Vm, Va'; % Fixed responses because of the method
        case 'OI'
            % Outlier-Immune method based on the continuous relaxation-rounding algorithm
            opt.OI.bigM             = 1e6;  % Big-M constant: a large number to relax the constraint when a sample is flagged as an outlier.           
            opt.OI.outlierRatio     = 0.08; % Outlier Ratio: the allowed fraction of outliers. For example, 0.1 means that up to 10% of the data can be marked as outliers.      
            opt.OI.theta            = 0.9;  % Rounding Threshold: the threshold at which the relaxed binary variable z is fixed to 1. For instance, 0.9 means that any sample with z>=0.9 in the relaxed solution is fixed as an outlier.         
            opt.OI.maxIter          = 100;  % Maximum Iterations: limits the number of iterations for the continuous relaxation-rounding process.       
            opt.OI.solver           = 'gurobi'; % Solver Option: the name of the solver to be used (e.g., 'gurobi', 'mosek', or 'sdpt3').  
            opt.OI.verbose          = 1;    % Verbose Option: controls the amount of output produced by the solver. A value of 0 means quiet, 1 means minimal output, and higher values can yield more details.
        case 'PLOT'
            % Choose which responses to show in the figure
            opt.PLOT.switch       = 1;             % 1: plot the result; 0: don't plot the result
            opt.PLOT.response     = [];            % E.g., {'Vm','Va'}, {'PF', 'QF'}, etc., will plot the error distribution of the chosen response; if the chosen responses don't exist => method will be considered fail; if PLOT.response is not given, will plot the errors of all responses from training.
            opt.PLOT.type         = 'moment';      % 'probability': plot probability distribution of error (3D); 'moment': plot moment distribution (min, max, mean) of error (2D)
            opt.PLOT.theme        = 'commercial';  % For moment error distribution only: 'commercial' or 'academic'; 'commercial' will use the theme of Big Tech company such as Apple (only works for 'indivi'); 'academic' will use an average theme for academic papers
            opt.PLOT.pattern      = 'indivi';      % For moment error distribution only: 'indivi' or 'joint', i.e., paint the error/ranking individually for each response, or paint them together on one figure
            opt.PLOT.startAlpha   = 0.95;          % For probability error distribution only: the transparency of the 1st distribution (the most accurate one)
            opt.PLOT.endAlpha     = 0.4;           % For probability error distribution only: the transparency of the last distribution (the most inaccurate one)
            opt.PLOT.disPoints    = 1000;          % For probability error distribution only: the number of points used to draw the probability distribution. The larger, the smoother the distribution
            opt.PLOT.logShift     = 1e-6;          % For probability error distribution only: a small constant to handle the log transformation of zero error values; for painting only, the value will not be added to the quantified result
            opt.PLOT.numComponent = 3;             % For probability error distribution only: the number of components in Gaussian mixture model, which is used to fit the error probability distribution. When the number of testing data points is small, consider using less components
            opt.PLOT.norm         = 0;             % For probability error distribution only: 0 means showing the original distribution; 1 means showing the normalized distribution (suggested when the differences among different distributions are huge and cannot be visualized effectively in the same figure)
            opt.PLOT.style        = 'dark';        % 'dark' or 'light'; 'dark'/'light' plots the ranking on a dark/light background
            opt.PLOT.titleHight   = 0.5;           % The larger the titleHight, the closer the title to the figure
            opt.PLOT.origin       = 15;            % E.g., if origin= 15, then 1e-15 is used as the origin of the log-scaled x-axis
            opt.PLOT.repeat       = 3;             % Times repeated to get the average computational time
            opt.PLOT.caseName     = '';            % case name will show up in the title of the figure, if specified; empty by default
            opt.PLOT.print        = 0;             % For 'commercial' and 'indivi' styles, 1: print the figure into PDF; 0: don't print.
        otherwise
            error(['The querying field "', key{n}, '" is not supported. Check the manual or func_default_option_category.m to see the supported fields.']);
    end
end



