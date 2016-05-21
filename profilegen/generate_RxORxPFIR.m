function profile = generate_RxORxPFIR(mode, rxorx_config, fhandle);
%   GENERATE_RXORX_PFIR    generate Programable FIR filter for the Rx/ORx paths
%   profile = GENERATE_RXORXPFIR(mode, rxorx_config, fhandle);
%
%   mode is either 'Rx' or 'ORx' - filters used are different in the 2 modes
%   rxorx_config is the substructure




%% Mykonos Rx Signal Processing Path Diagram
%I = imread('img/MykonosRxSignalPath.jpg');
%imshow(I);
%title('Mykonos Rx Signal Processing Path');

%% Constants - Do Not Modify
fftlen = 1024*8;        % FFT length 
MHz = 1e6;              % MHz declared as 1e6
bands = 2;              % Passband and stopband

%% Assign Input Configuration Parameters from structure to 

Fp_Hz = rxorx_config.RFBW_MHz*MHz/2;      % single side BW parameter
dec5_enable = rxorx_config.dec5_enable;
RHB1_enable = rxorx_config.rhb1_enable;
pfir_decimation = rxorx_config.pfir_decimation;
output_rate_Hz = rxorx_config.output_rate_MHz*MHz;
adc_Fs = rxorx_config.ADC_clk_rate_MHz*MHz;

pfir_in_rate_Hz = output_rate_Hz * pfir_decimation;

if output_rate_Hz > Fp_Hz*4.0
    Fstop_offset = Fp_Hz;
elseif output_rate_Hz > Fp_Hz*3.2
    Fstop_offset = Fp_Hz*0.5;       % This is additional BW required for stopband if we think its of benefit
else
    Fstop_offset = 0;
end

% Calculate the decimation before the PFIR to calculate
if dec5_enable == 1
    dec_before_pfir = 5*2^(RHB1_enable);
else
    dec_before_pfir = 4*2^(RHB1_enable);
end

%adc_Fs = output_rate_Hz*5^(dec5_enable)*2^(RHB1_enable)*pfir_decimation;  % ADC sampling rate calculation



debugplot = 0;          % Switch to enable plotting interim checks for debug


%% Load all Halfband (RHB) and Decimation (DEC) Filter Coeefficients
hb1 = 2^(-14) * [9 0 -41 0 124 0 -304 0	665 0 -1473 0 5074 8108 5074 0 -1473 0 665 0 -304 0 124 0 -41 0 9];
hb2 = 2^( -7) * [1 0 -7 0 38 64 38 0 -7 0 1];
hb3 = 2^( -4) * [1 4 6 4 1];
dec5 =2^(-13) * [18 35 56 72 70 28 -38 -126 -209 -244 -184 -20 256 612 976 1273 1448 1448 1273 976 612 256 -20 -184 -244 -209 -126 -38 28 70 72 56 35 18];
dec5hr = 2^(-15) * [-64 -165 -305 -442 -499 -273 280 1208 2433 3762 4866 5503 5503 4866 3762 2433 1208 280 -273 -499 -442 -305 -165 -64];

%% Calculate Sample Rates for Each Filter Output
fpass = [0 Fp_Hz]
if dec5_enable == 1
    Fs_hb2dec5 = adc_Fs/5;
    hb2dec5_stop = [adc_Fs/5-Fp_Hz adc_Fs/5+Fp_Hz 2*adc_Fs/5-Fp_Hz 2*adc_Fs/5+Fp_Hz];
else
    Fs_hb3 = adc_Fs/2;
    hb3_stop = [adc_Fs/2-Fp_Hz adc_Fs/2];
    Fs_hb2dec5 = Fs_hb3/2;
    hb2dec5_stop = [adc_Fs/4-Fp_Hz adc_Fs/4+Fp_Hz adc_Fs/2-Fp_Hz adc_Fs/2];
end


if RHB1_enable == 1
    Fs_hb1 = Fs_hb2dec5/2;
    hb1_stop = [Fs_hb2dec5/2-Fp_Hz Fs_hb2dec5/2+Fp_Hz hb2dec5_stop];
