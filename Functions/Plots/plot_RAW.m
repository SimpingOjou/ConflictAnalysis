function plot_RAW(signal, t, raw, vb_onset_indexes, mv_onset_indexes, raw_lims)
    % This function plots the raw signal for given signal.
    % 
    % Inputs:
    %   signal - a cell array containing channel information
    %   t - a vector containing time values
    %   raw - a matrix containing raw signal data
    %   vb_onset_indexes - a cell array containing indexes of vibration onsets
    %   mv_onset_indexes - a cell array containing indexes of movement onsets
    %   raw_lims - an optional parameter for additional customization (default: []). i.e. raw_lims = [xlim; ylim]

    if isempty(raw_lims)
        raw_lims = [];
    end

    figure('Name', 'Raw Signal');
    for i = 1:length(signal)
        subplot(length(signal)/2, length(signal)/2, i);
        hold on
        plot(t, raw(:,i));
        scatter(t(vb_onset_indexes{i}), raw(vb_onset_indexes{i}, i), 'filled', 'o');
        scatter(t(mv_onset_indexes{i}), raw(mv_onset_indexes{i}, i), 'filled', 'o');
        hold off
        title(signal{i}.name + " RAW");
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
