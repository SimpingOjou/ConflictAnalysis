function [result] = getUniqueOnsets(onsets, min_distance_ms)
    % GETUNIQUEONSETS Get unique onsets given an array
    % Input:
    % - onsets: cell array where each cell contains an array of onset times
    % - min_distance_ms: minimum distance in milliseconds between unique onsets
    % Output:
    % - result: array of unique onsets that are at least min_distance_ms apart

    unique_onsets = unique([onsets{1}', onsets{2}', onsets{3}', onsets{4}', onsets{5}', onsets{6}']);

    result = unique_onsets(1);
    for i = 2:length(unique_onsets)
        % Check that the current value is at least no_onset_period_ms distant
        % from the rest
        if all(abs(unique_onsets(i) - result) >= min_distance_ms)
            result = [result, unique_onsets(i)]; 
        end
    end

end