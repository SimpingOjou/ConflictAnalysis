%% Initialization of the data
clear all;
clc;

% Load the user defined parameters of the script
parameters;

% Compute the data
% [tkeo_movement_envelope, tkeo_vibration_envelope, mv_baseline_th, vb_baseline_th, trial_onset_index, test_type, vb_index, mv_index, vb_fing, mv_fing, vb_onset_indexes, mv_onset_indexes, ratio_vb_mv] = computeAll(signal, filter_order_mv, cutoff_low_mv, cutoff_high_mv, sampling, tkeo_window_size, vb_alpha, mv_alpha, no_onset_period_ms, vibration_time_ms, vb_filter_order, vb_cutoff_low, vb_cutoff_high, trial_nbr, trial_segment, box_triallist);
doAllComputing;

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
% s = [signal{1}.data', signal{2}.data', signal{3}.data', signal{4}.data', signal{5}.data', signal{6}.data'];
% % Normalize all signals relative to signal{1}.data

% % Calculate the mean and standard deviation of signal{1}.data
% mean_signal1 = mean(signal{1}.data);
% std_signal1 = std(signal{1}.data);

% % Normalize all signals relative to signal{1}.data
% normalized_signal = (s - mean_signal1) ./ std_signal1;

% avg_fdi = mean([normalized_signal(:,1), normalized_signal(:,2), normalized_signal(:,3)], 2)';
% avg_fdm = mean([normalized_signal(:,4), normalized_signal(:,5), normalized_signal(:,6)], 2)';
% avg_raw = [avg_fdi, avg_adm];

% cutoff_low = 1; 
% cutoff_high = 300; 
% filter_order = 1;

% [b, a] = butter(filter_order, [cutoff_low/(sampling/2), cutoff_high/(sampling/2)], 'bandpass');

% avg_raw = filtfilt(b, a , avg_raw);

% figure()
% len = length(avg_raw(1,:));
% for i = 1:len
%     subplot(len, len/2, i);
%     hold on
%     plot(t, avg_raw(:,i));
%     scatter(t(vb_onset_indexes{i}), avg_raw(vb_onset_indexes{i}, i), 'filled', 'o');
%     scatter(t(mv_onset_indexes{i}), avg_raw(mv_onset_indexes{i}, i), 'filled', 'o');
%     hold off
%     title(signal{i+2}.name + " RAW");
%     legend('Avg_raw', 'Vibration onsets', 'Movement onsets');
%     xlabel('t [s]');
%     ylabel('acceleration(m/s^2)');
%     grid("on");
%     xlim(plot_raw_lims(1,:));
%     ylim(plot_raw_lims(2,:));
% end

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
        % FFT
        power_spectrum = abs(fft(signal)).^2 ./ data_length;

        f = (1:length(power_spectrum)) * sampling / length(power_spectrum);

        plot_PS(signal, f, power_spectrum, plot_ps_lims, signal_ch_name);
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