function [ mykonos_config_updated ] = generate_Mykonos_datapath_config( mykonos_config,tx_fhandle, rx_fhandle, orx_fhandle, snf_fhandle, snrx_enabled);
%GENERATE_MYKONOS_DATAPATH_CONFIG Generate all the config parameters here
%   [ Mykonos_config ] =
%   generate_Mykonos_datapath_config(mykonos_config,tx_fhandle, rx_fhandle, orx_fhandle)
%
%   mykonos_config is the Mykonos configuration structure generated using
%   init_Mykonos_config
%   tx_fhandle is the handle to the Tx frequency response graph
%   rx_fhandle is the handle to the Rx frequency response graph
%   orx_fhandle is the handle to the ORx frequency response graph
%   snrx_fhandle is the handle to the Sniffer frequency response graph
%   snrx_enabled is 1 if Sniffer Rx profile needs to be generated


%% assign the required parameters to independent variables
Tx_input_rate_MHz = mykonos_config.Tx.input_rate_MHz;
Rx_output_rate_MHz = mykonos_config.Rx.output_rate_MHz;
ORx_output_rate_MHz = mykonos_config.ORx.output_rate_MHz;
Snf_output_rate_MHz = mykonos_config.Snf.output_rate_MHz;
Tx_prim_sgl_RFBW_MHz = mykonos_config.Tx.prim_sgl_RFBW_MHz;
Tx_synthesis_RFBW_MHz = mykonos_config.Tx.synthesis_RFBW_MHz;
Rx_RFBW_MHz = mykonos_config.Rx.RFBW_MHz;
ORx_RFBW_MHz = mykonos_config.ORx.RFBW_MHz;
Snf_RFBW_MHz = mykonos_config.Snf.RFBW_MHz;



%% Check input parameter bounds

% Tx Input rate should be greater than 30MHz and less than 320MHz
if Tx_input_rate_MHz < 30
    % return error to GUI
    error('Tx input rate should be greater than 30MHz and less than 320MHz. Tx input rate was %0.2f. ERROR_CODE1',...
        Tx_input_rate_MHz);
  
elseif Tx_input_rate_MHz > 320
    error('Tx input rate should be greater than 30MHz and less than 320MHz. Tx input rate was %0.2f. ERROR_CODE1',...
        Tx_input_rate_MHz);
end

% Rx output rate should be greater than 20MHz and less than 200MHz
if Rx_output_rate_MHz < 20
    % return error to GUI
    error('Rx output rate should be greater than 20MHz and less than 200MHz. Rx output rate was %0.2f. ERROR_CODE1',...
        Rx_output_rate_MHz);
elseif Rx_output_rate_MHz > 200
    error('Rx output rate should be greater than 20MHz and less than 200MHz. Rx output rate was %0.2f. ERROR_CODE1',...
        Rx_output_rate_MHz);
end

% ORx output rate should be greater than 30MHz and less than 320MHz
if ORx_output_rate_MHz < 30
    % return error to GUI
    error('ORx output rate should be greater than 20MHz and less than 320MHz. ORx output rate was %0.2f. ERROR_CODE1',...
        ORx_output_rate_MHz);
elseif ORx_output_rate_MHz > 320
    error('ORx output rate should be greater than 20MHz and less than 320MHz. ORx output rate was %0.2f. ERROR_CODE1',...
        ORx_output_rate_MHz);
end

% Snf Rx output rate should be greater than 20MHz and less than 200MHz
if Snf_output_rate_MHz < 20
    % return error to GUI
    error('Sniffer Rx output rate should be greater than 20MHz and less than 200MHz. Rx output rate was %0.2f. ERROR_CODE1',...
        Snf_output_rate_MHz);
elseif Snf_output_rate_MHz > 200
    error('Sniffer Rx output rate should be greater than 20MHz and less than 200MHz. Rx output rate was %0.2f. ERROR_CODE1',...
        Snf_output_rate_MHz);
end

% Tx_prim_sgl_RFBW_MHz should be greater than 30MHz and less than 320MHz
if Tx_prim_sgl_RFBW_MHz < 5
    % return error to GUI
    error('Primary signal RF BW should be greater than 5MHz and less than 100MHz');
elseif Tx_prim_sgl_RFBW_MHz > 100
    error('Primary signal RF BW should be greater than 5MHz and less than 100MHz');
end


