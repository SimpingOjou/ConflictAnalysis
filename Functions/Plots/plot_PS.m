function plot_PS(f, fft_raw, ps_lims, signal_ch_name)
    % This function plots the power spectrum for given signal.
    % 
    % Inputs:
    %   f - a vector containing frequency values
    %   fft_raw - a matrix containing FFT of the raw signal
    %   ps_lims - an optional parameter for additional customization (default: []). i.e. ps_lims = [xlim; ylim]
    %   signal_ch_name - a cell array containing channel names

    if isempty(ps_lims)
        ps_lims = [[0, 400]; [0, 10]];
    end

    figure('Name', 'Power Spectrum');
    subplot_len = length(signal_ch_name(:,1));
    if subplot_len > 2
        subplot_len = subplot_len / 2;
    end
    for i = 1:length(signal_ch_name(:,1))
        subplot(subplot_len, length(signal_ch_name(:,1))/2, i);
        hold on 
        plot(f, fft_raw(:,i))
        hold off

        title(signal_ch_name(i,:) + " PS")
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
