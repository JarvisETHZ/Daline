function [Beta, success] = func_solve_DRCC_randXY_moment(X, Y, opt)
%
% is much faster.

%% Start
switch opt.DRC.language 
    % for cvx
    case 'cvx'
        switch opt.DRC.programType
            case 'whole'
                % use the whole model to solve
                [Beta, success] = func_solve_DRCC_randXY_moment_whole_cvx(X, Y, opt);
            case 'indivi'
                % use the individual model to solve
                [Beta, success] = func_solve_DRCC_randXY_moment_indivi_cvx(X, Y, opt);
        end 
    % for yalmip
    case 'yalmip'
        switch opt.DRC.programType
            case 'whole'
                % use the whole model to solve
                [Beta, success] = func_solve_DRCC_randXY_moment_whole_yalmip(X, Y, opt);
            case 'indivi'
                % use the individual model to solve
                [Beta, success] = func_solve_DRCC_randXY_moment_indivi_yalmip(X, Y, opt);
        end
end