function [X, D] = func_decompose_PCA(X, numComponentRatio)
% Get the number of principal components
Nx = size(X, 2);
Np = round(Nx * numComponentRatio / 100);

% Principal component analysis for X_train; no dimension reduction here
D0 = pca(X);
D  = D0(:, 1:Np);

% Convert X
X = X * D;