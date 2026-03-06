function [] = pruebaPartido(repeticiones)
    conteo = [0, 0, 0];
    
    for i = 1:repeticiones
        p = rand;
        
        if p < 0.5
            conteo(1) = conteo(1) + 1;
        elseif p < 0.6
            conteo(2) = conteo(2) + 1;
        else
            conteo(3) = conteo(3) + 1;
        end
    end
    
    frecuencias = conteo / repeticiones;
    
    figure;
    b = bar(frecuencias);
    
    etiquetas = {'Perdio (😭)', 'Empato (😒)', 'Ganó (😃)'};
    set(gca, 'XTickLabel', etiquetas);
    ylabel('Frecuencia Relativa (Probabilidad)');
    title(['Simulación de ' num2str(repeticiones) ' Partidos']);
    grid on;
    
    b.FaceColor = 'flat';
    b.CData(1,:) = [0.9 0.4 0.4];
    b.CData(2,:) = [0.6 0.6 0.6];
    b.CData(3,:) = [0.4 0.8 0.4];
    
    xtips = b.XEndPoints;
    ytips = b.YEndPoints;
    labels = string(round(frecuencias*100, 1)) + '%';
    text(xtips, ytips, labels, 'HorizontalAlignment', 'center', ...
        'VerticalAlignment', 'bottom', 'FontSize', 11, 'FontWeight', 'bold');
end