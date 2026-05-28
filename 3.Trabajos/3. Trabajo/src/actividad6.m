%% Actividad 6 - Analisis fractal de la volatilidad del S&P 500
%
%  Serie analizada: volatilidad realizada |r_t| = |ln(P_t/P_{t-1})|
%  Los retornos tienen H ~ 0.5, pero la volatilidad exhibe LRD fuerte.
%
%  Utiliza: vt.m, LD.m, clasificar_fractal.m

clear; close all; clc;

%% Configuracion
baseDir = fileparts(mfilename('fullpath'));
cd(baseDir);
addpath('../doc/clase');
addpath('../src');
outputDir = '../doc/actividades/actividad6/imgs';
if ~exist(outputDir, 'dir'), mkdir(outputDir); end

%% Funcion auxiliar: forzar modo claro en cualquier figura
function forceWhite(fig)
    set(fig, 'Color', 'white');
    set(findall(fig, 'Type', 'axes'), 'Color', 'white', 'XColor', 'k', 'YColor', 'k');
    set(findall(fig, 'Type', 'legend'), 'Color', 'white', 'TextColor', 'k', 'EdgeColor', [0.5 0.5 0.5]);
    set(findall(fig, 'Type', 'text'), 'Color', 'k');
end

%% Paso 1: Leer datos
fprintf('--- Paso 1: Leyendo S&P 500 ---\n');
data = readtable('../doc/data/sp500_daily.csv', 'HeaderLines', 2, 'ReadVariableNames', false);
dates = datetime(data.Var1, 'InputFormat', 'yyyy-MM-dd');
close_prices = data.Var2;
valid = ~isnan(close_prices);
dates = dates(valid);
close_prices = close_prices(valid);
fprintf('  Periodo: %s a %s (%d dias)\n', datestr(dates(1)), datestr(dates(end)), length(close_prices));

%% Paso 2: Log-retornos y volatilidad
logReturns = diff(log(close_prices));
volatility = abs(logReturns);
nonzero = volatility > 0;
volatility = volatility(nonzero);
dates_vol = dates(2:end);
dates_vol = dates_vol(nonzero);
fprintf('  Muestras volatilidad: %d\n', length(volatility));
fprintf('  Media |r_t|: %.6f | Mediana: %.6f | Max: %.6f\n', mean(volatility), median(volatility), max(volatility));

%% Paso 3: Serie de volatilidad (modo claro, sin superplot)
fig = figure('Position', [100 100 1200 400], 'Color', 'white');
plot(dates_vol, volatility, '-', 'Color', [0.8 0.2 0.2], 'LineWidth', 0.5);
hold on;
plot([dates_vol(1) dates_vol(end)], [mean(volatility) mean(volatility)], 'b--', 'LineWidth', 2);
hold off;
title('Volatilidad diaria del S&P 500: |r_t|', 'FontSize', 16);
xlabel('Fecha', 'FontSize', 14);
ylabel('|r_t|', 'FontSize', 14);
legend({'|r_t|', 'Media'}, 'FontSize', 12);
set(gca, 'FontSize', 12);
grid on;
forceWhite(fig);
print(fullfile(outputDir, 'serie_volatilidad.png'), '-dpng', '-r200');
fprintf('  Guardado: serie_volatilidad.png\n');
close;

%% Paso 4: VT sobre retornos (para el contraste)
fig = figure('Color', 'white');
[H_ret, Hmin_ret, Hmax_ret] = vt(logReturns);
forceWhite(fig);
title(sprintf('VT sobre retornos: H = %.4f', H_ret), 'FontSize', 14, 'Color', 'k');
print(fullfile(outputDir, 'vt_retornos.png'), '-dpng', '-r200');
fprintf('  H retornos (VT): %.4f [%.4f, %.4f]\n', H_ret, Hmin_ret, Hmax_ret);
close;

%% Paso 5: Diagrama VT sobre volatilidad
fig = figure('Color', 'white');
[H_vt, Hmin_vt, Hmax_vt] = vt(volatility);
forceWhite(fig);
print(fullfile(outputDir, 'diagrama_vt.png'), '-dpng', '-r200');
fprintf('  H volatilidad (VT): %.4f [%.4f, %.4f]\n', H_vt, Hmin_vt, Hmax_vt);
close;

