% ACTIVIDAD 6 — Venta de boletería Independiente Santa Fe
% Basado en actividad3.m, actividad4.m y actividad5.m del curso
%
% Escenarios:
%   1. Liga regular:        k=5,  lambda=20,  mu=4.0
%   2. Clásico Millonarios: k=10, lambda=60,  mu=3.0
%   3. Final de Copa:       k=15, lambda=100, mu=2.0
%   4. Súper-clásico:       k=20, lambda=150, mu=2.5
%
% Metodología (como enseñó el profe):
%   - Generar datos sintéticos (interarribos y servicios exponenciales)
%   - Graficar: CDF empírica, PDF/histograma, QQ-plot vs exponencial
%   - Simular M/M/k/k con mmkk.m
%   - Comparar simulación vs teoría Erlang-B
%   - Curvas de sensibilidad B(k,a) vs lambda
%   - Dimensionamiento óptimo de taquillas

clear; clc; close all;

% Directorio de salida para figuras
outDir = '../doc/plots/act_6_santafe';
if ~exist(outDir, 'dir')
    mkdir(outDir);
end

%% ============================================================
% ESCENARIOS SANTA FE
%% ============================================================
escenarios = struct();
escenarios(1).nombre = 'Liga regular';
escenarios(1).k = 5;
escenarios(1).lambda = 20;
escenarios(1).mu = 4.0;
escenarios(1).n = 30000;

escenarios(2).nombre = 'Clásico Millonarios';
escenarios(2).k = 10;
escenarios(2).lambda = 60;
escenarios(2).mu = 3.0;
escenarios(2).n = 50000;

escenarios(3).nombre = 'Final de Copa';
escenarios(3).k = 15;
escenarios(3).lambda = 100;
escenarios(3).mu = 2.0;
escenarios(3).n = 80000;

escenarios(4).nombre = 'Súper-clásico';
escenarios(4).k = 20;
escenarios(4).lambda = 150;
escenarios(4).mu = 2.5;
escenarios(4).n = 100000;

nEsc = numel(escenarios);

%% ============================================================
% 1. GENERAR DATOS Y GRAFICAR: CDF, PDF, QQ-PLOT
%    (Metodología del profe — Actividad 4)
%% ============================================================
fprintf('=== GENERANDO DATOS Y GRÁFICAS BÁSICAS (CDF, PDF, QQ-PLOT) ===\n');

