function optcell = func_struct2cell(opt, prefix, depth)
    if nargin < 2
        prefix = '';
        depth = 1;
    end
    
    if nargin < 3
        depth = 1;
    end
    
    optcell = {};
    fields = fieldnames(opt); % Get names of all fields in opt
    
    for i = 1:length(fields)
        field = fields{i}; % Get name of i-th field
        value = opt.(field); % Get value of i-th field
        
        if isstruct(value) && depth < 3
            % If value is a structure and depth is less than 3, recursively call structToCell
            newPrefix = [prefix, field, '.'];
            cellArray = func_struct2cell(value, newPrefix, depth + 1);
            optcell = [optcell, cellArray]; % Concatenate cell arrays
        else
            % If value is not a structure or depth is 3, add field name and value to cell array
            optcell{end + 1} = [prefix, field]; % Add field name to cell array
            optcell{end + 1} = value; % Add field value to cell array
        end
    end
end

