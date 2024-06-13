function preprocess_image(folder)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Preprocess image

% author: Alejandro Salgado
% date: 06.12.2024
% version: 1.0

% From a TIF file the contrast and brightness is adjusted while also 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Variables for functions activation (EDIT THIS IF NEEDED)

    % Control variables
    applyContrast = true;
    applySharpness = true;
    saveTiff = true;
    showVideo = true;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Display a message in command window
    disp('1. Starting the image preprocessing...');

    % Specify the directory where the images are stored
    imageDir = [folder, '\input_data\'];

    % Prompt the user to select a TIFF file for preprocessing
    [fileName, filePath] = uigetfile({'*.tif;*.tiff', 'TIFF files (*.tif, *.tiff)'}, 'Select TIFF Image for Preprocessing', imageDir, 'MultiSelect', 'off');

    % Check if the user has not canceled the file selection
    if isequal(fileName, 0) || isequal(filePath, 0)
        disp('User canceled file selection.');
        return;
    else
        % Full path to the selected file
        fullFilePath = fullfile(filePath, fileName);

        % Read all frames from the TIFF file
        info = imfinfo(fullFilePath);
        numFrames = numel(info);
        allFrames = cell(numFrames, 1);

        for k = 1:numFrames
            allFrames{k} = imread(fullFilePath, k, 'Info', info);
        end

        if applyContrast
            disp('    1.1. Your image adjustment options have been saved and are being applied to other images.');

            % Display the first frame
            hFig = figure;
            hIm = imshow(allFrames{1}, []);
            title('Edit First Frame Contrast (Applied to all)');

            % Use imcontrast to adjust contrast interactively
            hContrast = imcontrast(hIm);  % Opens the Adjust Contrast tool linked to the displayed image

            % Wait for the contrast adjustment window to be closed by the user
            waitfor(hContrast);

            % Get the contrast adjusted image data
            contrastAdjustedImage = getimage(hIm);

            % Close the figure after the imcontrast window is closed
            close(hFig);

            % Convert the adjusted image to uint16, preserving original data type range
            minVal = double(min(contrastAdjustedImage(:)));
            maxVal = double(max(contrastAdjustedImage(:)));
        end

        if applySharpness
            [radius, amount, threshold] = get_sharpening_parameters();
            disp('    1.2. Sharpness selection and contrast adjustment have been selected and are going to be applied.');
        end

        % Apply contrast settings from the first frame to all frames
        for k = 1:numFrames
            if applyContrast
                frame = double(allFrames{k});
                adjustedFrame = uint16(65535 * (frame - minVal) / (maxVal - minVal));
            else
                adjustedFrame = allFrames{k}; % Use original frame if contrast is not applied
            end

            if applySharpness
                % Sharpen the adjusted frame using user-specified parameters
                adjustedFrame = imsharpen(adjustedFrame, 'Radius', radius, 'Amount', amount, 'Threshold', threshold);
            end
    
            % Store the sharpened frame back in the cell array
            adjustedFrames{k} = adjustedFrame;
        end

        if saveTiff
            disp('    1.3. Starting the saving of the adjusted frames...')

            % Call function to create output directory and filename for the processed image
            [outputDir, fileNameOutput] = create_output_directory(folder, fileName);

            % Define the output file path
            tiffFileName = fullfile(outputDir, ['adjusted_', fileNameOutput, '.tif']);

            % Write adjusted frames to the TIFF file
            for k = 1:numFrames
                if k == 1
                    imwrite(adjustedFrames{k}, tiffFileName, 'WriteMode', 'overwrite', 'Compression', 'none');
                else
                    imwrite(adjustedFrames{k}, tiffFileName, 'WriteMode', 'append', 'Compression', 'none');
                end
            end
            disp('    Adjusted TIFF has been saved.');
        end

        if showVideo
            disp('    1.4. A video will display the processed frames, to stop it just press X');

            % Create a figure to display the frames
            hFig = figure;
            
            % Display the frames one by one in a loop
            for k = 1:numFrames
                % Check if the figure is still open before trying to display the next frame
                if ~isvalid(hFig)
                    disp('    Figure window has been closed. Stopping display.');
                    break;  % Exit the loop if the figure has been closed
                end
                
                imshow(adjustedFrames{k}, []);
                title(sprintf('Frame %d', k));
                % Allow time for the figure to be closed during the pause
                drawnow;
            end
        end

        disp('Image preprocessing completed.');
    end
end





