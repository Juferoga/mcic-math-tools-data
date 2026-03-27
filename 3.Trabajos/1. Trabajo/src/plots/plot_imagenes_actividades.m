% Script para generar imágenes en fondo blanco organizadas por Actividades (4 a 7)

clear; clc;
disp('Generando imagenes por actividades...');
base_dir = 'imagenes';

% ---------------- CARGA DE DATOS CORPUS ----------------
archivos = {
    'songs/m and wav files/lhymne_a_lamour_acoustic_guitar.m', ...
    'songs/m and wav files/la_goualante_du_pauvre_jean.m', ...
    'songs/m and wav files/la_vie_en_rose_by_edith_piaf.m'
};

corpus_matrix = [];
for i = 1:3
    contenido = fileread(archivos{i});
    tokens = regexp(contenido, 'melodia\s*=\s*\[(.*?)\]', 'tokens', 'once');
    eval(['melodia_temp = [' tokens{1} '];']);
    corpus_matrix = [corpus_matrix; melodia_temp];
end
duraciones_corpus = corpus_matrix(:, 7);
S = unique(duraciones_corpus, 'sorted');
N_S = length(S);

frecuencias = zeros(N_S, 1);
for i = 1:N_S
    frecuencias(i) = sum(duraciones_corpus == S(i));
end
probabilidades = frecuencias / sum(frecuencias);
cdf_probs = cumsum(probabilidades);

% =========================================================================
% ACTIVIDAD 4: Independencia Estadística de Tiempos
% =========================================================================
disp('Generando Actividad 4...');

% 4.1 Probabilidades (La que teníamos antes)
fig1 = figure('Visible', 'off', 'Color', 'w');
bar(1:N_S, probabilidades, 'FaceColor', [0.2 0.6 0.8]);
set(gca, 'XTick', 1:N_S, 'XTickLabel', strtrim(cellstr(num2str(S, '%g'))), 'Color', 'w', 'XColor', 'k', 'YColor', 'k');
xtickangle(45); 
title('Distribución de Probabilidades de Tiempos Relativos', 'Color', 'k');
xlabel('Duración', 'Color', 'k'); ylabel('Probabilidad', 'Color', 'k'); grid on;
exportgraphics(fig1, fullfile(base_dir, 'actividad4/act4_1_probabilidades.png'), 'Resolution', 300);
close(fig1);

% 4.2 CDF (Función de Distribución Acumulada usada para generación aleatoria)
fig2 = figure('Visible', 'off', 'Color', 'w');
stairs(1:N_S, cdf_probs, 'LineWidth', 2.5, 'Color', [0.8 0.3 0.3]);
set(gca, 'XTick', 1:N_S, 'XTickLabel', strtrim(cellstr(num2str(S, '%g'))), 'Color', 'w', 'XColor', 'k', 'YColor', 'k');
xtickangle(45); 
title('Función de Distribución Acumulada (CDF) de Tiempos', 'Color', 'k');
xlabel('Duración', 'Color', 'k'); ylabel('Probabilidad Acumulada', 'Color', 'k'); grid on;
exportgraphics(fig2, fullfile(base_dir, 'actividad4/act4_2_cdf_tiempos.png'), 'Resolution', 300);
close(fig2);

% 4.3 Comparativa Original vs Aleatoria Uniforme
cont_f2 = fileread('fase2/fase2_la_vie_en_rose_by_edith_piaf.m');
tok_f2 = regexp(cont_f2, 'melodia\s*=\s*\[(.*?)\]', 'tokens', 'once');
eval(['f2_mat = [' tok_f2{1} '];']);
f2_dur = f2_mat(1:min(50,size(f2_mat,1)), 7);

cont_orig = fileread(archivos{3});
tok_orig = regexp(cont_orig, 'melodia\s*=\s*\[(.*?)\]', 'tokens', 'once');
eval(['orig_mat = [' tok_orig{1} '];']);
orig_dur = orig_mat(1:min(50,size(orig_mat,1)), 7);

