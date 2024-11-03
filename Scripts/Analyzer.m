%% Initialization of the data
clear all;
clc;

% Load the user defined parameters of the script
parameters;

% Compute the data
% [tkeo_movement_envelope, tkeo_vibration_envelope, mv_baseline_th, vb_baseline_th, trial_onset_index, test_type, vb_index, mv_index, vb_fing, mv_fing, vb_onset_indexes, mv_onset_indexes, ratio_vb_mv] = computeAll(signal, filter_order_mv, cutoff_low_mv, cutoff_high_mv, sampling, tkeo_window_size, vb_alpha, mv_alpha, no_onset_period_ms, vibration_time_ms, vb_filter_order, vb_cutoff_low, vb_cutoff_high, trial_nbr, trial_segment, box_triallist);
doDetection;

% Get RT data
doRTComparison;

%% TODO
% get info about the previous type too
% test out on 2nd run
% mean plot for all tests (butterfly plot)
% tkeo over sum of all signal
% normalize mv and vb -> get finger onset
% box onset has 200ms offset to my data. fix it
% box before acc is impossible
% see everything from acc
% point at uncertainties from tkeo
% find agnostic way to determine rt
% find too fast rts
% write like a methods section
s = signal;

% Normalize vibration and movement sizes compared to the first signal
fdi_ratio_12 = mean(s(:,1) ./ s(:,2));
fdi_ratio_13 = mean(s(:,1) ./ s(:,3));
adm_ratio_45 = mean(s(:,4) ./ s(:,5));
adm_ratio_46 = mean(s(:,4) ./ s(:,6));

summated_signal = zeros(length(s), 2);
summated_signal(:,1) = s(:,1) + s(:,2)./fdi_ratio_12 + s(:,3)./fdi_ratio_13;
summated_signal(:,2) = s(:,4) + s(:,5)./adm_ratio_45 + s(:,6)./adm_ratio_46;

cutoff_low = 1; 
cutoff_high = 400; 
filter_order = 1;

[b, a] = butter(filter_order, [cutoff_low/(sampling/2), cutoff_high/(sampling/2)], 'bandpass');

summated_signal_raw = filtfilt(b, a , summated_signal);

figure()
for i = 1:length(summated_signal(1,:))
    subplot(2, 1, i);
    hold on
    plot(t, summated_signal_raw(:,i));
    scatter(t(vb_onset_indexes{i}), summated_signal_raw(vb_onset_indexes{i}, i), 'filled', 'o');
    scatter(t(mv_onset_indexes{i}), summated_signal_raw(mv_onset_indexes{i}, i), 'filled', 'o');
    hold off
    title(signal_ch_name(i,:) + " RAW");
    legend('summated_signal_raw', 'Vibration onsets', 'Movement onsets');
    xlabel('t [s]');
    ylabel('acceleration (m/s^2)');
    grid("on");
    xlim(plot_raw_lims(1,:));
    ylim(plot_raw_lims(2,:));
end

%% Plotting
if enable_plots
    if plot_raw
        % Raw signal
        cutoff_low = 1; 
        cutoff_high = 300; 
        filter_order = 1;

        [b, a] = butter(filter_order, [cutoff_low/(sampling/2), cutoff_high/(sampling/2)], 'bandpass');

        raw = filtfilt(b, a , signal);

        plot_RAW(signal, t, raw, vb_onset_indexes, mv_onset_indexes, plot_raw_lims, signal_ch_name);
    end

    if plot_ps
        % FFT of the raw signal
        power_spectrum = abs(fft(signal)).^2 ./ data_length;
        f = (1:length(power_spectrum)) * sampling / length(power_spectrum);

        plot_PS(f, power_spectrum, plot_ps_lims, signal_ch_name);
    end

    if plot_tkeo
        plot_TKEO(t, tkeo_movement_envelope, tkeo_vibration_envelope, vb_onset_indexes, mv_onset_indexes, ratio_vb_mv, mv_baseline_th, vb_baseline_th, plot_tkeo_lims);
    end

    if plot_rt
        plot_RT(rt_acc, box_presstime, box_null_value);
    end

    if plot_rt_by_type
        plot_RT_by_type(rt_acc, acc_test_type, box_presstime, box_triallist, box_null_value);
    end
end

summated_ps = abs(fft(summated_signal)).^2 ./ data_length;
f = (1:length(summated_ps)) * sampling / length(summated_ps);
titles = ["FDI"; "ADM"];
plot_PS(f, summated_ps, plot_ps_lims, titles);

% filter at 400?