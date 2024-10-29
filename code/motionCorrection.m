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
        fprintf('    REP1: %s\n', fullfile(specifiedPath, mainDirs(i).name, rep_1.name));

        % Extract the first number from rep_1.name
        rep_2_number = regexp(rep_1.name, 'REP\d+', 'match', 'once');
        rep_2_number = rep_2_number(end);
        rep_2_number = str2double(rep_2_number) + 1;

        rep_2 = filterByType(subDirs, sprintf('REP%d', rep_2_number));
        fprintf('    REP2: %s\n', fullfile(specifiedPath, mainDirs(i).name, rep_2.name));
    end
end

function target = filterByType(files, type)
    % Filter files by type
    target = files(contains({files.name}, type) & endsWith({files.name}, '.nii'));
    if ~isempty(target)
        target = target(1);
    end
end
