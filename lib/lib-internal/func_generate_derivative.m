function [dSbus_dVm, dSbus_dVa] = func_generate_derivative(Ybus, V, Vm)
% This function is to compute partial derivatives of power injection w.r.t.
% voltage. 
% The code is based on the built-in function "dSbus_dV" in MATPOWER. 
% A slight but important change is that abs(V) is replaced with Vm, the
% magnitude of complex V. Hence, Vm is also an input.  
% The reason for this change is that abs(V) cannot automatically lead to
% Vm, but to abs(Vm.*cosVa+1i*Vm.*sinVa), which is inseparable when
% extracting the real and imag parts out of it. 

% Get numbers
n = length(V);

% Get the current 
Ibus = Ybus * V;

% Form containers
diagV       = diag(V);
diagIbus    = diag(Ibus);
diagVnorm   = diag(V./Vm);

% Compute derivatives
dSbus_dVm = diagV * conj(Ybus * diagVnorm) + conj(diagIbus) * diagVnorm;
dSbus_dVa = 1j * diagV * conj(diagIbus - Ybus * diagV);
