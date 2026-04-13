clc;
clear;
close all;

filename = ['data/5_step_esp.txt'];
data = readmatrix(filename);

t      = data(:,1)/1000; % time(s)
ang    = data(:,2);      % joint angle(°)

%% plot angle

figure('Name','Angolo vs Tempo','Color','w');
plot(t, ang, 'b', 'LineWidth', 2);
grid on;
xlabel('Time (s)','FontSize', 15);
ylabel('Joint Angle (°)','FontSize', 15);
title('Joint Angle - ');

%% heel-strike detection

knee_filt = movmean(ang, 5);
[pks_min, locs_min] = findpeaks(-knee_filt, ...
    'MinPeakDistance', 150);

toe_off_idx = locs_min;
toe_off_time = t(toe_off_idx);

figure;
plot(t, knee_filt, 'b', 'LineWidth', 1.5);
hold on;

plot(t(locs_min), knee_filt(locs_min), 'ro', 'MarkerSize', 8, 'LineWidth', 2);

xlabel('Tempo (s)');
ylabel('Angolo ginocchio (°)');
title('Rilevamento Heel-Strike');
legend('Angolo ginocchio', 'Heel-Strike');
grid on;

%% Gait segmentation (Heel Strike -> Heel Strike)

hs_idx = locs_min;   % heel strike
num_steps = 2;      % numero passi che vuoi

cycles = cell(num_steps,1);
cycles_time = cell(num_steps,1);

for i = 1:num_steps+1
    idx1 = hs_idx(i);
    idx2 = hs_idx(i+1);
    
    cycles{i} = ang(idx1:idx2);
    cycles_time{i} = t(idx1:idx2) - t(idx1); % tempo che parte da 0
end

figure;
hold on;
for i = 1:num_steps+1
    plot(cycles_time{i}, cycles{i});
end
xlabel('Tempo (s)');
ylabel('Angolo ginocchio (°)');
title('Segmentazione passi (Heel Strike -> Heel Strike)');
grid on;

%% Gait normalization 0-100%

num_steps = length(cycles);   % numero cicli
cycles_norm = zeros(num_steps, 100);

for i = 1:num_steps
    cycle = cycles{i};
    
    % normalizzazione a 100 punti
    cycles_norm(i,:) = interp1(1:length(cycle), cycle, linspace(1,length(cycle),100));
end

figure;
hold on;
for i = 1:num_steps
    plot(linspace(0,100,100), cycles_norm(i,:));
end
xlabel('% Gait Cycle');
ylabel('Angolo ginocchio (°)');
title('Gait cycles normalizzati');
grid on;

