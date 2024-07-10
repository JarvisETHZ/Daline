function failedMethods = func_plot_ProDistribution3D(models, opt)
    % Get all field
    fields = opt.PLOT.response;
    
    % Define failedMethod container individually
    failedMethods = cell(length(fields), 2);

    % Predefined color set
    baseColors = [
        20, 49, 75;
        41, 85, 122;
        60, 108, 138;
        80, 130, 154;
        90, 145, 161;
        99, 153, 169;
        101, 158, 173;
        105, 163, 178;
        151, 186, 186;
        182, 207, 207;
        192, 214, 214;
        222, 250, 250
    ] / 255;

    % Function to interpolate colors
    function colors = interpolateColors(baseColors, numColors)
        baseColorCount = size(baseColors, 1);
        if numColors <= baseColorCount
            colors = baseColors(1:numColors, :);
        else
            % Interpolating colors to match the required number
            colors = interp1(linspace(0, 1, baseColorCount), baseColors, linspace(0, 1, numColors));
        end
    end

    % Loop through each field provided
    for fieldIdx = 1:numel(fields)
        
        % Get field
        field = fields{fieldIdx};
        
        % Original number of models
        numModels = numel(models);

        % Initialize valid models and their mean errors
        validModels = {};
        meanErrors = [];

        % Check each model for errors
        for i = 1:numModels
            % Extract error data for the current model
            errorData = models{i}.error;

            % Check if the specified field exists and contains no NaN values
            if isfield(errorData, field) && ~any(isnan(errorData.(field)(:)))
                % If valid, add the model to the validModels list
                validModels{end+1} = models{i};

                % Calculate the mean error
                allErrors = errorData.(field)(:);
                meanErrors(end+1) = mean(allErrors);
            else
                % If invalid, add the algorithm name to the failedMethods list
                failedMethods{fieldIdx, 1}{end+1, 1} = strrep(models{i}.algorithm, '_', '-');
            end
        end
        
        % Give notification for the failedMethods: if failedMethods{fieldIdx, 1} is not empty => method(s) failed for this response 
        if ~isempty(failedMethods{fieldIdx, 1})
            failedMethods{fieldIdx, 2} = ['Method(s) that failed when predicting ', field];
        end

        % Update the number of valid models
        numValidModels = numel(validModels);

        % Rank the valid models based on mean error
        [~, rankedIndices] = sort(meanErrors);

        % Extract algorithm names for y-tick labels and replace underscores with dashes
        algorithmNames = cellfun(@(model) strrep(model.algorithm, '_', '-'), validModels, 'UniformOutput', false);
        rankedAlgorithmNames = algorithmNames(rankedIndices);

        % Interpolate colors to match the number of valid models
        colors = interpolateColors(baseColors, numValidModels);

        % Define the base transparency and generate higher transparencies
        startAlpha = opt.PLOT.startAlpha;  % Initial transparency
        endAlpha = opt.PLOT.endAlpha;      % Final transparency
        alphas = linspace(startAlpha, endAlpha, numValidModels);

        % Create a new figure
        figureHandle = figure;

        % Set the figure background color based on the style
        if strcmp(opt.PLOT.style, 'dark')
            bgColor = [32/255, 34/255, 39/255];
            textColor = [1, 1, 1];
        else
            bgColor = [1, 1, 1];
            textColor = [0, 0, 0];
        end
        set(figureHandle, 'Color', bgColor);

        % Number of points for the fitted distribution
        numPoints = opt.PLOT.disPoints;

        % Small constant to handle zero or negative error values
        epsilon = opt.PLOT.logShift;
        
        % Number of components for GMM
        numComponent = opt.PLOT.numComponent;

        % Loop through each ranked model
        for i = 1:numValidModels
            % Get the ranked index
            rankedIndex = rankedIndices(i);

            % Extract error data for the current model
            errorData = validModels{rankedIndex}.error;

            % Flatten the 'all' field data and handle zeros by adding epsilon
            allErrors = errorData.(field)(:) + epsilon;

            % Fit a normal distribution to the data
            pd = fitgmdist(log(allErrors), numComponent);

            % Define the x range for the log-transformed error values
            x = linspace(min(log(allErrors)), max(log(allErrors)), numPoints);

            % Get the probability density values from the normal distribution
            z = pdf(pd, x');

            % Normalize the probability density values if the variance
            % among z values of different models is too large and the
            % distributions are invisible on the same figure
            if opt.PLOT.norm
                z = z / max(z);
            end

            % Model index for separation in the y-axis
            y = i * ones(size(x));

            % Transform x back to the original scale
            x = exp(x);

            % Create the polygon vertices for fill3
            x_poly = [x, fliplr(x)];
            y_poly = [y, y];
            z_poly = [zeros(size(z')), fliplr(z')];  % Baseline to the probability density

            % Plot the 3D area plot
            fill3(x_poly, y_poly, z_poly, colors(i, :), 'FaceAlpha', alphas(i), 'EdgeColor', 'none');
            hold on;

            % Add a line on the x-y plane for each distribution connecting to the y-axis
            plot3([1e4, min(x)], [i, i], [0, 0], 'Color', colors(i, :), 'LineWidth', 0.3);
        end

        % Set the x-axis to log scale
        set(gca, 'XScale', 'log');

        % Set the axis labels and title
        xlabelHandle = xlabel(['Relative Error of ', field], 'FontName', 'Times New Roman', 'FontSize', 18, 'Interpreter', 'none', 'Color', textColor);
        ylabelHandle = ylabel('Method', 'FontName', 'Times New Roman', 'FontSize', 18, 'Interpreter', 'none', 'Color', textColor);
        if opt.PLOT.norm
            zlabelHandle = zlabel('Normalized Probability Distribution', 'FontName', 'Times New Roman', 'FontSize', 18, 'Interpreter', 'none', 'Color', textColor);
        else
            zlabelHandle = zlabel('Probability Distribution', 'FontName', 'Times New Roman', 'FontSize', 18, 'Interpreter', 'none', 'Color', textColor);
        end
        
        
        % Adjust the position of the x-axis label
        set(xlabelHandle, 'Position', get(xlabelHandle, 'Position') - [0, 0.2, 0]); % Modify the y-distance

        % Turn off the grid
        grid off;

        % Customize the y-ticks to show the ranked method names
        set(gca, 'YTick', 1:numValidModels, 'YTickLabel', rankedAlgorithmNames, 'FontName', 'Times New Roman', 'FontSize', 18, 'Color', textColor);

        % Set the axes background color based on the style
        set(gca, 'Color', bgColor); 

        % Set the axis color based on the style
        set(gca, 'XColor', textColor, 'YColor', textColor, 'ZColor', textColor);

        % Turn off the legend
        legend off;

        % Set the view angle for better visualization
        view(-30, 30);
    end
end
