function plot_Segmented_raw(signal, t, raw, unique_onsets_vb, unique_onsets_mv, raw_lims, signal_ch_name, segmentation_points)
    % This function plots the raw signal for given signal.
    % 
    % Inputs:
    %   signal - a cell array containing channel information
    %   t - a vector containing time values [s]
    %   raw - a matrix containing raw signal data
    %   unique_onsets_vb - a vector containing unique vibration onsets [index]
    %   unique_onsets_mv - a vector containing unique movement onsets [index]
    %   raw_lims - an optional parameter for additional customization (default: []). i.e. raw_lims = [xlim; ylim]
    %   signal_ch_name - a cell array containing channel names
    %   segmentation_points - a vector containing segmentation points [s]

    if isempty(raw_lims)
        raw_lims = [];
    end

    % segmentation_points = 0:2:t(end)-2;

    figure('Name', 'Raw Signal');
    subplot_len = length(signal_ch_name(:,1));
    if subplot_len > 2
        subplot_len = subplot_len / 2;
    end
    for i = 1:length(signal(1,:))
        subplot(subplot_len, length(signal(1,:))/2, i);
        hold on
        plot(t, raw(:,i));
        scatter(t(unique_onsets_vb), raw(unique_onsets_vb, i), 'filled', 'o');
        scatter(t(unique_onsets_mv), raw(unique_onsets_mv, i), 'filled', 'o');
        xline(segmentation_points, '--', 'HandleVisibility', 'off');
        hold off
        title(signal_ch_name(i,:) + " RAW");
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
    end
end
