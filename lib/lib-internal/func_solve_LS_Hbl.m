function [Beta, success] = func_solve_LS_Hbl(X, Y, opt)
%
% we suggest using the individual model for each response in Y, as the
% overall model cannot find a solution within acceptable time, regardless
% of cvx or yalmip;
%
% yalmip is much faster.

%% Start
switch opt.HBL.language 
    % for cvx
    case 'cvx'
        switch opt.HBL.programType
            case 'whole'
                % use the whole model to solve
                [Beta, success] = func_solve_LS_Hbl_whole_cvx(X, Y, opt);
            case 'indivi'
                % use the individual model to solve
                [Beta, success] = func_solve_LS_Hbl_indivi_cvx(X, Y, opt);
        end
    % for yalmip
    case 'yalmip'
        switch opt.HBL.programType
            case 'whole'
                % use the whole model to solve
                [Beta, success] = func_solve_LS_Hbl_whole_yalmip(X, Y, opt);
            case 'indivi'
                % use the individual model to solve
                [Beta, success] = func_solve_LS_Hbl_indivi_yalmip(X, Y, opt);
        end
end