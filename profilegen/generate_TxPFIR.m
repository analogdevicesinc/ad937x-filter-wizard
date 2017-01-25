function profile = generate_TxPFIR(tx_config, fhandle);
%   GENERATE_TX_PFIR    generate Programable FIR filter for the TX path
%   profile = GENERATE_TxFIR(tx_config, fhandle);
%
%   tx_config is the substructure for tx



%% Constants - Do Not Modify
fftlen = 1024*8;           % FFT length
MHz = 1e6;                  % MHz macro
PD_Amp_fc = 600*MHz;        % PD amplifier corner frequency            
postPD_fc = 890*MHz;        % Post PD amplifier corner frequency
opt_for_dac_image = 0;      % Pushes BBF corner frequency further out to permit easier computation
bands = 2;                  % Passband and stopband

%% Input Configuration Parameters
Fspfir = tx_config.input_rate_MHz*MHz;          % PFIR input sampling rate
pfir_interp = tx_config.PFIR_interp;            % PFIR interpolation setting where 0 = pfir disabled, 1 = no interpolation, 2 = interpolate-by-2, 4 = not currently supported
Fp = tx_config.synthesis_RFBW_MHz/2*MHz;        % Transmitter passband single-sided bandwidth
Fspfirout = Fspfir*pfir_interp;                 % PFIR output sampling rate
thb2_en = tx_config.thb2_enable;                % Transmitter half Band 1 (THB1) filter enable where, 1 = enabled, 0 = disabled
Fsdac = Fspfir*2^(pfir_interp-1)*2^thb2_en*2;   % DAC sampling rate
pb_wt = tx_config.pfir_passband_weight;         % Passband weight selected empirically
sb_wt = tx_config.pfir_stopband_weight;         % Stopband weight selected empirically

debugplot = 0;              % Switch to enable plotting interim checks for debug

%% Rules for GUI

% Real pole Fc >= 187 MHz

%% DAC Fs Rate and BBF Fc Calculation
if Fp < 20*MHz
    BBF_fc = 20*MHz;
elseif Fp > 125*MHz
    BBF_fc = 125*MHz;
else
    BBF_fc = Fp;
end

%% BBF Corner Frequency Selection
if opt_for_dac_image == 1
    if Fp*2 > 125*MHz
        BBF_fc = 125*MHz;
    else
        BBF_fc = Fp*2;
    end
end

%% Real Pole Corner Frequency Calculation
if Fp*2 < 92*MHz
    prePD_rp_fc = 92*MHz;
elseif Fp*2 > 187*MHz
    prePD_rp_fc = 187*MHz;
else
    prePD_rp_fc = Fp*2;
end

freqgrid = linspace(0,Fsdac,fftlen);

%% Calculating Individual Analog Responses
dac = sin(pi*freqgrid/Fsdac)./(pi*freqgrid/Fsdac);
BBF_resp = 1./(1+ i*(freqgrid./BBF_fc).^2);
rp_resp = 1./(1+ i*freqgrid./prePD_rp_fc);
PDAmp_resp = 1./(1+ i*freqgrid./PD_Amp_fc);
postPD_resp = 1./(1+ i*freqgrid./postPD_fc);

%% Composite Analog Response Calculation
freqplot = freqgrid/MHz;
analog = dac.*BBF_resp.*rp_resp.*PDAmp_resp.*postPD_resp;

%% Plot Individual Analog Responses
if debugplot == 1
    figure;
    plot(freqplot,dbv(abs(dac)),'y');
    grid;
    hold on;
    plot(freqplot,dbv(abs(BBF_resp)));
    plot(freqplot,dbv(abs(rp_resp)),'k');
    plot(freqplot,dbv(abs(PDAmp_resp)),'r');
    plot(freqplot,dbv(abs(postPD_resp)),'g');
    plot(freqplot,dbv(abs(analog)),'c');
    axis([0 Fsdac/MHz -50 5]);
    title('Analog Responses');
    legend('DAC','BBF','Real Pole','PD Amp','Post PD','Composite Analog');
    xlabel('MHz');
    ylabel('dB');
end

%% Load All Digital Filters
thb1 = 2^(-14)*[21 0 -56 0 108 0 -188 0 319 0 -526 0 876 0 -1632 0 5179 8192 5179 0 -1632 0 876 0 -526 0 319 0 -188 0 108 0 -56 0 21];
thb2 = 2^(-9)*[-17 0 145 256 145 0 -17];    

