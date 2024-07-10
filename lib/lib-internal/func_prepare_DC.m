function [X_test, B, pq, pvq, ref, Bf, Pfinj, baseMVA] = func_prepare_DC(X, opt)

% Deal the system
[baseMVA, bus, gen, branch] = deal(opt.mpc.baseMVA, opt.mpc.bus, opt.mpc.gen, opt.mpc.branch);

% get bus index lists of each type of bus
[ref, pv, pq] = bustypes(bus, gen);
pvq = [pv; pq];

% Get testing data => no need to train
P_test  = X.P;               % sorted by [pv; pq]; derived from real(makeSbus(baseMVA, bus, gen))
Va_test = X.Va * (pi/180);   % convert to radian

% build B matrices and phase shift injections
% Note that phase shifters and real shunts have not changed when generating the dataset,
% hence, for each observations, the contributions of phase shifters and
% real shunts remain the same!
[B, Bf, Pbusinj, Pfinj] = makeBdc(baseMVA, bus, branch);

% compute complex bus power injections (generation - load)
% adjusted the independent variables to account for the fixed phase shifters and real shunts
% according to Pbus = real(makeSbus(baseMVA, bus, gen)) - Pbusinj - bus(:, GS) / baseMVA;
% now X_test is still Ns-by-Nx
P_test = P_test' - Pbusinj(pvq) - bus(pvq, opt.idx.GS) / baseMVA;
P_test = P_test'; 

% combine P_test and Va_test
X_test = [P_test, Va_test];

% Convert X_test according to (Pbus([pv; pq]) - B([pv; pq], ref) * Va0(ref))
X_test = X_test * [eye(size(P_test, 2)); - B([pv; pq], ref)'];