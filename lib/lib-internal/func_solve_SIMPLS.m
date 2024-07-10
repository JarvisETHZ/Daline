function [Yloadings, Weights] = func_solve_SIMPLS(X, Y, ncomp)
% Inputs:
%   X - Predictor matrix
%   Y - Response matrix
%   ncomp - Number of components
%
% Outputs:
%   Yloadings - Loadings for Y
%   Weights - Weights for X

[~, dx] = size(X);
dy = size(Y, 2);

% Preallocate output matrices
Yloadings = zeros(dy, ncomp);
Weights = zeros(dx, ncomp);

% Initialize variables for algorithm
V = zeros(dx, ncomp);  % Orthonormal basis for the span of the X loadings
Cov = X' * Y;  % Covariance matrix

for i = 1:ncomp
    [U, S, C] = svd(Cov, 'econ');
    r = U(:,1);
    c = C(:,1);
    S = S(1);

    t = X * r;
    normt = norm(t);
    t = t / normt;  % Normalize

    Xloadings = X' * t;
    q = S * c / normt;  % Loadings for Y
    Yloadings(:, i) = q;

    Weights(:, i) = r / normt;  % Weights

    % Update orthonormal basis V using modified Gram-Schmidt
    v = Xloadings;
    for repeat = 1:2
        for j = 1:i-1
            vj = V(:, j);
            v = v - (vj' * v) * vj;
        end
    end
    v = v / norm(v);
    V(:, i) = v;

    % Deflate the covariance matrix
    Cov = Cov - v * (v' * Cov);
    Vi = V(:, 1:i);
    Cov = Cov - Vi * (Vi' * Cov);
end
