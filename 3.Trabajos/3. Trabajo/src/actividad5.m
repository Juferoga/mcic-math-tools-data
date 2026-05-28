%% Actividad 5 - Clasificacion fractal de intervalos RR (90 pacientes)
%
%  Lee las anotaciones de los 90 registros de la European ST-T Database,
%  calcula los intervalos RR (tiempo entre picos R consecutivos),
%  y aplica el clasificador fractal sin graficas.
%
%  Mejoras respecto a la version inicial:
%    - Filtra anotaciones por tipo (solo beats)
%    - Extrae datos clinicos de los archivos .hea
%    - Analisis de sensibilidad al umbral tau
%
%  Requisito: WFDB Toolbox para MATLAB (rdann)

%% Configuracion
clc; clear;

scriptDir = fileparts(mfilename('fullpath'));
dataDir = fullfile(scriptDir, '..', 'doc', 'data', 'european-st-t-database-1.0.0');
recordsFile = fullfile(dataDir, 'RECORDS');
fs = 250; % Frecuencia de muestreo [Hz]

% Umbrales (mismos que Actividad 4)
umbral_vt  = 0.85;
umbral_tau = 0.95;

% Filtro fisiologico de intervalos RR [segundos]
rr_min = 0.3;  % ~200 bpm
rr_max = 2.0;  % ~30 bpm

% Tipos de anotacion que son beats (WFDB standard)
% N=normal, L=LBBB, R=RBBB, A=APB, a=aberrated APB, V=PVC,
% F=fusion, J=junctional, S=SVP, E=ventricular escape, e=atrial escape, j=junctional escape
beats_validos = 'NLRAaVFJSEej';

%% Leer IDs de pacientes
fid = fopen(recordsFile, 'r');
registros = textscan(fid, '%s');
fclose(fid);
registros = registros{1};
nPacientes = length(registros);

%% Preasignar resultados
H_est           = nan(nPacientes, 1);
R2_vt           = nan(nPacientes, 1);
R2_tau          = nan(nPacientes, 1);
clasificaciones = cell(nPacientes, 1);
nLatidos        = zeros(nPacientes, 1);
nTotal          = zeros(nPacientes, 1);  % anotaciones totales antes de filtrar
H_vt2           = nan(nPacientes, 1);
H_vt2_min       = nan(nPacientes, 1);
H_vt2_max       = nan(nPacientes, 1);
H_LD2           = nan(nPacientes, 1);

% Datos clinicos
edades          = nan(nPacientes, 1);
sexos           = cell(nPacientes, 1);
diagnosticos    = cell(nPacientes, 1);
medicaciones    = cell(nPacientes, 1);
nVasos          = zeros(nPacientes, 1);  % 0=desconocido, 1-3=vasos afectados
tieneIAM        = false(nPacientes, 1);  % infarto de miocardio
tieneHTA        = false(nPacientes, 1);  % hipertension arterial

%% Agregar paths
addpath(fullfile(scriptDir, '..', 'doc', 'clase'));
addpath(scriptDir);

