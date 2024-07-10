function func_algorithm_DC_forTest(data, opt)
% Training algorithm: classic DC model, on the basis of MATPOWER
% Tested by comparing this function to runpf of MATPOWER when using DCPF

%% Start

% Deal the system
[baseMVA, bus, gen, branch] = deal(opt.mpc.baseMVA, opt.mpc.bus, opt.mpc.gen, opt.mpc.branch);

% get bus index lists of each type of bus
[ref, pv, pq] = bustypes(bus, gen);
pvq = [pv; pq];

% Get testing data => no need to train
P_test = real(makeSbus(baseMVA, bus, gen))';
P_test = P_test(:, pvq);
Va_test = opt.mpc.bus(ref, opt.idx.VA);
% P_test  = X.test.P;    % sorted by [pv; pq]; derived from real(makeSbus(baseMVA, bus, gen))
% Va_test = X.test.Va * (pi/180); 
Y_test  = Y.test.Va;



% build B matrices and phase shift injections
% Note that phase shifters and real shunts have not changed when generating the dataset,
% hence, for each observations, the contributions of phase shifters and
% real shunts remain the same!
[B, ~, Pbusinj, ~] = makeBdc(baseMVA, bus, branch);

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

% Get the regression matrix Beta
Beta = inv(B([pv; pq], [pv; pq]))' * (180/pi);       

% Get Va according to Va([pv; pq]) = B([pv; pq], [pv; pq]) \ (Pbus([pv; pq]) - B([pv; pq], ref) * Va0(ref))
Va_pred = X_test * Beta;   % sorted by [pv; pq]
Va_pred=Va_pred';
% Test the accuracy

