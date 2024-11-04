% This Perform all necessary computations for the given task using the resulting magnitude of each finger.
% This function is designed to handle all the computational tasks required
% for the signal analysis project using the magnitude. 
%   - Detects vibrations and movements in the signal
%   - Detects the onset of vibrations and movements [index]
%   - Determines the test type based on the onset data
%   - Compares the result with the box data
% 
% Syntax:
%   doDetectionMagnitude

% Magnitude of the signal
signal_magnitude = zeros(length(signal), 2);
signal_magnitude(:,1) = vecnorm(signal(:,1:3), 2, 2);
signal_magnitude(:,2) = vecnorm(signal(:,4:6), 2, 2);

%% Detect features
% Movement detection
[tkeo_movement, tkeo_movement_envelope, mv_onset_indexes, mv_baseline_th] = getFeatures(signal_magnitude, filter_order_mv, cutoff_low_mv, cutoff_high_mv, sampling, tkeo_window_size, mv_alpha, no_onset_period_ms, vibration_time_ms, 0);
% Vibration detection
[tkeo_vibration, tkeo_vibration_envelope, vb_onset_indexes, vb_baseline_th] = getFeatures(signal_magnitude, vb_filter_order, vb_cutoff_low, vb_cutoff_high, sampling, tkeo_window_size, vb_alpha, no_onset_period_ms, vibration_time_ms, 1);

% Normalize vibration and movement sizes. Then remove movement from vibration
ratio_vb_mv = mean(tkeo_vibration_envelope) ./ mean(tkeo_movement_envelope);
tkeo_vibration_envelope = tkeo_vibration_envelope - tkeo_movement_envelope .* ratio_vb_mv;

vb_onset_indexes = getSignalOnset(tkeo_vibration_envelope, vb_baseline_th, no_onset_period_ms, 1, vibration_time_ms);

% plot_TKEO(t, tkeo_movement_envelope, tkeo_vibration_envelope, vb_onset_indexes, mv_onset_indexes, ratio_vb_mv, mv_baseline_th, vb_baseline_th, plot_tkeo_lims);

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

% magnitude_ps = abs(fft(signal_magnitude)).^2 ./ data_length;
% f = (1:length(magnitude_ps)) * sampling / length(magnitude_ps);
% titles = ["FDI"; "ADM"];
% plot_PS(f, magnitude_ps, plot_ps_lims, titles);

% cutoff_low = 1; 
% cutoff_high = 400; 
% filter_order = 1;

% [b, a] = butter(filter_order, [cutoff_low/(sampling/2), cutoff_high/(sampling/2)], 'bandpass');

% signal_magnitude_raw = filtfilt(b, a , signal_magnitude);

% figure()
% for i = 1:length(signal_magnitude_raw(1,:))
%     subplot(2, 1, i);
%     hold on
%     plot(t, signal_magnitude_raw(:,i));
%     scatter(t(vb_onset_indexes{i}), signal_magnitude_raw(vb_onset_indexes{i}, i), 'filled', 'o');
%     scatter(t(mv_onset_indexes{i}), signal_magnitude_raw(mv_onset_indexes{i}, i), 'filled', 'o');
%     hold off
%     title(signal_ch_name(i,:) + " RAW");
%     legend('Acceleration magnitude', 'Vibration onsets', 'Movement onsets');
%     xlabel('t [s]');
%     ylabel('acceleration (m/s^2)');
%     grid("on");
%     xlim(plot_raw_lims(1,:));
%     ylim(plot_raw_lims(2,:));
% end