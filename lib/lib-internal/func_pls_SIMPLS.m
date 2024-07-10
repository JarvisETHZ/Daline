function Beta = func_pls_SIMPLS(X, Y)
% func_pls_SIMPLS generates the regression coefficient Beta using partial
% least squares with SIMPLS. This function also adds intercept
% automatically. 
%
% This function is modified from the built-in function plsregress, the only
% difference is that we extract the centered data X0 so that we can use the
% rank of X0 as the number of components.
%
% Note: 
%
%   the number of component is set as the rank of X.
%
%   Use the rank of X0 (centered predictors) will significantly improve
%   accuracy (error: from 1e-5 to 1e-10, TimeSeries), compared to using the
%   rank of X.
%
%   Remove all-one from X and add it back later will significantly improve
%   accuracy (error: from incredibly large to 1e-5, Random).

%% Start
% Center both predictors and response, and do PLS
meanX = mean(X, 1);
meanY = mean(Y, 1);
X0 = bsxfun(@minus, X, meanX);
Y0 = bsxfun(@minus, Y, meanY);
% PLS training
[Yloadings, Weights] = func_solve_SIMPLS(X0, Y0, rank(X0));
Beta = Weights * Yloadings';
Beta = [meanY - meanX*Beta; Beta];