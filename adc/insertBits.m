%Insert two's complement value of size into register at pos
%All numbers are decimal
    function regOut = insertBits(regIn, value, size, pos)
        unsign = mod(value,2^size);
        regOut = bitor(regIn,unsign*2^pos);
    return