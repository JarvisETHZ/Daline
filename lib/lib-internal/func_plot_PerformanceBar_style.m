function func_plot_PerformanceBar_style(methodList, case_list, time_list, PLOT_style)

    % Sort the time
    [time_list, methodList] = func_sortMethodTime(time_list, methodList);
    
    % Global settings
    barWidth = 0.035;
    
    % Apply color schemes
    switch PLOT_style
        case 'dark'
            % Set colors
%             gradientStartColor = [0.1, 0.1, 0.1]; 
            gradientStartColor = [32/255, 34/255, 39/255]; 
%             gradientEndColor = [0.9, 0, 0.8]; 
            gradientEndColor = [1, 1, 1]; 
            % Create the bar plot
            figure;
            nBars = length(time_list);
            nGradientSteps = 100; % Number of steps in the gradient

            for iBar = 1:nBars
                for iStep = 1:nGradientSteps
                    % Calculate the height and color of each patch
                    patchHeight = time_list(iBar) / nGradientSteps;
                    patchColor = gradientStartColor + (gradientEndColor - gradientStartColor) * (iStep / nGradientSteps);

                    % Draw the patch
                    patch([iBar-barWidth/2, iBar-barWidth/2, iBar+barWidth/2, iBar+barWidth/2], ...
                          [(iStep-1)*patchHeight, iStep*patchHeight, iStep*patchHeight, (iStep-1)*patchHeight], ...
                          patchColor, 'EdgeColor', 'none');
                    hold on;
                end
            end
            % Change the color scheme
            set(gca, 'Color', [32/255,34/255,39/255]); % Dark background
            set(gcf, 'Color', [32/255,34/255,39/255]);
            set(gca, 'XColor', 'w', 'YColor', 'w'); % White axes
            set(findall(gcf, 'Type', 'text'), 'Color', 'w'); % White text
        case 'light'
            % Set colors
            gradientStartColor = [1, 1, 1];  
            gradientEndColor = [0.1, 0.1, 0.1];      
            % Create the bar plot
            figure;
            nBars = length(time_list);
            nGradientSteps = 100; % Number of steps in the gradient

            for iBar = 1:nBars
                for iStep = 1:nGradientSteps
                    % Calculate the height and color of each patch
                    patchHeight = time_list(iBar) / nGradientSteps;
                    patchColor = gradientStartColor + (gradientEndColor - gradientStartColor) * (iStep / nGradientSteps);

                    % Draw the patch
                    patch([iBar-barWidth/2, iBar-barWidth/2, iBar+barWidth/2, iBar+barWidth/2], ...
                          [(iStep-1)*patchHeight, iStep*patchHeight, iStep*patchHeight, (iStep-1)*patchHeight], ...
                          patchColor, 'EdgeColor', 'none');
                    hold on;
                end
            end
            % Change the color scheme
            set(gca, 'Color', 'w'); % Light background
            set(gcf, 'Color', 'w');
            set(gca, 'XColor', 'k', 'YColor', 'k'); % Black axes
            set(findall(gcf, 'Type', 'text'), 'Color', 'k'); % Black text
    end
    hold off;

    % Set Y-axis to logarithmic scale
    set(gca, 'YScale', 'log');

    % Set Y-axis lower limit to a small fraction of the smallest non-zero value
    minNonZero = min(time_list(time_list > 0));
    if isempty(minNonZero) % In case all values are zero
        minNonZero = 1;
    end
    ylim([minNonZero/10, max(time_list)*10]);

    % Set X-axis labels with interpreter turned off
    set(gca, 'XTick', 1:length(methodList), 'XTickLabel', methodList, 'TickLabelInterpreter', 'none', 'FontSize', 20, 'FontName', 'Times New Roman');
    ax = gca; % Get current axes
    ax.XAxis.TickLength = [0 0]; % Set tick length to 0 for x-axis    
    if length(methodList) < 10
        ax.XTickLabelRotation = 0; % Rotate labels by 45 degrees
    elseif length(methodList) < 20
        ax.XTickLabelRotation = 30; % Rotate labels by 45 degrees
    elseif length(methodList) < 30
        ax.XTickLabelRotation = 45; % Rotate labels by 45 degrees
    else
        ax.XTickLabelRotation = 90; % Rotate labels by 45 degrees
    end
    xlabel('Methods', 'FontSize', 20, 'FontName', 'Times New Roman', 'FontWeight', 'light');
    ylabel('Compute Time (unit: sec., log-scale)', 'FontSize', 20, 'FontName', 'Times New Roman', 'FontWeight', 'light');
    title(['Computational Time for the ', num2str(case_list), '-bus System'], 'FontSize', 20, 'FontName', 'Times New Roman', 'FontWeight', 'light');
    
    % Apply color schemes again
    switch PLOT_style
        case 'dark'
            % Change the color scheme
            set(gca, 'Color', [32/255,34/255,39/255]); % Dark background
            set(gcf, 'Color', [32/255,34/255,39/255]);
            set(gca, 'XColor', 'w', 'YColor', 'w'); % White axes
            set(findall(gcf, 'Type', 'text'), 'Color', 'w'); % White text
        case 'light'
            % Change the color scheme
            set(gca, 'Color', 'w'); % Light background
            set(gcf, 'Color', 'w');
            set(gca, 'XColor', 'k', 'YColor', 'k'); % Black axes
            set(findall(gcf, 'Type', 'text'), 'Color', 'k'); % Black text
    end

end
