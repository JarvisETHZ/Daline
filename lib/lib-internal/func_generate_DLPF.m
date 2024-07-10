function Beta = func_generate_DLPF(mpc, idx)
% This code generates the coefficients for Decoupled Linearized Power Flow (DLPF)
% Beta maps all known to some unknown:
%      | Va_pvq |            | P_pvq  |
%      | Vm_pq  | =  Beta *  | Q_pq   |
%      |   PF   |            | Va_ref |
%      |   PT   |            | Vm_ref |
%                            | Vm_pv   |
%
% Note:
%  
% The code is from the open source code of the reference papar, with only
% one change. That is, the original open source code set the reference
% angle as the slack bus always as zero. Hence, in the open source code,
% the contribution from the reference angle has been removed. Here, we add
% the contribution from the reference angle, regardless of its value.
%
% When the reference angle is not zero, the absolute value of the resulting
% angles are significantly different from the AC results. However, the
% voltage result and branch flows are at pretty much the same accuracy
% level compared to the AC results. Hence, the absolute values of angles do
% not matter that much. The angles differences matter the most! Verifying
% the error of angles might not make much sense. 
%
% ref. Yang, J., Zhang, N., Kang, C. and Xia, Q., 2016. A state-independent
% linear power flow model with accurate estimation of voltage magnitude.
% IEEE Transactions on Power Systems, 32(5), pp.3607-3617.  



% Load case
[baseMVA, bus, gen, branch] = deal(mpc.baseMVA, mpc.bus, mpc.gen, mpc.branch);
[ref, pv, pq] = bustypes(bus, gen);
pvq = [pv;pq];
rpv = [ref;pv];


% Define numbers
Npq = length(pq);
Npv = length(pv);
Nref = length(ref);
Npvq = length(pvq);
Nrpv = length(rpv);
Nbus = Npvq + Nref;
Nknown = Npvq + Npq + Nref + Nref + Npv;
Nline  = size(branch, 1);

% Matrices in equation (8)
Ybus = makeYbus(mpc);
Gbus = real(Ybus);
Bbus = imag(Ybus);
GP = Gbus;
BD = diag(sum(Bbus));             %shunt elements
BP = -Bbus + BD;
BQ = -Bbus;
GQ = -Gbus;                       %GQ approxiately equals -Gbus

% Matrices in equation (11)
%      | Pm1 |   | B11  G12 |   | delta   |   
%      |     | = |          | * |         | 
%      | Qm1 |   | G21  B22 |   | voltage | 
B11 = BP(pvq,pvq);      % i.e., H, H = -B'= BP
G12 = GP(pvq,pq);       % i.e., N, N = +G = GP
G21 = GQ(pq,pvq);       % i.e., M, M = -G = GQ
B22 = BQ(pq,pq);        % i.e., L, L = -B = BQ
Beta1 = [B11, G12; G21, B22];

% Form the mapping matrix between Pm1, Qm1 and P_pvq, Q_pq, Va_ref, Vm_ref, V_pv
%      | Pm1 |                | P_pvq  |
%      |     | = | eye, A | * | Q_pq   |
%      | Qm1 |                | Va_ref |
%                             | Vm_ref |
%                             | V_pv   |
% Where A is actually the matrix before [Va_ref;Vm_ref;V_pv] in equation (12)
% Note that the sign follows the relation between G, B and GP, GQ, BP, BQ aforementioned 
A = [-BP(pvq, ref)*pi/180, -GP(pvq, rpv);
     -GQ(pq,  ref)*pi/180, -BQ(pq,  rpv)];
Beta2 = [eye(Npvq+Npq), A];

% Form the mapping matrix that maps P_pvq, Q_pq, Va_ref, Vm_ref, V_pv to Va_pvq, Vm_pq
%      | Va_pvq |                         | P_pvq  |
%      |        | = inv(Beta1) * Beta2 *  | Q_pq   |
%      | Vm_pq  |                         | Va_ref |
%                                         | Vm_ref |
%                                         | V_pv   |
% Separate the mapping matrix into two, one is for Va_all and one is for Vm_all
Beta_Vam = Beta1 \ Beta2;
Beta_Va  = Beta_Vam(1:Npvq,     :)/pi*180;
Beta_Vm  = Beta_Vam(Npvq+1:end, :);
Beta_Va(:, Npvq+Npq+1) = Beta_Va(:, Npvq+Npq+1) + 1;   % Add the ref angle to Va_pvq, according to the open source code, Va = Beta_Va * X + Va_ref: busAgl = ones(n,1)*bus(ref,VA); busAgl([pv;pq]) = busAgl([pv;pq]) + B11m\Pm2/pi*180;


