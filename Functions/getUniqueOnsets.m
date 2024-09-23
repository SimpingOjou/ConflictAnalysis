function [result] = getUniqueOnsets(onsets, min_distance_ms)
    %GETUNIQUEONSETS get unique onsets given an array
    % Input:
    % - onset array
    % - minimum distance in ms
    % Output:
    % - unique array

    result = onsets(1);
    for i = 2:length(onsets)
        % Check that the current value is at least no_onset_period_ms distant
        % from the rest
        if all(abs(onsets(i) - result) >= min_distance_ms/1000)
            result = [result, onsets(i)]; 
        end
    end

end