fig3 = figure('Visible', 'off', 'Color', 'w', 'Position', [100,100,1000,400]);
plot(orig_dur, '-o', 'LineWidth', 1.5, 'DisplayName', 'Original'); hold on;
plot(f2_dur, '-x', 'LineWidth', 1.5, 'DisplayName', 'Aleatorio (Act 4)');
title('Comparación de Tiempos: Original vs Generación Aleatoria (50 notas)', 'Color', 'k');
xlabel('Índice de Nota', 'Color', 'k'); ylabel('Duración', 'Color', 'k'); 
legend('Location', 'best'); grid on;
set(gca, 'Color', 'w', 'XColor', 'k', 'YColor', 'k');
exportgraphics(fig3, fullfile(base_dir, 'actividad4/act4_3_comparacion_aleatoria.png'), 'Resolution', 300);
close(fig3);

% =========================================================================
% ACTIVIDAD 5: Markov sobre Tiempos Relativos
% =========================================================================
disp('Generando Actividad 5...');
P3 = zeros(N_S, N_S);
for s = 1:3
    cont = fileread(archivos{s});
    tok = regexp(cont, 'melodia\s*=\s*\[(.*?)\]', 'tokens', 'once');
    eval(['mat = [' tok{1} '];']);
    dur = mat(:, 7);
    for i = 1:(length(dur)-1)
        [~, a] = ismember(dur(i), S);
        [~, b] = ismember(dur(i+1), S);
        P3(a, b) = P3(a, b) + 1;
    end
end
for i=1:N_S, if sum(P3(i,:))>0, P3(i,:) = P3(i,:)/sum(P3(i,:)); end; end

% 5.1 Heatmap de Transición (El que teníamos antes)
fig4 = figure('Visible', 'off', 'Color', 'w');
imagesc(P3); colormap(parula); colorbar('Color', 'k');
set(gca, 'XTick', 1:N_S, 'XTickLabel', strtrim(cellstr(num2str(S, '%g'))), 'Color', 'w', 'XColor', 'k', 'YColor', 'k');
set(gca, 'YTick', 1:N_S, 'YTickLabel', strtrim(cellstr(num2str(S, '%g'))));
title('Matriz de Transición de Markov P[T_{i+1}|T_i]', 'Color', 'k');
xlabel('Estado Siguiente (T_{i+1})', 'Color', 'k'); ylabel('Estado Actual (T_i)', 'Color', 'k');
exportgraphics(fig4, fullfile(base_dir, 'actividad5/act5_1_heatmap_markov.png'), 'Resolution', 300);
close(fig4);

% 5.2 Vista 3D de la Matriz de Transición
fig5 = figure('Visible', 'off', 'Color', 'w');
bar3(P3);
set(gca, 'XTick', 1:N_S, 'XTickLabel', strtrim(cellstr(num2str(S, '%g'))), 'Color', 'w', 'XColor', 'k', 'YColor', 'k');
set(gca, 'YTick', 1:N_S, 'YTickLabel', strtrim(cellstr(num2str(S, '%g'))));
title('Probabilidades de Transición en 3D', 'Color', 'k');
zlabel('Probabilidad Condicional', 'Color', 'k');
exportgraphics(fig5, fullfile(base_dir, 'actividad5/act5_2_markov_3d.png'), 'Resolution', 300);
close(fig5);

% 5.3 Comparativa Tiempos Markov
cont_f3 = fileread('fase3/fase3_la_vie_en_rose_by_edith_piaf.m');
tok_f3 = regexp(cont_f3, 'melodia\s*=\s*\[(.*?)\]', 'tokens', 'once');
eval(['f3_mat = [' tok_f3{1} '];']);
f3_dur = f3_mat(1:min(50,size(f3_mat,1)), 7);

