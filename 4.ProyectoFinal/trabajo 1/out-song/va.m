function y = va(x,p,filas,columnas)
% Función VA(x,p,filas,columnas)
% La función VA(x,p,filas,columnas) retorna una matriz de tamaño filas por
% columnas. Los elementos de la matriz pertenecen a los números indicados
% en el vector x. La probabilidad de ocurrencia de cada elemento de x se
% debe indicar en el vector p.
%
% Ejemplo:
%
% x = [1 2 3];
% p = [0.2 0.3 0.5];
% VA(x,p,1,10)
%
% Retorna un vector fila de 10 elementos, que contiene aleatoriamente los
% números del 1 al 3. En promedio, dos elementos deberían ser 1, tres
% elementos deberían ser 2 y cinco deberían ser 3
%
% Ejemplo:
%
% x = [-2 1];
% p = [0.3 0.7];
% VA(x,p,10)
%
% Retorna una matriz de 10x10, que contiene aleatoriamente los números -2
% y 1. En promedio, treinta elementos deberían ser -2 y setenta deberían
% ser iguales a 1
%
% Ejemplo:
%
% x = [0 1 3];
% p = [0.2 0.3 0.5];
% VA(x,p)
%
% Retorna aleatoriamente uno de los números que pertenecen al vector x. Las
% probabilidades de ocurrencia son: 20%, para que retorne el 0; 30%, para
% que retorne el 1; y 50%, para que retorne el 3.
%
% Función VA, Versión 4.0
% Elaborada por Hans López, hanslop@gmail.com
%
% Versión 4.0. 20 de septiembre de 2019. Se corrigió el error de dimensión
% causado con los vectores columnas (antes se generaba un vector fila, en
% vez de uno columna).
% Versión 3.0. 28 de febrero de 2017. Se corrigió y complementó el texto de
% la ayuda.
%
% Versión 2.0. 22 de agosto de 2016. Corregido el error presentado al
% utilizar menos de tres argumentos de entrada.
    switch nargin
        case 0
            help va;
            return;
        case 1
            help va;
            return;
        case 2
            y = rand;
            columnas = 1;
        case 3
            y = rand(filas);
            columnas = filas;
        case 4
            y = rand(filas,columnas);
    end

    cdf = cumsum(p);
    total = numel(x);

    pos = 1;

    for n = 1:total-1
        pos = pos + (y>=cdf(n));
    end
    if columnas == 1
        y = x(pos)';
    else
        y = x(pos);
    end
end