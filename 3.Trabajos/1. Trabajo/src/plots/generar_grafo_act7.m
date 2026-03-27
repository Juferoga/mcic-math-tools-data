clear; clc;
base_dir = 'imagenes';
archivos = {'songs/m and wav files/lhymne_a_lamour_acoustic_guitar.m', ...
            'songs/m and wav files/la_goualante_du_pauvre_jean.m', ...
            'songs/m and wav files/la_vie_en_rose_by_edith_piaf.m'};
corpus = [];
for i=1:3
    cont = fileread(archivos{i});
    tok = regexp(cont, 'melodia\s*=\s*\[(.*?)\]', 'tokens', 'once');
    eval(['mat = [' tok{1} '];']);
    corpus = [corpus; mat];
end
[estados_un, ~, idx_est] = unique(corpus, 'rows', 'stable');
N = max(idx_est);
P = zeros(N, N);
for i=1:length(idx_est)-1
    if i ~= 426 && i ~= (426+174) % fronteras
        P(idx_est(i), idx_est(i+1)) = P(idx_est(i), idx_est(i+1)) + 1;
    end
end
for i=1:N, if sum(P(i,:))>0, P(i,:) = P(i,:)/sum(P(i,:)); end; end

% Grafo para Actividad 7
conteo = histcounts(idx_est, 1:N+1);
[~, top_idx] = sort(conteo, 'descend');
top25 = top_idx(1:25); % Top 25 estados mas comunes
P_sub = P(top25, top25);

% Limpiar aristas de muy baja probabilidad para que el grafo se vea bien
P_sub(P_sub < 0.05) = 0;

nombres = cell(1, 25);
for i=1:25
    nombres{i} = ['S' num2str(i)]; % Renombrar para no saturar
end

G = digraph(P_sub);
G.Nodes.Name = nombres';
fig = figure('Visible', 'off', 'Color', 'w', 'Position', [100,100,900,700]);
if ~isempty(G.Edges)
    LWidths = 5 * G.Edges.Weight / max(G.Edges.Weight);
    p = plot(G, 'Layout', 'force', 'LineWidth', LWidths, 'NodeColor', [0.8 0.2 0.2], 'EdgeColor', [0.2 0.5 0.8]);
    p.MarkerSize = 10;
    p.NodeFontSize = 10;
else
    plot(G);
end
title('Grafo Dirigido: Transiciones entre los 25 Macro-Estados más frecuentes', 'Color', 'k');
set(gca, 'Color', 'w', 'XColor', 'w', 'YColor', 'w');
exportgraphics(fig, fullfile(base_dir, 'actividad7/act7_8_grafo_estados.png'), 'Resolution', 300);
close(fig);

disp('Grafo generado exitosamente.');
exit;