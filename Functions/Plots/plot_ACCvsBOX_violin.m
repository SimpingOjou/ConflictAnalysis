function plot_ACCvsBOX_violin(rt_acc, acc_test_type, box_presstime, box_triallist, box_null_value)
    % Violin plot for data distribution
    test_types = unique(acc_test_type);

    num_tests = length(test_types);
    num_cols = 2; % Number of columns for subplots
    num_rows = ceil(num_tests / num_cols); % Number of rows for subplots

    figure('Name', 'Violin plots for all test types');

    for i = 1:num_tests
        subplot(num_rows, num_cols, i);

        % Extract the data for the current test
        current_rt = rt_acc(acc_test_type == i);
        current_box_rt = box_presstime(box_presstime ~= box_null_value & box_triallist == i);

        % Ensure both datasets are column vectors
        current_rt = current_rt(:);
        current_box_rt = current_box_rt(:);

        % Create grouping variables
        xgroupdata1 = categorical(repelem("Acc", length(current_rt), 1));
        xgroupdata2 = categorical(repelem("Box", length(current_box_rt), 1));

        % Combine data and grouping into a table
        tbl = table([xgroupdata1; xgroupdata2], ...
                    [current_rt; current_box_rt], ...
                    'VariableNames', ["Group", "Values"]);

        % Plot violin plot using the table
        violinplot(tbl, "Group", "Values");
        hold on;

        % Calculate mean and standard deviation
        mean_acc = mean(current_rt);
        std_acc = std(current_rt);
        mean_box = mean(current_box_rt);
        std_box = std(current_box_rt);

        % Plot mean and standard deviation bars
        errorbar(1, mean_acc, std_acc, 'o', 'LineWidth', 1.5, 'Color', [0, 0.4470, 0.7410]);
        errorbar(2, mean_box, std_box, 'o', 'LineWidth', 1.5, 'Color', [0, 0.4470, 0.7410]);

        title(['Test ' num2str(i)]);
        xlabel('Test type');
        ylabel('RT [s]');
        grid on;
        hold off;
    end
end