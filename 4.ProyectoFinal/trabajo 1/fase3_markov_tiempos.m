% ======== FASE 3: CADENAS DE MARKOV EN TIEMPOS RELATIVOS (QUINTA ACTIVIDAD) ========
% Este script:
% 1) Carga 3 canciones (matrices Nx7).
% 2) Construye el espacio de estados S con los tiempos relativos (columna 7).
% 3) Estima la matriz global de transición condicional P[Ti+1|Ti].
% 4) Genera 3 nuevos vectores de tiempos por cadena de Markov.
% 5) Reemplaza la columna 7 de cada matriz, guarda fase3_*.m y fase3_*.wav.
% Nota: Script lineal (sin declaraciones function) para ejecutar con stdin.

clearvars -except tiempo_total_inicio;
clc;

fprintf('\n');
fprintf('========================================================================\n');
fprintf(' FASE 3 - QUINTA ACTIVIDAD: MARKOV SOBRE TIEMPOS RELATIVOS (COLUMNA 7)\n');
fprintf('========================================================================\n\n');

% ======== PARÁMETROS DE ENTRADA (MISMAS 3 CANCIONES) ========
archivos_entrada = {
    'songs/m and wav files/lhymne_a_lamour_acoustic_guitar.m', ...
    'songs/m and wav files/la_goualante_du_pauvre_jean.m', ...
    'songs/m and wav files/la_vie_en_rose_by_edith_piaf.m'
};

carpeta_salida_fase3 = 'fase3';
nombre_variable_salida = 'melodia';
tempo_sintesis_bpm = 120;

if length(archivos_entrada) ~= 3
    error('Configuración inválida: se requieren exactamente 3 archivos de entrada.');
end

% ======== PREPARACIÓN DE CARPETA DE SALIDA ========
if exist(carpeta_salida_fase3, 'dir') ~= 7
    mkdir(carpeta_salida_fase3);
    fprintf('Carpeta creada: %s\n', carpeta_salida_fase3);
else
    fprintf('Carpeta existente: %s\n', carpeta_salida_fase3);
end

archivos_salida_m = cell(3, 1);
archivos_salida_wav = cell(3, 1);
nombres_base = cell(3, 1);

for i = 1:3
    [~, nombre_base, ~] = fileparts(archivos_entrada{i});
    nombres_base{i} = nombre_base;
    archivos_salida_m{i} = sprintf('%s/fase3_%s.m', carpeta_salida_fase3, nombre_base);
    archivos_salida_wav{i} = sprintf('%s/fase3_%s.wav', carpeta_salida_fase3, nombre_base);
end

fprintf('\nCanciones de entrada:\n');
for i = 1:3
    fprintf('  %d) %s\n', i, archivos_entrada{i});
end

fprintf('\nArchivos de salida (.m):\n');
for i = 1:3
    fprintf('  %d) %s\n', i, archivos_salida_m{i});
end

fprintf('\nArchivos de salida (.wav):\n');
for i = 1:3
    fprintf('  %d) %s\n', i, archivos_salida_wav{i});
end
fprintf('\n');

% ======== CARGA DE MATRICES Y EXTRACCIÓN DE DURACIONES (COLUMNA 7) ========
melodias_originales = cell(3, 1);
todas_las_duraciones = [];

for i = 1:3
    ruta = archivos_entrada{i};
    fprintf('Cargando %s ...\n', ruta);

    if exist(ruta, 'file') ~= 2
        error('No se encontró el archivo requerido: %s', ruta);
    end

    contenido = fileread(ruta);
    tokens = regexp(contenido, 'melodia\s*=\s*\[(.*?)\]', 'tokens', 'once');

    if isempty(tokens)
        error('No se encontró el bloque "melodia = [ ... ]" en: %s', ruta);
    end

    bloque_matriz = tokens{1};
    expr = ['melodia_temp = [', bloque_matriz, '];'];
    eval(expr);

    if ~isnumeric(melodia_temp) || size(melodia_temp, 2) ~= 7
        error('La matriz en %s no es numérica o no tiene 7 columnas.', ruta);
    end

    melodias_originales{i} = melodia_temp;
    todas_las_duraciones = [todas_las_duraciones; melodia_temp(:, 7)];

    fprintf('  -> OK: %d notas, 7 columnas.\n', size(melodia_temp, 1));
end

fprintf('\nTotal de tiempos relativos en el corpus global: %d\n\n', length(todas_las_duraciones));

% ======== ESPACIO DE ESTADOS S ========
S = unique(todas_las_duraciones, 'sorted');
N = length(S);

fprintf('Espacio de estados S (duraciones únicas globales):\n');
fprintf('-----------------------------------------\n');
fprintf('%6s | %14s\n', 'Estado', 'Duración');
fprintf('-----------------------------------------\n');
for i = 1:N
    fprintf('%6d | %14.8g\n', i, S(i));
