function failAlgorithms = func_visualize_multi_errors(allResult, selectedErrorFields, alreadyFailedMethod, plotSwitch)
% Function to visualize selected error fields of each algorithm in allResult

% Initialize variables
failAlgorithms = {};
validIndices = [];
groupLabels = {};
groupMaxErrors = [];

% Set colors for boxes
colors = lines(length(selectedErrorFields)+9);

% Iterate over each algorithm to collect max errors and labels
for i = 1:length(allResult)
    % When there is only one result, allResult is a structure, directly give it to algoData
    if isstruct(allResult)
        algoData = allResult;
    % When there are many results, allResult is a cell, give allResult{i} to algoData
    elseif iscell(allResult)
        algoData = allResult{i};
    end
    % Get error fields
    errorFields = fieldnames(algoData.error);
    hasNaN = false;
    
    % Check for NaN values and selected fields presence
    hasSelectedFields = any(ismember(selectedErrorFields, errorFields));
    for j = 1:length(errorFields)
        if any(isnan(algoData.error.(errorFields{j})(:))) || ~hasSelectedFields
            hasNaN = true;
            break;
        end
    end
    
    % Record algorithm if NaN values are present or selected fields are absent
    if hasNaN || ismember(algoData.algorithm, alreadyFailedMethod)
        failAlgorithms{end+1} = algoData.algorithm;
        continue;
    end
    
    % Record valid index, maximum error, and algorithm name for selected fields
    maxError = mean(cellfun(@(field) mean(algoData.error.(field)(:)), intersect(errorFields, selectedErrorFields)));
    validIndices = [validIndices; i];
    groupMaxErrors = [groupMaxErrors; maxError];
    groupLabels{end+1} = algoData.algorithm;
end

% combine skippedAlgorithms with FailedMethod
for i = 1:length(alreadyFailedMethod)
    failAlgorithms{end+1} = alreadyFailedMethod{i};
end
Nfail = length(failAlgorithms);

% Plot the ranking (if requested)
if plotSwitch
    % Sort valid indices by maximum error of selected fields
    [~, sortedIndices] = sort(groupMaxErrors, 'descend');
    sortedValidIndices = validIndices(sortedIndices);

    % Create a figure
    figure;
    hold on;
    set(gca, 'FontName', 'Times New Roman');

    % Create an array of patch and line handles for legend
    totalFields = 2 * length(selectedErrorFields) + 1;  % Twice the number of fields +1 for the Failure legend
    handles = gobjects(totalFields, 1);

    % Create handles for boxes and corresponding mean lines
    for i = 1:length(selectedErrorFields)
        handles(i) = patch(nan(1,3), nan(1,3), colors(i, :), 'EdgeColor', colors(i, :), 'FaceAlpha', 0.2);
        handles(length(selectedErrorFields) + i) = line(NaN, NaN, 'Color', colors(i, :), 'LineWidth', 1.5);
    end
    handles(end) = patch(nan(1,3), nan(1,3), [51/255,58/255,98/255], 'EdgeColor', [51/255,58/255,98/255], 'FaceAlpha', 0.2);  % Handle for Failure


    % Iterate over sorted valid indices to plot data
    for idx = sortedValidIndices'
        % When there is only one result (i.e. length(sortedValidIndices) == 1), allResult is a structure, directly give it to algoData
        if isstruct(allResult)
            algoData = allResult;
        % When there are many results, allResult is a cell, give allResult{i} to algoData
        elseif iscell(allResult)
            algoData = allResult{idx};
        end

        errorFields = fieldnames(algoData.error);

        % Iterate over selected error fields within each algorithm
        for j = 1:length(selectedErrorFields)
            if ismember(selectedErrorFields{j}, errorFields)
                % Get corresponding color
                colorIdx = find(strcmp(selectedErrorFields, selectedErrorFields{j}));
                edgeColor = colors(j, :);
                faceColor = (edgeColor + [1, 1, 1]) / 2;

                % Get error field data and calculate statistics
                errorData = algoData.error.(selectedErrorFields{j});
                minVal = min(errorData(:));
                maxVal = max(errorData(:));
                meanVal = mean(errorData(:));

                % When minVal = 0, replace minVal with 1e-20, otherwise the
                % minVal won't be shown in a log scale figure, as log(0)
                % doesn't exist
                if minVal == 0
                    minVal = 1e-20;
                end

                % Set y-coordinate and draw boxes
                yCoord = Nfail + find(sortedValidIndices == idx) - 0.2;
    %             yCoord = Nfail + find(sortedValidIndices == idx) - 0.2 + (j-1)*0.03;
                X = [minVal, maxVal, maxVal, minVal];
                Y = [yCoord, yCoord, yCoord+0.4, yCoord+0.4];
                fill(X, Y, (faceColor), 'EdgeColor', (edgeColor), 'FaceAlpha', 0.2);
                line([meanVal, meanVal], [yCoord, yCoord+0.4], 'Color', edgeColor, 'LineWidth', 4);
            end
        end
    end

    % Plot failure boxes
    for k = 1:length(failAlgorithms)
        yCoord = k - 0.2;
        X = [1e-20, 1e15, 1e15, 1e-20];
        Y = [yCoord, yCoord, yCoord+0.4, yCoord+0.4];
        fill(X, Y, [51/255,58/255,98/255], 'EdgeColor', [51/255,58/255,98/255], 'FaceAlpha', 0.2);
        groupLabels{end+1} = failAlgorithms{k};  % Use individual algorithm names
    end

    % Set y-axis labels and limits
    set(gca, 'YLim', [0, length(validIndices) + length(failAlgorithms) + 1]);
    set(gca, 'YTick', 1:(length(validIndices) + length(failAlgorithms)));
    yticklabels([failAlgorithms, groupLabels(sortedIndices)]);
    set(gca, 'TickLabelInterpreter', 'none');
    set(gca, 'FontSize', 14); % Enlarges the font size for y-axis labels

    % Set x-axis to logarithmic scale (if desired)
    set(gca, 'XScale', 'log');
    xlim([0, 1e6]);
    xlabel('Relative error |Y_{pred} - Y_{true}| / |Y_{true}|', 'FontName', 'Times New Roman', 'FontSize', 14); % Enlarges the font size for the x-axis label

    % Construct legend labels for both boxes and mean lines
    legendLabels = cell(1, totalFields);
    for i = 1:length(selectedErrorFields)
        legendLabels{i} = [selectedErrorFields{i}, ' distribution'];
        legendLabels{length(selectedErrorFields) + i} = [selectedErrorFields{i} ' mean'];
    end
    legendLabels{end} = 'Failure';

    % Add legend using both patch and line handles
    lgd = legend(handles, legendLabels, 'Location', 'northoutside', 'Orientation', 'horizontal');
    set(lgd, 'FontSize', 16); % Adjusts font size of legend text

    hold off;
end
