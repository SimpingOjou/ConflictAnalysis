function [test_type, vb_index, mv_index] = getTestFromBox(trial_onset_index,...
    box_trial_list, timeframe, mv_onset, vb_onset)
%GETTESTFROMBOX returns the test type (1,2,3,4,0), the vb index and the mv
% index
%   Detailed explanation goes here

    if length(trial_onset_index) == length(box_trial_list)
        data_length = length(trial_onset_index);
    else
        disp("Issue with trial and box lengths")
        return
    end

    test_type = zeros(1,data_length);
    vb_index = [];
    mv_index = [];
    for i = 1:data_length

        [vibration, movement] = getChannels(box_trial_list(i));

        if trial_onset_index(i) == 0
           trial_onset_index(i) = 1;
        end
        
        % If in the trial time there is a vibration and an onset, then 
        % it is a acceptable test
        sgn = trial_onset_index(i):trial_onset_index(i)+timeframe;
        [vibration_found, temp_vb] = look_for_match(sgn, vb_onset);

        sgn = trial_onset_index(i):trial_onset_index(i)+timeframe;
        [movement_found, temp_mv] = look_for_match(sgn, mv_onset);

        % Ensure that vibration is before movement
        % if there is a match save it. Otherwise say idk
        if (vibration_found == movement_found) && (vibration_found == 1) 
            if temp_vb < temp_mv
                if vibration == [1,2,3] & movement == [4,5,6]
                    test_type(i) = 1;
                end
                if vibration == [4,5,6] & movement == [1,2,3]
                    test_type(i) = 2;
                end
                if vibration == [1,2,3] & movement == [1,2,3]
                    test_type(i) = 3;
                end
                if vibration == [4,5,6] & movement == [4,5,6]
                    test_type(i) = 4;
                end

                vb_index = [vb_index, temp_vb];
                mv_index = [mv_index, temp_mv];
            end
        end
    end

end

function [x, index] = look_for_match(signal, onsets)
    % Return true if there is a match
    for i = 1:size(signal,2)
        members = ismember(onsets, signal(:, i));
        if any(members)
            x = 1;
            index = max(onsets(members));
            return
        end
    end
    x = 0;
    index = 0;
end

function [vibration, movement] = getChannels(trial)
    switch trial
            case 1
                vibration = [1,2,3];
                movement = [4,5,6];
            case 2
                vibration = [4,5,6];
                movement = [1,2,3];
            case 3
                vibration = [1,2,3];
                movement = [1,2,3];
            case 4
                vibration = [4,5,6];
                movement = [4,5,6];
            otherwise
                disp("Box trials are not consistent")
                return
    end
end