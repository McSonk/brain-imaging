function motionCorrection(specifiedPath, spmFile)
    % listDirectoriesAndSubdirectories
    % Function to list all directories and their first-level subdirectories on a specified path

    spmData = load(spmFile);
    spm_jobman('initcfg');

    % Check if the specified TPM file exists
    tpmFile = spmData.matlabbatch{1, 5}.spm.spatial.preproc.tissue(1).tpm{1};
    if ~isfile(tpmFile)
        templates = getTemplates();
        warning('The specified template file does not exist: %s.\n Using %s', tpmFile, templates{1});
        for i = 1:6
            spmData.matlabbatch{1, 5}.spm.spatial.preproc.tissue(i).tpm{1} = templates{i};
        end
    end

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
        
        fprintf('  Files:\n');
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

        spmData.matlabbatch{1, 1}.spm.spatial.realign.estwrite.data = headMotionData(rep_1, rep_2);
        spmData.matlabbatch{1, 3}.spm.spatial.coreg.estimate.source = {fullfile(t2.folder, t2.name)};
        spmData.matlabbatch{1, 4}.spm.spatial.coreg.estimate.source = {fullfile(t1.folder, t1.name)};

        fprintf('Going to run the batch\n');
        spm_jobman('run', spmData.matlabbatch)
        fprintf('Done\n');
    end
end

function templates = getTemplates()
    templates = cell(6);
    spmPath = fileparts(which('spm'));
    tpmFileReal = fullfile(spmPath, 'tpm', 'TPM.nii');

    for i = 1:6
        templates{i} = strcat(tpmFileReal, sprintf(',%d', i));
    end
end

function target = filterByType(files, type)
    % Filter files by type
    target = files(contains({files.name}, type) & endsWith({files.name}, '.nii'));
    if ~isempty(target)
        target = target(1);
    end
end

function repFiles = headMotionData(rep1, rep2)
    % Load the first and second repetitions
    % Access individual elements of the 150x1 cell array
    
    aux1 = cell(150, 1);
    aux2 = cell(150, 1);
    repFiles = cell(1, 2);

    for i = 1:150
        aux1{i, 1} = strcat(fullfile(rep1.folder, rep1.name), sprintf(',%d', i));
        aux2{i, 1} = strcat(fullfile(rep2.folder, rep2.name), sprintf(',%d', i));
    end

    repFiles{1} = aux1;
    repFiles{2} = aux2;
end
