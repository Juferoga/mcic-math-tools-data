function [] = superplot(x,y,titulo,ejex,ejey,grosor,colorlinea)
%   Utiliza la función plot para realizar la gráfica de f(x). SUPERPLOT
%   cambia el fondo de la figura a color blanco y el tamaño de las fuentes.
%   Adicionalmente ajusta de forma automática los límites de las gráficas.
%
%   La función permite agregar el título de la gráfica, y el nombre de los
%   ejes como parámetros de entrada.
%
%   Ejemplo:
%
%   x = linspace(-5,5,1000);
%   SUPERPLOT(x,sinc(x),'Función Seno Cardinal','$x$','sinc($x$)');
%
%   Función SUPERPLOT, Versión 7.0, 6 de mayo de 2026
%   - Se independizaron los límites de las gráficas para que se acepten
%   datos de tipo fecha en el eje x.
%   Versión 6.0, 9 de mayo de 2020
%   - Se corrigió el error que se presentaba al intentar ajustar de manera
%   automática los ejes cuando el vector "y" era constante.
%   Versión 5.0, 28 de agosto de 2019
%   - Se cambió de gráfica de puntos a línea continua de grosor 2.
%   Versión 4.0, 23 de marzo de 2019
%   - Se agregó un séptimo parámetro para modificar el color de la línea.
%   Versión 3.0, 18 de mayo de 2017
%   - Se modificó el interprete de los ejes a LaTeX. El interprete del
%   título no se modificó.
%   Versión 2.0, 2 de diciembre de 2016:
%   - Se modificó el tamaño del punto a 10, para mejorar la visualización.
%   - El tamaño del punto se puede modificar indicándolo en el sexto
%   parámetro, como muestra el ejemplo.
%   Versión 1.0, 29 de septiembre de 2015
%   Elaborada por Hans López, hilopezc@udistrital.edu.co
%    
switch nargin
    case 0
        disp('Faltan argumentos de entrada');
        return;
    case 1
        plot(x,'LineWidth',2);
        grid on;
        set(gca,'FontSize',14);
        set(gcf,'Color','white');
        if max(x) - mean(x) > 1e-6
            axis([1 length(x) min(x)-0.1*(max(x)-min(x)) max(x)+0.1*(max(x)-min(x))]);
        end
        return;
    case 2
        plot(x,y,'LineWidth',2);
    case 3
        plot(x,y,'LineWidth',2);
        title(titulo,'FontSize',16);
    case 4
        plot(x,y,'LineWidth',2);
        title(titulo,'FontSize',16);
        xlabel(ejex,'FontSize',16,'Interpreter','latex');
    case 5
        plot(x,y,'LineWidth',2);       
        title(titulo,'FontSize',16);
        xlabel(ejex,'FontSize',16,'Interpreter','latex');
        ylabel(ejey,'FontSize',16,'Interpreter','latex');
    case 6        
        plot(x,y,'LineWidth',grosor);       
        title(titulo,'FontSize',16);
        xlabel(ejex,'FontSize',16,'Interpreter','latex');
        ylabel(ejey,'FontSize',16,'Interpreter','latex');
    case 7        
        plot(x,y,'Color',colorlinea,'LineWidth',grosor);       
        title(titulo,'FontSize',16);
        xlabel(ejex,'FontSize',16,'Interpreter','latex');
        ylabel(ejey,'FontSize',16,'Interpreter','latex');
end
grid on;
set(gca,'FontSize',14);
set(gca,'TickLabelInterpreter','latex');
set(gcf,'Color','white');

if max(y) - mean(y) > 1e-6
    ylim([min(y)-0.1*(max(y)-min(y)), max(y)+0.1*(max(y)-min(y))])
    xlim([min(x) max(x)]);
end
end