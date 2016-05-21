function [] = generate_rxorxpfir_file(mykonos_config)

%GENERATE_RXORXPFIR_FILE Generates pfir coeff file for Apps


pfirfile = sprintf('data/%sPFIR_usecase%d.txt',mode,use_case)
%pfir = readfile(pfirfile);
pfir = coef/sum(coef)
max(pfir),sum(pfir)
filename = ''
if max(pfir) < 0.5
    mult = 2;
    gain = '-6dB'
elseif max(pfir) >= 1.0
    mult = 0.5
    gain = '+6dB'
    
else
    mult = 1;
    gain = '0dB'
end
pfirb = bround(pfir*mult,15);
if max(pfirb) >=1.0
    error('Max coefficient is greater than or equal to 1\n')
end

%Generate file name
adcrate_MHz = mykonos_config.Rx.ADC_clk_rate_MHz;
outputrate_MHz = mykonos_config.Rx.output_rate_MHz;
bandwidth = mykonos_config.Rx.RFBW_MHz;


ADCrate = fix(adcrate_MHz);
ADCrate_frac = round(100*(adcrate_MHz - ADCrate))
OR = fix(outputrate_MHz);
OR_frac = round(100*(outputrate_MHz - OR));
file_name = sprintf('RxPFIRApp%d_BW%d_ADC%dp%d_OR%dp%d.ftr',usecase_no,ADCrate, ADCrate_frac, OR,OR_frac,bandwidth);

%Create file header based on parameters
header = ['ENABLE_DEC5HR=%dx\n' ...
          'DEC5_DECIMATION=%dx\n' ...
          'RHB1_DECIMATION=%dx\n' ... 
          'RXFIR_GAIN=%s\n' ...
          'RXFIR_OUTPUTRATE=%0.2f\n' ...
          'RXTIA_3dBCORNER=%d\n' ...
          '\n' ...
          'RXFIR\n'];
%Open file
f_id = fopen(file_name,'w');

fprintf(f_id,header,output_rate,fir_M,thb1_L,thb2_L,thb3_L,int5_L,tx_bbf_3dbcorner,dacfilter_3dbcorner,txfir_gain_DB);
%Print array
fprintf(f_id,'%d\n',coeff_array);
fprintf(f_id,'RXFIR_END');
    
fclose(f_id);
end

