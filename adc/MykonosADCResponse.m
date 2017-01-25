function [ADCSTF, fresp, AdcCodes] = MykonosADCResponse(fp, fftlen, Fs);
% MykonosADCResponse function to plot the ADC response
% for a given passband and sampling rate
%
% [ADCSTF,fresp] = MykonosADCResponse(fp, fftlen, Fs);
%
% where fp is the passband of the ADC, fftlen is the number of FFT points,
% and Fs is the clock rate of the ADC

plotresp = 0;

MHz = 1e6;

adc.Fs = Fs;
adc.F0 = 0;
adc.BW = fp;
adc = makeADCpoly(adc);

% regs.profbytes contains the SPI reg values to be written for ADC profile


if plotresp == 1
    figure, clf; hold on; grid on;
    plot(adc.STFfreq/MHz, dbv(adc.STFdata), 'b-','LineWidth',2);
    axis([0 max(adc.STFfreq)/MHz -120 20])
    title('Signal Transfer Function');
    xlabel('Frequency (MHz)');
    ylabel('dB');
    f_pb = linspace(0.01,0.5,20)/adc.osr;
    G_pb = evalTFP(adc.L0,adc.ntf,f_pb);
    pbvar = max(dbv(G_pb))-min(dbv(G_pb));
    msg = sprintf(' Passband gain variation =%.2fdB', pbvar);
    
    if(adc.F0==0)
        fhigh=adc.BW; flow=0;
    else
        fhigh=adc.F0+adc.BW/2; flow=adc.F0-adc.BW/2;
    end

    text(0.4*max(adc.STFfreq)/MHz,0.5,msg,'hor','cen','vert','bot','FontSize',12);
    line([fhigh/MHz fhigh/MHz], [-140 20], 'LineStyle', '-.', 'LineWidth', 2, 'Color', 'g')
    line([flow/MHz flow/MHz], [-140 20], 'LineStyle', '-.', 'LineWidth', 2, 'Color', 'g')
end

fresp = 0:Fs/((fftlen)):Fs-(Fs/fftlen);
ADCSTF = spline(adc.STFfreq, adc.STFdata, fresp);
AdcCodes = adc.regs.profbytes;
if plotresp == 1
    plot(fresp, dbv(ADCSTF),'r','LineWidth',1);
end

end
