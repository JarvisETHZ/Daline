function [data, count] = func_generate_dataTimeSeriesRandom(opt)
% func_generate_dataTimeSeries Generates time-series data with randomness for power system scenarios

%% Start

% read and save the selected test case from MATPOWER
mpc = opt.mpc;
mpc_backup = mpc;

% get the index for the slack bus
[ref, ~, ~] = bustypes(opt.mpc.bus, opt.mpc.gen);

% read numbers
num_gen = size(mpc.gen, 1);
num_bus = size(mpc.bus, 1);
num_branch = size(mpc.branch, 1);
num_sample = opt.num.trainSample + opt.num.testSample;
num_sample_redundant = num_sample +  opt.num.redundant;   

% define containers
result_P  = zeros(num_sample_redundant, num_bus);
result_Q  = zeros(num_sample_redundant, num_bus);
result_Vm = zeros(num_sample_redundant, num_bus);
result_Vm2 = zeros(num_sample_redundant, num_bus);
result_Va = zeros(num_sample_redundant, num_bus);
result_PF = zeros(num_sample_redundant, num_branch);
result_PT = zeros(num_sample_redundant, num_branch);
result_QF = zeros(num_sample_redundant, num_branch);
result_QT = zeros(num_sample_redundant, num_branch);

% Genereate the load curve from a specified time window
loadCurve = func_generate_timeSeries_loadCurve(opt.load.timeStart, opt.load.timeEnd, num_sample_redundant, opt.load.amplifyFactor, opt.load.baseLoadCurve, opt.data.curvePlot);

% Voltage variation (if requested)
% Genereate redundant (3 times) random factors for voltage variation
if opt.voltage.varyIndicator
    % If the randomness is requested to be fixed
    if opt.data.fixRand
        rng(opt.data.fixSeed)
    end
    % change the voltage magnitudes of generators
    if strcmp(opt.voltage.distribution, 'normal')
        rf_voltage = opt.voltage.lowerRange + (opt.voltage.upperRange - opt.voltage.lowerRange) * randn(num_gen, num_sample_redundant);
    elseif strcmp(opt.voltage.distribution, 'uniform')
        rf_voltage = opt.voltage.lowerRange + (opt.voltage.upperRange - opt.voltage.lowerRange) * rand(num_gen, num_sample_redundant);
    end
    % for opf only: set 'opf.use_vg' as 0, i.e., doesn't respect generators' voltage set points
    % in this case, the voltage magnitudes of generators are optimized in
    % opf, different from the set points, even though the set points are
    % randomly altered. 
    opt_use_vg = 0; % Will go to opt.mpopt
else
    % do not change the voltage magnitudes of generators
    rf_voltage = zeros(num_gen, num_sample_redundant);
    % for opf only: set 'opf.use_vg' as 1 to respect the generator voltage magnitudes. In
    % this case, the voltage magnitudes of generators are fixed constant
    % and will not change in opf. 
    opt_use_vg = 1; % Will go to opt.mpopt
end

% Genereate redundant random factors for load variation
if opt.data.fixRand
    rng(opt.data.fixSeed)
end
rf_load = opt.load.lowerRangeTime + (opt.load.upperRangeTime - opt.load.lowerRangeTime) * rand(1, num_sample_redundant);
if strcmp(opt.load.distribution, 'normal')
    rf_load = opt.load.lowerRangeTime + (opt.load.upperRangeTime - opt.load.lowerRangeTime) * randn(1, num_sample_redundant);
elseif strcmp(opt.load.distribution, 'uniform')
    rf_load = opt.load.lowerRangeTime + (opt.load.upperRangeTime - opt.load.lowerRangeTime) * rand(1, num_sample_redundant);
end

% Add randomness to loadCurve
loadCurve = loadCurve .* rf_load;

% Get external parameters for computation
idxPD = opt.idx.PD;
idxQD = opt.idx.QD;
idxVG = opt.idx.VG;
idxVA = opt.idx.VA;
idxVM = opt.idx.VM;
idxPF = opt.idx.PF;
idxPT = opt.idx.PT;
idxQF = opt.idx.QF;
idxQT = opt.idx.QT;
idxPG = opt.idx.PG;
idxQG = opt.idx.QG;
idxBrStat = opt.idx.BR_STATUS;
changeGenerationACPF = opt.gen.varyIndicator;
voltageRefAngle = opt.voltage.refAngle;
dataProgram = opt.data.program;
loadSmallValue = opt.load.smallValue;
genSmallValue = opt.gen.smallValue;
loadAmplifyFactor = opt.load.amplifyFactor;

