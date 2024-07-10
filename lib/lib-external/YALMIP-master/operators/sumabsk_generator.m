function [Model,Properties] = sumabsk_generator(X,k,t,w)
[n,m] = size(X);
if min(n,m)==1 && length(w)==1
    % Non-weighted sum of k largest vector elements    
    Z = sdpvar(n,m);
    s = sdpvar(1,1);
    Model = (t-k*s-sum(Z) >= 0) + (Z >= 0) + (Z + s >= X >= -(Z + s));
    Properties = struct('convexity','convex','monotonicity','none','definiteness','positive','model','graph');
elseif min(n,m)==1
    % Weighted sum of k largest vector elements
    s = sdpvar(k,1);
    Z = sdpvar(n,k,'full');
    Model = [Z>=0];
    for i = 1:k-1
        Model = [Model, s(i) + Z(:,i) >= (w(i)-w(i+1))*X >= -(s(i) + Z(:,i))];
    end
    Model = [Model, s(k) + Z(:,k) >= w(k)*X >= -(s(k) + Z(:,k))];
    Model = [Model, t >= (1:k)*s+sum(sum(Z))];    
    Properties = struct('convexity','convex','monotonicity','none','definiteness','positive','model','graph');
elseif length(w)==1
    % Non-weighted sum of k largest eigenvalues
    [n,m] = size(X);
    Z = sdpvar(n,m);
    s = sdpvar(1,1);
    Model = [t-k*s-trace(Z) >= 0, Z >= 0, Z + s*eye(n) >= X >= -(Z + s*eye(n))];
    Properties = struct('convexity','convex','monotonicity','none','definiteness','positive','model','graph');
else
    s = sdpvar(k,1);
    Z = sdpvar(n*ones(1,k),n*ones(1,k));
    Model = [Z{k} >= 0];
    for i = 1:k-1
        Model = [Model, Z{i} >= 0];
        Model = [Model, s(i)*eye(n) + Z{i} >= (w(i)-w(i+1))*X >= -(s(i)*eye(n) + Z{i})];
    end
    Model = [Model, s(k)*eye(n) + Z{k} >= w(k)*X >= -(s(k)*eye(n) + Z{k})];
    r = 0;
    for i = 1:k
        r = r + i*s(i) + trace(Z{i});
    end
    Model = [Model, t >= r];    
    Properties = struct('convexity','convex','monotonicity','none','definiteness','positive','model','graph');
end