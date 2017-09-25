%  regression.m matlab

%% Initialization
clear ; close all; clc ;

%% Load Data
table = readtable('data.csv');
% 1st column (date)

data = table(1:200,1:24);
% clear error features
data.Events = [];
data.MaxGustSpeedKm_h = [];
data.Date = [];
% display first 5 row of  data
data(1:5,:)

fprintf('1. Run Regression on US data \n');
% Fit Linear Model with Response Variable
mdl1 = fitlm(data,'linear','ResponseVar','mass_aveDay_US');
% ...


fprintf('2. Run Regression on Internation School \n');
% change y column
data(1:200,24) = table.
%mdl2 = fitlm(data,'linear','ResponseVar','mass_IS');
fprintf('3. Run Regression on  Dylos\n');
% change y column
data(1:200,24) = table.
%mdl3 = fitlm(data,'linear','ResponseVar','aveDay_Dylos_Small');