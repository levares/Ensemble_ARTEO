function plotResults(seedPoints, observations, ensembleModels, xFit, combinedMeanPredictions, combinedStdPredictions, combinedSpreadPredictions, safeIndices, safeXMin, safeXMax, g, blackBoxFunction, newExplorationPoint)
    figure;

    % Subplot 1: Seed points and ensemble fittings using all seed points
    subplot(2, 2, 1);
    hold on;

    maxOrder = length(ensembleModels);
    colors = lines(maxOrder);
    plotHandles = gobjects(maxOrder, 1); % Handles for the plot lines
    for i = 1:maxOrder
        polyModel = ensembleModels{i};
        yFitPoly = polyval(polyModel, xFit);
        plotHandles(i) = plot(xFit, yFitPoly, 'Color', colors(i, :), 'LineWidth', 2);
    end

    % Plot the seed points on top
    scatterHandle = scatter(seedPoints, observations, 'filled', 'k'); % Seed points

    % Highlight the new exploration point if provided
    if ~isempty(newExplorationPoint)
        scatter(newExplorationPoint, blackBoxFunction(newExplorationPoint), 'filled', 'MarkerFaceColor', 'm', 'MarkerEdgeColor', 'm'); % Purple dot for new point
    end

    title('Ensemble Fittings with All Seed Points');
    xlabel('x');
    ylabel('y');
    Differences = max(observations) - min(observations);
    ylim([min(observations) - Differences/2, max(observations) + Differences/2]);
    xlim([min(seedPoints) - 1, max(seedPoints) + 1]); % Focus on the region around known points
    legend([plotHandles; scatterHandle], [arrayfun(@(i) sprintf('Poly %d', i), 1:maxOrder, 'UniformOutput', false), 'Seed Points'], 'Location', 'Best');
    hold off;

    % Subplot 2: Mean, spread, and std of the ensemble models with safe restriction
    subplot(2, 2, 2);
    hold on;
    yyaxis left;

    fill([xFit(safeIndices); flipud(xFit(safeIndices))], [combinedMeanPredictions(safeIndices) + combinedSpreadPredictions(safeIndices) / 2; flipud(combinedMeanPredictions(safeIndices) - combinedSpreadPredictions(safeIndices) / 2)], ...
        [0.8 0.8 1.0], 'EdgeColor', 'none', 'DisplayName', 'Spread'); % Spread

    plot(xFit(safeIndices), combinedMeanPredictions(safeIndices) + combinedSpreadPredictions(safeIndices) / 2, 'b--', 'LineWidth', 1.5, 'DisplayName', 'Upper Spread');
    plot(xFit(safeIndices), combinedMeanPredictions(safeIndices) - combinedSpreadPredictions(safeIndices) / 2, 'b--', 'LineWidth', 1.5, 'HandleVisibility','off');
    plot(xFit(safeIndices), combinedMeanPredictions(safeIndices), 'b-', 'LineWidth', 2, 'DisplayName', 'Mean Prediction');
    ylabel('Mean and Spread');
    xline(safeXMin, 'r--', 'DisplayName', 'Safety Boundary');
    xline(safeXMax, 'r--', 'HandleVisibility','off');

    % Plot the black box function values at seed points on top
    scatter(seedPoints, observations, 'filled', 'k', 'DisplayName', 'Seed Points');

    yyaxis right;
    plot(xFit(safeIndices), combinedStdPredictions(safeIndices), 'r-', 'LineWidth', 2, 'DisplayName', 'Std Deviation');
    ylabel('Standard Deviation');

    title('Ensemble Mean, Spread, and Std with Safe Restriction');
    xlabel('x');
    xlim([min(seedPoints) - 1, max(seedPoints) + 1]); % Focus on the region around known points
    legend('show', 'Location', 'Best');
    hold off;

    % Subplot 3: Real BBF and mean prediction with safe restriction
    subplot(2, 2, [3 4]);
    hold on;
    realBBF = blackBoxFunction(xFit);
    plot(xFit, realBBF, 'k-', 'LineWidth', 2, 'DisplayName', 'Real BBF');
    plot(xFit(safeIndices), combinedMeanPredictions(safeIndices), 'b-', 'LineWidth', 2, 'DisplayName', 'Mean Prediction');
    scatter(seedPoints, observations, 'filled', 'k', 'DisplayName', 'Seed Points');
    xline(safeXMin, 'r--', 'DisplayName', 'Safety Boundary');
    xline(safeXMax, 'r--', 'HandleVisibility','off');

    % Highlight the new exploration point if provided
    if ~isempty(newExplorationPoint)
        scatter(newExplorationPoint, blackBoxFunction(newExplorationPoint), 'filled', 'MarkerFaceColor', 'm', 'MarkerEdgeColor', 'm','DisplayName', 'New Point'); % Purple dot for new point
    end

    % Zoom in on the y-axis to focus on values within g

    ylim([min(observations) - Differences/2, max(observations) + Differences/2]);
    xlim([min(seedPoints) - 1, max(seedPoints) + 1]); % Focus on the region around known points

    title('Real BBF and Mean Prediction with Safe Restriction');
    xlabel('x');
    ylabel('y');
    legend('show', 'Location', 'Best');
    hold off;
end
