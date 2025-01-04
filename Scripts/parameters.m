% Load accelerometer data
accelerometer = load("acc_run1.mat");
sampling = accelerometer.samples_per_second;
cell_signal = accelerometer.channels;
data_length = length(cell_signal{1}.data);
channel_nbr = length(cell_signal);
signal = zeros(data_length, channel_nbr); % Transform cell to matrix
signal_ch_name = zeros(channel_nbr, length(cell_signal{1}.name));
for i = 1:channel_nbr
    signal(:,i) = cell_signal{i}.data;
    signal_ch_name(i,:) = cell_signal{i}.name;
end
signal_ch_name = char(signal_ch_name);
trial_segment = accelerometer.event_markers;
trial_nbr = length(trial_segment);
t = linspace(0, data_length/2, data_length) / 1000;
trial_length = 2; % Length of each trial in seconds
segmentation_points = 0:trial_length:t(end)-2;

% Load box data
box_data = load('1330_1_2021_Jul_13_1449_V_cued_r_time.mat');
box_presstime = box_data.presstime;
box_triallist = box_data.triallist;
box_null_value = 99; % Value used in the box data to indicate no response
box_presstime(box_presstime ~= box_null_value) = box_presstime(box_presstime ~= box_null_value) * 1000 + 200;
box_presstime = round(box_presstime); % Round to the nearest integer

output_filename = strcat("1330_1_2021_Jul_13_1449", ".mat");
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
vibration_time_ms = 180; % Vibration duration in ms
vb_cutoff_low = 120;%220;%120; % Low cutoff frequency for vibration detection (Hz)
vb_cutoff_high = 130;%230;%130; % High cutoff frequency for vibration detection (Hz)
vb_filter_order = 6; % Filter order for vibration detection
vb_alpha = 0.7; % Multiplier for standard deviation. Used for onset detection for vibration. Higher value means more strict onset detection

% Plot flags
enable_plots = 0; % Enable plots if 1 otherwise 0

plot_raw = 1; % Plot raw data if 1 otherwise 0
plot_raw_lims = [450, 482; -0.1, 1]; % [xmin, xmax; ymin, ymax], if empty, default values are used [s]

plot_ps = 0; % Plot power spectrum if 1 otherwise 0
plot_ps_lims = [0, 400; 0, 10]; % [xmin, xmax; ymin, ymax], if empty, default values are used

plot_tkeo = 1; % Plot TKEO data if 1 otherwise 0
plot_tkeo_lims = [70, 90; -1e-4, 15e-4]; % [xmin, xmax; ymin, ymax], if empty, default values are used

plot_rt = 1; % Plot RT coparison if 1 otherwise 0

plot_rt_by_type = 1; % Plot RT comparison by test type if 1 otherwise 0

plot_acc_vs_box_violin = 1; % Plot violin plot acc vs box if 1 otherwise 0

plot_histogram = 1; % Plot histogram if 1 otherwise 0