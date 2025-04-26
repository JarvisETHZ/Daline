%% Get data once
data = daline.data('case.name', 'case118');
data = daline.data('case.name', 'case39');
data = daline.data('case.name', 'case9');
data = daline.data('case.name', 'case14');

%% 4.1 daline.fit
model = daline.fit(data);
model_A = daline.fit(data, 'method.name', 'RR', 'variable.predictor', {'P' , 'Vm2'}, 'RR.lambdaInterval', [0:1e-3:0.02]);
opt = daline.setopt('method.name', 'RR', 'variable.predictor', {'P', 'Vm2' }, 'RR.lambdaInterval', 0:1e-3:0.02);
model_B = daline.fit(data, opt);
model_A = func_algorithm_LS(data);
model_B = daline.fit(data, 'method.name', 'LS');

%% 4.2.1 Ordinary least squares
model = daline.fit(data, 'method.name', 'LS');
model = daline.fit(data, 'method.name', 'LS', 'variable.predictor', {'P'}, 'variable.response', {'PF', 'Vm'});
opt = daline.setopt('method.name', 'LS', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF'});
model = daline.fit(data, opt);
model = func_algorithm_LS(data, 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'QF'});
opt = daline.setopt('variable.predictor', {'P', 'Q'}, 'variable.response', {'PF'});
model = func_algorithm_LS(data, opt);

%% 4.2.2 Ordinary least squares with generalized inverse
model = daline.fit(data, 'method.name', 'LS_PIN');
model = daline.fit(data, 'method.name', 'LS_PIN', 'variable.predictor', {'P'}, 'variable.response', {'PF', 'Vm'});
opt = daline.setopt('method.name', 'LS_PIN', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF'});
model = daline.fit(data, opt);
model = func_algorithm_LS_PIN(data, 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'QF'});
opt = daline.setopt('variable.predictor', {'P', 'Q'}, 'variable.response', {'PF'});
model = func_algorithm_LS_PIN(data, opt);

%% 4.2.3 Least squares with singular value decomposition
model = daline.fit(data, 'method.name', 'LS_SVD');
model = daline.fit(data, 'method.name', 'LS_SVD', 'variable.predictor', {'P'}, 'variable.response', {'PF', 'Vm'});
opt = daline.setopt('method.name', 'LS_SVD', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF'});
model = daline.fit(data, opt);
model = func_algorithm_LS_SVD(data, 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'QF'});
opt = daline.setopt('variable.predictor', {'P', 'Q'}, 'variable.response', {'PF'});
model = func_algorithm_LS_SVD(data, opt);

%% 4.2.4 Least squares with complete orthogonal decomposition
model = daline.fit(data, 'method.name', 'LS_COD');
model = daline.fit(data, 'method.name', 'LS_COD', 'variable.predictor', {'P'}, 'variable.response', {'PF', 'Vm'});
opt = daline.setopt('method.name', 'LS_COD', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF'});
model = daline.fit(data, opt);
model = func_algorithm_LS_COD(data, 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'QF'});
opt = daline.setopt('variable.predictor', {'P', 'Q'}, 'variable.response', {'PF'});
model = func_algorithm_LS_COD(data, opt);

%% 4.2.5 Least squares with principal component analysis
model = daline.fit(data, 'method.name', 'LS_PCA');
model = daline.fit(data, 'method.name', 'LS_PCA', 'variable.predictor', {'P'}, 'variable.response', {'PF', 'Vm'}, 'PCA.parallel', 0, 'PCA.PerComponent', [30:10:90], 'PCA.numFold', 5);
opt = daline.setopt('method.name', 'LS_PCA', 'variable.predictor', {'P'}, 'variable.response', {'PF', 'Vm'}, 'PCA.PerComponent', [30:10:90], 'PCA.numFold', 5);
model = daline.fit(data, opt);
model = func_algorithm_LS_PCA(data, 'variable.predictor', {'P'}, 'variable.response', {'PF', 'Vm'}, 'PCA.PerComponent', [30:10:90], 'PCA.numFold', 5);
opt = daline.setopt('variable.predictor', {'P'}, 'variable.response', {'PF', 'Vm'}, 'PCA.PerComponent', [30:10:90], 'PCA.numFold', 5);
model = func_algorithm_LS_PCA(data, opt);

