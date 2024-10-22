function plot_RT(rt_acc, cued_presstime)
    % This function plots reaction times (rt_acc) and cued presentation times (cued_presstime)
    % It also fits a linear trend to both sets of data and plots these trends.
    % Inputs:
    %   rt_acc - Reaction times (array)
    %   cued_presstime - Cued presentation times (array)
    
    x_acc = linspace(1, length(rt_acc), length(rt_acc));
    x_box = linspace(1, length(cued_presstime(cued_presstime ~= 99000)), length(cued_presstime(cued_presstime ~= 99000)));

    p_acc = polyfit(x_acc, rt_acc, 1);
    fit_acc = polyval(p_acc, x_acc);

    p_box = polyfit(x_box, cued_presstime(cued_presstime ~= 99000), 1);
    fit_box = polyval(p_box, x_box);

    figure('Name', 'Reaction Times and Cued Presentation Times')
    hold on
    plot(cued_presstime(cued_presstime ~= 99000), 'o');
    plot(rt_acc, 'o')
    plot(fit_box, 'LineWidth', 2)
    plot(fit_acc, 'LineWidth', 2)
    hold off

    legend({'box', 'acc', 'box trend', 'acc trend'});
    title('Box vs Acc RT');
    grid("on");
    xlabel('Test nbr [#]');
    ylabel('RT [ms]');
end