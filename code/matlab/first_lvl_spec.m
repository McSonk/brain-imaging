
% first_lvl_spec('/home/sonk/Devel/master/brain-imaging/data/rawdata', '/home/sonk/Devel/master/brain-imaging/code/first_level_specification.mat')
function first_lvl_spec(specifiedPath, spmFile)
    spmData = load(spmFile);
    spm_jobman('initcfg');

    % Get the list of all directories in the specified path
    mainDirs = dir(specifiedPath);
    mainDirs = mainDirs([mainDirs.isdir]); % Filter only directories
    mainDirs = mainDirs(~ismember({mainDirs.name}, {'.', '..'})); % Remove '.' and '..'
    % mainDirs contains the list of all directories in the specified path
    for i = 1:length(mainDirs)
        % mainDirs(i).name contains the name of the current directory
        fprintf('Analysing: %s\n', fullfile(specifiedPath, mainDirs(i).name));
        
        % Extract the repetitions
        subDirs = dir(fullfile(specifiedPath, mainDirs(i).name));
        subFiles = subDirs(~[subDirs.isdir]); % Filter only files
        % subFiles contains the list of all files in the current directory
        fprintf('Current working directory: %s\n', pwd);
        fprintf('%s\n', fullfile(specifiedPath, mainDirs(i).name));
        rep_1 = getFirstSwarRep(subFiles);
        fprintf('    REP1: %s\n', fullfile(specifiedPath, mainDirs(i).name, rep_1.name));
        
        % Extract the first number from rep_1.name
        rep_2 = getNextSwarRep(subFiles, rep_1);
        fprintf('    REP2: %s\n', fullfile(specifiedPath, mainDirs(i).name, rep_2.name));

        reps = rep150(rep_1, rep_2);

        % Get the behavioural data
        beh_dir = dir(fullfile(specifiedPath, mainDirs(i).name, 'beh'));
        beh_files = beh_dir(~[beh_dir.isdir]); % Filter only files
        beh_1 = fullfile(specifiedPath,mainDirs(i).name, 'beh', getFirstBeh(beh_files).name);
        beh_2 = fullfile(specifiedPath,mainDirs(i).name, 'beh', getNextBeh(beh_files).name);
        fprintf('    Behaviour 1: %s\n', beh_1);
        fprintf('    Behaviour 2: %s\n', beh_2);

        % Get motion parameters
        motion_1 = getFirstMotion(subFiles);
        motion_2 = getNextMotion(subFiles, motion_1);
        fprintf('    Motion 1: %s\n', fullfile(specifiedPath, mainDirs(i).name, motion_1.name));
        fprintf('    Motion 2: %s\n', fullfile(specifiedPath, mainDirs(i).name, motion_2.name));

        % Results dir
        results_dir = fullfile(specifiedPath, mainDirs(i).name, 'results');

        if ~exist(results_dir, 'dir')
            mkdir(results_dir);
        else
            filesInResultsDir = dir(results_dir);
            filesInResultsDir = filesInResultsDir(~[filesInResultsDir.isdir]); % Filter only files
            if ~isempty(filesInResultsDir)
            fprintf('    Results directory already contains files. Skipping...\n');
            continue;
            end
        end
        fprintf('    Results dir: %s\n', results_dir);

        % Update the SPM data
        spmData.matlabbatch{1}.spm.stats.fmri_spec.dir{1} = results_dir;


        spmData.matlabbatch{1}.spm.stats.fmri_spec.sess(1).scans = reps{1};
        spmData.matlabbatch{1}.spm.stats.fmri_spec.sess(2).scans = reps{2};
        
        spmData.matlabbatch{1}.spm.stats.fmri_spec.sess(1).multi = {beh_1};
        spmData.matlabbatch{1}.spm.stats.fmri_spec.sess(2).multi = {beh_2};

        spmData.matlabbatch{1}.spm.stats.fmri_spec.sess(1).multi_reg = {fullfile(specifiedPath, mainDirs(i).name, motion_1.name)};
        spmData.matlabbatch{1}.spm.stats.fmri_spec.sess(2).multi_reg = {fullfile(specifiedPath, mainDirs(i).name, motion_2.name)};

        fprintf('Going to run the batch\n');
        fprintf('Current working directory: %s\n', pwd);
        original_path = pwd;
        try
            fprintf('Current working directory: %s\n', pwd);
            spm_jobman('run', spmData.matlabbatch)
            fprintf('Done\n');
        catch ME
            cd(original_path);
            fprintf('Current working directory: %s\n', pwd);
            fprintf('An error occurred: %s\n', ME.message);
            errorFile = fullfile('/home/sonk/Devel/master/brain-imaging/code/matlab', 'error_log.txt');
            if ~exist(errorFile, 'file')
                fid = fopen(errorFile, 'w');
            else
                fid = fopen(errorFile, 'a');
            end
            fprintf(fid, 'Error in directory: %s\n', fullfile(specifiedPath, mainDirs(i).name));
            fprintf(fid, 'Error message: %s\n', ME.message);
            fprintf(fid, 'Stack trace:\n');
            for k = 1:length(ME.stack)
                fprintf(fid, '    File: %s\n', ME.stack(k).file);
                fprintf(fid, '    Name: %s\n', ME.stack(k).name);
                fprintf(fid, '    Line: %d\n', ME.stack(k).line);
            end

            fprintf(fid, 'PARAMS:\n');
            fprintf(fid, '    REP1: %s\n', fullfile(specifiedPath, mainDirs(i).name, rep_1.name));
            fprintf(fid, '    REP2: %s\n', fullfile(specifiedPath, mainDirs(i).name, rep_2.name));
            fprintf(fid, '    Behaviour 1: %s\n', beh_1);
            fprintf(fid, '    Behaviour 2: %s\n', beh_2);
            fprintf(fid, '    Motion 1: %s\n', fullfile(specifiedPath, mainDirs(i).name, motion_1.name));
            fprintf(fid, '    Motion 2: %s\n', fullfile(specifiedPath, mainDirs(i).name, motion_2.name));

            fprintf(fid, '\n');
            fclose(fid);

            fprintf('Done with errors\n');
            fprintf('Current working directory: %s\n', pwd);
            % cd ../../../../code/matlab
        end
    end
