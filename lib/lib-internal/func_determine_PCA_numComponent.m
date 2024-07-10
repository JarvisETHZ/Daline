function Np = func_determine_PCA_numComponent(X_train, Y_train, opt)
% Determine the best number of components of PCA according to user
% settings, e.g., rank, given value, or cross-validation for tuning

switch opt.PCA.rank
    case 1
        % use rank as the number of components
        Np = rank(X_train);
    case 0
        % Tune this hyperparameter
        % Check if opt.PCA.PerComponent is a scalar or a vector
        if isscalar(opt.PCA.PerComponent)
            % If it's a scalar, use it
            Nx = size(X_train, 2);
            Np = round(Nx * opt.PCA.PerComponent / 100);
        else
            % If it's a vector, call func_tune_PCA to select the best percentage of components
            if opt.PCA.parallel
                disp('Pallelization starts to tune the percentage of components in PCA')
                best_PerComponent = func_tune_PCA_parallel(X_train, Y_train, opt.PCA.PerComponent, opt.PCA.numFold, opt.PCA.fixCV, opt.PCA.fixSeed);
            else
                disp('Start to tune the percentage of components in PCA')
                best_PerComponent = func_tune_PCA(X_train, Y_train, opt.PCA.PerComponent, opt.PCA.numFold, opt.PCA.fixCV, opt.PCA.fixSeed);
            end
            Nx = size(X_train, 2);
            Np = round(Nx * best_PerComponent / 100);
        end
end