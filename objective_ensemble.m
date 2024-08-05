function g = objective_ensemble(x, seedPoints, blackBoxFunction, minOrder, maxOrder, a, b)
    observations = blackBoxFunction(seedPoints);
    n_range = minOrder:maxOrder; % Polynomial orders to consider

    y_pred = zeros(length(n_range), 1);
    spread = zeros(length(n_range), 1);
    
    % Fit polynomial models and calculate predictions
    for i = 1:length(n_range)
        n = n_range(i);
        p = polyfit(seedPoints, observations, n); % Fit polynomial of order n
        y_pred(i) = polyval(p, x);
    end

    Y = mean(y_pred); % Mean prediction
    I = max(y_pred) - min(y_pred); % Spread (deviation)
    
    g = -(a * Y + b * I); % Objective to maximize (minimize negative)
end
