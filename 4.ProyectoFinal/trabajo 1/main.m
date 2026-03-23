% ======== MAIN: ORQUESTADOR GENERAL DEL PROYECTO ========
% Ejecuta en orden:
%   1) fase2_independencia.m
%   2) fase3_markov_tiempos.m
%   3) fase5_generador_final.m

clear;
clc;

fprintf('\n');
fprintf('==========================================================================\n');
fprintf(' INICIO DE EJECUCIÓN GLOBAL - PROYECTO GENERADOR DE MELODÍAS (FASES 2-3-5)\n');
fprintf('==========================================================================\n\n');

% ======== CONFIGURACIÓN DE RUTA GLOBAL ========
addpath('songs/m and wav files');
fprintf('Ruta agregada correctamente: songs/m and wav files\n\n');

tiempo_total_inicio = tic;

try
    % ======== FASE 2 ========
    fprintf('>>> Ejecutando FASE 2: Independencia estadística...\n');
    run('fase2_independencia.m');
    fprintf('>>> FASE 2 finalizada correctamente.\n\n');

    % ======== PAUSA / SEPARADOR ========
    fprintf('--------------------------------------------------------------\n');
    fprintf(' Pausa breve antes de continuar con la siguiente fase...\n');
    fprintf('--------------------------------------------------------------\n\n');
    pause(2);

    % ======== FASE 3 ========
    fprintf('>>> Ejecutando FASE 3: Markov sobre tiempos relativos...\n');
    run('fase3_markov_tiempos.m');
    fprintf('>>> FASE 3 finalizada correctamente.\n\n');

    % ======== FASE 5 ========
    fprintf('>>> Ejecutando FASE 5: Generador final de melodías...\n');
    run('fase5_generador_final.m');
    fprintf('>>> FASE 5 finalizada correctamente.\n\n');

    tiempo_ejecucion = toc(tiempo_total_inicio);

    % ======== RESUMEN FINAL ========
    fprintf('==========================================================================\n');
    fprintf(' EJECUCIÓN GLOBAL COMPLETADA CON ÉXITO\n');
    fprintf('==========================================================================\n');
    fprintf('Tiempo total de ejecución: %.2f segundos\n\n', tiempo_ejecucion);
    fprintf('Archivos generados:\n');
    fprintf('  - Fase 2 (.m y .wav): carpeta fase2/\n');
    fprintf('  - Fase 3 (.m y .wav): carpeta fase3/\n');
    fprintf('  - Fase 5 (.m y .wav): carpeta fase5/\n\n');
    fprintf('Ruta base de trabajo: 4.ProyectoFinal/trabajo 1/\n');
    fprintf('Listo. Puedes revisar y reproducir los resultados generados.\n');
    fprintf('==========================================================================\n\n');

catch ME
    fprintf('\n');
    fprintf('==========================================================================\n');
    fprintf(' ERROR DURANTE LA EJECUCIÓN GLOBAL\n');
    fprintf('==========================================================================\n');
    fprintf('Mensaje: %s\n', ME.message);
    fprintf('Archivo : %s\n', ME.stack(1).file);
    fprintf('Línea   : %d\n', ME.stack(1).line);
    fprintf('==========================================================================\n\n');
    rethrow(ME);
end
