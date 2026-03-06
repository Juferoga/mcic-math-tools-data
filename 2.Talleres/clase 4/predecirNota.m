function notaHerramientasMatematicas = predecirNota()
nota = rand;

if nota > (1/15)
    resultado = 4.8
elseif nota > (2/15)
    resultado = 4.9;
elseif nota > (5/15)
    resultado = 4.6;
elseif nota > (11/15)
    resultado = 4.5;
else
    resultado = 4.0;
end


