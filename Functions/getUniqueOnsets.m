function [result] = getUniqueOnsets(onsets, min_distance_ms)
    % GETUNIQUEONSETS Get unique onsets given an array
    % Input:
    % - onsets: cell array where each cell contains an array of onset times
    % - min_distance_ms: minimum distance in milliseconds between unique onsets
    % Output:
    % - result: array of unique onsets that are at least min_distance_ms apart

    temp = [];
    for i = 1:length(onsets)
        temp = [temp, onsets{i}'];
    end
    unique_onsets = unique(temp);

    result = unique_onsets(1);
    for i = 2:length(unique_onsets)
        % Check that the current value is at least no_onset_period_ms distant
        % from the rest
        if all(abs(unique_onsets(i) - result) >= min_distance_ms)
            result = [result, unique_onsets(i)]; 
        end
    end
end