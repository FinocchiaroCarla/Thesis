%% ESP data Analysis
% the present code is to plot simple data from sensors on board

clc;
clear;
close all;

filename = ['data/1_walk_esp.txt'];
data = readmatrix(filename);

t      = data(:,1)/1000;    %time(s)
ang    = data(:,2);         % joint angle(°) -> if you want the estimated knee angle, double this value
accX1  = data(:,3);         % accX femoral IMU(m/s^2)
accY1  = data(:,4);         % accY femoral IMU(m/s^2)
accZ1  = data(:,5);         % accZ femoral IMU(m/s^2)
accX2  = data(:,6);         % accX tibial IMU(m/s^2)
accY2  = data(:,7);         % accY tibial IMU(m/s^2)
accZ2  = data(:,8);         % accZ tibial IMU(m/s^2)
Hall   = data(:,9);         %Hall voltage
x      = data(:,10);        %displacement
torque = data(:,11);        %assistive torque

%% filtering data

ang   = movmean(ang, 10);
accX1 = movmean(accX1, 10);
accY1 = movmean(accY1, 10);
accZ1 = movmean(accZ1, 10);
accX2 = movmean(accX2, 10);
accY2 = movmean(accY2, 10);
accZ2 = movmean(accZ2, 10);
Hall  = movmean(Hall, 10);
x     = movmean(x, 10);
torque  = movmean(torque, 10);

%% simple data plot

%angle
figure('Name','Joint angle vs Time','Color','w');
plot(t, ang, 'b', 'LineWidth', 2);
grid on;
xlabel('Time (s)','FontSize', 15);
ylabel('Joint Angle (°)','FontSize', 15);
title('Joint Angle - ');

%accelerations
figure('Name','Acceleration X, Y, Z (femoral IMU) vs Time','Color','w');
subplot(3,1,1)
plot(t, accX1, 'r', 'LineWidth', 1.5);
xlim([1 7]); 
ylim([-10 20]);
xlabel('Time (s)','FontSize', 15);
ylabel('Acceleration X (m/s^2)','FontSize', 15);
grid on;

subplot(3,1,2)
plot(t, accY1, 'g', 'LineWidth', 1.5);
xlim([1 7]);
ylim([-10 20]);
xlabel('Time (s)','FontSize', 15);
ylabel('Acceleration Y (m/s^2)','FontSize', 15);
grid on;

subplot(3,1,3)
plot(t, accZ1, 'b', 'LineWidth', 1.5);
xlim([1 7]);
ylim([-10 20]);
xlabel('Time (s)','FontSize', 15);
ylabel('Acceleration Z (m/s^2)','FontSize', 15);
grid on;

figure('Name','Acceleration X, Y, Z (tibial IMU) vs Time','Color','w');
subplot(3,1,1)
plot(t, accX2, 'r', 'LineWidth', 1.5);
xlim([1 7]);
ylim([-10 20]);
xlabel('Time (s)','FontSize', 15);
ylabel('Acceleration X (m/s^2)','FontSize', 15);
grid on;

subplot(3,1,2)
plot(t, accY2, 'g', 'LineWidth', 1.5);
xlim([1 7]);
ylim([-10 20]);
xlabel('Time (s)','FontSize', 15);
ylabel('Acceleration Y (m/s^2)','FontSize', 15);
grid on;

subplot(3,1,3)
plot(t, accZ2, 'b', 'LineWidth', 1.5);
xlim([1 7]);
ylim([-10 20]);
xlabel('Time (s)','FontSize', 15);
ylabel('Acceleration Z (m/s^2)','FontSize', 15);
grid on;

%voltage
Hall_mean = mean(Hall, 'omitnan');
figure('Name','Voltage vs Time','Color','w');
plot(t, Hall, 'b', 'LineWidth', 1.5);
grid on;
hold on
plot(t, Hall_mean*ones(size(t)), 'r', 'LineWidth', 1.5)
xlabel('Time (s)','FontSize', 15);
ylabel('Voltage (V)','FontSize', 15);
title('Voltage vs Time - WALKING');

%displacement
x_mean = mean(x, 'omitnan');
figure('Name','Displacement vs Time','Color','w');
plot(t, x, 'b', 'LineWidth', 1.5);
grid on;
hold on
plot(t, x_mean*ones(size(t)), 'r', 'LineWidth', 1.5)
xlabel('Time (s)');
ylabel('Displacement (mm)');
title('Displacement vs Time');

%torque
figure('Name','Assistive Torque vs Time','Color','w');
plot(t, torque, 'b', 'LineWidth', 1.5);
grid on;
xlabel('Tempo (s)');
ylabel('Torque (Nmm)');
title('Assistive Torque vs Time');

%% torque and joint angle vs time

figure('Name','Joint angle and Torque vs Time','Color','w');
yyaxis right
plot(t, torque, 'LineWidth', 2);
ylabel('Torque (Nmm)','FontSize', 17);
xlim([1 15])
grid on

yyaxis left
plot(t, ang, 'b', 'LineWidth', 2,'Color', [0 0.45 0.74]);
ylabel('Joint Angle (°)','FontSize', 17);

xlabel('Time (s)','FontSize', 17);

title('Joint angle and Motor Torque vs Time - STS');