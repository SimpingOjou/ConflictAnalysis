function [test_type, vb_index, mv_index, vb_fing, mv_fing] = doManualFix(test_type, vb_index, mv_index, vb_fing, mv_fing, segmentation_points_index, t, signal)
    % Create a GUI window for each suspicious detection 
    % and fix them manually. A unlikely detection is given 
    % through physiological parameters

    % Syntax:
    % doManualFix(test_type, vb_index, mv_index, vb_fing, mv_fing, segmentation_points_index, t)

    segmentation_points_index = [segmentation_points_index, length(signal(:,1))];

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
            disp(vb_index(i))
            disp(mv_index(i))
            % Create a GUI window showing the signal during the current segment
            % and ask the user to fix the detection
            fig_title = sprintf('Segment %d: RT = %.2f s', i, current_rt);
            fig = figure('Name',fig_title,'NumberTitle','off');
            locStart = segmentation_points_index(i);
            locEnd = segmentation_points_index(i+1);
            current_vb_index = round(vb_index(i));
            current_mv_index = round(mv_index(i));

            % Store data in GUI
            data.t = t;
            data.signal = signal;
            data.vb_index = vb_index;
            data.mv_index = mv_index;
            data.plot1vb = [];
            data.plot1mv = [];
            data.plot2vb = [];
            data.plot2mv = [];
            data.index = i;
            guidata(fig, data);

            % Plot signals
            subplot(2, 1, 1);
            hold on;
            plot(t(locStart:locEnd), signal(locStart:locEnd, 1));
            if current_vb_index > 0
                plot(t(current_vb_index), signal(current_vb_index, 1), '*', 'LineWidth', 1.5);
            end
            if current_mv_index > 0
                plot(t(current_mv_index), signal(current_mv_index, 1), '*', 'LineWidth', 1.5);
            end
            data.plot1vb = plot(NaN, NaN, '*', 'LineWidth', 1.5); % Placeholder for vibration onset
            data.plot1mv = plot(NaN, NaN, '*', 'LineWidth', 1.5); % Placeholder for movement onset
            title('Signal 1');
            legend('Signal', 'Vibration', 'Movement');
            grid on;
            hold off;

            subplot(2, 1, 2);
            hold on;
            plot(t(locStart:locEnd), signal(locStart:locEnd, 2));
            if current_vb_index > 0
                plot(t(current_vb_index), signal(current_vb_index, 2), '*', 'LineWidth', 1.5);
            end
            if current_mv_index > 0
                plot(t(current_mv_index), signal(current_mv_index, 2), '*', 'LineWidth', 1.5);
            end
            data.plot2vb = plot(NaN, NaN, '*', 'LineWidth', 1.5); % Placeholder for vibration onset
            data.plot2mv = plot(NaN, NaN, '*', 'LineWidth', 1.5); % Placeholder for movement onset
            title('Signal 2');
            legend('Signal', 'Vibration', 'Movement');
            grid on;
            hold off;

            % Update shared data
            guidata(fig, data);

            uicontrol('Parent', fig, 'Style', 'pushbutton', ...
                'String', 'Next', 'Units', 'normalized',...
                'Position', [0.8 0.01 0.1 0.05], ...
                'Callback', 'uiresume(gcbf)');
            uicontrol('Parent', fig, 'Style', 'togglebutton', ...
                'String', 'Select vibration onset', 'Units', 'normalized',...
                'Position', [0.1 0.01 0.3 0.05], ...
                'Callback', @(src, event) setVibrationOnset(fig));
            uicontrol('Parent', fig, 'Style', 'togglebutton', ...
                'String', 'Select movement onset', 'Units', 'normalized',...
                'Position', [0.4 0.01 0.3 0.05], ...
                'Callback', @(src, event) setMovementOnset(fig));
            uiwait(fig);
            data = guidata(fig); % Retrieve updated data after GUI
            close(fig);

            vb_index(i) = data.vb_index(i);
            mv_index(i) = data.mv_index(i);
            disp(data.vb_index(data.index))
            disp(data.mv_index(data.index))
        end
        
    end
end

function setVibrationOnset(fig)
    % Retrieve shared data
    data = guidata(fig);

    % Select point on plot
    [x, ~] = ginput(1);

    % Find closest index
    [~, idx] = min(abs(data.t - x));

    % Update vibration onset
    data.vb_index(data.index) = idx;

    % Update plot markers
    set(data.plot1vb, 'XData', data.t(idx), 'YData', data.signal(idx, 1)); % First plot
    set(data.plot2vb, 'XData', data.t(idx), 'YData', data.signal(idx, 2)); % Second plot

    % Save updated data
    guidata(fig, data);
end

function setMovementOnset(fig)
    % Retrieve shared data
    data = guidata(fig);

    % Select point on plot
    [x, ~] = ginput(1);

    % Find closest index
    [~, idx] = min(abs(data.t - x));

    % Update vibration onset
    data.mv_index(data.index) = idx;

    % Update plot markers
    set(data.plot1mv, 'XData', data.t(idx), 'YData', data.signal(idx, 1)); % First plot
    set(data.plot2mv, 'XData', data.t(idx), 'YData', data.signal(idx, 2)); % Second plot

    % Save updated data
    guidata(fig, data);
end
