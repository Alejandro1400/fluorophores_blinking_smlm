function [radius, amount, threshold] = get_sharpening_parameters()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Sharpening parameters for preprocessing prompt 

% author:  Alejandro Salgado
% date:    06.13.2024
% version: 1.0

%  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    disp('    When selecting the parameters use a double format X.X, also on each parameter is shown the expected range to use')
    % Default values
    defaultRadius = 1;
    defaultAmount = 0;
    defaultThreshold = 0;

    % User input dialog
    prompt = {'Enter Radius [1,5] (standard deviation of Gaussian filter):', ...
              'Enter Amount [0,2] (strength of sharpening effect):', ...
              'Enter Threshold [0,1] (minimum contrast for an edge):'};
    dlgtitle = 'Input for Sharpening Parameters, use doubles (X.X)';
    dims = [1 35];
    definput = {num2str(defaultRadius), num2str(defaultAmount), num2str(defaultThreshold)};
    sharpenParams = inputdlg(prompt, dlgtitle, dims, definput);

    % Validate user input
    if isempty(sharpenParams)
        disp('User canceled the input. Using default sharpening parameters.');
        radius = defaultRadius;
        amount = defaultAmount;
        threshold = defaultThreshold;
        return;
    end

    % Convert input to doubles and validate
    radius = str2double(sharpenParams{1});
    amount = str2double(sharpenParams{2});
    threshold = str2double(sharpenParams{3});

    if isnan(radius)
        disp('Invalid input for Radius. Using default value.');
        radius = defaultRadius;
    end

    if isnan(amount)
        disp('Invalid input for Amount. Using default value.');
        amount = defaultAmount;
    end

    if isnan(threshold)
        disp('Invalid input for Threshold. Using default value.');
        threshold = defaultThreshold;
    end
end
