function adc = implementADCpoly(adc)

%Get component values from ADC design
C=adc.C;
R(1:7)=[1/adc.Gin 1./(adc.G(1,2)) 1./(adc.G(2,1)) 1./(adc.G(2,3)) 1./(adc.G(3,2)) 1./(adc.G(3,4)) 1./(adc.G(4,3))];
Ia=adc.I;
Ev = adc.ABCDc(end,end)*adc.FlashLSB/2*0.96;

%Layout parasitic compensation
Cple = [40e-15 44e-15 34e-15 32e-15];
Rple = [0 5.4 4.8 5.3 4.2 4.6 3.6];

%Circuit parameters
Iunit=2e-6;
Idfbunit=0.5e-6;
Imax=[96e-6 96e-6*1 96e-6 96e-6];
Idfbmax=127.5e-6;

Cunit=54e-15/4;
Cfix = [76 40 28 16]*4;
Cmax = 2.^[11 9 7 6] + Cfix - 1; %in units including fixed cap
Chigh=1.16;
Clow=0.84;

Gunit(1:size(R,2)) = 1/640e3;
Gunit([4 6]) = 1/1280e3;
Gord = [1 1 2 2 3 3 4];
Gin=1/500;  %We want Rin of 500 ohms per side
Gmax = 2.^[11 11 12 10 11 10 11] - 1;  %Gmax(2) is actually 11 in analog, needs digital fix
Glow=0.86;  %Need this much headroom for process

Rv=200;

%Compensate for R/C parasitics
Ca = C-Cple;
Ga = 1./(abs(R)-Rple);

%Increase G's and I's to meet minimum cap requirements if necessary
Cminsc = max(Cfix./(Ca./(Cunit*Chigh))*1.05,1);  %Cminsc>1 if a cap is below minimum
Ca = Ca.*Cminsc;
Ga = Ga.*Cminsc(Gord);
Ia = Ia.*Cminsc;

Ia = -1*Ia; %Flip DAC current polarity to +ve numbers
Isc = min(Imax./Ia, 1);  %Isc<1 for DAC current clipping

Csc = 1./(max(Ca./(Cunit.*Cmax*Clow),1));  %Csc<1 for cap clipping

Gsc = ones(size(Ga));
for i = 1:size(Ga,2)
    Gsc(i) = 1/(max(Ga(i)./(Gunit(i).*Gmax(i)*Glow), 1)); %Gsc<1 for conductance clipping
end

Gscstg = ones(1,max(Gord));
for i = 1:max(Gord)
    Gscstg(i) = min(Gsc(Gord==i)); %Gscstg<1 for stage conductance clipping
end

ascale=min(Gscstg,min(Isc,Csc)); %Combined G/C/I clipping for each stage

%Final DAC current quantization
Ia=Ia.*ascale;
Iq = floor(Ia/Iunit+1e-9)*Iunit; %Floor to avoid exceeding G/C limits
Iscq = Iq./Ia; %Stage current QE to compensate in G/C
Icode = round(Iq/Iunit);

%Limit quantization compensation to 5%
Iscq=max(Iscq,0.95);
scale = ascale.*Iscq;    %Scale including quantization

%Scale and squantize Cs
Ca = Ca.*scale;
Cq = round(Ca./Cunit).*Cunit;
Ccode = round(Cq./Cunit);

%Scale and squantize Gs
for i = 2:size(Ga,2)
    Ga(i) = Ga(i).*scale(Gord(i));
end
Gq = round(Ga./Gunit).*Gunit;
Gcode = round(abs(Gq./Gunit));

%Find DFB current
Idfb = -Ev/Rv;    
Iq(:,5) = round(Idfb/Idfbunit)*Idfbunit;
Icode(:,5) = round(Iq(:,5)/Idfbunit);

%Stuff codes into a register structure

regs.Ccodes = Ccode;
regs.Gcodes = Gcode;
regs.Icodes = Icode;

%Stuff profile bytes
adc.regs = regs;
[profbytes, usestr] = openbytes(adc);
regs.profbytes = profbytes;
regs.usestr = usestr;
adc.regs = regs;

%Stuff final component values back into adc
adc.Cfix = Cfix;
adc.C = Ccode.*Cunit+Cple;
Gvals = Gcode.*Gunit;
adc.Gs = 1./(Rple+1./Gvals);
adc.Gin = Gvals(1);
adc.G = [0,-Gvals(2),0,0;
         Gvals(3),0,-Gvals(4),0;
         0,Gvals(5),0,-Gvals(6);
         0,0,Gvals(7),0];
adc.I = -Icode(1:4)*Iunit;

return;
