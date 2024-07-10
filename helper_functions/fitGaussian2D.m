function [muX, muY] = fitGaussian2D(localArea, centralX, centralY)

    [rows, cols] = size(localArea);
    [X, Y] = meshgrid(1:cols, 1:rows);  % Create coordinate grids
    
    % Flatten the matrices for fitting
    xData = X(:);
    yData = Y(:);
    zData = double(localArea(:));

    % Set amplitude to the intensity at the central point
    A = double(localArea(centralX, centralY));  % Amplitude guess

    % Initial guesses for Gaussian parameters
    initialGuess = [A, centralX, centralY, 0, 0];  % [A, muX, muY, sigmaX, sigmaY]

    % Lower and upper bounds (assuming the center can't be outside the local area)
    lb = [0, 1, 1, 0.1, 0.1];  % Lower bounds to ensure positive values
    ub = [Inf, cols, rows, cols/2, rows/2];  % Upper bounds limit the sigma to the area size

    % Gaussian model function
    gaussianModel = @(p, x, y) p(1) * exp(-((x - p(2)).^2 / (2 * p(4)^2) + (y - p(3)).^2 / (2 * p(5)^2)));

    % Objective function
    objectiveFunc = @(p) gaussianModel(p, xData, yData) - zData;

    % Optimization settings
    options = optimoptions('lsqnonlin', 'Display', 'off', 'Algorithm', 'trust-region-reflective');
    params = lsqnonlin(objectiveFunc, initialGuess, lb, ub, options);

    % Extract the fitted parameters
    muY = params(2);
    muX = params(3);
    
end

