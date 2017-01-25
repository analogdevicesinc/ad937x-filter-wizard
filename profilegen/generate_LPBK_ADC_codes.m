function profile = generate_LPBK_ADC_codes(primary_sgl_RFBW_MHz, rxorx_config)
%   GENERATE_LPBK_ADC_CODES(primary_sgl_RFBW_MHz, rxorx_config)




%% Mykonos Rx Signal Processing Path Diagram
%I = imread('img/MykonosRxSignalPath.jpg');
%imshow(I);
%title('Mykonos Rx Signal Processing Path');

%% Constants - Do Not Modify
fftlen = 1024*8;        % FFT length 
MHz = 1e6;              % MHz declared as 1e6
bands = 2;              % Passband and stopband

%% Assign Input Configuration Parameters from structure to 

Fp_Hz = primary_sgl_RFBW_MHz*MHz/2;      % single side BW parameter
adc_Fs = rxorx_config.ADC_clk_rate_MHz*MHz;



%% ADC Response up to Fs
[ADCresp, frespADC, AdcCodes] = MykonosADCResponse(Fp_Hz,fftlen,adc_Fs);
rxorx_config.LPBK_ADC_codes = AdcCodes;

profile = rxorx_config;
return