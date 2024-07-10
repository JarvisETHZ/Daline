function func_plot_errorLine_style(methodNames, meanErrors, maxErrors, style, origin, methodsNaN, selectedField, titleHight, caseName, printSwitch)
    % Check if the input vectors are of the same length
    if length(methodNames) ~= length(meanErrors) || length(methodNames) ~= length(maxErrors)
        error('Input vectors must be of the same length.');
    end
    
    % Set the style based on input
    if strcmp(style, 'dark')
        bgColor = [32/255,34/255,39/255]; % black
        textColor = 'w'; % white
        lineBgColor = [0.15, 0.15, 0.15];
        blockEdgeColor = bgColor; % cyan
        % Define gradient colors for the lines (dark style)
        gradientColors = generateGradient([1, 1, 1], [0, 1, 1], [0.5, 0.5, 0.9], [0.6, 0.4, 0.7], 100);
        % Define colors for the mean error blocks (dark style)
        blockColors = bgColor;
    elseif strcmp(style, 'light')
        bgColor = [1,1,1]; % %[1,1,1]
        textColor = 'k'; % black
        lineBgColor = [0.85, 0.85, 0.85];
        blockEdgeColor = [1,1,1]; %[1,1,1]
        % Define gradient colors for the lines (light style)
        gradientColors = generateGradient([0.678, 0.847, 0.902], [0.000, 0.749, 1.000], [0.000, 0.447, 0.741], [0.000, 0.000, 0.502], 100);
        % Define colors for the mean error blocks (light style)
        blockColors = [1,1,1]; %[1,1,1]
    else
        error('Style must be ''dark'' or ''light''.');
    end

    % Create a figure with the chosen background color
    h = figure('Color', bgColor);
    
    % Define the maximum line length based on the max of the max errors
    if ~isempty(maxErrors)
        % If there are some methods that succeed and have a max error
        fullLength = max(maxErrors);
    else
        % If all the methods are failed
        fullLength = 0.1;
    end
    
    
    % Set the line width and spacing between lines
    lineWidth = 2;
    blockWidth = 0.1;  % Make the block a bit wider than the line
    
    % Determine spacing between lines
    lineSpacing = 0.5;  % Adjust spacing if needed
    
    % Assume yPos is the starting vertical position for the first line
    yPos = 0.1; 
    
    % Plot the lines for methods with NaN errors
    for i = 1:length(methodsNaN)
        % Draw the full length background line
        line([0, fullLength], [yPos, yPos], 'Color', lineBgColor, 'LineWidth', lineWidth);

        % Add the method name to the left of the line
        text(0.01*fullLength, yPos+0.1, methodsNaN{i}, 'Color', textColor, 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'left', 'FontSize', 12, 'FontName', 'Times New Roman', 'FontWeight', 'light', 'Interpreter', 'none');

        % Add the text "failure" on the right
        text(fullLength, yPos+0.1, 'failure', 'Color', textColor, 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', 'FontSize', 12, 'FontName', 'Times New Roman', 'FontWeight', 'light');
        
        % Update the yPos for the next line (adjust the increment as needed)
        yPos = yPos + lineSpacing;
    end
    
    % Loop to create each line and block for mean error
    for i = 1:length(methodNames)
        
        % Draw the full length line as background with a darker color
        line([0, fullLength], [yPos, yPos], 'Color', lineBgColor, 'LineWidth', lineWidth);
        
        % Draw the actual max error line with gradient
        numGradientSegments = round(length(gradientColors));
%         numGradientSegments = round(maxErrors(i) / fullLength * length(gradientColors));
        for j = 1:numGradientSegments
            line([(j-1)*maxErrors(i)/numGradientSegments, j*maxErrors(i)/numGradientSegments], [yPos, yPos], 'Color', gradientColors(j, :), 'LineWidth', lineWidth);
        end
        
        % Draw the mean error block
        blockCenter = meanErrors(i);
        patch('Vertices', [blockCenter - blockWidth/2, yPos - lineWidth/16; ...
                   blockCenter + blockWidth/2, yPos - lineWidth/16; ...
                   blockCenter + blockWidth/2, yPos + lineWidth/16; ...
                   blockCenter - blockWidth/2, yPos + lineWidth/16], ...
                  'Faces', [1, 2, 3, 4], 'EdgeColor', blockEdgeColor, ...
                  'FaceColor', blockColors, 'FaceAlpha', 0.8);
              
        % Add the method name to the left of the line
        text(0.01*fullLength, yPos+0.1, methodNames{i}, 'Color', textColor, 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'left', 'FontSize', 12, 'FontName', 'Times New Roman', 'FontWeight', 'light', 'Interpreter', 'none');
%         text(-0.07*fullLength, yPos-0.1, methodNames{i}, 'Color', textColor, 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'left', 'FontSize', 12, 'FontName', 'Times New Roman', 'FontWeight', 'light', 'Interpreter', 'none');
        
        % Add the error details to the right of the line
        % Convert numbers to scientific notation string
        meanErrorStr = sprintf('%.1fx10^{%d}', significand(10^(meanErrors(i)-origin)), exponent(10^(meanErrors(i)-origin)));
        maxErrorStr = sprintf('%.1fx10^{%d}', significand(10^(maxErrors(i)-origin)), exponent(10^(maxErrors(i)-origin)));

        % Create the text for the plot
        textStr = ['mean: ', meanErrorStr, '      max: ', maxErrorStr];
        text(fullLength, yPos+0.1, textStr, 'Color', textColor, 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', 'FontSize', 12, 'FontName', 'Times New Roman', 'FontWeight', 'light');
        
        % Calculate position of the line
        yPos = yPos + lineSpacing;

    end
    
    % Remove x and y axis ticks and labels
    set(gca, 'xtick', [], 'ytick', [], 'XColor', 'none', 'YColor', 'none', 'Color', bgColor);
    
    % Set the axis limits
    xlim([0, fullLength]);
    ylim([0, lineSpacing*(length(methodsNaN)+length(methodNames)+1)]);
    
    % Set the axis to logarithmic if needed
%     set(gca, 'XScale', 'log');
    
    % Add title with chosen text color and modern font
    if isempty(caseName)
        hTitle = title(['Relative Error of ', selectedField{1}, ' (log-scale)'], 'Color', textColor, 'FontSize', 16, 'FontName', 'Times New Roman', 'FontWeight', 'light');
    else
        hTitle = title([caseName, ': Relative Error of ', selectedField{1}, ' (log-scale)'], 'Color', textColor, 'FontSize', 16, 'FontName', 'Times New Roman', 'FontWeight', 'light');
    end
    titlePos = get(hTitle, 'Position');
    titlePos(2) = titlePos(2) - titleHight; 
    set(hTitle, 'Position', titlePos);
    
    % Remove the box around the plot
    box off;
    
    % Print the figure if needed
    if printSwitch
        % Set units
        set(h, 'Units', 'Centimeters');

        % Set the position and size of the figure window
        % [left, bottom, width, height]
        figPosition = [0, 0, 62.00, 42.30];
        set(h, 'Position', figPosition);

        % Set the paper size and paper position
        % Here, 'PaperPosition' determines the location and size of the figure on the paper
        % For landscape orientation, width is greater than height
        paperWidth = 51;
        paperHeight = 36;
        set(h, 'PaperSize', [paperHeight, paperWidth]);

        % 'PaperPositionMode' is set to 'auto' so that MATLAB automatically adjusts the
        % printing to match the figure's size and position
        set(h, 'PaperPositionMode', 'auto', 'PaperUnits', 'Centimeters', 'PaperOrientation', 'landscape');

        % Print the figure to a PDF file
        % '-r0' specifies screen resolution
        if isempty(caseName)
            print(h, 'filename', '-dpdf', '-r0');
        else
            print(h, [caseName, '-', selectedField{1}], '-dpdf', '-r0');
        end
    end
    
end

function gradColors = generateGradient(startColor, midColor1, midColor2, endColor, steps)
    % Generates a smooth gradient given four colors and the number of steps
    gradColors = [linspace(startColor(1), midColor1(1), ceil(steps/3))', linspace(startColor(2), midColor1(2), ceil(steps/3))', linspace(startColor(3), midColor1(3), ceil(steps/3))';
                  linspace(midColor1(1), midColor2(1), ceil(steps/3))', linspace(midColor1(2), midColor2(2), ceil(steps/3))', linspace(midColor1(3), midColor2(3), ceil(steps/3))';
                  linspace(midColor2(1), endColor(1), floor(steps/3))', linspace(midColor2(2), endColor(2), floor(steps/3))', linspace(midColor2(3), endColor(3), floor(steps/3))'];
end


function s = significand(x)
    if x == 0
        s = 0;
    else
        e = floor(log10(abs(x)));
        s = x / 10^e;
    end
end

function e = exponent(x)
    if x == 0
        e = 0;
    else
        e = floor(log10(abs(x)));
    end
end


