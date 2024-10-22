%% Initialization of the data
clear all;

% Accelerometer data
accelerometer = load("acc_run1.mat");
sampling = accelerometer.samples_per_second;
channels = accelerometer.channels;
data_length = length(channels{1}.data);
channel_nbr = length(channels);
segments = accelerometer.event_markers;
trial_nbr = length(segments);
t = linspace(0, data_length/2, data_length) / 1000;

% Box data
box_data = load('1330_1_2021_Jul_13_1449_V_cued_r_time.mat');
box_data.presstime = round(box_data.presstime * 1000); % ms to s
box_presstime = box_data.presstime;
box_triallist = box_data.triallist;

clear("accelerometer", "box_data");

%% Parameters for tuning of the analysis
tkeo_window_size = 0.05*sampling; % sliding window size for TKEO https://www.ncbi.nlm.nih.gov/pmc/articles/PMC2945630/
no_onset_period_ms = 1800; % Slightly less than actual test time (2000 ms) to avoid errors. It is used to avoid multiple onsets for the same movement or vibration

% Movement detection parameters
cutoff_low_mv = 1; % Low cutoff frequency for movement detection (Hz)
cutoff_high_mv = 10; % High cutoff frequency for movement detection (Hz), 10 Hz is around the maximum of non-trained human movement
filter_order_mv = 1; % Filter order for movement detection
mv_alpha = 1; % Multiplier for standard deviation. Used for onset detection for movement. Higher value means more strict onset detection

% Vibration detection parameters
vibration_time_ms = 150; % Vibration duration in ms
vb_cutoff_low = 120; % Low cutoff frequency for vibration detection (Hz)
vb_cutoff_high = 130; % High cutoff frequency for vibration detection (Hz)
vb_filter_order = 6; % Filter order for vibration detection
vb_alpha = 0.7; % Multiplier for standard deviation. Used for onset detection for vibration. Higher value means more strict onset detection

% Plot flags
enable_plots = 1; % Enable plots if 1 otherwise 0

plot_raw = 1; % Plot raw data if 1 otherwise 0
plot_raw_lims = [70, 90; -0.1, 1]; % [xmin, xmax; ymin, ymax], if empty, default values are used

plot_ps = 1; % Plot power spectrum if 1 otherwise 0
plot_ps_lims = [0, 400; 0, 10]; % [xmin, xmax; ymin, ymax], if empty, default values are used

plot_tkeo = 1; % Plot TKEO data if 1 otherwise 0
plot_tkeo_lims = [70, 90; -1e-4, 15e-4]; % [xmin, xmax; ymin, ymax], if empty, default values are used

plot_rt = 1; % Plot RT coparison if 1 otherwise 0

%% Detect features
% Movement detection
[tkeo_movement, tkeo_movement_envelope, mv_onset_indexes, mv_baseline_th] = getFeatures(channels, filter_order_mv, cutoff_low_mv, cutoff_high_mv, sampling, data_length, tkeo_window_size, mv_alpha, no_onset_period_ms, vibration_time_ms, 0);
% Vibration detection
[tkeo_vibration, tkeo_vibration_envelope, vb_onset_indexes, vb_baseline_th] = getFeatures(channels, vb_filter_order, vb_cutoff_low, vb_cutoff_high, sampling, data_length, tkeo_window_size, vb_alpha, no_onset_period_ms, vibration_time_ms, 1);

% normalize vibration and movement sizes
ratio_vb_mv = mean(tkeo_vibration_envelope) ./ mean(tkeo_movement_envelope);
tkeo_vibration_envelope = tkeo_vibration_envelope - tkeo_movement_envelope .* ratio_vb_mv;

vb_onset_indexes = getSignalOnset(tkeo_vibration_envelope, vb_baseline_th, no_onset_period_ms, channel_nbr, 1, vibration_time_ms);

%% Test type detection
% Get unique onsets so that we can compare them with the box data
no_onset_period_index = no_onset_period_ms * 2;

unique_vb = getUniqueOnsets(vb_onset_indexes, no_onset_period_index);
unique_mv = getUniqueOnsets(mv_onset_indexes, no_onset_period_index);

% Use box data to get test type
trial_onset_index = zeros(1,trial_nbr); % 240 trials from 0 
for i = 1:trial_nbr
    trial_onset_index(i) = segments{i}.sample_index;
end

box_trial_list = box_triallist;
[test_type, vb_index, mv_index] = getTestFromBox(trial_onset_index, box_trial_list, no_onset_period_index, unique_mv, unique_vb);

%% Accuracy check
total_trials = test_type == box_triallist;
correct_nbr = length(total_trials(total_trials==1));
incorrect_nbr = length(total_trials(total_trials==0));

fprintf('\nAccuracy: %d of %d >> %f %%',correct_nbr,length(total_trials),correct_nbr/length(total_trials)*100);
fprintf('\nNot sure guesses: %d of %d >> %f %%',incorrect_nbr,length(total_trials),incorrect_nbr/length(total_trials)*100);

%% RT comparison with box data
rt_acc_index = mv_index - vb_index;
rt_acc = t(rt_acc_index) * 1000;

fprintf('\nAverage accelerometer rt: %f ms', mean(rt_acc));
fprintf('\nAverage box rt: %f ms', mean(box_presstime(box_presstime ~= 99000)));

% compare between response types
% get info about the previous type too
% test out on 2nd run

%% Plotting

if enable_plots
    if plot_raw
        % Raw signal
        cutoff_low = 1; 
        cutoff_high = 300; 
        filter_order = 1;

        [b, a] = butter(filter_order, [cutoff_low/(sampling/2), cutoff_high/(sampling/2)], 'bandpass');

        raw = zeros(data_length, channel_nbr);
        for i = 1:channel_nbr
            raw(:,i) = filtfilt(b, a , channels{i}.data);
        end

        plot_RAW(channels, t, raw, vb_onset_indexes, mv_onset_indexes, plot_raw_lims);
    end

    if plot_ps
        % FFT
        fft_raw = zeros(data_length, channel_nbr);
        for i = 1:channel_nbr
            fft_raw(:, i) = abs(fft(channels{i}.data)).^2 ./ data_length;
        end

        f = (1:length(fft_raw)) * sampling / length(fft_raw);

        plot_PS(channels, f, fft_raw, plot_ps_lims);
    end

    if plot_tkeo
        plot_TKEO(t, tkeo_movement_envelope, tkeo_vibration_envelope, vb_onset_indexes, mv_onset_indexes, ratio_vb_mv, mv_baseline_th, vb_baseline_th, plot_tkeo_lims);
    end

    if plot_rt
        plot_RT(rt_acc, box_presstime);
    end
end