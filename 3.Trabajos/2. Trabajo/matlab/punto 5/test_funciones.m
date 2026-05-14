%% Test de funciones críticas
disp('=== Test de xx12.m ===');
A_test = [0.1, 1, 10, 50, 90];
k_test = 5;
for A = A_test
    result = xx12(A, k_test);
    fprintf('A=%.1f, k=%d => B=%.6f\n', A, k_test, result);
    if isnan(result) || isinf(result)
        warning('ALERTA: Valor inválido detectado');
    end
end

disp('=== Test de simMMkk.m ===');
tea = [0.01 0.02 0.01 0.03 0.02];
tds = [0.1 0.2 0.15 0.1 0.2];
k_test = 2;
pb = simMMkk(tea, tds, k_test);
fprintf('Probabilidad de bloqueo: %.6f\n', pb);

disp('=== Test de agostornd.m (primeras 10) ===');
datos = agostornd(1, 10);
disp(datos);

disp('=== Test de cálculo con trazas (100 usuarios) ===');
tic;
datos = agostornd(1, 100);
lambda = 1 / mean(datos);
fprintf('Lambda: %.6f\n', lambda);
A_sim = linspace(0.1, 90, 10);  % Solo 10 puntos para prueba
mu_sim = lambda ./ A_sim;
pbloqueo = zeros(1, 10);
for n = 1:10
    tea = agostornd(1, 100);
    tds = -log(rand(1, 100)) / mu_sim(n);
    pbloqueo(n) = simMMkk(tea, tds, 5);
    fprintf('Punto %d/%d completado\n', n, 10);
end
elapsed = toc;
fprintf('Tiempo de prueba (100 usuarios, 10 puntos): %.2f segundos\n', elapsed);
