function plot_RAW(signal, t, raw, vb_onset_indexes, mv_onset_indexes, raw_lims, signal_ch_name)
    % This function plots the raw signal for given signal.
    % 
    % Inputs:
    %   signal - a cell array containing channel information
    %   t - a vector containing time values [s]
    %   raw - a matrix containing raw signal data
    %   vb_onset_indexes - a cell array containing indexes of vibration onsets
    %   mv_onset_indexes - a cell array containing indexes of movement onsets
    %   raw_lims - an optional parameter for additional customization (default: []). i.e. raw_lims = [xlim; ylim]
    %   signal_ch_name - a cell array containing channel names

    if isempty(raw_lims)
        raw_lims = [];
    end

    segmentation_points = 0:2:t(end);

    figure('Name', 'Raw Signal');
    subplot_len = length(signal_ch_name(:,1));
    if subplot_len > 2
        subplot_len = subplot_len / 2;
    end
    for i = 1:length(signal(1,:))
        subplot(subplot_len, length(signal(1,:))/2, i);
        hold on
        plot(t, raw(:,i));
        scatter(t(vb_onset_indexes{i}), raw(vb_onset_indexes{i}, i), 'filled', 'o');
        scatter(t(mv_onset_indexes{i}), raw(mv_onset_indexes{i}, i), 'filled', 'o');
        xline(segmentation_points, '--');
        hold off
        title(signal_ch_name(i,:) + " RAW");
        % legend('Signal', 'Vibration onsets', 'Movement onsets');
        xlabel('t [s]');
        ylabel('acceleration(m/s^2)');
        grid("on");
        if ~isempty(raw_lims)
            xlim(raw_lims(1,:));
            ylim(raw_lims(2,:));
        else
            ylim([-1e-2, max(raw(:,i)) / 2]);
        end
    end
end
