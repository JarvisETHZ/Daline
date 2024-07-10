function func_plot_Performance_style(methodNames, caseNumbers, computeTime, style)
    % Validate inputs
    if size(computeTime, 2) ~= numel(caseNumbers)
        error('Number of columns in computeTime must match the number of elements in caseNumbers.');
    end

    % Check for style input and set the figure style accordingly
    if nargin < 4 || strcmp(style, 'dark')
        bgColor = [32/255,34/255,39/255]; % black background
        txtColor = 'w'; % white text
        axColor = [32/255,34/255,39/255]; % black axes
        transColor = [1 1 1]; % transition to white for gradients
        edgeColor = [0.5 0.5 0.5]; % edge color for the legend
        % Define sophisticated end colors for dark style
        endColors = load('lineColorSchme.mat');
        endColors = endColors.endColors;
        scalingFactor = 1.5; % Adjust this value as needed
        endColors = min(endColors * scalingFactor, 1); % Scale and clip the values
    elseif strcmp(style, 'light')
        bgColor = 'w'; % white background
        txtColor = 'k'; % black text
        axColor = 'w'; % white axes
        transColor = [0.8 0.8 0.8]; % transition to light gray for gradients
        edgeColor = [0.8 0.8 0.8]; % edge color for the legend
        % Define sophisticated end colors for light style
        endColors = load('lineColorSchme.mat');
        endColors = endColors.endColors;
        scalingFactor = 0.8; % Adjust this value as needed
        endColors = min(endColors * scalingFactor, 1); % Scale and clip the values
    else
        error('Style must be either ''dark'' or ''light''.');
    end

    % Ensure there are enough colors for each method, repeat the colors if necessary
    numMethods = size(computeTime, 1);
    if numMethods > size(endColors, 1)
        repeatedColors = repmat(endColors, ceil(numMethods / size(endColors, 1)), 1);
        endColors = repeatedColors(1:numMethods, :);
    end
    
    % Define additional line styles and markers
    lineStyles = {'-', '--', ':', '-.'}; % Different line styles
%     lineStyles = {'-', '--', ':', '-.'}; % Different line styles
    markers = {'o', 's', 'd', '^', 'v', '<', '>', 'p', 'h', '*', '+'}; % Different markers
%     markers = {'o', 's', 'd', '^', 'v', '<', '>', 'p', 'h', '*', '+'}; % Different markers
    numMethods = size(computeTime, 1);

    % Prepare the figure
    figure('Color', bgColor);
    
    % Set axes properties
    ax = axes('Parent', gcf, 'Color', axColor, 'XColor', txtColor, 'YColor', txtColor);
    set(ax, 'TickLength', [0 0]); % Hide the ticks but keep labels
    box off; % Remove the box around the plot
    hold on;
    
    % Generate x-ticks based on the unique values in caseNumbers
    xTicks = unique(caseNumbers);
    set(ax, 'XTick', xTicks, 'XTickLabel', string(xTicks)); % Set x-tick labels

    % Generate y-ticks with a log-scale distribution
    yMin = min(computeTime(computeTime > 0), [], 'all'); % Minimum non-zero value
    yMax = max(computeTime, [], 'all'); % Maximum value
    yTicks = logspace(log10(yMin), log10(yMax), 10); % Generate 10 ticks on a log scale
    set(ax, 'YTick', yTicks, 'YTickLabel', string(round(yTicks, 2)));
    
    % Find the minimum value for x-axis that makes sense for the plot
    minCaseNumber = min(caseNumbers);

    % Ensure the x-axis starts from the minimum value of caseNumbers
    xlim(ax, [minCaseNumber max(caseNumbers)]);

    % Plot the performance lines with gradient
    legendEntries = gobjects(size(computeTime, 1), 1); % Preallocate for legend handles

    for i = 1:size(computeTime, 1)
        % Skip NaN values in computeTime
        validIndices = ~isnan(computeTime(i,:));
        validCaseNumbers = caseNumbers(validIndices);
        validComputeTimes = computeTime(i, validIndices);

        % Generate the x values for interpolation on valid data
        xx = linspace(min(validCaseNumbers), max(validCaseNumbers), 200);
        yy = interp1(validCaseNumbers, validComputeTimes, xx, 'pchip');

        % Determine the number of segments for the gradient
        numSegments = length(xx) - 1;
        halfSegment = floor(numSegments / 4);
        
        % Choose line style, marker for current method
        lineStyle = lineStyles{mod(i-1, numel(lineStyles)) + 1};
        marker = markers{mod(i-1, numel(markers)) + 1};

        % Generate a gradient for the current line
        for j = 1:numSegments
            
            % Now use the sophisticated end color for this method
            finalColor = endColors(i, :);
        
            if j <= halfSegment
                % First half transitions from darkColor to transColor
                t = (j - 1) / halfSegment; % Transition factor
                currentColor = (1 - t) * finalColor/3 + t * transColor;
            else
                % Second half transitions from transColor to endColor
                t = (j - halfSegment - 1) / (numSegments - halfSegment); % Transition factor
                currentColor = (1 - t) * transColor + t * finalColor;
            end

            % Ensure RGB values are within the correct range
            currentColor = max(0, min(1, currentColor));

            % Plot the current segment
            plot(ax, xx(j:j+1), yy(j:j+1), 'Color', [currentColor, 0.98], 'LineWidth', 1.5, 'LineStyle', lineStyle);
        end
        
        % Instead of using original data points for markers, use interpolated points
        markerIndices = unique([1 round(linspace(1, length(xx), min(10, length(xx))))]);

        % Plot markers on the interpolated curve
        plot(ax, xx(markerIndices), yy(markerIndices), 'LineStyle', 'none', 'Marker', marker, 'Color', finalColor);
        
        % Plot an invisible line with the same style and marker for the legend
        legendEntries(i) = plot(ax, NaN, NaN, 'LineStyle', lineStyle, 'Marker', marker, 'Color', finalColor, 'LineWidth', 1.5, 'DisplayName', methodNames{i});
    end

    % Set the axis to logarithmic
    set(gca, 'YScale', 'log', 'FontSize', 20); 
    set(gca, 'XScale', 'log', 'FontSize', 20); 
    
    % Create the legend using the handles of the invisible points
    lgd = legend(legendEntries);
    set(lgd, 'TextColor', txtColor, 'EdgeColor', edgeColor, 'Interpreter', 'none', 'FontSize', 20, 'FontName', 'Times New Roman', 'FontWeight', 'light');
    xlabel('Number of Buses (log-scale)', 'Color', txtColor, 'FontSize', 20, 'FontName', 'Times New Roman', 'FontWeight', 'light');
    ylabel('Compute Time (unit: sec., log-scale)', 'Color', txtColor, 'FontSize', 20, 'FontName', 'Times New Roman', 'FontWeight', 'light');
    title('Compute Time vs. System Size', 'Color', txtColor, 'FontSize', 20, 'FontName', 'Times New Roman', 'FontWeight', 'light');
    hold off;
end
