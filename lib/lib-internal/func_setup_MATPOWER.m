function success = func_setup_MATPOWER(baseDir)
    % func_setup_MATPOWER - Checks and installs MATPOWER if necessary.
    % baseDir: base directory of Daline
    % Returns success = true if MATPOWER is ready, false otherwise

    success = false;  % Default to failure

    libExternalDir = fullfile(baseDir, 'lib', 'lib-external');

    % Ensure the external library directory exists
    if ~exist(libExternalDir, 'dir')
        mkdir(libExternalDir);
    end

    % Add base directory and subfolders to the MATLAB path
    addpath(genpath(baseDir));
    savepath;

    % Check for existing MATPOWER installation
    matpowerInstalled = false;
    matpowerVersionOk = false;

    if exist('mpver', 'file') == 2
        try
            v = mpver('all');
            versionStr = v(1).Version;
            matpowerInstalled = true;
            if str2double(versionStr) >= 6.0
                matpowerVersionOk = true;
                fprintf('\nMATPOWER v%s detected.\n', versionStr);
                success = true;
                return;
            else
                fprintf('\nMATPOWER v%s detected (requires v6.0 or higher).\n', versionStr);
            end
        catch
            fprintf('\nUnable to determine MATPOWER version.\n');
        end
    end

    if ~matpowerInstalled || ~matpowerVersionOk
        fprintf('\nMATPOWER not found or outdated.\n');

        if ~isInternetConnected()
            fprintf('No internet connection. Please connect and rerun setup.\n');
            return;
        end

        userInput = input('Download the latest MATPOWER now? [Y/N]: ', 's');
        if strcmpi(userInput, 'Y')
            try
                fprintf('Downloading MATPOWER...\n');
                zipFilePath = fullfile(libExternalDir, 'matpower.zip');
                websave(zipFilePath, 'https://matpower.org/dld/1631/?tmstv=1745655185');
                fprintf('Download complete. Installing...\n');
                unzip(zipFilePath, libExternalDir);
                delete(zipFilePath);

                matpowerFolder = dir(fullfile(libExternalDir, 'matpower*'));
                if ~isempty(matpowerFolder)
                    matpowerPath = fullfile(libExternalDir, matpowerFolder(1).name);
                    addpath(genpath(matpowerPath));
                    savepath;
                    relativePath = strrep(matpowerPath, [baseDir filesep], '');  % Get path relative to baseDir
                    fprintf('MATPOWER installed at: %s\n', fullfile('Daline117', relativePath));


                    if exist('mpver', 'file') == 2
                        v = mpver('all');
                        versionStr = v(1).Version;
                        if str2double(versionStr) >= 6.0
                            fprintf('MATPOWER v%s installed successfully.\n', versionStr);
                            success = true;
                            return;
                        else
                            fprintf('Warning: Installed MATPOWER v%s may be too old.\n', versionStr);
                            return;
                        end
                    end
                else
                    error('MATPOWER folder not found after installation.');
                end
            catch ME
                fprintf('MATPOWER installation failed: %s\n', ME.message);
                fprintf('Please download and install manually: https://matpower.org/download/\n');
                return;
            end
        else
            fprintf('MATPOWER is required for Daline.\n');
            fprintf('Setup halted. Please install MATPOWER manually from:\n');
            fprintf('https://matpower.org/download/\n');
            return;
        end
    end
end

function connected = isInternetConnected()
    try
        java.net.InetAddress.getByName('www.mathworks.com');
        connected = true;
    catch
        connected = false;
    end
end
