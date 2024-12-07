function plot_ACC_by_test_violin(rt_acc, acc_test_type)
    % Violin plot for data distribution
    test_types = unique(acc_test_type);
    num_tests = length(test_types);

    figure('Name', 'Accelerometer violin plots');

    all_groups = [];
    all_values = [];
    means = [];
    stds = [];
    group_positions = [];

    for i = 1:num_tests
        % Extract the data for the current test
        current_rt = rt_acc(acc_test_type == test_types(i));

        % Ensure the dataset is a column vector
        current_rt = current_rt(:);

        % Calculate mean and standard deviation
        means = [means; mean(current_rt)];
        stds = [stds; std(current_rt)];

        % Create grouping variable
        groupname = ['Trial ' num2str(test_types(i))];
        xgroupdata = categorical(cellstr(repelem(groupname, length(current_rt), 1))); % Convert to cellstr

        % Append data to the arrays
        all_groups = [all_groups; xgroupdata];
        all_values = [all_values; current_rt];
        group_positions = [group_positions; i]; % Position for overlaying mean/std
    end

    % Combine data and grouping into a table
    tbl = table(all_groups, all_values, 'VariableNames', ["Group", "Values"]);

    % Plot violin plot using the table
    violinplot(tbl, "Group", "Values");
    title('Accelerometer violin plots');
    xlabel('Test type');
    ylabel('RT [s]');
    grid on;
    hold on;

    % Overlay mean and standard deviation
    errorbar(group_positions, means, stds, 'o', 'LineWidth', 1.5, 'MarkerSize', 8, 'CapSize', 10, 'Color', [0, 0.4470, 0.7410]);
    
    % legend('Location', 'best');
    hold off;
end