% Define containers for the mapping matrix that maps P_pvq, Q_pq, Va_ref, Vm_ref, V_pv to Va_all, Vm_all
% The aim is to form the mapping matrix that maps P_pvq, Q_pq, Va_ref, Vm_ref, V_pv to branch flows
%      | Va_all |   | Beta_VaAll |   | P_pvq  |
%      |        | = |            | * | Q_pq   |
%      | Vm_all |   | Beta_VmAll |   | Va_ref |
%                                    | Vm_ref |
%                                    | V_pv   |
Beta_VaAll = zeros(Nbus, Nknown);
Beta_VmAll = zeros(Nbus, Nknown);

% For Beta_VaAll for all Va
Beta_VaAll(pvq, :) = Beta_Va;
Beta_VaAll(ref, :) = [zeros(Nref, Npvq+Npq), eye(Nref), zeros(Nref, Nrpv)];

% For Beta_VmAll for all Vm
Beta_VmAll(pq,  :) = Beta_Vm;
Beta_VmAll(rpv, :) = [zeros(Nrpv, Npvq+Npq+Nref), eye(Nrpv)];

% Form the mapping matrix that maps P_pvq, Q_pq, Va_ref, Vm_ref, V_pv to active branch flows 
Beta_PF = zeros(Nline, Nknown);
Beta_PT = zeros(Nline, Nknown);
for i = 1:Nline
    % Get the index of the from/to bus
    fbus = branch(i, idx.F_BUS);
    tbus = branch(i, idx.T_BUS);
    % Define some parameters to simply the following expression
    g_branch = branch(i, idx.BR_R) / (branch(i, idx.BR_X)^2 + branch(i, idx.BR_R)^2);
    b_branch = branch(i, idx.BR_X) / (branch(i, idx.BR_X)^2 + branch(i, idx.BR_R)^2);
    t_branch = branch(i, idx.TAP);
    % Extract the related mapping coefficients from Beta_VaAll and Beta_VmAll
    coeff_Vm_f = Beta_VmAll(fbus, :);
    coeff_Vm_t = Beta_VmAll(tbus, :);
    coeff_Va_f = Beta_VaAll(fbus, :);
    coeff_Va_t = Beta_VaAll(tbus, :);
    % Build the mapping matrix for each row 
    Beta_PF(i, :) = g_branch * (coeff_Vm_f/t_branch - coeff_Vm_t) / t_branch + ...
                    b_branch * (coeff_Va_f - coeff_Va_t) /180*pi / t_branch ;
    Beta_PT(i, :) = - Beta_PF(i, :);  % Lossless model <= DLPF
end
Beta_PF = Beta_PF * baseMVA;
Beta_PT = Beta_PT * baseMVA;

% Form the overall mapping matrix that maps all known to some unknown
%      | Va_pvq |            | P_pvq  |
%      | Vm_pq  | =  Beta *  | Q_pq   |
%      |   PF   |            | Va_ref |
%      |   PT   |            | Vm_ref |
%                            | V_pv   |
Beta = [Beta_Va; Beta_Vm; Beta_PF; Beta_PT];

% For test => comparison with DLPF; tested okay!
% Sbus = makeSbus(baseMVA, bus, gen);
% Pbus = real(Sbus);
% Qbus = imag(Sbus);
% P_pvq = Pbus(pvq);
% Q_pq = Qbus(pq);
% Va_ref = bus(ref, idx.VA);
% Vm_ref = bus(ref, idx.VM);
% Vm_pv  = bus(pv,  idx.VM);
% Va_pvq = Beta_Va * [P_pvq;Q_pq;Va_ref;Vm_ref;Vm_pv];
% Vm_pq = Beta_Vm * [P_pvq;Q_pq;Va_ref;Vm_ref;Vm_pv];
% VmAll = zeros(Nbus,1);
% VaAll = zeros(Nbus,1);
% VmAll(pq) = Vm_pq;
% VmAll(ref)= Vm_ref;
% VmAll(pv)= Vm_pv;
% VaAll(pvq) = Va_pvq;
% VaAll(ref) = Va_ref;
% PF = Beta_PF * [P_pvq;Q_pq;Va_ref;Vm_ref;Vm_pv];
% [BusAglAT,BusVolAT,BranchFlowAT] = func_compute_DLPF(mpc);




