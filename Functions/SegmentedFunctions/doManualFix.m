function [test_type, vb_index, mv_index, vb_fing, mv_fing] = doManualFix(test_type, vb_index, mv_index, vb_fing, mv_fing, segmentation_points_index, t, signal)
    % Create a GUI window for each suspicious detection 
    % and fix them manually. A unlikely detection is given 
    % through physiological parameters

    % Syntax:
    % doManualFix(test_type, vb_index, mv_index, vb_fing, mv_fing, segmentation_points_index, t)

    for i = 1:length(test_type)
        show_GUI = 0;
        current_rt = 0;

        current_mv_index = round(mv_index(i));
        current_vb_index = round(vb_index(i));
        if current_vb_index < 1 || current_mv_index < 1
            show_GUI = 1;
        else
            current_rt = t(current_mv_index) - t(current_vb_index);
            if current_rt < 0.2 || current_rt > 0.7
                show_GUI = 1;
            end
        end

        if show_GUI
            % Create a GUI window showing the signal during the current segment
            % and ask the user to fix the detection
            fig_title = sprintf('Segment %d: RT = %.2f s', i, current_rt);
            fig = figure('Name',fig_title,'NumberTitle','off');
            locStart = segmentation_points_index(i);
            locEnd = segmentation_points_index(i+1);

            subplot(2,1,1);
            plot(t(locStart:locEnd), signal(locStart:locEnd, 1));
            title(sprintf('FDI'));
            set(gca, 'XTick', []);
            
            subplot(2,1,2);
            plot(t(locStart:locEnd), signal(locStart:locEnd, 2));
            title(sprintf('ADM'))

            uicontrol('Parent', fig, 'Style', 'pushbutton', ...
                'String', 'Next', 'Units', 'normalized',...
                'Position', [0.8 0.01 0.1 0.05], ...
                'Callback', 'uiresume(gcbf)');
            uiwait(fig);
            close(fig);
        end
    end
end