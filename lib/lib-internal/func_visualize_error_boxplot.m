function skippedAlgs = func_visualize_error_boxplot(result, fieldName)
    % Get the number of sub-structs
    numSubStructs = size(result, 1);
    
    % Initialize an empty cell array to hold the names of skipped algorithms
    skippedAlgs = {};
    
    % Initialize subplot index
    subplotIdx = 1;
    
    % Initialize global min and max variables
    globalMin = inf;
    globalMax = -inf;
    
    if nargin > 1 && ~isempty(fieldName)
        globalMin = inf;
        globalMax = -inf;
        for i = 1:numSubStructs
            errorStruct = result{i, 1}.error;
            if isfield(errorStruct, fieldName)
                fieldData = errorStruct.(fieldName)(:);
                localMin = min(fieldData);
                localMax = max(fieldData);
                globalMin = min(globalMin, localMin);
                globalMax = max(globalMax, localMax);
            end
        end
    end
    
    % Second loop to create subfigures
    for i = 1:numSubStructs
        errorStruct = result{i, 1}.error;
        fieldNames = fieldnames(errorStruct);
        allFieldsNaN = all(cellfun(@(field) all(isnan(errorStruct.(field)(:))), fieldNames));
        if allFieldsNaN
            skippedAlgs{end+1} = result{i, 2};
            continue;
        end

        % Filter data based on fieldName
        if nargin > 1 && ~isempty(fieldName)
            if ~isfield(errorStruct, fieldName)
                warning(['Field ' fieldName ' not found in data set ' num2str(i) '. Skipping this data set.']);
                continue;
            end
            fieldNames = {fieldName};
        end

        % Adjust subplot call for vertical arrangement
        subplot(numSubStructs - length(skippedAlgs), 1, subplotIdx);
        subplotIdx = subplotIdx + 1;

        % plot
        boxData = [];
        group = [];
        for j = 1:length(fieldNames)
            fieldData = errorStruct.(fieldNames{j})(:);
            boxData = [boxData; fieldData];
            group = [group; j * ones(size(fieldData))];
        end
        % Create box plot without suppressing outliers
        hBoxPlot = boxplot(boxData, group, 'Orientation', 'horizontal', 'Labels', fieldNames);

        % Change color scheme to low saturation using patch
        hBox = findobj(gca,'Tag','Box');
        for j=1:length(hBox)
            patch(get(hBox(j),'XData'),get(hBox(j),'YData'),[0.8 0.8 0.8],'FaceAlpha',.5);
        end

        % Highlight the mean
        hMean = findobj(gca,'Tag','Mean');
        set(hMean, 'Color', [0 0 0], 'LineWidth', 3); % Set color to bright red and line width to 2

        % Adjust outlier properties
        hOutliers = findobj(gca,'Tag','Outliers');
        set(hOutliers, 'MarkerEdgeColor', [0.93 0.93 0.93]); % Set outlier color to a light gray
        
        % Set the x-axis to logarithmic scale
        set(gca, 'XScale', 'log');
        
        % Set x-axis limits
        xlim([globalMin, globalMax]);

        % Set title, and axis labels
        if i == 1
            title(fieldNames, 'Interpreter', 'none', 'FontName', 'Times New Roman', 'FontSize', 14);
        end
        xlabel('Fields', 'FontName', 'Times New Roman', 'FontSize', 12);
%         ylabel(result{i, 2}, 'Interpreter', 'none', 'FontName', 'Times New Roman', 'FontSize', 14, 'Rotation', 0);
        set(gca, 'FontName', 'Times New Roman', 'FontSize', 12);
        set(gca, 'YTickLabel', {});
        
        % Set y-axis label and store handle
        hYLabel = ylabel(result{i, 2}, 'Interpreter', 'none', 'FontName', 'Times New Roman', 'FontSize', 12, 'Rotation', 0);
        
        % Switch to normalized units for positioning
        set(hYLabel, 'Units', 'Normalized');

        % Adjust position of y-label
        labelPosition = get(hYLabel, 'Position');
        set(hYLabel, 'Position', [labelPosition(1) - 0.02, labelPosition(2) - 0.07, labelPosition(3)]);
    end
end
