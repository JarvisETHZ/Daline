function daline_setup(varargin)
    % daline_setup - Setup function for the Daline toolbox

    % Clear the command window
    clc;
    warning off
    
    % Print the header with border
    fprintf('------------------------------------------------------------------------\n');
    fprintf('Daline: Data-Driven Power Flow Linearization          Copyright (c) 2024\n');
    fprintf('Dr. Mengshuo Jia    www.shuo.science     Power Systems Lab    ETH Zürich\n');
    fprintf('------------------------------------------------------------------------\n');

    
    % Display the initial setup message without newline
    fprintf('Setting Up Daline ..................');
    
    % Add the current folder and its subdirectories to the MATLAB path
    baseDir = fileparts(mfilename('fullpath'));
    addpath(genpath(baseDir));
    savepath;

    % Proceed with CVX setup using cvx_setup
    % Note that users must trust the developer of the files in CVX and
    % allow their operating system open these files.
    % Perform CVX setup
    try
        evalc('cvx_setup');  % Execute cvx_setup, muting it
        setupSuccess_cvx = true;
    catch ME
        fprintf('Failed to set up CVX: %s\n', ME.message);
        setupSuccess_cvx = false;
    end

    % Proceed through YALMIP setup using yalmiptest
    % Executing this can avoid some weird bugs when using YALMIP
    try
        evalc('yalmiptest');  % Execute yalmiptest, muting it
        setupSuccess_yalmip = true;
    catch ME
        fprintf('Failed to set up YALMIP: %s\n', ME.message);
        setupSuccess_yalmip = false;
    end

    % Update the status message based on the outcome of the setups
    if setupSuccess_cvx && setupSuccess_yalmip
        % Both setups succeeded
        fprintf(' Done!\n');
    else
        % If there was a failure, clear the line and show error message
        fprintf([repmat('\b', 1, 31) ' Not 100% Successful!\n']);  
    end
    
    % Test data generation
    fprintf('Testing Data Generation .......');
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
    fprintf('Testing Available Solvers ..........');
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
    fprintf(' Done!\n');
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

    % Before testing the linearization methods, determine the method list
    if nargin == 0 || (nargin == 1 && strcmpi(varargin{1}, 'fast'))
        % No input or input is 'fast'
        method = {'LS'; 'QR'; 'LD'; 'PIN'; 'SVD'; 'PCA'; 'LS_SVD'; 'LS_PIN'; 'LS_COD'; 'COD'; 'LS_PCA'; 'LS_HBW'; 'LS_GEN'; 'LS_LIFX'; 'LS_LIFXi'; 'LS_TOL'; 'LS_CLS'; 'LS_REC'; 'LS_REP'; 'PLS_SIM'; 'PLS_SIMRX'; 'PLS_NIP'; 'PLS_BDL'; 'PLS_BDLY2'; 'PLS_BDLopen'; 'PLS_REC'; 'PLS_RECW'; 'PLS_REP'; 'PLS_CLS'; 'RR'; 'RR_WEI'; 'RR_KPC'; 'RR_VCS'; 'SVR_POL'; 'DC'; 'DC_LS'; 'DLPF'; 'DLPF_C'; 'PTDF'; 'TAY'};
        methodNotTest = {'LS_HBLD'; 'LS_HBLE'; 'LS_WEI'; 'SVR'; 'SVR_CCP'; 'SVR_RR'; 'LCP_BOXN'; 'LCP_BOX'; 'LCP_JGDN'; 'LCP_JGD'; 'LCP_COUN'; 'LCP_COUN2'; 'LCP_COU'; 'LCP_COU2'; 'DRC_XM'; 'DRC_XYM'; 'DRC_XYD'};
    elseif nargin == 1 && strcmpi(varargin{1}, 'full')
        % Input is 'full'
        method = {'LS'; 'QR'; 'LD'; 'PIN'; 'SVD'; 'PCA'; 'LS_SVD'; 'LS_PIN'; 'LS_COD'; 'COD'; 'LS_PCA'; 'LS_HBW'; 'LS_HBLD'; 'LS_HBLE'; 'LS_GEN'; 'LS_LIFX'; 'LS_LIFXi'; 'LS_TOL'; 'LS_CLS'; 'LS_WEI'; 'LS_REC'; 'LS_REP'; 'PLS_SIM'; 'PLS_SIMRX'; 'PLS_NIP'; 'PLS_BDL'; 'PLS_BDLY2'; 'PLS_BDLopen'; 'PLS_REC'; 'PLS_RECW'; 'PLS_REP'; 'PLS_CLS'; 'RR'; 'RR_WEI'; 'RR_KPC'; 'RR_VCS'; 'SVR'; 'SVR_POL'; 'SVR_CCP'; 'SVR_RR'; 'LCP_BOXN'; 'LCP_BOX'; 'LCP_JGDN'; 'LCP_JGD'; 'LCP_COUN'; 'LCP_COUN2'; 'LCP_COU'; 'LCP_COU2'; 'DRC_XM'; 'DRC_XYM'; 'DRC_XYD'; 'DC'; 'DC_LS'; 'DLPF'; 'DLPF_C'; 'PTDF'; 'TAY'};
        methodNotTest = {};
    else
        error('Invalid input argument. Use ''whole'' for full method list or ''fast'' for a shortened list.');
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
                if ismember('Gurobi', unavailableSolvers)
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
                if ismember('quadprog', unavailableSolvers)
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
                if ismember('fmincon', unavailableSolvers)
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

    % Display methods not tested
    for n = 1:length(methodNotTest)
        fprintf('        Method %-*s .... Not Tested!\n', maxLen, methodNotTest{n});
    end

    
    
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
%         if any(strcmp(unavailableSolvers, 'Gurobi'))
%             fprintf('  Note: Gurobi being unavailable is          \n');
%             fprintf('  considered non-critical.                   \n');
%         end
    end
    
    % Other notes
    fprintf('Please consult the user''s manual for more information. \n');    

    % End the box
    fprintf('------------------------------------------------------------------------\n');
    fprintf('Daline: Data-Driven Power Flow Linearization          Copyright (c) 2024\n');
    fprintf('Dr. Mengshuo Jia    www.shuo.science     Power Systems Lab    ETH Zürich\n');
    fprintf('------------------------------------------------------------------------\n');
    
end
   

%% Auxiliary sub-functions
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

% Function to check each solver and categorize them
function [available, unavailable] = checkSolver(name, testFunc, available, unavailable)
    if testFunc()
        available{end+1} = name;
    else
        unavailable{end+1} = name;
    end
end

    
    
    