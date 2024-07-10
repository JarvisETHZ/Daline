function [Beta, success] = func_solve_SVR(X, Y, opt)

%% Start
switch opt.SVR.language 
    % for cvx
    case 'cvx'
        switch opt.SVR.programType
            case 'whole'
                % use the whole model to solve
                disp('To be continued!')
            case 'indivi'
                % use the individual model to solve
                [Beta, success] = func_solve_SVR_indivi_cvx(X, Y, opt);
        end 
    % for yalmip
    case 'yalmip'
        switch opt.SVR.programType
            case 'whole'
                % use the whole model to solve
                disp('To be continued!')
            case 'indivi'
                % use the individual model to solve
                [Beta, success] = func_solve_SVR_indivi_yalmip(X, Y, opt);
        end
end