function Parameters = LSMParameters()
% This is where I save all the parameters and variables used throughout the
% the code for analyzing the sleep LSM dataset.
% for iota-neurophys, Snipes, 2024.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Analysis parameters

Parameters.Participants = {'P01', 'P02', 'P03', 'P04', 'P05', 'P06', 'P07', 'P08', 'P09', 'P10', 'P11', 'P12', 'P13', 'P14', 'P15', 'P16', 'P17', 'P18', 'P19'};
Parameters.Task = 'Sleep'; 
Parameters.Session = 'Baseline';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Paths

Paths = struct();

% raw data (really big hard disk)
RawCore = 'E:\LSM\Data';
Paths.Datasets = fullfile(RawCore, 'Raw');

% where to put preprocessed data (much smaller hard disk)
% PrepCore = 'F:\Data';
PrepCore = 'E:\Data';

Paths.Preprocessed = fullfile(PrepCore, 'Preprocessed');
Paths.Core = PrepCore;

% where current functions are
Paths.Analysis = mfilename('fullpath');
Paths.Analysis = fullfile(extractBefore(Paths.Analysis, '\LSM_Sleep\'));


% add to path all folders in functions
Content = deblank(string(ls(fullfile(Paths.Analysis, 'functions'))));
for Indx = 1:numel(Content)
    addpath(fullfile(Paths.Analysis, 'functions', Content{Indx}))
end


Paths.Cache =  fullfile(PrepCore, 'Cache', 'iota-neurophys');
Paths.Final = fullfile(PrepCore, 'Final'); % where data gets saved once its been turned into something else
Paths.Results = fullfile(PrepCore, 'Results', 'iota-neurophys');

Parameters.Paths = Paths;


%%% Folders for raw data: participants, and respective subfolders (legacy
%%% code)

RawFolders = struct();

RawFolders.Template = 'PXX';
RawFolders.Ignore = {'CSVs', 'other', 'Lazy', 'P00', 'Applicants'};

[RawFolders.Subfolders, RawFolders.Datasets] = AllFolderPaths(Paths.Datasets, ...
    RawFolders.Template, false, RawFolders.Ignore);

RawFolders.Subfolders(~contains(RawFolders.Subfolders, 'EEG')) = [];
RawFolders.Subfolders(~contains(RawFolders.Subfolders, 'Sleep')) = [];

Parameters.RawFolders = RawFolders;

% eeglab functions
if ~exist('topoplot', 'file')
    eeglab
    close all
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Preprocessing filter parameters

FilterParameters = struct();

% this is what I use to calculate power with minimal filtering for removing
% drift and antialiasing to allow downsampling.
FilterParameters.Minimal.Format = 'Minimal'; % reference name
FilterParameters.Minimal.fs = 250; % new sampling rate
FilterParameters.Minimal.lp = 100; % low pass filter
FilterParameters.Minimal.hp = 0.2; % high pass filter
FilterParameters.Minimal.hp_stopband = 0.1; % high pass filter
FilterParameters.Minimal.line = 50;

% this is what I used to use to calculate power
FilterParameters.Power.Format = 'Power'; % reference name
FilterParameters.Power.fs = 250; % new sampling rate
FilterParameters.Power.lp = 40; % low pass filter
FilterParameters.Power.hp = 0.5; % high pass filter
FilterParameters.Power.hp_stopband = 0.25; % high pass filter
FilterParameters.Power.line = 50;

% ICA: heavily filtered data for getting ICA components (I don't use it,
% but in case I ever want to...)
FilterParameters.ICA.Format = 'ICA'; % reference name
FilterParameters.ICA.fs = 250; % new sampling rate
FilterParameters.ICA.lp = 80; % low pass filter
FilterParameters.ICA.hp = 2.5; % high pass filter
FilterParameters.ICA.hp_stopband = .5; % high pass filter
FilterParameters.ICA.line = 50;

Parameters.FilterParameters = FilterParameters;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% EEG info

%%% bands
Bands.Theta = [4 8]; % add little gaps toavoid capturing edges
Bands.Alpha = [8 12];
Bands.Sigma = [12 16];
Bands.Beta = [16 25];
Bands.Iota = [25 35];
Bands.Gamma = [35 40];

Parameters.Bands = Bands;

%%% channels
Frontspot = [22 15 9 23 18 16 10 3 24 19 11 4 124 20 12 5 118 13 6 112];
Backspot = [66 71 76 84 65 70 75 83 90 69 74 82 89];
Centerspot = [129 7 106 80 55 31 30 37 54 79 87 105 36 42 53 61 62 78 86 93 104 35 41 47  52 92 98 103 110, 60 85 51 97];

Channels.PreROI.Front = Frontspot;
Channels.PreROI.Center = Centerspot;
Channels.PreROI.Back = Backspot;
Channels.NotEdge = 1:128;
Channels.Edge =   [1 8 14 17 21 25 32 128 38 44 43 48 63 68 73 81 88 94 99 120 119 114 121 125];
Channels.NotEdge(Channels.Edge) = [];
Channels.notEEG = [49, 56, 107, 113, 126, 127];
Channels.Standard_10_20 = [11 22 9 24 124 33 122 129 36 104 45 108 62 52 92 58 96 75 70 83];

Parameters.Channels = Channels;


%%% cycle-by-cycle parameters
CriteriaSet = struct();

CriteriaSet.MonotonicityInAmplitude = 0.9;
CriteriaSet.AmplitudeConsistency = .3; % left and right cycles should be of similar amplitude
CriteriaSet.isTruePeak = 1;
CriteriaSet.isProminent = 1;
CriteriaSet.MinCyclesPerBurst = 4;
CriteriaSet.ShapeConsistency = .4;
CriteriaSet.FlankConsistency = .4;

Parameters.CriteriaSet = CriteriaSet;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Plotting information


Parameters.PlotProps.Manuscript = chART.load_plot_properties({'Manuscript', 'Iota'});
Parameters.PlotProps.Manuscript.Color.Participants = ...
    chART.utils.resize_colormap(Parameters.PlotProps.Manuscript.Color.Maps.Rainbow, ...
    numel(Parameters.Participants));

Parameters.PlotProps.Powerpoint = chART.load_plot_properties({'Powerpoint', 'Iota'});
Parameters.PlotProps.Poster = chART.load_plot_properties({'Poster', 'Iota'});





