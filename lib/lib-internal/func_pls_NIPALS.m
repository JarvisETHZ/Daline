function [T, P, U, Q, B, W, Beta] = func_pls_NIPALS(X, Y, opt)
% func_pls_NIPALS performs Partial Least Squares Regrassion using nonlinear 
% iterative partial least squares (NIPALS) algorithm.
%
% X = T*P' + E;
% Y = U*Q' + F;
%
% Inputs:
% X     data matrix of independent variables
% Y     data matrix of dependent variables
% tol   the tolerant of convergence (defaut 1e-10)
% 
% Outputs:
% T     score matrix of X
% P     loading matrix of X
% U     score matrix of Y
% Q     loading matrix of Y
% B     matrix of regression coefficient, diagonal matrix
% W     weight matrix of X
% Beta  Beta in the regression model where Y=X*Beta.
%
% Using the PLS model, the regression coefficients can be given by
% Beta = (W/(P'*W))*B*Q'.
%
% Modified from Yi Cao (2023). Partial Least-Squares and Discriminant 
% Analysis (https://www.mathworks.com/matlabcentral/fileexchange/18760-partial-least-squares-and-discriminant-analysis), 
% MATLAB Central File Exchange. Retrieved August 24, 2023.
%
% Modification: 
%  1. w=w/norm(w) => w/(u'*u)
%  2. norm(Y) > inner_tol => norm(X) > inner_tol; Because E_r = 0 at the end,
%     where E_r is X in this code (see: Eq13 in Recursive PLS algorithms for adaptive data modeling)
%  3. Beta = P*B*Q' => Beta = (W/(P'*W))*B*Q'
%
% Ref.:
%   Qin, S.J., 1998. Recursive PLS algorithms for adaptive data modeling. 
%   Computers & Chemical Engineering, 22(4-5), pp.503-514.

%% Start

% Get threshold
inner_tol = opt.PLS.innerTol;
outer_tol = opt.PLS.outerTol;

% Size of x and y
[rX, cX] = size(X);
[rY, cY] = size(Y);

% Number of components: see below, when norm(X) < inner_tol, k is almost the rank of X, 
% so make n as large as possible. In the end, n is (almost) the rank of X
n = max(cX, cY); 

% Allocate memory to the maximum size 
T = zeros(rX, n);
P = zeros(cX, n);
U = zeros(rY, n);
Q = zeros(cY, n);
B = zeros(n,  n);
W = P;
k = 0;

% Perform inner iteration loop if residual is larger than specfied
while norm(X) > inner_tol && k < n  % when norm(X) < inner_tol, k is almost the rank of X, so make n as large as possible
    
    % Initialization: choose the column of x with the largest square of sum as t.  
    [~, tidx] =  max(sum(X.*X));
    % Initialization: choose the column of y with the largest square of sum as u.  
    [~, uidx] =  max(sum(Y.*Y));
    t1 = X(:, tidx);
    u = Y(:, uidx);
    t = zeros(rX, 1);

    % Perform outer iteration for outer modeling until convergence
    while norm(t1-t) > outer_tol
        w = X'*u;
        w = w/(u'*u);
        t = t1;
        t1 = X*w/norm(X*w);
        q = Y'*t1;
        q = q/norm(q);
        u = Y*q;
    end
    
    % Update p based on t
    t = t1;
    p = X'*t/(t'*t);
    
    % Get regression and residuals
    b = u'*t/(t'*t);
    X = X - t*p';
    Y = Y - b*t*q';
    
    % Save iteration results to outputs:
    k = k + 1;
    T(:, k) = t;
    P(:, k) = p;
    U(:, k) = u;
    Q(:, k) = q;
    W(:, k) = w;
    B(k, k) = b;
end

% Wrap the output
T(:, k+1:end) = [];
P(:, k+1:end) = [];
U(:, k+1:end) = [];
Q(:, k+1:end) = [];
W(:, k+1:end) = [];
B = B(1:k, 1:k);
Beta = (W/(P'*W))*B*Q';
