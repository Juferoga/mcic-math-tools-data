function [H,alpha] = LD(traza)
%% Función LD
%   LD(traza) realiza el diagrama log - escala de una matriz de datos. La
%   descomposición wavelet se realiza con la wavelet de Haar. La regresión
%   lineal se realiza con el método de mínimos cuadrados entre la octava 2
%   y la calculada con floor(log2(numel(traza))/2);
%
%   Ejemplo:
%
%   traza = randn(1,1000000);
%   LD(traza);
%
%   Realiza el diagrama log - escala de una muestra aleatoria, normalmente
%   distribuida y sin dependencia, de tamaño n.
%
%   Versión 2.0, 24 de mayo de 2019.
%   - Se automatiza la función para que solo se necesite la muestra
%   aleatoria.
%   - Se configuran por defecto: j1 = 2, j2 = N-1 y wavelet = 'db1'
%   - Se modifica N de floor(log2(length(X))) a floor(log2(length(X))/2+1)
%   - Se realizan ajustes gráficos.
%
%   Versión 1.0, 2012.
%
%   Elaborada por Hans López, hanslop@gmail.com
X = traza(:)';
wavelet = 'db1';
j1 = 2;
N = floor(log2(length(X))/2+1);
j2 = N-1;
mu = zeros(1,N);
media = mu;

[C,L] = wavedec(X,N,wavelet);

for i = 1:N-1
    D = detcoef(C,L,i);
    mu(i) = mean(abs(D).^2); % Exponente = 2, para LD    
end

p = polyfit(j1:j2,log2(mu(j1:j2)),1);
plot(1:N,log2(mu(1:N)),'b.',[0 N], [p(2) p(2)+N*p(1)],'r-');
set(gcf,'Color','white');
set(gca,'FontSize',16);
set(gca,'TickLabelInterpreter','latex');

grid on;

H = p(1)/2 + 1/2;
alpha = p(1);

%Cálculo de los intervalos de confianza para H

j = j2-j1;
nj1 = length(detcoef(C,L,j1));
desviacion = sqrt(2*(1-(2^(-j)))/(nj1*(log(2)^2)*(1-((2^(-j-1))*((j^2)+4))+2^(-2*j))));
error = 1.9599*desviacion;

Hmin = H - error;
Hmax = H + error;

title(['Diagrama Log-Escala (LD)'],'FontSize',18);

xlabel('Octava $j$','FontSize',18,'Interpreter','latex');
ylabel('$y_j = \log_2(\mu_j)$','FontSize',18,'Interpreter','latex');
legend({['Estimación. H = ',num2str(H)],...
    ['Regresión Lineal. ',num2str(Hmin),' < H < ',num2str(Hmax)]});