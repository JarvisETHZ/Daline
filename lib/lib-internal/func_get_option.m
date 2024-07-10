function opt = func_get_option(varargin)

% If is empty, get all the default options
if isempty(varargin)
    error('Please input at least one field.');
% If varargin is not empty
else
    opt = func_default_option_category(varargin);
end