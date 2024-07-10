function func_plot_Distributions(error_matrix, title_str, legends)
% plotDistributions - Plot distributions with filled areas under the curves

%% Start

% Number of distributions
numDistributions = size(error_matrix, 2);

% Define a colormap
colors = lines(numDistributions);

% Create a figure
hold on;

% Initialize handles for the legend
h = zeros(numDistributions, 1);

% Loop through each distribution
for i = 1:numDistributions
    % Compute the kernel density estimate
%     [f, x] = ksdensity(error_matrix(:, i), 'Kernel', 'box', 'Bandwidth', 0.5);
    [f, x] = ksdensity(error_matrix(:, i));

    % Fill the area under the curve and store the handle
    h(i) = fill(x, f, colors(i, :), 'FaceAlpha', 0.5, 'EdgeColor', 'none');

    % Plot the curve
    plot(x, f, 'Color', colors(i, :), 'LineWidth', 2);
end

% Add labels, title, etc.
xlabel('Error', 'FontName', 'Times New Roman');
ylabel('Density', 'FontName', 'Times New Roman');
title(['Distributions of ', title_str], 'FontName', 'Times New Roman');
legend(h, legends, 'FontName', 'Times New Roman', 'Interpreter', 'none');

hold off;

end