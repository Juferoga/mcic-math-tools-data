% ACTIVIDAD 4
% Genera funciones empiricas f1..f4 a partir de trazas Bellcore
% y muestra evidencia con QQ-plot frente a exponencial.

clear; clc;

archivos = {
    '../data/BCOct89Ext.TL', ...
    '../data/BCOct89Ext4.TL', ...
    '../data/BCpAug89.TL', ...
    '../data/BCpOct89.TL'};

nombres_funciones = {'f1','f2','f3','f4'};

figure;
tiledlayout(2,2,'Padding','compact');

for i = 1:numel(archivos)
    t = cargar_tiempo_primera_columna(archivos{i});
    interarribos = diff(t);
    interarribos = interarribos(interarribos > 0 & isfinite(interarribos));

    if isempty(interarribos)
        error('No se pudieron calcular interarribos validos para %s', archivos{i});
    end

    superfuncion(interarribos,nombres_funciones{i});

    lambda_hat = 1/mean(interarribos);
    referencia_exp = exprnd(1/lambda_hat,size(interarribos));

    nexttile;
    qqplot(interarribos,referencia_exp);
    grid on;
    title(sprintf('%s vs Exp(\\lambda=%.4f)',nombres_funciones{i},lambda_hat));
    xlabel('Cuantiles empiricos');
    ylabel('Cuantiles exponenciales');
end

sgtitle('QQ-plot interarribos Bellcore vs exponencial');

function t = cargar_tiempo_primera_columna(ruta)
    try
        M = readmatrix(ruta);
    catch
        M = dlmread(ruta);
    end

    if isempty(M)
        error('Archivo vacio o ilegible: %s', ruta);
    end

    if isvector(M)
        t = M(:);
    else
        t = M(:,1);
    end

    t = t(isfinite(t));

    if numel(t) < 2
        error('No hay suficientes marcas de tiempo en %s', ruta);
    end
end
