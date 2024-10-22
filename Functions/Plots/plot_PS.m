function plot_PS(channels, f, fft_raw, ps_lims)
    % This function plots the power spectrum for given channels.
    % 
    % Inputs:
    %   channels - a cell array containing channel information
    %   f - a vector containing frequency values
    %   fft_raw - a matrix containing FFT of the raw signal
    %   ps_lims - an optional parameter for additional customization (default: []). i.e. ps_lims = [xlim; ylim]

    if isempty(ps_lims)
        ps_lims = [[0, 400]; [0, 10]];
    end

    figure('Name', 'Power Spectrum');
    for i = 1:length(channels)
        subplot(3, 3, i);
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
