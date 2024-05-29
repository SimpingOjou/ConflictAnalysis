function [borders] = getBorders(data, locs, peaks)
% Finds borders given data and peaks
    
    threshold = peaks * 0.25;
    borders = zeros(length(locs),2);

    for i = 1:length(locs)
        peakPos = locs(i);
        leftBorder = find(data(1:peakPos, 1) < threshold(i), 1, 'last');
        rightBorder = find(data(peakPos:end, 1) < threshold(i), 1, 'first') + peakPos - 1;
        if isempty(leftBorder)
            leftBorder = 1;
        end
        if isempty(rightBorder)
            rightBorder = length(data(:, 1));
        end
        borders(i,:) = [leftBorder, rightBorder];
    end
end