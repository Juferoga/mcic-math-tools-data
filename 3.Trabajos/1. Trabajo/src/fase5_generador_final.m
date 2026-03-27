% ======== FASE 5: GENERADOR FINAL DE MELODÍAS (SÉPTIMA ACTIVIDAD) ========
% Este script:
% 1) Carga 3 melodías base (Nx7).
% 2) Construye un espacio de estados con filas completas [6 trastes + duración].
% 3) Estima una matriz de transición Markoviana global P entre estados.
% 4) Genera una nueva canción de 200 notas.
% 5) Exporta matriz y audio en fase5/.
% Nota: Script lineal (sin declaraciones function) para ejecutar con stdin.

clearvars -except tiempo_total_inicio;
clc;

fprintf('\n');
fprintf('========================================================================\n');
fprintf(' FASE 5 - SÉPTIMA ACTIVIDAD: GRAN FINAL (GENERADOR MARKOV DE MELODÍAS)\n');
fprintf('========================================================================\n\n');

% ======== CONFIGURACIÓN GENERAL ========
archivos_entrada = {
    'songs/m and wav files/lhymne_a_lamour_acoustic_guitar.m', ...
    'songs/m and wav files/la_goualante_du_pauvre_jean.m', ...
    'songs/m and wav files/la_vie_en_rose_by_edith_piaf.m'
};

carpeta_salida_fase5 = 'fase5';
archivo_salida_m = 'fase5/generacion_markov_edith_piaf.m';
archivo_salida_wav = 'fase5/generacion_markov_edith_piaf.wav';
num_notas_generadas = 200;
tempo_sintesis_bpm = 120;

if length(archivos_entrada) ~= 3
    error('Configuración inválida: se requieren exactamente 3 canciones base.');
end

% ======== PREPARACIÓN DE CARPETA DE SALIDA ========
if exist(carpeta_salida_fase5, 'dir') ~= 7
    mkdir(carpeta_salida_fase5);
    fprintf('Carpeta creada: %s\n', carpeta_salida_fase5);
else
    fprintf('Carpeta existente: %s\n', carpeta_salida_fase5);
end

fprintf('\nCanciones base:\n');
for i = 1:3
    fprintf('  %d) %s\n', i, archivos_entrada{i});
end

fprintf('\nSalidas:\n');
fprintf('  - Matriz: %s\n', archivo_salida_m);
fprintf('  - Audio : %s\n\n', archivo_salida_wav);

% ======== CARGA DE LAS 3 MATRICES BASE ========
melodias_base = cell(3, 1);
longitudes = zeros(3, 1);

for i = 1:3
    ruta = archivos_entrada{i};
    fprintf('Cargando %s ...\n', ruta);

    if exist(ruta, 'file') ~= 2
        error('No se encontró el archivo requerido: %s', ruta);
    end

    contenido = fileread(ruta);
    tokens = regexp(contenido, 'melodia\s*=\s*\[([\s\S]*?)\]', 'tokens', 'once');

    if isempty(tokens)
        error('No se encontró el bloque "melodia = [ ... ];" en: %s', ruta);
    end

    bloque_matriz = tokens{1};
    expr = ['melodia_temp = [', bloque_matriz, '];'];
    eval(expr);

    if ~isnumeric(melodia_temp) || size(melodia_temp, 2) ~= 7
        error('La matriz en %s no es numérica o no tiene 7 columnas.', ruta);
    end

    melodias_base{i} = melodia_temp;
    longitudes(i) = size(melodia_temp, 1);

    fprintf('  -> OK: %d notas, 7 columnas.\n', longitudes(i));
end

fprintf('\nLongitudes por canción: [%d, %d, %d]\n', longitudes(1), longitudes(2), longitudes(3));
fprintf('Total de notas en el corpus concatenado: %d\n\n', sum(longitudes));

% ======== CONCATENACIÓN DE LAS 3 MATRICES EN UN SOLO DATASET Nx7 ========
dataset_matrix = [melodias_base{1}; melodias_base{2}; melodias_base{3}];

% ======== IDENTIFICACIÓN DE ESTADOS ÚNICOS (FILA COMPLETA) ========
[unique_states, ~, state_indices] = unique(dataset_matrix, 'rows', 'stable');
N = size(unique_states, 1);

fprintf('Espacio de estados construido.\n');
fprintf('Cada estado = [cuerda1..cuerda6, duración].\n');
fprintf('Cantidad total de estados únicos (N): %d\n\n', N);

% ======== CONSTRUCCIÓN DE MATRIZ DE TRANSICIÓN (SIN CRUCES ENTRE CANCIONES) ========
Counts = zeros(N, N);

% Índices de fin de cada canción en el vector concatenado
indices_fin_cancion = cumsum(longitudes);

% Saltos inválidos (fin de canción -> inicio de la siguiente)
saltos_invalidos = false(length(state_indices) - 1, 1);
indices_fin_sin_ultima = indices_fin_cancion(1:end-1);
saltos_invalidos(indices_fin_sin_ultima) = true;

