% doSegmentedDetection - Perform all necessary computations for the given task.
%
% This function is designed to handle all the computational tasks required
% for the signal analysis project. 
%   - Segments the signal into trials
%   - Detects vibrations and movements in the signal
%   - Detects the onset of vibrations and movements [index]
%   - Determines the test type based on the onset data
%   - Compares the result with the box data
%
% Syntax: 
%   doSegmentedDetection
%%% 

%% Detect features

% Segment the signal into trials
segmentation_points_index = round(segmentation_points * sampling);
segmentation_points_index(1) = 1;

% % Movement detection
[tkeo_movement, tkeo_movement_envelope, mv_onset_indexes, mv_baseline_th] = getSegmentedFeatures(signal, filter_order_mv, cutoff_low_mv, cutoff_high_mv, sampling, tkeo_window_size, mv_alpha, no_onset_period_ms, vibration_time_ms, 0, segmentation_points_index);
% Vibration detection
[tkeo_vibration, tkeo_vibration_envelope, vb_onset_indexes, vb_baseline_th] = getSegmentedFeatures(signal, vb_filter_order, vb_cutoff_low, vb_cutoff_high, sampling, tkeo_window_size, vb_alpha, no_onset_period_ms, vibration_time_ms, 1, segmentation_points_index);

% Normalize vibration and movement sizes
ratio_vb_mv = mean(tkeo_vibration_envelope) ./ mean(tkeo_movement_envelope);
tkeo_vibration_envelope = tkeo_vibration_envelope - tkeo_movement_envelope .* ratio_vb_mv;

% % Find signal baseline
% baseline = mean(tkeo_envelope);
% baseline_std = std(tkeo_envelope);
% baseline_th = baseline + alpha*baseline_std;

% Sometrhing is wrong with the baseline calculation
vb_onset_indexes = getSegmentedSignalOnset(tkeo_vibration_envelope, vb_baseline_th, no_onset_period_ms, 1, vibration_time_ms, segmentation_points_index);

%% Test type detection
% Get unique onsets so that we can compare them with the box data
% no_onset_period_index = no_onset_period_ms * 2;

unique_vb = getSegmentedUniqueOnsets(vb_onset_indexes);
unique_mv = getSegmentedUniqueOnsets(mv_onset_indexes);

unique_onsets_vb = round(unique(unique_vb(unique_vb >= 0)));
unique_onsets_mv = round(unique(unique_mv(unique_mv >= 0)));

% Use box data to get test type
trial_onset_index = zeros(1, trial_nbr); % 240 trials from 0 
for i = 1:trial_nbr
    trial_onset_index(i) = trial_segment{i}.sample_index;
end

box_trial_list = box_triallist;
% [test_type, vb_index, mv_index, vb_fing, mv_fing] = getTestFromBox(trial_onset_index, box_trial_list, no_onset_period_index, unique_mv, unique_vb);
[test_type, vb_index, mv_index, vb_fing, mv_fing] = getSegmentedTestType(unique_vb, unique_mv);
