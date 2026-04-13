clc;
clear;

filename = ['data/calibration.txt'];
data = readmatrix(filename);

x = data(:,1);
voltage = data(:, 2:end);

[row_v, col_v] = size(voltage);
mean_v = zeros(row_v, 1);

for i = 1 : row_v
    mean_v(i) = mean(voltage(i,:));
end 

%% Calibration diagram  V=f(x)
figure('Name','Calibration Diagram','Color','w');
for i=1:row_v
    plot(x(i), mean_v(i), "x", "MarkerSize", 10, "LineWidth", 2.5, "HandleVisibility","off");
    hold on
end
grid on;
hold on

[fit_cal, gof1] = fit(x, mean_v, 'rat22');x

plot(fit_cal);
ylabel("Distance (mm)",'FontSize', 17);
xlabel("Voltage (V)",'FontSize', 17);
legend('Fitted calibration curve', 'FontSize', 17);
gof1 


%% Trasduction diagram x=f(V)

figure('Name','Trasduction Diagram','Color','w');
plot(mean_v, x, 'x',"MarkerSize", 10, "LineWidth", 2.5, "HandleVisibility","off")
hold on
xlabel("Voltage (V)",'FontSize', 17);
ylabel("Distance (mm)",'FontSize', 17);
grid on
hold on

[fit_trasd, gof2] = fit(mean_v, x, 'exp2');
plot(fit_trasd);
xlabel("Voltage (V)",'FontSize', 17);
ylabel("Distance (mm)",'FontSize', 17);
legend('Fitted trasduction curve', 'FontSize', 17);
gof2 %goodness of fit



save('hall_calibration.mat', 'fit_trasd');