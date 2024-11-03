function plot_PS(signal, f, fft_raw, ps_lims, signal_ch_name)
    % This function plots the power spectrum for given signal.
    % 
    % Inputs:
    %   signal - a cell array containing signal data
    %   f - a vector containing frequency values
    %   fft_raw - a matrix containing FFT of the raw signal
    %   ps_lims - an optional parameter for additional customization (default: []). i.e. ps_lims = [xlim; ylim]
    %   signal_ch_name - a cell array containing channel names

    if isempty(ps_lims)
        ps_lims = [[0, 400]; [0, 10]];
    end

    figure('Name', 'Power Spectrum');
    for i = 1:length(signal(1,:))
        subplot(3, 3, i);
        hold on 
        plot(f, fft_raw(:,i))
        hold off

        title(signal_ch_name{i} + " PS")
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
