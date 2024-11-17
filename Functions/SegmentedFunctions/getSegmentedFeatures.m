function [tkeo, tkeo_envelope, onset_indexes, baseline_th] = getSegmentedFeatures(signal, filter_order, cutoff_low, cutoff_high, sampling, tkeo_window_size, alpha, no_onset_period_ms, vibration_time_ms, vibration_flag, segmentation_points_index)
    % This function extracts features from given segmented signal.
    % Inputs:
    %   signal - cell array containing signal data for each channel
    %   filter_order - order of the Butterworth filter
    %   cutoff_low - lower cutoff frequency for the bandpass filter
    %   cutoff_high - upper cutoff frequency for the bandpass filter
    %   sampling - sampling rate of the signal
    %   tkeo_window_size - window size for the TKEO (Teager-Kaiser Energy Operator)
    %   alpha - multiplier for the standard deviation to set the baseline threshold
    %   no_onset_period_ms - minimum period in milliseconds to consider between onsets
    %   vibration_time_ms - time in milliseconds to consider for vibration flag
    %   vibration_flag - flag to indicate if vibration should be considered
    %   segmentation_points_index - indexes of the signal segmentation points
    % Outputs:
    %   tkeo - TKEO processed signal
    %   tkeo_envelope - envelope of the TKEO processed signal
    %   onset_indexes - indexes of the signal onsets
    %   baseline_th - baseline threshold calculated from the signal

    onset_indexes = [];

    channel_nbr = length(signal(1,:));
    % Design bandpass filter
    [b, a] = butter(filter_order, [cutoff_low/(sampling/2), cutoff_high/(sampling/2)], 'bandpass');

    % Filter signal to detect feature
    feature = filtfilt(b, a , signal);

    % Apply TKEO and get envelope
    [tkeo, tkeo_envelope] = getCleanSignal_tkeo(feature, tkeo_window_size, channel_nbr);

    % Find signal baseline
    baseline = mean(tkeo_envelope);
    baseline_std = std(tkeo_envelope);
    baseline_th = baseline + alpha*baseline_std;

    if ~vibration_flag
        % Get signal onset indexes
        onset_indexes = getSegmentedSignalOnset(tkeo_envelope, baseline_th, no_onset_period_ms, vibration_flag, vibration_time_ms, segmentation_points_index);
    end
end