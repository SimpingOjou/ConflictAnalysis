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
% see everything from acc
% point at uncertainties from tkeo
% find agnostic way to determine rt
% find too fast rts
% write like a methods section
% manually count bc i don't trust the code
% compound vibration signal
% if both fingers no vb -> skip test

% doDetectionMagnitude;

% doRTComparison;

% plot_RT_by_type(rt_acc, acc_test_type, box_presstime, box_triallist, box_null_value);