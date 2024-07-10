function [data, X, Y] = func_data(opt)
% Generation, pollution, clean, normalization, XY separation
% Will only produce one final data structure and XY according to user settings 
% If you want to save different types of data, use the following functions
% individually

% Training/testing data generation
data = func_generate_data(opt);

% Pollute data by adding noise or/and outliers (if requested)
data = func_pollute_data(data, opt);

% Filter data, i.e., outlier filter, noise filter (if requested)
data = func_filter_data(data, opt);

% Normalize data (if requested)
data = func_normalize_data(data, opt);  

% Independent (X) & dependent (Y) data generation
[X, Y] = func_generate_XY(data);
