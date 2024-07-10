function func_plot_Performance(methodNames, caseNumbers, computeTime)
    % Validate inputs
    if size(computeTime, 2) ~= numel(caseNumbers)
        error('Number of columns in computeTime must match the number of elements in caseNumbers.');
    end
    
    % Define sophisticated end colors
    endColors = [
        [68, 189, 50]/255;  % A shade of green
        [189, 147, 249]/255;  % A soft purple
        [245, 59, 87]/255;  % A gentle red
        [87, 101, 116]/255;  % A muted blue-grey
        [255, 195, 18]/255;  % A warm yellow
        [24, 44, 97]/255;  % A deep navy blue
        [210, 218, 226]/255;  % Light grey-blue
        [255, 87, 51]/255;  % Coral red
    ];

    % Ensure there are enough colors for each method, repeat the colors if necessary
    numMethods = size(computeTime, 1);
    if numMethods > size(endColors, 1)
        repeatedColors = repmat(endColors, ceil(numMethods / size(endColors, 1)), 1);
        endColors = repeatedColors(1:numMethods, :);
    end

    % Prepare the figure
    figure('Color', 'k'); % Set the figure background to black
    
    % Set axes properties
    ax = axes('Parent', gcf, 'Color', 'k', 'XColor', 'w', 'YColor', 'w');
    set(ax, 'TickLength', [0 0]); % Hide the ticks but keep labels
    box off; % Remove the box around the plot
    hold on;
    
    % Generate x-ticks based on the unique values in caseNumbers
    xTicks = unique(caseNumbers);
    set(ax, 'XTick', xTicks, 'XTickLabel', string(xTicks)); % Set x-tick labels

    % Generate y-ticks based on the range of computeTime
    yTicks = linspace(min(computeTime, [], 'all'), max(computeTime, [], 'all'), 5);
    set(ax, 'YTick', yTicks, 'YTickLabel', string(round(yTicks, 2))); % Set y-tick labels
    
    % Find the minimum value for x-axis that makes sense for the plot
    minCaseNumber = min(caseNumbers);

    % Ensure the x-axis starts from the minimum value of caseNumbers
    xlim(ax, [minCaseNumber max(caseNumbers)]);

    % Define starting color for the gradients
    darkColor = [0.1, 0.1, 0.1]; % Dark grey
    
    % Define transition color
    transColor = [0.9, 0.9, 0.9];

    % Plot smooth curves for each method and prepare legend entries
    legendEntries = zeros(1, size(computeTime, 1)); % Preallocate for legend handles

    for i = 1:size(computeTime, 1)
        % Generate the x values for interpolation
        xx = linspace(minCaseNumber, max(caseNumbers), 200); % Fine grid for a smooth curve
        yy = interp1(caseNumbers, computeTime(i,:), xx, 'pchip'); % PCHIP interpolation

        % Determine the number of segments for the gradient
        numSegments = length(xx) - 1;
        halfSegment = floor(numSegments / 2);

        % Generate a gradient for the current line
        for j = 1:numSegments
            
            % Now use the sophisticated end color for this method
            finalColor = endColors(i, :);
        
            if j <= halfSegment
                % First half transitions from darkColor to white
                t = (j - 1) / halfSegment; % Transition factor
                currentColor = (1 - t) * finalColor/3 + t * transColor;
            else
                % Second half transitions from white to endColor
                t = (j - halfSegment - 1) / (numSegments - halfSegment); % Transition factor
                currentColor = (1 - t) * transColor + t * finalColor;
            end

            % Ensure RGB values are within the correct range
            currentColor = max(0, min(1, currentColor));

            % Plot the current segment
            plot(ax, xx(j:j+1), yy(j:j+1), 'Color', [currentColor, 0.8], 'LineWidth', 1.5);
        end

        % Plot an invisible point for the legend
        legendEntries(i) = plot(ax, NaN, NaN, 'Color', finalColor, 'LineWidth', 2, 'DisplayName', methodNames{i});
    end

    % Create the legend using the handles of the invisible points
    lgd = legend(legendEntries);
    set(lgd, 'TextColor', 'w', 'EdgeColor', [0.5 0.5 0.5]);
    xlabel('Number of Cases');
    ylabel('Compute Time (s)');
    title('Compute Time vs. Case Number', 'Color', 'w');
    
    % Set the axis to logarithmic if needed
    set(gca, 'YScale', 'log');
    
    hold off;
end
