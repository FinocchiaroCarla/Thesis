%% Synchronized Comparative Analysis
% With this code, we are able to observe the correspondence between the angle measured 
% by the onboard AS5600 and the corresponding angle estimated by the OptiTrack system.

clc; 
clear; 
close all;

%% optitrack data
filename_opti = 'data/4_sts_opti.csv';
opts = detectImportOptions(filename_opti);
opts.VariableNamingRule = 'preserve';
opts.DataLines = [8, Inf];
fullData = readtable(filename_opti, opts);

% remember to change marker mapping, if needed
p_pol = fullData{:, 40:42};
p_gin = fullData{:, 37:39};
p_cos = fullData{:, 34:36};

fs_opti = 240;
numFrames = size(fullData, 1);
t_opti = (0:numFrames-1)' / fs_opti;

ang_opti = nan(numFrames, 1);

for t = 1:numFrames
    if ~any(isnan(p_cos(t,:))) && ~any(isnan(p_gin(t,:))) && ~any(isnan(p_pol(t,:)))
        
        v_thigh = p_cos(t,:) - p_gin(t,:);
        v_link  = p_pol(t,:) - p_gin(t,:);
        
        cosTheta = dot(v_thigh, v_link) / (norm(v_thigh) * norm(v_link));
        ang_opti(t) = 180 - acosd(max(min(cosTheta, 1), -1));
    end
end

%% ESP data
filename_esp = 'data/4_sts_esp.txt';
data_esp = readmatrix(filename_esp);

t_ms_raw = data_esp(:,1);
delta_timeline = 0.4;
t_esp = ((t_ms_raw - t_ms_raw(1)) / 1000) + delta_timeline;

ang_esp = data_esp(:,2);

%% 3. STATISTICAL ANALYSIS (Standard Deviation)
std_opti = std(ang_opti, 'omitnan');
std_esp  = std(ang_esp, 'omitnan');

%% 4. VISUALIZATION (Single Plot with Dual Y-Axis)
figure('Color', 'w', 'Units', 'normalized', 'Position', [0.1 0.2 0.8 0.6]);
hold on; grid on;

% --- LEFT AXIS: OPTITRACK ---
yyaxis left
plot(t_opti, ang_opti, 'LineWidth', 2, 'Color', [0, 0.447, 0.741]);
ylabel('OptiTrack: θ3 angle (°)','FontSize', 18);
set(gca, 'YColor', [0, 0.447, 0.741]);

% --- RIGHT AXIS: ESP ---
yyaxis right
plot(t_esp, ang_esp, 'LineWidth', 1.5, 'Color', [0.85, 0.32, 0.1]);
ylabel('ESP: joint angle (°)','FontSize', 18);
set(gca, 'YColor', [0.85, 0.32, 0.1]);

% Plot formatting
title('Synchronized Comparison', 'FontSize', 18);
xlabel('Time (s)','FontSize', 18);
xlim([0, max(t_opti)]);

% Display statistics
fprintf('Statistical Analysis (current data):\n');
fprintf('OptiTrack Std Dev: %.2f°\n', std_opti);
fprintf('ESP Std Dev (shifted): %.2f°\n', std_esp);

% Axis limits
yyaxis left
ylim([-10 80])

yyaxis right
ylim([-10 80])