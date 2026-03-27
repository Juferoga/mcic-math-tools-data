% ======== FASE 2: INDEPENDENCIA ESTADÍSTICA (CUARTA ACTIVIDAD) ========
% Este script:
% 1) Carga exactamente 3 canciones (matrices Nx7).
% 2) Estima la probabilidad marginal global de la columna 7 (tiempos relativos).
% 3) Genera 3 vectores aleatorios independientes, uno por canción,
%    respetando la longitud de cada matriz original.
% 4) Reemplaza SOLO la columna 7 de cada canción (sin mezclar columnas 1-6).
% 5) Guarda 3 nuevas matrices codificadas fase2_*.m.
% 6) Sintetiza y reproduce las 3 melodías generadas.
% Nota: Script lineal (sin declaraciones function) para ejecutar con stdin.

clearvars -except tiempo_total_inicio;
clc;

fprintf('\n');
fprintf('=====================================================================\n');
fprintf(' FASE 2 - CUARTA ACTIVIDAD: INDEPENDENCIA ESTADÍSTICA DE DURACIONES\n');
fprintf('=====================================================================\n\n');

% ======== PARÁMETROS DE ENTRADA (EXACTAMENTE 3 CANCIONES) ========
archivos_entrada = {
    'songs/m and wav files/lhymne_a_lamour_acoustic_guitar.m', ...
    'songs/m and wav files/la_goualante_du_pauvre_jean.m', ...
    'songs/m and wav files/la_vie_en_rose_by_edith_piaf.m'
};

carpeta_salida_fase2 = 'fase2';

nombres_cortos = {
    'L''Hymne à l''Amour', ...
    'La Goualante du Pauvre Jean', ...
    'La Vie en Rose'
};

nombre_variable_salida = 'melodia';
tempo_sintesis_bpm = 60;
generar_wav = true;

if length(archivos_entrada) ~= 3
    error('Configuración inválida: se requieren exactamente 3 archivos de entrada.');
end

% ======== PREPARACIÓN DE CARPETA DE SALIDA ========
if exist(carpeta_salida_fase2, 'dir') ~= 7
    mkdir(carpeta_salida_fase2);
    fprintf('Carpeta creada: %s\n', carpeta_salida_fase2);
else
    fprintf('Carpeta existente: %s\n', carpeta_salida_fase2);
end

archivos_salida = cell(3, 1);
archivos_wav_salida = cell(3, 1);
for i = 1:3
    [~, nombre_base, ~] = fileparts(archivos_entrada{i});
    archivos_salida{i} = sprintf('%s/fase2_%s.m', carpeta_salida_fase2, nombre_base);
    archivos_wav_salida{i} = sprintf('%s/fase2_%s.wav', carpeta_salida_fase2, nombre_base);
end

fprintf('Canciones de entrada:\n');
for i = 1:3
    fprintf('  %d) %s\n', i, archivos_entrada{i});
end
fprintf('\nArchivos de salida:\n');
for i = 1:3
    fprintf('  %d) %s\n', i, archivos_salida{i});
end
fprintf('\nArchivos WAV de salida:\n');
for i = 1:3
    fprintf('  %d) %s\n', i, archivos_wav_salida{i});
end
fprintf('\n');

% ======== CARGA DE MATRICES Y EXTRACCIÓN DE DURACIONES ========
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

fprintf('\nTotal de duraciones acumuladas (corpus global): %d\n\n', length(todas_las_duraciones));

% ======== PROBABILIDADES MARGINALES GLOBALES (COLUMNA 7) ========
[duraciones_unicas, ~, idx_unicas] = unique(todas_las_duraciones, 'sorted');
conteos = accumarray(idx_unicas, 1);
probabilidades = conteos ./ sum(conteos);
probabilidades = probabilidades ./ sum(probabilidades); % normalización defensiva

fprintf('Distribución global estimada de tiempos relativos:\n');
fprintf('-------------------------------------------------------------\n');
fprintf('%14s | %10s | %14s\n', 'Duración', 'Frecuencia', 'Probabilidad');
fprintf('-------------------------------------------------------------\n');
for i = 1:length(duraciones_unicas)
    fprintf('%14.8g | %10d | %14.8f\n', duraciones_unicas(i), conteos(i), probabilidades(i));
end
fprintf('-------------------------------------------------------------\n');
fprintf('%14s | %10d | %14.8f\n\n', 'TOTAL', sum(conteos), sum(probabilidades));

% ======== GENERACIÓN INDEPENDIENTE DE 3 VECTORES Y REEMPLAZO COL 7 ========
rng('shuffle');
cdf = cumsum(probabilidades);
melodias_fase2 = cell(3, 1);

for i = 1:3
    melodia_actual = melodias_originales{i};
    n = size(melodia_actual, 1);

    u = rand(n, 1);
    idx_muestreo = ones(n, 1);
    for k = 1:(length(duraciones_unicas) - 1)
        idx_muestreo = idx_muestreo + (u > cdf(k));
    end

    nueva_col7 = duraciones_unicas(idx_muestreo);

    % SOLO se reemplaza la séptima columna
    melodia_fase2 = [melodia_actual(:, 1:6), nueva_col7];
    melodias_fase2{i} = melodia_fase2;

    fprintf('Canción %d (%s):\n', i, nombres_cortos{i});
    fprintf('  - Longitud original          : %d notas\n', n);
    fprintf('  - Vector aleatorio generado  : %d tiempos\n', length(nueva_col7));
    fprintf('  - Columnas 1..6 conservadas  : SI\n');
    fprintf('  - Columna 7 reemplazada      : SI\n\n');
end

% ======== GUARDADO DE CADA MATRIZ CODIFICADA (FASE 2) ========
for i = 1:3
    ruta_salida = archivos_salida{i};
    melodia = melodias_fase2{i}; %#ok<NASGU>

    fid = fopen(ruta_salida, 'w');
    if fid == -1
        error('No se pudo crear el archivo de salida: %s', ruta_salida);
    end

    fprintf(fid, '%% ======== MATRIZ GENERADA EN FASE 2 (CUARTA ACTIVIDAD) ========\n');
    fprintf(fid, '%% Fuente original: %s\n', archivos_entrada{i});
    fprintf(fid, '%% Columna 7 regenerada por muestreo independiente con probabilidad global.\n');
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

    fprintf('Archivo .m generado correctamente en carpeta fase2: %s\n', ruta_salida);
end

fprintf('\n');
fprintf('=====================================================================\n');
fprintf(' RESULTADO: 3 matrices fase2_* generadas con tiempos aleatorios.\n');
fprintf('=====================================================================\n\n');

% ======== SÍNTESIS Y GUARDADO DE LAS 3 MELODÍAS EN WAV ========
if generar_wav
    addpath('songs/m and wav files');

    fprintf('Iniciando síntesis y guardado de WAV de las 3 melodías generadas...\n\n');

    for i = 1:3
        melodia = melodias_fase2{i}; %#ok<NASGU>
        ruta_wav_salida = archivos_wav_salida{i};
        fprintf('Procesando %d/3: %s\n', i, nombres_cortos{i});

        y = generamelodia(melodia, tempo_sintesis_bpm, 0);
        audiowrite(ruta_wav_salida, y, 44100);
        fprintf('Archivo .wav generado correctamente en carpeta fase2: %s\n', ruta_wav_salida);
    end

    fprintf('\nSíntesis y guardado WAV completados.\n');
end

fprintf('\nTodos los archivos .m y .wav fueron guardados correctamente en la carpeta fase2/.\n');
fprintf('\nProceso finalizado con éxito.\n');
