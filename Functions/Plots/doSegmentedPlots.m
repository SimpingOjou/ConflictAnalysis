if enable_plots
    if plot_raw
        % Raw signal
        cutoff_low = 1; 
        cutoff_high = 300; 
        filter_order = 1;

        [b, a] = butter(filter_order, [cutoff_low/(sampling/2), cutoff_high/(sampling/2)], 'bandpass');

        raw = filtfilt(b, a , signal);

        plot_Segmented_raw(signal, t, raw, unique_onsets_vb, unique_onsets_mv, plot_raw_lims, signal_ch_name, segmentation_points);
    end

    if plot_ps
        % FFT of the raw signal
        power_spectrum = abs(fft(signal)).^2 ./ data_length;
        f = (1:length(power_spectrum)) * sampling / length(power_spectrum);

        plot_PS(f, power_spectrum, plot_ps_lims, signal_ch_name);
    end

    if plot_tkeo
        plot_Segmented_TKEO(t, tkeo_movement_envelope, tkeo_vibration_envelope, unique_onsets_vb, unique_onsets_mv, ratio_vb_mv, mv_baseline_th, vb_baseline_th, plot_tkeo_lims);
    end

    if plot_rt
        plot_RT(rt_acc, box_presstime, box_null_value);
    end

    if plot_rt_by_type
        plot_RT_by_type(rt_acc, acc_test_type, box_presstime, box_triallist, box_null_value);
    end

    if plot_acc_vs_box_violin
        plot_ACCvsBOX_violin(rt_acc, acc_test_type, box_presstime, box_triallist, box_null_value);
    end

    if plot_acc_by_test_violin
        plot_ACC_by_test_violin(rt_acc, acc_test_type);
    end

    if plot_histogram
        plot_Histogram(rt_acc, acc_test_type);
    end
end