%% 4.2.6 Least squares with Huber loss function: a direct solution (solver: fminunc)
model = daline.fit(data, 'method.name', 'LS_HBLD');
model = daline.fit(data, 'method.name', 'LS_HBLD', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'HBL.delta', [0.04:0.005:0.06]);
model = daline.fit(data, 'method.name', 'LS_HBLD', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'HBL.delta', 0.04);
model = daline.fit(data, 'method.name', 'LS_HBLD', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'HBL.parallel', 0, 'HBL.delta', 0.04);
model = daline.fit(data, 'method.name', 'LS_HBLD', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'HBL.parallel', 0, 'HBL.delta', 0.01);
model = daline.fit(data, 'method.name', 'LS_HBLD', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'HBL.parallel', 0, 'HBL.delta', [0.04:0.005:0.06]);
opt = daline.setopt('method.name', 'LS_HBLD', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'HBL.delta', [0.04:0.005:0.06]);
model = daline.fit(data, opt);
model = func_algorithm_LS_HBLD(data, 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'HBL.delta', [0.04:0.005:0.06]);
opt = daline.setopt('variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'HBL.delta', [0.04:0.005:0.06]);
model = func_algorithm_LS_HBLD(data, opt);

%% 4.2.7 Least squares with Huber loss function: an equivalent solution (solvers: fmincon, Gurobi, recommend: yalmip+fmincon+indivi)
model = daline.fit(data, 'method.name', 'LS_HBLE');
model = daline.fit(data, 'method.name', 'LS_HBLE', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'HBL.language', 'yalmip', 'HBL.solver', 'fmincon', 'HBL.delta', 0.01);
opt = daline.setopt('method.name', 'LS_HBLE', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'HBL.parallel', 0, 'HBL.language', 'yalmip', 'HBL.solver', 'fmincon');
model = daline.fit(data, opt);
model = func_algorithm_LS_HBLE(data, 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'HBL.language', 'yalmip', 'HBL.solver', 'fmincon');
opt = daline.setopt('variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'HBL.language', 'yalmip', 'HBL.solver', 'fmincon');
model = func_algorithm_LS_HBLE(data, opt);

%% 4.2.8 Least squares with Huber weighting function
model = daline.fit(data, 'method.name', 'LS_HBW');
model = daline.fit(data, 'method.name', 'LS_HBW', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'HBW.TuningConst', [0.8:0.1:1.5], 'HBW.PCA', 0);
model = daline.fit(data, 'method.name', 'LS_HBW', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'HBW.TuningConst', [0.8:0.1:1.5], 'HBW.PCA', 0);
model = daline.fit(data, 'method.name', 'LS_HBW', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'HBW.TuningConst', [0.8:0.1:1.5], 'HBW.PCA', 0);
model = daline.fit(data, 'method.name', 'LS_HBW', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'HBW.TuningConst', [0.8:0.1:1.5], 'HBW.PCA', 0);
model = daline.fit(data, 'method.name', 'LS_HBW', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'HBW.TuningConst', [0.8:0.1:1.5], 'HBW.PCA', 0);
model = daline.fit(data, 'method.name', 'LS_HBW', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'HBW.TuningConst', [0.8:0.1:1.5], 'HBW.PCA', 0);
opt = daline.setopt('method.name', 'LS_HBW', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'HBW.TuningConst', [0.8:0.1:1.5], 'HBW.PCA', 0);
model = daline.fit(data, opt);
model = func_algorithm_LS_HBW(data, 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'HBW.TuningConst', [0.8:0.1:1.5], 'HBW.PCA', 0);
opt = daline.setopt('variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'HBW.TuningConst', [0.8:0.1:1.5], 'HBW.PCA', 0);
model = func_algorithm_LS_HBW(data, opt);

%% 4.2.9 Generalized least squares
model = daline.fit(data, 'method.name', 'LS_GEN');
model = daline.fit(data, 'method.name', 'LS_GEN', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'LSG.InnovMdl', 'AR');
opt = daline.setopt('method.name', 'LS_GEN', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'LSG.InnovMdl', 'AR');
model = daline.fit(data, opt);
model = func_algorithm_LS_GEN(data, 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'LSG.InnovMdl', 'AR');
opt = daline.setopt('variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'LSG.InnovMdl', 'AR');
model = func_algorithm_LS_GEN(data, opt);

%% 4.2.10 Total least squares
model = daline.fit(data, 'method.name', 'LS_TOL');
model = daline.fit(data, 'method.name', 'LS_TOL', 'variable.predictor', {'P'}, 'variable.response', {'PF', 'Vm'});
opt = daline.setopt('method.name', 'LS_TOL', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF'});
model = daline.fit(data, opt);
model = func_algorithm_LS_TOL(data, 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'QF'});
opt = daline.setopt('variable.predictor', {'P', 'Q'}, 'variable.response', {'PF'});
model = func_algorithm_LS_TOL(data, opt);

%% 4.2.11 Least squares with clustering
model = daline.fit(data, 'method.name', 'LS_CLS');
model = daline.fit(data, 'method.name', 'LS_CLS', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'LSC.fixKmeans', 0, 'LSC.clusNumInterval', [6:2:12], 'LSC.cvNumFold', 5);
opt = daline.setopt('method.name', 'LS_CLS', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'LSC.fixKmeans', 0, 'LSC.clusNumInterval', [6:2:12], 'LSC.cvNumFold', 5);
model = daline.fit(data, opt);
model = func_algorithm_LS_CLS(data, 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'LSC.fixKmeans', 0, 'LSC.clusNumInterval', [6:2:12], 'LSC.cvNumFold', 5);
opt = daline.setopt('variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'LSC.fixKmeans', 0, 'LSC.clusNumInterval', [6:2:12], 'LSC.cvNumFold', 5);
model = func_algorithm_LS_CLS(data, opt);

%% 4.2.12 Least squares with lifting dimension: lifting the whole x jointly
model = daline.fit(data, 'method.name', 'LS_LIFX');
model = daline.fit(data, 'method.name', 'LS_LIFX', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'variable.liftType', 'polyharmonic', 'variable.liftK', 2);
opt = daline.setopt('method.name', 'LS_LIFX', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'variable.liftType', 'polyharmonic', 'variable.liftK', 2);
model = daline.fit(data, opt);
model = func_algorithm_LS_LIFX(data, 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'variable.liftType', 'polyharmonic', 'variable.liftK', 2);
opt = daline.setopt('variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'variable.liftType', 'polyharmonic', 'variable.liftK', 2);
model = func_algorithm_LS_LIFX(data, opt);

%% 4.2.13 Least squares with lifting dimension: lifting the elements of x individually
model = daline.fit(data, 'method.name', 'LS_LIFXi');
model = daline.fit(data, 'method.name', 'LS_LIFXi', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'variable.liftType', 'polyharmonic', 'variable.liftK', 2);
opt = daline.setopt('method.name', 'LS_LIFXi', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'variable.liftType', 'polyharmonic', 'variable.liftK', 2); 
model = daline.fit(data, opt);
model = func_algorithm_LS_LIFXi(data, 'variable.predictor', {'P', 'Q' }, 'variable.response', {'PF', 'Vm'}, 'variable.liftType', 'polyharmonic', 'variable.liftK', 2);
opt = daline.setopt('variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'variable.liftType', 'polyharmonic', 'variable.liftK', 2);
model = func_algorithm_LS_LIFXi(data, opt);

%% 4.2.14 Weighed least squares (solvers: quadprog, Gurobi, SDPT3, SeDuMi, recommend: cvx+SeDuMi+whole)
model = daline.fit(data, 'method.name', 'LS_WEI');
model = daline.fit(data, 'method.name', 'LS_WEI', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'LSW.omega', 0.95, 'LSW.programType', 'whole', 'LSW.solver', 'SeDuMi', 'LSW.language', 'cvx', 'LSW.programType', 'whole');
opt = daline.setopt('method.name', 'LS_WEI', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'LSW.omega', 0.95, 'LSW.programType', 'whole', 'LSW.solver', 'SeDuMi');
model = daline.fit(data, opt);
model = func_algorithm_LS_WEI(data, 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'LSW.omega', 0.95, 'LSW.programType', 'whole', 'LSW.solver', 'SeDuMi');
opt = daline.setopt('variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'LSW.omega', 0.95, 'LSW.programType', 'whole', 'LSW.solver', 'SeDuMi');
model = func_algorithm_LS_WEI(data, opt);

%% 4.2.15 Recursive least squares
model = daline.fit(data, 'method.name', 'LS_REC');
model = daline.fit(data, 'method.name', 'LS_REC', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'LSR.recursivePercentage', 30, 'LSR.initializeP', 0);
opt = daline.setopt('method.name', 'LS_REC', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'LSR.recursivePercentage', 30, 'LSR.initializeP', 0);
model = daline.fit(data, opt);
model = func_algorithm_LS_REC(data, 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'LSR.recursivePercentage', 30, 'LSR.initializeP', 0);
opt = daline.setopt('variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'LSR.recursivePercentage', 30, 'LSR.initializeP', 0);
model = func_algorithm_LS_REC(data, opt);

%% 4.2.16 Repeated least squares
model = daline.fit(data, 'method.name', 'LS_REP');
model = daline.fit(data, 'method.name', 'LS_REP', 'variable.predictor', { 'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'LSR.recursivePercentage', 75);
opt = daline.setopt('method.name', 'LS_REP', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'LSR.recursivePercentage', 75);
model = daline.fit(data, opt);
model = func_algorithm_LS_REP(data, 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'LSR.recursivePercentage', 75);
opt = daline.setopt('variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'LSR.recursivePercentage', 75);
model = func_algorithm_LS_REP(data, opt);

%% 4.3.1 Ordinary partial least squares with SIMPLS
model = daline.fit(data, 'method.name', 'PLS_SIM');
model = daline.fit(data, 'method.name', 'PLS_SIM', 'variable.predictor', {'P'}, 'variable.response', {'PF', 'Vm'});
opt = daline.setopt('method.name', 'PLS_SIM', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF'});
model = daline.fit(data, opt);
model = func_algorithm_PLS_SIM(data, 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'QF'});
opt = daline.setopt('variable.predictor', {'P', 'Q'}, 'variable.response', {'PF'});
model = func_algorithm_PLS_SIM(data, opt);

%% 4.3.2 Ordinary partial least squares with SIMPLS using rank of X
model = daline.fit(data, 'method.name', 'PLS_SIMRX');
model = daline.fit(data, 'method.name', 'PLS_SIMRX', 'variable.predictor' , {'P'}, 'variable.response', {'PF', 'Vm'});
opt = daline.setopt('method.name', 'PLS_SIMRX', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF'});
model = daline.fit(data, opt);
model = func_algorithm_PLS_SIMRX(data, 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'QF'});
opt = daline.setopt('variable.predictor', {'P', 'Q'}, 'variable.response', {'PF'});
model = func_algorithm_PLS_SIMRX(data, opt);


%% 4.3.3 Ordinary partial least squares with NIPALS
model = daline.fit(data, 'method.name', 'PLS_NIP');
model = daline.fit(data, 'method.name', 'PLS_NIP', 'variable.predictor', {'P'}, 'variable.response', {'PF', 'Vm'}, 'PLS.innerTol', 1e-10);
opt = daline.setopt('method.name', 'PLS_NIP', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF'}, 'PLS.innerTol', 1e-10);
model = daline.fit(data, opt);
model = func_algorithm_PLS_NIP(data, 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'QF'}, 'PLS.innerTol', 1e-10);
opt = daline.setopt('variable.predictor', {'P', 'Q'}, 'variable.response', {'PF'}, 'PLS.innerTol', 1e-10);
model = func_algorithm_PLS_NIP(data, opt);

%% 4.3.4 Partial least squares bundling known/unknown variables and re-placing slack bus’s power injection
model = daline.fit(data, 'method.name', 'PLS_BDL');
opt = daline.setopt('method.name', 'PLS_BDL'); 
model = daline.fit(data, opt);
model = func_algorithm_PLS_BDL(data);

%% 4.3.5 Partial least squares bundling known/unknown variables
model = daline.fit(data, 'method.name', 'PLS_BDLY2');
opt = daline.setopt('method.name', 'PLS_BDLY2'); 
model = daline.fit(data, opt);
model = func_algorithm_PLS_BDLY2(data);

%% 4.3.6 Partial least squares bundling known/unknown variables: the open-source version
model = daline.fit(data, 'method.name', 'PLS_BDLopen');
model = func_algorithm_PLS_BDLopen(data);
opt = daline.setopt('method.name', 'PLS_BDLopen'); 
model = daline.fit(data, opt);

%% 4.3.7 Recursive partial least squares with NIPALS
model = daline.fit(data, 'method.name', 'PLS_REC');
model = daline.fit(data, 'method.name', 'PLS_REC', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'PLS.recursivePercentage', 50, 'PLS.innerTol', 1e-10);
opt = daline.setopt('method.name', 'PLS_REC', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'PLS.recursivePercentage', 50, 'PLS.innerTol', 1e-10);
model = daline.fit(data, opt);
model = func_algorithm_PLS_REC(data, 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'PLS.recursivePercentage', 50, 'PLS.innerTol', 1e-10);
opt = daline.setopt('variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'PLS.recursivePercentage', 50, 'PLS.innerTol', 1e-10);
model = func_algorithm_PLS_REC(data, opt);

%% 4.3.8 Recursive partial least squares with NIPALS, using forgetting factors for observations
model = daline.fit(data, 'method.name', 'PLS_RECW');
model = daline.fit(data, 'method.name', 'PLS_RECW', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'PLS.omega', 0.95, 'PLS.recursivePercentage', 30);
opt = daline.setopt('method.name', 'PLS_RECW', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'PLS.omega', 0.95, 'PLS.recursivePercentage', 30);
model = daline.fit(data, opt);
model = func_algorithm_PLS_RECW(data, 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'PLS.omega', 0.95, 'PLS.recursivePercentage', 30);
opt = daline.setopt('variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'PLS.omega', 0.95, 'PLS.recursivePercentage', 30);
model = func_algorithm_PLS_RECW(data, opt);

%% 4.3.9 Repeated partial least squares with NIPALS
model = daline.fit(data, 'method.name', 'PLS_REP');
model = daline.fit(data, 'method.name', 'PLS_REP', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'PLS.recursivePercentage', 50, 'PLS.innerTol', 1e-10);
opt = daline.setopt('method.name', 'PLS_REP', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'PLS.recursivePercentage', 50, 'PLS.innerTol', 1e-10);
model = daline.fit(data, opt);
model = func_algorithm_PLS_REP(data, 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'PLS.recursivePercentage', 50, 'PLS.innerTol', 1e-10);
opt = daline.setopt('variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'PLS.recursivePercentage', 50, 'PLS.innerTol', 1e-10);
model = func_algorithm_PLS_REP(data, opt);

%% 4.3.10 Partial least squares with clustering
model = daline.fit(data, 'method.name', 'PLS_CLS');
model = daline.fit(data, 'method.name', 'PLS_CLS', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'PLS.fixKmeans', 0, 'PLS.clusNumInterval', [6:2:12], 'PLS.cvNumFold', 5);
opt = daline.setopt('method.name', 'PLS_CLS', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'PLS.fixKmeans', 0, 'PLS.clusNumInterval', [6:2:12], 'PLS.cvNumFold', 5);
model = daline.fit(data, opt);
model = func_algorithm_PLS_CLS(data, 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'PLS.fixKmeans', 0, 'PLS.clusNumInterval', [6:2:12], 'PLS.cvNumFold', 5);
opt = daline.setopt('variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'PLS.fixKmeans', 0, 'PLS.clusNumInterval', [6:2:12], 'PLS.cvNumFold', 5);
model = func_algorithm_PLS_CLS(data, opt);

%% 4.4.1 Ordinary ridge regression
model = daline.fit(data, 'method.name', 'RR');
model = daline.fit(data, 'method.name', 'RR', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'RR.lambdaInterval', [0:5e-3:0.1]);
opt = daline.setopt('method.name', 'RR', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'RR.lambdaInterval', [0:5e-3:0.1]);
model = daline.fit(data, opt);
model = func_algorithm_RR(data, 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'RR.lambdaInterval', [0:5e-3:0.1]);
opt = daline.setopt('variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'RR.lambdaInterval', [0:5e-3:0.1]);
model = func_algorithm_RR(data, opt);

%% 4.4.2 Ordinary ridge regression with the voltage-angle coupling
model = daline.fit(data, 'method.name', 'RR_VCS');
model = daline.fit(data, 'method.name', 'RR_VCS', 'RR.lambdaInterval', [0:5e-3:0.1]);
opt = daline.setopt('method.name', 'RR_VCS', 'RR.lambdaInterval', [0:5e-3:0.1]);
model = daline.fit(data, opt);
model = func_algorithm_RR_VCS(data, 'RR.lambdaInterval', [0:5e-3:0.1]);
opt = daline.setopt('RR.lambdaInterval', [0:5e-3:0.1]); 
model = func_algorithm_RR_VCS(data, opt);

%% 4.4.3 Ordinary ridge regression with K-plane clustering
model = daline.fit(data, 'method.name', 'RR_KPC');
model = daline.fit(data, 'method.name', 'RR_KPC', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'RR.lambdaInterval', [0:5e-2:0.1], 'RR.etaInterval', logspace(-3, 3, 7), 'RR.clusNumInterval', [2:2:10]);
opt = daline.setopt('method.name', 'RR_KPC', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'RR.lambdaInterval', [0:5e-2:0.1],'RR.etaInterval', logspace(-3, 3, 7), 'RR.clusNumInterval', [2:2:10]); 
model = daline.fit(data, opt);
model = func_algorithm_RR_KPC(data, 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'RR.lambdaInterval', [0:5e-2:0.1], 'RR.etaInterval', logspace(-3, 3, 7), 'RR.clusNumInterval', [2:2:10]);
opt = daline.setopt('variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'RR.lambdaInterval', [0:5e-2:0.1], 'RR.etaInterval', logspace(-3, 3, 7), 'RR.clusNumInterval', [2:2:10]); 
model = func_algorithm_RR_KPC(data, opt);

%% 4.4.4 Locally weighted ridge regression
model = daline.fit(data, 'method.name', 'RR_WEI');
model = daline.fit(data, 'method.name', 'RR_WEI', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'RR.lambdaInterval', [0:5e-3:0.1], 'RR.tauInterval', [0.1:1e-2:0.3]);
opt = daline.setopt('method.name', 'RR_WEI', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'RR.lambdaInterval', [0:5e-3:0.1], 'RR.tauInterval', [0.1:1e-2:0.3]); 
model = daline.fit(data, opt);
model = func_algorithm_RR_WEI(data, 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'RR.lambdaInterval', [0:5e-3:0.1], 'RR.tauInterval', [0.1:1e-2:0.3]);
opt = daline.setopt('variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'RR.lambdaInterval', [0:5e-3:0.1], 'RR.tauInterval', [0.1:1e-2:0.3]);
model = func_algorithm_RR_WEI(data, opt);

%% 4.5.1 Ordinary support vector regression: a direct solution (solvers: quadprog, Gurobi, recommend: yalmip+quadprog+indivi)
model = daline.fit(data, 'method.name', 'SVR');
model = daline.fit(data, 'method.name', 'SVR', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'SVR.omega', 25, 'SVR.language', 'yalmip', 'SVR.programType', 'indivi', 'SVR.solver', 'quadprog');
opt = daline.setopt('method.name', 'SVR', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'SVR.omega', 25, 'SVR.yalDisplay', 1);
model = daline.fit(data, opt);
model = func_algorithm_SVR(data, 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'SVR.omega', 25, 'SVR.yalDisplay', 1);
opt = daline.setopt('variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'SVR.omega', 25, 'SVR.yalDisplay', 1);
model = func_algorithm_SVR(data, opt);

%% 4.5.2 Support vector regression with polynomial kernel
model = daline.fit(data, 'method.name', 'SVR_POL');
model = daline.fit(data, 'method.name', 'SVR_POL', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'SVR.default', 0, 'SVR.epsilon', 0.05);
opt = daline.setopt('method.name', 'SVR_POL', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'SVR.default', 0, 'SVR.epsilon', 0.05);
model = daline.fit(data, opt);
model = func_algorithm_SVR_POL(data, 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'SVR.default', 0, 'SVR.epsilon', 0.05);
opt = daline.setopt('variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'SVR.default', 0, 'SVR.epsilon', 0.05);
model = func_algorithm_SVR_POL(data, opt);

%% 4.5.3 Support vector regression with ridge regression (solvers: quadprog, Gurobi, recommend: yalmip+quadprog+indivi)
model = daline.fit(data, 'method.name', 'SVR_RR');
model = daline.fit(data, 'method.name', 'SVR_RR', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'SVR.lambda', -0.4999, 'SVR.PCA', 0, 'SVR.language', 'yalmip', 'SVR.programType', 'indivi', 'SVR.solver', 'quadprog');
opt = daline.setopt('method.name', 'SVR_RR', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'SVR.lambda', -0.4999, 'SVR.PCA', 0);
model = daline.fit(data, opt);
model = func_algorithm_SVR_RR(data, 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'SVR.lambda', -0.4999, 'SVR.PCA', 0);
opt = daline.setopt('variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'SVR.lambda', -0.4999, 'SVR.PCA', 0);
model = func_algorithm_SVR_RR(data, opt);

%% 4.5.4 Support vector regression with chance-constrained programming (solver: Gurobi, recommend: yalmip+Gurobi+indivi)
model = daline.fit(data, 'method.name', 'SVR_CCP');
model = daline.fit(data, 'method.name', 'SVR_CCP', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'SVRCC.epsilon', 1e-3, 'SVRCC.probThreshold', 0.95);
model = daline.fit(data, 'method.name', 'SVR_CCP', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'SVRCC.epsilon', 1e-3, 'SVRCC.probThreshold', 0.95, 'SVRCC.language', 'yalmip', 'SVRCC.programType', 'indivi', 'SVRCC.solver', 'Gurobi');
opt = daline.setopt('method.name', 'SVR_CCP', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'SVRCC.epsilon', 1e-3, 'SVRCC.probThreshold', 0.95);
model = daline.fit(data, opt);
model = func_algorithm_SVR_CCP(data, 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'SVRCC.epsilon', 1e-3, 'SVRCC.probThreshold', 0.95);
opt = daline.setopt('variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'}, 'SVRCC.epsilon', 1e-3, 'SVRCC.probThreshold', 0.95);
model = func_algorithm_SVR_CCP(data, opt);

%% 4.6.1 Linearly constrained programming with box constraints (solvers: quadprog, Gurobi, SDPT3, SeDuMi, recommend: SeDuMi)
model = daline.fit(data, 'method.name', 'LCP_BOX');
model = daline.fit(data, 'method.name', 'LCP_BOX', 'LCP.solver', 'SeDuMi', 'LCP.cvxQuiet', 1);
opt = daline.setopt('method.name', 'LCP_BOX', 'LCP.solver', 'SeDuMi', 'LCP.cvxQuiet', 1);
model = daline.fit(data, opt);
model = func_algorithm_LCP_BOX(data, 'LCP.solver', 'SeDuMi', 'LCP.cvxQuiet', 1);
opt = daline.setopt('LCP.solver', 'SeDuMi', 'LCP.cvxQuiet', 1); 
model = func_algorithm_LCP_BOX(data, opt);

%% 4.6.2 Linearly constrained programming without box constraints (solvers: quadprog, Gurobi, SDPT3, SeDuMi, recommend: SeDuMi)
model = daline.fit(data, 'method.name', 'LCP_BOXN');
model = daline.fit(data, 'method.name', 'LCP_BOXN', 'LCP.solver', 'SeDuMi' , 'LCP.cvxQuiet', 1);
opt = daline.setopt('method.name', 'LCP_BOXN', 'LCP.solver', 'SeDuMi', 'LCP.cvxQuiet', 1);
model = daline.fit(data, opt);
model = func_algorithm_LCP_BOXN(data, 'LCP.solver', 'SeDuMi', 'LCP.cvxQuiet', 1);
opt = daline.setopt('LCP.solver', 'SeDuMi', 'LCP.cvxQuiet', 1); 
model = func_algorithm_LCP_BOXN(data, opt);

%% 4.6.3 Linearly constrained programming with Jacobian guidance constraints
model = daline.fit(data, 'method.name', 'LCP_JGD');
model = daline.fit(data, 'method.name', 'LCP_JGD', 'LCP.cvxQuiet', 1);
opt = daline.setopt('method.name', 'LCP_JGD', 'LCP.cvxQuiet', 1);
model = daline.fit(data, opt);
model = func_algorithm_LCP_JGD(data, 'LCP.cvxQuiet', 1);
opt = daline.setopt('LCP.cvxQuiet', 1);
model = func_algorithm_LCP_JGD(data, opt);

%% 4.6.4 Linearly constrained programming without Jacobian guidance constraints
model = daline.fit(data, 'method.name', 'LCP_JGDN');
model = daline.fit(data, 'method.name', 'LCP_JGDN', 'LCP.cvxQuiet', 1);
model = func_algorithm_LCP_JGDN(data, 'LCP.cvxQuiet', 1);
opt = daline.setopt('method.name', 'LCP_JGDN', 'LCP.cvxQuiet', 1); 
model = daline.fit(data, opt);
opt = daline.setopt('LCP.cvxQuiet', 1);
model = func_algorithm_LCP_JGDN(data, opt);

%% 4.6.5 Linearly constrained programming with coupling constraints (solvers: quadprog, Gurobi, SDPT3, SeDuMi, recommend: quadprog)
model = daline.fit(data, 'method.name', 'LCP_COU');
model = daline.fit(data, 'method.name', 'LCP_COU', 'LCP.coupleDelta', 1e-3, 'LCP.solver', 'quadprog');
opt = daline.setopt('method.name', 'LCP_COU', 'LCP.coupleDelta', 1e-3, 'LCP.solver', 'quadprog');
model = daline.fit(data, opt);
model = func_algorithm_LCP_COU(data, 'LCP.coupleDelta', 1e-3, 'LCP.solver', 'quadprog');
opt = daline.setopt('LCP.coupleDelta', 1e-3, 'LCP.solver', 'quadprog'); 
model = func_algorithm_LCP_COU(data, opt);

%% 4.6.6 Linearly constrained programming without coupling constraints (solvers: quadprog, Gurobi, SDPT3, SeDuMi, recommend: quadprog)
model = daline.fit(data, 'method.name', 'LCP_COUN');
model = daline.fit(data, 'method.name', 'LCP_COUN', 'LCP.solver', 'quadprog');
opt = daline.setopt('method.name', 'LCP_COUN', 'LCP.solver', 'quadprog'); 
model = daline.fit(data, opt);
model = func_algorithm_LCP_COUN(data, 'LCP.solver', 'quadprog');
opt = daline.setopt('LCP.solver', 'quadprog'); 
model = func_algorithm_LCP_COUN(data, opt);

%% 4.7.1 Moment-based distributionally robust chance-constrained programming with X as random variable (solvers: SDPT3, SeDuMi, recommend: cvx+SeDuMi+whole for small cases, cvx+SeDuMi+indivi for large cases)
dataN = daline.normalize(data);
model = daline.fit(dataN, 'method.name', 'DRC_XM');
model = daline.fit(dataN, 'method.name', 'DRC_XM', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF'}, 'DRC.epsilon', 1e-3, 'DRC.language' , 'cvx', 'DRC.solverM', 'SeDuMi', 'DRC.programType', 'indivi');
opt = daline.setopt('method.name', 'DRC_XM', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF'}, 'DRC.epsilon', 1e-3, 'DRC.language', 'cvx', 'DRC.solverM', 'SeDuMi');
model = daline.fit(dataN, opt);
model = func_algorithm_DRC_XM(dataN, 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF'}, 'DRC.epsilon', 1e-3, 'DRC.language', 'cvx', 'DRC.solverM', 'SeDuMi');
opt = daline.setopt('variable.predictor', {'P', 'Q'}, 'variable.response', {'PF'}, 'DRC.epsilon', 1e-3, 'DRC.language', 'cvx', 'DRC.solverM', 'SeDuMi');
model = func_algorithm_DRC_XM(dataN, opt);

%% 4.7.2 Moment-based distributionally robust chance-constrained programming with X and Y as random variables (solvers: SDPT3, SeDuMi, recommend: cvx+SeDuMi+whole for small cases, cvx+SeDuMi+indivi for large cases)
dataN = daline.normalize(data);
model = daline.fit(dataN, 'method.name', 'DRC_XYM');
model = daline.fit(dataN, 'method.name', 'DRC_XYM', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF'}, 'DRC.probThreshold', 90, 'DRC.gamma2', 0.5, 'DRC.language', 'cvx', 'DRC.solverM', 'SeDuMi', 'DRC.programType', 'whole');
opt = daline.setopt('method.name', 'DRC_XYM', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF'}, 'DRC.probThreshold', 90, 'DRC.gamma2', 0.5);
model = daline.fit(dataN, opt);
model = func_algorithm_DRC_XYM(dataN, 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF'}, 'DRC.probThreshold', 90, 'DRC.gamma2', 0.5);
opt = daline.setopt('variable.predictor', {'P', 'Q'}, 'variable.response', {'PF'}, 'DRC.probThreshold', 90, 'DRC.gamma2', 0.5);
model = func_algorithm_DRC_XYM(dataN, opt);

%% 4.7.3 Divergence-based distributionally robust chance-constrained programming with X and Y as random variables (solvers: Gurobi, recommend: yalmip+Gurobi)
dataN = daline.normalize(data);
model = daline.fit(dataN, 'method.name', 'DRC_XYD');
model = daline.fit(dataN, 'method.name', 'DRC_XYD', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF'}, 'DRC.infMethod', 'bisec', 'DRC.bisecTol', 1e-8, 'DRC.language', 'yalmip', 'DRC.solverD', 'Gurobi', 'DRC.programType', 'indivi');
opt = daline.setopt('method.name', 'DRC_XYD', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF'}, 'DRC.infMethod', 'bisec', 'DRC.bisecTol' , 1e-8);
model = daline.fit(dataN, opt);
model = func_algorithm_DRC_XYD(dataN, 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF'}, 'DRC.infMethod', 'bisec', 'DRC.bisecTol', 1e-8);
opt = daline.setopt('variable.predictor', {'P', 'Q'}, 'variable.response', {'PF'}, 'DRC.infMethod', 'bisec', 'DRC.bisecTol', 1e-8);
model = func_algorithm_DRC_XYD(dataN, opt);

%% 4.8.1 DCPF
model = daline.fit(data, 'method.name', 'DC');
model = func_algorithm_DC(data);

%% 4.8.2 DCPF with ordinary least squares
model = daline.fit(data, 'method.name', 'DC_LS'); 
model = func_algorithm_DC_LS(data);

%% 4.8.3 Decoupled linearized power flow (DLPF)
model = daline.fit(data, 'method.name', 'DLPF');
model = func_algorithm_DLPF(data);

%% 4.8.4 DLPF corrected in a data-driven manner
model = daline.fit(data, 'method.name', 'DLPF_C'); 
model = func_algorithm_DLPF_C(data);

%% 4.8.5 Power transfer distribution factor (PTDF)
model = daline.fit(data, 'method.name', 'PTDF'); 
model = func_algorithm_PTDF(data);

%% 4.8.6 First-order Taylor approximation
model = daline.fit(data, 'method.name', 'TAY');
model = daline.fit(data, 'method.name', 'TAY', 'TAY.point0', 1);
model = func_algorithm_TAY(data, 'TAY.point0', 1);
opt = daline.setopt('method.name', 'TAY', 'TAY.point0', 1); 
model = daline.fit(data, opt);
opt = daline.setopt('TAY.point0', 1); 
model = func_algorithm_TAY(data, opt);

%% 4.9.1 Direct QR decomposition
model = daline.fit(data, 'method.name', 'QR');
model = daline.fit(data, 'method.name', 'QR', 'variable.predictor', {'P'}, 'variable.response', {'PF', 'Vm'});
opt = daline.setopt('method.name', 'QR', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF'});
model = daline.fit(data, opt);
model = func_algorithm_QR(data, 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'QF'});
opt = daline.setopt('variable.predictor', {'P', 'Q'}, 'variable.response', {'PF'});
model = func_algorithm_QR(data, opt);

%% 4.9.2 Direct left division
model = daline.fit(data, 'method.name', 'LD');
model = daline.fit(data, 'method.name', 'LD', 'variable.predictor', {'P'}, 'variable.response', {'PF', 'Vm'});
opt = daline.setopt('method.name', 'LD', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF'});
model = daline.fit(data, opt);
model = func_algorithm_LD(data, 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'QF'});
opt = daline.setopt('variable.predictor', {'P', 'Q'}, 'variable.response', {'PF'});
model = func_algorithm_LD(data, opt);

%% 4.9.3 Direct generalized inverse
model = daline.fit(data, 'method.name', 'PIN');
model = daline.fit(data, 'method.name', 'PIN', 'variable.predictor', {'P'}, 'variable.response', {'PF', 'Vm'});
opt = daline.setopt('method.name', 'PIN', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF'});
model = daline.fit(data, opt);
model = func_algorithm_PIN(data, 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'QF'});
opt = daline.setopt('variable.predictor', {'P', 'Q'}, 'variable.response', {'PF'});
model = func_algorithm_PIN(data, opt);

%% 4.9.4 Direct singular value decomposition
model = daline.fit(data, 'method.name', 'SVD');
model = daline.fit(data, 'method.name', 'SVD', 'variable.predictor', {'P'}, 'variable.response', {'PF', 'Vm'});
opt = daline.setopt('method.name', 'SVD', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF'});
model = daline.fit(data, opt);
model = func_algorithm_SVD(data, 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'QF'});
opt = daline.setopt('variable.predictor', {'P', 'Q'}, 'variable.response', {'PF'});
model = func_algorithm_SVD(data, opt);

%% 4.9.5 Direct complete orthogonal decomposition
model = daline.fit(data, 'method.name', 'COD');
model = daline.fit(data, 'method.name', 'COD', 'variable.predictor', {'P'}, 'variable.response', {'PF', 'Vm'});
opt = daline.setopt('method.name', 'COD', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF'});
model = daline.fit(data, opt);
model = func_algorithm_COD(data, 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'QF'});
opt = daline.setopt('variable.predictor', {'P', 'Q'}, 'variable.response', {'PF', 'Vm'});
model = func_algorithm_COD(data, opt);

%% 4.9.6 Direct principal component analysis
model = daline.fit(data, 'method.name', 'PCA');
model = daline.fit(data, 'method.name', 'PCA', 'variable.predictor', {'P'}, 'variable.response', {'PF', 'Vm'}, 'PCA.parallel', 1, 'PCA.PerComponent', [30:10:90], 'PCA.numFold', 5);
opt = daline.setopt('method.name', 'PCA', 'variable.predictor', {'P'}, 'variable.response', {'PF', 'Vm'}, 'PCA.PerComponent', [30:10:90], 'PCA.numFold', 5);
model = daline.fit(data, opt);
model = func_algorithm_PCA(data, 'variable.predictor', {'P'}, 'variable.response', {'PF', 'Vm'}, 'PCA.PerComponent', [30:10:90], 'PCA.numFold', 5);
opt = daline.setopt('variable.predictor', {'P'}, 'variable.response', {'PF', 'Vm'}, 'PCA.PerComponent', [30:10:90], 'PCA.numFold', 5);
model = func_algorithm_PCA(data, opt);

%% 4.10 Mixed integer programming
data = daline.data('case.name', 'case39', 'voltage.varyIndicator', 0, 'load.upperRangeTime', 1.2, 'load.lowerRangeTime', 0.8, 'data.parallel', 0);
data = daline.normalize(data);
model = daline.fit(data, 'method.name', 'OI', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'Vm', 'PF'});
model = daline.fit(data, 'method.name', 'OI', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF'}, 'OI.outlierRatio', 0.1, 'OI.theta', 0.9);
opt = daline.setopt('method.name', 'OI', 'variable.predictor', {'P', 'Q'}, 'variable.response', {'PF'}, 'OI.outlierRatio', 0.1, 'OI.theta', 0.9);
model = daline.fit(data, opt);