%% Extraer datos clinicos de archivos .hea
fprintf('Extrayendo datos clinicos de archivos .hea...\n');
for i = 1:nPacientes
    heaFile = fullfile(dataDir, [registros{i} '.hea']);
    fid = fopen(heaFile, 'r');
    lineas = {};
    while ~feof(fid)
        linea = fgetl(fid);
        if startsWith(linea, '#')
            lineas{end+1} = linea(2:end); %#ok<SAGROW>
        end
    end
    fclose(fid);

    diagnosticos{i} = '';
    medicaciones{i} = '';
    sexos{i} = '-';

    for j = 1:length(lineas)
        l = strtrim(lineas{j});

        % Edad y sexo
        if startsWith(l, 'Age:')
            tokens = regexp(l, 'Age:\s*(\d+)', 'tokens');
            if ~isempty(tokens)
                edades(i) = str2double(tokens{1}{1});
            end
            tokens = regexp(l, 'Sex:\s*(\w)', 'tokens');
            if ~isempty(tokens)
                sexos{i} = tokens{1}{1};
            end
        end

        % Medicacion
        if startsWith(l, 'Medications:')
            medicaciones{i} = strtrim(l(13:end));
        end

        % Numero de vasos
        if contains(l, '1-vessel'), nVasos(i) = 1; end
        if contains(l, '2-vessel'), nVasos(i) = 2; end
        if contains(l, '3-vessel'), nVasos(i) = 3; end

        % Infarto
        if contains(l, 'myocardial infarction', 'IgnoreCase', true)
            tieneIAM(i) = true;
        end

        % Hipertension
        if contains(l, 'hypertension', 'IgnoreCase', true)
            tieneHTA(i) = true;
        end

        % Diagnostico general (todo excepto Age, Medications, Recorder)
        if ~startsWith(l, 'Age:') && ~startsWith(l, 'Medications:') && ~startsWith(l, 'Recorder')
            if isempty(diagnosticos{i})
                diagnosticos{i} = l;
            else
                diagnosticos{i} = [diagnosticos{i} '; ' l];
            end
        end
    end
end
fprintf('  Datos clinicos extraidos para %d pacientes.\n\n', nPacientes);

%% rdann requiere cd al directorio de datos
originalDir = pwd;
cd(dataDir);

%% Procesamiento principal
fprintf('========================================================================\n');
fprintf('  ACTIVIDAD 5: Clasificacion fractal de intervalos RR - 90 pacientes\n');
fprintf('========================================================================\n\n');

fprintf('%-4s %-8s %-6s %-8s %-8s %-8s %-8s %-8s %-15s\n', ...
    '#', 'ID', 'Beats', 'H_vt', 'H_LD', 'R2_VT', 'R2_tau', 'Edad', 'Clasificacion');
fprintf('%s\n', repmat('-', 1, 82));

