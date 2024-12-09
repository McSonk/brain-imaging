
% first_lvl_contrast('/home/sonk/Devel/master/brain-imaging/data/rawdata', '/home/sonk/Devel/master/brain-imaging/code/first_level_contrast.mat')
function first_lvl_contrast(specifiedPath, spmFile)
    spmData = load(spmFile);
    % spm_jobman('initcfg');

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

        spm_info = load(spm_file);

        % Check the number of sessions
        if length(spm_info.SPM.Sess) ~= 2
            fprintf('    ***************************************************************ERROR: Number of sessions is not 2\n');
            appendError(sprintf('Number of sessions is not 2: %s\n', results_dir));
            continue;
        end

        weights1 = getWeightsVector(spm_info);
        if isempty(weights1)
            continue;
        end
        disp(weights1);

        % Update the SPM data


        spmData.matlabbatch{1}.spm.stats.con.spmmat = {spm_file};
        spmData.matlabbatch{1}.spm.stats.con.consess{1}.tcon.weights = weights1{1};
        spmData.matlabbatch{1}.spm.stats.con.consess{2}.tcon.weights = weights1{2};
        spmData.matlabbatch{1}.spm.stats.con.consess{3}.tcon.weights = weights1{3};
        spmData.matlabbatch{1}.spm.stats.con.consess{4}.tcon.weights = weights1{4};


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

function text = getWeightsVector(spm_info)
    % Only session1 is important!!!
    % For session 1 with dummy data:
    % 1 zeros(1, 10) 1
    % 0 1 zeros(1, 10) 1
    % 0 0 1 zeros(1, 10) 1
    % 0 0 0 1 zeros(1, 10) 1

    % For session 1 without dummy data:
    % 1 zeros(1, 9) 1
    % 0 1 zeros(1, 9) 1
    % 0 0 1 zeros(1, 9) 1
    % 0 0 0 1 zeros(1, 9) 1

    % Check the number of regressors
    if length(spm_info.SPM.Sess(1).U) == 5
        % The session has dummy data, so we'll set the usual case
        weights{1} = [1 zeros(1, 10) 1];
        weights{2} = [0 1 zeros(1, 10) 1];
        weights{3} = [0 0 1 zeros(1, 10) 1];
        weights{4} = [0 0 0 1 zeros(1, 10) 1];
    else
        if length(spm_info.SPM.Sess(1).U) == 4
            % The session does not have dummy data
            weights{1} = [1 zeros(1, 9) 1];
            weights{2} = [0 1 zeros(1, 9) 1];
            weights{3} = [0 0 1 zeros(1, 9) 1];
            weights{4} = [0 0 0 1 zeros(1, 9) 1];
        else
            fprintf('    ERROR: Number of regressors for session 1 is not 4 or 5\n');
            appendError(sprintf('Number of regressors for session 1 is not 4 or 5: %s\n', results_dir));
            my_data = '';
        end
    end
    text = weights;
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
