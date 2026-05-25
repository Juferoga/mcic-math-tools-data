%% Uso del generador betamwm
muestra = betamwm(1,10,0.8);
vt(muestra)

%% Uso del generador wfbm
muestra = diff(wfbm(0.8,2^10));
vt(muestra)

%% Actividad 1, prueba de sesgo para vt
haches = zeros(1,10000);

tic;
parfor n = 1:numel(haches)
    muestra = randn(1,100000);
    haches(n) = vt2(muestra);
end
toc;

pdfcdfcontinua(haches,0);
subplot(2,1,2);
qqplot(haches);
normfit(haches)

%% Actividad 1, prueba de sesgo para LD
haches = zeros(1,10000);

tic;
parfor n = 1:numel(haches)
    muestra = randn(1,100000);
    haches(n) = LD2(muestra);
end
toc;

pdfcdfcontinua(haches,0);
subplot(2,1,2);
qqplot(haches);
normfit(haches)

%% Actividad 1, prueba de consistencia para vt

tic;
m = 1;
varianzas = zeros(1,4);
for exponente = 10:2:16
    haches = zeros(1,1000);
    for n = 1:numel(haches)
        muestra = randn(1,2^exponente);
        haches(n) = vt2(muestra);
    end
    varianzas(m) = var(haches);
    m = m + 1;
    pdfcdfcontinua(haches,0);
    subplot(2,1,1);
    hold on;
end
toc;

subplot(2,1,1);
legend('N = 2^{14}','N = 2^{16}','N = 2^{18}','N = 2^{20}');
hold off;
subplot(2,1,2);
superstem(1:4,varianzas,'Comportamiento de las Varianzas');
xticks(1:4);
xticklabels({'$2^{14}$','$2^{16}$','$2^{18}$','$2^{20}$'});

%% Actividad 2

haches = zeros(1,1000);

tic;
parfor n = 1:numel(haches)
    %muestra = betamwm(1,16,0.9);
    muestra = diff(wfbm(0.9,2^16));
    haches(n) = vt2(muestra);
end
toc;

pdfcdfcontinua(haches,0);

subplot(2,1,2);
qqplot(haches);
normfit(haches)

%% Boxplot
muestra = randn(1,1000);
boxplot(muestra);

%% Actividad 4, prueba de fractalidad

muestra = diff(wfbm(0.8,2^10));
%muestra = betamwm(1,14,0.8);
[dh,h,cp,tauq] = dwtleader(muestra);
subplot(1,2,1)
superplot(-5:5,tauq,'Exponentes de Escala',...
    '$q$','$\tau(q)$');
subplot(1,2,2)
superplot(h,dh,'Espectro Multifractal',...
    '$h$','$D(h)$');
axis([0 1 0 1.5]);