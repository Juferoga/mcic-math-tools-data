function resultado = partido()
p = rand;

if p < 0.5
    resultado = '😭';
elseif p < 0.6
    resultado = '😒';
else
    resultado = '😃';
end