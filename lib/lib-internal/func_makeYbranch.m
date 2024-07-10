%%  Funtion
function Yft = func_makeYbranch(mpc)
% Note: This function is learned from makeYbus of MATPOWER.

% Get info
branch  = mpc.branch;
num_branch = size(branch, 1);       %% number of lines

% define named indices into bus, branch matrices
[PQ, PV, REF, NONE, BUS_I, BUS_TYPE, PD, QD, GS, BS, BUS_AREA, VM, ...
    VA, BASE_KV, ZONE, VMAX, VMIN, LAM_P, LAM_Q, MU_VMAX, MU_VMIN] = idx_bus;
[F_BUS, T_BUS, BR_R, BR_X, BR_B, RATE_A, RATE_B, RATE_C, ...
    TAP, SHIFT, BR_STATUS, PF, QF, PT, QT, MU_SF, MU_ST, ...
    ANGMIN, ANGMAX, MU_ANGMIN, MU_ANGMAX] = idx_brch;

% Build the branch admittance
stat = branch(:, BR_STATUS);                   
Ys = stat ./ (branch(:, BR_R) + 1j * branch(:, BR_X));                         
tap = ones(num_branch, 1);                             
i = find(branch(:, TAP));                      
tap(i) = branch(i, TAP);                        
tap = tap .* exp(1j*pi/180 * branch(:, SHIFT)); 
Yft = - Ys ./ conj(tap);