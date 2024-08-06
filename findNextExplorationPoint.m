function findNextExplorationPoint(a, b, iterationCount)
    global seedPoints blackBoxFunction minOrder maxOrder g
    global x_opt modelCoefficients combinedMeanPredictions newExplorationPoint safeXMin safeXMax

    % Adjust the weight for information based on the iteration count
    adjusted_b = b * (0.85 ^ (iterationCount - 1));

    % Define the objective function for fmincon
    objectiveFunction = @(x) objective_ensemble(x, seedPoints, blackBoxFunction, minOrder, maxOrder, a, adjusted_b);

    % Options for fmincon
    options = optimoptions('fmincon','Display','iter');

    % Initial guess for x
    x0 = mean(seedPoints); % Initial guess can be the mean of known x values

    % Set bounds for optimization
    if iterationCount == 1
        lb = min(seedPoints);
        ub = max(seedPoints);
    else
        lb = safeXMin;
        ub = safeXMax;
    end

    % Optimization with constraints to ensure x_opt is within safe boundaries
    x_opt = fmincon(objectiveFunction, x0, [], [], [], [], lb, ub, [], options);
    
    % Update newExplorationPoint
    newExplorationPoint = x_opt;

    % Log the model coefficients
    observations = blackBoxFunction(seedPoints);
    modelCoefficients = cell(maxOrder - minOrder + 1, 1);
    for i = minOrder:maxOrder
        modelCoefficients{i - minOrder + 1} = polyfit(seedPoints, observations, i);
    end
    
    % Calculate combined mean predictions for logging
    xFit = linspace(min(seedPoints)-10, max(seedPoints)+10, 100)';
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
