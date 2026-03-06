function lanzarDado = dado()
cara = rand

if cara < (1/6)
    lanzarDado = 1;
elseif cara < (2/6)
    lanzarDado = 2;
elseif cara < (3/6)
    lanzarDado = 3;
elseif cara < (4/6)
    lanzarDado = 4;
elseif cara < (5/6)
    lanzarDado = 5;
else
    lanzarDado = 6;
end

