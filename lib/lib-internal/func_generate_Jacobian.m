function Jac = func_generate_Jacobian(Ybus, V, Vm, opt)
% func_generate_Jacobian generates the Jacobian matrix of all active and
% reactive power injections w.r.t. all unknown voltage magnitudes and
% angles. 

%% Start

% Identify the bus type
[~, pv, pq] = bustypes(opt.mpc.bus, opt.mpc.gen);

% Compute the partial derivatives of power injection w.r.t. voltage magnitude and angle. The outputs are complex, symbolic matrices
[dSbus_dVm, dSbus_dVa] = func_generate_derivative(Ybus, V, Vm);

% Form the Jacobian matrix w.r.t. unknown voltage magnitudes and angles
j11 = real(dSbus_dVa([pv; pq], [pv; pq]));
j12 = real(dSbus_dVm([pv; pq], pq));
j21 = imag(dSbus_dVa(pq, [pv; pq]));
j22 = imag(dSbus_dVm(pq, pq));
Jac = [  j11    j12;
         j21    j22;  ];