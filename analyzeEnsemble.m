%% Fit ensemble models and calculate combined predictions
function [ensembleModels, combinedMeanPredictions, combinedStdPredictions, combinedSpreadPredictions, safeIndices, safeXMin, safeXMax] = analyzeEnsemble(seedPoints, observations, minOrder, maxOrder, xFit, blackBoxFunction, g)
    % Fit ensemble models
    ensembleModels = cell(maxOrder - minOrder + 1, 1);
    for i = minOrder:maxOrder
        ensembleModels{i - minOrder + 1} = polyfit(seedPoints, observations, i); % Polynomial models of orders minOrder to maxOrder
    end
    
    % Initialize variables to store combined results
    combinedMeanPredictions = zeros(length(xFit), 1);
    combinedStdPredictions = zeros(length(xFit), 1);
    combinedSpreadPredictions = zeros(length(xFit), 1);
    combinationCount = 0;

    % Iterate over combinations of seed points
    for k = length(seedPoints)-1:length(seedPoints)
        combinations = nchoosek(seedPoints, k);
        for j = 1:size(combinations, 1)
            currentSeedPoints = combinations(j, :)';
            currentObservations = blackBoxFunction(currentSeedPoints);

            % Fit ensemble models for the current combination
            for i = minOrder:maxOrder
                ensembleModels{i - minOrder + 1} = polyfit(currentSeedPoints, currentObservations, i);
            end

            % Calculate predictions
            predictions = zeros(length(xFit), maxOrder - minOrder + 1);
            for i = minOrder:maxOrder
                predictions(:, i - minOrder + 1) = polyval(ensembleModels{i - minOrder + 1}, xFit);
            end

            meanPrediction = mean(predictions, 2);
            stdPrediction = std(predictions, 0, 2);
            spreadPrediction = max(predictions, [], 2) - min(predictions, [], 2);

            % Accumulate results
            combinedMeanPredictions = combinedMeanPredictions + meanPrediction;
            combinedStdPredictions = combinedStdPredictions + stdPrediction;
            combinedSpreadPredictions = combinedSpreadPredictions + spreadPrediction;
            combinationCount = combinationCount + 1;
        end
    end

    % Average the accumulated results
    combinedMeanPredictions = combinedMeanPredictions / combinationCount;
    combinedStdPredictions = combinedStdPredictions / combinationCount;
    combinedSpreadPredictions = combinedSpreadPredictions / combinationCount;

    % Constrain the values of the black box function to be within the safety bounds
    safeIndices = find(combinedMeanPredictions <= g);
    if isempty(safeIndices)
        % If no points are within the safety bounds, use the full range of xFit
        safeXMin = min(xFit);
        safeXMax = max(xFit);
    else
        % Otherwise, use the range of xFit where the predictions are within the safety bounds
        safeXMin = min(xFit(safeIndices));
        safeXMax = max(xFit(safeIndices));
    end
    
end
