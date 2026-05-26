%% Actividad 4 - Validacion del clasificador mono/multifractal
%
%  Se valida clasificar_fractal con:
%    - wfbm  (monofractal)  -> debe clasificar como monofractal
%    - betamwm (multifractal) -> debe clasificar como multifractal

%% Validacion con monofractal (wfbm)
H_teorico = 0.8;
muestra_mono = diff(wfbm(H_teorico, 2^17));

fprintf('\n=== MONOFRACTAL (wfbm, H = %.1f) ===\n', H_teorico);
[H_mono, clas_mono, R2vt_mono, R2tau_mono] = clasificar_fractal(muestra_mono);
fprintf('  H estimado:     %.4f\n', H_mono);
fprintf('  Clasificacion:  %s\n', clas_mono);
fprintf('  R2 VT:          %.4f\n', R2vt_mono);
fprintf('  R2 tau(q):      %.4f\n', R2tau_mono);

%% Validacion con multifractal (betamwm)
muestra_multi = betamwm(1, 17, H_teorico);

fprintf('\n=== MULTIFRACTAL (betamwm, H = %.1f) ===\n', H_teorico);
[H_multi, clas_multi, R2vt_multi, R2tau_multi] = clasificar_fractal(muestra_multi);
fprintf('  H estimado:     %.4f\n', H_multi);
fprintf('  Clasificacion:  %s\n', clas_multi);
fprintf('  R2 VT:          %.4f\n', R2vt_multi);
fprintf('  R2 tau(q):      %.4f\n', R2tau_multi);

%% Validacion con secuencia independiente (randn, N=100000)
fprintf('\n=== SECUENCIA INDEPENDIENTE (randn, N=100000) ===\n');
muestra_iid = randn(1, 100000);
[H_iid, clas_iid, R2vt_iid, R2tau_iid] = clasificar_fractal(muestra_iid);
fprintf('  H estimado:     %.4f\n', H_iid);
fprintf('  Clasificacion:  %s\n', clas_iid);
fprintf('  R2 VT:          %.4f\n', R2vt_iid);
fprintf('  R2 tau(q):      %.4f\n', R2tau_iid);

%% Comparacion con varios valores de H
fprintf('\n=== BARRIDO DE H ===\n');
fprintf('%-6s %-10s %-10s %-8s %-8s %-15s %-15s\n', ...
    'H', 'H_mono', 'H_multi', 'R2t_m', 'R2t_M', 'Clas_mono', 'Clas_multi');
fprintf('%s\n', repmat('-', 1, 80));

for H_test = [0.6 0.7 0.8 0.9]
    % Monofractal
    m_mono = diff(wfbm(H_test, 2^17));
    [Hm, cm, ~, R2m] = clasificar_fractal(m_mono);
    close;

    % Multifractal
    m_multi = betamwm(1, 17, H_test);
    [Hmm, cmm, ~, R2mm] = clasificar_fractal(m_multi);
    close;

    fprintf('%-6.1f %-10.4f %-10.4f %-8.4f %-8.4f %-15s %-15s\n', ...
        H_test, Hm, Hmm, R2m, R2mm, cm, cmm);
end
