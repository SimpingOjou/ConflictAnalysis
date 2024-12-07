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

% Statistical analysis
doSegmentedStatisticalAnalysis;

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

% for each subject, i want the rt ratio (mean/median) between hetero and homotopic between response fingers -> check normality
% i get a conflict score (homo rt vs etero rt -> t: 4/1 and 3/2) score for each subject. I want something relative, not absolute
% Extract a metric for the variaibility around the mean
% Coefficient of variation: how much trials vary depending on the mean
% Make sure to segment all trials correctly
% Increase accuracy. Manually insert through gui
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