% use acopf to generate the operating point for each scenario
for n = 1:num_sample_redundant
    
    % restore the test case
    mpc = mpc_backup;

    % change the load data 
    mpc.bus(:, idxPD) = loadSmallValue + loadAmplifyFactor * loadCurve(n) * mpc.bus(:, idxPD);
    mpc.bus(:, idxQD) = loadSmallValue + loadAmplifyFactor * loadCurve(n) * mpc.bus(:, idxQD);

    % change the voltage magnitude of generators (if requested)
    mpc.gen(:, idxVG) = mpc.gen(:, idxVG) + rf_voltage(:, n);

    % change the voltage angle of the slack bus to avoid all-zero input (if requested)
    mpc.bus(ref, idxVA) = mpc.bus(ref, idxVA) + voltageRefAngle;

    % run power flow program
    switch dataProgram
        case 'acopf'
            % Run acopf
            mpopt = mpoption('model', 'AC', 'opf.ac.solver', 'MIPS', 'out.all', 0, 'verbose', 0, 'opf.use_vg', opt_use_vg, 'opf.violation', 1e-9);
            mpc = runopf(mpc, mpopt);
            % Convert back to the internal indexing for later use (runpf automatically converts mpc to the external indexing)
            mpc = ext2int(mpc);
            % Deal the results using the internal indexing
            [baseMVA, bus, gen, branch, success] = deal(mpc.baseMVA, mpc.bus, mpc.gen, mpc.branch, mpc.success);
            % You can run acpf again based on the opf result: but the results would be extremely close (checked many times) because 'opf.violation' is 1e-9 => tiny.
        case 'acpf'
            % change the power generations simultaneously like loads (if requested)
            if changeGenerationACPF
                mpc.gen(:, idxPG) = genSmallValue + loadAmplifyFactor * loadCurve(n) * mpc.gen(:, idxPG);
                mpc.gen(:, idxQG) = genSmallValue + loadAmplifyFactor * loadCurve(n) * mpc.gen(:, idxQG);
            end
            % Run acpf
            mpopt = mpoption('model', 'AC', 'out.all', 0, 'verbose', 0);
            mpc = runpf(mpc, mpopt); 
            % Convert back to the internal indexing for later use (runpf automatically converts mpc to the external indexing)
            mpc = ext2int(mpc);
            % Deal the results using the internal indexing
            [baseMVA, bus, gen, branch, success] = deal(mpc.baseMVA, mpc.bus, mpc.gen, mpc.branch, mpc.success);
        case 'dcopf_acpf'
            % Run dcopf first
            mpopt = mpoption('model', 'DC', 'opf.dc.solver', 'MIPS','out.all', 0, 'verbose', 0, 'opf.use_vg', opt_use_vg, 'opf.violation', 1e-9);
            mpc_dcopf = runopf(mpc, mpopt);
            % Convert back to the internal indexing to match mpc, which is using the internal indexing (runopf automatically converts mpc to the external indexing)
            mpc_dcopf = ext2int(mpc_dcopf);
            % Get the optimal dispatch for power generations only
            mpc.gen = mpc_dcopf.gen;
            % Run acpf
            mpopt = mpoption('model', 'AC', 'out.all', 0, 'verbose', 0);
            mpc = runpf(mpc, mpopt); 
            % Convert back to the internal indexing for later use (runpf automatically converts mpc to the external indexing)
            mpc = ext2int(mpc);
            % Deal the results using the internal indexing
            [baseMVA, bus, gen, branch, success] = deal(mpc.baseMVA, mpc.bus, mpc.gen, mpc.branch, mpc.success);
    end  
    % Organize results
    Sbus = makeSbus(baseMVA, bus, gen);
    branch(branch(:, idxBrStat)==0, :) = [];  % Remove the line flows of off-line, just in case. Theoretically, ext2int already removed the off-lines

    % see if the acopf succeeds or not
    if success
        % Collect results
        result_P(n, :)  = real(Sbus)';
        result_Q(n, :)  = imag(Sbus)';
        result_Vm(n, :) = bus(:, idxVM)';
        result_Va(n, :) = bus(:, idxVA)';
        result_PF(n, :) = branch(:, idxPF)';
        result_PT(n, :) = branch(:, idxPT)';
        result_QF(n, :) = branch(:, idxQF)';
        result_QT(n, :) = branch(:, idxQT)';
        result_Vm2(n, :) = result_Vm(n, :).^2;
    end
    
    % display
    clc
    disp(['Data generation progress: ', num2str(100*n/num_sample_redundant), '%'])
end

