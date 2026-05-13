function [Pk] = mmkk(tiempoentrearribos,tiemposdeservicio,k)
%MMKK Simula una cola M/M/k/k (sin cola de espera).
%   Pk = MMKK(tiempoentrearribos,tiemposdeservicio,k) retorna la
%   probabilidad de bloqueo estimada a partir de la simulación.

if nargin < 3
    error('mmkk requiere tres argumentos: tiempoentrearribos, tiemposdeservicio, k.');
end

if k <= 0 || floor(k) ~= k
    error('k debe ser un entero positivo.');
end

tiempoentrearribos = tiempoentrearribos(:)';
tiemposdeservicio = tiemposdeservicio(:)';
usuarios = min(length(tiempoentrearribos), length(tiemposdeservicio));

if usuarios == 0
    error('Los vectores de entrada no pueden estar vacios.');
end

tiempoentrearribos = tiempoentrearribos(1:usuarios);
tiemposdeservicio = tiemposdeservicio(1:usuarios);

reloj = cumsum(tiempoentrearribos);
fin_servicio = zeros(1,k);
bloqueados = 0;

for i = 1:usuarios
    t = reloj(i);
    ocupados = fin_servicio > t;

    if sum(ocupados) == k
        bloqueados = bloqueados + 1;
    else
        idx_libre = find(~ocupados, 1, 'first');
        fin_servicio(idx_libre) = t + tiemposdeservicio(i);
    end
end

Pk = bloqueados / usuarios;
end