%% Calculating Final Response for PFIR Generation
if thb2_en == 1
    [THB1,f1] = freqz(thb1,1,fftlen/2,'whole');
    THB1UP = [THB1; (THB1)];
    [THB2,f2] = freqz(thb2,1,fftlen,'whole');
    hDig = transpose(THB1UP).*transpose(THB2);
    finalresp = transpose(THB1UP).*transpose(THB2).*analog;
    
    if debugplot == 1
        figure
        plot(dbv(abs(THB1UP)));
        grid;
        figure;
        plot(freqplot,dbv(abs(THB1UP)));
        grid;
        hold on;
        plot(freqplot,dbv(abs(THB2)),'k');
        plot(freqplot,dbv(abs(analog)),'g');
        plot(freqplot,dbv(abs(finalresp)),'r');
        axis([0 Fsdac/MHz -100 5]);
        title('Analog and THB Response');
        legend('THB1','THB2','Composite Analog','Composite THB1, THB2 and Analog');
        xlabel('MHz');
        ylabel('dB');
    end
else
    [THB1,f1] = freqz(thb1,1,fftlen,'whole');
    hDig = transpose(THB1);
    finalresp = transpose(THB1).*analog;
    
    if debugplot == 1
        figure;
        plot(freqplot,dbv(abs(THB1)));
        grid;
        hold on;
        plot(freqplot,dbv(abs(analog)),'g');
        plot(freqplot,dbv(abs(finalresp)),'r');
        axis([0 Fsdac/MHz -100 5]);
        title('Analog and THB Response');
        legend('THB1','Composite Analog','Composite THB1 and Analog');
        xlabel('MHz');
        ylabel('dB');
    end
end

%% Generate Final Response for Correction
pbendfreq = ceil(Fp/Fsdac*fftlen);
respuse = finalresp(2:pbendfreq+1);

absresp = transpose(abs(finalresp));
absrespuse = 1./transpose((abs(respuse)));

fgrid = linspace(0,Fspfirout,fftlen*Fspfirout/Fsdac);
fgrid_pb = fgrid(1:pbendfreq)/Fspfirout*2;    % 2 required since Matlab expects grid b/w 0 and 1
wt_pb = ones(1,length(fgrid_pb))*pb_wt;

%% PFIR Maximum Frequency Calculation
endfreq = round((Fspfirout/2)*fftlen/Fsdac);

%% Stopband Response Based on PFIR Interpolation
if pfir_interp == 1
    fgrid_sb = fgrid(endfreq)/Fspfirout;
    fgrid_sb(end) = 1;
    stopresp = ones(1,length(fgrid_sb))*absrespuse(end);
    wt_sb = ones(1,length(fgrid_sb))*sb_wt;
elseif pfir_interp == 2
    sb_wt = sb_wt*2;
    pfir_stopuse = [Fspfirout/2-Fp Fspfirout/2];
    pfir_stopbands = round(pfir_stopuse/(Fsdac)*fftlen)*2;
    fgrid_sb = fgrid(pfir_stopbands(1):pfir_stopbands(2))/Fspfirout;
    stopresp = zeros(1,length(fgrid_sb));
    wt_sb = ones(1,length(fgrid_sb))*sb_wt;
end

%% Setting the Number of Taps Based On The Interpolation Rate
if pfir_interp == 1
    N = 15;
elseif pfir_interp == 2
    N = 32;
end

%% Passband and Stopband Response Plots
if debugplot == 1
    figure;
    plot(fgrid_pb,dbv(absrespuse));
    hold on;
    plot(fgrid_sb,stopresp,'r');
    legend('Passband','Stopband');
    title('Passband and Stopband Frequency Response');
    xlabel('MHz');
    ylabel('dB');
    grid;
end

%% Passband and Stopband Weighting Plots
if debugplot == 1
    figure;
    plot(fgrid_pb,wt_pb,'ko-');
    hold on;
    plot(fgrid_sb,wt_sb,'bo-');
    legend('Passband Weighting','Stopband Weighting');
    grid;
end

%% Calculating PFIR Coeeficients
d = fdesign.arbmag('N,B,F,A',N-1,bands,fgrid_pb,absrespuse,fgrid_sb,stopresp);
Hd = design(d,'equiripple','B1Weights',wt_pb,'B2Weights',wt_sb,'SystemObject',false);

%% PFIR Taps and Coeeficients Plot 
pfir = Hd.Numerator;