for i = 1:nEsc
    esc = escenarios(i);
    lam = esc.lambda;
    mu = esc.mu;
    n = esc.n;

    % Generar datos sintéticos (igual que en actividad2.m y actividad3.m)
    tiempoentrearribos = exprnd(1/lam, n, 1);
    tiemposdeservicio = exprnd(1/mu, n, 1);

    % Guardar datos para uso posterior
    datos_interarribos{i} = tiempoentrearribos;
    datos_servicios{i} = tiemposdeservicio;

    % --- Figura: CDF, PDF, QQ-plot ---
    figure('Position', [100, 100, 1200, 900]);
    t = tiledlayout(2, 2, 'Padding', 'compact', 'TileSpacing', 'compact');
    title(t, sprintf('Análisis de distribución — %s (\\lambda=%.0f, \\mu=%.1f)', ...
        esc.nombre, lam, mu), 'FontWeight', 'bold', 'FontSize', 13);

    % 1.1 PDF/Histograma de interarribos + densidad exponencial teórica
    nexttile;
    histogram(tiempoentrearribos, 60, 'Normalization', 'pdf', ...
        'FaceColor', [0.2, 0.4, 0.6], 'EdgeColor', 'none', 'FaceAlpha', 0.7);
    hold on;
    x_max = max(tiempoentrearribos);
    xs = linspace(0, x_max, 200);
    pdf_teo = lam * exp(-lam * xs);
    plot(xs, pdf_teo, 'r-', 'LineWidth', 2);
    xlabel('Tiempo entre llegadas (min)');
    ylabel('Densidad');
    title('PDF: Interarribos vs Exponencial');
    legend('Empírico', sprintf('Exp(\\lambda=%.0f)', lam), 'Location', 'best');
    grid on;

    % 1.2 CDF empírica de interarribos + CDF teórica
    nexttile;
    [f_emp, x_emp] = ecdf(tiempoentrearribos);
    stairs(x_emp, f_emp, 'Color', [0.2, 0.4, 0.6], 'LineWidth', 1.5);
    hold on;
    cdf_teo = 1 - exp(-lam * xs);
    plot(xs, cdf_teo, 'r-', 'LineWidth', 2);
    xlabel('Tiempo entre llegadas (min)');
    ylabel('Probabilidad acumulada');
    title('CDF: Interarribos vs Exponencial');
    legend('Empírica', sprintf('Exp(\\lambda=%.0f)', lam), 'Location', 'best');
    grid on;

    % 1.3 QQ-plot de interarribos vs exponencial (como en actividad4.m)
    nexttile;
    referencia_exp = exprnd(1/lam, size(tiempoentrearribos));
    qqplot(tiempoentrearribos, referencia_exp);
    grid on;
    title(sprintf('QQ-plot: Interarribos vs Exp(\\lambda=%.0f)', lam));
    xlabel('Cuantiles empíricos');
    ylabel('Cuantiles exponenciales');

    % 1.4 QQ-plot de servicios vs exponencial
    nexttile;
    referencia_exp_serv = exprnd(1/mu, size(tiemposdeservicio));
    qqplot(tiemposdeservicio, referencia_exp_serv);
    grid on;
    title(sprintf('QQ-plot: Servicios vs Exp(\\mu=%.1f)', mu));
    xlabel('Cuantiles empíricos');
    ylabel('Cuantiles exponenciales');

    saveas(gcf, fullfile(outDir, sprintf('validacion_%s.png', esc.nombre)));
    close(gcf);
    fprintf('    ✓ validacion_%s.png\n', esc.nombre);
end

%% ============================================================
% 2. SIMULACIÓN M/M/k/k Y COMPARACIÓN TEORÍA vs SIMULACIÓN
%    (Metodología del profe — Actividad 3 y 5)
%% ============================================================
fprintf('\n=== SIMULACIÓN Y COMPARACIÓN TEORÍA vs SIMULACIÓN ===\n');
fprintf('Escenario              | k  | lambda | mu  | a     | B_teo   | B_sim   | Diff\n');
fprintf('----------------------------------------------------------------------------\n');

B_teo = zeros(1, nEsc);
B_sim = zeros(1, nEsc);

for i = 1:nEsc
    esc = escenarios(i);
    k = esc.k;
    lam = esc.lambda;
    mu = esc.mu;
    n = esc.n;
    a = lam / mu;

    % Usar datos ya generados
    tiempoentrearribos = datos_interarribos{i};
    tiemposdeservicio = datos_servicios{i};

    % Simulación con mmkk.m (función del profe)
    Pk_sim = mmkk(tiempoentrearribos', tiemposdeservicio', k);

    % Teoría Erlang B (igual que en actividad3.m y actividad5.m)
    Pk_teo = erlangB(a, k);

    B_teo(i) = Pk_teo;
    B_sim(i) = Pk_sim;

    fprintf('%-22s | %2d | %6.1f | %3.1f | %5.2f | %7.4f | %7.4f | %.4f\n', ...
        esc.nombre, k, lam, mu, a, Pk_teo, Pk_sim, abs(Pk_teo - Pk_sim));
end

% --- Gráfica comparación barras ---
figure('Position', [100, 100, 900, 500]);
x = 1:nEsc;
width = 0.35;
b1 = bar(x - width/2, B_teo, width, 'FaceColor', [0.2, 0.4, 0.6], 'EdgeColor', 'k', 'LineWidth', 0.5);
hold on;
b2 = bar(x + width/2, B_sim, width, 'FaceColor', [0.9, 0.5, 0.3], 'EdgeColor', 'k', 'LineWidth', 0.5);
grid on;
xlabel('Escenario');
ylabel('Probabilidad de bloqueo B(k,a)');
title('Comparación: Erlang B analítico vs Simulación — Boletería Santa Fe');
set(gca, 'XTick', x, 'XTickLabel', {escenarios.nombre}, 'XTickLabelRotation', 15);
legend('Erlang B (teoría)', 'Simulación (eventos discretos)', 'Location', 'best');
ylim([0, max(max(B_teo), max(B_sim)) * 1.25]);

