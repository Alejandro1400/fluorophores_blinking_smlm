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
                         'BackgroundColor', 'white', ...
                         'Visible', 'off');
    
    % Image Axes for displaying the first frame
    axImage = uiaxes(imagePanel, ...
                     'Position', [10, 30, 360, 250], ... % Adjusted to fill the panel
                     'Visible', 'off'); % Set to 'on' to see changes immediately
    
    % Panel for Parameter Selection
    paramPanel = uipanel(fig, ...
                         'Title', 'Parameter Selection', ...
                         'Position', [400, 70, 180, 360], ... % Expanded downwards
                         'BackgroundColor', 'white', ...
                         'Visible', 'off');

    % Labels and Fields for 'Range of Intensity'
    intensityMinLabel = uilabel(paramPanel, ...
                                'Text', 'Min Intensity:', ...
                                'Position', [10, 300, 80, 22], ...
                                'Visible', 'off');
    intensityMinValue = uilabel(paramPanel, ...
                                'Text', 'NA', ...
                                'Position', [100, 300, 70, 22], ...
                                'BackgroundColor', 'black', ...
                                'FontColor', 'white', ...
                                'HorizontalAlignment', 'center', ...
                                'Visible', 'off');
    intensityMaxLabel = uilabel(paramPanel, ...
                                'Text', 'Max Intensity:', ...
                                'Position', [10, 270, 80, 22], ...
                                'Visible', 'off');
    intensityMaxValue = uilabel(paramPanel, ...
                                'Text', 'NA', ...
                                'Position', [100, 270, 70, 22], ...
                                'BackgroundColor', 'black', ...
                                'FontColor', 'white', ...
                                'HorizontalAlignment', 'center',...
                                'Visible', 'off');

    % Detection Threshold
    thresholdLabel = uilabel(paramPanel, ...
                             'Text', 'Det. Threshold:', ...
                             'Position', [10, 220, 150, 22], ...
                             'Visible', 'off');
    thresholdField = uieditfield(paramPanel, 'numeric', ...
                                 'Position', [100, 220, 70, 22], ...
                                 'AllowEmpty','on', 'Visible', 'off');

    % Pixel Resolution
    pixelResolutionLabel = uilabel(paramPanel, ...
                                   'Text', 'Pixel Res. (nm):', ...
                                   'Position', [10, 190, 160, 22], ...
                                   'Visible', 'off');
    pixelResolutionField = uieditfield(paramPanel, 'numeric', ...
                                       'Position', [100, 190, 70, 22], ...
                                       'Value', 100, ...
                                       'Visible', 'off');

    % Diffraction Limit
    diffractLimitLabel = uilabel(paramPanel, ...
                                 'Text', 'Diff. Limit (nm):', ...
                                 'Position', [10, 160, 160, 22], ...
                                 'Visible', 'off'); 
    diffractLimitField = uieditfield(paramPanel, 'numeric', ...
                                     'Position', [100, 160, 70, 22], ...
                                     'Value', 200, ...
                                     'Visible', 'off'); 

    % Test Parameters Button
    testButton = uibutton(paramPanel, ...
                          'Text', 'Test Parameters', ...
                          'Position', [40, 60, 100, 22], ...
                          'ButtonPushedFcn', @(btn, event) testParameters(), ...
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
        intensityMinValue.Text = num2str(imageAdjustments.minVal);
        intensityMaxValue.Text = num2str(imageAdjustments.maxVal);
        thresholdField.Value = imageAdjustments.minVal;
        intensityMinValue.Visible = 'on';
        intensityMaxLabel.Visible = 'on';
        intensityMaxValue.Visible = 'on';
        intensityMinLabel.Visible = 'on';
        thresholdLabel.Visible = 'on';
        thresholdField.Visible = 'on';
        pixelResolutionField.Visible = 'on';
        pixelResolutionLabel.Visible = 'on';
        diffractLimitField.Visible = 'on';
        diffractLimitLabel.Visible = 'on';

        % Display the first frame without axes
        imshow(loadedImages{1}, 'Parent', axImage, 'InitialMagnification','fit');
        axImage.Visible = 'on';
        axImage.XTick = [];
        axImage.YTick = [];
        axImage.XColor = 'none';
        axImage.YColor = 'none';
    
        % Update the GUI components
        imagePanel.Visible = 'on';
        paramPanel.Visible = 'on';
        testButton.Visible = 'on';
        startButton.Visible = 'on';
    end

    function testParameters()
    
        % Load the first frame
        frame = loadedImages{1};
    
        % Retrieve threshold and pixel resolution values
        threshold = thresholdField.Value;
        pixelResolution = pixelResolutionField.Value;
        diffractLimit = diffractLimitField.Value;
    
        % Normalize the threshold
        if (imageAdjustments.maxVal - imageAdjustments.minVal) == 0
            normalizedThreshold = 0;
        else
            normalizedThreshold = 65535 * (threshold - imageAdjustments.minVal) / (imageAdjustments.maxVal - imageAdjustments.minVal);
        end
    
        % Determine search radius and minimal overlap detection distance
        minOverlapDistance = diffractLimit / pixelResolution;  % Minimum overlap distance
        searchRadius = minOverlapDistance + (diffractLimit / pixelResolution) - 1;
    
        % Initialize maps for detection and checked areas
        moleculeMap = false(size(frame));
        checkedMap = false(size(frame));
    
        [rows, cols] = size(frame);
        for i = 1:rows
            for j = 1:cols
                if frame(i, j) > normalizedThreshold && ~checkedMap(i, j)
                    % Define the search area boundaries around the point
                    top = max(1, i-searchRadius);
                    bottom = min(rows, i+searchRadius);
                    left = max(1, j-searchRadius);
                    right = min(cols, j+searchRadius);
                    localArea = frame(top:bottom, left:right);

                    % Calculate the number of rows and columns in localArea
                    localRows = size(localArea, 1);
                    localCols = size(localArea, 2);
        
                    % Calculate the coordinates of the central point in the localArea context
                    centralRow = i - top + 1;  % Adjust central row based on the top boundary
                    centralCol = j - left + 1;  % Adjust central col based on the left boundary

                    % Initialize minimum distances to a large value
                    minDistTop = inf;
                    minDistBottom = inf;
                    minDistLeft = inf;
                    minDistRight = inf;
                    
                    % Initialize variables to store the closest subRow and subCol values for each side that way understanding the boundaries used for that molecule
                    topCut = top;
                    bottomCut = bottom;
                    leftCut = left;
                    rightCut = right;
    
                    % Check for other high intensity points within the overlap criteria
                    [subRow, subCol] = find(localArea > normalizedThreshold);
                    distances = sqrt((subCol - centralCol).^2 + (subRow - centralCol).^2);
    
                    % Iterate over the high-intensity points
                    for k = 1:length(subRow)
                        if distances(k) >= minOverlapDistance
                            % Change the possible overlapping value to 0
                            localArea(subRow(k), subCol(k)) = 0;
                            % Calculate absolute changes in row and col from the central point
                            deltaRow = abs(subRow(k) - centralRow);
                            deltaCol = abs(subCol(k) - centralCol);
                    
                            % Determine the direction of change
                            changeDirectionRow = sign(subRow(k) - centralRow);  % 1 for down, -1 for up
                            changeDirectionCol = sign(subCol(k) - centralCol);  % 1 for right, -1 for left
                    
                            if deltaRow > deltaCol
                                % Change is greater in row direction
                                % Zero out only the directly connected pixels horizontally
                                if subCol(k) - 1 >= 1  % Check left neighbor
                                    localArea(subRow(k), subCol(k)-1) = 0;
                                end
                                if subCol(k) + 1 <= localCols  % Check right neighbor
                                    localArea(subRow(k), subCol(k) + 1) = 0;
                                end
                                % Eliminate all rows further in the direction of change
                                if changeDirectionRow > 0
                                    localArea(subRow(k)+1:end, :) = 0;  % Zero out all rows at bottom
                                    if deltaRow < minDistBottom
                                        minDistBottom = deltaRow;
                                        bottomCut = bottom - localRows + subRow(k) -1;
                                    end
                                else
                                    localArea(1:subRow(k)-1, :) = 0;  % Zero out all rows on top
                                    if deltaRow < minDistTop
                                        minDistTop = deltaRow;
                                        topCut = top + subRow(k) -1;
                                    end
                                end
                            elseif deltaCol > deltaRow
                                % Change is greater in y direction
                                % Zero out only the directly connected pixels vertically
                                if subRow(k) - 1 >= 1  % Check upper neighbor
                                    localArea(subRow(k)-1, subCol(k)) = 0;
                                end
                                if subRow(k) + 1 <= localRows  % Check lower neighbor
                                    localArea(subRow(k)+1, subCol(k)) = 0;
                                end
                                % Eliminate all cols further in the direction of change
                                if changeDirectionCol > 0
                                    localArea(:, subCol(k)+1:end) = 0;  % Zero out all cols on right
                                    if deltaCol < minDistRight
                                        minDistRight = deltaCol;
                                        rightCut = right - localCols + subCol(k) - 1;
                                    end
                                else
                                    localArea(:, 1:subCol(k)-1) = 0;  % Zero out all cols on left
                                    if deltaCol < minDistLeft
                                        minDistLeft = deltaCol;
                                        leftCut = left + subCol(k) -1;
                                    end
                                end
                            else
                                % Changes are equal, indicating a diagonal movement
                                % Zero out direct horizontal and vertical neighbors
                                if subRow(k) + changeDirectionRow >= 1 && subRow(k) + changeDirectionRow <= localRows
                                    localArea(subRow(k) + changeDirectionRow, subCol(k)) = 0;  % Vertical step in the direction of change
                                end
                                if subCol(k) + changeDirectionCol >= 1 && subCol(k) + changeDirectionCol <= localCols
                                    localArea(subRow(k), subCol(k) + changeDirectionCol) = 0;  % Horizontal step in the direction of change
                                end
                                % Zero out farther columns and rows in the diagonal direction
                                if changeDirectionRow > 0
                                    localArea(subRow(k)+1:end, :) = 0;  % Further lower rows
                                    if deltaRow < minDistBottom
                                        minDistBottom = deltaRow;
                                        bottomCut = bottom - localRows + subRow(k) - 1;
                                    end 
                                else
                                    localArea(1:subRow(k)-1, :) = 0;  % Further upper rows
                                    if deltaRow < minDistTop
                                        minDistTop = deltaRow;
                                        topCut = top + subRow(k) - 1;
                                    end
                                end
                                if changeDirectionCol > 0
                                    localArea(:, subCol(k)+1:end) = 0;  % Further right cols
                                    if deltaCol < minDistRight
                                        minDistRight = deltaCol;
                                        rightCut = right - localCols + subCol(k) - 1;
                                    end
                                else
                                    localArea(:, 1:subCol(k)-1) = 0;  % Further left cols
                                    if deltaCol < minDistLeft
                                        minDistLeft = deltaCol;
                                        leftCut = left + subCol(k) - 1;
                                    end
                                end
                            end
                        end
                    end

                    % Update the checkedMap with the newly calculated boundaries
                    checkedMap(topCut:bottomCut, leftCut:rightCut) = true;
    
                    % Apply Gaussian fitting to the localArea
                    [fittedRow, fittedCol] = fitGaussian2D(localArea, centralRow, centralCol);
        
                    % Convert local fitted coordinates to global image coordinates
                    globalRow = top + fittedRow - 1;  % Adjust for the offset of localArea within the global frame
                    globalCol = left + fittedCol - 1;   % Adjust for the offset of localArea within the global frame
            
                    % Update the molecule map based on the fitted results
                    if round(globalCol) <= cols && round(globalRow) <= rows && round(globalCol) > 0 && round(globalRow) > 0
                        moleculeMap(round(globalRow), round(globalCol)) = true;
                    end
                end
            end
        end
    
        % Display the results
        cla(axImage);
        imshow(frame, 'Parent', axImage);
        hold(axImage, 'on');
        [moleculeY, moleculeX] = find(moleculeMap);
        plot(axImage, moleculeX, moleculeY, 'r*');
        hold(axImage, 'off');
    
        % Update the title with the number of molecules found
        numMolecules = sum(moleculeMap(:));
        title(axImage, [num2str(numMolecules) ' molecules found']);

        
    end


    function startAnalysis()
        % Load the first frame
        frame = loadedImages{1};
        
        % Thresholding
        threshold = graythresh(frame); % Otsu's method to find an automatic threshold
        binaryImage = imbinarize(frame, threshold);
        
        % Label connected components
        cc = bwconncomp(binaryImage);
        stats = regionprops(cc, 'Centroid', 'Area');
        
        % Filter out very small components that might be noise
        minArea = 5; % Minimum number of pixels to consider a molecule
        filteredStats = stats([stats.Area] >= minArea);
        
        % Extract centroids
        centroids = cat(1, filteredStats.Centroid);
        
        % Plot the results
        figure;
        imshow(frame, []);
        hold on;
        plot(centroids(:,1), centroids(:,2), 'r*');
        title('Detected Molecules');
        xlabel('X Position');
        ylabel('Y Position');
    end

    function menuCallback()
        disp('Menu button clicked.');
    end

    function saveCallback()
        disp('Save button clicked.');
    end
end