for i = 1:nPacientes
    id = registros{i};

    try
        % Leer TODAS las anotaciones
        [ann, anntype] = rdann(id, 'atr');
        nTotal(i) = length(ann);

        % FILTRAR: solo anotaciones que son beats
        esBeat = ismember(anntype, beats_validos');
        ann_beats = ann(esBeat);

        % Calcular intervalos RR en segundos
        rr = diff(ann_beats) / fs;

        % Filtrar intervalos fisiologicamente validos
        rr = rr(rr > rr_min & rr < rr_max);
        nLatidos(i) = length(rr);

        if nLatidos(i) < 100
            clasificaciones{i} = 'insuficiente';
            continue;
        end

        % Clasificar sin graficas
        [H_est(i), clasificaciones{i}, R2_vt(i), R2_tau(i)] = ...
            clasificar_fractal_silent(rr(:)', umbral_vt, umbral_tau);

        % Estimaciones complementarias con vt2 y LD2
        [H_vt2(i), H_vt2_min(i), H_vt2_max(i)] = vt2(rr(:)');
        [H_LD2(i), ~] = LD2(rr(:)');

    catch ME
        clasificaciones{i} = 'error';
        fprintf('  [!] %s: %s\n', id, ME.message);
    end

    fprintf('%-4d %-8s %-6d %-8.4f %-8.4f %-8.4f %-8.4f %-8s %-15s\n', ...
        i, id, nLatidos(i), H_vt2(i), H_LD2(i), R2_vt(i), R2_tau(i), ...
        sprintf('%d/%s', edades(i), sexos{i}), clasificaciones{i});
end

%% Restaurar directorio
cd(originalDir);

%% Resumen general
fprintf('\n========================================================================\n');
fprintf('  RESUMEN DE CLASIFICACION\n');
fprintf('========================================================================\n\n');

mono    = sum(strcmp(clasificaciones, 'monofractal'));
multi   = sum(strcmp(clasificaciones, 'multifractal'));
noClas  = sum(strcmp(clasificaciones, 'no clasificable'));
insuf   = sum(strcmp(clasificaciones, 'insuficiente'));
errores = sum(strcmp(clasificaciones, 'error'));

fprintf('  Monofractal:      %3d  (%5.1f%%)\n', mono,    100*mono/nPacientes);
fprintf('  Multifractal:     %3d  (%5.1f%%)\n', multi,   100*multi/nPacientes);
fprintf('  No clasificable:  %3d  (%5.1f%%)\n', noClas,  100*noClas/nPacientes);
if insuf > 0
    fprintf('  Insuficiente:     %3d  (%5.1f%%)\n', insuf, 100*insuf/nPacientes);
end
if errores > 0
    fprintf('  Errores:          %3d  (%5.1f%%)\n', errores, 100*errores/nPacientes);
end

valido = ~isnan(H_est);
if any(valido)
    fprintf('\n  --- Parametro de Hurst (VT) ---\n');
    fprintf('  Promedio:   %.4f\n', mean(H_est(valido)));
    fprintf('  Desv. est.: %.4f\n', std(H_est(valido)));
    fprintf('  Min:        %.4f\n', min(H_est(valido)));
    fprintf('  Max:        %.4f\n', max(H_est(valido)));
end

validVT  = ~isnan(R2_vt);
validTau = ~isnan(R2_tau);
if any(validVT)
    fprintf('\n  --- R^2 promedios ---\n');
    fprintf('  R2_VT:      %.4f\n', mean(R2_vt(validVT)));
end
if any(validTau)
    fprintf('  R2_tau(q):  %.4f\n', mean(R2_tau(validTau)));
end

%% Impacto del filtrado de beats
fprintf('\n========================================================================\n');
fprintf('  IMPACTO DEL FILTRADO DE ANOTACIONES\n');
fprintf('========================================================================\n\n');
fprintf('  Anotaciones totales promedio:  %.0f\n', mean(nTotal));
fprintf('  Beats validos promedio:        %.0f\n', mean(nLatidos));
fprintf('  Anotaciones descartadas:       %.1f%%\n', ...
    100 * (1 - sum(nLatidos) / sum(nTotal)));

%% Tabla clinica con clasificacion
fprintf('\n========================================================================\n');
fprintf('  TABLA CLINICA + CLASIFICACION FRACTAL\n');
fprintf('========================================================================\n\n');

fprintf('%-6s %-4s %-3s %-8s %-8s %-8s %-15s %-30s\n', ...
    'ID', 'Edad', 'Sex', 'H_vt', 'R2_VT', 'R2_tau', 'Clasificacion', 'Diagnostico');
fprintf('%s\n', repmat('-', 1, 100));

for i = 1:nPacientes
    diag_corto = diagnosticos{i};
    if length(diag_corto) > 30
        diag_corto = [diag_corto(1:27) '...'];
    end
    fprintf('%-6s %-4d %-3s %-8.4f %-8.4f %-8.4f %-15s %-30s\n', ...
        registros{i}, edades(i), sexos{i}, H_vt2(i), R2_vt(i), R2_tau(i), ...
        clasificaciones{i}, diag_corto);
end

%% Analisis por numero de vasos afectados
fprintf('\n========================================================================\n');
fprintf('  CLASIFICACION vs. NUMERO DE VASOS AFECTADOS\n');
fprintf('========================================================================\n\n');

fprintf('  %-12s %-6s %-6s %-6s %-8s %-8s\n', ...
    'Vasos', 'N', 'Mono', 'Multi', 'H_prom', 'R2t_prom');
fprintf('  %s\n', repmat('-', 1, 55));

for v = 0:3
    idx = (nVasos == v) & valido;
    if ~any(idx), continue; end
    if v == 0, label = 'Desconocido'; else, label = sprintf('%d-vessel', v); end
    n_mono = sum(strcmp(clasificaciones(idx), 'monofractal'));
    n_multi = sum(strcmp(clasificaciones(idx), 'multifractal'));
    fprintf('  %-12s %-6d %-6d %-6d %-8.4f %-8.4f\n', ...
        label, sum(idx), n_mono, n_multi, ...
        mean(H_est(idx)), mean(R2_tau(idx & ~isnan(R2_tau))));
end

%% Analisis por presencia de infarto
fprintf('\n========================================================================\n');
fprintf('  CLASIFICACION vs. INFARTO DE MIOCARDIO\n');
fprintf('========================================================================\n\n');

for condicion = [false, true]
    idx = (tieneIAM == condicion) & valido;
    if condicion, label = 'Con IAM'; else, label = 'Sin IAM'; end
    n_mono = sum(strcmp(clasificaciones(idx), 'monofractal'));
    n_multi = sum(strcmp(clasificaciones(idx), 'multifractal'));
    fprintf('  %s (N=%d):\n', label, sum(idx));
    fprintf('    Monofractal:  %d (%.1f%%)\n', n_mono, 100*n_mono/sum(idx));
    fprintf('    Multifractal: %d (%.1f%%)\n', n_multi, 100*n_multi/sum(idx));
    fprintf('    H promedio:   %.4f\n', mean(H_est(idx)));
    fprintf('    R2_tau prom:  %.4f\n\n', mean(R2_tau(idx & ~isnan(R2_tau))));
end

%% Analisis por hipertension
fprintf('========================================================================\n');
fprintf('  CLASIFICACION vs. HIPERTENSION ARTERIAL\n');
fprintf('========================================================================\n\n');

for condicion = [false, true]
    idx = (tieneHTA == condicion) & valido;
    if condicion, label = 'Con HTA'; else, label = 'Sin HTA'; end
    n_mono = sum(strcmp(clasificaciones(idx), 'monofractal'));
    n_multi = sum(strcmp(clasificaciones(idx), 'multifractal'));
    fprintf('  %s (N=%d):\n', label, sum(idx));
    fprintf('    Monofractal:  %d (%.1f%%)\n', n_mono, 100*n_mono/sum(idx));
    fprintf('    Multifractal: %d (%.1f%%)\n', n_multi, 100*n_multi/sum(idx));
    fprintf('    H promedio:   %.4f\n\n', mean(H_est(idx)));
end

%% Analisis de sensibilidad al umbral tau
fprintf('========================================================================\n');
fprintf('  SENSIBILIDAD AL UMBRAL DE tau(q)\n');
fprintf('========================================================================\n\n');

fprintf('  %-12s %-8s %-8s %-8s\n', 'Umbral_tau', 'Mono', 'Multi', 'NoClas');
fprintf('  %s\n', repmat('-', 1, 40));

for u_tau = [0.80, 0.85, 0.90, 0.95]
    n_mono_s = sum(R2_tau >= u_tau & ~isnan(R2_tau));
    n_multi_s = sum(R2_tau < u_tau & ~isnan(R2_tau));
    n_noclas_s = sum(isnan(R2_tau) & valido) + sum(~valido);
    fprintf('  %-12.2f %-8d %-8d %-8d\n', u_tau, n_mono_s, n_multi_s, n_noclas_s);
end

fprintf('\n  Nota: el umbral actual es %.2f. Valores mas altos son mas\n', umbral_tau);
fprintf('  exigentes para clasificar como monofractal.\n');

%% Exportar CSV con datos clinicos
csvPath = fullfile(scriptDir, 'resultados_actividad5.csv');
T = table((1:nPacientes)', registros, edades, sexos, nLatidos, nTotal, ...
    H_vt2, H_vt2_min, H_vt2_max, H_LD2, ...
    H_est, R2_vt, R2_tau, clasificaciones, ...
    nVasos, tieneIAM, tieneHTA, diagnosticos, medicaciones, ...
    'VariableNames', {'Num', 'ID', 'Edad', 'Sexo', 'Beats', 'AnotTotal', ...
    'H_vt2', 'H_vt2_min', 'H_vt2_max', 'H_LD2', ...
    'H_clasificador', 'R2_VT', 'R2_tau', 'Clasificacion', ...
    'Vasos', 'IAM', 'HTA', 'Diagnostico', 'Medicacion'});
writetable(T, csvPath);
fprintf('\nResultados exportados a: %s\n', csvPath);
