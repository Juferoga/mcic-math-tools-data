# Trabajo 2

> Vence el 7 de mayo de 2026 18:00. Se cierra el 7 de mayo de 2026 18:00

## Instrucciones
### Resultado de Aprendizaje:

Al completar con éxito el curso de Herramientas Matemáticas para el Manejo de la Información, los estudiantes deberían ser capaces de validar modelos matemáticos mediante técnicas de simulación estadística.
### Indicaciones:

Elaboren un documento en el que se consigne el desarrollo de cada una de las actividades propuestas en el archivo HM20261trabajo2.pdf. No olviden registrar una sección de conclusiones y agregar las citas referenciales que se necesiten.
El día de la entrega, realicen una presentación del trabajo, utilizando, como único recurso, el documento en formato pdf.

# Rúbrica del segundo trabajo grupal: simulación de colas.

* Actividad 1: Resuelve la actividad siguiendo todas las indicaciones propuestas.
* Actividad 2: Resuelve la actividad siguiendo todas las indicaciones propuestas.
* Actividad 3: Resuelve la actiMidait siguiendin todas las indicaciones propuestas
* Actividad 4: Resuelve la actividad siguiendo todas las indicaciones propuestas.
* Actividad 5: Resuelve la actividad siguiendo todas todas las indicaciones propuestas.
* Actividad 6: Resuelve la artMdad siguiendo todas las indicaciones propuestas.
* Conclusiones: Presenta las conclusiones del trabajo utilizando inferencias, propuestas, apilcaciones yoo trabajos futuros. Aunque los argumentos se basan en los resultados obtenides, las conclusiones se distinguen ciaramente de ellos
* Ortografia: Redacta y aplica las reglas de ortografia sin ninguna falta apreciabile o comete menos de diez fattas de ortografia
* Citas referenciales: Utiliza, a lo largo del stocumento, citas referenciales correctamente ubicadas y provenientes de articulos indexados y/o libros especializados en la temática. Al final del documento se presenta el listado de referencias y en el formato escogido por el estudiante (IEEE, por ejemplo).

# Contenido PDF 

