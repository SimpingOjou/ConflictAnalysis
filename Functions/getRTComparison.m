function getRTComparison(test_type, box_triallist, box_presstime, box_null_value, mv_index, vb_index, t)
    %% Printing the RT values
    total_trials = test_type == box_triallist;
    correct_nbr = length(total_trials(total_trials==1));
    incorrect_nbr = length(total_trials(total_trials==0));

    fprintf('\nAccuracy: %d of %d >> %f %%',correct_nbr,length(total_trials),correct_nbr/length(total_trials)*100);
    fprintf('Not sure guesses: %d of %d >> %f %%\n',incorrect_nbr,length(total_trials),incorrect_nbr/length(total_trials)*100);
    fprintf('-------------------------------------------------------------------');

    % RT comparison with box data
    box_presstime(box_presstime ~= box_null_value) = box_presstime(box_presstime ~= box_null_value) * 1000 + 200; % add vibration duration delay & s to ms
    box_presstime = round(box_presstime); % convert presstime to seconds

    rt_acc_index = mv_index - vb_index;
    rt_acc = t(rt_acc_index) * 1000;

    fprintf('\nAverage rt | Accelerometer: %f ms | Box: %f ms', mean(rt_acc), mean(box_presstime(box_presstime ~= box_null_value)));
    fprintf('-------------------------------------------------------------------\n');

    % Divide rt based on test type
    acc_test_type = test_type(test_type ~= 0);

    for i = 1:4
        fprintf('\nAverage rt (test %d) | Accelerometer: %f ms | Box: %f ms', i, mean(rt_acc(acc_test_type == i)), mean(box_presstime(box_presstime ~= box_null_value & box_triallist == i)));
        fprintf('-------------------------------------------------------------------\n');
    end
end