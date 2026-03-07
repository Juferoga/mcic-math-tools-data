experimentos = 100000;
resultados = zeros(1, experimentos);
frecuencias = zeros(1,2);

for n = 1:experimentos
     resultados(n) = moneda();
end

resultados;
frecuencias(1) = sum(resultados == 0);
frecuencias(2) = sum(resultados == 1);
fr = frecuencias/experimentos;
bar([0,1],fr);
title(['Validación con ', num2str(experimentos),' experimentos']);
xlabel('Resultados');
ylabel('Frecuencias relativas');
grid on;
set(gcf,"Color",'white');