% Script para generar MÁS imágenes (Correlaciones, Autocorrelaciones, etc)
clear; clc;
disp('Generando MÁS imagenes analíticas avanzadas (Correlaciones)...');
base_dir = 'imagenes';

% Carga de datos base
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

% Variables originales de Piaf
cont_orig = fileread(archivos{3});
tok_orig = regexp(cont_orig, 'melodia\s*=\s*\[(.*?)\]', 'tokens', 'once');
eval(['orig_mat = [' tok_orig{1} '];']);
orig_dur = orig_mat(:, 7);

% Variables Fase 2
cont_f2 = fileread('fase2/fase2_la_vie_en_rose_by_edith_piaf.m');
tok_f2 = regexp(cont_f2, 'melodia\s*=\s*\[(.*?)\]', 'tokens', 'once');
eval(['f2_mat = [' tok_f2{1} '];']);
f2_dur = f2_mat(:, 7);

% Variables Fase 3
cont_f3 = fileread('fase3/fase3_la_vie_en_rose_by_edith_piaf.m');
tok_f3 = regexp(cont_f3, 'melodia\s*=\s*\[(.*?)\]', 'tokens', 'once');
eval(['f3_mat = [' tok_f3{1} '];']);
f3_dur = f3_mat(:, 7);

% Variables Fase 5
cont_f5 = fileread('fase5/generacion_markov_edith_piaf.m');
tok_f5 = regexp(cont_f5, 'nueva_cancion\s*=\s*\[(.*?)\]', 'tokens', 'once');
eval(['f5_mat = [' tok_f5{1} '];']);

% ----- ACT 4 -----
disp('Correlaciones Actividad 4...');
fig1 = figure('Visible', 'off', 'Color', 'w', 'Position', [100,100,1000,400]);
subplot(1,2,1); 
[acf_orig, lags_orig] = xcorr(orig_dur - mean(orig_dur), 30, 'normalized');
stem(lags_orig(lags_orig>=0), acf_orig(lags_orig>=0), 'filled');
title('Autocorrelación: Original (Piaf)', 'Color', 'k');
xlabel('Lags'); ylabel('Autocorrelación');
set(gca, 'Color', 'w', 'XColor', 'k', 'YColor', 'k');

subplot(1,2,2); 
[acf_f2, lags_f2] = xcorr(f2_dur - mean(f2_dur), 30, 'normalized');
stem(lags_f2(lags_f2>=0), acf_f2(lags_f2>=0), 'filled');
title('Autocorrelación: Aleatoria (Act 4)', 'Color', 'k');
xlabel('Lags'); ylabel('Autocorrelación');
set(gca, 'Color', 'w', 'XColor', 'k', 'YColor', 'k');
exportgraphics(fig1, fullfile(base_dir, 'actividad4/act4_4_autocorr_comparativa.png'), 'Resolution', 300);
close(fig1);

fig2 = figure('Visible', 'off', 'Color', 'w');
histogram(orig_dur, 'Normalization', 'probability', 'FaceColor', 'b', 'FaceAlpha', 0.5); hold on;
histogram(f2_dur, 'Normalization', 'probability', 'FaceColor', 'r', 'FaceAlpha', 0.5);
title('Distribución de Tiempos (Original vs Aleatoria)', 'Color', 'k');
legend('Original', 'Aleatoria');
xlabel('Duración', 'Color', 'k'); ylabel('Probabilidad', 'Color', 'k');
set(gca, 'Color', 'w', 'XColor', 'k', 'YColor', 'k');
exportgraphics(fig2, fullfile(base_dir, 'actividad4/act4_5_hist_tiempos.png'), 'Resolution', 300);
close(fig2);

% ----- ACT 5 -----
disp('Correlaciones Actividad 5...');
fig3 = figure('Visible', 'off', 'Color', 'w');
[acf_f3, lags_f3] = xcorr(f3_dur - mean(f3_dur), 30, 'normalized');
stem(lags_f3(lags_f3>=0), acf_f3(lags_f3>=0), 'filled');
title('Autocorrelación: Generación Markov (Act 5)', 'Color', 'k');
xlabel('Lags'); ylabel('Autocorrelación');
set(gca, 'Color', 'w', 'XColor', 'k', 'YColor', 'k');
exportgraphics(fig3, fullfile(base_dir, 'actividad5/act5_5_autocorr_markov.png'), 'Resolution', 300);
close(fig3);

% Matriz P3 real
P3 = zeros(N_S, N_S);
for i = 1:(length(duraciones_corpus)-1)
    [~, a] = ismember(duraciones_corpus(i), S);
    [~, b] = ismember(duraciones_corpus(i+1), S);
    P3(a, b) = P3(a, b) + 1;
end
for i=1:N_S, if sum(P3(i,:))>0, P3(i,:) = P3(i,:)/sum(P3(i,:)); end; end

% Matriz P3 empirica (de la generada)
P3_emp = zeros(N_S, N_S);
for i = 1:(length(f3_dur)-1)
    [~, a] = ismember(f3_dur(i), S);
    [~, b] = ismember(f3_dur(i+1), S);
    P3_emp(a, b) = P3_emp(a, b) + 1;
end
for i=1:N_S, if sum(P3_emp(i,:))>0, P3_emp(i,:) = P3_emp(i,:)/sum(P3_emp(i,:)); end; end

