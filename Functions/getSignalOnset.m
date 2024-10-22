function [onset_indexes] = getSignalOnset(signal, threshold,...
    no_onset_period, channel_nbr, vibration)
    %GETSIGNALONSET Get signal onset from given parameters
    %   Inputs:
    %   - signal
    %   - threshold
    %   - no_onset_period: how many ms after another possible onset
    %   - channel_nbr
    %   - vibration: 1 if checking vibrations, 0 otherwise
    %   Output: onset times and onset indexes
    
    vibration_time = 150; % ms
    vibration_plot = vibration_time * 2;
    baseline = mean(signal) + 0.1 * std(signal);

    over_th = zeros(length(signal(:, channel_nbr)), channel_nbr);
    for i=1:channel_nbr
        over_th(:,i) = signal(:,i) > threshold(i);
    end

    no_onset_period_plot = no_onset_period * 2; % from ms to iterations

    onsets = over_th;
    onset_indexes = {};
    for i=1:channel_nbr
        for j = 1:length(signal(:, i))
            if onsets(j, i) == 1
                if vibration == 1
                    window = signal(j:j+vibration_plot, i);

                    if ~isempty(find(window < 0, 1)) 
                        onsets(j:j+vibration_plot, i) = 0;
                        continue
                    end
                end

                k = j; % get first value at baseline
                while k > 1 && signal(k, i) > baseline(i) &&...
                        k > j - no_onset_period_plot
                    k = k - 1;
                end
                onsets(k, i) = 1;

                % put values afterwards to 0
                onsets(k+1:k+no_onset_period_plot, i) = 0;
            end
        end
        onset_indexes{i} = find(onsets(:,i) == 1);
    end
end