%% Paso 6: Diagrama LD sobre volatilidad
fig = figure('Color', 'white');
[H_ld, alpha] = LD(volatility);
forceWhite(fig);
print(fullfile(outputDir, 'diagrama_ld.png'), '-dpng', '-r200');
fprintf('  H volatilidad (LD): %.4f (alpha: %.4f)\n', H_ld, alpha);
close;

%% Paso 7: Clasificacion mono/multifractal
fprintf('\n--- Clasificacion ---\n');
[H, clasificacion, R2_vt_class, R2_tau_class] = clasificar_fractal(volatility);
fig = gcf;

% Suavizar D(h): redibujar subplot(2,2,4) con spline
ax4 = subplot(2, 2, 4);
lines = findobj(ax4, 'Type', 'line');
if ~isempty(lines)
    h_data = get(lines(end), 'XData');
    dh_data = get(lines(end), 'YData');
    % Ordenar y eliminar duplicados
    [h_data, idx] = unique(h_data);
    dh_data = dh_data(idx);
    if length(h_data) >= 3
        cla(ax4);
        h_fine = linspace(min(h_data), max(h_data), 200);
        dh_fine = interp1(h_data, dh_data, h_fine, 'pchip');
        plot(ax4, h_fine, dh_fine, '-', 'Color', [0.2 0.4 0.8], 'LineWidth', 2);
        hold(ax4, 'on');
        plot(ax4, h_data, dh_data, 'o', 'MarkerFaceColor', [0.2 0.4 0.8], ...
            'MarkerEdgeColor', 'none', 'MarkerSize', 5);
        hold(ax4, 'off');
    end
end
title(ax4, 'Espectro Multifractal $D(h)$', 'FontSize', 16, 'Interpreter', 'latex');
xlabel(ax4, '$h$', 'FontSize', 15, 'Interpreter', 'latex');
ylabel(ax4, '$D(h)$', 'FontSize', 15, 'Interpreter', 'latex');
set(ax4, 'FontSize', 13);
grid(ax4, 'on');

sgtitle(sprintf('%s  -  H = %.4f', upper(clasificacion), H), ...
    'FontSize', 18, 'FontWeight', 'bold');
forceWhite(fig);
print(fullfile(outputDir, 'clasificacion_fractal.png'), '-dpng', '-r200');
fprintf('  H: %.4f | Clasificacion: %s\n', H, clasificacion);
fprintf('  R2_VT: %.4f | R2_tau: %.4f\n', R2_vt_class, R2_tau_class);
close;

%% Paso 8: Contraste retornos vs volatilidad (modo claro, sin superplot)
fig = figure('Position', [50 50 1400 500], 'Color', 'white');

subplot(1, 2, 1);
plot(dates(2:end), logReturns, '-', 'Color', [0.2 0.4 0.8], 'LineWidth', 0.3);
title(sprintf('Log-retornos r_t  (H_{VT} = %.4f)', H_ret), 'FontSize', 14);
xlabel('Fecha', 'FontSize', 12);
ylabel('r_t', 'FontSize', 12);
set(gca, 'FontSize', 11);
grid on;

subplot(1, 2, 2);
plot(dates_vol, volatility, '-', 'Color', [0.8 0.2 0.2], 'LineWidth', 0.3);
title(sprintf('Volatilidad |r_t|  (H_{VT} = %.4f)', H_vt), 'FontSize', 14);
xlabel('Fecha', 'FontSize', 12);
ylabel('|r_t|', 'FontSize', 12);
set(gca, 'FontSize', 11);
grid on;

sgtitle('Contraste: retornos (sin memoria) vs volatilidad (LRD)', ...
    'FontSize', 16, 'FontWeight', 'bold');
forceWhite(fig);
print(fullfile(outputDir, 'contraste_ret_vol.png'), '-dpng', '-r200');
fprintf('  Guardado: contraste_ret_vol.png\n');
close;

%% Resumen
fprintf('\n========== RESUMEN ==========\n');
fprintf('  H retornos (VT):    %.4f  <-- sin memoria\n', H_ret);
fprintf('  H volatilidad (VT): %.4f  <-- LRD fuerte\n', H_vt);
fprintf('  H volatilidad (LD): %.4f\n', H_ld);
fprintf('  Clasificacion:      %s (R2_tau = %.4f)\n', clasificacion, R2_tau_class);
