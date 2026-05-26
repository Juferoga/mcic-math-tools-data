function [H, clasificacion, R2_vt, R2_tau] = clasificar_fractal(muestra, umbral_vt, umbral_tau)
%% clasificar_fractal - Clasifica una muestra como mono o multifractal
%
%   Sigue el diagrama de flujo de la Actividad 4:
%     1. Calcular VT y verificar alineacion (R^2)
%     2. Si NO alinea -> "no clasificable"
%     3. Si alinea -> dwtleader -> exponentes de escala tau(q)
%     4. Ajuste lineal de tau(q): R^2 alto -> mono, R^2 bajo -> multi
%     5. Graficar: VT, LD, exponentes de escala, espectro multifractal
%
%   [H, clas] = clasificar_fractal(muestra)
%   [H, clas, R2_vt, R2_tau] = clasificar_fractal(muestra, umbral_vt, umbral_tau)
%
%   Entradas:
%     muestra     - vector de datos
%     umbral_vt   - R^2 minimo para VT (default: 0.90)
%     umbral_tau  - R^2 de tau(q) lineal: >= umbral -> mono (default: 0.70)
%
%   Salidas:
%     H             - Parametro de Hurst estimado via VT
%     clasificacion - 'monofractal', 'multifractal', o 'no clasificable'
%     R2_vt         - R^2 de la regresion VT
%     R2_tau        - R^2 del ajuste lineal de tau(q)

    if nargin < 2, umbral_vt  = 0.85; end
    if nargin < 3, umbral_tau = 0.90; end

    %% Paso 1: Calcular VT y su R^2
    [H, R2_vt, x_vt, y_vt, p_vt] = vt_r2(muestra);

    %% Paso 2: Puntos alineados en VT?
    if R2_vt < umbral_vt
        % Ruta (a): no se puede clasificar
        clasificacion = 'no clasificable';
        R2_tau = NaN;

        figure;
        plot(x_vt, y_vt, 's', 'MarkerFaceColor', 'b');
        hold on;
        plot(x_vt, polyval(p_vt, x_vt), 'r', 'LineWidth', 2);
        hold off;
        grid on;
        title(sprintf('VT - No clasificable (R^2 = %.4f)', R2_vt), 'FontSize', 16);
        xlabel('$\log m$', 'FontSize', 16, 'Interpreter', 'latex');
        ylabel('$\log S_{X^{(m)}}^2$', 'FontSize', 16, 'Interpreter', 'latex');
        set(gcf, 'Color', 'white');
        set(gca, 'FontSize', 14);
        return;
    end

    %% Paso 3: VT alineado -> dwtleader -> exponentes de escala
    try
        [dh, h, cp, tauq] = dwtleader(muestra);
    catch
        clasificacion = 'no clasificable';
        R2_tau = NaN;
        figure;
        vt(muestra);
        title(sprintf('VT - No clasificable (datos insuficientes)'), 'FontSize', 16);
        return;
    end
    q = -5:5;

    %% Paso 4: Ajuste lineal de tau(q) y R^2
    [p_tau, S_tau] = polyfit(q, tauq, 1);
    SS_res = S_tau.normr^2;
    SS_tot = sum((tauq - mean(tauq)).^2);
    R2_tau = 1 - SS_res / SS_tot;

    %% Paso 5: Clasificacion
    if R2_tau >= umbral_tau
        clasificacion = 'monofractal';
    else
        clasificacion = 'multifractal';
    end

    %% Paso 6: Graficar VT, LD, exponentes de escala, espectro multifractal
    figure('Position', [100 100 1200 800]);

    % VT
    subplot(2, 2, 1);
    vt(muestra);
    title(sprintf('VT (R^2 = %.4f)', R2_vt), 'FontSize', 14);

    % LD
    subplot(2, 2, 2);
    LD(muestra);

    % Exponentes de escala tau(q)
    subplot(2, 2, 3);
    superplot(q, tauq, 'Exponentes de Escala', '$q$', '$\tau(q)$');
    hold on;
    plot(q, polyval(p_tau, q), 'r--', 'LineWidth', 1.5);
    hold off;
    legend({'$\tau(q)$', sprintf('Lineal $R^2 = %.4f$', R2_tau)}, ...
        'Interpreter', 'latex', 'Location', 'northwest');

    % Espectro multifractal D(h)
    subplot(2, 2, 4);
    superplot(h, dh, 'Espectro Multifractal', '$h$', '$D(h)$');

    sgtitle(sprintf('%s | H = %.4f', upper(clasificacion), H), 'FontSize', 18);
end

%% Funcion interna: VT con R^2
function [H, R2, x, y, p] = vt_r2(traza)
    L = length(traza);
    gruposmax = fix(L / sqrt(L));
    varianza = zeros(1, gruposmax - 1);

    for n = 2:gruposmax
        columnas = fix(L / n);
        datos = reshape(traza(1:n*columnas), [n, columnas]);
        promedios = mean(datos);
        varianza(n-1) = var(promedios);
    end

    x = log10(2:gruposmax);
    y = log10(varianza);

    [p, S] = polyfit(x, y, 1);
    SS_res = S.normr^2;
    SS_tot = sum((y - mean(y)).^2);
    R2 = 1 - SS_res / SS_tot;

    H = p(1)/2 + 1;
end
