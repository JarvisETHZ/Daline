function [Beta, success] = func_solve_SVR_CC(X, Y, opt)
%
% we suggest using the individual model for each response in Y, as the
% overall model cannot find a solution within acceptable time, regardless
% of cvx or yalmip;
%
% yalmip is much faster.

%% Start
switch opt.SVRCC.language 
    % for cvx
    case 'cvx'
        switch opt.SVRCC.programType
            case 'whole'
                % use the whole model to solve
                [Beta, success] = func_solve_SVR_CC_whole_cvx(X, Y, opt);
            case 'indivi'
                % use the individual model to solve
                [Beta, success] = func_solve_SVR_CC_indivi_cvx(X, Y, opt);
        end
    % for yalmip
    case 'yalmip'
        switch opt.SVRCC.programType
            case 'whole'
                % use the whole model to solve
                [Beta, success] = func_solve_SVR_CC_whole_yalmip(X, Y, opt);
            case 'indivi'
                % use the individual model to solve
                [Beta, success] = func_solve_SVR_CC_indivi_yalmip(X, Y, opt);
        end
end