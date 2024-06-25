function [radius, amount, threshold] = get_sharpening_parameters()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Sharpening parameters for preprocessing prompt using sliders with Apply button
%
% author:  Alejandro Salgado
% date:    06.13.2024
% version: 1.0
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Initialize outputs to empty indicating no valid input if window is closed
    radius = [];
    amount = [];
    threshold = [];

    % Create the figure for the UI
    fig = uifigure('Name', 'Set Sharpening Parameters', 'Position', [100 100 400 300], 'CloseRequestFcn', @(src, evt) onClose());

    % Create sliders
    % Slider for Radius
    lblRadius = uilabel(fig, 'Position', [50 250 300 20], 'Text', 'Radius [1,5]:');
    sldRadius = uislider(fig, 'Position', [50 230 300 3], 'Limits', [1 5], 'Value', 1);

    % Slider for Amount
    lblAmount = uilabel(fig, 'Position', [50 180 300 20], 'Text', 'Amount [0,2]:');
    sldAmount = uislider(fig, 'Position', [50 160 300 3], 'Limits', [0 2], 'Value', 0);

    % Slider for Threshold
    lblThreshold = uilabel(fig, 'Position', [50 110 300 20], 'Text', 'Threshold [0,1]:');
    sldThreshold = uislider(fig, 'Position', [50 90 300 3], 'Limits', [0 1], 'Value', 0);

    % Create Apply Button
    btnApply = uibutton(fig, 'push', 'Position', [150 30 100 22], 'Text', 'Apply', ...
                        'ButtonPushedFcn', @(btn,event) onApply());

    % Function to handle Apply button click
    function onApply()
        % Retrieve values from sliders
        radius = sldRadius.Value;
        amount = sldAmount.Value;
        threshold = sldThreshold.Value;

        % Resume execution and close the window
        uiresume(fig);
        delete(fig);
    end

    % Function to handle window close without Apply
    function onClose()
        % Output a message or handle the logic for no input
        disp('Window closed without applying changes.');
        delete(fig);
    end

    % Pause the UI and wait for the user to press Apply or close the window
    uiwait(fig);
end
