function plot_Segmented_TKEO(t, tkeo_movement_envelope, tkeo_vibration_envelope, unique_onsets_vb, unique_onsets_mv, ratio_vb_mv, mv_th, vb_th, tkeo_lims)
    %   This function generates a figure with subplots to visualize the TKEO (Teager-Kaiser Energy Operator) 
    %   movement and vibration envelopes for different channels. It also marks the onset points for both 
    %   movement and vibration signals and includes threshold lines for visual reference.
    %
    % INPUT
    %   t                        - Time vector
    %   tkeo_movement_envelope   - Matrix containing TKEO movement envelopes for each channel
    %   tkeo_vibration_envelope  - Matrix containing TKEO vibration envelopes for each channel
    %   unique_onsets_vb         - A vector containing unique vibration onsets [index]
    %   unique_onsets_mv         - A vector containing unique movement onsets [index]
    %   ratio_vb_mv              - Vector containing the ratio of vibration to movement for each channel
    %   mv_th                    - Vector containing movement threshold values for each channel
    %   vb_th                    - Vector containing vibration threshold values for each channel
    %   tkeo_lims                - Limits for the x and y axes in the format [x_min x_max; y_min y_max]
    %
    % OUTPUT
    %   A figure with 6 subplots, each showing the TKEO movement and vibration envelopes for a specific channel.
    %   The first three subplots correspond to FDI channels, and the next three correspond to ADM channels.

    if isempty(tkeo_lims)
        tkeo_lims = [];
    end

    figure('Name', 'TKEO Movement and Vibration Envelopes');
    subplot_len = length(tkeo_movement_envelope(1,:));
    if subplot_len > 2
        subplot_len = subplot_len / 2;
    end
    for i = 1:length(tkeo_movement_envelope(1,:))/2
        subplot(subplot_len, length(tkeo_movement_envelope(1,:))/2, i);
        ch = i;
        hold on
        plot(t, tkeo_movement_envelope(:,ch)*ratio_vb_mv(ch), t, tkeo_vibration_envelope(:,ch));
        scatter(t(unique_onsets_vb), tkeo_vibration_envelope(unique_onsets_vb, i), 'filled', 'o');
        scatter(t(unique_onsets_mv), tkeo_movement_envelope(unique_onsets_mv, i), 'filled', 'o');
        hold off
        yline(vb_th(ch),'-', 'vb threshold');
        yline(mv_th(ch),'--', 'mv threshold');
        legend({'mv tkeo', 'vb tkeo', 'vb onsets', 'mv onsets'});
        title("FDI Channel " + i)
        xlabel('t [s]');
        ylabel('Energy');
        if ~isempty(tkeo_lims)
            xlim(tkeo_lims(1,:));
            ylim(tkeo_lims(2,:));
        end
        grid("on");
    end

    for i = length(tkeo_movement_envelope(1,:))/2+1:length(tkeo_movement_envelope(1,:))
        subplot(subplot_len, length(tkeo_movement_envelope(1,:))/2, i);
        ch = i;
        hold on
        plot(t, tkeo_movement_envelope(:,ch)*ratio_vb_mv(ch), t, tkeo_vibration_envelope(:,ch));
        scatter(t(unique_onsets_vb), tkeo_vibration_envelope(unique_onsets_vb, i), 'filled', 'o');
        scatter(t(unique_onsets_mv), tkeo_movement_envelope(unique_onsets_mv, i), 'filled', 'o');
        hold off
        yline(vb_th(ch),'-', 'vb threshold');
        yline(mv_th(ch),'--', 'mv threshold');
        legend({'mv tkeo', 'vb tkeo', 'vb onsets', 'mv onsets'});
        title("ADM Channel " + i)
        xlabel('t [s]');
        ylabel('Energy');
        if ~isempty(tkeo_lims)
            xlim(tkeo_lims(1,:));
            ylim(tkeo_lims(2,:));
        end
        grid("on");
    end
end