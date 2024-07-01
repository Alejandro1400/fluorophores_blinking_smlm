function image_reconstruction_gui(folder)
    % Image Reconstruction GUI for STORM
    % This function creates a graphical user interface for managing image reconstruction
    % and analysis tasks related to STORM imaging techniques.

    % Create the main figure for the GUI
    fig = uifigure('Name', 'STORM Image Reconstruction', ...
                   'Position', [100 100 600 500], 'Resize', 'off');
    
    % Title label
    titleLabel = uilabel(fig, ...
                         'Text', 'STORM Image Reconstruction', ...
                         'Position', [150, 450, 300, 30], ...
                         'FontSize', 14, ...
                         'FontWeight', 'bold', ...
                         'HorizontalAlignment', 'center');

    % Panel for Image Reconstruction Display
    imagePanel = uipanel(fig, ...
                         'Title', 'Image Reconstruction', ...
                         'Position', [10, 70, 380, 360], ... % Expanded downwards
                         'BackgroundColor', 'white');
    
    % Image Axes for displaying the first frame
    axImage = uiaxes(imagePanel, ...
                     'Position', [20, 30, 360, 250], ... % Adjusted to fill the panel
                     'Visible', 'on'); % Set to 'on' to see changes immediately
    
    % Panel for Parameter Selection
    paramPanel = uipanel(fig, ...
                         'Title', 'Parameter Selection', ...
                         'Position', [400, 70, 180, 360], ... % Expanded downwards
                         'BackgroundColor', 'white');

    % Labels and Edit Fields for 'Range of Intensity'
    intensityMinLabel = uilabel(paramPanel, ...
                                'Text', 'Min Intensity:', ...
                                'Position', [10, 280, 80, 22], ...
                                'Visible', 'off');
    intensityMinField = uieditfield(paramPanel, 'numeric', ...
                                    'Position', [100, 280, 70, 22], ...
                                    'Value', 0, ...
                                    'Visible', 'off');
    intensityMaxLabel = uilabel(paramPanel, ...
                                'Text', 'Max Intensity:', ...
                                'Position', [10, 250, 80, 22], ...
                                'Visible', 'off');
    intensityMaxField = uieditfield(paramPanel, 'numeric', ...
                                    'Position', [100, 250, 70, 22], ...
                                    'Value', 100, ...
                                    'Visible', 'off');

    % Start button in Parameter Panel
    startButton = uibutton(paramPanel, ...
                           'Text', 'Start', ...
                           'Position', [40, 30, 100, 22], ...
                           'ButtonPushedFcn', @(btn, event) startAnalysis(), ...
                           'Visible', 'off');

    % Lower Toolbar Panel
    toolbarPanel = uipanel(fig, ...
                           'Position', [10, 10, 580, 50], ...
                           'BorderType', 'none');

    % Load Files Button
    loadButton = uibutton(toolbarPanel, ...
                          'Text', 'Load Files', ...
                          'Position', [10, 15, 180, 20], ...
                          'ButtonPushedFcn', @(btn, event) loadFiles());

    % Menu Button
    menuButton = uibutton(toolbarPanel, ...
                          'Text', 'Menu', ...
                          'Position', [200, 15, 180, 20], ...
                          'ButtonPushedFcn', @(btn,event) menu(), ...
                          'Visible', 'off');

    % Save Button
    saveButton = uibutton(toolbarPanel, ...
                          'Text', 'Save', ...
                          'Position', [390, 15, 180, 20], ...
                          'ButtonPushedFcn', @(btn,event) save(), ...
                          'Visible', 'off');

    % Definition of global variables
    loadedImages = [];
    imageAdjustments = struct('minVal', [], 'maxVal', []);

    % Define the loadFiles function
    function loadFiles()
        % Specify the directory where the processed images and adjustments are stored
        processingDir = fullfile(folder, 'output_data');
    
        % Prompt the user to select a directory for the processed output
        filesDir = uigetdir(processingDir, 'Select the Folder Containing Processed Output');
        if filesDir == 0
            disp('User canceled the selection.');
            return;
        end

        % Attempt to find the TIFF files
        tiffFiles = dir(fullfile(filesDir, '*.tif'));
        if isempty(tiffFiles)  % Check for both .tif and .TIFF if needed
            tiffFiles = dir(fullfile(filesDir, '*.TIFF'));
        end
    
        % Attempt to find the MAT files
        matFiles = dir(fullfile(filesDir, '*.mat'));
    
        if isempty(tiffFiles) || isempty(matFiles)
            disp('No appropriate files found in the directory.');
            return;
        end
    
        % Load the TIFF file
        tiffFileName = fullfile(filesDir, tiffFiles(1).name);
        info = imfinfo(tiffFileName);
        numFrames = numel(info);
        loadedImages = cell(numFrames, 1);
    
        % Create and show the progress bar
        progressBar = uiprogressdlg(fig, 'Title', 'Loading TIFF Image', 'Message', 'Loading...', 'Indeterminate', 'off', 'Value', 0);
    
        for k = 1:1
            loadedImages{k} = imread(tiffFileName, k, 'Info', info);
            progressBar.Value = k / numFrames;
        end

        % Close the progress bar
        close(progressBar);

        % Load the adjustments MAT file
        adjustmentsFileName = fullfile(filesDir, matFiles(1).name);
        adjustmentsData = load(adjustmentsFileName);
        imageAdjustments = adjustmentsData.imageAdjustments;

        % Update the edit fields with loaded values
        intensityMinField.Value = imageAdjustments.minVal;
        intensityMaxField.Value = imageAdjustments.maxVal;
        intensityMinField.Visible = 'on';
        intensityMaxLabel.Visible = 'on';
        intensityMaxField.Visible = 'on';
        intensityMinLabel.Visible = 'on';

        % Display the first frame without axes
        imshow(loadedImages{1}, 'Parent', axImage, 'Border', 'tight');
        axImage.Visible = 'on';
        axImage.XTick = [];
        axImage.YTick = [];
        axImage.XColor = 'none';
        axImage.YColor = 'none';
    
        % Update the GUI components
        imagePanel.Visible = 'on';
        paramPanel.Visible = 'on';
        startButton.Visible = 'on';
    end

    function startAnalysis()
        disp('Start analysis process.');
    end

    function menuCallback()
        disp('Menu button clicked.');
    end

    function saveCallback()
        disp('Save button clicked.');
    end
end