% Tx_synthesis_RFBW_MHz should be greater than 20MHz and less than 240MHz
if Tx_synthesis_RFBW_MHz < 20
    % return error to GUI
    error('Tx synthesis signal RF BW should be greater than 20MHz and less than 240MHz');
elseif Tx_synthesis_RFBW_MHz > 240
    error('Tx synthesis signal RF BW should be greater than 20MHz and less than 240MHz');
end


% Rx_RFBW should be greater than 5MHz and less than 100MHz (5MHz is
% arbitrary at this point. It can be lower)
if Rx_RFBW_MHz < 5
    % return error to GUI
    error('Rx signal RF BW should be greater than 5MHz and less than 100MHz');
elseif Rx_RFBW_MHz > 100
    error('Rx signal RF BW should be greater than 5MHz and less than 100MHz');
end

% ORx_RFBW should be greater than 5MHz and less than 240MHz 
if ORx_RFBW_MHz < 5
    % return error to GUI
    error('ORx signal RF BW should be greater than 5MHz and less than 240MHz');
elseif ORx_RFBW_MHz > 240
    error('ORx signal RF BW should be greater than 5MHz and less than 240MHz');
end

% Snf_RFBW should be greater than 5MHz and less than 100MHz (5MHz is
% arbitrary at this point. It can be lower)
if Snf_RFBW_MHz < 5
    % return error to GUI
    error('Sniffer Rx signal RF BW should be greater than 5MHz and less than 100MHz');
elseif Snf_RFBW_MHz > 100
    error('Sniffer Rx signal RF BW should be greater than 5MHz and less than 100MHz');
end



%% Determine ORx ADC rate, and datapath blocks to be used in the ORx datapath

adc_rate_mult_5 = [40 20 10 5];
adc_rate_5 = ORx_output_rate_MHz * adc_rate_mult_5;

adc_rate_mult_4 = [32 16 8 4];
adc_rate_4 = ORx_output_rate_MHz * adc_rate_mult_4;

valid_orx_adc_rate_5 = find(adc_rate_5 <= 1600)  % In DEC5 mode, max ORx_ADC_rate is 1600MHz

valid_orx_adc_rate_4 = find(adc_rate_4 <= 1280)  % In DEC4 mode, max ORx_ADC_rate is 1280MHz

hs_dig_clk_rate_5 = adc_rate_5(valid_orx_adc_rate_5(1))
hs_dig_clk_rate_4 = adc_rate_4(valid_orx_adc_rate_4(1))

if hs_dig_clk_rate_5 > hs_dig_clk_rate_4
    hs_dig_clk_rate_MHz = hs_dig_clk_rate_5
    ORx_DEC5_enable = 1;    % Rx and ORx modes are both either DEC4 or DEC5
    Rx_DEC5_enable = 1;
    Snf_DEC5_enable = 1;
else
    hs_dig_clk_rate_MHz = hs_dig_clk_rate_4
    ORx_DEC5_enable = 0;
    Rx_DEC5_enable = 0;
    Snf_DEC5_enable = 0;
end

% adc_rate is common for Rx and ORx path in almost all cases and is the
% same as the hs_dig_clk_rate. Rx_ADC has a rx_adc_clk_rate_divider that
% can be either 1 or 2, but this may require some more thought since we
% will need to confirm that FW will work with varying ADC rates on Rx/ORx
% paths. THis non-equal rate is only possible when we are in DEC4 mode
ORX_Rx_adc_rate_MHz = hs_dig_clk_rate_MHz  



%% Determine the filters to be enabled in the ORx path
total_ORx_dec = ORX_Rx_adc_rate_MHz/ORx_output_rate_MHz;

if total_ORx_dec > 10
    ORx_RHB1_enable = 1     % PFIR decimates by 2 for path decimation > 5
                           % Anything > 10 we use the RHB1 filter
else
    ORx_RHB1_enable = 0     
end

if total_ORx_dec > 20
    ORx_PFIR_decimation = 4
elseif total_ORx_dec > 5
    ORx_PFIR_decimation = 2
else
    ORx_PFIR_decimation = 1
end

% check to confirm that the adc_rate is < 1600 for DEC5 mode and < 1280 for
% DEC4 mode
if ORx_DEC5_enable == 1
    if ORX_Rx_adc_rate_MHz > 1600 || ORX_Rx_adc_rate_MHz < 980
        error('Max ADC clk rate should be less than 1600MHz. Calculated ADC_CLK rate is %0.2f. ERROR_CODE1', ...
            ORX_Rx_adc_rate_MHz);
    end
