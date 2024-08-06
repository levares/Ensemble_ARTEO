function g = objective_ensemble(x, seedPoints, blackBoxFunction, minOrder, maxOrder, a, b)

    global combinedMeanPredictions combinedSpreadPredictions safeIndices xFit Y I

% Interpolate the mean and spread predictions at point x
    Y = interp1(xFit, combinedMeanPredictions, x); % Mean prediction
    I = interp1(xFit, combinedSpreadPredictions, x); % Spread (deviation)
    g = -(a * Y + b * I); % Objective to maximize (minimize negative)
end
