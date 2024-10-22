function [tkeo_signal, tkeo_envelope] = getCleanSignal_tkeo(signal, window_size, channel_nbr)
    %GETCLEANSIGNAL_TKEO Return tkeo of signal and envelope
    %   Input:
    %       - signal with size (n x channel_nbr)
    %       - window_size for convolution
    %       - channel_nbr of the signal
    
    %  TKEO
    tkeo_signal = zeros(size(signal));
    for i = 1:channel_nbr
        tkeo_signal(2:end-1,i) = signal(2:end-1,i).^2 - signal(1:end-2,i).*signal(3:end,i);
    end
    
    % Enveloping
    tkeo_envelope = zeros(size(signal));
    for i = 1:channel_nbr
        tkeo_envelope(:,i) = conv(abs(tkeo_signal(:,i)), ones(window_size, 1) / window_size,"same");
    end
end