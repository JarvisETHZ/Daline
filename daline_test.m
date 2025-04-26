function daline_test(varargin)
    % test Daline
    
    % Test data generation
    fprintf('\nTesting Data Generation .......');
    try
        % Execute daline.data, potentially muting it
        evalc('data = daline.data(''case.name'', ''case9'')');
        % Succeeded
        fprintf(' Succeeded!\n');
    catch ME
        % Failed
        fprintf(' Failed to generate data: %s\n', ME.message);
    end
    
    % Test Data Pollution
    fprintf('Testing Data Pollution ........');
    try
        % Execute daline.noise, potentially muting it
        evalc('daline.noise(data, ''noise.switchTrain'', 1, ''noise.SNR_dB'', 46)');
        try
            % Execute daline.outlier, potentially muting it
            evalc('daline.outlier(data, ''outlier.switchTrain'', 1, ''outlier.percentage'', 2.5)');
            % Succeeded
            fprintf(' Succeeded!\n');
        catch ME
            % Failed
            fprintf(' Failed to add outliers: %s\n', ME.message);
        end
    catch ME
        % Failed
        fprintf(' Failed to add noise: %s\n', ME.message);
    end
    
    % Test Data Clean
    fprintf('Testing Data Cleaning .........');
    try
        % Execute daline.denoise, potentially muting it
        evalc('daline.denoise(data, ''filNoi.switchTrain'', 1)');
        try
            % Execute daline.deoutlier, potentially muting it
            evalc('daline.deoutlier(data, ''filOut.switchTrain'', 1)');
            % Succeeded
            fprintf(' Succeeded!\n');
        catch ME
            % Failed
            fprintf(' Failed to add outliers: %s\n', ME.message);
        end
    catch ME
        % Failed
        fprintf(' Failed to add noise: %s\n', ME.message);
    end
    
    % Test Data Normalization
    fprintf('Testing Data Normalization ....');
    try
        % Execute daline.data, potentially muting it
        evalc('data = daline.data(''case.name'', ''case9'')');
        % Execute daline.normalize, potentially muting it
        evalc('daline.normalize(data, ''norm.switch'', 1)');
        % Succeeded
        fprintf(' Succeeded!\n');
    catch ME
        % Failed
        fprintf(' Failed to normalize data: %s\n', ME.message);
    end
    
    % Test the minimum required solvers
    fprintf('Testing Available Solvers ......... Start!\n');
    availableSolvers = {};
    unavailableSolvers = {};

    % Function to test each solver and categorize them
    [availableSolvers, unavailableSolvers] = checkSolver('fminunc', @test_fminunc, availableSolvers, unavailableSolvers);
    [availableSolvers, unavailableSolvers] = checkSolver('fmincon', @test_fmincon, availableSolvers, unavailableSolvers);
    [availableSolvers, unavailableSolvers] = checkSolver('quadprog', @test_quadprog_yalmip, availableSolvers, unavailableSolvers);
    [availableSolvers, unavailableSolvers] = checkSolver('Gurobi', @test_gurobi_yalmip, availableSolvers, unavailableSolvers);
    [availableSolvers, unavailableSolvers] = checkSolver('SeDuMi', @test_sedumi, availableSolvers, unavailableSolvers);
    [availableSolvers, unavailableSolvers] = checkSolver('SDPT3', @test_sdpt3, availableSolvers, unavailableSolvers);
    
    % Display the summary of tesing solvers

    % Find the maximum length of solver names for proper alignment
    maxLen = max(cellfun(@length, [availableSolvers, unavailableSolvers]));
    % Loop through available solvers and display each as available
    for i = 1:length(availableSolvers)
        fprintf('        Solver %-*s ....... Available!\n', maxLen, availableSolvers{i});
    end
    % Loop through unavailable solvers and display each as unavailable
    for j = 1:length(unavailableSolvers)
        fprintf('        Solver %-*s ....... Unavailable!\n', maxLen, unavailableSolvers{j});
    end


    
    % Determine the full method list
    methodFullList = {'LS'; 'QR'; 'LD'; 'PIN'; 'SVD'; 'PCA'; 'LS_SVD'; 'LS_PIN'; 'LS_COD'; 'COD'; 'LS_PCA'; 'LS_HBW'; 'LS_HBLD'; 'LS_HBLE'; 'LS_GEN'; 'LS_LIFX'; 'LS_LIFXi'; 'LS_TOL'; 'LS_CLS'; 'LS_WEI'; 'LS_REC'; 'LS_REP'; 'PLS_SIM'; 'PLS_SIMRX'; 'PLS_NIP'; 'PLS_BDL'; 'PLS_BDLY2'; 'PLS_BDLopen'; 'PLS_REC'; 'PLS_RECW'; 'PLS_REP'; 'PLS_CLS'; 'RR'; 'RR_WEI'; 'RR_KPC'; 'RR_VCS'; 'SVR'; 'SVR_POL'; 'SVR_CCP'; 'SVR_RR'; 'LCP_BOXN'; 'LCP_BOX'; 'LCP_JGDN'; 'LCP_JGD'; 'LCP_COUN'; 'LCP_COUN2'; 'LCP_COU'; 'LCP_COU2'; 'DRC_XM'; 'DRC_XYM'; 'DRC_XYD'; 'DC'; 'DC_LS'; 'DLPF'; 'DLPF_C'; 'PTDF'; 'TAY'; 'OI'};
    
    % Before testing the linearization methods, determine the method list
    if nargin == 0
        % Default to full list if no arguments
        method = methodFullList;
        methodNotTest = {};
        flag_methodNotTest = 1;
    elseif nargin == 1
        if ischar(varargin{1}) && strcmpi(varargin{1}, 'fast')
            % Header
            % 'fast' preset methods
            method = {'LS'; 'QR'; 'LD'; 'PIN'; 'SVD'; 'PCA'; 'LS_SVD'; 'LS_PIN'; 'LS_COD'; 'COD'; ...
                      'LS_PCA'; 'LS_HBW'; 'LS_GEN'; 'LS_LIFX'; 'LS_LIFXi'; 'LS_TOL'; 'LS_CLS'; 'LS_REC'; ...
                      'LS_REP'; 'PLS_SIM'; 'PLS_SIMRX'; 'PLS_NIP'; 'PLS_BDL'; 'PLS_BDLY2'; 'PLS_BDLopen'; ...
                      'PLS_REC'; 'PLS_RECW'; 'PLS_REP'; 'PLS_CLS'; 'RR'; 'RR_WEI'; 'RR_KPC'; 'RR_VCS'; ...
                      'SVR_POL'; 'DC'; 'DC_LS'; 'DLPF'; 'DLPF_C'; 'PTDF'; 'TAY'};
            methodNotTest = setdiff(methodFullList, method);
            flag_methodNotTest = 1;
        elseif ischar(varargin{1}) && strcmpi(varargin{1}, 'full')
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
            if strcmp(method{n}, 'SVR_CCP') || strcmp(method{n}, 'DRC_XYD') || strcmp(method{n}, 'OI')
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
        
        % Check and display available solvers
        if ~isempty(availableSolvers)
            solversFormatted = strjoin(availableSolvers, ', ');
            fprintf('Available   Solvers: %-25s \n', solversFormatted);
        end

        % Check and display unavailable solvers and note on critical solvers
        if ~isempty(unavailableSolvers)
            solversUnavailableFormatted = strjoin(unavailableSolvers, ', ');
            fprintf('Unavailable solvers: %-23s \n', solversUnavailableFormatted);
        end

        % Other notes
        fprintf('Please consult the user''s manual for more information. \n');    

        % End the box
        fprintf('================================================================\n');
        fprintf('        ██████╗  █████╗ ██╗     ██╗███╗   ██╗███████╗\n');
        fprintf('        ██╔══██╗██╔══██╗██║     ██║████╗  ██║██╔════╝\n');
        fprintf('        ██║  ██║███████║██║     ██║██╔██╗ ██║█████╗  \n');
        fprintf('        ██║  ██║██╔══██║██║     ██║██║╚██╗██║██╔══╝  \n');
        fprintf('        ██████╔╝██║  ██║███████╗██║██║ ╚████║███████╗\n');
        fprintf('        ╚═════╝ ╚═╝  ╚═╝╚══════╝╚═╝╚═╝  ╚═══╝╚══════╝\n');
        fprintf('================================================================\n');
        fprintf('Daline v1.1.7 - Generalized Data-Driven Power Flow Linearization \n');
        fprintf('Website: www.shuo.science/Daline       Contact: Dr. Mengshuo Jia\n');
        fprintf('================================================================\n');
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


function success = test_fminunc()
    % Test MATLAB's fminunc function from the Optimization Toolbox
    try
        objFunc = @(x) (x-3)^2;  % Simple quadratic function
        options = optimoptions('fminunc', 'Display', 'off');
        x0 = 0;  % Initial guess
        [~, ~, exitflag] = fminunc(objFunc, x0, options);
        success = exitflag > 0;
    catch
        success = false;
    end
end

% Function to check each solver and categorize them
function [available, unavailable] = checkSolver(name, testFunc, available, unavailable)
    if testFunc()
        available{end+1} = name;
    else
        unavailable{end+1} = name;
    end
end

function success = test_sedumi()
    % Test CVX's interface to SeDuMi
    try
        cvx_begin quiet sdp
            variable x(1,1)
            minimize (x^2)
            subject to
                x >= 1
        cvx_end
        success = strcmp(cvx_status, 'Solved');
    catch
        success = false;
    end
end

function success = test_sdpt3()
    % Test CVX's interface to SDPT3
    try
        cvx_begin quiet sdp
            variable x(1,1)
            minimize (x^2 + 1)
            subject to
                x >= 2
        cvx_end
        success = strcmp(cvx_status, 'Solved');
    catch
        success = false;
    end
end
   
