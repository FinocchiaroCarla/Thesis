%% Optitrack position analysis 
% with this code, we observe the time evolution of the position of the marker on YZ (sagittal) plane

filename = 'data/1_sts_opti.csv';

opts = detectImportOptions(filename);
opts.VariableNamingRule = 'preserve';
opts.DataLines = [8, Inf];
fullData = readtable(filename, opts);

% AN:AP (40-42) -> 1171 (Femoral)
% AK:AM (37-39) -> 1170 (Joint)
% AH:AJ (34-36) -> 1169 (Polycentric)
% AQ:AS (43-45) -> 1172 (Tibial)

tags(1).id = 'ID: 1185';    tags(1).cols = 40:42;
tags(2).id = 'ID: 1186';    tags(2).cols = 37:39;
tags(3).id = 'ID: 1187';    tags(3).cols = 34:36;
tags(4).id = 'ID: 1188';    tags(4).cols = 43:45;

figure('Color', 'w', 'Name', 'Traiettoria Sagittale Tag');
hold on; grid on;
colors = [0.85 0.33 0.1; 0 0.45 0.74; 0.47 0.67 0.19; 0.49 0.18 0.56];

for i = 1:4
    y_data = fullData{:, tags(i).cols(2)}; 
    z_data = fullData{:, tags(i).cols(3)};
   
    valid = ~isnan(y_data) & ~isnan(z_data);
    
    plot(z_data(valid), y_data(valid), '-', 'LineWidth', 2, ...
        'Color', colors(i,:), 'DisplayName', tags(i).id);
    
    plot(z_data(find(valid,1)), y_data(find(valid,1)), 'ko', ...
        'MarkerFaceColor', colors(i,:), 'HandleVisibility', 'off');
end

xlabel('Z (mm)','FontSize',15);
ylabel('Y (mm)','FontSize',15);
legend('Location', 'best','FontSize',15);
axis equal;
