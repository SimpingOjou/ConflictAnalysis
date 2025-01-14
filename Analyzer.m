%% Initialization of the data
clear all;
clc;

% Load the user defined parameters of the script
parameters;

% Compute the data
% doDetection;
% doDetectionMagnitude;
doSegmentedDetection;

% Fix not likely data with GUI
normalized_signal = signal;
ratio36 = mean(normalized_signal(:,3)) ./ mean(normalized_signal(:,6));
normalized_signal(:,3) = normalized_signal(:,3) * ratio36; % Make the signals comparable
signal_magnitude = [getMagnitude(signal(:,1:3), sampling), getMagnitude(signal(:,4:6), sampling)];
% [test_type, vb_index, mv_index, vb_fing, mv_fing] = doManualFix(test_type, vb_index, mv_index, vb_fing, mv_fing, segmentation_points_index, t, signal_magnitude);

% Get RT data
% doRTComparison;
doSegmentedRTComparison;

% Statistical analysis
doSegmentedStatisticalAnalysis;

%% Plotting

% doPlots;
doSegmentedPlots;

% Save variables into a file -> use python to do statistical analysis
% Visualize all variables
clear("box_trial_list", "cell_signal", "channel_nbr", "cutoff_low_mv",...
    "cutoff_high_mv", "data_length", "enable_plots", "filter_order_mv",...
    "h", "i", "mean_homo_rt", "mean_hetero_rt", "median_homo_rt",...
    "median_hetero_rt", "mv_alpha", "mv_baseline_th", "mv_onset_indexes",...
    "no_onset_period_ms", "p_hetero", "p_homo", ...
    "plot_tkeo_lims", "plot_tkeo", "plot_rt_by_type", "plot_rt", ...
    "plot_raw_lims", "plot_raw", "plot_ps_lims", "plot_acc_vs_box_violin",...
    "plot_ps", "plot_histogram", "ratio36", "ratio_mean", "ratio_median",...
    "ratio_vb_mv", "signal", "signal_ch_name", "tkeo_movement_envelope",...
    "tkeo_movement", "tkeo_vibration_envelope", "tkeo_vibration",...
    "tkeo_window_size", "total_trials", "trial_length", "trial_nbr", ...
    "trial_onset_index", "trial_segment", "unique_mv", "unique_onsets_mv",...
    "unique_onsets_vb", "unique_vb", "vb_alpha", "vb_baseline_th", ...
    "vb_cutoff_low", "vb_cutoff_high", "vb_filter_order", "vb_onset_indexes",...
    "vibration_time_ms", "W");
% save(output_filename, '-v6');

%% TODO
% get info about the previous type too
% test out on 2nd run
% write like a methods section

% for each subject, i want the rt ratio (mean/median) between hetero and homotopic between response fingers -> check normality
% i get a conflict score (homo rt vs etero rt -> t: 4/1 and 3/2) score for each subject. I want something relative, not absolute
% Extract a metric for the variaibility around the mean
% Coefficient of variation: how much trials vary depending on the mean
% Make sure to segment all trials correctly
% Analyze all data for every subject

% 1 and 4 are same response finger but different vibration finger
% y response. What is y? 
% index finger d2 corresponds to b
% pinky d5 corresponds to y
% 1 = FDI vb and ADM mv
% 2 = ADM vb and FDI mv

% sequence influences conflict (switch makes slower (look into the run before))
% program t.c. find onset vb and response -> segment response type -> 20 subj

% doDetectionMagnitude;

% doRTComparison;

% plot_RT_by_type(rt_acc, acc_test_type, box_presstime, box_triallist, box_null_value);

% figure in python -> file format (csv)
% almost always ok to use median -> sw test in python too
% add a guideline for the looks of the GUI
% analyze reesponse box if wanted
% do box statistics and compare with acceleration data