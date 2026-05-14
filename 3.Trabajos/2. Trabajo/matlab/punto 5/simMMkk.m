function pbloqueo = simMMkk(tea, tds, k)
% simMMkk  Simula M/M/k/k y devuelve probabilidad de bloqueo.
%   tea : vector de tiempos entre arribos
%   tds : vector de tiempos de servicio
%   k   : numero de servidores

n = length(tea);
servidores = zeros(1, k);   % instante en que cada servidor se libera
bloqueados = 0;
t = 0;

for i = 1:n
    t = t + tea(i);
    servidores(servidores <= t) = 0;    % liberar servidores
    libre = find(servidores == 0, 1);
    if isempty(libre)
        bloqueados = bloqueados + 1;
    else
        servidores(libre) = t + tds(i);
    end
end

pbloqueo = bloqueados / n;
end