Hans López Herramientas Matemáticas 2026-1
Herramientas Matemáticas para el Manejo de la Informa-
ción 2026-1
Segundo trabajo grupal - Simulación de colas.
Fecha de entrega: 7 de mayo de 2026.
Hora máxima de entrega del archivo: 6:00 p. m.
Contenido
Herramientas Matemáticas para el Manejo de la Información 2026-1 1
Objetivo: . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 1
Actividades Propuestas: . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 1
Ejemplo de partida (lo estudiaremos a fondo en clase): . . . . . . . . . . . . . . . . . . . 2
Tarea 10 3
Función mm1 3
Objetivo:
Diseñar y construir una herramienta de simulación, ambientada en el contexto de la teoría de
colas, que permita aplicar los conceptos de independencia, estimación de parámetros y generación
de números aleatorios.
Actividades Propuestas:
1. Construyan el modelo matemático de la cola asignada a su grupo. El modelo debe incluir:
diagrama de transición de estados, ecuaciones de estado estacionario y el procedimiento ma-
temático que permita calcular la medida de desempeño de interés (propabilidad de bloqueo:
Pk, en los sistemasM/M/1/k/∞ y M/M/k/k/∞; y tiempo medio de espera: E[Tw], en el
sistema M/M/k/∞/∞).
2. Diseñen y codifiquen en MATLAB una función que permita simular la cola asignada. Los
parámetros de entrada de la función deben ser: un vector con los tiempos entre arribos
consecutivos y un vector con los tiempos de servicio. El resultado de la simulación debe ser
la estimación de la medida de desempeño.
16 de abril de 2026 Segundo trabajo grupal 1
Hans López Herramientas Matemáticas 2026-1
3. Realicen la simulación de la cola asignada, variando A = λ/μ. Consideren que los elemen-
tos del vector de tiempos entre arribos consecutivos se distribuyen exponencialmente, con
parámetro λ; y que los elementos del vector de tiempos de servicio se distribuyen expo-
nencialmente, con parámetro μ. Como resultado principal, realicen la gráfica de la medida
de desempeño versus A. Verifiquen que los resultados de simulación coincidan con el valor
teórico de la medida de desempeño.
4. Utilicen la función superfuncion (que hará parte de una tarea futura), para generar cuatro
funciones asociadas al conjunto de datos suministrados en clase. Muestren evidencias de la
validez de sus funciones (comparación de las gráficas de las distribuciones de los datos y
gráficas qqplot, por ejemplo).
5. Realicen la simulación de la cola asignada variando A = λ/μ. Consideren que los elementos
del vector de tiempos entre arribos consecutivos, se obtienen con cada una de las cuatro fun-
ciones de la cuarta actividad (para cada función consideren que el parámetro λ, se estima con
el inverso multiplicativo de la media aritmética de los elementos del vector generado con cada
una de las cuatro funciones: λ ≈ 1/Tarribo), y que los elementos del vector de tiempos de servi-
cio se distribuyen exponencialmente, con parámetro μ. Como resultado principal, realicen las
cuatro gráficas de la medida de desempeño versus A. Comparen los resultados de simulación
con el valor teórico (para distribuciones exponenciales) de la medida de desempeño.
6. Identifiquen un escenario real de su disciplina, profesión, campo laboral, o investigación, en
el que puedan aplicar el modelo de la cola asignada, y procedan a realizar una simulación de
ejemplo.
Ejemplo de partida (lo estudiaremos a fondo en clase):
Considérese que en una cola M/M/1/∞/∞, los tiempos de servicio se distribuyen exponencialmen-
te, con parámetro μ; y que los tiempos de arribo se distribuyen exponencialmente, con parámetro
λ.
lambda = 3;
mu = 4;
El valor esperado del tiempo de espera es:
E [Tw] = 1
μ − λ − 1
μ
ETw = (1/(mu-lambda))-(1/mu)
ETw = 0.7500
16 de abril de 2026 Segundo trabajo grupal 2
Hans López Herramientas Matemáticas 2026-1
Simulación de la cola:
usuarios = 100000;
tiempoentrearribos = exprnd(1/lambda,1,usuarios);
tiemposdeservicio = exprnd(1/mu,1,usuarios);
Tw = mm1(tiempoentrearribos,tiemposdeservicio)
Tw = 0.7581
Tarea 10
Individualmente, desarrolle el modelo matemático de la cola asignada a su grupo: plantee el diagra-
ma de transición de estados, obtenga las ecuaciones de estado estacionario, obtenga Pn en función
de P0; y por último, obtenga Pn en función de los parámetros λ y μ.
Función mm1
function [Tw] = mm1(tiempoentrearribos,tiemposdeservicio)
usuarios = length(tiempoentrearribos);
inicio = zeros(1,usuarios);
salida = zeros(1,usuarios);
espera = zeros(1,usuarios);
reloj = cumsum(tiempoentrearribos);
inicio(1) = reloj(1);
for i = 1:usuarios-1
salida(i) = inicio(i) + tiemposdeservicio(i);
espera(i) = inicio(i) - reloj(i);
if salida(i)>reloj(i+1)
inicio(i+1) = salida(i);
else
inicio(i+1) = reloj(i+1);
end
end
salida(usuarios) = inicio(usuarios) + tiemposdeservicio(usuarios);
espera(usuarios) = inicio(usuarios) - reloj(usuarios);
Tw = mean(espera);
end
16 de abril de 2026 Segundo trabajo grupal 3

## Archivos anexos 

SuperFuncion.m 

```m
function [] = superfuncion(datos,nombre)
switch nargin
    case 0
        disp('Falta el vector de datos');
        return;
    case 1
        nombre = 'aleatorio';
end

p = linspace(0,1,100000);
datos = 1.0000000001*datos(:)'; % Materia de Investigación
numero = quantile(datos,p);

encabezado = ['function y = ',nombre,'(m,n)'];
cuerpo = 'numero = [';
final = '];if m==1, y = transpose(numero(randi(numel(numero),m,n))); else, y = numero(randi(numel(numero),m,n));end;end';


fid = fopen([nombre,'.m'],'w');

%fprintf(fid,'%s\n%s\n%10.8f\n%s\n',encabezado,cuerpo,numero,final);
fprintf(fid,'%s\n%s\n%s\n%s\n',encabezado,cuerpo,numero,final);
fclose(fid);
disp([nombre,'.m codificado. Revisa tu carpeta de MATLAB, por favor.']);
disp(['Luego puedes ejecutar: ',nombre,'(m,n).']);
end
```

Y lo que está en assets