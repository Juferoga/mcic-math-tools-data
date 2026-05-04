% Actividad 2 - Uso de mmkk
% Este script demuestra cómo usar la función mmkk.m
% Genera tiempos entre arribos y tiempos de servicio exponenciales
% para 100000 usuarios, con k = 5 servidores.

usuarios = 100000;
lambda = 3; % Tasa de arribos
mu = 4;     % Tasa de servicio

% Tiempos entre arribos exponenciales (lambda)
tiempoentrearribos = exprnd(1 / lambda, usuarios, 1);

% Tiempos de servicio exponenciales (mu)
tiemposdeservicio = exprnd(1 / mu, usuarios, 1);

k = 5;

Pk = mmkk(tiempoentrearribos, tiemposdeservicio, k);

disp("Resultado Pk:");
disp(Pk);
