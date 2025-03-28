function EEG = add_cz(EEG)
% adds an empty channel for Cz
%
% From iota-neurophys by Sophia Snipes, 2024

if any(strcmpi({EEG.chanlocs.labels}, 'CZ'))
    return
end

load('Cz.mat', 'CZ')

EEG.data(end+1, :) = zeros(1, size(EEG.data, 2));
EEG.chanlocs(end+1) = CZ;
EEG.nbchan = size(EEG.data, 1);
EEG = eeg_checkset(EEG);