if N == 15
    Np = 16;
    pfir = [pfir 0];
else
    Np = N;
end

if debugplot == 1
    figure; 
    stem((1:length(pfir))-1,pfir);
    grid;
    title('PFIR Taps and Coefficients');
    xlabel('Tap');
    ylabel('Coefficient');
end

%% PFIR Magnitude Plot
[FIR,fFIR] = freqz(pfir,1,(fftlen*Fspfirout/Fsdac),'whole');
if debugplot == 1
    figure;
    plot(fFIR/2/pi*Fspfirout,dbv(abs(FIR)));
    grid;
    title('PFIR Magnitude Response');
    xlabel('MHz');
    ylabel('dB');
end

%% Determining Total Interpolation for DAC
if thb2_en == 1
    OUT = [FIR; FIR; FIR; FIR];
else
    OUT = [FIR; FIR];
end

%% Combined DAC, THB, and PFIR Response plot
if debugplot == 1
    figure;
    plot(freqplot,dbv(abs(OUT)));
    grid;
    hold on;plot(freqplot,dbv(abs(finalresp)),'r');
    axis([0 Fsdac/MHz -80 5]);
    title('PFIR + DAC Sinc + THB Responses');
    legend('PFIR','DAC Sinc + THB(s)');
    xlabel('MHz');
    ylabel('dB');
end

%% Final Composite Digital Respose
FINALdig = OUT .* transpose(hDig);

%% Final Composite Response Plot
FINAL = OUT.*transpose(finalresp);

%% Final Magnified Composite Response with Ripple Calculation
if isempty(fhandle)
    figure;
else
    axes(fhandle);
    cla;
    
end
              %R    G    B
traceColors = [0.0  0.5  1.0  %Trace1 color
               0.4  0.4  0.4  %Trace2 color
               0.0  0.0  0.0  %Trace3 color
               0.4  0.6  0.7
               0.2  0.8  0.8
               0.0  1.0  0.9];
%set(groot,'defaultAxesColorOrder',traceColors)
ax = gca;
ax.ColorOrder = traceColors;
hold off;
hold on;

%plot(freqplot,dbv(abs(dac)),'y');
%plot(freqplot,dbv(abs(BBF_resp)));
%plot(freqplot,dbv(abs(rp_resp)),'k');
%plot(freqplot,dbv(abs(PDAmp_resp)),'r');
%plot(freqplot,dbv(abs(postPD_resp)),'g');
%plot(freqplot,dbv(abs(OUT)), '--');
plot(freqplot,dbv(abs(FINALdig)), '--');
plot(freqplot,dbv(abs(analog)),'--');
plot(freqplot,dbv(abs(FINAL)));
xlabel('Baseband Frequency (MHz)');
ylabel('Magnitude (dB)');

grid on;
zoom on;
leg = legend('Composite Digital Response','Composite Analog Response','Composite Final Response');
leg.TextColor = 'black';
leg.Location = 'southwest';
axis([0 Fsdac/MHz -100 10]);
title('Composite Analog and Digital Signal Chain Response');


%axis([0 Fspfir/2/MHz -1.5 1.5]);
passbandvals = abs(FINAL(1:pbendfreq));
maxpass = dbv(max(passbandvals));
minpass = dbv(min(passbandvals));
line([1 Fp/MHz], [maxpass maxpass],'LineStyle','--','Color','r');
line([1 Fp/MHz], [minpass minpass],'LineStyle','--','Color','r');
str = sprintf('max ripple is %.2f dB',maxpass-minpass);
t = text(Fp/MHz/4, maxpass-5, str);
tt = t.FontWeight;
t.FontWeight = 'bold';

%% Create File with Coefficients and Correct PFIR Gain
pfirfile = sprintf('data/TxPFIR_Fp%s_OR%.2f.txt',Fp/MHz*2,Fspfir/MHz);
if max(pfir) < 0.5
    mult = 2;
elseif max(pfir) > ((2^15)-1)/2^15
    mult = 0.5;
else
    mult = 1;
end

% Rounding PFIR Coeeficients and Writing to File
pfirb = bround(pfir*mult,15);


%% update the profile with the new information
tx_config.pfir_coefs = pfirb*2^15;
tx_config.pfir_gain = mult;
tx_config.pfir_no_of_coefs = Np;
tx_config.real_pole_fc = prePD_rp_fc/MHz;
tx_config.BBF_fc = BBF_fc/MHz;
profile = tx_config;

return
