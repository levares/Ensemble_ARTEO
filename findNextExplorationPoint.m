function [x_opt, modelCoefficients, combinedMeanPredictions] = findNextExplorationPoint(seedPoints, blackBoxFunction, minOrder, maxOrder, a, b, g, iterationCount)
    % Adjust the weight for information based on the iteration count
    adjusted_b = b * (0.9 ^ (iterationCount - 1));

    % Define the objective function for fmincon
    objectiveFunction = @(x) objective_ensemble(x, seedPoints, blackBoxFunction, minOrder, maxOrder, a, adjusted_b);

    % Options for fmincon
    options = optimoptions('fmincon','Display','iter');

    % Initial guess for x
    x0 = mean(seedPoints); % Initial guess can be the mean of known x values

    % Optimization
    x_opt = fmincon(objectiveFunction, x0, [], [], [], [], min(seedPoints), max(seedPoints), [], options);
    
    % Log the model coefficients
    observations = blackBoxFunction(seedPoints);
    modelCoefficients = cell(maxOrder - minOrder + 1, 1);
    for i = minOrder:maxOrder
        modelCoefficients{i - minOrder + 1} = polyfit(seedPoints, observations, i);
    end
    
    % Calculate combined mean predictions for logging
    xFit = linspace(min(seedPoints)-2, max(seedPoints)+2, 100)';
    combinedMeanPredictions = calculateMeanPredictions(modelCoefficients, xFit, minOrder);
end

function combinedMeanPredictions = calculateMeanPredictions(modelCoefficients, xFit, minOrder)
    numModels = length(modelCoefficients);
    predictions = zeros(length(xFit), numModels);
    for i = 1:numModels
        predictions(:, i) = polyval(modelCoefficients{i}, xFit);
    end
    combinedMeanPredictions = mean(predictions, 2);
end
