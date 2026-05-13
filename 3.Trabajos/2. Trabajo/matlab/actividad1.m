% Actividad 1 - Modelo matemático (Erlang B)
% Este script grafica la fórmula teórica de Erlang B (P_k)
% variando el tráfico A desde 0.1 hasta 20 para k = 10 servidores.

k = 10; % Número de servidores
A = 0.1:0.1:20; % Tráfico ofrecido

% Fórmula de Erlang B para P_k
Pk = (A.^k ./ factorial(k)) ./ sum(arrayfun(@(n) A.^n ./ factorial(n), 0:k), 1);

figure;
plot(A, Pk, "LineWidth", 2);
grid on;
xlabel("Tráfico A");
ylabel("Probabilidad de bloqueo P_k");
title("Erlang B (k = 10)");