for i = 1:nEsc
    text(x(i)-width/2, B_teo(i)+0.02, sprintf('%.3f', B_teo(i)), ...
        'HorizontalAlignment', 'center', 'FontSize', 8);
    text(x(i)+width/2, B_sim(i)+0.02, sprintf('%.3f', B_sim(i)), ...
        'HorizontalAlignment', 'center', 'FontSize', 8);
end

saveas(gcf, fullfile(outDir, 'comparacion_bloqueo.png'));
close(gcf);
fprintf('    ✓ comparacion_bloqueo.png\n');

%% ============================================================
% 3. CURVAS B(k,a) VS λ PARA CADA ESCENARIO
%% ============================================================
fprintf('\n=== CURVAS DE ERLANG B POR ESCENARIO ===\n');

figure('Position', [100, 100, 1200, 900]);
t = tiledlayout(2, 2, 'Padding', 'compact', 'TileSpacing', 'compact');

for i = 1:nEsc
    esc = escenarios(i);
    k = esc.k;
    mu = esc.mu;
    lam_actual = esc.lambda;

    lambdas = linspace(1, k * mu * 1.5, 200);
    a_vals = lambdas / mu;
    B_vals = arrayfun(@(a) erlangB(a, k), a_vals);

    nexttile;
    plot(lambdas, B_vals, 'LineWidth', 2.5);
    hold on;
    xline(lam_actual, '--k', sprintf('\\lambda_{actual}=%.0f', lam_actual), ...
        'LineWidth', 1, 'LabelVerticalAlignment', 'bottom');
    yline(0.05, ':r', 'B_{max}=0.05', 'LineWidth', 1.2);

    B_act = erlangB(lam_actual/mu, k);
    plot(lam_actual, B_act, 'ko', 'MarkerFaceColor', 'k', 'MarkerSize', 8);
    text(lam_actual + 3, B_act + 0.05, sprintf('B=%.3f', B_act), 'FontSize', 9);

    xlabel('Tasa de llegadas \lambda (fans/min)');
    ylabel('Probabilidad de bloqueo B(k,a)');
    title(sprintf('%s — k=%d, \\mu=%.1f', esc.nombre, k, mu));
    ylim([-0.02, 1.02]);
    grid on;
end

title(t, 'Curvas de Erlang B por escenario de boletería', 'FontWeight', 'bold', 'FontSize', 13);

saveas(gcf, fullfile(outDir, 'curvas_erlang_por_escenario.png'));
close(gcf);
fprintf('    ✓ curvas_erlang_por_escenario.png\n');

%% ============================================================
% 4. DIMENSIONAMIENTO ÓPTIMO
%% ============================================================
fprintf('\n=== DIMENSIONAMIENTO ÓPTIMO ===\n');

umbrales = [0.001, 0.01, 0.05, 0.10];
nombres_umbral = {'99.9%', '99%', '95%', '90%'};

k_stars = zeros(nEsc, numel(umbrales));
for i = 1:nEsc
    a = escenarios(i).lambda / escenarios(i).mu;
    for j = 1:numel(umbrales)
        k = 1;
        while erlangB(a, k) > umbrales(j)
            k = k + 1;
            if k > 500, break; end
        end
        k_stars(i, j) = k;
    end
end

figure('Position', [100, 100, 1000, 600]);
x = 1:nEsc;
width = 0.18;
hold on;
colores_umbral = [0.13, 0.40, 0.67; 0.26, 0.58, 0.76; 0.57, 0.77, 0.87; 0.82, 0.90, 0.94];
for j = 1:numel(umbrales)
    bar(x + (j - 2.5) * width, k_stars(:, j), width, ...
        'FaceColor', colores_umbral(j, :), 'EdgeColor', 'k', 'LineWidth', 0.4, ...
        'DisplayName', sprintf('B_{max}=%s', nombres_umbral{j}));
end