end

function target = filterByType(files, type)
    % Filter files by type (ONLY NII)
    target = files(contains({files.name}, type) & endsWith({files.name}, '.nii'));
    if ~isempty(target)
        target = target(1);
    end
end

function target = filterMAT(files, type)
    % Filter files by type (ONLY MAT)
    target = files(contains({files.name}, type) & endsWith({files.name}, '.mat') & ~strcmp({files.name}, '.DS_Store'));
    if ~isempty(target)
        target = target(1);
    end
end

function target = filterTXT(files, type)
    % Filter files by type (ONLY NII)
    target = files(contains({files.name}, type) & endsWith({files.name}, '.txt'));
    if ~isempty(target)
        target = target(1);
    end
end

function target = getFirstSwarRep(files)
    % Filter files by type
    target = filterByType(files, 'swa_r');
    if isempty(target)
        fprintf('No swa_r files found\n');
    end
end

function target = getNextSwarRep(files, currentRep)
    % Extract the first number from rep_1.name
    rep2Number = regexp(currentRep.name, 'REP\d+', 'match', 'once');
    rep2Number = rep2Number(end);
    rep2Number = str2double(rep2Number) + 1;

    % Filter files by type
    target = files(contains({files.name}, 'swa_r') & contains({files.name}, sprintf('REP%d', rep2Number)) & endsWith({files.name}, '.nii'));
    if ~isempty(target)
        target = target(1);
    end
end


function target = getFirstBeh(files)
    % Filter files by type
    target = filterMAT(files, 'r1');
end

function target = getNextBeh(files)
    % Filter files by type
    target = filterMAT(files, 'r2');
end

function target = getFirstMotion(files)
    % Filter files by type
    target = filterTXT(files, 'REP');
end

function target = getNextMotion(files, currentRep)
    % Extract the first number from rep_1.name
    rep2Number = regexp(currentRep.name, 'REP\d+', 'match', 'once');
    rep2Number = rep2Number(end);
    rep2Number = str2double(rep2Number) + 1;

    % Filter files by type
    target = files(contains({files.name}, 'REP') & contains({files.name}, sprintf('REP%d', rep2Number)) & endsWith({files.name}, '.txt'));
    if ~isempty(target)
        target = target(1);
    end
end

function repFiles = rep150(rep1, rep2)
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
