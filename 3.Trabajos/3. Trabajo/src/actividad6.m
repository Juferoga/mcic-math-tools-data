%% Actividad 6 - Analisis fractal del trafico HTTP NASA (Kaggle)
%
%  Script para analizar la dependencia de rango largo (LRD) en el trafico
%  de peticiones HTTP del servidor NASA Kennedy Space Center (julio 1995).
%  Se usa como proxy del trafico transaccional de un API Gateway Cloud.
%
%  Utiliza las funciones del profesor en doc/clase/:
%    vt.m, LD.m, superplot.m, betamwm.m, vt2.m, LD2.m
%
%  y la herramienta clasificar_fractal.m de src/.

clear; close all; clc;

%% Configuracion de rutas
baseDir = fileparts(mfilename('fullpath'));
cd(baseDir);
addpath('../doc/clase');
addpath('../src');
outputDir = '../doc/actividades/actividad6/imgs';

if ~exist(outputDir, 'dir')
    mkdir(outputDir);
end

logFile = '../access.log';

%% ============================================================
%  PASO 1: Parsear access.log (formato Apache Common Log)
%% ============================================================
fprintf('--- Paso 1: Parseando access.log ---\n');
fid = fopen(logFile, 'r');
if fid == -1
    error('No se pudo abrir: %s', logFile);
end

timestamps = [];
lineCount = 0;
parseErrors = 0;

while ~feof(fid)
    line = fgetl(fid);
    if ~ischar(line), break; end
    lineCount = lineCount + 1;

    token = regexp(line, '\[(\d{2}/\w{3}/\d{4}:\d{2}:\d{2}:\d{2})', 'tokens');
    if isempty(token)
        parseErrors = parseErrors + 1;
        continue;
    end

    try
        ts = datenum(token{1}{1}, 'dd/mmm/yyyy:HH:MM:SS');
        timestamps(end+1) = ts;
    catch
        parseErrors = parseErrors + 1;
    end

    if mod(lineCount, 50000) == 0
        fprintf('  Procesadas %d lineas...\n', lineCount);
    end
end
fclose(fid);

fprintf('  Total de lineas:        %d\n', lineCount);
fprintf('  Timestamps extraidos:   %d\n', length(timestamps));
fprintf('  Errores de parseo:      %d\n', parseErrors);

%% ============================================================
%  PASO 2: Calcular inter-arrival times
%% ============================================================
fprintf('\n--- Paso 2: Calculando inter-arrival times ---\n');
timestamps = sort(timestamps);
interArrival = diff(timestamps) * 86400;  % dias -> segundos
interArrival = interArrival(interArrival > 0);

fprintf('  Muestras validas:   %d\n', length(interArrival));
fprintf('  Media:              %.4f seg\n', mean(interArrival));
fprintf('  Mediana:            %.4f seg\n', median(interArrival));
fprintf('  Desv. estandar:     %.4f seg\n', std(interArrival));

%% ============================================================
%  PASO 3: Grafica 1 - Serie de tiempo (superplot del profesor)
%% ============================================================
fprintf('\n--- Paso 3: Generando graficas ---\n');

figure('Position', [100 100 1200 400]);
superplot(1:length(interArrival), interArrival, ...
    'Serie de tiempo: Inter-arrival times del trafico HTTP NASA', ...
    'Indice de peticion', 'Tiempo entre llegadas (s)', 2, [0.2 0.4 0.8]);
hold on;
plot([1 length(interArrival)], [mean(interArrival) mean(interArrival)], ...
    'r--', 'LineWidth', 2);
legend({'Inter-arrival times', 'Media'}, 'FontSize', 12);
hold off;
print(fullfile(outputDir, 'serie_tiempo.png'), '-dpng', '-r200');
fprintf('  Guardado: serie_tiempo.png\n');
close;

%% ============================================================
%  PASO 4: Grafica 2 - Histograma vs Poisson
%% ============================================================
figure('Position', [100 100 800 500]);
h = histogram(interArrival, 100, 'Normalization', 'pdf');
h.FaceColor = [0.2 0.4 0.8];
h.EdgeColor = 'none';
hold on;
x = linspace(0, min(max(interArrival), 50), 500);
lambda = 1/mean(interArrival);
plot(x, lambda*exp(-lambda*x), 'r-', 'LineWidth', 2.5);
hold off;
title('Distribucion de inter-arrival times vs. modelo exponencial (Poisson)', 'FontSize', 16);
xlabel('Tiempo entre llegadas (s)', 'FontSize', 16, 'Interpreter', 'latex');
ylabel('Densidad de probabilidad', 'FontSize', 16, 'Interpreter', 'latex');
legend({'Datos observados', 'Modelo Poisson (sin memoria)'}, 'FontSize', 13);
set(gca, 'FontSize', 13);
set(gcf, 'Color', 'white');
xlim([0 50]);
grid on;
print(fullfile(outputDir, 'histograma.png'), '-dpng', '-r200');
fprintf('  Guardado: histograma.png\n');
close;

