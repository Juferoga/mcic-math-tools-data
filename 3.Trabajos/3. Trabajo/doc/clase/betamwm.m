function [traza] = betamwm(Uoo,n,H)
    traza = Uoo;
    beta = (2^(2*H-1)-1)/(2-2^(2*H-1));
    for i=1:n
        b = betarnd(beta,beta,1,2^(i-1));
        p = [b;1-b];
        p = p(:)';
        traza = [traza;traza];
        traza = traza(:)';
        traza = traza.*p;
    end
end
