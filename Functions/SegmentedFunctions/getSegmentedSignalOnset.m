function [onset_indexes] = getSegmentedSignalOnset(signal, threshold,...
    no_onset_period, vibration, vibration_time_ms, segmentation_points_index)
    %GETSIGNALONSET Get segmented signal onset from given parameters
    %   Inputs:
    %   - signal
    %   - threshold
    %   - no_onset_period: how many ms after another possible onset
    %   - vibration: 1 if checking vibrations, 0 otherwise
    %   - vibration_time_ms: vibration time in ms
    %   - segmentation_points_index: indexes of the signal segmentation points
    %   Output: onset indexes. If -1, no onset detected

    channel_nbr = length(signal(1,:));

    if vibration == 1
        vibration_plot = vibration_time_ms * 2;
    end
    if vibration == 0
        vibration_plot = 0;
    end

    no_onset_period_plot = no_onset_period * 2; % from ms to iterations

    baseline = mean(signal) + 0.1 * std(signal);

    % Store the values above the threshold
    over_th = zeros(length(signal(:, channel_nbr)), channel_nbr);
    for i=1:channel_nbr
        over_th(:,i) = signal(:,i) > threshold(i);
    end

    onsets = over_th;
    onset_indexes = ones(length(segmentation_points_index), channel_nbr);
    onset_indexes = onset_indexes * -1;
    tmp_segmentation = [segmentation_points_index, length(signal(:,1))];
    for i=1:channel_nbr
        % Iterate through each segment in the signal
        for j = 1:length(tmp_segmentation) - 1
            % Iterate through each sample in the signal trial window for the current channel
            for z = tmp_segmentation(j):tmp_segmentation(j + 1)
                if onsets(z, i) == 1
                    if vibration == 1
                        % Check for vibrations in the window
                        window = signal(z:z+vibration_plot, i);
    
                        % If any value in the window is below 0, reset the window because it is a movement
                        if ~isempty(find(window < 0, 1)) 
                            onsets(z:z+vibration_plot, i) = 0;
                            continue
                        end
                    end
    
                    k = z; % Initialize k to the current sample index
                    % Move backwards to find the first value at baseline
                    while k > 1 && signal(k, i) > baseline(i) && k > j - no_onset_period_plot
                        k = k - 1;
                    end
                    onsets(k, i) = 1; % Mark the onset at the baseline
                    onset_indexes(j, i) = k; % Store the index of the onset
    
                    % Set values after the onset to 0 to avoid multiple detections
                    onsets(k+1:k+no_onset_period_plot, i) = 0;
                end
            end
        end
    end
end