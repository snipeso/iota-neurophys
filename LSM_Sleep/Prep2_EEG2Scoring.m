% goes through folder structure, gets set/mat file, saves sleep scoring data.
% This is saving data in the legacy format for "zurich sleep scoring"
% software. Now, I recommend to use Sven Leach's "scoringhero".
% from iota-neurophys, Snipes, 2024 (originally much older).

clear
clc
close all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Tasks = {'Sleep'};

Refresh = false;

P = LSMParameters();

Paths = P.Paths;
Folders = P.RawFolders;

% Scoring: has special script for running this
Parameters.fs = 128;
Parameters.SpChannel = 6;
Parameters.lp = 40; % low pass filter
Parameters.hp = .5; % high pass filter
Parameters.hp_stopband = .2; % high pass filter gradual roll-off


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Consider only relevant subfolders
Folders.Subfolders(~contains(Folders.Subfolders, Tasks)) = [];

for Indx_D = 1:size(Folders.Datasets,1) % loop through participants
    for Indx_F = 1:size(Folders.Subfolders, 1) % loop through all subfolders
        
        %%%%%%%%%%%%%%%%%%%%%%%%
        %%% Check if data exists
        
        Path = fullfile(Paths.Datasets, Folders.Datasets{Indx_D}, Folders.Subfolders{Indx_F});
        
        % skip rest if folder not found
        if ~exist(Path, 'dir')
            warning([deblank(Path), ' does not exist'])
            continue
        end
        
        % identify menaingful folders traversed
        Levels = split(Folders.Subfolders{Indx_F}, '\');
        Levels(cellfun('isempty',Levels)) = []; % remove blanks
        Levels(strcmpi(Levels, 'EEG')) = []; % remove uninformative level that its an EEG
        
        Task = Levels{1}; % task is assumed to be the first folder in the sequence
        
        % if does not contain EEG, then skip
        Content = ls(Path);
        MAT = contains(string(Content), '.mat');
        if ~any(MAT)
            if any(strcmpi(Levels, 'EEG')) % if there should have been an EEG file, be warned
                warning([Path, ' is missing MAT file'])
            end
            continue
        elseif nnz(MAT) > 1 % if there's more than one set file, you'll need to fix that
            warning([Path, ' has more than one MAT file'])
            continue
        end
        
        Filename_MAT = Content(MAT, :);
        
        % set up destination location
        Destination = fullfile(Paths.Core, 'Scoring', Task);
        Filename_Core = join([Folders.Datasets{Indx_D}, Levels(:)'], '_');
        Filename_Core = Filename_Core{1};
        
        % create destination folder
        if ~exist(Destination, 'dir')
            mkdir(Destination)
        end
        
        % skip filtering if file already exists
        if ~Refresh && exist(fullfile(Destination, Filename_Core), 'file')
            disp(['***********', 'Already did ', Filename_Core, '***********'])
            continue
        elseif Refresh && exist(fullfile(Destination, Filename_Core), 'file')
            FinalDestination = [Destination,'_Copy'];
            warning(['***********', 'Already did ', Filename_Core, ' so making copy ***********'])
        else
            FinalDestination = Destination;
        end
        
        
        %%%%%%%%%%%%%%%%%%%
        %%% process the data
        
        % load file
        EEGunf = load_eeglab_file_for_sleep(Path, Sleep_Channels()); % loads a .set, selects relevant channels
        
        % filter and downsample the data
        EEG = FilterScoring(EEGunf);
        
        %%% Rereference the data
        ScoringData = RereferenceScoring(EEG.data); % Only takes the data matrix
        
        %%% Create delta power (sp1) and vigilance index (sp2) spectrums
        [sp1, sp2] = SpectrumScoring(ScoringData(Parameters.SpChannel, :), Parameters.fs);
        
        %%% Save
        Filename_Short = [Folders.Datasets{Indx_D}, '_', num2str(Indx_F)];
        SaveScoring(FinalDestination, Filename_Core, Filename_Short, ScoringData, double(sp1), double(sp2));
    end
end