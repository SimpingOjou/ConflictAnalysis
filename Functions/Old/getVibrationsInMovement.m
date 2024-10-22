function [indexes] = getVibrationsInMovement(locs,border_locs)
% returns vibration indexes not in movement given vibration locs and movement borders
% locs
    
    indexes = [];

    for i = 1:length(locs)
        for j = 1:length(border_locs)
            start = border_locs(j,1);
            finish = border_locs(j,2);
    
            if locs(i) > start && locs(i) < finish
                indexes = [indexes, i];
                break
            end
        end
    end

end