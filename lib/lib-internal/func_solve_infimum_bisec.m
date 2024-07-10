function [x_infimum, h_val] = func_solve_infimum_bisec(d_val, alpha_val, a, b, tol)
    % Define the derivative h'(x)
    dhdx = @(x) (exp(-d_val) * x^(-alpha_val) * (-1 + alpha_val - alpha_val * x + exp(d_val) * x^alpha_val)) / (-1 + x)^2;

    % Define h(x)
    h = @(x) (exp(-d_val) * x^(1 - alpha_val) - 1) / (x - 1);

    % Check if the signs at the endpoints are opposite
    if sign(dhdx(a)) == sign(dhdx(b))
        error('The function must have opposite signs at the endpoints a and b.');
    end

    % Bisection method
    while (b - a)/2 > tol
        c = (a + b)/2;
        if dhdx(c) == 0
            break;
        elseif sign(dhdx(c)) == sign(dhdx(a))
            a = c;
        else
            b = c;
        end
    end

    x_infimum = (a + b)/2;
    h_val = h(x_infimum);
end
