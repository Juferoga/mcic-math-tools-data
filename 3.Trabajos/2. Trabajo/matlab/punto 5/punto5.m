%% Actividad 5 - Simulacion M/M/k/k con trazas Bellcore
nombre_traza = 'agostornd'; % Cambiá esto si usás otro archivo de trazas
datos = agostornd(1, 100000);
lambda = 1 / mean(datos);
Amin = 0.1;
Amax = 90;
simulaciones = 100;
usuarios = 100000;
kvalores = [5 20 40 60 100];

for idx = 1:length(kvalores)
    k = kvalores(idx);

    % --- Simulacion ---
    A_sim = linspace(Amin, Amax, simulaciones);
    mu_sim = lambda ./ A_sim;
    pbloqueo = zeros(1, simulaciones);

    for n = 1:simulaciones
        tea = agostornd(1, usuarios);
        % Generación manual de exponencial (sin Statistics Toolbox)
        % tds = exprnd(1/mu_sim(n), 1, usuarios); 
        tds = -log(rand(1, usuarios)) / mu_sim(n);
        pbloqueo(n) = simMMkk(tea, tds, k);
    end

    % --- Teorico (Erlang B) ---
    A_teo = linspace(Amin, Amax, 1000);
    B_teo = zeros(1, length(A_teo));
    for m = 1:length(A_teo)
        B_teo(m) = xx12(A_teo(m), k);
    end

    % --- Grafica ---
    figure;
    superplot(A_teo, B_teo, ...
        sprintf('Probabilidad de Bloqueo - k = %d', k), ...
        '$A$', '$B(k,A)$');
    hold on;
    superplot(A_sim, pbloqueo);
    hold off;
    legend({'Erlang B teórico', 'Agosto (simulado)'}, ...
        'location', 'best');
    xlim([Amin Amax]);

    % --- Exportar ---
    % Crear carpeta dinámica si no existe
    carpeta_export = sprintf('../../doc/plots/act_5/%s/', nombre_traza);
    if ~exist(carpeta_export, 'dir')
        mkdir(carpeta_export);
    end
    
    nombre_archivo = sprintf('%sprob_bloqueo_k%d.png', carpeta_export, k);
    saveas(gcf, nombre_archivo);
    fprintf('Gráfica guardada en: %s\n', nombre_archivo);
end