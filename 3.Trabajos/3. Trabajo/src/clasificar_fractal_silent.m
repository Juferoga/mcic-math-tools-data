function [H, clasificacion, R2_vt, R2_tau] = clasificar_fractal_silent(muestra, umbral_vt, umbral_tau)
%% clasificar_fractal_silent - Clasificador mono/multifractal SIN graficas
%
%   Version silenciosa de clasificar_fractal para uso en bucles.
%   Usa la misma logica: VT (R^2) -> dwtleader -> tau(q) -> clasificacion.
%
%   [H, clas, R2_vt, R2_tau] = clasificar_fractal_silent(muestra)
%   [H, clas, R2_vt, R2_tau] = clasificar_fractal_silent(muestra, umbral_vt, umbral_tau)

    if nargin < 2, umbral_vt  = 0.85; end
    if nargin < 3, umbral_tau = 0.95; end

    %% Paso 1: VT y R^2
    L = length(muestra);
    gruposmax = fix(L / sqrt(L));
    varianza = zeros(1, gruposmax - 1);

    for n = 2:gruposmax
        columnas = fix(L / n);
        datos = reshape(muestra(1:n*columnas), [n, columnas]);
        promedios = mean(datos);
        varianza(n-1) = var(promedios);
    end

    x = log10(2:gruposmax);
    y = log10(varianza);

    [p_vt, S_vt] = polyfit(x, y, 1);
    SS_res = S_vt.normr^2;
    SS_tot = sum((y - mean(y)).^2);
    R2_vt = 1 - SS_res / SS_tot;
    H = p_vt(1)/2 + 1;

    %% Paso 2: VT alineado?
    if R2_vt < umbral_vt
        clasificacion = 'no clasificable';
        R2_tau = NaN;
        return;
    end

    %% Paso 3: dwtleader -> exponentes de escala
    try
        [~, ~, ~, tauq] = dwtleader(muestra);
    catch
        clasificacion = 'no clasificable';
        R2_tau = NaN;
        return;
    end
    q = -5:5;

    %% Paso 4: Ajuste lineal de tau(q)
    [p_tau, S_tau] = polyfit(q, tauq, 1);
    SS_res_tau = S_tau.normr^2;
    SS_tot_tau = sum((tauq - mean(tauq)).^2);
    R2_tau = 1 - SS_res_tau / SS_tot_tau;

    %% Paso 5: Clasificacion
    if R2_tau >= umbral_tau
        clasificacion = 'monofractal';
    else
        clasificacion = 'multifractal';
    end
end