fig6 = figure('Visible', 'off', 'Color', 'w', 'Position', [100,100,1000,400]);
plot(orig_dur, '-o', 'LineWidth', 1.5, 'DisplayName', 'Original'); hold on;
plot(f3_dur, '-x', 'LineWidth', 1.5, 'DisplayName', 'Markov (Act 5)');
title('Comparación de Tiempos: Original vs Markov Condicional (50 notas)', 'Color', 'k');
xlabel('Índice de Nota', 'Color', 'k'); ylabel('Duración', 'Color', 'k'); 
legend('Location', 'best'); grid on;
set(gca, 'Color', 'w', 'XColor', 'k', 'YColor', 'k');
exportgraphics(fig6, fullfile(base_dir, 'actividad5/act5_3_comparacion_markov.png'), 'Resolution', 300);
close(fig6);

% =========================================================================
% ACTIVIDAD 6: Dependencia entre Trastes y Cuerdas
% =========================================================================
disp('Generando Actividad 6...');
cuerdas = corpus_matrix(:, 1:6);
trastes_validos = cuerdas(cuerdas >= 0);

% 6.1 Histograma de uso de trastes
fig7 = figure('Visible', 'off', 'Color', 'w');
histogram(trastes_validos, 'BinMethod', 'integers', 'FaceColor', [0.4 0.7 0.4]);
title('Frecuencia de Uso de Trastes en el Corpus', 'Color', 'k');
xlabel('Número de Traste (0 = al aire)', 'Color', 'k'); ylabel('Frecuencia Absoluta', 'Color', 'k'); 
grid on; set(gca, 'Color', 'w', 'XColor', 'k', 'YColor', 'k');
exportgraphics(fig7, fullfile(base_dir, 'actividad6/act6_1_histograma_trastes.png'), 'Resolution', 300);
close(fig7);

% 6.2 Uso por Cuerda
usos_cuerda = sum(cuerdas >= 0, 1);
fig8 = figure('Visible', 'off', 'Color', 'w');
bar(1:6, usos_cuerda, 'FaceColor', [0.8 0.5 0.2]);
title('Actividad por Cuerda en las Melodías Base', 'Color', 'k');
xlabel('Cuerda de la Guitarra (1-6)', 'Color', 'k'); ylabel('Cantidad de Notas Tocadas', 'Color', 'k'); 
grid on; set(gca, 'Color', 'w', 'XColor', 'k', 'YColor', 'k');
exportgraphics(fig8, fullfile(base_dir, 'actividad6/act6_2_uso_cuerdas.png'), 'Resolution', 300);
close(fig8);

% 6.3 Patrones de Transición de Trastes (Scatter)
notas_sec = [];
for r=1:size(cuerdas,1)
    % Tomamos el traste máximo tocado en ese instante (para acordes o notas simples)
    n = max(cuerdas(r,:));
    if n >= 0
        notas_sec(end+1) = n;
    end
end
fig9 = figure('Visible', 'off', 'Color', 'w');
scatter(notas_sec(1:end-1), notas_sec(2:end), 80, 'filled', 'MarkerFaceAlpha', 0.15, 'MarkerFaceColor', 'b');
title('Patrones de Transición: Traste_{i} vs Traste_{i+1}', 'Color', 'k');
xlabel('Traste de la Nota_{i}', 'Color', 'k'); ylabel('Traste de la Nota_{i+1}', 'Color', 'k'); 
grid on; set(gca, 'Color', 'w', 'XColor', 'k', 'YColor', 'k');
exportgraphics(fig9, fullfile(base_dir, 'actividad6/act6_3_dependencia_trastes.png'), 'Resolution', 300);
close(fig9);

% =========================================================================
% ACTIVIDAD 7: Generador Aleatorio Final (Estados Completos)
% =========================================================================
disp('Generando Actividad 7...');
cont_f5 = fileread('fase5/generacion_markov_edith_piaf.m');
tok_f5 = regexp(cont_f5, 'nueva_cancion\s*=\s*\[(.*?)\]', 'tokens', 'once');
eval(['f5_mat = [' tok_f5{1} '];']);

