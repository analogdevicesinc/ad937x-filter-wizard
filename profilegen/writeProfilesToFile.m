function writeProfilesToFile(mykonos_config, filename)        
    profileFileVersion = 0;  %update this if format of this file changes

    fd = fopen(filename, 'w');
        
    fprintf(fd, '%s%d%s%d%s%3.3f%s\n', '<profile AD9371 version=', profileFileVersion, ' name=Rx ', mykonos_config.Rx.RFBW_MHz, ', IQrate ', mykonos_config.Rx.output_rate_MHz, '>');
    
    % Write Clocks structure
    fprintf(fd, '%s\n', ' <clocks>');  
    devclk = mykonos_config.CLK.selectedDEV_CLK_rate_MHz;        
    fprintf(fd, '%s%d%s\n', '  <deviceClock_kHz=', devclk * 1000, '>'); 
    fprintf(fd, '%s%d%s\n', '  <clkPllVcoFreq_kHz=', mykonos_config.CLK.VCO_CLK_rate_MHz * 1000, '>');
    fprintf(fd, '%s%d%s\n', '  <clkPllVcoDiv=', mykonos_config.CLK.VCO_CLK_divider, '>');      
    fprintf(fd, '%s%d%s\n', '  <clkPllHsDiv=', mykonos_config.CLK.HS_CLK_divider, '>');      
    fprintf(fd, '%s\n', ' </clocks>');
    
    % Write Rx Settings structure
    writeRxProfileToFile(mykonos_config, fd);
    
    % Write Observatin Rx Settings structure
    writeObsRxProfileToFile(mykonos_config, fd);
    
    % Write Sniffer Rx Settings structure
    writeSnifferRxProfileToFile(mykonos_config, fd);
    
    % Write Tx Settings structure
    writeTxProfileToFile(mykonos_config, fd);
    
    fprintf(fd, '%s\n', '</profile>');
    fclose(fd);
    
function writeRxProfileToFile(mykonos_config, fd) 
    % Write Rx Settings structure
    fprintf(fd, '\n');
    fprintf(fd, '%s\n', ' <rx>');
    fprintf(fd, '%s%d%s\n', '  <adcDiv=', mykonos_config.Rx.ADC_clk_divider, '>'); 
    fprintf(fd, '%s%d%s\n', '  <rxFirDecimation=', mykonos_config.Rx.pfir_decimation, '>'); 
    
    if (mykonos_config.Rx.dec5_enable == 1)
       dec5 = 5;
       dec5hr = 1;  %high rejection dec 5 only enabled for Rx when dec5 enabled     
    else 
        dec5 = 4;
        dec5hr = 0;
    end
    fprintf(fd, '%s%d%s\n', '  <rxDec5Decimation=', dec5, '>'); 
  
    
    fprintf(fd, '%s%d%s\n', '  <enHighRejDec5=', dec5hr, '>');     
    
    if (mykonos_config.Rx.rhb1_enable == 1)
        rhb1dec = 2;
    else
        rhb1dec = 1;
    end
    
    fprintf(fd, '%s%d%s\n', '  <rhb1Decimation=', rhb1dec, '>');     
   
    fprintf(fd, '%s%d%s\n', '  <iqRate_kHz=', (mykonos_config.Rx.output_rate_MHz * 1000), '>');     
    fprintf(fd, '%s%d%s\n', '  <rfBandwidth_Hz=', mykonos_config.Rx.RFBW_MHz * 1e6, '>');  
    fprintf(fd, '%s%d%s\n', '  <rxBbf3dBCorner_kHz=', mykonos_config.Rx.tia_fc_MHz * 1e3, '>'); 
     
    % Print out FIR filter coefs
    if (mykonos_config.Rx.pfir_gain == 0.25)
        rxPfirGain = -12;
    elseif (mykonos_config.Rx.pfir_gain == 0.5)
        rxPfirGain = -6;
    elseif (mykonos_config.Rx.pfir_gain == 1)
        rxPfirGain = 0;
    elseif (mykonos_config.Rx.pfir_gain == 2)
        rxPfirGain = 6;
    end
   
    fprintf(fd, '\n');
    fprintf(fd, '%s%d%s%d%s\n', '  <filter FIR gain=', rxPfirGain, ' num=', mykonos_config.Rx.pfir_no_of_coefs, '>');  
    
    %RxCoefSum = sum(mykonos_config.Rx.pfir_coefs)/32768
    for i = 1:1:numel(mykonos_config.Rx.pfir_coefs)
        fprintf(fd, '  %d\n', mykonos_config.Rx.pfir_coefs(i));
    end
    
    fprintf(fd, '%s\n', '  </filter>');
    
    fprintf(fd, '\n');
    fprintf(fd, '%s%d%s\n', '  <adc-profile num=', numel(mykonos_config.Rx.ADC_codes), '>');
    for i = 1:1:numel(mykonos_config.Rx.ADC_codes)
        fprintf(fd, '  %d\n', mykonos_config.Rx.ADC_codes(i));
    end
    fprintf(fd, '%s\n', '  </adc-profile>');

    
    fprintf(fd, '%s\n', ' </rx>');
    
