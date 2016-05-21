function adc = designADCpoly(adc)
% This function uses a polynomial model to generate Mykonos ADC

% Values for the following fields are taken directly from the 
% parameters struct, if they exist as fields in that struct.
%	BW=50e6             bandwidth
% 	Fs=1474.56e6        sampling frequency
%   usage='RX'/'ORX'    use case
%
%	ABCDc	ABCD matrix for the matlab model of the scaled CT system

BW=adc.BW;
Fs=adc.Fs;
F0=0; %low-pass only

% Calculated modulator design parameters
adc.osr = Fs/(2*BW);
adc.bw = BW/Fs;
adc.f0 = F0/Fs;

%Load polynomial model data from file ABCDpolydata.m
ABCDpolydata;
%Choose RX or ORX
if adc.osr>=12
    ABCDpolys=RXpolys;
    adc.usage='RX';
else
    ABCDpolys=ORXpolys;
    adc.usage='ORX';
end
% Mykonos design parameters
adc.FullScale = 0.7;
order=4;
adc.order = order;
adc.M = 16;
adc.FlashLSB = 0.02;
adc.tdac = [1 2];
adc.PeakSignal = -3;
adc.tdac2 = [-1 -1; 1 2; 0.5 1.5];
adc.dacv=0.2;
adc.Gin=0.002;
Imax=96e-6;
adc.F0=0;
adc.f1f2=[0 1/adc.osr/2];

%Preliminary cap values, implement will fix these up
adc.C = [10e-12 10e-12 2.75e-12 1.35e-12];

%All design steps replaced by ABCDc from polynomial model
bw=max(adc.bw,1/27/2);
ABCDc = zeros(order+1,order+3);
for ii = 1:max(size(ABCDpolys))  
    ABCDc(ABCDpolys{ii}.i(1),ABCDpolys{ii}.i(2)) = evalpoly(bw,ABCDpolys{ii}.c);
end
%Set flash gain according to FlashLSB - design compensates for this
ABCDc(order+1,order) = 2/adc.FlashLSB;
adc.ABCDc=ABCDc;

%Compute remaining component values
Ev = ABCDc(end,end) * adc.FlashLSB/2;
Eu = ABCDc(end,order+1) * adc.M/adc.FullScale * adc.FlashLSB/2;
[Ac,Bc,Cc,Dc] = partitionABCD(ABCDc,size(adc.tdac2,1));
if ~iscell(adc.tdac)
    Bci = Bc(:,2).';
else
    Bci = ones(1,4)*Bc(:,2:order+1);
end
adc.I = Fs * adc.C .* Bci;
adc.G = Fs * repmat(adc.C',1,order) .* Ac;
adc.E = [Cc Eu Ev];

%put scaling here in implement?
%R1u=500,I2=96uA,C3/C4 already fixed

%Stg1: R1u=500 (Gin=0.002)
Gin = adc.Fs*adc.C(1)*adc.ABCDc(1,adc.order+1)*adc.M/adc.FullScale;
k=adc.Gin/Gin; %how much to scale admittance of stg1
%scale C,G,I by k
adc.C(1)=k*adc.C(1);
adc.G(1,:)=k*adc.G(1,:);
adc.I(1)=k*adc.I(1);

%Stg2: I2=96uA
k=abs(Imax/adc.I(2)); %how much to scale admittance of stg2
%scale C,G,I by k
adc.C(2)=k*adc.C(2);
adc.G(2,:)=k*adc.G(2,:);
adc.I(2)=k*adc.I(2);

return