else
    Fs_hb1 = Fs_hb2dec5;
    hb1_stop = [hb2dec5_stop];
end

% PFIR Fs out and PFIR stop band calculations
if pfir_decimation == 4
    Fs_pfirout = Fs_hb1/4;
    pfir_stop = [Fs_pfirout-Fp_Hz-Fstop_offset Fs_pfirout+Fp_Hz Fs_pfirout*2-Fp_Hz Fs_pfirout*2+Fp_Hz hb1_stop];
elseif pfir_decimation == 2
    Fs_pfirout = Fs_hb1/2;
    pfir_stop = [Fs_pfirout-Fp_Hz-Fstop_offset Fs_pfirout+Fp_Hz hb1_stop];
else
    Fs_pfirout = Fs_hb1;
    pfir_stop = hb1_stop-Fstop_offset;
end


%% Setting TIA Corner Frequency (Fc) Based on Passband Frequency and Rx Type
if ( rxorx_config.tia_fc_MHz == 0 )
    if strcmpi('ORx', mode)
        if (Fp_Hz > 100*MHz)
            tia_Fc = 100*MHz;
        elseif (Fp_Hz < 20*MHz)
            tia_Fc = 20*MHz
        else
            tia_Fc = Fp_Hz;
        end
    else
        if (Fp_Hz*2 > 100*MHz)
            tia_Fc = 100*MHz;
        elseif (Fp_Hz*2 < 20*MHz)
            tia_Fc = 20*MHz;
        else
            tia_Fc = Fp_Hz*2;
        end
    end
    
    rxorx_config.tia_fc_MHz = tia_Fc/1e6;
else
    tia_Fc = rxorx_config.tia_fc_MHz*MHz;
end


%% TIA Frequency Response Calculation
% TIA response is based on single pole RC model = 1/(1+(2*pi*R*C)) 
Ftia = 1:adc_Fs/2/1000:adc_Fs/2;
tiaresp = 1./(1 + i*Ftia./tia_Fc);

%% ADC Response up to Fs
[ADCresp, frespADC, AdcCodes] = MykonosADCResponse(Fp_Hz,fftlen,adc_Fs);
rxorx_config.ADC_codes = AdcCodes;

%% Cubic Spline Interpolation to Determine Final TIA Response
TIAresp = spline(Ftia,tiaresp,frespADC);

%% Plotting All Analog Responses
analogresp = ADCresp.*TIAresp;

if debugplot == 1
figure,
plot(frespADC,dbv(abs(ADCresp)),'b');grid, hold on;
plot(frespADC,dbv(abs(TIAresp)),'g--');
plot(frespADC,dbv(abs(analogresp)),'r-');
legend('ADC resp','TIA resp','Analog Response');
title('Analog Frequency Responses');
xlabel('MHz');
ylabel('dB');
end

%% Convolve Analog and Digital Filter Responses
if strcmpi('ORx',mode)
    dec5use = dec5;
else
    dec5use = dec5hr;
end

if dec5_enable == 1 
    if RHB1_enable == 1
        hb1up = upsample(hb1,5);
        hbout = conv(dec5use,hb1up);
    else
        hbout = dec5;
    end
else
    hb2up = upsample(hb2,2);
    hb32 = conv(hb2up,hb3);
    if RHB1_enable == 1
        hb1up = upsample(hb1,4);
        hbout = conv(hb32,hb1up);
    else
        hbout = hb32;
    end
end

%% Plotting the Combined HB and DEC5 Responses
[HBOUT,fhbout] = freqz(hbout,1,fftlen,'whole');
if debugplot == 1
    figure;
    filterplot(hbout,1,fftlen,adc_Fs,'HB Output Response', [0 Fp_Hz], hb1_stop);
    grid;
    xlabel('MHz');
    ylabel('dB');
end

