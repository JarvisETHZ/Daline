function func_visualize_error_selective(result)
     % Get the number of sub-structs
    numSubStructs = size(result, 1);
    
    % Set up colors for each field
    colors = lines(9);  % Assuming at most 9 fields
    
    % Create an overall figure to hold all sub-figures
    figure;
    
    % Initialize an empty cell array to hold the names of skipped algorithms
    skippedAlgs = {};
    
    % Initialize subplot index
    subplotIdx = 1;
    
    for i = 1:numSubStructs
        % Get the error struct for the current sub-struct
        errorStruct = result{i, 1}.error;
        
        % Get the fieldnames within the error struct
        fieldNames = fieldnames(errorStruct);
        
        % Check if all fields are full of NaN values
        allFieldsNaN = all(cellfun(@(field) all(isnan(errorStruct.(field)(:))), fieldNames));
        
        if allFieldsNaN
            % If all fields are full of NaN values, skip plotting for this sub-struct
            % and add the algorithm name to the skippedAlgs array
            skippedAlgs{end+1} = result{i, 2};  %#ok<AGROW>
            continue;
        end
        
        % Create a sub-figure for the current sub-struct
        subplot(ceil(sqrt(numSubStructs - length(skippedAlgs))), ceil(sqrt(numSubStructs - length(skippedAlgs))), subplotIdx);
        subplotIdx = subplotIdx + 1;  % Increment subplot index% Create a sub-figure for the current sub-struct
        hold on;
        
        for j = 1:length(fieldNames)
            % Get the current field data
            fieldData = errorStruct.(fieldNames{j})(:);  % Reshape the data into a vector
            
            % Find the color index corresponding to the current field
            if strcmp({'PF'}, fieldNames{j})
            
                % Find the color index corresponding to the current field
                colorIdx = find(strcmp({'Vm', 'Va', 'PF', 'PT', 'QF', 'QT', 'P', 'Q', 'all'}, fieldNames{j}));

                % If the color index is empty, use a default value
                if isempty(colorIdx)
                    colorIdx = 1;
                end

                % Estimate the probability density function using ksdensity
                [f, x] = ksdensity(fieldData);

                % Fill the area under the curve
                fill(x, f, colors(colorIdx, :), 'FaceAlpha', 0.5, 'EdgeColor', 'none', 'HandleVisibility', 'off');

                % Plot the curve
                plot(x, f, 'Color', colors(colorIdx, :), 'LineWidth', 2);
            end
        end
        
        % Set title, axis labels, and legend
        title(result{i, 2}, 'FontName', 'Times New Roman', 'FontSize', 14);
%         legend(fieldNames, 'FontName', 'Times New Roman', 'FontSize', 12);
        set(gca, 'FontName', 'Times New Roman', 'FontSize', 12);
        
%         % Adjust the x-axis ticks to reflect the original data scale in scientific notation
%         xticks = 10 .^ (floor(min(x)):ceil(max(x)));
%         set(gca, 'XTick', log(xticks));
%         set(gca, 'XTickLabel', arrayfun(@(x) sprintf('%.1e', x), xticks, 'UniformOutput', false));
        
        hold off;
    end
end






