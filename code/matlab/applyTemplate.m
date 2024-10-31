function applyTemplate(specifiedPath, spmFile)
    spmData = load(spmFile);
    spm_jobman('initcfg');

    % Get the list of all directories in the specified path
    mainDirs = dir(specifiedPath);
    mainDirs = mainDirs([mainDirs.isdir]); % Filter only directories
    mainDirs = mainDirs(~ismember({mainDirs.name}, {'.', '..'})); % Remove '.' and '..'
    for i = 1:length(mainDirs)
        fprintf('Analysing: %s\n', fullfile(specifiedPath, mainDirs(i).name));
        % Get the list of first-level subdirectories
        subDirs = dir(fullfile(specifiedPath, mainDirs(i).name));
        subDirs = subDirs(~[subDirs.isdir]); % Filter only files
        fprintf('  Files:\n');

        template = filterByType(subDirs, 'Template');
        template = fullfile(template.folder, template.name);
        fprintf('    Template: %s\n', template);

        rep1 = getFirstARRep(subDirs);
        rep2 = getNextARRep(subDirs, rep1);

        rep1 = fullfile(rep1.folder, rep1.name);
        fprintf('    REP1: %s\n', rep1);

        rep2 = fullfile(rep2.folder, rep2.name);
        fprintf('    REP2: %s\n', rep2);

        spmData.matlabbatch{1}.spm.tools.dartel.mni_norm.data.subj.flowfield = {template};
        spmData.matlabbatch{1}.spm.tools.dartel.mni_norm.data.subj.images{1,1} = rep1;
        spmData.matlabbatch{1}.spm.tools.dartel.mni_norm.data.subj.images{2,1} = rep2;
        % display(spmData.matlabbatch{1}.spm.tools.dartel.mni_norm.data.subj.images);

        fprintf('Going to run the batch\n');
        spm_jobman('run', spmData.matlabbatch)
        fprintf('Done\n');
    end
end

function target = filterByType(files, type)
    % Filter files by type
    target = files(contains({files.name}, type) & endsWith({files.name}, '.nii'));
    if ~isempty(target)
        target = target(1);
    end
end

function target = getFirstARRep(files)
    % Filter files by type
    target = filterByType(files, 'a_r');
end

function target = getNextARRep(files, currentRep)
    % Extract the first number from rep_1.name
    rep2Number = regexp(currentRep.name, 'REP\d+', 'match', 'once');
    rep2Number = rep2Number(end);
    rep2Number = str2double(rep2Number) + 1;

    % Filter files by type
    target = files(contains({files.name}, 'a_r') & contains({files.name}, sprintf('REP%d', rep2Number)) & endsWith({files.name}, '.nii'));
    if ~isempty(target)
        target = target(1);
    end
end