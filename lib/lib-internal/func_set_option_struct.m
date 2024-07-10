function opt = func_set_option_struct(opt)
        
% If there is a filed 'case' in opt, convert the inputted case to get opt.mpc
if isfield(opt, 'case')
    % If opt.case.name exists
    if isfield(opt.case, 'name') && ~strcmp(opt.case.name, 'External System from User') % Just in case that mpc has been loaded by daline.setopt before, which will give a opt.case.name as 'External System from User'
        opt.mpc = ext2int(loadcase(opt.case.name));
    % If opt.case.mpc exists (and opt.case.name doesn't have any value other than 'External System from User')
    elseif isfield(opt.case, 'mpc')
        opt.mpc = opt.case.mpc;
        opt.case.name = 'External System from User';
    end
end