function writeObsRxProfileToFile(mykonos_config, fd) 
    % Write Observatin Rx Settings structure
    fprintf(fd, '\n');
    fprintf(fd, '%s\n', ' <obs>');
    fprintf(fd, '%s%d%s\n', '  <adcDiv=', mykonos_config.ORx.ADC_clk_divider, '>'); 
    fprintf(fd, '%s%d%s\n', '  <rxFirDecimation=', mykonos_config.ORx.pfir_decimation, '>'); 
    
    if (mykonos_config.ORx.dec5_enable == 1)
       dec5 = 5;
       dec5hr = 1;  %high rejection dec 5 only enabled for Rx when dec5 enabled     
    else 
        dec5 = 4;
        dec5hr = 0;
    end
    fprintf(fd, '%s%d%s\n', '  <rxDec5Decimation=', dec5, '>'); 
  
    
    fprintf(fd, '%s%d%s\n', '  <enHighRejDec5=', dec5hr, '>');     
    
    if (mykonos_config.ORx.rhb1_enable == 1)
        rhb1dec = 2;
    else
        rhb1dec = 1;
    end
    
    fprintf(fd, '%s%d%s\n', '  <rhb1Decimation=', rhb1dec, '>');     
   
    fprintf(fd, '%s%d%s\n', '  <iqRate_kHz=', (mykonos_config.ORx.output_rate_MHz * 1000), '>');     
    fprintf(fd, '%s%d%s\n', '  <rfBandwidth_Hz=', mykonos_config.ORx.RFBW_MHz * 1e6, '>');  
    fprintf(fd, '%s%d%s\n', '  <rxBbf3dBCorner_kHz=', mykonos_config.ORx.tia_fc_MHz * 1e3, '>'); 
     
    % Print out FIR filter coefs
    if (mykonos_config.ORx.pfir_gain == 0.25)
        rxPfirGain = -12;
    elseif (mykonos_config.ORx.pfir_gain == 0.5)
        rxPfirGain = -6;
    elseif (mykonos_config.ORx.pfir_gain == 1)
        rxPfirGain = 0;
    elseif (mykonos_config.ORx.pfir_gain == 2)
        rxPfirGain = 6;
    end
   
    fprintf(fd, '\n');
    fprintf(fd, '%s%d%s%d%s\n', '  <filter FIR gain=', rxPfirGain, ' num=', mykonos_config.ORx.pfir_no_of_coefs, '>');  
    
    for i = 1:1:numel(mykonos_config.ORx.pfir_coefs)
        fprintf(fd, '  %d\n', mykonos_config.ORx.pfir_coefs(i));
    end
    
    fprintf(fd, '%s\n', '  </filter>');
    
    fprintf(fd, '\n');
    fprintf(fd, '%s%d%s\n', '  <adc-profile num=', numel(mykonos_config.ORx.ADC_codes), '>');
    for i = 1:1:numel(mykonos_config.ORx.ADC_codes)
        fprintf(fd, '  %d\n', mykonos_config.ORx.ADC_codes(i));
    end
    fprintf(fd, '%s\n', '  </adc-profile>');
    fprintf(fd, '%s\n', ' </obs>');
    
