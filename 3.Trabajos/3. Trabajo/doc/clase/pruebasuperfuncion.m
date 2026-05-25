%% Creación del generador de números aleatorios
muestra = exprnd(1,1,100000);
superfuncion(muestra);

%% Validación
muestra = aleatorio(1,10000);
qqplot(muestra,exprnd(1,1,10000));
