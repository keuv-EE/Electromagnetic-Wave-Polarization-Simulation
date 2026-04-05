%% Electromagnetic Wave Polarization Simulation
% Field: E(z,t) = (Ex * ax + Ey * ay) * exp(-i*beta*z)
% Polarization analyzed in the XY plane as a function of time (z=0)
% Ex and Ey can be complex: E = |E| * exp(i*phi)
%
% PROPAGATION DIRECTION: +z (wave traveling toward the observer)
% POLARIZATION CONVENTION: IEEE (engineering/antenna standard)
%   - Right-hand polarization: sin(Δφ) < 0 (clockwise rotation when
%     looking against propagation, i.e., from +z toward the origin)
%   - Left-hand polarization:  sin(Δφ) > 0
%   - Reference: IEEE Std 145-2013 (definition of polarization)

clear; clc; close all;

%% Simulation parameters
f = 1e9;           % Frequency (Hz)
w = 2*pi*f;        % Angular frequency (rad/s)
T = 1/f;           % Period (s)
t = linspace(0, T, 500);  % Time vector (one period)

%% Definition of complex fields Ex and Ey
% ==================== ACTIVE COMBINATION ====================
% Ex = 1.0;                              % Amplitude of Ex (real, phase 0°)
% Ey = 0.6 * exp(1i * (-pi/3));          % Ey (amplitude 0.6, phase -60°)

Ex = 1 + 2i;                              % Amplitude of Ex
Ey = 1 - 1i;          % Ey = 0 (linear horizontal polarization)

%% Extract amplitude and phase of each component
Ex_amp = abs(Ex);
Ex_phase = angle(Ex);
Ey_amp = abs(Ey);
Ey_phase = angle(Ey);

% Phase difference (phase_y - phase_x)
phase_diff = Ey_phase - Ex_phase;

%% Compute instantaneous fields
Ex_t = Ex_amp * cos(w*t + Ex_phase);
Ey_t = Ey_amp * cos(w*t + Ey_phase);

%% Determine polarization type
polarization_type = determine_polarization(Ex_amp, Ey_amp, phase_diff);

%% Display parameters
fprintf('\n========== SIMULATION PARAMETERS ==========\n');
fprintf('Frequency: %.2e Hz\n', f);
fprintf('Period: %.2e s\n', T);
fprintf('\nComplex field components (z=0):\n');
fprintf('E_x = %.3f + %.3fi = %.3f * exp(i*%.2f°)\n', ...
    real(Ex), imag(Ex), Ex_amp, Ex_phase*180/pi);
fprintf('E_y = %.3f + %.3fi = %.3f * exp(i*%.2f°)\n', ...
    real(Ey), imag(Ey), Ey_amp, Ey_phase*180/pi);
fprintf('\nPhase difference (Δφ = φ_y - φ_x): %.2f°\n', phase_diff*180/pi);
fprintf('Polarization type: %s\n', polarization_type);
fprintf('==============================================\n\n');

%% Create main figure
figure('Name', 'Polarization Analysis', 'Position', [100, 100, 1400, 900]);

% Subplot 1: Polarization trajectory (XY plane)
subplot(2, 3, 1);
plot(Ex_t, Ey_t, 'b-', 'LineWidth', 2);
hold on;
plot(Ex_t(1), Ey_t(1), 'ro', 'MarkerSize', 10, 'MarkerFaceColor', 'r');
plot(Ex_t(end), Ey_t(end), 'gs', 'MarkerSize', 10, 'MarkerFaceColor', 'g');
num_arrows = 12;
idx_arrows = round(linspace(1, length(t), num_arrows));
quiver(Ex_t(idx_arrows(1:end-1)), Ey_t(idx_arrows(1:end-1)), ...
       diff(Ex_t(idx_arrows)), diff(Ey_t(idx_arrows)), ...
       0.2, 'Color', 'k', 'LineWidth', 1.5, 'MaxHeadSize', 0.8);
axis equal;
grid on;
xlabel('E_x (V/m)', 'FontSize', 11);
ylabel('E_y (V/m)', 'FontSize', 11);
title({'Polarization Trajectory'; polarization_type}, 'FontSize', 12, 'FontWeight', 'bold');
max_limit = max([Ex_amp, Ey_amp]) * 1.2;
if max_limit == 0; max_limit = 1.2; end
xlim([-max_limit, max_limit]);
ylim([-max_limit, max_limit]);
legend({'Trajectory', 'Start (t=0)', 'End (t=T)'}, 'Location', 'best');
hold off;

% Subplot 2: Temporal components
subplot(2, 3, 2);
plot(t/T, Ex_t, 'r-', 'LineWidth', 2);
hold on;
plot(t/T, Ey_t, 'b-', 'LineWidth', 2);
plot(t/T, sqrt(Ex_t.^2 + Ey_t.^2), 'k--', 'LineWidth', 1.5);
xlabel('t / T (periods)', 'FontSize', 11);
ylabel('Electric Field (V/m)', 'FontSize', 11);
title('Components E_x(t) and E_y(t)', 'FontSize', 12, 'FontWeight', 'bold');
legend({'E_x(t)', 'E_y(t)', '|E(t)|'}, 'Location', 'best');
grid on;
xlim([0, 1]);
hold off;

