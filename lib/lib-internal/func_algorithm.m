function result = func_algorithm(data, opt)
% perform the selected algorithm by given the algorithm name


% Start
switch opt.method.name
    case 'LS'
        % Ordinary least squares
        result = func_algorithm_LS(data, opt);
    case 'QR'
        % Ordinary least squares with QR decomposition
        result = func_algorithm_QR(data, opt);
    case 'LD'
        % Ordinary least squares with Left divide (amount to QR decomposition)
        result = func_algorithm_LD(data, opt);
    case 'LS_PIN'
        % Ordinary least squares with generalized inverse
        result = func_algorithm_LS_PIN(data, opt);
    case 'PIN'
        % Direct generalized inverse
        result = func_algorithm_PIN(data, opt);
    case 'LS_SVD'
        % Least squares with singular value decomposition
        result = func_algorithm_LS_SVD(data, opt);
    case 'SVD'
        % Direct SVD
        result = func_algorithm_SVD(data, opt);
    case 'LS_COD'
        % Least squares with complete orthogonal decomposition
        result = func_algorithm_LS_COD(data, opt);
    case 'COD'
        % Direct complete orthogonal decomposition
        result = func_algorithm_COD(data, opt);
    case 'LS_PCA'
        % Least squares with principal component analysis
        result = func_algorithm_LS_PCA(data, opt);
    case 'PCA'
        % Direct principal component analysis
        result = func_algorithm_PCA(data, opt);
    case 'LS_HBW'
        % Least squares with Huber weighting function
        result = func_algorithm_LS_HBW(data, opt);
    case 'LS_HBLD'
        % Least squares with Huber loss function, directly solve
        result = func_algorithm_LS_HBLD(data, opt);
    case 'LS_HBLE'
        % Least squares with Huber loss function, use equivalent problem to solve
        result = func_algorithm_LS_HBLE(data, opt);
    case 'LS_GEN'
        % Generalized least squares
        result = func_algorithm_LS_GEN(data, opt);
    case 'LS_TOL'
        % Total least squares
        result = func_algorithm_LS_TOL(data, opt);
    case 'LS_CLS'
        % Least squares with clustering
        result = func_algorithm_LS_CLS(data, opt);
    case 'LS_LIFX'
        % Least squares with lifting dimension and Moore-Penrose inverse
        result = func_algorithm_LS_LIFX(data, opt);
    case 'LS_LIFXi'
        % Least squares with lifting dimension and Moore-Penrose inverse
        result = func_algorithm_LS_LIFXi(data, opt);
    case 'LS_WEI'
        % Least squares with programming, use weights for observations
        result = func_algorithm_LS_WEI(data, opt);
    case 'LS_REC'
        % Recursive least squares
        result = func_algorithm_LS_REC(data, opt);
    case 'LS_REP'
        % Repeated least squares
        result = func_algorithm_LS_REP(data, opt);
    case 'PLS_SIM'
        % Ordinary partial least squares with SIMPLS
        result = func_algorithm_PLS_SIM(data, opt);
    case 'PLS_SIMRX'
        % Ordinary partial least squares with SIMPLS using rank of X
        result = func_algorithm_PLS_SIMRX(data, opt);
    case 'PLS_NIP'
        % Ordinary partial least squares with NIPALS
        result = func_algorithm_PLS_NIP(data, opt);
    case 'PLS_BDL'
        % Partial least squares with bundling known and unknown variables
        result = func_algorithm_PLS_BDL(data, opt);
    case 'PLS_BDLY2'
        % Partial leas/t squares with bundling known and unknown variables, but P_ref is in Y2
        result = func_algorithm_PLS_BDLY2(data, opt);
    case 'PLS_BDLopen'
        % Partial least squares with bundling known and unknown variables --- the open source code, can only generate erros of Vm and Va
        result = func_algorithm_PLS_BDLopen(data, opt);
    case 'PLS_REC'
        % Recursive partial least squares with NIPALS only
        result = func_algorithm_PLS_REC(data, opt);
    case 'PLS_RECW'
        % Recursive partial least squares with NIPALS only, using weight for observations
        result = func_algorithm_PLS_RECW(data, opt);
    case 'PLS_REP'
        % Repeated partial least squares with NIPALS for time comparison
        result = func_algorithm_PLS_REP(data, opt);
    case 'PLS_CLS'
        % Partial least squares with clustering
        result = func_algorithm_PLS_CLS(data, opt);
    case 'RR'
        % Ordinary ridge regression
        result = func_algorithm_RR(data, opt);
    case 'RR_WEI'
        % Locally Weighted ridge regression
        result = func_algorithm_RR_WEI(data, opt);
    case 'RR_KPC'
        % Ordinary ridge regression with k-plane clustering
        result = func_algorithm_RR_KPC(data, opt);
    case 'RR_VCS'
        % Ordinary ridge regression with coordinate transformation: VCS
        result = func_algorithm_RR_VCS(data, opt);
    case 'SVR'
        % Ordinary support vector regression - solve the programming problem
        result = func_algorithm_SVR(data, opt);
    case 'SVR_POL'
        % Support vector regression with polynomial kernel
        result = func_algorithm_SVR_POL(data, opt);
    case 'SVR_CCP'
        % Support vector regression with chance-constrained programming
        result = func_algorithm_SVR_CCP(data, opt);
    case 'SVR_RR'
        % Support vector regression with ridge regression -  solve the programming problem - 
        result = func_algorithm_SVR_RR(data, opt);
    case 'LCP_BOXN'
        % Linearly constrained programming without box constraints for Beta
        result = func_algorithm_LCP_BOXN(data, opt);
    case 'LCP_BOX'
        % Linearly constrained programming with box constraints for Beta
        result = func_algorithm_LCP_BOX(data, opt);
    case 'LCP_JGDN'
        % Linearly constrained programming without Jacobian guidance using unnormalized data
        result = func_algorithm_LCP_JGDN(data, opt);
    case 'LCP_JGD'
        % Linearly constrained programming with Jacobian guidance constraints for Beta; using unnormalized data
        result = func_algorithm_LCP_JGD(data, opt);
    case 'LCP_COUN'
        % Linearly constrained programming without coupling constraints for Beta
        result = func_algorithm_LCP_COUN(data, opt);
    case 'LCP_COUN2'
        % Linearly constrained programming without coupling constraints for Beta; use Vm^2
        result = func_algorithm_LCP_COUN2(data, opt);
    case 'LCP_COU'
        % Linearly constrained programming with coupling constraints for Beta
        result = func_algorithm_LCP_COU(data, opt);
    case 'LCP_COU2'
        % Linearly constrained programming with coupling constraints for Beta; use Vm^2
        result = func_algorithm_LCP_COU2(data, opt);
    case 'DRC_XM'
        % Distributionally robust chance-constrained programming, moment based, consider X as random variable
        result = func_algorithm_DRC_XM(data, opt);
    case 'DRC_XYM'
        % Distributionally robust chance-constrained programming, moment based, consider X and Y as random variables
        result = func_algorithm_DRC_XYM(data, opt);
    case 'DRC_XYD'
        % Distributionally robust chance-constrained programming, divergence based, consider X and Y as random variables
        result = func_algorithm_DRC_XYD(data, opt);
    case 'DC'
        % DCPF; using unnormalized data
        result = func_algorithm_DC(data, opt);
    case 'DC_LS'
        % DCPF with ordinary least squares; using unnormalized data
        result = func_algorithm_DC_LS(data, opt);
    case 'DLPF'
        % DLPF, original, using unnormalized data
        result = func_algorithm_DLPF(data, opt);
    case 'DLPF_C'
        % DLPF, corrected by QR decomposition, using unnormalized data
        result = func_algorithm_DLPF_C(data, opt);
    case 'PTDF'
        % DC-based PTDF to compute branch flow, same PF result as the DC model
        result = func_algorithm_PTDF(data, opt);
    case 'TAY'
        % 1st order Taylor approximation
        result = func_algorithm_TAY(data, opt);  
    otherwise
        error(['Method "', opt.method.name, '" is not supported by the toolbox. This may be a typo. Please also ensure there are no spaces in the method name. If this is not a typo, please check the manual for the list of supported methods.']);
end