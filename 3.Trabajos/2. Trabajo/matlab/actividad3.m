% ACTIVIDAD 3
% Simulacion de una cola M/M/k/k variando A = lambda/mu,
% comparando probabilidad de bloqueo simulada vs. teoria Erlang-B.

clear; clc;

k = 10;                  % Numero de servidores/canales
usuarios = 100000;       % Numero de arribos simulados
mu = 1;                  % Tasa de servicio fija
A_vals = 0.1:0.2:20;     % Trafico ofrecido

Pk_sim = zeros(size(A_vals));
Pk_teo = zeros(size(A_vals));

for i = 1:numel(A_vals)
    A = A_vals(i);
    lambda = A * mu;

    tiempoentrearribos = exprnd(1/lambda,1,usuarios);
    tiemposdeservicio = exprnd(1/mu,1,usuarios);

    Pk_sim(i) = mmkk(tiempoentrearribos,tiemposdeservicio,k);
    Pk_teo(i) = erlangB(A,k);
end

figure;
plot(A_vals,Pk_sim,'o-','LineWidth',1.2,'DisplayName','Simulacion mmkk');
hold on;
plot(A_vals,Pk_teo,'-','LineWidth',2,'DisplayName','Teoria Erlang-B');
grid on;
xlabel('A = \lambda/\mu');
ylabel('P_k (probabilidad de bloqueo)');
title(sprintf('M/M/%d/%d: Simulacion vs Teoria',k,k));
legend('Location','best');

function B = erlangB(A,k)
    n = 0:k;
    B = (A^k/factorial(k)) / sum((A.^n)./factorial(n));
end
