function x = tinv(p, nu)
%TINV  Cuantil de la distribucion t de Student (aproximacion)
%   x = tinv(p, nu) devuelve el cuantil p para una t con nu grados de libertad
%
%   Implementacion standalone para compatibilidad sin Statistics Toolbox.
%   Para nu > 30 usa la aproximacion normal (1.96 para p=0.975).
%   Para valores menores usa la aproximacion de Wallace (1959).

if p < 0 || p > 1
    error('p debe estar en [0,1]');
end
if nu <= 0
    error('nu debe ser positivo');
end

% Casos extremos
if p == 0.5
    x = 0;
    return;
end
if p < 0.5
    signo = -1;
    p = 1 - p;
else
    signo = 1;
end

% Para nu grande (>30), aproximacion normal
if nu > 30
    x = signo * norminv(p);
    return;
end

% Aproximacion de Wallace (1959) para nu <= 30
z = norminv(p);
h = nu / 2;
a = 4 * h + 1;
b = z * sqrt(a);
c = 1 - b^2 / (4 * h);

if c < 0
    c = 0;
end

x = signo * b / sqrt(c);

end

function z = norminv(p)
%NORMINV  Cuantil de la distribucion normal estandar (aproximacion)
%   Aproximacion de Abramowitz & Stegun (1964), formula 26.2.23

if p <= 0
    z = -inf;
    return;
elseif p >= 1
    z = inf;
    return;
end

% Simetria
if p > 0.5
    signo = 1;
    p = 1 - p;
else
    signo = -1;
end

% Constantes
c = [2.515517, 0.802853, 0.010328];
d = [1.432788, 0.189269, 0.001308];

% Calculo
t = sqrt(-2 * log(p));
z = signo * (t - ((c(3)*t + c(2))*t + c(1)) / (((d(3)*t + d(2))*t + d(1))*t + 1));

end