% 7.1 Scatter Plot de la Melodía Generada (La que teníamos antes)
fig10 = figure('Visible', 'off', 'Color', 'w', 'Position', [100, 100, 1200, 600]);
hold on; t_acum = 0;
for i = 1:size(f5_mat, 1)
    d = f5_mat(i, 7);
    trs = f5_mat(i, 1:6);
    c_toc = find(trs >= 0);
    for c = 1:length(c_toc)
        scatter(t_acum, c_toc(c), 50, 'filled', 'MarkerFaceColor', [0 0.4470 0.7410]);
        text(t_acum, c_toc(c) + 0.25, num2str(trs(c_toc(c))), 'FontSize', 8, 'HorizontalAlignment', 'center', 'Color', 'k');
    end
    t_acum = t_acum + d;
end
hold off; 
title('Generador Final: Cuerdas y Trastes en el Tiempo (Act. 7)', 'Color', 'k');
xlabel('Tiempo Relativo Acumulado (Compases)', 'Color', 'k'); ylabel('Cuerda (1-6)', 'Color', 'k');
ylim([0.5 6.5]); xlim([-0.5, t_acum + 1]);
set(gca, 'YTick', 1:6, 'Color', 'w', 'XColor', 'k', 'YColor', 'k'); grid on;
exportgraphics(fig10, fullfile(base_dir, 'actividad7/act7_1_melodia_generada.png'), 'Resolution', 300);
close(fig10);

% 7.2 Estructura de la Matriz de Estados Completos (Sparsity)
[~, ~, idx_estados] = unique(corpus_matrix, 'rows', 'stable');
num_estados_totales = max(idx_estados);
P_estados = sparse(num_estados_totales, num_estados_totales);
for i=1:length(idx_estados)-1
    % No cruzar fin de cancion
    if i ~= 426 && i ~= (426+174)
        P_estados(idx_estados(i), idx_estados(i+1)) = 1;
    end
end
fig11 = figure('Visible', 'off', 'Color', 'w');
spy(P_estados, 'k', 15);
title('Dispersión de la Matriz de Transición de Estados Completos', 'Color', 'k');
xlabel('Estado Siguiente', 'Color', 'k'); ylabel('Estado Actual', 'Color', 'k');
set(gca, 'Color', 'w', 'XColor', 'k', 'YColor', 'k');
exportgraphics(fig11, fullfile(base_dir, 'actividad7/act7_2_sparsidad_estados.png'), 'Resolution', 300);
close(fig11);

% 7.3 Distribución de Tiempos: Corpus vs Generada
frec_f5 = zeros(N_S, 1);
dur_f5 = f5_mat(:, 7);
for i = 1:N_S
    frec_f5(i) = sum(dur_f5 == S(i));
end
prob_f5 = frec_f5 / sum(frec_f5);

fig12 = figure('Visible', 'off', 'Color', 'w', 'Position', [100,100,900,450]);
b = bar(1:N_S, [probabilidades, prob_f5], 'grouped');
b(1).FaceColor = [0.2 0.6 0.8];
b(2).FaceColor = [0.8 0.4 0.2];
set(gca, 'XTick', 1:N_S, 'XTickLabel', strtrim(cellstr(num2str(S, '%g'))), 'Color', 'w', 'XColor', 'k', 'YColor', 'k');
xtickangle(45); 
title('Distribución de Tiempos: Corpus Original vs Melodía Generada', 'Color', 'k');
legend('Corpus Original', 'Melodía Generada (Markov)', 'Location', 'northeast');
xlabel('Duración', 'Color', 'k'); ylabel('Probabilidad', 'Color', 'k'); grid on;
exportgraphics(fig12, fullfile(base_dir, 'actividad7/act7_3_comparacion_distribuciones.png'), 'Resolution', 300);
close(fig12);

