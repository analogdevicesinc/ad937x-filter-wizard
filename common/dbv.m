function y=dbv(x)
% dbv(x) = 20*log10(abs(x)); the dB equivalent of the voltage x
y = -200*ones(size(x));
if isempty(x)
    return
end
nonzero = x~=0;
y(nonzero) = 20*log10(abs(x(nonzero)));
