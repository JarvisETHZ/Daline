function delta = func_determine_Hbl_direct_const(X_train, Y_train, algorithm, opt)
% Determine the best delta of LS_Hbl according to user
% settings, e.g., given value, or cross-validation for tuning

% Tune this hyperparameter
% Check if opt.HBW.TuningConst is a scalar or a vector
if isscalar(opt.HBL.delta)
    % If it's a scalar, use it
    delta = opt.HBL.delta;
else
    % If it's a vector, call func_tune_PCA to select the best percentage of components
    if opt.HBL.parallel
        disp('Pallelization starts to tune delta in LS_HBLD')
    else
        disp('Start to tune delta in LS_HBLD')
    end
    delta = func_tune_Hbl_direct(X_train, Y_train, algorithm, opt.HBL.parallel, opt.HBL.delta, opt.HBL.initialGuess, opt.HBL.directOptions, opt.HBL.numFold, opt.HBL.fixCV, opt.HBL.fixSeed);
end