fig4 = figure('Visible', 'off', 'Color', 'w');
imagesc(abs(P3 - P3_emp)); colormap(hot); colorbar('Color','k');
title('Diferencias Absolutas: Transición Teórica vs Empírica', 'Color', 'k');
set(gca, 'XTick', 1:N_S, 'XTickLabel', strtrim(cellstr(num2str(S, '%g'))), 'YTick', 1:N_S, 'YTickLabel', strtrim(cellstr(num2str(S, '%g'))));
xlabel('Estado Siguiente', 'Color', 'k'); ylabel('Estado Actual', 'Color', 'k');
set(gca, 'Color', 'w', 'XColor', 'k', 'YColor', 'k');
exportgraphics(fig4, fullfile(base_dir, 'actividad5/act5_6_diferencias_transicion.png'), 'Resolution', 300);
close(fig4);

% ----- ACT 6 -----
disp('Correlaciones Actividad 6...');
cuerdas_bin = corpus_matrix(:, 1:6) >= 0;
R = corrcoef(cuerdas_bin);
R(isnan(R)) = 0; % Evitar NaNs
fig5 = figure('Visible', 'off', 'Color', 'w');
imagesc(R); colormap(jet); colorbar('Color','k');
title('Matriz de Correlación Cruzada entre Cuerdas (Simultaneidad)', 'Color', 'k');
xlabel('Cuerda', 'Color', 'k'); ylabel('Cuerda', 'Color', 'k');
set(gca, 'Color', 'w', 'XColor', 'k', 'YColor', 'k');
exportgraphics(fig5, fullfile(base_dir, 'actividad6/act6_4_correlacion_cuerdas.png'), 'Resolution', 300);
close(fig5);

cuerdas = corpus_matrix(:, 1:6);
trastes_all = []; cuerdas_all = [];
for i=1:size(cuerdas,1)
    for j=1:6
        if cuerdas(i,j) >= 0
            cuerdas_all(end+1) = j;
            trastes_all(end+1) = cuerdas(i,j);
        end
    end
end
fig6 = figure('Visible', 'off', 'Color', 'w');
histogram2(cuerdas_all, trastes_all, 'DisplayStyle', 'tile', 'ShowEmptyBins', 'on');
colormap(parula); colorbar('Color','k');
title('Densidad de Uso Bivariado: Cuerda vs Traste', 'Color', 'k');
xlabel('Cuerda', 'Color', 'k'); ylabel('Traste', 'Color', 'k');
set(gca, 'Color', 'w', 'XColor', 'k', 'YColor', 'k');
exportgraphics(fig6, fullfile(base_dir, 'actividad6/act6_5_heatmap_cuerda_traste.png'), 'Resolution', 300);
close(fig6);

% ----- ACT 7 -----
disp('Correlaciones Actividad 7...');
min_len = min(length(orig_dur), length(f5_mat(:,7)));
[xcorr_val, lags] = xcorr(orig_dur(1:min_len) - mean(orig_dur(1:min_len)), f5_mat(1:min_len,7) - mean(f5_mat(1:min_len,7)), 'normalized');
fig7 = figure('Visible', 'off', 'Color', 'w');
plot(lags, xcorr_val, 'LineWidth', 1.5, 'Color', [0.8 0.2 0.5]);
title('Correlación Cruzada (Lags) Original vs Generada', 'Color', 'k');
xlabel('Desfase (Lags)', 'Color', 'k'); ylabel('Coeficiente de Correlación', 'Color', 'k');
grid on; set(gca, 'Color', 'w', 'XColor', 'k', 'YColor', 'k');
exportgraphics(fig7, fullfile(base_dir, 'actividad7/act7_5_cross_correlacion.png'), 'Resolution', 300);
close(fig7);

[estados_un, ~, idx_est] = unique(corpus_matrix, 'rows', 'stable');
conteo_estados = histcounts(idx_est, 1:max(idx_est)+1);
[val_sort, top_idx] = sort(conteo_estados, 'descend');
topN = min(15, length(top_idx));

fig8 = figure('Visible', 'off', 'Color', 'w', 'Position', [100,100,800,400]);
bar(1:topN, val_sort(1:topN), 'FaceColor', [0.2 0.8 0.6]);
title('Top 15 Estados Más Frecuentes (Acordes/Notas) en el Corpus', 'Color', 'k');
xlabel('Rango del Estado', 'Color', 'k');
ylabel('Frecuencia Absoluta', 'Color', 'k');
set(gca, 'XTick', 1:topN, 'Color', 'w', 'XColor', 'k', 'YColor', 'k');
exportgraphics(fig8, fullfile(base_dir, 'actividad7/act7_6_top_estados.png'), 'Resolution', 300);
close(fig8);

% 7.7 Comparativa de Tiempos en Línea (Igual a la de Act 5 pero con el Generador Final)
fig9 = figure('Visible', 'off', 'Color', 'w', 'Position', [100,100,1000,400]);
plot(orig_dur(1:min(50, length(orig_dur))), '-o', 'LineWidth', 1.5, 'DisplayName', 'Original'); hold on;
plot(f5_mat(1:min(50, size(f5_mat,1)), 7), '-x', 'LineWidth', 1.5, 'DisplayName', 'Generador Final (Act 7)');
title('Comparación de Tiempos: Original vs Generador Final de Estados Completos (50 notas)', 'Color', 'k');
xlabel('Índice de Nota', 'Color', 'k'); ylabel('Duración', 'Color', 'k'); 
legend('Location', 'best'); grid on;
set(gca, 'Color', 'w', 'XColor', 'k', 'YColor', 'k');
exportgraphics(fig9, fullfile(base_dir, 'actividad7/act7_7_comparacion_tiempos_lineas.png'), 'Resolution', 300);
close(fig9);

disp('Nuevas imágenes de correlación generadas con éxito.');
exit;
