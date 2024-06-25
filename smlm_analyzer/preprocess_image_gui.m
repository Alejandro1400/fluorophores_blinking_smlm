function preprocess_image_gui(folder)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Image Preprocessing GUI for STORM
%
% This function creates a graphical user interface(GUI) for image 
% preprocessing tasks including loading TIFF files, adjusting contrast, 
% applying sharpness, resetting changes, applying changes across frames, 
% saving processed files, and displaying processed frames as a video.
%
% author:  Alejandro Salgado
% date:    06.13.2024
% version: 1.0
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Create a figure for the GUI
    fig = uifigure('Name', 'Image Preprocessing for STORM', 'Position', [100 100 600 500]);

    % Add title
    lblTitle = uilabel(fig, 'Position', [200 470 200 22], 'Text', 'Image Preprocessing', 'FontSize', 16, 'FontWeight', 'bold');

    % Add UI components
    lbl = uilabel(fig, 'Position', [10 450 400 22], 'Text', 'Load a TIFF file for preprocessing:');
    btnLoad = uibutton(fig, 'push', 'Position', [420 450 100 22], 'Text', 'Load Image', 'ButtonPushedFcn', @(btn,event) loadImage());

    ax = uiaxes(fig, 'Position', [10 150 580 280]);
    imshow([], 'Parent', ax);
    hold(ax, 'on');

    % Calculate button positions
    spacing = 20; % Spacing between buttons
    buttonWidth = 100;
    buttonHeight = 22;
    startX = (600 - 3 * buttonWidth - 2 * spacing) / 2; % Center align the button group
    startY = 40; % Lower button positioning

    % First Column: Adjust Contrast, Apply Sharpness
    btnContrast = uibutton(fig, 'push', 'Position', [startX, startY + buttonHeight + spacing, buttonWidth, buttonHeight], 'Text', 'Adjust Contrast', 'Visible', 'off','ButtonPushedFcn', @(btn, event) adjustContrast());
    btnSharpness = uibutton(fig, 'push', 'Position', [startX, startY, buttonWidth, buttonHeight], 'Text', 'Apply Sharpness', 'Visible', 'off','ButtonPushedFcn', @(btn, event) adjustSharpness());

    % Second Column: Apply Changes, Reset
    btnApply = uibutton(fig, 'push', 'Position', [startX + buttonWidth + spacing, startY, buttonWidth, buttonHeight], 'Text', 'Apply Changes', 'Visible', 'off','ButtonPushedFcn', @(btn, event) applyChanges());
    btnReset = uibutton(fig, 'push', 'Position', [startX + buttonWidth + spacing, startY + buttonHeight + spacing, buttonWidth, buttonHeight], 'Text', 'Reset', 'Visible', 'off','ButtonPushedFcn', @(btn, event) resetImage());

    % Third Column: Show Video, Save File
    btnShow = uibutton(fig, 'push', 'Position', [startX + 2 * (buttonWidth + spacing), startY + buttonHeight + spacing, buttonWidth, buttonHeight], 'Text', 'Show Video', 'Visible', 'off','ButtonPushedFcn', @(btn, event) showVideo());
    btnSave = uibutton(fig, 'push', 'Position', [startX + 2 * (buttonWidth + spacing), startY, buttonWidth, buttonHeight], 'Text', 'Save File', 'Visible', 'off','ButtonPushedFcn', @(btn, event) saveFile());

    % Variables to store the image and adjustments
    originalImage = [];
    adjustedImage = [];
    finalImage = [];
    info = [];
    numFrames = 0;

    %Variables for files and folders
    fileName = "";
    filePath = "";
    savedImage = false;
    

    % Initialize the image and adjustment storage
    imageAdjustments = struct('minVal', [], 'maxVal', [], 'radius', [], 'amount', [], 'threshold', []);


    function loadImage()
        % Specify the directory where the images are stored
        imageDir = fullfile(folder, 'input_data');

        % Prompt the user to select a TIFF file for preprocessing
        [fileName, filePath] = uigetfile({'*.tif;*.tiff', 'TIFF files (*.tif, *.tiff)'}, 'Select TIFF Image for Preprocessing', imageDir, 'MultiSelect', 'off');
        
        if isequal(fileName, 0) || isequal(filePath, 0)
            disp('User canceled file selection.');
            return;
        end

        fullFilePath = fullfile(filePath, fileName);
        info = imfinfo(fullFilePath);
        numFrames = numel(info);
        originalImage = cell(numFrames, 1);

        % Create and show the progress bar
        progressBar = uiprogressdlg(fig, 'Title', 'Loading Image', 'Message', 'Loading...', 'Indeterminate', 'off', 'Value', 0);

        for k = 1:numFrames
            originalImage{k} = imread(fullFilePath, k, 'Info', info);
            progressBar.Value = k / numFrames;
        end

        % Close the progress bar
        close(progressBar);

        imshow(originalImage{1}, 'Parent', ax);
        title(ax, 'Original Image');

        % Make sliders and buttons visible after loading the image
        btnContrast.Visible = 'on';
        btnSharpness.Visible = 'on';
        btnApply.Visible = 'on';
        btnSave.Visible = 'on';
        btnShow.Visible = 'on';
        btnReset.Visible = 'on';
    end


    function adjustContrast()
        % Ensure there is an image loaded
        if isempty(originalImage)
            uialert(fig, 'Load an image first', 'Image Not Loaded');
            return;
        end
    
        % Ensure the adjustedImage is initialized
        if isempty(adjustedImage)
            adjustedImage = originalImage;  % Initialize with original if nothing adjusted yet
        else
            uialert(fig, 'The contrast was already adjusted', 'Error');
            return;
        end
    
        % Display the image on the GUI axes
        hIm = imshow(adjustedImage{1}, 'Parent', ax);  % Assume adjustedImage is now directly accessible
        title(ax, 'Edit Image Contrast');  % Set title for editing mode
    
        % Use imcontrast to adjust contrast interactively on the displayed image
        hContrast = imcontrast(hIm);
    
        % Find the UI controls for window minimum and maximum
        minEditBox = findobj(hContrast, 'Tag', 'window min edit');
        maxEditBox = findobj(hContrast, 'Tag', 'window max edit');
        applyButton = findobj(hContrast, 'String', 'Adjust Data');  % Locate the Adjust Data button
    
        % Initialize a function to save values when Adjust Data is pressed
        function saveValues(source, event)
            imageAdjustments.minVal = str2double(minEditBox.String);  % Convert string to double
            imageAdjustments.maxVal = str2double(maxEditBox.String);
        end
    
        % Add listeners to these controls
        addlistener(minEditBox, 'String', 'PostSet', @(s, e) []);
        addlistener(maxEditBox, 'String', 'PostSet', @(s, e) []);
        addlistener(applyButton, 'Action', @saveValues);  % Listen to button press for saving values and closing window
    
        % Wait for the contrast adjustment window to be closed by the user
        waitfor(hContrast);
    
        % Check if hContrast is still valid before trying to get the image data
        if isvalid(hIm)
            % Get the contrast adjusted image data
            contrastAdjustedImage = getimage(hIm);
        
            % Update the adjustedImage with new data
            adjustedImage{1} = contrastAdjustedImage;
        
            % Redisplay the updated image
            imshow(adjustedImage{1}, 'Parent', ax);
            title(ax, 'Adjusted Contrast');  % Update title to indicate the adjustment
        end
    end



    function adjustSharpness()
        if isempty(adjustedImage)
            uialert(fig, 'The contrast needs to be changed first.', 'Adjustment Required');
            return;
        end
    
        % Get sharpening parameters from the user
        % Save sharpening values globally
        [imageAdjustments.radius, imageAdjustments.amount, imageAdjustments.threshold] = get_sharpening_parameters();
    
        % Apply sharpening to the adjusted image
        adjustedImage{1} = imsharpen(adjustedImage{1}, 'Radius', imageAdjustments.radius, 'Amount', imageAdjustments.amount, 'Threshold', imageAdjustments.threshold);
    
        % Redisplay the sharpened image
        imshow(adjustedImage{1}, 'Parent', ax);
        title(ax, 'Adjusted Sharpness');  % Update the title to indicate sharpness has been adjusted
    end


    function resetImage()
        % Check if there is an original image to reset to
        if isempty(originalImage)
            uialert(fig, 'No original image to reset to.', 'Error');
            return;
        end
    
        % Reset adjustedImage and finalImage 
        adjustedImage = [];
        finalImage = [];
    
        % Display the original image on the GUI axes
        imshow(originalImage{1}, 'Parent', ax);
        title(ax, 'Original Image');  % Update the title to indicate it's the original image

        %Allow for new savings as there are going to be changed adjustments
        savedImage = false;
    
    end


    function applyChanges()
        % Check if adjustedImage is already set
        if isempty(adjustedImage)
            uialert(fig, 'First apply changes to the image.', 'Warning');
            return;
        end

        % Check if finalImage is already set
        if ~isempty(finalImage)
            uialert(fig, 'Changes have already been applied.', 'Warning');
            return;
        end

        numFrames = numel(originalImage);  % Assuming adjustedImage is a cell array of frames
    
        % Create and show the progress bar
        progressBar = uiprogressdlg(fig, 'Title', 'Applying Changes','Message', 'Applying changes to frames...','Indeterminate', 'off', 'Value', 0);
    
        % Check settings for applying contrast and sharpness
        applyContrast = ~isempty(imageAdjustments.minVal) && ~isempty(imageAdjustments.maxVal);
        applySharpness = ~isempty(imageAdjustments.radius) && ~isempty(imageAdjustments.amount) && ~isempty(imageAdjustments.threshold);
    
        % Apply contrast and sharpness settings from the first frame to all frames
        for k = 1:numFrames
            frame = double(originalImage{k}); % Convert current frame to double for processing

            % Clip and scale the frame
            clippedFrame = max(min(frame, imageAdjustments.maxVal), imageAdjustments.minVal); % Clip values outside [minVal, maxVal]
            % Scale the clipped values to [0, 65535]
            if (imageAdjustments.maxVal - imageAdjustments.minVal) == 0 % Check for divide by zero scenario
                adjustedFrame = zeros(size(frame), 'uint16');
            else
                adjustedFrame = uint16(65535 * (clippedFrame - imageAdjustments.minVal) / (imageAdjustments.maxVal - imageAdjustments.minVal));
            end
    
            if applySharpness
                % Sharpen the adjusted frame using the stored parameters
                adjustedFrame = imsharpen(adjustedFrame, 'Radius', imageAdjustments.radius, 'Amount', imageAdjustments.amount, 'Threshold', imageAdjustments.threshold);
            end
    
            % Store the sharpened/adjusted frame back in the cell array
            finalImage{k} = adjustedFrame;
    
            % Update the progress bar
            progressBar.Value = k / numFrames;

        end
    
        % Close the progress bar
        close(progressBar);

        % Pop up message indicating completion
        uialert(fig, 'Changes have been successfully applied.', 'Completed');
    end


    function saveFile()
        % If this settings have already been saved then it cant be saved
        % again
        if savedImage 
            uialert(fig, 'This image adjustments have already been saved.', 'Error');
            return;
        end
        % Check if finalImage is already set
        if isempty(finalImage)
            uialert(fig, 'The changes need to be applied to all images first.', 'Error');
            return;
        end

        numFrames = numel(finalImage);  % Get the number of frames
    
        % Call function to create output directory and filename for the processed image
        [outputDir, fileNameOutput] = create_output_directory(folder, fileName);
    
        % Define the output file path
        tiffFileName = fullfile(outputDir, ['adjusted_', fileNameOutput, '.tif']);
    
        % Create and show the progress bar
        progressBar = uiprogressdlg(fig, 'Title', 'Saving Adjusted TIFF', 'Message', 'Saving adjusted frames to TIFF...', 'Indeterminate', 'off', 'Value', 0);
    
        % Write adjusted frames to the TIFF file
        for k = 1:numFrames
            if k == 1
                imwrite(finalImage{k}, tiffFileName, 'WriteMode', 'overwrite', 'Compression', 'none');
            else
                imwrite(finalImage{k}, tiffFileName, 'WriteMode', 'append', 'Compression', 'none');
            end
    
            % Update the progress bar
            progressBar.Value = k / numFrames;
        end
    
        % Close the progress bar
        close(progressBar);

        %Make sure the image is saved and then not saved again
        savedImage = true;

        % Construct the completion message with the file name
        completionMessage = sprintf('File with changes has been successfully saved: %s', tiffFileName);
    
        % Pop up message indicating the file save completion
        uialert(fig, completionMessage, 'Save Completed');

    end


    function showVideo()
        % Check if finalImage is already set
        if isempty(finalImage)
            uialert(fig, 'The changes need to be applied to all images first.', 'Error');
            return;
        end
    
        numFrames = numel(finalImage);  % Determine the number of frames
    
        % Create a figure to display the frames
        hFig = figure('Name', 'Processed Frames Video', 'NumberTitle', 'off', 'CloseRequestFcn', @stopVideo);
    
        % Add a 'Stop' button to the figure
        stopBtn = uicontrol('Style', 'pushbutton', 'String', 'Stop', ...
                            'Position', [20 20 60 20], 'Callback', @stopVideo);
    
        % Initialize a flag to control the display loop
        isRunning = true;
    
        % Display the frames one by one in a loop
        for k = 1:numFrames
            if ~isRunning  % Check if the stop button has been pressed
                break;
            end
    
            if ~isvalid(hFig)  % Check if the figure is still open
                disp('    Figure window has been closed. Stopping display.');
                break;  % Exit the loop if the figure has been closed
            end
    
            imshow(finalImage{k}, 'Parent', gca);
            title(gca, sprintf('Frame %d', k));
            drawnow;
    
            pause(0.1);  % Pause for a short duration to simulate video playback
        end
    
        function stopVideo(~, ~)
            isRunning = false;  % Set the flag to false to stop the loop
            delete(hFig);  % Optionally close the figure
        end
    end

end

