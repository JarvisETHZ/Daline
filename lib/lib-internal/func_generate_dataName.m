function name = func_generate_dataName(opt)
% name and save data according to the settings

%% Start

% Shorten names for pf type
switch opt.data.program
    case 'acpf'
        optPF = 'pf';
    case 'acopf'
        optPF = 'opf';
end

% Shorten names for data type
switch opt.data.baseType
    case 'Random'
        optDataType = 'RND';
    case 'TimeSeries'
        % Remove : from the time window
        timeStart = strrep(opt.load.timeStart, ':', '');
        timeEnd   = strrep(opt.load.timeEnd,   ':', '');
        optDataType = ['TSS_', timeStart, '_', timeEnd];
    case 'TimeSeriesRand'
        timeStart = strrep(opt.load.timeStart, ':', '');
        timeEnd   = strrep(opt.load.timeEnd,   ':', '');
        optDataType = ['TSR_', timeStart, '_', timeEnd];
end

% Give names for whether changing the voltages of PV nodes
if opt.voltage.varyIndicator 
    optVolChange = 'volVar'; % Varying voltages of PV nodes
else
    optVolChange = 'volFix'; % Fixed voltages of PV nodes
end

% Give names for whether setting the reference angle as zero
if opt.voltage.refAngle
    optZeroAngle = 'angPosi'; % Positive slack angle
else
    optZeroAngle = 'angZero'; % Zero slack angle
end

% Give names for whether adding noise
if opt.noise.switchTrain
    optNoise = ['Noise', num2str(opt.noise.SNR_dB)];
else
    optNoise = 'Noise00';  % No noise
end

% Give names for whether adding outliers
if opt.outlier.switchTrain 
    optOutlier = ['Outlier', num2str(opt.outlier.percentage)];
else
    optOutlier = 'Outlier0'; % No outlier
end

% Give names for whether normalizing data
if opt.norm.switch
    optNorm = 'NormT';  % Normalization
else
    optNorm = 'NormF';  % No normalization
end

% Combine the name
name = [opt.case.name, '_', optPF, '_', optDataType, '_', optZeroAngle, '_', optVolChange, '_', optNoise, '_', optOutlier, '_', optNorm];

