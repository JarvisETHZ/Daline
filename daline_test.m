function daline_test(varargin)
    % daline_test - Quickly test built-in methods of Daline

    % Clear the command window
    clc;
    
    % Determine the full method list
    methodFullList = {'LS'; 'QR'; 'LD'; 'PIN'; 'SVD'; 'PCA'; 'LS_SVD'; 'LS_PIN'; 'LS_COD'; 'COD'; 'LS_PCA'; 'LS_HBW'; 'LS_HBLD'; 'LS_HBLE'; 'LS_GEN'; 'LS_LIFX'; 'LS_LIFXi'; 'LS_TOL'; 'LS_CLS'; 'LS_WEI'; 'LS_REC'; 'LS_REP'; 'PLS_SIM'; 'PLS_SIMRX'; 'PLS_NIP'; 'PLS_BDL'; 'PLS_BDLY2'; 'PLS_BDLopen'; 'PLS_REC'; 'PLS_RECW'; 'PLS_REP'; 'PLS_CLS'; 'RR'; 'RR_WEI'; 'RR_KPC'; 'RR_VCS'; 'SVR'; 'SVR_POL'; 'SVR_CCP'; 'SVR_RR'; 'LCP_BOXN'; 'LCP_BOX'; 'LCP_JGDN'; 'LCP_JGD'; 'LCP_COUN'; 'LCP_COUN2'; 'LCP_COU'; 'LCP_COU2'; 'DRC_XM'; 'DRC_XYM'; 'DRC_XYD'; 'DC'; 'DC_LS'; 'DLPF'; 'DLPF_C'; 'PTDF'; 'TAY'};
    
    % Before testing the linearization methods, determine the method list
    if nargin == 0
        % Header
        fprintf('------------------------------------------------------------------------\n');
        fprintf('Daline: Data-Driven Power Flow Linearization          Copyright (c) 2024\n');
        fprintf('Dr. Mengshuo Jia    www.shuo.science     Power Systems Lab    ETH Zürich\n');
        fprintf('------------------------------------------------------------------------\n');
        % Default to full list if no arguments
        method = methodFullList;
        methodNotTest = {};
        flag_methodNotTest = 1;
    elseif nargin == 1
        if ischar(varargin{1}) && strcmpi(varargin{1}, 'fast')
            % Header
            fprintf('------------------------------------------------------------------------\n');
            fprintf('Daline: Data-Driven Power Flow Linearization          Copyright (c) 2024\n');
            fprintf('Dr. Mengshuo Jia    www.shuo.science     Power Systems Lab    ETH Zürich\n');
            fprintf('------------------------------------------------------------------------\n');
            % 'fast' preset methods
            method = {'LS'; 'QR'; 'LD'; 'PIN'; 'SVD'; 'PCA'; 'LS_SVD'; 'LS_PIN'; 'LS_COD'; 'COD'; ...
                      'LS_PCA'; 'LS_HBW'; 'LS_GEN'; 'LS_LIFX'; 'LS_LIFXi'; 'LS_TOL'; 'LS_CLS'; 'LS_REC'; ...
                      'LS_REP'; 'PLS_SIM'; 'PLS_SIMRX'; 'PLS_NIP'; 'PLS_BDL'; 'PLS_BDLY2'; 'PLS_BDLopen'; ...
                      'PLS_REC'; 'PLS_RECW'; 'PLS_REP'; 'PLS_CLS'; 'RR'; 'RR_WEI'; 'RR_KPC'; 'RR_VCS'; ...
                      'SVR_POL'; 'DC'; 'DC_LS'; 'DLPF'; 'DLPF_C'; 'PTDF'; 'TAY'};
            methodNotTest = setdiff(methodFullList, method);
            flag_methodNotTest = 1;
        elseif ischar(varargin{1}) && strcmpi(varargin{1}, 'full')
            % Header
            fprintf('------------------------------------------------------------------------\n');
            fprintf('Daline: Data-Driven Power Flow Linearization          Copyright (c) 2024\n');
            fprintf('Dr. Mengshuo Jia    www.shuo.science     Power Systems Lab    ETH Zürich\n');
            fprintf('------------------------------------------------------------------------\n');
            % 'full' all methods
            method = methodFullList;
            methodNotTest = {};
            flag_methodNotTest = 1;
        elseif iscell(varargin{1}) && all(ismember(varargin{1}, methodFullList))
            % List of specific methods
            method = varargin{1};
            methodNotTest = setdiff(methodFullList, method);
            flag_methodNotTest = 0;
        else
            error('Invalid input argument. Use ''full'', ''fast'', or specify valid method names in {}, like {''SVR''; ''COD''}.');
        end
    else
        error('Too many input arguments.');
    end

    % Test linearization methods
    fprintf('Testing Linearization Methods ..... Start!\n');
    % Execute daline.data, potentially muting it
    evalc('data = daline.data(''case.name'', ''case9'', ''num.trainSample'', 100, ''num.testSample'', 50)');
    maxLen = max(cellfun(@length, [method; methodNotTest]));  % Determine the maximum length of method names for both lists

    % Initialize counters for available, unavailable, and not tested methods
    countAvailable = 0;
    countUnavailable = 0;
    for n = 1:length(method)
        try 
            % Execute daline.fit, potentially muting it
            if strcmp(method{n}, 'SVR_CCP') || strcmp(method{n}, 'DRC_XYD')
                % For methods SVR_CCP and DRC_XYD, since YALMIP will not
                % report errors even if Gurobi is not available, here we
                % use a different manner to check the availability of these
                % two methods. 
                if ~test_gurobi_yalmip
                    % If Gurobi is unavailable
                    fprintf('        Method %-*s .... Unavailable! Error: %s\n', maxLen, method{n}, 'Gurobi Unavailable!');
                    countUnavailable = countUnavailable + 1;  % Increment unavailable counter
                else
                    % otherwise, do the normal test
                    evalc('model = daline.fit(data, ''method.name'', method{n}, ''variable.predictor'', {''P'', ''Q''}, ''variable.response'', {''PF''})');
                    fprintf('        Method %-*s .... Available!\n', maxLen, method{n});  % Adjust space to align the output
                    countAvailable = countAvailable + 1;  % Increment available counter
                end
            elseif strcmp(method{n}, 'SVR') || strcmp(method{n}, 'SVR_RR')
                % For methods SVR and SVR_RR, since YALMIP will not
                % report errors even if quadprog is not available, here we
                % use a different manner to check the availability of these
                % two methods.
                if ~test_quadprog_yalmip
                    % If quadprog is unavailable
                    fprintf('        Method %-*s .... Unavailable! Error: %s\n', maxLen, method{n}, 'quadprog Unavailable!');
                    countUnavailable = countUnavailable + 1;  % Increment unavailable counter
                else
                    % otherwise, do the normal test
                    evalc('model = daline.fit(data, ''method.name'', method{n}, ''variable.predictor'', {''P'', ''Q''}, ''variable.response'', {''PF''})');
                    fprintf('        Method %-*s .... Available!\n', maxLen, method{n});  % Adjust space to align the output
                    countAvailable = countAvailable + 1;  % Increment available counter
                end
            elseif strcmp(method{n}, 'LS_HBLE')
                % For method LS_HBLE, since YALMIP will not
                % report errors even if fmincon is not available, here we
                % use a different manner to check the availability of these
                % two methods.
                if ~test_fmincon
                    % If fmincon is unavailable
                    fprintf('        Method %-*s .... Unavailable! Error: %s\n', maxLen, method{n}, 'fmincon Unavailable!');
                    countUnavailable = countUnavailable + 1;  % Increment unavailable counter
                else
                    % otherwise, do the normal test
                    evalc('model = daline.fit(data, ''method.name'', method{n}, ''variable.predictor'', {''P'', ''Q''}, ''variable.response'', {''PF''})');
                    fprintf('        Method %-*s .... Available!\n', maxLen, method{n});  % Adjust space to align the output
                    countAvailable = countAvailable + 1;  % Increment available counter
                end
            % For other methods, use the simple test
            else
                evalc('model = daline.fit(data, ''method.name'', method{n}, ''variable.predictor'', {''P'', ''Q''}, ''variable.response'', {''PF''})');
                fprintf('        Method %-*s .... Available!\n', maxLen, method{n});  % Adjust space to align the output
                countAvailable = countAvailable + 1;  % Increment available counter
            end
        catch ME
            if strcmp(ME.message, 'Undefined function ''cvx_quiet'' for input arguments of type ''logical''.')
                % This means CVX has not been successfully installed and added to the path, which is rare 
                fprintf('        Method %-*s .... Unavailable! Error: %s\n', maxLen, method{n}, 'CVX Unrecognized!');
            else
                % Report other normal errors
                fprintf('        Method %-*s .... Unavailable! Error: %s\n', maxLen, method{n}, ME.message);
            end
            countUnavailable = countUnavailable + 1;  % Increment unavailable counter
        end
    end

    % Display methods not tested (for full or fast)
    if flag_methodNotTest
        for n = 1:length(methodNotTest)
            fprintf('        Method %-*s .... Not Tested!\n', maxLen, methodNotTest{n});
        end
    end
    
    % Display the summary (for full or fast)
    if flag_methodNotTest
        % Start the box
        fprintf('------------------------------------------------------------------------\n');
        fprintf('Daline Setting Up and Initial Test Completed!         \n');    


        % Display total counts of methods dynamically
        fprintf('Available   Methods: %-2d Methods           \n', countAvailable);
        fprintf('Unavailable Methods: %-2d Methods         \n', countUnavailable);
        if ~isempty(methodNotTest)
            fprintf('Not Tested  Methods: %-2d Methods (run daline_test for the Full Test).\n', length(methodNotTest));
        end

        % Other notes
        fprintf('Please consult the user''s manual for more information. \n');    

        % End the box
        fprintf('------------------------------------------------------------------------\n');
        fprintf('Daline: Data-Driven Power Flow Linearization          Copyright (c) 2024\n');
        fprintf('Dr. Mengshuo Jia    www.shuo.science     Power Systems Lab    ETH Zürich\n');
        fprintf('------------------------------------------------------------------------\n');
    end
    
