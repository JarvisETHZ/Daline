function [CB, success] = func_solve_LCP_Couple_individual(X, Y, Delta)

% Get numbers
[num_sample, num_branch] = size(Y);

% Start CVX to solve the problem
cvx_begin
    % Define the decision variables
    variable B(4, num_branch)
    variable C(1, num_branch)

    % Define the objective function
    objective = sum(norms(Y - X * B - repmat(C, num_sample, 1), 2, 2));  

    % Minimize the objective
    minimize(objective)
    
    % Add constraints
%     subject to
%         % Restrict coefficients for Va_F and Va_T are oppose,
%         % regardless of which one is From and which one is to.
%         %     idx.F(n) refers to the row index of Va_F
%         %     idx.T(n) refers to the row index of Va_T
%         B(1) + B(2) <= Delta;
%         - Delta <= B(1) + B(2);

cvx_end 

% Combine C and B together
CB = [C; B];

% Test the results if succeed
if strcmp(cvx_status, 'Solved')
    success = 1;
else
    success = 0;
end