function [tkeo_movement_envelope, tkeo_vibration_envelope, mv_baseline_th, vb_baseline_th,...
    trial_onset_index, test_type, vb_index, mv_index, vb_fing, mv_fing, vb_onset_indexes, mv_onset_indexes] = computeAll(signal,...
    filter_order_mv, cutoff_low_mv, cutoff_high_mv, sampling, tkeo_window_size, vb_alpha, mv_alpha,...
    no_onset_period_ms, vibration_time_ms, vb_filter_order, vb_cutoff_low, vb_cutoff_high, trial_nbr, trial_segment, box_triallist)
    % This function computes various features from a given signal, including movement and vibration envelopes,
    % baseline thresholds, trial onset indexes, test types, and other related indexes.
    %
    % Inputs:
    %   - signal: The input signal to be analyzed.
    %   - filter_order_mv: Filter order for movement detection.
    %   - cutoff_low_mv: Low cutoff frequency for movement detection.
    %   - cutoff_high_mv: High cutoff frequency for movement detection.
    %   - sampling: Sampling rate of the signal.
    %   - tkeo_window_size: Window size for the Teager-Kaiser Energy Operator (TKEO).
    %   - mv_alpha: Alpha value for movement detection.
    %   - no_onset_period_ms: No onset period in milliseconds.
    %   - vibration_time_ms: Vibration time in milliseconds.
    %   - vb_filter_order: Filter order for vibration detection.
    %   - vb_cutoff_low: Low cutoff frequency for vibration detection.
    %   - vb_cutoff_high: High cutoff frequency for vibration detection.
    %   - trial_nbr: Number of trials.
    %   - trial_segment: Cell array containing trial segments.
    %   - box_triallist: List of box trials.
    %
    % Outputs:
    %   - tkeo_movement_envelope: TKEO movement envelope.
    %   - tkeo_vibration_envelope: TKEO vibration envelope.
    %   - mv_baseline_th: Movement baseline threshold.
    %   - vb_baseline_th: Vibration baseline threshold.
    %   - trial_onset_index: Trial onset indexes.
    %   - test_type: Test types.
    %   - vb_index: Vibration indexes.
    %   - mv_index: Movement indexes.
    %   - vb_fing: Vibration finger indexes.
    %   - mv_fing: Movement finger indexes.
    %   - vb_onset_indexes: Vibration onset indexes.
    %   - mv_onset_indexes: Movement onset indexes.
    
    %% Detect features
    % Movement detection
    [tkeo_movement, tkeo_movement_envelope, mv_onset_indexes, mv_baseline_th] = getFeatures(signal, filter_order_mv, cutoff_low_mv, cutoff_high_mv, sampling, tkeo_window_size, mv_alpha, no_onset_period_ms, vibration_time_ms, 0);
    % Vibration detection
    [tkeo_vibration, tkeo_vibration_envelope, vb_onset_indexes, vb_baseline_th] = getFeatures(signal, vb_filter_order, vb_cutoff_low, vb_cutoff_high, sampling, tkeo_window_size, vb_alpha, no_onset_period_ms, vibration_time_ms, 1);

    % Normalize vibration and movement sizes
    ratio_vb_mv = mean(tkeo_vibration_envelope) ./ mean(tkeo_movement_envelope);
    tkeo_vibration_envelope = tkeo_vibration_envelope - tkeo_movement_envelope .* ratio_vb_mv;

    vb_onset_indexes = getSignalOnset(tkeo_vibration_envelope, vb_baseline_th, no_onset_period_ms, 1, vibration_time_ms);

    %% Test type detection
    % Get unique onsets so that we can compare them with the box data
    no_onset_period_index = no_onset_period_ms * 2;

    unique_vb = getUniqueOnsets(vb_onset_indexes, no_onset_period_index);
    unique_mv = getUniqueOnsets(mv_onset_indexes, no_onset_period_index);

    % Use box data to get test type
    trial_onset_index = zeros(1, trial_nbr); % 240 trials from 0 
    for i = 1:trial_nbr
        trial_onset_index(i) = trial_segment{i}.sample_index;
    end

    box_trial_list = box_triallist;
    [test_type, vb_index, mv_index, vb_fing, mv_fing] = getTestFromBox(trial_onset_index, box_trial_list, no_onset_period_index, unique_mv, unique_vb);
end
