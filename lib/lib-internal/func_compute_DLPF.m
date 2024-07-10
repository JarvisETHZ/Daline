function [busAgl,busVol,BranchFlow]=func_compute_DLPF(mpc)
% This code realizes Decoupled Linearized Power Flow (DLPF)
% The code is from the open source code of the reference papar, with only
% one change. That is, the original open source code set the reference
% angle as the slack bus always as zero. Hence, in the open source code,
% the contribution from the reference angle has been removed. Here, we add
% the contribution from the reference angle, regardless of its value.
%
% ref. Yang, J., Zhang, N., Kang, C. and Xia, Q., 2016. A state-independent
% linear power flow model with accurate estimation of voltage magnitude.
% IEEE Transactions on Power Systems, 32(5), pp.3607-3617.  

% Define matpower constants
define_constants;
% Load case
[baseMVA, bus, gen, branch] = deal(mpc.baseMVA, mpc.bus, mpc.gen, mpc.branch);
[ref, pv, pq] = bustypes(bus, gen);

% Matrices in equation (8)
Ybus = makeYbus(mpc);
Gbus = real(Ybus);
Bbus = imag(Ybus);
GP = Gbus;
BD = diag(sum(Bbus));             %shunt elements
BP = -Bbus + BD;
BQ = -Bbus;
GQ = -Gbus;                       %GQ approxiately equals -Gbus
Sbus = makeSbus(baseMVA, bus, gen);
Pbus = real(Sbus);
Qbus = imag(Sbus);

% Matrices in equation (11)
%      | Pm1 |   | B11  G12 |   | delta   |   
%      |     | = |          | * |         | 
%      | Qm1 |   | G21  B22 |   | voltage | 
B11 = BP([pv;pq],[pv;pq]);  
G12 = GP([pv;pq],pq);
G21 = GQ(pq,[pv;pq]);
B22 = BQ(pq,pq);
Pm1 = Pbus([pv;pq]) -BP([pv;pq], ref)*bus(ref,VA)*pi/180 - GP([pv;pq],ref)*bus(ref,VM) - GP([pv;pq],pv)*bus(pv,VM);
Qm1 = Qbus(pq) -GQ(pq,  ref)*bus(ref,VA)*pi/180 - BQ(pq,ref)*bus(ref,VM) - BQ(pq,pv)*bus(pv,VM);
% Pm1 = Pbus([pv;pq]) - GP([pv;pq],ref)*bus(ref,VM) - GP([pv;pq],pv)*bus(pv,VM);
% Qm1 = Qbus(pq)  - BQ(pq,ref)*bus(ref,VM) - BQ(pq,pv)*bus(pv,VM);

% Matrices in equation (17)
t1 =G12/B22;
t2 =G21/B11;
B11m = B11 - t1*G21;
B22m = B22 - t2*G12;
Pm2 = Pm1 - t1*Qm1;
Qm2 = Qm1 - t2*Pm1;

% Calculate voltage magnitude
n = size(bus,1);
busVol = zeros(n,1);
busVol(ref) = bus(ref,VM);
busVol(pv) = bus(pv,VM);
busVol(pq) = B22m\Qm2;
% Calculate voltage phase angle
busAgl = ones(n,1)*bus(ref,VA);
busAgl([pv;pq]) = busAgl([pv;pq]) + B11m\Pm2/pi*180;
% Calculate line lossless MW flow
BranchFlow = (busVol(branch(:,F_BUS))./branch(:,TAP)-busVol(branch(:,T_BUS))).*branch(:,BR_R)./(branch(:,BR_X).^2+branch(:,BR_R).^2)*baseMVA ...
    +(busAgl(branch(:,F_BUS))-busAgl(branch(:,T_BUS))).*branch(:,BR_X)./(branch(:,BR_X).^2+branch(:,BR_R).^2)/180*pi./branch(:,TAP)*baseMVA;


