% ACTIVIDAD 5
% Simula M/M/k/k variando A = lambda/mu usando funciones empiricas
% f1..f4 (arribos) y servicio exponencial.

clear; clc;

k = 10;
usuarios = 100000;
mu = 1;
A_vals = 0.1:0.2:20;

funcs = {@f1,@f2,@f3,@f4};
labels = {'f1','f2','f3','f4'};

figure;
tiledlayout(2,2,'Padding','compact');

for j = 1:numel(funcs)
    f = funcs{j};

    % Vector base empirico (interarribos)
    x_base = f(1,usuarios);
    x_base = x_base(:)';
    x_base = x_base(x_base > 0 & isfinite(x_base));

    if numel(x_base) < usuarios
        x_base = f(1,usuarios);
        x_base = x_base(:)';
        x_base = x_base(x_base > 0 & isfinite(x_base));
    end

    if isempty(x_base)
        error('La funcion %s no produjo interarribos validos.',labels{j});
    end

    lambda_base = 1/mean(x_base); % estimacion pedida en la actividad

    Pk_sim = zeros(size(A_vals));
    Pk_teo = zeros(size(A_vals));

    for i = 1:numel(A_vals)
        A = A_vals(i);
        lambda_obj = A * mu;

        % Escalado para conservar forma empirica y ajustar tasa objetivo.
        factor_escala = lambda_base / lambda_obj;
        tiempoentrearribos = x_base * factor_escala;

        tiemposdeservicio = exprnd(1/mu,1,numel(tiempoentrearribos));

        Pk_sim(i) = mmkk(tiempoentrearribos,tiemposdeservicio,k);
        Pk_teo(i) = erlangB(A,k);
    end

    nexttile;
    plot(A_vals,Pk_sim,'o-','LineWidth',1.2,'DisplayName','Simulacion');
    hold on;
    plot(A_vals,Pk_teo,'-','LineWidth',2,'DisplayName','Teoria Erlang-B (exp)');
    grid on;
    xlabel('A = \lambda/\mu');
    ylabel('P_k');
    title(sprintf('%s (\\lambda_{base}=%.4f)',labels{j},lambda_base));
    legend('Location','best');
end

sgtitle(sprintf('M/M/%d/%d con arribos empiricos f1..f4',k,k));

function B = erlangB(A,k)
    n = 0:k;
    B = (A^k/factorial(k)) / sum((A.^n)./factorial(n));
end
