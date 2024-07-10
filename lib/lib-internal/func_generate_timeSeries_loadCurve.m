function loadCurve = func_generate_timeSeries_loadCurve(timeStart, timeEnd, dataPoints, amplifyFactor, baseLoadCurve, curvePlot)
% func_generate_timeSeries_loadCurve generates an time series electricity load curve for a specified time window
%
% INPUTS:
%   timeStart:      A string representing the start time of the window (e.g., '8:00')
%   timeEnd:        A string representing the end time of the window (e.g., '18:00')
%   dataPoints:     The number of data points to generate for the load curve
%   amplifyFactor:  A scalar double to regulate the over load level (3.g., 0.9);
%   baseLoadCurve:  A vector representing the base load curve (optional). If empty, a default curve is used.
%
% OUTPUT:
%   loadCurve:      A vector representing the interpolated load curve for the specified time window
%
% EXAMPLE USAGE:
%   loadCurve = func_generate_loadCurve('8:00', '18:00', 100, 0.9, []);

%% Start

% Check if users prefer a different baseLoadCurve
if isempty(baseLoadCurve)
    % Use the default base load curve, which is similar to the
    % national daily load curve of French on Aug.16, 2023
    % For more details: see https://www.services-rte.com/en/view-data-published-by-rte/daily-load-curves.html
    baseLoadCurve = [1.0300,0.99440,0.96140,0.93070,0.90230,0.87640,0.85290,0.83180,0.81300,0.79430,0.78060,0.78240,0.78860,0.79310,0.79780,0.81210,0.84070,0.86560,0.88990,0.91780,0.94860,0.97180,0.98990,1.0142,1.0458,1.0703,1.0887,1.1117,1.1421,1.1488,1.1384,1.1256,1.1107,1.0954,1.0800,1.0668,1.0544,1.0504,1.0594,1.0723,1.0908,1.0999,1.0956,1.0896,1.0853,1.0797,1.0678,1.0500];
end

% To avoid infeasible acopf problem, baseLoadCurve can be tuned by amplifyFactor
baseLoadCurve = amplifyFactor * baseLoadCurve;

% Time dictionary
name_temp = ["0:00", "0:30", "1:00", "1:30", "2:00", "2:30", "3:00", "3:30", "4:00", "4:30", "5:00", "5:30", "6:00", "6:30", "7:00", "7:30", "8:00", "8:30", "9:00", "9:30", "10:00", "10:30", "11:00", "11:30", "12:00", "12:30", "13:00", "13:30", "14:00", "14:30", "15:00", "15:30", "16:00", "16:30", "17:00", "17:30", "18:00", "18:30", "19:00", "19:30", "20:00", "20:30", "21:00", "21:30", "22:00", "22:30", "23:00", "23:30"];
d = containers.Map(name_temp, 1:1:48);

% Get the time indices
idx_start = d(timeStart);
idx_end = d(timeEnd);

% Handle the case where the end time is earlier than the start time
if idx_end < idx_start
    selectedLoadCurve = [baseLoadCurve(idx_start:end), baseLoadCurve(1:idx_end)];
    selectedTimeLabels = [name_temp(idx_start:end), name_temp(1:idx_end)];
else
    selectedLoadCurve = baseLoadCurve(idx_start:idx_end);
    selectedTimeLabels = name_temp(idx_start:idx_end);
end

% Time vector for the selected window
time = linspace(0, numel(selectedLoadCurve)/2, dataPoints); % Divide by 2 to get hours

% Interpolate the selected load curve to match the desired number of data points
loadCurve = interp1(linspace(0, numel(selectedLoadCurve)/2, numel(selectedLoadCurve)), selectedLoadCurve, time, 'pchip');

% Plot the load curve (if requested)
if curvePlot
    figure;
    plot(time, loadCurve, 'LineWidth', 2);
    xlabel('Time', 'FontName', 'Times New Roman');
    ylabel('Electricity Load', 'FontName', 'Times New Roman');
    title(['Electricity Load Curve from ', timeStart, ' to ', timeEnd], 'FontName', 'Times New Roman');
    grid on;
    % Customize x-ticks to match the selected time window
    xtickIndices = linspace(1, numel(selectedTimeLabels), 10); % 10 x-ticks
    xticks(linspace(0, numel(selectedLoadCurve)/2, 10)); % Divide by 2 to get hours
    xticklabels(selectedTimeLabels(round(xtickIndices)));
    % Set the font for the axes
    set(gca, 'FontName', 'Times New Roman');
end