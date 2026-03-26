% Script para generar imágenes en fondo blanco para el Trabajo 1

% 1. Fase 2: Probabilidades
disp('Generando gráfica de probabilidades (Fase 2)...');
todas_las_duraciones = [];
archivos = {
    'songs/m and wav files/lhymne_a_lamour_acoustic_guitar.m', ...
    'songs/m and wav files/la_goualante_du_pauvre_jean.m', ...
    'songs/m and wav files/la_vie_en_rose_by_edith_piaf.m'
};

for i = 1:3
    contenido = fileread(archivos{i});
    tokens = regexp(contenido, 'melodia\s*=\s*\[(.*?)\]', 'tokens', 'once');
    eval(['melodia_temp = [' tokens{1} '];']);
    todas_las_duraciones = [todas_las_duraciones; melodia_temp(:, 7)];
end

S = unique(todas_las_duraciones, 'sorted');
N_S = length(S);
frecuencias = zeros(N_S, 1);
for i = 1:N_S
    frecuencias(i) = sum(todas_las_duraciones == S(i));
end
probabilidades = frecuencias / sum(frecuencias);

fig1 = figure('Visible', 'off', 'Color', 'w');
bar(1:N_S, probabilidades, 'FaceColor', [0.2 0.6 0.8]);
set(gca, 'XTick', 1:N_S, 'XTickLabel', strtrim(cellstr(num2str(S, '%g'))), 'Color', 'w', 'XColor', 'k', 'YColor', 'k');
xtickangle(45);
title('Probabilidades de Tiempos Relativos (Fase 2)', 'Color', 'k');
xlabel('Duración (Tiempos Relativos)', 'Color', 'k');
ylabel('Probabilidad Estimada', 'Color', 'k');
grid on;
exportgraphics(fig1, 'imagenes/fase2/fase2_probabilidades.png', 'BackgroundColor', 'white', 'Resolution', 300);


% 2. Fase 3: Heatmap de Matriz de Transición
disp('Generando heatmap de transición de Markov (Fase 3)...');
P3 = zeros(N_S, N_S);
for s = 1:3
    contenido = fileread(archivos{s});
    tokens = regexp(contenido, 'melodia\s*=\s*\[(.*?)\]', 'tokens', 'once');
    eval(['melodia_temp = [' tokens{1} '];']);
    duraciones = melodia_temp(:, 7);
    for i = 1:(length(duraciones)-1)
        [~, idx_a] = ismember(duraciones(i), S);
        [~, idx_b] = ismember(duraciones(i+1), S);
        P3(idx_a, idx_b) = P3(idx_a, idx_b) + 1;
    end
end
for i = 1:N_S
    if sum(P3(i,:)) > 0
        P3(i,:) = P3(i,:) / sum(P3(i,:));
    end
end

fig2 = figure('Visible', 'off', 'Color', 'w');
imagesc(P3);
colormap(parula);
colorbar('Color', 'k');
set(gca, 'XTick', 1:N_S, 'XTickLabel', strtrim(cellstr(num2str(S, '%g'))), 'Color', 'w', 'XColor', 'k', 'YColor', 'k');
set(gca, 'YTick', 1:N_S, 'YTickLabel', strtrim(cellstr(num2str(S, '%g'))));
title('Matriz de Transición de Markov P[T_{i+1}|T_i] (Fase 3)', 'Color', 'k');
xlabel('Estado Siguiente (T_{i+1})', 'Color', 'k');
ylabel('Estado Actual (T_i)', 'Color', 'k');
exportgraphics(fig2, 'imagenes/fase3/fase3_matriz_transicion.png', 'BackgroundColor', 'white', 'Resolution', 300);


% 3. Fase 5: Scatter Plot Melodía Generada
disp('Generando scatter plot de la melodía generada (Fase 5)...');
contenido_fase5 = fileread('fase5/generacion_markov_edith_piaf.m');
tokens_f5 = regexp(contenido_fase5, 'nueva_cancion\s*=\s*\[(.*?)\]', 'tokens', 'once');
eval(['melodia_final = [' tokens_f5{1} '];']);

fig3 = figure('Visible', 'off', 'Color', 'w', 'Position', [100, 100, 1200, 600]);
hold on;
tiempo_acumulado = 0;
for i = 1:size(melodia_final, 1)
    duracion = melodia_final(i, 7);
    trastes = melodia_final(i, 1:6);
    cuerdas_tocadas = find(trastes >= 0);
    
    for c = 1:length(cuerdas_tocadas)
        cuerda = cuerdas_tocadas(c);
        traste = trastes(cuerda);
        scatter(tiempo_acumulado, cuerda, 50, 'filled', 'MarkerFaceColor', [0 0.4470 0.7410]);
        text(tiempo_acumulado, cuerda + 0.25, num2str(traste), 'FontSize', 8, 'HorizontalAlignment', 'center', 'Color', 'k');
    end
    tiempo_acumulado = tiempo_acumulado + duracion;
end
hold off;
title('Melodía Generada: Cuerdas y Trastes en el Tiempo (Fase 5)', 'Color', 'k');
xlabel('Tiempo Relativo Acumulado (Compases)', 'Color', 'k');
ylabel('Cuerda de la Guitarra (1-6)', 'Color', 'k');
ylim([0.5 6.5]);
xlim([-0.5, tiempo_acumulado + 1]);
set(gca, 'YTick', 1:6, 'Color', 'w', 'XColor', 'k', 'YColor', 'k');
grid on;
exportgraphics(fig3, 'imagenes/fase5/fase5_melodia_generada.png', 'BackgroundColor', 'white', 'Resolution', 300);

disp('Imágenes en fondo blanco generadas correctamente en "imagenes/".');
exit;