else
    if ORX_Rx_adc_rate_MHz > 1280 || ORX_Rx_adc_rate_MHz < 980
        error('Max ADC clk rate should be less than 1280MHz in DEC4 mode. Calculated ADC_CLK rate is %0.2f. ERROR_CODE1' ...
            ,ORX_Rx_adc_rate_MHz);
    end
end    
    

%% determine the filters that need to be active/enabled in the Rx path
total_Rx_dec = ORX_Rx_adc_rate_MHz/Rx_output_rate_MHz


if total_Rx_dec > 10
    Rx_RHB1_enable = 1     % PFIR decimates by 2 for path decimation > 5
                           % Anything > 10 we use the RHB1 filter
else
    Rx_RHB1_enable = 0     
end


if total_Rx_dec > 20
    Rx_PFIR_decimation = 4
elseif total_Rx_dec > 5
    Rx_PFIR_decimation = 2
else
    Rx_PFIR_decimation = 1
end

%% determine the filters that need to be active/enabled in the Sniffer Rx path
total_Snf_dec = ORX_Rx_adc_rate_MHz/Snf_output_rate_MHz


if total_Snf_dec > 10
    Snf_RHB1_enable = 1     % PFIR decimates by 2 for path decimation > 5
                           % Anything > 10 we use the RHB1 filter
else
    Snf_RHB1_enable = 0     
end


if total_Snf_dec > 20
    Snf_PFIR_decimation = 4
elseif total_Snf_dec > 5
    Snf_PFIR_decimation = 2
else
    Snf_PFIR_decimation = 1
end

%% determine DAC CLK rate and Tx datapath active filters

% since Tx datapath has only interpolation by power of 2, a decimate by
% DEC5 neccesitates the use of the dac_clk divider ratio of 2.5. If DEC4
% mode is used, then dac_clk_divider is 2. Max DAC_CLK rate should be less
% than 640MHz
if ORx_DEC5_enable == 1
    dac_clk_divider = 2.5
else
    dac_clk_divider = 2
end

dac_clk_rate_MHz = hs_dig_clk_rate_MHz/dac_clk_divider

% check for max dac clk rate
if dac_clk_rate_MHz > 640
    error('Max DAC clk rate should be less than 640MHz. Calculated DAC_CLK rate is %0.2f. ERROR_CODE1', ...
        dac_clk_rate_MHz)
end
total_interpolation = dac_clk_rate_MHz/Tx_input_rate_MHz

if total_interpolation == 16
    Tx_PFIR_interpolation = 4
    thb2_enable = 1
elseif total_interpolation == 8
    Tx_PFIR_interpolation = 2
    thb2_enable = 1
elseif total_interpolation == 4
    Tx_PFIR_interpolation = 1
    thb2_enable = 1
elseif total_interpolation == 2
    Tx_PFIR_interpolation = 1
    thb2_enable = 0
else
    error('Total Interpolation should be 2, 4, 8 or 16. Calculated Tx interpolation was %d. ERROR_CODE2', ...
        total_interpolation);
end


%% Determine the VCO rate and clock dividers
% Combination of HS_CLK_divider and DEC5 or DEC4 needs to be 20. Hence, if DEC5
% is enabled, then HS_divider is 4 or vice versa
if ORx_DEC5_enable == 1
    HS_CLK_divider = 4;
else
    HS_CLK_divider = 5;
end

HS_CLK_rate_MHz = hs_dig_clk_rate_MHz * HS_CLK_divider;

if HS_CLK_rate_MHz < 2000
    error('HS_CLK_rate_MHz is less than 2GHz. It is %0.2g',HS_CLK_rate_MHz);
end

% Finally, VCO rate needs to be b/w 6.25GHz and 12.5GHz. VCO_CLK_divider
% needs to get the VCO rate up into this band
VCO_max_rate = 12500
if HS_CLK_rate_MHz < VCO_max_rate/3
    VCO_CLK_divider = 3;
elseif HS_CLK_rate_MHz < VCO_max_rate/2
    VCO_CLK_divider = 2;
elseif HS_CLK_rate_MHz < VCO_max_rate/1.5
    VCO_CLK_divider = 1.5
