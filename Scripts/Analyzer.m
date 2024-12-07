%% Initialization of the data
clear all;
clc;

% Load the user defined parameters of the script
parameters;

% Compute the data
% doDetection;
% doDetectionMagnitude;
doSegmentedDetection;

% Get RT data
% doRTComparison;
doSegmentedRTComparison;

%% Plotting

% doPlots;
doSegmentedPlots;

%% TODO
% get info about the previous type too
% test out on 2nd run
% normalize mv and vb -> get finger onset
% box before acc is impossible
% point at uncertainties from tkeo
% find too fast rts
% write like a methods section
% manually count bc i don't trust the code

% violin plot for data distribution
% for each subject, i want the rt ratio (mean/median) between hetero and homotopic between response fingers -> check normality
% i get a conflict score (homo rt vs etero rt -> t: 4/1 and 3/2) score for each subject. I want something relative, not absolute
% Extract a metric for the variaibility around the mean
% Coefficient of variation: how much trials vary depending on the mean
% Make sure to segment all trials correctly
% Increase accuracy. Manually insert
% Analyze all data for every subject
% 

% 1 and 4 are same response finger but different vibration finger
% y response. What is y? 
% index finger d2 corresponds to b
% pinky d5 corresponds to y
% 1 = FDI vb and ADM mv
% 2 = ADM vb and FDI mv

% doDetectionMagnitude;

% doRTComparison;

% plot_RT_by_type(rt_acc, acc_test_type, box_presstime, box_triallist, box_null_value);

% Violin plot for data distribution
% test_types = unique(acc_test_type);

% num_tests = length(test_types);
% num_cols = 2; % Number of columns for subplots
% num_rows = ceil(num_tests / num_cols); % Number of rows for subplots

% figure('Name', 'Violin plots for all test types');

% for i = 1:num_tests
%     subplot(num_rows, num_cols, i);
    
%     % Extract the data for the current test
%     current_rt = rt_acc(acc_test_type == i);
%     current_box_rt = box_presstime(box_presstime ~= box_null_value & box_triallist == i);
    
%     % Ensure both datasets are column vectors
%     current_rt = current_rt(:);
%     current_box_rt = current_box_rt(:);
    
%     % Create grouping variables
%     xgroupdata1 = categorical(repelem("Acc", length(current_rt), 1));
%     xgroupdata2 = categorical(repelem("Box", length(current_box_rt), 1));
    
%     % Combine data and grouping into a table
%     tbl = table([xgroupdata1; xgroupdata2], ...
%                 [current_rt; current_box_rt], ...
%                 'VariableNames', ["Group", "Values"]);
    
%     % Plot violin plot using the table
%     violinplot(tbl, "Group", "Values");
%     title(['Test ' num2str(i)]);
%     xlabel('Test type');
%     ylabel('RT [s]');
%     grid on;
% end

