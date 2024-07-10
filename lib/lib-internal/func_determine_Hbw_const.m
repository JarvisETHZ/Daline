function const = func_determine_Hbw_const(X_train, Y_train, D, algorithm, opt)
% Determine the best tuning constant of LS_Hbw according to user
% settings, e.g., given value, or cross-validation for tuning

% Tune this hyperparameter
% Check if opt.HBW.TuningConst is a scalar or a vector
if isscalar(opt.HBW.TuningConst)
    % If it's a scalar, use it
    const = opt.HBW.TuningConst;
else
    % If it's a vector, call func_tune_PCA to select the best percentage of components
    if opt.HBW.parallel
        disp('Pallelization starts to tune the tuning constant in LS_HBW')
    else
        disp('Start to tune the tuning constant in LS_HBW')
    end
    const = func_tune_Hbw(X_train, Y_train, D, algorithm, opt.HBW.parallel, opt.HBW.TuningConst, opt.HBW.numFold, opt.HBW.fixCV, opt.HBW.fixSeed);
end