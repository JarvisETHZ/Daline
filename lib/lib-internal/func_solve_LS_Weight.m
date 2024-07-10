function [Beta, success] = func_solve_LS_Weight(X, Y, opt)
%
%
% cvx is much faster; yalmip seems cannot work for this problem, though the
% codes are correct. 

%% Start
switch opt.LSW.language 
    % for cvx
    case 'cvx'
        switch opt.LSW.programType
            case 'whole'
                % use the whole model to solve
                [Beta, success] = func_solve_LS_Weight_whole_cvx(X, Y, opt.LSW.omega, opt.LSW.cvxQuiet, opt.LSW.solver);
            case 'indivi'
                % use the individual model to solve
                [Beta, success] = func_solve_LS_Weight_indivi_cvx(X, Y, opt.LSW.omega, opt.LSW.cvxQuiet, opt.LSW.solver);
        end
    % for yalmip
    case 'yalmip'
        switch opt.LSW.programType
            case 'whole'
                % use the whole model to solve
                [Beta, success] = func_solve_LS_Weight_whole_yalmip(X, Y, opt.LSW.omega, opt.LSW.yalDisplay, opt.LSW.solver);
            case 'indivi'
                % use the individual model to solve
                [Beta, success] = func_solve_LS_Weight_indivi_yalmip(X, Y, opt.LSW.omega, opt.LSW.yalDisplay, opt.LSW.solver, opt.LSW.parallel);
        end
end