% Subplot 3: Phase diagram (Lissajous) - CORRECTED
subplot(2, 3, 3);
plot(Ex_t, Ey_t, 'b-', 'LineWidth', 2);
hold on;
fill(Ex_t, Ey_t, 'b', 'FaceAlpha', 0.1);
axis equal;
grid on;
xlabel('E_x (V/m)', 'FontSize', 11);
ylabel('E_y (V/m)', 'FontSize', 11);
title('Lissajous Figure', 'FontSize', 12, 'FontWeight', 'bold');
% Use the same max limit for both axes
max_limit_liss = max(Ex_amp, Ey_amp) * 1.2;
if max_limit_liss == 0; max_limit_liss = 1.2; end
xlim([-max_limit_liss, max_limit_liss]);
ylim([-max_limit_liss, max_limit_liss]);
hold off;

% Subplot 4: 3D field evolution
subplot(2, 3, 4);
plot3(Ex_t, Ey_t, t/T, 'b-', 'LineWidth', 1.5);
hold on;
plot3(Ex_t(1), Ey_t(1), t(1)/T, 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'r');
plot3(Ex_t(end), Ey_t(end), t(end)/T, 'go', 'MarkerSize', 8, 'MarkerFaceColor', 'g');
xlabel('E_x (V/m)', 'FontSize', 11);
ylabel('E_y (V/m)', 'FontSize', 11);
zlabel('t / T', 'FontSize', 11);
title('3D Temporal Evolution', 'FontSize', 12, 'FontWeight', 'bold');
grid on;
view(45, 30);
hold off;

% Subplot 5: Parameters panel
subplot(2, 3, 5);
axis off;
info_text = { ...
    'FIELD PARAMETERS'; '';
    sprintf('|E_x| = %.3f V/m', Ex_amp);
    sprintf('∠E_x  = %.2f°', Ex_phase*180/pi);
    '';
    sprintf('|E_y| = %.3f V/m', Ey_amp);
    sprintf('∠E_y  = %.2f°', Ey_phase*180/pi);
    '';
    sprintf('Δφ = ∠E_y - ∠E_x = %.2f°', phase_diff*180/pi);
    '';
    sprintf('Polarization: %s', polarization_type);
    '';
    'Characteristic relations:';
    '• Linear:   Δφ = 0° or ±180°';
    '• Circular: |E_x| = |E_y| and Δφ = ±90°';
    '• Elliptical: other cases';
    '• Right-hand: sin(Δφ) < 0';
    '• Left-hand:  sin(Δφ) > 0'};
text(0.1, 0.95, info_text, 'Units', 'normalized', ...
     'FontSize', 10, 'VerticalAlignment', 'top', ...
     'BackgroundColor', [0.95, 0.95, 0.95], ...
     'EdgeColor', 'k', 'LineWidth', 1);

% Subplot 6: Animation
subplot(2, 3, 6);
for k = 1:20:length(t)
    plot(Ex_t(1:k), Ey_t(1:k), 'b-', 'LineWidth', 2);
    hold on;
    plot(Ex_t(k), Ey_t(k), 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'r');
    text(0.05, 0.95, sprintf('t = %.2f T', t(k)/T), ...
         'Units', 'normalized', 'FontSize', 10, ...
         'BackgroundColor', 'white');
    axis equal;
    grid on;
    xlabel('E_x (V/m)', 'FontSize', 11);
    ylabel('E_y (V/m)', 'FontSize', 11);
    title(['Animation: ', polarization_type], 'FontSize', 12, 'FontWeight', 'bold');
    xlim([-max_limit, max_limit]);
    ylim([-max_limit, max_limit]);
    drawnow;
    pause(0.05);
    if k < length(t); cla; end
end
hold off;

%% Additional figure: Polarization comparison
figure('Name', 'Polarization Comparison', 'Position', [150, 150, 1200, 800]);

test_cases = {
    'Linear (0°)', 1.0, 0.5, 0;
    'Linear (45°)', 1.0, 1.0, 0;
    'Right-hand Circular', 1.0, 1.0, -pi/2;
    'Left-hand Circular', 1.0, 1.0, pi/2;
    'Right-hand Elliptical', 1.0, 0.5, -pi/2;
    'Left-hand Elliptical', 1.0, 0.5, pi/2;
};

for idx = 1:size(test_cases, 1)
    name = test_cases{idx, 1};
    Ex_amp_test = test_cases{idx, 2};
    Ey_amp_test = test_cases{idx, 3};
    delta_test = test_cases{idx, 4};
    
    Ex_t_test = Ex_amp_test * cos(w*t);
    Ey_t_test = Ey_amp_test * cos(w*t + delta_test);
    type_test = determine_polarization(Ex_amp_test, Ey_amp_test, delta_test);
    
    subplot(2, 3, idx);
    plot(Ex_t_test, Ey_t_test, 'b-', 'LineWidth', 2);
    hold on;
    plot(Ex_t_test(1), Ey_t_test(1), 'ro', 'MarkerSize', 6, 'MarkerFaceColor', 'r');
    axis equal;
    grid on;
    xlabel('E_x');
    ylabel('E_y');
    title({name; type_test}, 'FontSize', 10);
    xlim([-1.2, 1.2]);
    ylim([-1.2, 1.2]);
    hold off;
end

%% Function to determine polarization type
function type = determine_polarization(Ex0, Ey0, phase_diff)
    tolerance_amp = 1e-6;
    tolerance_phase = 1e-6;
    
    if Ex0 < tolerance_amp && Ey0 < tolerance_amp
        type = 'Null field';
        return;
    end
    
    if abs(sin(phase_diff)) < tolerance_phase
        type = 'Linear';
        return;
    end
    
    if abs(Ex0 - Ey0) < tolerance_amp
        if sin(phase_diff) < 0
            type = 'Right-hand Circular';
        else
            type = 'Left-hand Circular';
        end
        return;
    end
    
    if sin(phase_diff) < 0
        type = 'Right-hand Elliptical';
    else
        type = 'Left-hand Elliptical';
    end
end