%% Multiply With Analog Response
HBOUTanalog = transpose(HBOUT).*(analogresp);
if debugplot == 1    
    figure;
    plot(frespADC,dbv(abs(analogresp)));
    grid;
    title('HB and Analog Convolved Response');
    xlabel('MHz');
    ylabel('dB');

    figure;
    filterplot_fft(HBOUTanalog(1:end/2),fhbout(1:end/2),adc_Fs,'Fixed Filter Output Response',[0 Fp_Hz], hb1_stop);
    xlabel('MHz');
    ylabel('dB');
end

%% Adding The PFIR Response And Calculating the Remez Algorithm Weights
absHBout = transpose((abs(HBOUTanalog)));
pfir_passband = ceil([0 Fp_Hz]/(adc_Fs)*fftlen);
pfir_pb_response = (1./absHBout(1:pfir_passband(2)));
fgrid = linspace(0,1,fftlen/dec_before_pfir);
fgrid_pb = fgrid(1:pfir_passband(2));    % 2 required since Matlab expects grid b/w 0 and 1
wt_pb = ones(1,length(fgrid_pb))*rxorx_config.pfir_passband_weight;

% Calculating pass band and stop band weights based on PFIR DEC selection
if pfir_decimation == 4
    pfir_stopuse = [pfir_stop(1:3) pfir_in_rate_Hz/2];
    pfir_stopbands = round(pfir_stopuse/(adc_Fs)*fftlen);
    fgrid_sb0 = fgrid(pfir_stopbands(1):pfir_stopbands(4)); % 2 required since Matlab expects grid b/w 0 and 1
    fgrid_sb1 = fgrid(pfir_stopbands(3):pfir_stopbands(4));
    pfir_sb0_response = zeros(1,length(fgrid_sb0));
    pfir_sb1_response = zeros(1,length(fgrid_sb1));
    wt_sb0 = absHBout(pfir_stopbands(1):pfir_stopbands(4))*rxorx_config.pfir_stopband_weight;
    wt_sb1 = absHBout(pfir_stopbands(3):pfir_stopbands(4))*rxorx_config.pfir_stopband_weight;
elseif pfir_decimation == 2
    pfir_stopuse = [pfir_stop(1) pfir_in_rate_Hz/2];
    pfir_stopbands = round(pfir_stopuse/(adc_Fs)*fftlen);
    fgrid_sb0 = fgrid(pfir_stopbands(1):pfir_stopbands(2));
    pfir_sb0_response = zeros(1,length(fgrid_sb0))*rxorx_config.pfir_stopband_weight;
    wt_sb0 = absHBout(pfir_stopbands(1):pfir_stopbands(2))*rxorx_config.pfir_stopband_weight;
else
    pfir_stopuse = [(pfir_in_rate_Hz/2 - 1) pfir_in_rate_Hz/2];
    pfir_stopbands = round(pfir_stopuse/(pfir_in_rate_Hz)*fftlen/dec_before_pfir);
    fgrid_sb0 = fgrid(pfir_stopbands(1):pfir_stopbands(2));
    pfir_sb0_response = ones(1,length(fgrid_sb0))*pfir_pb_response(end);
    wt_sb0 = ones(1,length(fgrid_sb0))*rxorx_config.pfir_stopband_weight;
end

%% Setting the Number of Taps Based On The Decimation Rate 
if ( ( pfir_decimation == 2 || pfir_decimation == 4 ) && RHB1_enable == 1)
    N = 72;
elseif (pfir_decimation == 2 || RHB1_enable == 1)
    N = 48;
else
    N = 23;
end

%% Plotting PFIR Passband and Stopband Response
if debugplot == 1
    figure;
    plot(fgrid_pb,pfir_pb_response);
    hold on;
    plot(fgrid_sb0,pfir_sb0_response,'r');
    title('PFIR Passband and Stopband Coefficients');
    legend('Passband','Stopband');
    grid;
end

%% Plotting Passband and Stopband Weighting
if debugplot == 1
    figure;
    plot(fgrid_pb,wt_pb,'ko-');
    hold on;
    plot(fgrid_sb0,wt_sb0,'bd-');
    title('Passband and Stopband Weighting');
    legend('Passband Weighting','Stopband Weighting');
    grid;
