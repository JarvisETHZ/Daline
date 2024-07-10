function opt = func_set_option(varargin)
%  Users specify the desired settings for the case studies here. 
%  All settings (i.e., options) are wrapped into a struct opt.

% If varargin is empty, wrong
if isempty(varargin)
    opt = struct;
% If varargin is not empty
else
    % Test: the number of input must be even
    if mod(length(varargin), 2) ~= 0
        error('The options for functions in Daline must be either an opt structure or name-value pairs. It cannot accept both the opt structure and name-value pairs simultaneously.');
    end

    % Define opt structure
    opt = struct;

    % Collect the inputted options
    for i = 1:2:length(varargin)
        % Test: the names for values must be character vectors or strings
        if ~ischar(varargin{i})
            error('Input name(s) must be character vectors or strings');
        end
        % Split the field name at '.' to allow nested structures
        fieldNames = strsplit(varargin{i}, '.');
        % Test if the inputted name follows the structure name1.name2
        if length(fieldNames) < 2
            error('Input name(s) must follow the structure: field.subfield');
        end
        % Assign the value to the appropriate nested field
        opt = setfield(opt, fieldNames{:}, varargin{i+1});
    end

    % If there is a filed 'case' in opt, convert the inputted case to get opt.mpc
    opt = func_set_option_struct(opt);
end


