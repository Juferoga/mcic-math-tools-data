% =========================================================================
% TAREA 5: SIMULACION DE VARIABLES ALEATORIAS DISCRETAS
% Autor: Juan Felipe Rodriguez G. (20261595004)
% Fecha: Marzo 2026
% Curso: Herramientas Matematicas para el Manejo de la Informacion
% =========================================================================
%
% INSTRUCCIONES DE USO:
% 
% 1. Para ejecutar la validacion completa con graficas:
%    >> validar_tarea5
%
% 2. Para usar la funcion va directamente (cargar primero este archivo):
%    >> Tarea5_JuanFelipeRodriguezG
%    >> resultado = va([1,2,3,4,5,6], [1/6,1/6,1/6,1/6,1/6,1/6])
%    >> moneda = va([0,1], [0.7,0.3])
%
% 3. Desde terminal con Octave:
%    $ octave --eval "source('Tarea5_JuanFelipeRodriguezG.m'); validar_tarea5"
%
% =========================================================================

fprintf('\n========================================================\n');
fprintf('TAREA 5: Simulacion de Variables Aleatorias Discretas\n');
fprintf('========================================================\n');
fprintf('Funciones disponibles:\n');
fprintf('  - va(x,p): Genera una variable aleatoria discreta\n');
fprintf('  - validar_tarea5: Ejecuta validacion completa\n');
fprintf('\nEjemplo de uso:\n');
fprintf('  >> va([1,2,3,4,5,6], [1/6,1/6,1/6,1/6,1/6,1/6])\n');
fprintf('  >> validar_tarea5\n');
fprintf('========================================================\n\n');


% =========================================================================
% FUNCIONES DEL PROGRAMA
% =========================================================================

% FUNCION 1: va(x,p)
% -------------------------------------------------------------------------
% Genera una variable aleatoria discreta con distribucion especificada
%
% PARAMETROS:
%   x - Vector con los valores posibles de la variable aleatoria
%   p - Vector con las probabilidades asociadas a cada valor
%
% RETORNA:
%   valor - Uno de los elementos de x seleccionado segun p
%
% LOGICA:
%   1. Calcula cantidad de elementos con length(x)
%   2. Normaliza probabilidades para que sumen 1
%   3. Genera numero aleatorio u con rand
%   4. Compara u con intervalos acumulados usando if-elseif
%   5. Retorna el valor correspondiente
%
% EJEMPLOS:
%   lanzarDado = va([1,2,3,4,5,6], [1/6,1/6,1/6,1/6,1/6,1/6])
%   moneda = va([0,1], [0.7,0.3])
% =========================================================================

function valor = va(x, p)
    % Determinar automaticamente la cantidad de elementos
    n = length(x);
    
    % Normalizar probabilidades para que sumen 1
    p = p / sum(p);
    
    % Generar numero aleatorio uniforme entre 0 y 1
    u = rand;
    
    % Calcular intervalos acumulados y buscar donde cae u
    % Primer intervalo: [0, p(1))
    if u < p(1)
        valor = x(1);
    % Segundo intervalo: [p(1), p(1)+p(2))
    elseif u < (p(1) + p(2))
        valor = x(2);
    % Para el resto de elementos, calcular la suma acumulada
    else
        suma_acumulada = p(1) + p(2);
        for i = 3:n
            if u < (suma_acumulada + p(i))
                valor = x(i);
                return;
            end
            suma_acumulada = suma_acumulada + p(i);
        end
        % Si no cayó en ninguno anterior, es el último
        valor = x(n);
    end
end


% PARTE B: SCRIPT DE VALIDACION
% =========================================================================
% Este script valida que la funcion va(x,p) funciona correctamente
% estimando frecuencias relativas mediante multiples ejecuciones.
% Se utilizan 3 ejemplos concretos con diferentes distribuciones.
% =========================================================================

