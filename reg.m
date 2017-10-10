%  regression.m matlab

%% Initialization
clear ; close all; clc ;

%% Load Data
table = readtable('data.csv');
% 1st column (date)

data = table(89:220,1:24);
% clear error features
data.Events = [];
data.MaxGustSpeedKm_h = [];
data.Date = [];
% display first 5 row of  data
data(1:5,:)

% plot output vs time 
hold on ;
x = table.Date; % time vector
y1 = table.mass_aveDay_US;
y2 = table.mass_IS;
y3 = table.aveDay_Dylos_Small* 0.003; % convert to mass
y4 = table.LE_Pm10;
plot(x,y1,x,y2,x,y3,x,y4);
xlabel('Time');
ylabel('Mass (mu g) ')
title('PM_{10} Reading ')
legend('US', 'IS','DL','LE')

hold off;

fprintf('1. Run Regression on US data \n');
% Fit Linear Model with Response Variable
mdl1 = fitlm(data,'linear','ResponseVar','mass_aveDay_US');
% ...


fprintf('2. Run Regression on Internation School \n');
% change y column
%data(1:200,24) = table.
%mdl2 = fitlm(data,'linear','ResponseVar','mass_IS');
fprintf('3. Run Regression on  Dylos\n');
% change y column
%data(1:200,24) = table.
%mdl3 = fitlm(data,'linear','ResponseVar','aveDay_Dylos_Small');