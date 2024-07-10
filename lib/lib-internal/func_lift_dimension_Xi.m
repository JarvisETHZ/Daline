function X_lift = func_lift_dimension_Xi(X, opt)
% func_lift_dimension_Xi lifts the dimension of X using Koopman operator
%
% Here, fb is defined according to Eq.(12) in Ref.1, where 
% fb(n, i) = (X(n, i) - c(i, :, n)) * (X(n, i) - c(i, :, n))'
%
% Ref.1. L. Guo, Y. Zhang, X. Li, Z. Wang, Y. Liu, L. Bai, and C. Wang,
% “Data-driven power flow calculation method: A lifting dimension linear
% regression approach,” IEEE Transactions on Power Systems, 2021. 
%
% Ref.2. Korda, M. and Mezić, I., 2018. Linear predictors for nonlinear dynamical
% systems: Koopman operator meets model predictive control. Automatica,
% 93, pp.149-160. open source code https://github.com/MilanKorda/KoopmanMPC/raw/master/KoopmanMPC.zip


%% Start

% Fix randomness for C if requested
if opt.variable.liftFixC
    rng(88)
end

% Get numbers
[Ns, Nx] = size(X);

% Set the number of dimensions to be lifted Nd
% The predictors in X from 1 to Nd will be lifted
Nd = opt.variable.liftNumDim;
if isempty(Nd) || Nd > Nx
    Nd = Nx;   % The maximum is Nx
elseif Nd < 0
    Nd = 0;    % The minimum is 0
end

% Get the max & min for each col of X => the interval to randomly generate C
Xmax = max(X);
Xmin = min(X);

% Generate c, for each sample, and each predictor (to be lifted), there is a row vector c of 1-by-Nx
% That is, for sample n, for predictor i (to be lifted), the base vector is c(i, :, n)
c = zeros(Nd, Nx, Ns);
for n = 1 : Ns
    for i = 1 : Nd
        c(i, :, n) = Xmin + rand(size(Xmin)) .* (Xmax - Xmin);
    end
end

% Form base function fb(X-ci) for each sample n and predictor i (to be lifted)
fb = zeros(Ns, Nd);
for n = 1 : Ns
    % For each predictor to be lifted
    for i = 1 : Nd
        fb(n, i) = (X(n, i) - c(i, :, n)) * (X(n, i) - c(i, :, n))';
    end
end

% Form lift function f_lift(X-ci) for each sample n and predictor i (to be lifted)
% The case suffixed with ref refers to the case from Data-driven power flow calculation method: A lifting dimension linear
% regression approach; other cases are from the open source code https://github.com/MilanKorda/KoopmanMPC/raw/master/KoopmanMPC.zip
fl = zeros(Ns, Nd);
switch opt.variable.liftType
    case 'thinplate'
        % For each sample
        for n = 1 : Ns
            fl(n, :) = fb(n, :) .* log(sqrt(fb(n, :)));
            fl(isnan(fl)) = 0;  % This is suggested by the open source code 
        end
    case 'gauss'
        % For each sample
        for n = 1 : Ns
            fl(n, :) = exp(-opt.variable.liftEps^2*fb(n, :));
            fl(isnan(fl)) = 0;  % This is suggested by the open source code
        end
    case 'polyharmonic'
        % For each sample
        for n = 1 : Ns
            fl(n, :) = fb(n, :).^(opt.variable.liftK/2) .* log(sqrt(fb(n, :)));
            fl(isnan(fl)) = 0;  % This is suggested by the open source code 
        end
    case 'invquad'
        % For each sample
        for n = 1 : Ns
            fl(n, :) = 1 ./ (1 + opt.variable.liftEps^2*fb(n, :));
        end
    case 'invmultquad'
        % For each sample
        for n = 1 : Ns
            fl(n, :) = 1 ./ sqrt((1 + opt.variable.liftEps^2*fb(n, :)));
        end
    case 'polyharmonic_ref'
        % For each sample
        for n = 1 : Ns
            fl(n, :) = sqrt(fb(n, :)) .* log(sqrt(fb(n, :)));
            fl(isnan(fl)) = 0;  % This is suggested by the open source code https://github.com/MilanKorda/KoopmanMPC/raw/master/KoopmanMPC.zip
        end
    case 'invquad_ref'
        % For each sample
        for n = 1 : Ns
            fl(n, :) = 1 ./ (1 + exp(fb(n, :)));
        end
    case 'invmultquad_ref'
        % For each sample
        for n = 1 : Ns
            fl(n, :) = 1 ./ sqrt((1 + exp(fb(n, :))));
        end
end

% Output X_lift
X_lift = [X, fl];