function writeSnifferRxProfileToFile(mykonos_config, fd) 
%Sniffer profile Not implemented yet    

    if (mykonos_config.Snf.profileEnabled == 1)
    % Write Sniffer Rx Settings structure
    fprintf(fd, '\n');
    fprintf(fd, '%s\n', ' <sniffer>');
    
    fprintf(fd, '%s%d%s\n', '  <adcDiv=', mykonos_config.Snf.ADC_clk_divider, '>'); 
    fprintf(fd, '%s%d%s\n', '  <rxFirDecimation=', mykonos_config.Snf.pfir_decimation, '>'); 
    
    if (mykonos_config.Snf.dec5_enable == 1)
       dec5 = 5;
       dec5hr = 1;  %high rejection dec 5 only enabled for Rx when dec5 enabled     
    else 
        dec5 = 4;
        dec5hr = 0;
    end
    fprintf(fd, '%s%d%s\n', '  <rxDec5Decimation=', dec5, '>'); 
  
    
    fprintf(fd, '%s%d%s\n', '  <enHighRejDec5=', dec5hr, '>');     
    
    if (mykonos_config.Snf.rhb1_enable == 1)
        rhb1dec = 2;
    else
        rhb1dec = 1;
    end
    
    fprintf(fd, '%s%d%s\n', '  <rhb1Decimation=', rhb1dec, '>');     
   
    fprintf(fd, '%s%d%s\n', '  <iqRate_kHz=', (mykonos_config.Snf.output_rate_MHz * 1000), '>');     
    fprintf(fd, '%s%d%s\n', '  <rfBandwidth_Hz=', mykonos_config.Snf.RFBW_MHz * 1e6, '>');  
    fprintf(fd, '%s%d%s\n', '  <rxBbf3dBCorner_kHz=', mykonos_config.Snf.tia_fc_MHz * 1e3, '>'); 
     
    % Print out FIR filter coefs
    if (mykonos_config.Snf.pfir_gain == 0.25)
        rxPfirGain = -12;
    elseif (mykonos_config.Snf.pfir_gain == 0.5)
        rxPfirGain = -6;
    elseif (mykonos_config.Snf.pfir_gain == 1)
        rxPfirGain = 0;
    elseif (mykonos_config.Snf.pfir_gain == 2)
        rxPfirGain = 6;
    end
   
    fprintf(fd, '\n');
    fprintf(fd, '%s%d%s%d%s\n', '  <filter FIR gain=', rxPfirGain, ' num=', mykonos_config.Snf.pfir_no_of_coefs, '>');  
    
    %RxCoefSum = sum(mykonos_config.Rx.pfir_coefs)/32768
    for i = 1:1:numel(mykonos_config.Snf.pfir_coefs)
        fprintf(fd, '  %d\n', mykonos_config.Snf.pfir_coefs(i));
    end
    
    fprintf(fd, '%s\n', '  </filter>');
    
    fprintf(fd, '\n');
    fprintf(fd, '%s%d%s\n', '  <adc-profile num=', numel(mykonos_config.Snf.ADC_codes), '>');
    for i = 1:1:numel(mykonos_config.Snf.ADC_codes)
        fprintf(fd, '  %d\n', mykonos_config.Snf.ADC_codes(i));
    end
    fprintf(fd, '%s\n', '  </adc-profile>');
    
    fprintf(fd, '%s\n', ' </sniffer>');    
    end

    
function writeTxProfileToFile(mykonos_config, fd)
    % Write Tx Settings structure
    fprintf(fd, '\n');
    fprintf(fd, '%s\n', ' <tx>');
    fprintf(fd, '%s%2g%s\n', '  <dacDiv=', mykonos_config.Tx.DAC_clk_divider, '>'); 
    fprintf(fd, '%s%d%s\n', '  <txFirInterpolation=', mykonos_config.Tx.PFIR_interp, '>'); 
    
    if (mykonos_config.Tx.thb1_enable == 1)
        thb1Int = 2;
    else 
        thb1Int = 1;
    end
    fprintf(fd, '%s%d%s\n', '  <thb1Interpolation=', thb1Int, '>'); 
  
    if (mykonos_config.Tx.thb2_enable == 1)
        thb2Int = 2;
    else 
        thb2Int = 1;
    end
    fprintf(fd, '%s%d%s\n', '  <thb2Interpolation=', thb2Int, '>');     
    fprintf(fd, '%s\n', '  <txInputHbInterpolation=1>');                    
   
    fprintf(fd, '%s%d%s\n', '  <iqRate_kHz=', (mykonos_config.Tx.input_rate_MHz * 1000), '>');     
    fprintf(fd, '%s%d%s\n', '  <primarySigBandwidth_Hz=', mykonos_config.Tx.prim_sgl_RFBW_MHz * 1e6, '>');
    fprintf(fd, '%s%d%s\n', '  <rfBandwidth_Hz=', mykonos_config.Tx.synthesis_RFBW_MHz * 1e6, '>');  
    fprintf(fd, '%s%d%s\n', '  <txDac3dBCorner_kHz=', mykonos_config.Tx.real_pole_fc * 1e3, '>'); 
    fprintf(fd, '%s%d%s\n', '  <txBbf3dBCorner_kHz=', mykonos_config.Tx.BBF_fc * 1e3, '>'); 
     
    
    %txCoefSum = sum(mykonos_config.Tx.pfir_coefs) / 32768
    % Print out FIR filter coefs
    if (mykonos_config.Tx.pfir_gain == 1)
        txPfirGain = 0;
    elseif (mykonos_config.Tx.pfir_gain == 0.5)
        txPfirGain = 6;
    end
   
    fprintf(fd, '\n');
    fprintf(fd, '%s%d%s%d%s\n', '  <filter FIR gain=', txPfirGain, ' num=', mykonos_config.Tx.pfir_no_of_coefs, '>');  
    
    for i = 1:1:numel(mykonos_config.Tx.pfir_coefs)
        fprintf(fd, '  %d\n', mykonos_config.Tx.pfir_coefs(i));
    end
    
    fprintf(fd, '%s\n', '  </filter>');
    fprintf(fd, '%s\n', ' </tx>');