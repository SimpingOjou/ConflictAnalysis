function plot_Histogram(rt_acc, acc_test_type)
    test_types = unique(acc_test_type);

    num_tests = length(test_types);
    num_cols = 2; % Number of columns for subplots
    num_rows = ceil(num_tests / num_cols); % Number of rows for subplots

    figure('Name', 'Histogram of reaction times');
    for i = 1:num_tests
        % Extract the data for the current test
        current_rt = rt_acc(acc_test_type == test_types(i));

        % Ensure the dataset is a column vector
        current_rt = current_rt(:);

        subplot(num_rows, num_cols, i);
        histogram(current_rt);
        title(['Test Type: ', num2str(test_types(i))]);
        xlabel('Reaction Time');
        ylabel('Frequency');
    end
end