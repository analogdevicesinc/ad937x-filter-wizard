function adc=evalADCpoly(adc)
    %Calculates STF and NTF (also SQNR)
    
    Nntf=512;  %NTF points from 0 to 0.5*Fs
    Nstf=256; %STF points from 0 to Fs
    
    %Get modulator parameters
    Fs = adc.Fs;
    Fsm = round(adc.Fs/1e6)*1e6;
    BW = adc.BW;
    F0 = adc.F0;
    LSB = adc.FlashLSB;
    osr = adc.osr;
    FullScale = adc.FullScale;
    order=adc.order;    
    M=adc.M;
    PeakSignal = adc.PeakSignal;
    VFS=undbv(-3)*FullScale;
    
    %Bust into ABCD and apply tuning errors if desired
    %RC ERRORS HERE
    [Ac, Bc, Cc, Dc] = partitionABCD(adc.ABCDc);
    [sys Gp] = mapCtoD(ss(Ac,Bc,Cc,Dc),adc.tdac2,adc.f0);
    ABCD = [sys.a sys.b; sys.c sys.d];
    ntf = calculateTF(ABCD);
    L0 = zpk( ss(Ac,Bc(:,1),Cc,Dc(1)) );
    %Put these back into adc object
    adc.L0 = L0;
    adc.ntf = ntf;

    %Get the NTF
    df=Fs/2/Nntf;
    f = 0:df:Fs/2-df;
    adc.NTFdata = evalTF(adc.ntf,exp(2i*pi*f/adc.Fs));
    adc.NTFfreq = f;
    
    % Get the STF
    df=adc.Fs/Nstf/1.25;
    f = 0:df:1.25*Fs-df;
    adc.STFdata = evalTFP(adc.L0,adc.ntf,f/Fs);
    adc.STFfreq = f;
    
    %Calculate in-band noise density
    %0.5 Mhz bins
    if(F0==0)
        fib = 0e6:0.5e6:BW;
    else
        fib = (F0-BW/2):0.5e6:(F0+BW/2);
    end
    fib=fib';
    flow=min(fib);
    fhigh=max(fib);
    NTFib = evalTF(adc.ntf,exp(2i*pi*fib/Fs));

    %Calculate SQNR
    
    %RMS quant noise with offsets
    Pq= (FullScale/M*2)^2/12*1.25; %1db degradation due to offsets
    %Quant noise density in v^2/hz
    See = Pq/(Fs/2);
    %Shaped quant noise
    Ssq = See*abs(NTFib).^2;
    Nd = Ssq.^0.5;
    
    adc.SQNR = dbv(VFS/sqrt(2))-dbp(sum(Nd.^2)/length(Nd))-dbp(BW);
