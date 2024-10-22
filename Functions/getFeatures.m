function [tkeo, tkeo_envelope, onset_indexes, baseline_th] = getFeatures(channels, filter_order, cutoff_low, cutoff_high, sampling, data_length, tkeo_window_size, alpha, no_onset_period_ms, vibration_time_ms, vibration_flag)
    % This function extracts features from given signal channels.
    % Inputs:
    %   channels - cell array containing signal data for each channel
    %   filter_order - order of the Butterworth filter
    %   cutoff_low - lower cutoff frequency for the bandpass filter
    %   cutoff_high - upper cutoff frequency for the bandpass filter
    %   sampling - sampling rate of the signal
    %   data_length - length of the signal data
    %   tkeo_window_size - window size for the TKEO (Teager-Kaiser Energy Operator)
    %   alpha - multiplier for the standard deviation to set the baseline threshold
    %   no_onset_period_ms - minimum period in milliseconds to consider between onsets
    %   vibration_time_ms - time in milliseconds to consider for vibration flag
    %   vibration_flag - flag to indicate if vibration should be considered
    % Outputs:
    %   tkeo - TKEO processed signal
    %   tkeo_envelope - envelope of the TKEO processed signal
    %   onset_indexes - indexes of the signal onsets
    %   baseline_th - baseline threshold calculated from the signal

    onset_indexes = [];

    channel_nbr = length(channels);
    % Design bandpass filter
    [b, a] = butter(filter_order, [cutoff_low/(sampling/2), cutoff_high/(sampling/2)], 'bandpass');

    % Initialize movement matrix
    movement = zeros(data_length, channel_nbr);
    for i = 1:channel_nbr
        movement(:,i) = filtfilt(b, a , channels{i}.data);
    end

    % Apply TKEO and get envelope
    [tkeo, tkeo_envelope] = getCleanSignal_tkeo(movement, tkeo_window_size, channel_nbr);

    % Find signal baseline
    baseline = mean(tkeo_envelope);
    baseline_std = std(tkeo_envelope);
    baseline_th = baseline + alpha*baseline_std;

    if ~vibration_flag
        % Get signal onset indexes
        onset_indexes = getSignalOnset(tkeo_envelope, baseline_th, no_onset_period_ms, channel_nbr, vibration_flag, vibration_time_ms);
    end
end