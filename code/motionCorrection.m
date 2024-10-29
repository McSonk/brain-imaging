function motionCorrection(specifiedPath)
    % listDirectoriesAndSubdirectories
    % Function to list all directories and their first-level subdirectories on a specified path

    % Get the list of all directories in the specified path
    mainDirs = dir(specifiedPath);
    mainDirs = mainDirs([mainDirs.isdir]); % Filter only directories
    mainDirs = mainDirs(~ismember({mainDirs.name}, {'.', '..'})); % Remove '.' and '..'

    % Display the directories and their first-level subdirectories
    for i = 1:length(mainDirs)
        fprintf('Analysing: %s\n', fullfile(specifiedPath, mainDirs(i).name));
        
        % Get the list of first-level subdirectories
        subDirs = dir(fullfile(specifiedPath, mainDirs(i).name));
        subDirs = subDirs(~[subDirs.isdir]); % Filter only files
        
        fprintf('  Subdirectories:\n');
        % Filter subdirectories containing 'T1' and ending with '.nii'
        t1 = filterByType(subDirs, 'T1');
        fprintf('    T1: %s\n', fullfile(specifiedPath, mainDirs(i).name, t1.name));

        t2 = filterByType(subDirs, 't2');
        fprintf('    t2: %s\n', fullfile(specifiedPath, mainDirs(i).name, t2.name));

        rep_1 = filterByType(subDirs, 'REP');
        fprintf('    REP: %s\n', fullfile(specifiedPath, mainDirs(i).name, rep_1.name));
    end
end

function target = filterByType(files, type)
    % Filter files by type
    target = files(contains({files.name}, type) & endsWith({files.name}, '.nii'));
    if ~isempty(target)
        target = target(1);
    end
end
