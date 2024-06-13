function [outputDir, fileNameOutput] = create_output_directory(folder, fileName)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create output directory 

% author:  Alejandro Salgado
% date:    06.13.2024
% version: 1.0

%  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Define the base output directory
    baseOutputDir = fullfile(folder, 'output_data');

    % Get the current date
    currentDate = datestr(now, 'dd-mm-yyyy');

    % Extract the first part of the filename before any hyphen
    idx = strfind(fileName, '-');
    if ~isempty(idx)
        fileNameOutput = fileName(1:idx(1)-1);
    else
        fileNameOutput = fileName;
    end

    % Base directory where directories with dates are stored
    dateDir = fullfile(baseOutputDir, [fileNameOutput, '_', currentDate]);

    % Check and create baseOutputDir if it doesn't exist
    if ~exist(baseOutputDir, 'dir')
        mkdir(baseOutputDir);
    end

    % Check and create dateDir if it doesn't exist, if it does, manage the index
    if ~exist(dateDir, 'dir')
        mkdir(dateDir);
        outputDir = fullfile(dateDir, [fileNameOutput, '_', currentDate, '_1']);
        mkdir(outputDir);
    else
        % List all subfolders in the date directory
        d = dir([dateDir, '\', fileNameOutput, '_', currentDate, '_*']);
        numFolders = size(d, 1);

        % Find the highest index
        maxIndex = 0;
        for i = 1:numFolders
            folderName = d(i).name;
            splits = strsplit(folderName, '_');
            index = str2double(splits{end});
            if index > maxIndex
                maxIndex = index;
            end
        end

        % Define new directory with the next index
        newIndex = maxIndex + 1;
        outputDir = fullfile(dateDir, [fileNameOutput, '_', currentDate, '_', num2str(newIndex)]);
        mkdir(outputDir);
    end

    disp('    The output folder and file were created')
end
