function plot_RAW(channels, t, raw, f, fft_raw, vb_onset_indexes, mv_onset_indexes, raw_lims, ps_lims)
    % This function plots the raw signal and its power spectrum for given channels.
    % 
    % Inputs:
    %   channels - a cell array containing channel information
    %   t - a vector containing time values
    %   raw - a matrix containing raw signal data
    %   f - a vector containing frequency values
    %   fft_raw - a matrix containing FFT of the raw signal
    %   vb_onset_indexes - a cell array containing indexes of vibration onsets
    %   mv_onset_indexes - a cell array containing indexes of movement onsets
    %   raw_lims - an optional parameter for additional customization (default: []). i.e. raw_lims = [xlim; ylim]
    %   ps_lims - an optional parameter for additional customization (default: []). i.e. ps_lims = [xlim; ylim]

    if isempty(raw_lims)
        raw_lims = [];
    end
    if isempty(ps_lims)
        ps_lims = [[0, 400]; [0, 10]];
    end

    figure('Name', 'Raw Signal and Power Spectrum (Channels 1-3)');
    for i = 1:3
        % First subplot
        subplot(3, 3, i);
        hold on
        plot(t, raw(:,i));
        scatter(t(vb_onset_indexes{i}), raw(vb_onset_indexes{i}, i), 'filled', 'o');
        scatter(t(mv_onset_indexes{i}), raw(mv_onset_indexes{i}, i), 'filled', 'o');
        hold off
        title(channels{i}.name + " RAW");
        legend('Signal', 'Vibration onsets', 'Movement onsets');
        xlabel('t [s]');
        ylabel('acceleration(m/s^2)');
        grid("on");
        if ~isempty(raw_lims)
            xlim(raw_lims(1,:));
            ylim(raw_lims(2,:));
        else
            ylim([-1e-2, max(raw(:,i)) / 2]);
        end

        % Second subplot
        subplot(3,3,i+3);
        hold on 
        plot(f, fft_raw(:,i))
        hold off

        title(channels{i}.name + " PS")
        ylabel('Magnitude')
        xlabel('fz [Hz]')
        grid("on")
        legend("Raw")
        if ~isempty(ps_lims)
            xlim(ps_lims(1,:));
            ylim(ps_lims(2,:));
        end
    end

    figure('Name', 'Raw Signal and Power Spectrum (Channels 4-6)');
    for i = 4:6
        % First subplot
        subplot(3, 3, i-3);
        hold on
        plot(t, raw(:,i));
        scatter(t(vb_onset_indexes{i}), raw(vb_onset_indexes{i}, i), 'filled', 'o');
        scatter(t(mv_onset_indexes{i}), raw(mv_onset_indexes{i}, i), 'filled', 'o');
        hold off
        title(channels{i}.name + " RAW");
        legend('Signal', 'Vibration onsets', 'Movement onsets');
        xlabel('t [s]');
        ylabel('acceleration(m/s^2)');
        grid("on");
        if ~isempty(raw_lims)
            xlim(raw_lims(1,:));
            ylim(raw_lims(2,:));
        else
            ylim([-1e-2, max(raw(:,i)) / 2]);
        end

        % Second subplot
        subplot(3,3,i);
        hold on 
        plot(f, fft_raw(:,i))
        hold off

        title(channels{i}.name + " PS")
        ylabel('Magnitude')
        xlabel('fz [Hz]')
        grid("on")
        legend("Raw")
        if ~isempty(ps_lims)
            xlim(ps_lims(1,:));
            ylim(ps_lims(2,:));
        end
    end
    
end