% Remove zero rows (only occur when opf/pf fails lots of times so that we didn't get enough data points)
result_P(all(~result_P, 2), : ) = [];
result_Q(all(~result_Q, 2), : ) = [];
result_Vm(all(~result_Vm, 2), : ) = [];
result_Va(all(~result_Va, 2), : ) = [];
result_PF(all(~result_PF, 2), : ) = [];
result_PT(all(~result_PT, 2), : ) = [];
result_QF(all(~result_QF, 2), : ) = [];
result_QT(all(~result_QT, 2), : ) = [];
result_Vm2(all(~result_Vm2, 2), : ) = [];

% get the actual number of samples
count = size(result_P, 1);

% Separate data into training and testing data
if count >= opt.num.trainSample + opt.num.testSample
    data.train.P = result_P(1:opt.num.trainSample, :);
    data.train.Q = result_Q(1:opt.num.trainSample, :);
    data.train.Vm = result_Vm(1:opt.num.trainSample, :);
    data.train.Va = result_Va(1:opt.num.trainSample, :);
    data.train.PF = result_PF(1:opt.num.trainSample, :);
    data.train.PT = result_PT(1:opt.num.trainSample, :);
    data.train.QF = result_QF(1:opt.num.trainSample, :);
    data.train.QT = result_QT(1:opt.num.trainSample, :);
    data.train.Vm2 = result_Vm2(1:opt.num.trainSample, :);
    data.test.P = result_P(opt.num.trainSample+1:opt.num.trainSample+opt.num.testSample, :);
    data.test.Q = result_Q(opt.num.trainSample+1:opt.num.trainSample+opt.num.testSample, :);
    data.test.Vm = result_Vm(opt.num.trainSample+1:opt.num.trainSample+opt.num.testSample, :);
    data.test.Va = result_Va(opt.num.trainSample+1:opt.num.trainSample+opt.num.testSample, :);
    data.test.PF = result_PF(opt.num.trainSample+1:opt.num.trainSample+opt.num.testSample, :);
    data.test.PT = result_PT(opt.num.trainSample+1:opt.num.trainSample+opt.num.testSample, :);
    data.test.QF = result_QF(opt.num.trainSample+1:opt.num.trainSample+opt.num.testSample, :);
    data.test.QT = result_QT(opt.num.trainSample+1:opt.num.trainSample+opt.num.testSample, :);
    data.test.Vm2 = result_Vm2(opt.num.trainSample+1:opt.num.trainSample+opt.num.testSample, :);
elseif count > opt.num.trainSample
    data.train.P = result_P(1:opt.num.trainSample, :);
    data.train.Q = result_Q(1:opt.num.trainSample, :);
    data.train.Vm = result_Vm(1:opt.num.trainSample, :);
    data.train.Va = result_Va(1:opt.num.trainSample, :);
    data.train.PF = result_PF(1:opt.num.trainSample, :);
    data.train.PT = result_PT(1:opt.num.trainSample, :);
    data.train.QF = result_QF(1:opt.num.trainSample, :);
    data.train.QT = result_QT(1:opt.num.trainSample, :);
    data.train.Vm2 = result_Vm2(1:opt.num.trainSample, :);
    data.test.P = result_P(opt.num.trainSample+1:end, :);
    data.test.Q = result_Q(opt.num.trainSample+1:end, :);
    data.test.Vm = result_Vm(opt.num.trainSample+1:end, :);
    data.test.Va = result_Va(opt.num.trainSample+1:end, :);
    data.test.PF = result_PF(opt.num.trainSample+1:end, :);
    data.test.PT = result_PT(opt.num.trainSample+1:end, :);
    data.test.QF = result_QF(opt.num.trainSample+1:end, :);
    data.test.QT = result_QT(opt.num.trainSample+1:end, :);
    data.test.Vm2 = result_Vm2(opt.num.trainSample+1:end, :);
else
    num_even = round(count/2);
    data.train.P = result_P(1:num_even, :);
    data.train.Q = result_Q(1:num_even, :);
    data.train.Vm = result_Vm(1:num_even, :);
    data.train.Va = result_Va(1:num_even, :);
    data.train.PF = result_PF(1:num_even, :);
    data.train.PT = result_PT(1:num_even, :);
    data.train.QF = result_QF(1:num_even, :);
    data.train.QT = result_QT(1:num_even, :);
    data.train.Vm2 = result_Vm2(1:num_even, :);
    data.test.P = result_P(num_even+1:end, :);
    data.test.Q = result_Q(num_even+1:end, :);
    data.test.Vm = result_Vm(num_even+1:end, :);
    data.test.Va = result_Va(num_even+1:end, :);
    data.test.PF = result_PF(num_even+1:end, :);
    data.test.PT = result_PT(num_even+1:end, :);
    data.test.QF = result_QF(num_even+1:end, :);
    data.test.QT = result_QT(num_even+1:end, :);
    data.test.Vm2 = result_Vm2(num_even+1:end, :);
end