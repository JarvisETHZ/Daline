%% Introduction
%  This function is from the open source code of the following reference:
%  Aim is to train the pls regression model
% 
%  Ref.: Y. Liu, N. Zhang, Y. Wang, J. Yang, and C. Kang, “Data-driven 
%  power flow linearization: A regression approach,” IEEE Transactions on 
%  Smart Grid, vol. 10, no. 3, pp. 2569–2580, 2018.

function [Xva, Xv, Xpf, Xqf] = func_pls_bundle(data, ref)
% this function conduct the inverse regression by calling different regressioin algorithms
    P = data.P;
    P(:, ref) = zeros;
    k = rank(P) + rank(data.Q) + 1;
    k = min(k, size(data.P, 1) - 1);
    X_pls = [P data.Q];
    Y_va_pls = data.Va  * pi / 180;
    Y_va_pls(:, ref) = data.P(:, ref);
    [~,~,~,~,Xva] = plsregress(X_pls, Y_va_pls, k);
    Xva = Xva';
    temp = Xva(:,1);Xva(:,1) = [];Xva = [Xva temp];

    Y_v_pls = data.Vm;
    [~,~,~,~,Xv] = plsregress(X_pls, Y_v_pls, k);
    Xv = Xv';
    temp = Xv(:,1);Xv(:,1) = [];Xv = [Xv temp];

    Y_pf_pls = data.PF;
    [~,~,~,~,Xpf] = plsregress(X_pls, Y_pf_pls, k);
    Xpf = Xpf';
    temp = Xpf(:,1);Xpf(:,1) = [];Xpf = [Xpf temp];

    Y_qf_pls = data.QF;
    [~,~,~,~,Xqf] = plsregress(X_pls, Y_qf_pls, k);
    Xqf = Xqf';
    temp = Xqf(:,1);Xqf(:,1) = [];Xqf = [Xqf temp];
end
