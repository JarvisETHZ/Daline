function [CB, cvx_status] = func_solve_LCP_Couple(X, Y, opt)

% Get numbers
num_branch = size(Y, 2);  
[num_sample, num_X_var]  = size(X);
num_X_var_half = num_X_var / 2;

% Get the index of From_bus and To_bus
idx.F = opt.mpc.branch(:, opt.idx.F_BUS);
idx.T = opt.mpc.branch(:, opt.idx.T_BUS);

% Get the index of zero coefficients in each column of Beta, i.e., the
% coefficients other than those of Va_F, Va_T, Vm_F, and Vm_T.
% For line n, in Beta:
%     idx.F(n) refers to the row index of Va_F
%     idx.T(n) refers to the row index of Va_T
%     num_X_var_half+idx.F(n) refers to the row index of Vm_F
%     num_X_var_half+idx.T(n) refers to the row index of Vm_T
idx.zero    = zeros(num_X_var-4, num_branch);
for n = 1:num_branch
    idx.nonzero = [idx.F(n), idx.T(n), num_X_var_half + idx.F(n), num_X_var_half + idx.T(n)];
    idx.zero(:, n) = setdiff([1:num_X_var]', idx.nonzero');
end

% Start CVX to solve the linearly constrained programming with coupling constraints for Beta
if opt.LCP.cvxQuiet
    cvx_quiet(true);          % Suppress CVX output
    disp('cvx starts to solve LCP_COU')
else
    cvx_quiet(false); 
end

% Start CVX to solve the problem
func_cvx_solver(opt.LCP.solver)  % set solver
cvx_begin
    % Define the decision variables
    variable B(num_X_var, num_branch)
    variable C(1, num_branch)

    % Define the objective function  
    objective = sum(sum((Y - X * B - repmat(C, num_sample, 1)).^2));  

    % Minimize the objective
    minimize(objective)
    
    % Add constraints
    subject to
        % Define constraints individually for each line
        for n = 1:num_branch
            
            % Restrict coefficients for Va_F and Va_T such that they are opposite,
            % regardless of which one is From and which one is to.
            % For line n, in Beta:
            %     idx.F(n) refers to the row index of Va_F
            %     idx.T(n) refers to the row index of Va_T
            B(idx.F(n), n) + B(idx.T(n), n) <= opt.LCP.coupleDelta;
            - opt.LCP.coupleDelta <= B(idx.F(n), n) + B(idx.T(n), n);
            
            % Restrict other coefficients as zero
            B(idx.zero(:, n), n) == 0; 
        end
cvx_end 

% Combine the coefficients together
CB = [C; B];