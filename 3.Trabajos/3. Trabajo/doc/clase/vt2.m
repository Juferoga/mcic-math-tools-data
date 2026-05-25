function [H,Hmin,Hmax] = vt2(traza)
%% Función Varianza - Tiempo
%   vt(traza) realiza el diagrama Varianza - Tiempo de un vector de datos
%   (traza). La regresión lineal se realiza mediante el Método de Mínimos
%   Cuadrados.
%
%   En la leyenda se muestra el estimado del Parámetro de Hurst, H. Tanto
%   la estimación de H, como el intervalo de confianza, se retornan en el
%   orden: H Hmin Hmax (para un 95% de confianza).
%
%   Ejemplo:
%
%   traza = exprnd(1,1,1000000);
%   [H Hmin Hmax] = vt(traza);
%
%   Genera el diagrama varianza - tiempo de una traza de datos
%   exponencialmente distribuida de media 1 y longitud 100000. En H se
%   almacena la estimación del Parámetro de Hurst; en Hmin y Hmax, se
%   almacenan los límites del intervalo de confianza.
%
%   Función vt, Versión 3.0, 26 de mayo de 2017.
%   - Se modifican las etiquetas de los ejes y la leyenda.
%
%   Versión 2.0, 3 de junio de 2016.
%   - Se incluye la función pendienteci().
%   - Se elimina la necesidad de usar la función superplot().
%   - Se realizan ajustes gráficos.
%
%   Versión 1.0, 5 de noviembre de 2015.
%
%   Elaborada por Hans López, hanslop@gmail.com
%
L = length(traza);
gruposmax = fix(L/sqrt(L));
varianza = zeros(1,gruposmax-1);


for n = 2:gruposmax
    columnas = fix(L/n);
    datos = reshape(traza(1:n*columnas),[n,columnas]);
    promedios = mean(datos);
    varianza(n-1) = var(promedios);  
end

x = log10(2:gruposmax);
y = log10(varianza);

[m,b,ml,mh] = pendienteci(x,y);

Hmin = ml/2+1;
H = m/2+1;
Hmax = mh/2+1;
end
%% función para la regresión lineal simple

function [m,b,ml,mh] = pendienteci(x,y)
% Regresión por mínimos cuadrados
A = x*x';
B = sum(x);
C = x*y';
m = (C-B*mean(y))/(A-B*mean(x));
b = mean(y)-m*mean(x);

% Cálculo de s
error = y - m*x - b;
n = length(x);
s = sqrt(error*error'/(n-2));
ex = x - mean(x);
Sxx = ex*ex';

% Cálculo del intervalo de confianza de m

ml = m - tinv(0.975,n-2)*s/sqrt(Sxx);
mh = m + tinv(0.975,n-2)*s/sqrt(Sxx);

end