%% Optitrack angle analysis
% with this code, we observe the time evolution of the angles formed between the markers

clc; 
clear; 
close all;

filename = 'data/1_walk_opti.csv';
fs = 240;

data = readmatrix(filename, 'NumHeaderLines', 7);

% remember to check the label from optitrack or from the code "position yz_opti.m"
p1187 = data(:, 40:42);   % femoral
p1186 = data(:, 43:45);   % joint
p1185 = data(:, 34:36);   % poly
p1188 = data(:, 37:39);   % tibial
time  = data(:, 2);       % time

% vector definition
v_fem1 = p1187 - p1186;   %femoral-joint
v_fem2 = p1187 - p1185;   %femoral-poly

v_tib1 = p1185 - p1188;   %poly-tibial
v_tib2 = p1188 - p1186;   %tibial-joint

v_joint =  p1185 - p1186; %poly-joint

% To compute angles: theta = acos( dot(a,b) / (|a|*|b|) )
num_frames = size(data, 1);

% theta1 - p1187/p1186/p1188
t1 = zeros(num_frames, 1);
for i = 1:num_frames
    dot_prod1 = dot(v_fem1(i,:), v_tib2(i,:));
    norm_prod1 = norm(v_fem1(i,:)) * norm(v_tib2(i,:));
    t1(i) = acosd(dot_prod1 / norm_prod1);
end

% theta2 - p1187/p1185/p1188
t2 = zeros(num_frames, 1);
for i = 1:num_frames
    dot_prod2 = dot(v_fem2(i,:), -v_tib1(i,:));
    norm_prod2 = norm(v_fem2(i,:)) * norm(-v_tib1(i,:));
    t2(i) = acosd(dot_prod2 / norm_prod2);
end

% theta3 - p1187/p1186/p1185
t3 = zeros(num_frames, 1);
for i = 1:num_frames
    dot_prod3 = dot(v_fem1(i,:), v_joint(i,:));
    norm_prod3 = norm(v_fem1(i,:)) * norm(v_joint(i,:));
    t3(i) = acosd(dot_prod3 / norm_prod3);
end

% theta4 - p1188/p1185/p1186
t4 = zeros(num_frames, 1);
for i = 1:num_frames
    dot_prod4 = dot(v_tib1(i,:), v_joint(i,:));
    norm_prod4 = norm(v_tib1(i,:)) * norm(v_joint(i,:));
    t4(i) = acosd(dot_prod4 / norm_prod4);
end

figure('Color', 'w');
plot(time, t1, 'LineWidth', 1.5, 'Color', [0, 0.447, 0.741]);
grid on;
hold on;
plot(time, t2, 'LineWidth', 1.5, 'Color', [0.850, 0.325, 0.098]);
xlabel('Time (s)','FontSize', 17);
ylabel('Knee Angle (°)','FontSize', 17);
xlim([0 5]);
legend('θ1', 'θ2','FontSize', 17);

figure('Color', 'w');
plot(time, t3, 'LineWidth', 1.5, 'Color', [0, 0.447, 0.741]);
grid on;
hold on;
plot(time, t4, 'LineWidth', 1.5, 'Color', [0.850, 0.325, 0.098]);
hold on;
xlabel('Time (s)','FontSize', 17);
ylabel('Joint Angle (°)','FontSize', 17);
xlim([0 5]);
legend('θ3', 'θ4','FontSize', 17);