k_act = [escenarios.k];
plot(x, k_act, 'rd', 'MarkerSize', 10, 'MarkerFaceColor', 'r', ...
    'DisplayName', 'k actual', 'LineWidth', 1.5);

grid on;
xlabel('Escenario');
ylabel('Número de taquillas k^*');
title('Dimensionamiento óptimo de taquillas por nivel de servicio');
set(gca, 'XTick', x, 'XTickLabel', {escenarios.nombre}, 'XTickLabelRotation', 15);
legend('Location', 'best');

saveas(gcf, fullfile(outDir, 'dimensionamiento_optimo.png'));
close(gcf);
fprintf('    ✓ dimensionamiento_optimo.png\n');

% --- Tabla en consola ---
fprintf('\nTabla de dimensionamiento:\n');
fprintf('%-22s | 99.9%% | 99%% | 95%% | 90%% | k actual\n', 'Escenario');
fprintf('---------------------------------------------------------------\n');
for i = 1:nEsc
    fprintf('%-22s | %5d | %4d | %4d | %4d | %8d\n', ...
        escenarios(i).nombre, k_stars(i, 1), k_stars(i, 2), ...
        k_stars(i, 3), k_stars(i, 4), escenarios(i).k);
end

%% ============================================================
% 5. OCUPACIÓN TEMPORAL
%% ============================================================
fprintf('\n=== OCUPACIÓN TEMPORAL ===\n');

figure('Position', [100, 100, 1300, 900]);
t = tiledlayout(2, 2, 'Padding', 'compact', 'TileSpacing', 'compact');

colores = [0.12, 0.47, 0.71; 1.0, 0.5, 0.05; 0.17, 0.63, 0.17; 0.84, 0.15, 0.16];

for i = 1:nEsc
    esc = escenarios(i);
    k = esc.k;
    lam = esc.lambda;
    mu = esc.mu;

    n_muestra = 5000;
    interarribos = exprnd(1/lam, 1, n_muestra);
    servicios = exprnd(1/mu, 1, n_muestra);

    reloj = cumsum(interarribos);
    fin_servicio = zeros(1, k);
    event_times = [];
    system_sizes = [];

    for j = 1:n_muestra
        t_arr = reloj(j);
        ocupados = fin_servicio > t_arr;
        n_ocup = sum(ocupados);

        event_times = [event_times, t_arr];
        system_sizes = [system_sizes, n_ocup];

        if n_ocup < k
            idx_libre = find(fin_servicio <= t_arr, 1, 'first');
            if isempty(idx_libre)
                [~, idx_libre] = min(fin_servicio);
            end
            fin_servicio(idx_libre) = t_arr + servicios(j);
            event_times = [event_times, t_arr];
            system_sizes = [system_sizes, n_ocup + 1];
        end
    end

    mask = event_times <= 30;
    t_w = event_times(mask);
    n_w = system_sizes(mask);

    nexttile;
    stairs(t_w, n_w, 'Color', colores(i, :), 'LineWidth', 1.0);
    hold on;
    yline(k, '--r', 'Capacidad máxima', 'LineWidth', 1);
    fill([t_w, fliplr(t_w)], [n_w, zeros(size(n_w))], colores(i, :), 'FaceAlpha', 0.15, 'EdgeColor', 'none');

    xlabel('Tiempo (min)');
    ylabel('Taquillas ocupadas');
    title(sprintf('%s (k=%d)', esc.nombre, k));
    ylim([-0.3, k + 0.8]);
    xlim([0, 30]);
    grid on;
end

title(t, 'Evolución temporal de ocupación de taquillas', 'FontWeight', 'bold', 'FontSize', 13);

saveas(gcf, fullfile(outDir, 'ocupacion_temporal_todos.png'));
close(gcf);
fprintf('    ✓ ocupacion_temporal_todos.png\n');

%% ============================================================
% FUNCIONES AUXILIARES (como en actividad3.m y actividad5.m)
%% ============================================================

function B = erlangB(A, k)
    % Fórmula de Erlang B
    n = 0:k;
    B = (A^k / factorial(k)) / sum((A.^n) ./ factorial(n));
end
