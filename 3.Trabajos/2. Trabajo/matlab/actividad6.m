% ACTIVIDAD 6
% Autoescalamiento y limite de Pods en Kubernetes/Docker modelado como M/M/k/k.
%
% Analogia:
% - Cada Pod es un servidor identico que procesa solicitudes HTTP.
% - El sistema NO tiene cola: si llegan mas solicitudes que Pods disponibles,
%   se rechazan (HTTP 503 Service Unavailable).
% - k representa el maximo de Pods permitidos por el autoescalamiento.
% - lambda es la tasa de llegada de peticiones (req/s).
% - mu es la tasa de servicio de cada Pod (req/s).
% - La probabilidad de bloqueo (Pk) es la probabilidad de Error 503.

clear; clc;

k = 20;          % Maximo numero de Pods (servidores) permitidos
mu = 10;         % Tasa de servicio por Pod (req/s)
usuarios = 100000; % Numero de solicitudes simuladas por cada lambda

% Rango de tasas de llegada de peticiones HTTP (req/s)
lambdas = 10:5:250;

Pk_sim = zeros(size(lambdas));

for i = 1:numel(lambdas)
    lambda = lambdas(i);

    % Interarribos ~ Exponencial(lambda): tiempos entre solicitudes HTTP
    tiempoentrearribos = exprnd(1/lambda, 1, usuarios);

    % Servicios ~ Exponencial(mu): tiempo de procesamiento por Pod
    tiemposdeservicio = exprnd(1/mu, 1, usuarios);

    % Probabilidad de rechazo (HTTP 503) usando el modelo M/M/k/k
    Pk_sim(i) = mmkk(tiempoentrearribos, tiemposdeservicio, k);
end

figure;
plot(lambdas, Pk_sim, 'o-', 'LineWidth', 1.5);
grid on;
xlabel('Tasa de peticiones \lambda (req/s)');
ylabel('Probabilidad de Error 503 (bloqueo)');
title(sprintf('M/M/%d/%d: Probabilidad de rechazo vs tasa de llegada', k, k));

% Comentarios adicionales sobre la analogia:
% - Cuando lambda << k*mu, casi siempre hay Pods libres y Pk ~ 0.
% - Cuando lambda se aproxima o supera k*mu, los Pods se saturan y Pk crece.
% - Esto modela un limite duro de autoescalamiento: no hay mas Pods disponibles,
%   por lo que la carga extra se rechaza inmediatamente (503).
