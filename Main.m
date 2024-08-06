global seedPoints observations xFit blackBoxFunction g minOrder maxOrder localMax
global combinedMeanPredictions combinedStdPredictions combinedSpreadPredictions safeIndices safeXMin safeXMax safePredictions newExplorationPoint x_opt modelCoefficients ensembleModels

% Define the black box function
%blackBoxFunction = @(x) (x - 3).^4 - 10*(x - 3).^2 + 70*sin(x) + 5;
blackBoxFunction = @(T) (1 ./ (1 + exp(-0.1 * (T - 50)))) .* (0.8 - 0.2 * cos(0.1 * T)) + 0.1 * sin(0.3 * T);
% Set initial parameters
seedPoints = [0;100];
minOrder = 6;
maxOrder = 10;
g = 5;
a = 1; % Coefficient for mean
b = 100; % Initial coefficient for information (spread)
iterationCount = 1;
iterations = 20;
% Initialize table to log models and exploration points
logTable = table('Size', [0 3], 'VariableTypes', {'double', 'double', 'double'}, 'VariableNames', {'Iteration', 'ExplorationPoint', 'LocalMaximum'});

% Run the initial analysis and plot the results
% Generate observations and data for plotting
observations = blackBoxFunction(seedPoints);   
xFit = linspace(min(seedPoints)-10, max(seedPoints)+10, 500)';

% Fit ensemble models and calculate combined predictions
analyzeEnsemble(minOrder, maxOrder);
% Find the local maximum of the current predictions within the safety boundaries
safeXFit = xFit(xFit >= safeXMin & xFit <= safeXMax);
safePredictions = combinedMeanPredictions(xFit >= safeXMin & xFit <= safeXMax);
[~, localMaxIdx] = max(safePredictions);
localMax = safePredictions(localMaxIdx);
% Plot the results
plotResults;

% Find the next exploration point iteratively
for iteration = 1:iterations
    % Find the next exploration point
    findNextExplorationPoint(a, b, iterationCount);
    
    % Update seed points with the new exploration point
    seedPoints = [seedPoints; x_opt];
    
    % Run analysis and plot results with updated seed points
    runInitialAnalysis(x_opt);
    
    % Find the local maximum of the current predictions within the safety boundaries
    safeXFit = xFit(xFit >= safeXMin & xFit <= safeXMax);
    safePredictions = combinedMeanPredictions(xFit >= safeXMin & xFit <= safeXMax);
    [~, localMaxIdx] = max(safePredictions);
    localMax = safePredictions(localMaxIdx);
    
    % Log the iteration, exploration point, and local maximum
    logTable = [logTable; {iterationCount, x_opt, localMax}];
    
    % Update iteration count and weight for information
    iterationCount = iterationCount + 1;
end

% Display the log table
disp(logTable);

disp(['Final optimized exploration point: ', num2str(x_opt)]);

%% Main function to run initial analysis and plot the results
function runInitialAnalysis(newExplorationPoint)
    global seedPoints observations xFit blackBoxFunction minOrder maxOrder g
    global combinedMeanPredictions combinedStdPredictions combinedSpreadPredictions safeIndices safeXMin safeXMax ensembleModels

    % Generate observations and data for plotting
    observations = blackBoxFunction(seedPoints);   
    xFit = linspace(min(seedPoints)-2, max(seedPoints)+2, 200)';
    
    % Fit ensemble models and calculate combined predictions
    analyzeEnsemble(minOrder, maxOrder);
    
    % Plot the results
    plotResults;
end
