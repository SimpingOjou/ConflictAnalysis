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
    middle_hetero_rt = median(hetero_rt);
else
    fprintf('\nHeterogeneous reaction times are normal.');
    middle_hetero_rt = mean(hetero_rt);
end

if p_homo < 0.05
    fprintf('\nHomogeneous reaction times are skewed.');
    middle_homo_rt = median(homo_rt);
else
    fprintf('\nHomogeneous reaction times are normal.');
    middle_homo_rt = mean(homo_rt); 
end