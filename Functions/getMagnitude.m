% Function to get the magnitude of the signal between the 3 channels
function [output_signal] = getMagnitude(signal)
    % Filter the signal
    cutoff_low = 1; 
    cutoff_high = 300; 
    filter_order = 1;

    [b, a] = butter(filter_order, [cutoff_low/(sampling/2), cutoff_high/(sampling/2)], 'bandpass');

    signal = filtfilt(b, a , signal);
    
    % Calculate the magnitude of the signal
    output_signal = sqrt(sum(signal.^2, 2));
end