end

% Setting up for Remez algorithm
d = fdesign.arbmag('N,B,F,A',N-1,bands,fgrid_pb*2,pfir_pb_response,fgrid_sb0*2,pfir_sb0_response);

% Filter design object creation
Hd = design(d,'equiripple','B1Weights',wt_pb,'B2Weights',transpose(wt_sb0),'SystemObject',false);



%% Calculate PFIR Frequency Response
pfir = Hd.Numerator;

if N == 23
    Np = 24
    pfir = [pfir 0];
else
    Np = N;

end
[FIR,f] = freqz(pfir,1,ceil(fftlen/dec_before_pfir));
if debugplot == 1
    figure;
    plot(f/2/pi*pfir_in_rate_Hz,dbv(abs(FIR)));
    title('PFIR Frequency Response');
    xlabel('MHz');
    ylabel('dB');
    grid;
end

%% Write PFIR Coefficients to File

if max(pfir) < 0.5
    mult = 2;
elseif max(pfir) > ((2^15)-1)/2^15
    mult = 0.5;
else
    mult = 1;
end

%% Plot Rounded PFIR Coeeficients
pfirb = bround(pfir*mult,15);
[PFIR,fpfir] = freqz(pfirb/mult,1,ceil(fftlen/dec_before_pfir),'whole');
if debugplot == 1
    figure;
    plot(fpfir/2/pi*Fs_pfirout,dbv(abs(PFIR)));
    grid;
    title('Rounded PFIR Coeficient Response');
    xlabel('MHz');
    ylabel('dB');
end

%% Combine the PFIR Response With the Other Filters for Total System Response
[PFIR,f] = freqz(pfir,1,floor(fftlen/dec_before_pfir),'whole');
PFIRtemp = [];
for iter = 1:dec_before_pfir
    PFIRtemp = [PFIRtemp; PFIR];
end
PFIRuse = [PFIRtemp(1:end); PFIRtemp(1:10)];
size(PFIRuse),size(HBOUTanalog);

% Multiplying the HB output with the PFIR output for HBoutanalog data
FINAL = HBOUTanalog.*transpose(PFIRuse(1:length(HBOUTanalog)));
FINALDig = HBOUT.*PFIRuse(1:length(HBOUT));

%% Plotting Composite Digital Filter Response
if debugplot == 1
    figure;
    filterplot_fft(FINALDig(1:end/2),fhbout(1:end/2),adc_Fs,'Composite Digital Filter Response',[0 Fp_Hz],pfir_stop);
    axis([0 adc_Fs/MHz/2 -140 5]);
    xlabel('MHz');
    ylabel('dB');
end

%% Plotting Total Digital and Analog System Response

if isempty(fhandle)
    figure;
else
    axes(fhandle);
    cla;
    
end
hold off;
plot(frespADC(1:end/2)/MHz,dbv(abs(ADCresp(1:end/2))),'b');hold on;
plot(frespADC(1:end/2)/MHz,dbv(abs(TIAresp(1:end/2))),'g--');
plot(frespADC(1:end/2)/MHz,dbv(abs(analogresp(1:end/2))),'r-');
filterplot_fft(FINAL(1:end/2),fhbout(1:end/2),adc_Fs,'Composite Analog and Digital Filter Response',[0 Fp_Hz],pfir_stop);
leg = legend('ADC resp','TIA resp','Composite Analog Response','Composite Response');
leg.TextColor = 'red';
leg.Location = 'southwest';
axis([0 adc_Fs/MHz/2 -140 5]);
xlabel('MHz');
ylabel('dB');

%% update the mykonos_config file at thsi point and return

rxorx_config.pfir_coefs = pfirb*2^15;
rxorx_config.pfir_gain = 1/mult;
rxorx_config.pfir_no_of_coefs = Np;
% update ADC codes here
rxorx_config.ADC_codes = AdcCodes;

profile = rxorx_config;
return