% doSegmentedStatisticalAnalysis - Perform all necessary statistical analysis on the run
%
% Syntax: 
%   doSegmentedStatisticalAnalysis
%%% 

hetero_rt = rt_acc(acc_test_type == 1 | acc_test_type == 2);
homo_rt = rt_acc(acc_test_type == 3 | acc_test_type == 4);

[h, p_hetero, W] = swtest(hetero_rt);
[h, p_homo, W] = swtest(homo_rt);

if p_hetero < 0.05
    fprintf('\nHeterogeneous reaction times are skewed.');
else
    fprintf('\nHeterogeneous reaction times are normal.');
end

if p_homo < 0.05
    fprintf('\nHomogeneous reaction times are skewed.\n-------------------------------------------------------------------')
else
    fprintf('\nHomogeneous reaction times are normal.\n-------------------------------------------------------------------');
end

median_hetero_rt = median(hetero_rt);
mean_hetero_rt = mean(hetero_rt);
median_homo_rt = median(homo_rt);
mean_homo_rt = mean(homo_rt);

ratio_median = median_hetero_rt / median_homo_rt;
ratio_mean = mean_hetero_rt / mean_homo_rt;

fprintf('\nRatio of medians (hetero/homo): %.3f', ratio_median);
fprintf('\nRatio of means (hetero/homo): %.3f', ratio_mean);