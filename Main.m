% Define the black box function
blackBoxFunction = @(x) (x - 3).^4 - 10*(x - 3).^2 + 7*sin(x) + 5;



% Set initial parameters
seedPoints = [0; 7];
minOrder = 4;
maxOrder = 7;
g = 10;
a = 1; % Coefficient for mean
b = 3; % Initial coefficient for information (spread)
iterationCount = 1;

% Initialize table to log models and exploration points
logTable = table('Size', [0 3], 'VariableTypes', {'double', 'double', 'double'}, 'VariableNames', {'Iteration', 'ExplorationPoint', 'ExplorationY'});

% Run the initial analysis and plot the results
runInitialAnalysis(seedPoints, blackBoxFunction, minOrder, maxOrder, g, []);

% Find the next exploration point iteratively
for iteration = 1:7
    % Find the next exploration point
    [x_opt, modelCoefficients] = findNextExplorationPoint(seedPoints, blackBoxFunction, minOrder, maxOrder, a, b, g, iterationCount);
    
    % Update seed points with the new exploration point
    seedPoints = [seedPoints; x_opt];
    
    % Run analysis and plot results with updated seed points
    runInitialAnalysis(seedPoints, blackBoxFunction, minOrder, maxOrder, g, x_opt);
    
    % Log the iteration, exploration point, and model coefficients
    logTable = [logTable; {iterationCount, x_opt, blackBoxFunction(x_opt)}];
    
    % Update iteration count and weight for information
    iterationCount = iterationCount + 1;
end

% Display the log table
disp(logTable);

disp(['Final optimized exploration point: ', num2str(x_opt)]);

%% Main function to run initial analysis and plot the results
function runInitialAnalysis(seedPoints, blackBoxFunction, minOrder, maxOrder, g, newExplorationPoint)
    % Generate observations and data for plotting
    observations = blackBoxFunction(seedPoints);   
    xFit = linspace(min(seedPoints)-2, max(seedPoints)+2, 100)';
    
    % Fit ensemble models and calculate combined predictions
    [ensembleModels, combinedMeanPredictions, combinedStdPredictions, combinedSpreadPredictions, safeIndices, safeXMin, safeXMax] = analyzeEnsemble(seedPoints, observations, minOrder, maxOrder, xFit, blackBoxFunction, g);
    
    % Plot the results
    plotResults(seedPoints, observations, ensembleModels, xFit, combinedMeanPredictions, combinedStdPredictions, combinedSpreadPredictions, safeIndices, safeXMin, safeXMax, g, blackBoxFunction, newExplorationPoint);
end
