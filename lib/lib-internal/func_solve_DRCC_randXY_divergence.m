function [Beta, success] = func_solve_DRCC_randXY_divergence(X, Y, opt, alpha)
%
% yalmip is faster

%% Start
switch opt.DRC.language 
    % for cvx
    case 'cvx'
        switch opt.DRC.programType
            case 'whole'
                % use the whole model to solve
                disp('To be continued')
            case 'indivi'
                % use the individual model to solve
                [Beta, success] = func_solve_DRCC_randXY_divergence_indivi_cvx(X, Y, opt, alpha);
        end 
    % for yalmip
    case 'yalmip'
        switch opt.DRC.programType
            case 'whole'
                % use the whole model to solve
                disp('To be continued')
            case 'indivi'
                % use the individual model to solve
                [Beta, success] = func_solve_DRCC_randXY_divergence_indivi_yalmip(X, Y, opt, alpha);
        end
end