%% ============================================================
%  PASO 5: Diagrama Varianza-Tiempo (funcion vt del profesor)
%% ============================================================
fprintf('\n--- Paso 5: Calculando VT con vt.m ---\n');
figure;
[H_vt, Hmin_vt, Hmax_vt] = vt(interArrival);
print(fullfile(outputDir, 'diagrama_vt.png'), '-dpng', '-r200');
fprintf('  Guardado: diagrama_vt.png\n');
fprintf('  H (VT):             %.4f (%.4f < H < %.4f)\n', H_vt, Hmin_vt, Hmax_vt);
close;

%% ============================================================
%  PASO 6: Diagrama Log-Escala (funcion LD del profesor)
%% ============================================================
fprintf('\n--- Paso 6: Calculando LD con LD.m ---\n');
figure;
[H_ld, alpha] = LD(interArrival);
print(fullfile(outputDir, 'diagrama_ld.png'), '-dpng', '-r200');
fprintf('  Guardado: diagrama_ld.png\n');
fprintf('  H (LD):             %.4f\n', H_ld);
fprintf('  alpha:              %.4f\n', alpha);
close;

%% ============================================================
%  PASO 7: Clasificacion mono/multifractal
%% ============================================================
fprintf('\n--- Paso 7: Clasificacion con clasificar_fractal.m ---\n');
[H, clasificacion, R2_vt_class, R2_tau_class] = clasificar_fractal(interArrival, 0.85, 0.90);

fprintf('\n  ========== RESULTADOS ==========\n');
fprintf('  Parametro de Hurst (H):       %.4f\n', H);
fprintf('  Clasificacion:                %s\n', clasificacion);
fprintf('  R^2 Varianza-Tiempo:          %.4f\n', R2_vt_class);
fprintf('  R^2 tau(q):                   %.4f\n', R2_tau_class);

%% Guardar la figura del clasificador (4 subplots generados automaticamente)
print(fullfile(outputDir, 'clasificacion_fractal.png'), '-dpng', '-r200');
fprintf('  Guardado: clasificacion_fractal.png\n');
close;

%% ============================================================
%  PASO 8: Panel integrado
%% ============================================================
fprintf('\n--- Paso 8: Panel integrado ---\n');

figure('Position', [50 50 1400 900], 'Color', 'white');

% (1,1) Serie de tiempo
subplot(2, 2, 1);
plot(1:length(interArrival), interArrival, '.', 'MarkerSize', 0.3, 'Color', [0.2 0.4 0.8]);
hold on;
plot([1 length(interArrival)], [mean(interArrival) mean(interArrival)], 'r--', 'LineWidth', 2);
hold off;
title('Serie de tiempo', 'FontSize', 14);
xlabel('Indice de peticion', 'FontSize', 12);
ylabel('Inter-arrival (s)', 'FontSize', 12);
set(gca, 'FontSize', 11);
grid on;

% (1,2) Diagrama VT
subplot(2, 2, 2);
[H_temp, ~, ~] = vt(interArrival);
title(sprintf('Diagrama VT | H = %.4f', H_temp), 'FontSize', 14);
set(gca, 'FontSize', 11);

% (2,1) Diagrama LD
subplot(2, 2, 3);
[H_temp2, ~] = LD(interArrival);
title(sprintf('Diagrama LD | H = %.4f', H_temp2), 'FontSize', 14);
set(gca, 'FontSize', 11);

% (2,2) Histograma
subplot(2, 2, 4);
h = histogram(interArrival, 80, 'Normalization', 'pdf');
h.FaceColor = [0.2 0.4 0.8];
h.EdgeColor = 'none';
hold on;
xexp = linspace(0, 50, 500);
plot(xexp, lambda*exp(-lambda*xexp), 'r-', 'LineWidth', 2);
hold off;
title('Distribucion vs Poisson', 'FontSize', 14);
xlabel('Inter-arrival (s)', 'FontSize', 12);
ylabel('Densidad', 'FontSize', 12);
set(gca, 'FontSize', 11);
xlim([0 50]);
grid on;

sgtitle(sprintf('Analisis Fractal Completo del Trafico HTTP NASA | %s (H = %.4f)', ...
    upper(clasificacion), H), 'FontSize', 18, 'FontWeight', 'bold');

print(fullfile(outputDir, 'panel_completo.png'), '-dpng', '-r200');
fprintf('  Guardado: panel_completo.png\n');
close;

%% ============================================================
%  PASO 9: Resumen final
%% ============================================================
fprintf('\n--- RESUMEN EJECUTIVO ---\n');
fprintf('  Dataset:          NASA HTTP Access Logs\n');
fprintf('  Muestras:         %d\n', length(interArrival));
fprintf('  H (VT):           %.4f\n', H_vt);
fprintf('  H (LD):           %.4f\n', H_ld);
fprintf('  H (clasificador): %.4f\n', H);
fprintf('  Clasificacion:    %s\n', clasificacion);
fprintf('  R^2 VT:           %.4f\n', R2_vt_class);
fprintf('  R^2 tau(q):       %.4f\n', R2_tau_class);

if H > 0.5
    fprintf('\n  >> CONCLUSION: El trafico exhibe LRD fuerte.\n');
    fprintf('     Los modelos de Poisson NO son adecuados.\n');
end

fprintf('\n  Imagenes guardadas en: %s\n', outputDir);
fprintf('  Ejecuta en MATLAB/Octave: run(''actividad6.m'')\n');
