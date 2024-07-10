function [PF, PT, QF, QT, coeff_PFQF_VCS] = func_compute_flowVCS(opt, V2CS)
% Build the linear model between Pij, Qij, Pji, Qji and VCS
% Compute the branch flow results using the linear model
% V2CS: [Vm.^2, C, S] 

%% Start

% Get systems
mpc = opt.mpc;
branch = opt.mpc.branch;

% Get numbers
num_branch = size(mpc.branch, 1);
num_bus = size(mpc.bus, 1);

% Form Ybranch, aim to get the admittance at line, e.g., Yij/t
YBranch = func_makeYbranch(mpc);
G_branch = real(YBranch);   % Note that G_branch(l) = - g_l, i.e., also negetive, like in Ybus
B_branch = imag(YBranch);   % Note that B_branch(l) = - b_l, i.e., also negetive, like in Ybus

% Form Tap
tap = ones(num_branch, 1);                              %% default tap ratio = 1
idx_tap = find(branch(:, opt.idx.TAP));                         %% indices of non-zero tap ratios
tap(idx_tap) = branch(idx_tap, opt.idx.TAP);                        %% assign non-zero tap ratios

% Define linear mapping coefficients
coeff_PFQF_VCS = zeros(num_branch * 4, num_bus + num_branch * 2);

% Fill in Coeff
for l = 1:num_branch
    % PF, QF
    % Get index of from bus, don't need to bus here
    i = branch(l, opt.idx.F_BUS);
    % Get the line admittance and tap ratio, already divided by tap for one time (Refer to DLPF paper)
    gij = - G_branch(l);
    bij = - B_branch(l);
    t = tap(l);
    % Get the admittance for vi^2, should be yij/tap^2, i.e. gij/tap and bij/tap
    % Note that line charging susceptance only affacts coeff between Qij and vi^2 (Refer to pfsoln.m)
    % Also, line charging susceptance should be divided by tap^2
    % Besides, shunt will not influnce Pij or Qij, but influnce Pi and Qi (considered in that case)
    gij_vi2 = gij/t;
    bij_vi2 = bij/t + branch(l, opt.idx.BR_B)/2/(t * conj(t));  
    % Fill in 
    coeff_PFQF_VCS(l, i) = gij_vi2;                               % Pij - vi^2
    coeff_PFQF_VCS(l, l+num_bus) = - gij;                         % Pij - Cij
    coeff_PFQF_VCS(l, l+num_bus+num_branch) = - bij;              % Pij - Sij
    coeff_PFQF_VCS(l+num_branch, i) = - bij_vi2;                  % Qij - vi^2
    coeff_PFQF_VCS(l+num_branch, l+num_bus) = bij;                % Qij - Cij
    coeff_PFQF_VCS(l+num_branch, l+num_bus+num_branch) = - gij;   % Qij - Sij
    
    % PT, QT
    % Get index of To bus, don't need from bus here
    i = branch(l, opt.idx.T_BUS);
    % Get the line admittance and tap ratio, already divided by tap for one time (Refer to DLPF paper)
    gij = - G_branch(l);
    bij = - B_branch(l);
    t = tap(l);
    % Get the admittance for vi^2, should be yij/tap^2, i.e. gij/tap and bij/tap
    % Note that line charging susceptance only affacts coeff between Qij and vi^2 (Refer to pfsoln.m)
    % Also, line charging susceptance should be divided by tap^2
    % Besides, shunt will not influnce Pij or Qij, but influnce Pi and Qi (considered in that case)
    gij_vi2 = gij*t;                      % To-end, original value, so times tap as gij is already divided by tap!
    bij_vi2 = bij*t + branch(l, opt.idx.BR_B)/2;  % To-end, original value, so times tap as bij is already divided by tap!
    % Fill in 
    coeff_PFQF_VCS(l+2*num_branch, i) = gij_vi2;                               % Pij - vi^2
    coeff_PFQF_VCS(l+2*num_branch, l+num_bus) = - gij;                         % Pij - Cij
    coeff_PFQF_VCS(l+2*num_branch, l+num_bus+num_branch) = + bij;              % Pij - Sij
    coeff_PFQF_VCS(l+3*num_branch, i) = - bij_vi2;                  % Qij - vi^2
    coeff_PFQF_VCS(l+3*num_branch, l+num_bus) = bij;                % Qij - Cij
    coeff_PFQF_VCS(l+3*num_branch, l+num_bus+num_branch) = + gij;   % Qij - Sij
end

% Transpose the linear mapping
coeff_PFQF_VCS = coeff_PFQF_VCS';

% Get results
flow = V2CS * coeff_PFQF_VCS * mpc.baseMVA;
PF = flow(:, 1:num_branch);
QF = flow(:, num_branch+1:2*num_branch);
PT = flow(:, 2*num_branch+1:3*num_branch);
QT = flow(:, 3*num_branch+1:end);

% % Target result - tested: okay!
% result = runpf(mpc);
% PLQL_target = [result.branch(:, opt.idx.PF);result.branch(:, opt.idx.QF);result.branch(:, opt.idx.PT);result.branch(:, opt.idx.QT)] / mpc.baseMVA;
% 
% % Test result
% idx_fbus_l = branch(:, opt.idx.F_BUS);
% idx_tbus_l = branch(:, opt.idx.T_BUS);
% V2 = result.bus(:, opt.idx.VM).^2;
% C = result.bus(idx_fbus_l, opt.idx.VM) .* result.bus(idx_tbus_l, opt.idx.VM) .* cosd(result.bus(idx_fbus_l, opt.idx.VA) - result.bus(idx_tbus_l, opt.idx.VA));
% S = result.bus(idx_fbus_l, opt.idx.VM) .* result.bus(idx_tbus_l, opt.idx.VM) .* sind(result.bus(idx_fbus_l, opt.idx.VA) - result.bus(idx_tbus_l, opt.idx.VA));
% VCS = [V2;C;S];
% PFQF_test = coeff_PFQF_VCS * VCS;
% 
% % Test accuracy
% error_PFQF_VCS = abs(PLQL_target - PFQF_test);
% max(abs(error_PFQF_VCS(:)))



