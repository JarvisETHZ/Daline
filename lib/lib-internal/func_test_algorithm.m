function result = func_test_algorithm(methodName, opt, data, X, Y)
% Test a specific algorithm, include testing error and whether it fails

% Get training/testing result 
if nargin <= 3
    % If X and Y are not given, get training/testing result without X and Y
    result = func_algorithm(methodName, opt, data);
else
    % Get training/testing result for the given X and Y
    result = func_algorithm(methodName, opt, data, X, Y);
end

% Get mean error for all responses
result.meanError = mean(result.error.all(:));

% Check if Beta exists and if it contains NaN
if exist('result.Beta','var')
    % func_algorithm_PLS_BDL_open doesn't have a Beta
    if iscell(result.Beta)
        % For cluster-based Beta
        result.betaNaN = 0;
        Ncell = length(result.Beta);
        for n = 1:Ncell
            result.betaNaN = result.betaNaN + any(isnan(result.Beta{n}(:)));
        end
    else
        % For normal Beta
        result.betaNaN = any(isnan(result.Beta(:)));
    end
end

% See if there is any failure
if exist('result.Beta','var')
    if isnan(result.meanError) && result.betaNaN   % When the error is NaN and Beta contains NaN, it is said to be failed
        result.failure = 1;
    elseif ~isnan(result.meanError) && ~result.betaNaN  % When the error is not NaN and Beta contains no NaN, it is said to be successful
        result.failure = 0;
    else     
        result.failure = 2;      % When 2 shows up, need further investigation
    end
else
    if isnan(result.meanError)    % When the error is NaN, it is said to be failed
        result.failure = 1;
    elseif ~isnan(result.meanError) % When the error is not NaN, it is said to be successful
        result.failure = 0;
    else     
        result.failure = 2;       % When 2 shows up, need further investigation
    end
end