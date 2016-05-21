%function to evaluate polynomial at values
function y = evalpoly(x,c)
    n=size(c,2);
    bigX = ones(size(x,1),1);
    for ii = 1:n-1
        bigX = [bigX x.^ii];
    end
    y = bigX*(c');
end