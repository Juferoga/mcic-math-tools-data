function [] = superplot(x,y,titulo,ejex,ejey,grosor,colorlinea)
%   Utiliza la funci�n plot para realizar la gr�fica de f(x). SUPERPLOT
%   cambia el fondo de la figura a color blanco y el tama�o de las fuentes.
%   Adicionalmente ajusta de forma autom�tica los l�mites de las gr�ficas.
%
%   La funci�n permite agregar el t�tulo de la gr�fica, y el nombre de los
%   ejes como par�metros de entrada.
%
%   Ejemplo:
%
%   x = linspace(-5,5,1000);
%   SUPERPLOT(x,sinc(x),'Funci�n Seno Cardinal','$x$','sinc($x$)');
%
%   Funci�n SUPERPLOT, Versi�n 6.0 9 de mayo de 2020
%   - Se corrigi� el error que se presentaba al intentar ajustar de manera
%   autom�tica los ejes cuando el vector "y" era constante.
%   Versi�n 5.0, 28 de agosto de 2019
%   - Se cambi� de gr�fica de puntos a l�nea cont�nua de grosor 2.
%   Versi�n 4.0, 23 de marzo de 2019
%   - se agreg� un s�ptimo par�metro para modificar el color de la l�nea.
%   Versi�n 3.0, 18 de mayo de 2017
%   - se modific� el interprete de los ejes a LaTeX. El interprete del
%   t�tulo no se modific�.
%   Versi�n 2.0, 2 de diciembre de 2016:
%   - Se modific� el tama�o del punto a 10, para mejorar la visualizaci�n.
%   - El tama�o del punto se puede modificar indic�ndolo en el sexto
%   par�metro, como muestra el ejemplo.
%   Versi�n 1.0, 29 de septiembre de 2015
%   Elaborada por Hans L�pez, hanslop@gmail.com
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
    axis([min(x) max(x) min(y)-0.1*(max(y)-min(y)) max(y)+0.1*(max(y)-min(y))]);
end
end