end
fprintf('-----------------------------------------\n');
fprintf('Total de estados (N): %d\n\n', N);

% ======== CONSTRUCCIÓN DE MATRIZ DE TRANSICIÓN GLOBAL P ========
conteos = zeros(N, N);

for s = 1:3
    duraciones = melodias_originales{s}(:, 7);

    if length(duraciones) < 2
        continue;
    end

    for i = 1:(length(duraciones) - 1)
        [existe_a, idx_a] = ismember(duraciones(i), S);
        [existe_b, idx_b] = ismember(duraciones(i + 1), S);

        if existe_a && existe_b
            conteos(idx_a, idx_b) = conteos(idx_a, idx_b) + 1;
        end
    end
end

P = zeros(N, N);
for i = 1:N
    suma_fila = sum(conteos(i, :));
    if suma_fila > 0
        P(i, :) = conteos(i, :) ./ suma_fila;
    else
        P(i, i) = 1; % fila absorbente defensiva para evitar NaN
    end
end

fprintf('Matriz global de transición condicional P[Ti+1|Ti]:\n');
fprintf('(Filas = estado actual Ti, Columnas = siguiente estado Ti+1)\n\n');

fprintf('%8s', '');
for j = 1:N
    fprintf(' E%-8d', j);
end
fprintf('\n');

for i = 1:N
    fprintf('E%-7d', i);
    for j = 1:N
        fprintf(' %-9.6f', P(i, j));
    end
    fprintf('\n');
end

fprintf('\nVerificación de normalización por filas (debe ser ~1):\n');
for i = 1:N
    fprintf('  Suma fila E%-3d = %.6f\n', i, sum(P(i, :)));
end
fprintf('\n');

% ======== GENERACIÓN MARKOVIANA DE 3 VECTORES Y REEMPLAZO DE COLUMNA 7 ========
rng('shuffle');
addpath('songs/m and wav files');

for s = 1:3
    melodia_original = melodias_originales{s};
    n = size(melodia_original, 1);

    nueva_col7 = zeros(n, 1);
    nueva_col7(1) = melodia_original(1, 7); % arranque con tiempo original de la primera nota

    for i = 2:n
        [existe_prev, idx_prev] = ismember(nueva_col7(i - 1), S);

        if ~existe_prev
            idx_prev = 1;
        end

        probs = P(idx_prev, :);
        cdf = cumsum(probs);
        u = rand;
        idx_siguiente = find(u <= cdf, 1, 'first');

        if isempty(idx_siguiente)
            idx_siguiente = N;
        end

        nueva_col7(i) = S(idx_siguiente);
    end

    matriz_fase3 = [melodia_original(:, 1:6), nueva_col7];

    % ======== GUARDADO DE MATRIZ CODIFICADA (.m) ========
    ruta_m = archivos_salida_m{s};
    melodia = matriz_fase3; %#ok<NASGU>

    fid = fopen(ruta_m, 'w');
    if fid == -1
        error('No se pudo crear el archivo de salida: %s', ruta_m);
    end

    fprintf(fid, '%% ======== MATRIZ GENERADA EN FASE 3 (QUINTA ACTIVIDAD) ========\n');
    fprintf(fid, '%% Fuente original: %s\n', archivos_entrada{s});
    fprintf(fid, '%% Columna 7 regenerada por cadena de Markov global P[Ti+1|Ti].\n');
    fprintf(fid, '%% Dimensión: %d x 7\n', size(melodia, 1));
    fprintf(fid, 'format rat;\n\n');
    fprintf(fid, '%s = [\n', nombre_variable_salida);

    for r = 1:size(melodia, 1)
        fprintf(fid, '    ');
        for c = 1:6
            fprintf(fid, '%g ', melodia(r, c));
        end
        fprintf(fid, '%.15g;...\n', melodia(r, 7));
    end

    fprintf(fid, '];\n');
    fclose(fid);

    % ======== SÍNTESIS Y GUARDADO DE AUDIO (.wav) ========
    y = generamelodia(matriz_fase3, tempo_sintesis_bpm, 0);
    audiowrite(archivos_salida_wav{s}, y, 44100);

    fprintf('Canción %d (%s) procesada con éxito:\n', s, nombres_base{s});
    fprintf('  - Notas totales                 : %d\n', n);
    fprintf('  - Vector Markov generado        : %d tiempos\n', length(nueva_col7));
    fprintf('  - Matriz guardada               : %s\n', ruta_m);
    fprintf('  - Audio sintetizado             : %s\n\n', archivos_salida_wav{s});
end

fprintf('========================================================================\n');
fprintf(' PROCESO COMPLETADO: FASE 3 MARKOV FINALIZADA CORRECTAMENTE\n');
fprintf('========================================================================\n');
fprintf('Se generaron 3 matrices fase3_*.m y 3 audios fase3_*.wav en fase3/.\n\n');
