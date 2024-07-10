function Gamma = func_generate_Gamma(T, U)
% func_generate_Gamma generates Gamma using T and U, the score components of X
% and Y in the partial least squares
%
% T: num_sample-by-num_comp
% U: num_sample-by-num_comp
% 
%  Ref.:
%   S. Nowak, Y. C. Chen, and L. Wang, “Measurement-based optimal der 
%   dispatch with a recursively estimated sensitivity model,” IEEE 
%   Transactions on Power Systems, vol. 35, no. 6, pp. 4792–4802, 2020.

%% Start

% Get numbers
num_component = size(T, 2);

% Define container
Gamma_diagonal = zeros(num_component, 1);

% Build Gamma
for n = 1:num_component
    Gamma_diagonal(n) = (U(:, n)' * T(:, n)) / (T(:, n)' * T(:, n));
end
Gamma = diag(Gamma_diagonal);

