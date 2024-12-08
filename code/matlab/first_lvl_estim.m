
% first_lvl_estim('/home/sonk/Devel/master/brain-imaging/data/rawdata', '/home/sonk/Devel/master/brain-imaging/code/first_level_model_estimation.mat')
function first_lvl_estim(specifiedPath, spmFile)
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

        % Check if required files exists
        results_dir = fullfile(specifiedPath, mainDirs(i).name, 'results');

        if ~exist(results_dir, 'dir')
            fprintf('    ERROR: Results directory does not exist. Skipping...\n');
            appendError(sprintf('Results directory does not exist: %s\n', results_dir));
            continue;
        end

        filesInResultsDir = dir(results_dir);
        filesInResultsDir = filesInResultsDir(~[filesInResultsDir.isdir]); % Filter only files
        if isempty(filesInResultsDir)
            fprintf('    ERROR: Results directory does not contain files. Skipping...\n');
            appendError(sprintf('Results directory does not contain files: %s\n', results_dir));
            continue;
        end
        % Check if 'SPM.mat' exists in the results directory
        if ~any(strcmp({filesInResultsDir.name}, 'SPM.mat'))
            fprintf('    ERROR: SPM.mat file does not exist in the results directory. Skipping...\n');
            appendError(sprintf('SPM.mat file does not exist in the results directory: %s\n', results_dir));
            continue;
        end

        % Load the SPM file
        spm_file = fullfile(results_dir, 'SPM.mat');
        fprintf('    Results dir: %s\n', results_dir);
        fprintf('    SPM file: %s\n', spm_file);
        % Update the SPM data


        spmData.matlabbatch{1}.spm.stats.fmri_est.spmmat = {spm_file};
        
        fprintf('Going to run the batch\n');
        original_path = pwd;
        try
            spm_jobman('run', spmData.matlabbatch)
            fprintf('Done\n');
        catch ME
            cd(original_path);
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
            fprintf(fid, '    SPM file: %s\n', spm_file);
            fprintf(fid, '\n');
            fclose(fid);

            fprintf('Done with errors\n');
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

function appendError(message)
    errorFile = fullfile('/home/sonk/Devel/master/brain-imaging/code/matlab', 'error_log.txt');
    if ~exist(errorFile, 'file')
        fid = fopen(errorFile, 'w');
    else
        fid = fopen(errorFile, 'a');
    end
    fprintf(fid, '========================================\n');
    fprintf(fid, message);
    fprintf(fid, 'Timestamp: %s\n', datestr(now, 'yyyy-mm-dd HH:MM:SS'));
    fprintf(fid, '\n');
    fclose(fid);
end
