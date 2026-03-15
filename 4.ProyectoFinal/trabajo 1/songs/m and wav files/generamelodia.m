function y = generamelodia(melodia,tempo,suenaograba,acompanamiento)
%% Función GENERAMELODIA
% Esta función sintetiza una melodia, con compás de 4/4, de acuerdo a la
% codificación de una tablatura de guitarra acústica. Para conseguirlo,
% GENERAMELODIA utiliza la función acorde, que emplea el algoritmo base de
% Karplus - Strong. Los argumentos de entrada de la función son:
% 
% - melodia: es una matriz de 7 u 8 columnas que tiene la información de
% los trastes de la guitarra que se deben tocar y el tiempo relativo de
% cada compás. Los primeros seis (6) valores, de cada fila de la matriz,
% deben corresponder al valor del traste que toca cada cuerda. Si el valor
% es 0, la cuerda se toca al aire; si es -1, no se toca. El séptimo valor
% debe corresponder al tiempo relativo de cada nota: 1, para completa; 1/2,
% para corchea, etc. El octavo valor es opcional y corresponde al tiempo,
% en segundos, entre cuerda y cuerda (para más imformación, se sugiere
% revisar el texto de ayuda de la función ACORDE).
% - tempo: es el valor del tempo en bpm. Es un valor opcional y por defecto
% se asume que es de 60 bpm.
% - suenaograba: 0, solo sintetiza la melodia; 1, la reproduce; 2, la graba
% en el archivo melodiaks.wav; 3, la reproduce y la graba. Es un valor
% opcional y por defecto es 1.
% - acompanamiento: es una matriz que debe presentar las mismas
% caracteristicas que la matriz melodia. Es una matriz opcional y por
% defecto se iguala a lo que se haya indicado en melodia. Cuando se indica
% se asocia con el canal izquierdo (y la melodia con el derecho).
%
% Ejemplo 1:
%
% Si se desean sintetizar los dos compases iniciales de Gerudo Valley, se
% puede ejecutar:
%
% melodia = [...
%     -1 4 -1 -1 -1 -1 1/16;...
%     -1 -1 6 -1 -1 -1 1/16;...
%     -1 -1 -1 4 -1 -1 1/8;...
%     -1 -1 -1 7 -1 -1 1/8;...
%     -1 -1 -1 -1 7 -1 1/8;...
%     -1 -1 -1 -1 10 -1 1/8;...
%     -1 -1 -1 -1 6 -1 1/16;...
%     -1 -1 -1 -1 9 -1 1/16;...
%     -1 -1 -1 -1 -1 7 1/16;...
%     -1 -1 -1 -1 -1 9 11/16;...
%     -1 -1 -1 -1 -1 -1 1/2;...
%     ];
% 
% tempo = 120; % En bpm
% generamelodia(melodia,tempo,1);
%
% Ejemplo 2:
%
% Si se desean sintetizar los primeros seis compases de Bolero Falaz, se
% puede ejecutar:
%
% melodia = [...
%     0 -1 -1 -1 -1 -1 3/16 0;...
%     -1 2 2 1 -1 -1 3/16 0;...
%     -1 2 2 1 0 -1 3/16 0;...
%     0 -1 -1 -1 -1 -1 3/16 0;...
%     2 -1 -1 -1 -1 -1 3/16 0;...
%     -1 4 4 2 -1 -1 3/16 0;...
%     -1 4 4 2 2 2 3/16 0;...
%     2 -1 -1 -1 -1 -1 3/16 0;...
%     4 -1 -1 -1 -1 -1 3/16 0;...
%     -1 6 6 4 4 4 3/16 0;...
%     4 -1 -1 -1 -1 -1 3/16 0;...
%     3 -1 -1 -1 -1 -1 3/16 0;...
%     -1 5 5 3 3 3 3/16 0;...
%     2 -1 -1 -1 -1 -1 3/16 0;...
%     -1 -1 4 4 4 2 3/16 0;...
%     -1 -1 4 4 4 2 3/16 0;...
%     -1 -1 4 4 4 2 3/16 0;...
%     -1 2 -1 -1 -1 -1 3/16 0;...
%     -1 2 1 2 0 2 3/16 0;...
%     -1 2 1 2 0 2 3/16 0;...
%     -1 2 1 2 0 2 1/4 0;...
%     0 2 2 1 0 0 23/16 0.005;...
%     ];
% 
% tempo = 145; % En bpm
% generamelodia(melodia,tempo,1);
%
% Función GENERAMELODIA, Versión 1.0, 11 de septiembre de 2020.
% Elaborada por Hans López, hilopezc@udistrital.edu.co
% Funciones requeridas para su ejecución: acorde.
    switch nargin
        case 1
            tempo = 60;
            suenaograba = 1;
            acompanamiento = melodia;
        case 2
            suenaograba = 1;
            acompanamiento = melodia;
        case 3
            acompanamiento = melodia;
    end
    
    [f,c] = size(acompanamiento);
    if c == 7
        acompanamiento = [acompanamiento,zeros(f,1)]; % agrega la columna de ceros (sin retardo)
    end
    a = [];
    for n = 1:f
        a = [a,acorde(acompanamiento(n,:),tempo,0)];    
    end
    
    [f,c] = size(melodia);
    if c == 7
        melodia = [melodia,zeros(f,1)]; % agrega la columna de ceros (sin retardo)
    end
    m = [];
    for n = 1:f
        m = [m,acorde(melodia(n,:),tempo,0)];    
    end

    na = numel(a);
    nm = numel(m);
    if na < nm
        m = m(1:na);
    else
        a = a(1:nm);
    end
    y = [a;m]';
    
    switch suenaograba
        case 1
            sound(y,44100);
        case 2
            audiowrite('melodiaks.wav',y,44100);
        case 3
            sound(y,44100);
            audiowrite('melodiaks.wav',y,44100);
    end
end