else
    VCO_CLK_divider = 1;
end

VCO_CLK_rate_MHz = HS_CLK_rate_MHz * VCO_CLK_divider;

% check to confirm that VCO clk rate is within bounds
if VCO_CLK_rate_MHz < 6000 || VCO_CLK_rate_MHz > 12500
    error('VCO clock rate should be greater than 6GHz and less than 12.5GHz. VCO clk rate is %0.2gMHz. ERROR_CODE2',...
        VCO_CLK_rate_MHz);
end

% Determine the possible DEV_CLK rates here
dev_clk_div_from_Rx_rate = [16 8 4 2 1 0.5 0.25 0.125]
dev_clk_rate = dev_clk_div_from_Rx_rate*Rx_output_rate_MHz;
% REF_CLK rate can be b/w 10Mhz and 80MHz. Divider values from DEV_CLK to
% REF_CLK is 1,2 or 4. THerefore max_DEV_CLK can be 240MHz
dev_clk_index_min = find(dev_clk_rate > 30)
valid_dev_clk_rate = dev_clk_rate(dev_clk_index_min)
dev_clk_index_max = find( valid_dev_clk_rate < 80*4 )
valid_dev_clk_rate = dev_clk_rate(dev_clk_index_max)


%% populate the structure to pass to the PFIR generation functions 
mykonos_config.ORx.ADC_clk_rate_MHz = ORX_Rx_adc_rate_MHz;
mykonos_config.ORx.ADC_clk_divider = 1; % 1 until we have a use case for > 1
mykonos_config.ORx.dec5_enable = ORx_DEC5_enable;
mykonos_config.ORx.rhb1_enable = ORx_RHB1_enable;
mykonos_config.ORx.pfir_decimation = ORx_PFIR_decimation;

mykonos_config.Rx.ADC_clk_rate_MHz = ORX_Rx_adc_rate_MHz;
mykonos_config.Rx.ADC_clk_divider = 1;
mykonos_config.Rx.dec5_enable = Rx_DEC5_enable;
mykonos_config.Rx.rhb1_enable = Rx_RHB1_enable;
mykonos_config.Rx.pfir_decimation = Rx_PFIR_decimation;

mykonos_config.Snf.ADC_clk_rate_MHz = ORX_Rx_adc_rate_MHz;
mykonos_config.Snf.ADC_clk_divider = 1;
mykonos_config.Snf.dec5_enable = Snf_DEC5_enable;
mykonos_config.Snf.rhb1_enable = Snf_RHB1_enable;
mykonos_config.Snf.pfir_decimation = Snf_PFIR_decimation;

mykonos_config.Tx.DAC_clk_rate_MHz = dac_clk_rate_MHz;
mykonos_config.Tx.DAC_clk_divider = dac_clk_divider;
mykonos_config.Tx.thb2_enable = thb2_enable;
mykonos_config.Tx.PFIR_interp = Tx_PFIR_interpolation;

mykonos_config.CLK.HS_CLK_divider = HS_CLK_divider;
mykonos_config.CLK.HS_DIG_CLK_rate_MHz = hs_dig_clk_rate_MHz;
mykonos_config.CLK.VCO_CLK_divider = VCO_CLK_divider;
mykonos_config.CLK.VCO_CLK_rate_MHz = VCO_CLK_rate_MHz;
mykonos_config.CLK.DEV_CLK_rate_MHz = valid_dev_clk_rate;




%% call the Tx PFIR generation function
tx_profile = generate_TxPFIR(mykonos_config.Tx, tx_fhandle);

%% call the RxPFIR generation function
rx_profile = generate_RxORxPFIR('Rx', mykonos_config.Rx, rx_fhandle);


%% call the ORxPFIR generation function 
orx_profile = generate_RxORxPFIR('ORx', mykonos_config.ORx, orx_fhandle);

%% call the SnfRxPFIR generation function
if snrx_enabled
    snf_profile = generate_RxORxPFIR('Rx', mykonos_config.Snf, snf_fhandle);
else
    snf_profile = [];
    axes(snf_fhandle);
    cla;
    legend('hide');

    
end


%% generate the structure to be returned

mykonos_config.Tx = tx_profile;
mykonos_config.Rx = rx_profile;
mykonos_config.ORx = orx_profile;
mykonos_config.Snf = snf_profile;
mykonos_config_updated = mykonos_config;

return

end

