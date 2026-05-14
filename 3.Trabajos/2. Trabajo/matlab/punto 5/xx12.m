function pk = xx12(A,k,mostrar)
% xx12  Probabilidad de bloqueo p_k = P[N=k] del sistema M/M/k/k
%       calculada por la recursion de Erlang B:
%
%           p_n = A*p_{n-1} / (n + A*p_{n-1}),    p_0 = 1.
%
%   Entradas:
%     A       : real positivo, A = lambda/mu
%     k       : entero positivo, numero de servidores
%     mostrar : 1 -> imprime A, k y pk; por defecto 0.

    switch nargin
        case 2
            mostrar = 0;
    end

    % Validacion minima
    if A < 0 || k < 1 || k ~= floor(k)
        error('A debe ser >=0 y k entero positivo.');
    end

    pk = 1;                         % p_0 = 1
    for n = 1:k
        pk = (A*pk)/(n + A*pk);     % recursion
    end

    if mostrar == 1
        A
        k
        pk
    end
end