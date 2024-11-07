function [onset_indexes] = getSegmentedSignalOnset(signal, threshold,...
    no_onset_period, vibration, vibration_time_ms)
    %GETSIGNALONSET Get segmented signal onset from given parameters
    %   Inputs:
    %   - signal
    %   - threshold
    %   - no_onset_period: how many ms after another possible onset
    %   - vibration: 1 if checking vibrations, 0 otherwise
    %   - vibration_time_ms: vibration time in ms
    %   Output: onset times and onset indexes

    channel_nbr = length(signal(1,:));

    if vibration == 1
        vibration_plot = vibration_time_ms * 2;
    end
    if vibration == 0
        vibration_plot = 0;
    end

    no_onset_period_plot = no_onset_period * 2; % from ms to iterations

    baseline = mean(signal) + 0.1 * std(signal);

    over_th = zeros(length(signal(:, channel_nbr)), channel_nbr);
    for i=1:channel_nbr
        over_th(:,i) = signal(:,i) > threshold(i);
    end

    onsets = over_th;
    onset_indexes = {};
    for i=1:channel_nbr
        % Iterate through each sample in the signal for the current channel
        for j = 1:length(signal(:, i))
            if onsets(j, i) == 1
                if vibration == 1
                    % Check for vibrations in the window
                    window = signal(j:j+vibration_plot, i);

                    % If any value in the window is below 0, reset the window
                    if ~isempty(find(window < 0, 1)) 
                        onsets(j:j+vibration_plot, i) = 0;
                        continue
                    end
                end

                k = j; % Initialize k to the current sample index
                % Move backwards to find the first value at baseline
                while k > 1 && signal(k, i) > baseline(i) && k > j - no_onset_period_plot
                    k = k - 1;
                end
                onsets(k, i) = 1; % Mark the onset at the baseline

                % Set values after the onset to 0 to avoid multiple detections
                onsets(k+1:k+no_onset_period_plot, i) = 0;
            end
        end
        % Store the indexes of detected onsets for the current channel
        onset_indexes{i} = find(onsets(:,i) == 1);
    end
end