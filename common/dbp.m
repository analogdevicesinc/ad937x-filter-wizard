% dbp(x) = 10*log10(abs(x)); the dB equivalent of the power x
function y=dbp(x)
y = -Inf*ones(size(x));
if isempty(x)
    return
end
nonzero = x~=0;
y(nonzero) = 10*log10(abs(x(nonzero)));
