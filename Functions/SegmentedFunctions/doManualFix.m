function [test_type, vb_index, mv_index, vb_fing, mv_fing] = doManualFix(test_type, vb_index, mv_index, vb_fing, mv_fing, segmentation_points_index, t, signal)
    % Create a GUI window for each suspicious detection 
    % and fix them manually. A unlikely detection is given 
    % through physiological parameters

    % Syntax:
    % doManualFix(test_type, vb_index, mv_index, vb_fing, mv_fing, segmentation_points_index, t)

    for i = 1:length(test_type)
        current_rt = t(mv_index(i)) - t(vb_index(i));
        if current_rt < 0.2 || current_rt > 0.7
            % Create a GUI window showing the signal during the current segment
            % and ask the user to fix the detection
            fig = figure('Name','Manual Fix','NumberTitle','off');
            locStart = segmentation_points_index(i);
            locEnd = segmentation_points_index(i+1);
            plot(t(locStart:locEnd), signal(locStart:locEnd));
            title(sprintf('Segment %d: RT = %.2f s', i, current_rt));
            uicontrol('Parent', fig, 'Style', 'pushbutton', ...
                'String', 'Next', 'Units', 'normalized',...
                'Position', [0.45 0.05 0.1 0.05], ...
                'Callback', 'uiresume(gcbf)');
            uiwait(fig);
            close(fig);
        end
    end
end
