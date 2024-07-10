function [x_solution, h_val] = func_solve_infimum_fzero(d_val, alpha_val, delta)

%% Start

% Define h(x)
h = @(x) (exp(-d_val) * x^(1 - alpha_val) - 1) / (x - 1);
    
% Define the dh/dx
f = @(x) (exp(-d_val) * x^(-alpha_val) * (-1 + alpha_val - alpha_val * x + exp(d_val) * x^alpha_val)) / (-1 + x)^2;

% Exclusive interval for x
x_interval = [delta, 1 - delta];

% Use fzero to find the root of dh/dx within the exclusive interval
x_solution = fzero(f, x_interval);

% Evaluate h(x) at the solution => the infimun of h(x) within (0, 1)
h_val = h(x_solution);

end