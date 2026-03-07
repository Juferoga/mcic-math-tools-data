function y = moneda()
    p = rand;
    if p < 0.5
        y = 0;
    else
        y = 1;
    end
end