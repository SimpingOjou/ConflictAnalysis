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
            data.vb_fing = vb_fing;
            data.mv_fing = mv_fing;
            data.test_type = test_type;
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
            
            vb = '/';
            if data.vb_fing(i) == 1
                vb = 'Vibration';
            end
            mv = '/';
            if data.mv_fing(i) == 1
                mv = 'Movement';
            end
            title_text = sprintf('FDI - %s - %s', vb, mv);
            title(title_text);
            legend('Signal', 'Vibration', 'Movement', 'Location', 'north', 'Orientation', 'horizontal');
            xlabel('Time (s)');
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

            vb = '/';
            if data.vb_fing(i) == 2
                vb = 'Vibration';
            end
            mv = '/';
            if data.mv_fing(i) == 2
                mv = 'Movement';
            end
            title_text = sprintf('ADM - %s - %s', vb, mv);
            title(title_text);
            legend('Signal', 'Vibration', 'Movement', 'Location', 'north', 'Orientation', 'horizontal');
            grid on;
            hold off;

            % Update shared data
            guidata(fig, data);

            uicontrol('Parent', fig, 'Style', 'pushbutton', ...
                'String', 'Next', 'Units', 'normalized',...
                'Position', [0.8 0.01 0.1 0.05], ...
                'Callback', 'uiresume(gcbf)');
            uicontrol('Parent', fig, 'Style', 'pushbutton', ...
                'String', 'Delete', 'Units', 'normalized',...
                'Position', [0.1 0.01 0.3 0.05], ...
                'Callback', @(src, event) deleteRun(fig));
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
            test_type(i) = updateTestType(data);
        end
    end
end

function [test_type] = updateTestType(data)
    test_type = -1;
    % Update test type based on the selected onsets
    if data.vb_fing(data.index) == 1 && data.mv_fing(data.index) == 2
        test_type = 1;
    end
    if data.vb_fing(data.index) == 2 && data.mv_fing(data.index) == 1
        test_type = 2;
    end
    if data.vb_fing(data.index) == 1 && data.mv_fing(data.index) == 1
        test_type = 3;
    end
    if data.vb_fing(data.index) == 2 && data.mv_fing(data.index) == 2
        test_type = 4;
    end
end

function deleteRun(fig)
    % Retrieve shared data
    data = guidata(fig);

    % Update vibration onset
    data.vb_index(data.index) = -1;
    data.mv_index(data.index) = -1;

    % Update plot markers
    set(data.plot1vb, 'XData', NaN, 'YData', NaN); % First plot
    set(data.plot2vb, 'XData', NaN, 'YData', NaN); % Second plot
    set(data.plot1mv, 'XData', NaN, 'YData', NaN); % First plot
    set(data.plot2mv, 'XData', NaN, 'YData', NaN); % Second plot

    % Save updated data
    guidata(fig, data);
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

    % Create a popup with two tickboxes
    data.vb_fing(data.index) = createPopup(data.vb_fing(data.index));

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

    % Create a popup with two tickboxes
    data.mv_fing(data.index) = createPopup(data.mv_fing(data.index));

    % Update plot markers
    set(data.plot1mv, 'XData', data.t(idx), 'YData', data.signal(idx, 1)); % First plot
    set(data.plot2mv, 'XData', data.t(idx), 'YData', data.signal(idx, 2)); % Second plot

    % Save updated data
    guidata(fig, data);
end

function fing = createPopup(fing)
    finger = 'NONE';
    
    if fing == 1
        finger = 'FDI';
    end
    if fing == 2
        finger = 'ADM';
    end

    popup = figure('Name', 'Assign finger', 'NumberTitle', 'off', 'Position', [500, 500, 300, 150]);

    % Output Text (on top)
    output_text = sprintf('Script found finger: %s', finger);
    uicontrol('Parent', popup, 'Style', 'text', ...
            'String', output_text, ...
            'Units', 'normalized', 'Position', [0.1, 0.8, 0.8, 0.15], ...
            'HorizontalAlignment', 'left', 'FontWeight', 'bold'); % Ensures text alignment and bold font

    % FDI Checkbox (below the text)
    uicontrol('Parent', popup, 'Style', 'text', 'String', 'fdi', ...
            'Units', 'normalized', 'Position', [0.3, 0.6, 0.3, 0.1]);
    fdiCheckbox = uicontrol('Parent', popup, 'Style', 'checkbox', ...
            'Units', 'normalized', 'Position', [0.1, 0.6, 0.2, 0.1]);

    % ADM Checkbox (below FDI checkbox)
    uicontrol('Parent', popup, 'Style', 'text', 'String', 'adm', ...
            'Units', 'normalized', 'Position', [0.3, 0.4, 0.3, 0.1]);
    admCheckbox = uicontrol('Parent', popup, 'Style', 'checkbox', ...
            'Units', 'normalized', 'Position', [0.1, 0.4, 0.2, 0.1]);

    % OK Button (at the bottom)
    uicontrol('Parent', popup, 'Style', 'pushbutton', 'String', 'OK', ...
            'Units', 'normalized', 'Position', [0.4, 0.1, 0.2, 0.15], ...
            'Callback', 'uiresume(gcbf)');

    uiwait(popup);
    fdiConfirmed = get(fdiCheckbox, 'Value');
    admConfirmed = get(admCheckbox, 'Value');
    close(popup);

    % Update data based on user confirmation
    if fdiConfirmed
        fing = 1;
    end
    if admConfirmed
        fing = 2;
    end
end