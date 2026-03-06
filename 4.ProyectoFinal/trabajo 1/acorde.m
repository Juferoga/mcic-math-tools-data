function salida = acorde(trastes,tempo,suena)
%% Función ACORDE
% Esta función utiliza el algoritmo base de Karplus-Strong para generar una
% secuencia discreta que sintetiza el sonido de un acorde de guitarra. Los
% argumentos de entrada de la función son:
%
% - trastes: es un vector fila de dimensiones 1x8. Los primeros seis (6)
% valores corresponden al valor del traste que toca cada cuerda. Si el
% valor es 0, la cuerda se toca al aire; si es -1, no se toca. El séptimo
% valor corresponde al tiempo relativo de cada nota: 1, para completa; 1/2,
% para corchea, etc. El octavo valor es el tiempo, en segundos, que existe
% entre cuerda y cuerda. Si el valor es cero, todas las cuerdas se tocan
% al tiempo; si es positivo, se toca primero desde la cuerda más gruesa,
% hacia abajo; si es negativo, se toca primero desde la cuerda más delgada,
% hacia arriba.  
% - tempo: es el valor del tempo en bpm. Es un valor opcional y por defecto
% se asume que es de 60 bpm.
% - suena: si su valor es 1 permite escuchar directamente el acorde. En un
% valor opcional y por defecto es 1.
%
% La función ACORDE retorna un vector fila cuyo contenido corresponde a la
% secuencia discreta sintetizada.
%
% Ejemplo 1:
%
% Si se desea generar el acorde mayor G, para un tempo de 60 bpm, se debe
% ejecutar:
%
% ACORDE([3,2,0,0,0,3,1,0]);
%
% Ejemplo 2:
%
% Si se desean tocar solo las cuerdas: 1, 5 y 6, del ejemplo anterior, se
% podría ejecutar:
%
% ACORDE([3,2,-1,-1,-1,3,1,0]);
%
% Ejemplo 3:
%
% Si se desean tocar los trastes 4 y 5, únicamente para las cuerdas 1 y 3,
% durante una corchea (medio tiempo), con un tempo de 120 bpm; se puede
% ejecutar:
%
% tempo = 120; % tempo en bpm
% duracion = 1/2; % corchea
% ACORDE([-1,-1,-1,5,-1,4,duracion,0],tempo);
%
% Ejemplo 4:
%
% Si se desean rasgar todas cuerdas, tocando el traste 3, de arriba
% hacia abajo, se puede incluir el tiempo que pasa entre cuerda y cuerda
% así:
%
% tempo = 120; % tempo en bpm
% duracion = 1/2; % corchea
% retardo = 0.015; % retardo de 15 ms
% ACORDE([3,3,3,3,3,3,duracion,retardo],tempo);
%
% Ejemplo 5:
%
% Si se desean rasgar todas cuerdas, del acorde mayor G, de abajo hacia
% arriba, con un retardo entre cuerdas de 100 ms, se puede ejecutar: 
%
% tempo = 60; % tempo en bpm
% duracion = 3/4; % H. = 1/2 + 1/4
% retardo = -0.1; % retardo de 100 ms. El signo negativo indica el sentido.
% ACORDE([3,2,0,0,0,3,duracion,retardo],tempo);
%
% Función ACORDE, Versión 1.0, 1 de mayo de 2020
% Elaborada por Hans López, hilopezc@udistrital.edu.co
switch nargin
        case 0
            trastes = [0,0,0,0,0,0,1,0];
            tempo = 60;
            suena = 1;
        case 1
            tempo = 60;
            suena = 1;
        case 2
            suena = 1;
    end
    
    figura = trastes(7);
    retardo = abs(trastes(8));
    D = figura*240/tempo;   
    
    fs = 44100;
    N = floor(D*fs);
    F0 = 110;
    Eoffset = -5;
    Doffset = 5;
    Goffset = 10;
    Boffset = 14;
    E2offset = 19;
    delta = floor(retardo*fs); %retardo en muestras
    

    T = [round(fs/(F0*2^((trastes(1)+Eoffset)/12))), ...
        round(fs/(F0*2^(trastes(2)/12))), ...
        round(fs/(F0*2^((trastes(3)+Doffset)/12))), ...
        round(fs/(F0*2^((trastes(4)+Goffset)/12))), ...
        round(fs/(F0*2^((trastes(5)+Boffset)/12))), ...
        round(fs/(F0*2^((trastes(6)+E2offset)/12)))]; % Tomado de Mathworks

    y = zeros(6,N);
    z = zeros(6,N);
    for n = 1:6
        x = 2*rand(1,T(n))-1;
        if trastes(n) ~= -1
            y(n,1:T(n)) = x;
            for i = 1:N-T(n)
                y(n,T(n)+i)=(y(n,i)+y(n,i+1))/2;
            end
            if trastes(8) >= 0
                z(n,:) = [y(n,1:N-6*delta),zeros(1,6*delta)];
                z(n,:) = circshift(z(n,:),(n-1)*delta);
            else
                z(n,:) = [zeros(1,6*delta),y(n,1:N-6*delta)];
                z(n,:) = circshift(z(n,:),-(n-1)*delta);
            end
        end
    end
    salida = sum(z);
    if max(abs(salida))~=0
        salida = salida/max(abs(salida));
    end
        
    if suena == 1
        sound(salida,fs);
    end
end