end


%% Auxiliary sub-functions
function success = test_gurobi_yalmip()
    % Test YALMIP's interface to Gurobi
    try
        x = sdpvar(1,1);
        objective = (x-3)^2;  % Simple quadratic function
        constraints = (x-1)^2 <= 4;  % Simple constraint
        ops = sdpsettings('solver', 'gurobi', 'verbose', 0);
        sol = optimize(constraints, objective, ops);
        success = sol.problem == 0;
    catch
        success = false;
    end
end

function success = test_quadprog_yalmip()
    % Test YALMIP's interface to quadprog
    try
        x = sdpvar(1,1);
        H = 2; f = -6;  % Coefficients for 2*x^2 - 6*x
        ops = sdpsettings('solver', 'quadprog', 'verbose', 0);
        sol = optimize([], H*x^2 + f*x, ops);
        success = sol.problem == 0;
    catch
        success = false;
    end
end

function success = test_quadprog_cvx()
    % Test CVX's interface to MATLAB's quadprog
    try
        cvx_begin quiet
            variable x(1,1)
            minimize (2*x^2 - 6*x)  % Quadratic function
        cvx_end
        success = strcmp(cvx_status, 'Solved');
    catch
        success = false;
    end
end

function success = test_fmincon()
    % Test YALMIP's interface to fmincon
    try
        x = sdpvar(1,1);
        objective = (x-3)^2;  % Simple quadratic function
        constraints = (x-1)^2 <= 4;  % Simple constraint
        ops = sdpsettings('solver', 'fmincon', 'verbose', 0);
        sol = optimize(constraints, objective, ops);
        success = sol.problem == 0;
    catch
        success = false;
    end
end
   
