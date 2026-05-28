addpath('/home/juferoga/repos/ud/maestria/mcic/semestre-1/mcic-math-tools-data/3.Trabajos/3. Trabajo/doc/clase');
addpath('/home/juferoga/repos/ud/maestria/mcic/semestre-1/mcic-math-tools-data/3.Trabajos/3. Trabajo/src');

disp('=== Verificando funciones ===');
try
    which vt;
    disp('vt.m: OK');
catch
    disp('vt.m: NO ENCONTRADO');
end

try
    which LD;
    disp('LD.m: OK');
catch
    disp('LD.m: NO ENCONTRADO');
end

try
    which superplot;
    disp('superplot.m: OK');
catch
    disp('superplot.m: NO ENCONTRADO');
end

try
    which dwtleader;
    disp('dwtleader: OK');
catch
    disp('dwtleader: NO ENCONTRADO');
end

try
    which betamwm;
    disp('betamwm.m: OK');
catch
    disp('betamwm.m: NO ENCONTRADO');
end

try
    which wfbm;
    disp('wfbm: OK');
catch
    disp('wfbm: NO ENCONTRADO');
end

try
    which wavedec;
    disp('wavedec: OK');
catch
    disp('wavedec: NO ENCONTRADO');
end

disp('');
disp('=== Verificando archivo access.log ===');
if exist('../access.log', 'file')
    disp('access.log: OK');
    fid = fopen('../access.log');
    line = fgetl(fid);
    fclose(fid);
    disp(['Primera linea: ' line(1:min(80,length(line)))]);
else
    disp('access.log: NO ENCONTRADO');
end

disp('');
disp('Todo listo para ejecutar actividad6.m');
