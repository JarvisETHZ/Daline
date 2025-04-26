function daline_setup(varargin)
    % daline_setup - Setup function for the Daline toolbox

    % Clear the command window
    clc;
    warning off
    
    % Print the header with border
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

    
    % Display the initial setup message without newline
    fprintf('Thank you for choosing Daline! Setup begins.\n');
        
    % Add the current folder and its subdirectories to the MATLAB path
    baseDir = fileparts(mfilename('fullpath'));
    addpath(genpath(baseDir));
    savepath;
    
    % Setup MATPOWER (check, download if necessary)
    successMATPOWER = func_setup_MATPOWER(baseDir);

    % If MATPOWER setup failed, stop Daline setup entirely
    if ~successMATPOWER
        fprintf('Daline setup terminated due to MATPOWER setup failure owing to the above reason(s).\n');
        return;
    end

    % ---------------- CVX Setup ----------------
    fprintf('\nSetting up CVX ...... ');
    try
        evalc('cvx_setup');  % Execute cvx_setup silently
        setupSuccess_cvx = true;
        fprintf('Done!\n');
    catch ME
        setupSuccess_cvx = false;
        fprintf('Failed to set up CVX. Error: %s\n', ME.message);
        fprintf('Please ensure CVX is correctly installed and try running cvx_setup manually.\n');
    end

    % ---------------- YALMIP Setup ----------------
    fprintf('Setting up YALMIP ... ');
    try
        evalc('yalmiptest');  % Execute yalmiptest silently
        setupSuccess_yalmip = true;
        fprintf('Done!\n');
    catch ME
        setupSuccess_yalmip = false;
        fprintf('Failed to verify YALMIP. Error: %s\n', ME.message);
        fprintf('Please ensure YALMIP is correctly installed and consider running yalmiptest manually to diagnose the issue.\n');
    end

    % ---------------- Combined Status ----------------
    if setupSuccess_cvx && setupSuccess_yalmip
        fprintf('Solver environments successfully set up.\n');
    else
        fprintf('Some solver environments were not set up successfully.\n');
        if ~setupSuccess_cvx
            fprintf('  - CVX setup failed. You may experience issues with convex optimization tasks.\n');
        end
        if ~setupSuccess_yalmip
            fprintf('  - YALMIP setup failed. You may encounter issues with solver integration or optimization modeling.\n');
        end
        fprintf('Please review the above messages and address any issues before proceeding.\n');
    end
    
    % Prompt user to run tests after setup completion
    fprintf('\nDaline setup complete.\n\n');
    fprintf('Would you like to run a test?\n');
    fprintf('  1. Full test (approx. 10+ minutes)\n');
    fprintf('  2. Quick test (approx. 1–5 minutes)\n');
    fprintf('  3. Skip tests\n\n');
    fprintf('Note: You can run daline_test() later at any time.\n\n');

    testChoice = input('Please enter 1, 2, or 3: ', 's');

    switch testChoice
        case '1'
            fprintf('\nStarting full test of Daline...\n');
            daline_test('full');
        case '2'
            fprintf('\nStarting quick test of Daline...\n');
            daline_test('fast');
        case '3'
            fprintf('\nDaline setup complete. Enjoy!\n');
        otherwise
            fprintf('\nInvalid selection. No tests will be run. Setup complete. Enjoy!\n');
    end

    
end    