function [] = validar_tarea5()
    clc;
    close all;
    
    fprintf('\n========================================================\n');
    fprintf('VALIDACION DE LA FUNCION va(x,p)\n');
    fprintf('========================================================\n\n');
    
    % Numero de repeticiones para cada ejemplo
    N = 50000;
    fprintf('Numero de simulaciones por ejemplo: %d\n\n', N);
    
    % --------------------------------------------------------------------
    % EJEMPLO 1: Dado justo (distribucion uniforme discreta)
    % --------------------------------------------------------------------
    fprintf('--------------------------------------------------------\n');
    fprintf('EJEMPLO 1: Dado justo de 6 caras\n');
    fprintf('--------------------------------------------------------\n');
    
    x1 = [1, 2, 3, 4, 5, 6];
    p1 = [1/6, 1/6, 1/6, 1/6, 1/6, 1/6];
    
    % Inicializar contadores
    conteo1 = [0, 0, 0, 0, 0, 0];
    
    % Realizar simulaciones
    for i = 1:N
        resultado = va(x1, p1);
        
        % Contar cual valor salio (similar a lo visto en clase)
        if resultado == 1
            conteo1(1) = conteo1(1) + 1;
        elseif resultado == 2
            conteo1(2) = conteo1(2) + 1;
        elseif resultado == 3
            conteo1(3) = conteo1(3) + 1;
        elseif resultado == 4
            conteo1(4) = conteo1(4) + 1;
        elseif resultado == 5
            conteo1(5) = conteo1(5) + 1;
        else
            conteo1(6) = conteo1(6) + 1;
        end
    end
    
    % Calcular frecuencias relativas
    frecuencias1 = conteo1 / N;
    
    % Mostrar resultados
    fprintf('\nValor\tP(teorica)\tFrecuencia\tError\n');
    fprintf('-----\t----------\t----------\t-----\n');
    for i = 1:length(x1)
        error = abs(p1(i) - frecuencias1(i));
        fprintf('%d\t%.4f\t\t%.4f\t\t%.4f\n', x1(i), p1(i), ...
                frecuencias1(i), error);
    end
    
    % Grafica de resultados
    figure('Name', 'Ejemplo 1: Dado justo');
    bar([p1; frecuencias1]');
    xlabel('Valor del dado');
    ylabel('Probabilidad');
    title(['Dado justo - ' num2str(N) ' lanzamientos']);
    legend('P(teorica)', 'Frecuencia observada');
    grid on;
    set(gca, 'XTickLabel', {'1','2','3','4','5','6'});
    print('grafica_dado.png', '-dpng', '-r300');
    
    % --------------------------------------------------------------------
    % EJEMPLO 2: Moneda sesgada (distribucion de Bernoulli)
    % --------------------------------------------------------------------
    fprintf('\n--------------------------------------------------------\n');
    fprintf('EJEMPLO 2: Moneda sesgada\n');
    fprintf('--------------------------------------------------------\n');
    fprintf('0 = Cara (70%%), 1 = Sello (30%%)\n');
    
    x2 = [0, 1];
    p2 = [0.7, 0.3];
    
    % Inicializar contadores
    conteo2 = [0, 0];
    
    % Realizar simulaciones
    for i = 1:N
        resultado = va(x2, p2);
        
        if resultado == 0
            conteo2(1) = conteo2(1) + 1;
        else
            conteo2(2) = conteo2(2) + 1;
        end
    end
    
    % Calcular frecuencias relativas
    frecuencias2 = conteo2 / N;
    
    % Mostrar resultados
    fprintf('\nResultado\tP(teorica)\tFrecuencia\tError\n');
    fprintf('---------\t----------\t----------\t-----\n');
    etiquetas2 = {'Cara (0)', 'Sello (1)'};
    for i = 1:length(x2)
        error = abs(p2(i) - frecuencias2(i));
        fprintf('%s\t\t%.4f\t\t%.4f\t\t%.4f\n', etiquetas2{i}, p2(i), ...
                frecuencias2(i), error);
    end
    
    % Grafica de resultados
    figure('Name', 'Ejemplo 2: Moneda sesgada');
    bar([p2; frecuencias2]');
    xlabel('Resultado');
    ylabel('Probabilidad');
    title(['Moneda sesgada - ' num2str(N) ' lanzamientos']);
    legend('P(teorica)', 'Frecuencia observada');
    grid on;
    set(gca, 'XTickLabel', etiquetas2);
    print('grafica_moneda.png', '-dpng', '-r300');
    
    % --------------------------------------------------------------------
    % EJEMPLO 3: Distribucion arbitraria (5 valores)
    % --------------------------------------------------------------------
    fprintf('\n--------------------------------------------------------\n');
    fprintf('EJEMPLO 3: Distribucion arbitraria no uniforme\n');
    fprintf('--------------------------------------------------------\n');
    
    x3 = [10, 20, 30, 40, 50];
    p3 = [0.1, 0.15, 0.35, 0.25, 0.15];
    
    % Inicializar contadores
    conteo3 = [0, 0, 0, 0, 0];
    
    % Realizar simulaciones
    for i = 1:N
        resultado = va(x3, p3);
        
        if resultado == 10
            conteo3(1) = conteo3(1) + 1;
        elseif resultado == 20
            conteo3(2) = conteo3(2) + 1;
        elseif resultado == 30
            conteo3(3) = conteo3(3) + 1;
        elseif resultado == 40
            conteo3(4) = conteo3(4) + 1;
        else
            conteo3(5) = conteo3(5) + 1;
        end
    end
    
    % Calcular frecuencias relativas
    frecuencias3 = conteo3 / N;
    
    % Mostrar resultados
    fprintf('\nValor\tP(teorica)\tFrecuencia\tError\n');
    fprintf('-----\t----------\t----------\t-----\n');
    for i = 1:length(x3)
        error = abs(p3(i) - frecuencias3(i));
        fprintf('%d\t%.4f\t\t%.4f\t\t%.4f\n', x3(i), p3(i), ...
                frecuencias3(i), error);
    end
    
    % Grafica de resultados
    figure('Name', 'Ejemplo 3: Distribucion arbitraria');
    bar([p3; frecuencias3]');
    xlabel('Valor');
    ylabel('Probabilidad');
    title(['Distribucion arbitraria - ' num2str(N) ' observaciones']);
    legend('P(teorica)', 'Frecuencia observada');
    grid on;
    set(gca, 'XTickLabel', {'10','20','30','40','50'});
    print('grafica_arbitraria.png', '-dpng', '-r300');
    
    % --------------------------------------------------------------------
    % RESUMEN Y CONCLUSIONES
    % --------------------------------------------------------------------
    fprintf('\n========================================================\n');
    fprintf('CONCLUSION:\n');
    fprintf('========================================================\n');
    fprintf('Las frecuencias relativas observadas convergen a las\n');
    fprintf('probabilidades teoricas especificadas, validando que\n');
    fprintf('la funcion va(x,p) funciona correctamente.\n\n');
    fprintf('Esto confirma la aplicacion practica de la Ley de los\n');
    fprintf('Grandes Numeros en la simulacion de variables aleatorias.\n\n');
    fprintf('Graficas guardadas como:\n');
    fprintf('  - grafica_dado.png\n');
    fprintf('  - grafica_moneda.png\n');
    fprintf('  - grafica_arbitraria.png\n');
    fprintf('========================================================\n\n');
end

% =========================================================================
% FIN DEL PROGRAMA
% =========================================================================
