function adc = makeADCpoly(adc)

%container for calling ADC design/implementation/analysis
adc = designADCpoly(adc);
adc = implementADCpoly(adc);
adc = evalADCpoly(adc);