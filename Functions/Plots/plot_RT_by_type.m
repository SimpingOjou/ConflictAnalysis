function plot_RT_by_type(rt_acc, acc_test_type, box_presstime, box_triallist) 
    % This function plots reaction times (RT) by test type.
    % Inputs:
    %   rt_acc - Reaction times from the accuracy test
    %   acc_test_type - Types of accuracy tests
    %   box_presstime - Reaction times from the box presentation
    %   box_triallist - List of trials for the box presentation
    % Define the unique test types
    test_types = unique(acc_test_type);

    figure('Name', 'RT by Test Type');

    % Loop through each test type and create a subplot
    for i = 1:length(test_types)
        current_rt = rt_acc(acc_test_type == i);
        current_box_rt = box_presstime(box_presstime ~= 99000 & box_triallist == i);
        
        x_acc = linspace(1, length(current_rt), length(current_rt));
        x_box = linspace(1, length(current_box_rt), length(current_box_rt));

        p_acc = polyfit(x_acc, current_rt, 1);
        fit_acc = polyval(p_acc, x_acc);

        p_box = polyfit(x_box, current_box_rt, 1);
        fit_box = polyval(p_box, x_box);
        
        subplot(2, 2, i);
        
        % Plot the reaction times
        hold on;
        plot(current_box_rt, 'o');
        plot(current_rt, 'o')
        plot(fit_box, 'LineWidth', 2)
        plot(fit_acc, 'LineWidth', 2)
        hold off;

        % Add title and labels
        title(['Test Type: ', num2str(test_types(i))]);
        legend({'box', 'acc', 'box trend', 'acc trend'});
        grid("on");
        xlabel('Test nbr [#]');
        ylabel('RT [ms]');
    end
end