% =========================================================================
% GRÁFICOS AVANZADOS (Sorpresas para el Profesor)
% =========================================================================
disp('Generando gráficos avanzados (Grafo Dirigido y Piano Roll)...');

% 5.4 Grafo Dirigido de Transiciones de Tiempos (Markov Network)
G = digraph(P3);
G.Nodes.Name = strtrim(cellstr(num2str(S, '%g')));
fig_new1 = figure('Visible', 'off', 'Color', 'w', 'Position', [100,100,800,800]);
% Limpiamos aristas con probabilidad muy baja para no saturar el grafo
P3_thresh = P3; P3_thresh(P3 < 0.05) = 0; 
G_plot = digraph(P3_thresh);
G_plot.Nodes.Name = strtrim(cellstr(num2str(S, '%g')));
LWidths = 5 * G_plot.Edges.Weight / max(G_plot.Edges.Weight);
p = plot(G_plot, 'Layout', 'force', 'EdgeLabel', round(G_plot.Edges.Weight,2), 'LineWidth', LWidths);
p.MarkerSize = 10; p.NodeColor = 'r'; p.EdgeColor = [0.2 0.5 0.8];
title('Grafo Dirigido de Transiciones de Tiempos (P > 0.05)', 'Color', 'k');
set(gca, 'Color', 'w', 'XColor', 'w', 'YColor', 'w'); % Ocultamos los ejes
exportgraphics(fig_new1, fullfile(base_dir, 'actividad5/act5_4_grafo_dirigido.png'), 'Resolution', 300);
close(fig_new1);

% 7.4 Piano Roll Comparativo (Corpus vs Generada)
fig_new2 = figure('Visible', 'off', 'Color', 'w', 'Position', [100,100,1200,500]);
subplot(1,2,1); hold on;
t_acum = 0;
for i = 1:min(100, size(corpus_matrix, 1))
    d = corpus_matrix(i, 7);
    trs = corpus_matrix(i, 1:6);
    c_toc = find(trs >= 0);
    for c = 1:length(c_toc)
        % Dibujamos una linea gruesa simulando la duración en un Piano Roll
        line([t_acum, t_acum + d*0.9], [c_toc(c), c_toc(c)], 'LineWidth', 8, 'Color', [0.2 0.6 0.8]);
    end
    t_acum = t_acum + d;
end
title('Piano Roll: Segmento Corpus Original', 'Color', 'k');
xlabel('Tiempo Acumulado', 'Color', 'k'); ylabel('Cuerda (1-6)', 'Color', 'k'); ylim([0.5 6.5]); grid on;
set(gca, 'YTick', 1:6, 'Color', 'w', 'XColor', 'k', 'YColor', 'k');

subplot(1,2,2); hold on;
t_acum = 0;
for i = 1:min(100, size(f5_mat, 1))
    d = f5_mat(i, 7);
    trs = f5_mat(i, 1:6);
    c_toc = find(trs >= 0);
    for c = 1:length(c_toc)
        line([t_acum, t_acum + d*0.9], [c_toc(c), c_toc(c)], 'LineWidth', 8, 'Color', [0.8 0.4 0.2]);
    end
    t_acum = t_acum + d;
end
title('Piano Roll: Melodía Generada (Markov)', 'Color', 'k');
xlabel('Tiempo Acumulado', 'Color', 'k'); ylabel('Cuerda (1-6)', 'Color', 'k'); ylim([0.5 6.5]); grid on;
set(gca, 'YTick', 1:6, 'Color', 'w', 'XColor', 'k', 'YColor', 'k');

exportgraphics(fig_new2, fullfile(base_dir, 'actividad7/act7_4_piano_roll.png'), 'Resolution', 300);
close(fig_new2);

disp('FIN: Todas las imágenes generadas correctamente en "imagenes/"');
exit;