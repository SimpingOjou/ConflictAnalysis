% doRTComparison - Perform all necessary computations for comparing box and found RTs.
%
% This function is designed to handle all the comparison tasks required
%   - Print accuracy of the test type detection
%   - Print the average RT values
%   - Print the average RT values based on test type
%
% Syntax: 
%   doRTComparison
%%% 

%% Printing the RT values
total_trials = test_type == box_triallist;
correct_nbr = length(total_trials(total_trials==1));
incorrect_nbr = length(total_trials(total_trials==0));

fprintf('\nAccuracy: %d of %d >> %f %%',correct_nbr,length(total_trials),correct_nbr/length(total_trials)*100);
fprintf('Not sure guesses: %d of %d >> %f %%\n',incorrect_nbr,length(total_trials),incorrect_nbr/length(total_trials)*100);
fprintf('-------------------------------------------------------------------');

% RT comparison with box data
rt_acc_index = mv_index - vb_index;
rt_acc = t(rt_acc_index) * 1000;

fprintf('\nAverage rt | Accelerometer: %f ms | Box: %f ms', mean(rt_acc), mean(box_presstime(box_presstime ~= box_null_value)));
fprintf('-------------------------------------------------------------------');

% Divide rt based on test type
acc_test_type = test_type(test_type ~= 0);

for i = 1:4
    fprintf('\nAverage rt (test %d) | Accelerometer: %f ms | Box: %f ms', i, mean(rt_acc(acc_test_type == i)), mean(box_presstime(box_presstime ~= box_null_value & box_triallist == i)));
    fprintf('-------------------------------------------------------------------');
end
