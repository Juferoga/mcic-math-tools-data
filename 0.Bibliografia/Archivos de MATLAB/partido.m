function resultado = partido()
    p = rand;
    if p < 0.7
        resultado = 0;
    elseif p < 0.9
        resultado = 1;
    else
        resultado = 3;
    end
end