for i = 1:(length(state_indices) - 1)
    if saltos_invalidos(i)
        continue;
    end

    A = state_indices(i);
    B = state_indices(i + 1);
    Counts(A, B) = Counts(A, B) + 1;
end

P = zeros(N, N);
for i = 1:N
    suma_fila = sum(Counts(i, :));

    if suma_fila > 0
        P(i, :) = Counts(i, :) ./ suma_fila;
    else
        P(i, i) = 1; % Estado absorbente defensivo para filas sin salidas observadas
    end
end

fprintf('Matriz de transición P construida (%d x %d).\n', N, N);
fprintf('Transiciones omitidas por frontera entre canciones: %d\n', sum(saltos_invalidos));

error_normalizacion = max(abs(sum(P, 2) - 1));
fprintf('Error máximo de normalización por fila: %.12f\n\n', error_normalizacion);

% ======== GENERACIÓN DE UNA NUEVA MELODÍA (200 NOTAS) ========
rng('shuffle');

% Elegir estado inicial entre las primeras notas de las 3 canciones base
estados_iniciales = zeros(3, 1);
for i = 1:3
    [encontrado, idx_estado] = ismember(melodias_base{i}(1, :), unique_states, 'rows');
    if ~encontrado
        error('No se encontró el estado inicial de la canción %d dentro del espacio de estados.', i);
    end
    estados_iniciales(i) = idx_estado;
end

secuencia_estados = zeros(num_notas_generadas, 1);
secuencia_estados(1) = estados_iniciales(randi(3));

for i = 2:num_notas_generadas
    estado_actual = secuencia_estados(i - 1);
    probs = P(estado_actual, :);
    cdf = cumsum(probs);
    u = rand();

    idx_siguiente = find(u <= cdf, 1, 'first');
    if isempty(idx_siguiente)
        idx_siguiente = N;
    end

    secuencia_estados(i) = idx_siguiente;
end

matriz_fase5_nueva_cancion = unique_states(secuencia_estados, :);
nueva_cancion = matriz_fase5_nueva_cancion; %#ok<NASGU>

fprintf('Nueva canción generada con %d notas.\n', size(matriz_fase5_nueva_cancion, 1));
fprintf('Estado inicial elegido (ID): %d\n\n', secuencia_estados(1));

% ======== EXPORTACIÓN DE MATRIZ .m ========
fid = fopen(archivo_salida_m, 'w');
if fid == -1
    error('No se pudo crear el archivo de salida: %s', archivo_salida_m);
end

fprintf(fid, '%% ======== MATRIZ GENERADA EN FASE 5 (SÉPTIMA ACTIVIDAD) ========\n');
fprintf(fid, '%% Generador aleatorio de melodías por dependencia estadística (Markov de estados completos).\n');
fprintf(fid, '%% Corpus base: la_foule + la_goualante_du_pauvre_jean + la_vie_en_rose_by_edith_piaf\n');
fprintf(fid, '%% Dimensión: %d x 7\n', size(matriz_fase5_nueva_cancion, 1));
fprintf(fid, 'format rat;\n\n');
fprintf(fid, 'nueva_cancion = [\n');

for r = 1:size(matriz_fase5_nueva_cancion, 1)
    fprintf(fid, '    ');
    for c = 1:6
        fprintf(fid, '%g ', matriz_fase5_nueva_cancion(r, c));
    end
    fprintf(fid, '%.15g;...\n', matriz_fase5_nueva_cancion(r, 7));
end

fprintf(fid, '];\n');
fprintf(fid, 'melodia = nueva_cancion;\n');
fclose(fid);

fprintf('Matriz exportada correctamente: %s\n', archivo_salida_m);

% ======== SÍNTESIS Y EXPORTACIÓN DE AUDIO ========
addpath('songs/m and wav files');
y = generamelodia(nueva_cancion, tempo_sintesis_bpm, 0);
audiowrite(archivo_salida_wav, y, 44100);

fprintf('Audio exportado correctamente : %s\n\n', archivo_salida_wav);

% ======== RESUMEN FINAL (POÉTICO Y CLARO) ========
fprintf('========================================================================\n');
fprintf(' GRAN FINAL COMPLETADO\n');
fprintf('========================================================================\n');
fprintf('De tres memorias musicales nació una cuarta voz.\n');
fprintf('No es copia exacta, no es ruido sin alma: es una caminata probable\n');
fprintf('sobre los pasos estadísticos de Edith Piaf y su universo armónico.\n\n');
fprintf('Resumen técnico:\n');
fprintf('  - Canciones base analizadas              : 3\n');
fprintf('  - Notas totales del corpus               : %d\n', size(dataset_matrix, 1));
fprintf('  - Estados únicos (filas completas Nx7)   : %d\n', N);
fprintf('  - Notas de la nueva canción              : %d\n', num_notas_generadas);
fprintf('  - Archivo de matriz generado             : %s\n', archivo_salida_m);
fprintf('  - Archivo de audio generado              : %s\n\n', archivo_salida_wav);
fprintf('La melodía quedó lista para sonar: distinta, coherente y viva.\n');
fprintf('========================================================================\n\n');
