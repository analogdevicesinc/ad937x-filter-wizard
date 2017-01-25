function [ mykonos_config_updated ] = generate_Mykonos_datapath_config( mykonos_config,tx_fhandle, rx_fhandle, orx_fhandle, snf_fhandle);
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
snrx_enabled = mykonos_config.Snf.profileEnabled;


%% Check input parameter bounds

% Tx Input rate should be greater than 30MHz and less than 320MHz
if ((Tx_input_rate_MHz < 30) || (Tx_input_rate_MHz > 320))
    % return error to GUI
    error('Tx input rate should be greater than 30MHz and less than 320MHz. Tx input rate was %0.2f.',...
        Tx_input_rate_MHz);      
end

if (Tx_input_rate_MHz ~= ORx_output_rate_MHz)
    error('Tx input rate and ORx output rate should match. ORx output rate was %0.2fMSPS.',...
        ORx_output_rate_MHz);
end

% Rx output rate should be greater than 20MHz and less than 200MHz
if ((Rx_output_rate_MHz < 20) || (Rx_output_rate_MHz > 200))
    % return error to GUI
    error('Rx output rate should be greater than 20MHz and less than 200MHz. Rx output rate was %0.2f.',...
        Rx_output_rate_MHz);
end

% ORx output rate should be greater than 30MHz and less than 320MHz
if ((ORx_output_rate_MHz < 30) || (ORx_output_rate_MHz > 320))
    error('ORx output rate should be greater than 20MHz and less than 320MHz. ORx output rate was %0.2f.',...
        ORx_output_rate_MHz);
end

% Tx_prim_sgl_RFBW_MHz should be greater than 30MHz and less than 320MHz
if ((Tx_prim_sgl_RFBW_MHz < 5) || (Tx_prim_sgl_RFBW_MHz > 100))
    error('Primary signal RF BW should be greater than 5MHz and less than 100MHz');
end


% Tx_synthesis_RFBW_MHz should be greater than 20MHz and less than 240MHz
if ((Tx_synthesis_RFBW_MHz < 20) || (Tx_synthesis_RFBW_MHz > 240))
    % return error to GUI
    error('Tx synthesis signal RF BW should be greater than 20MHz and less than 240MHz');
end

if (Tx_synthesis_RFBW_MHz > (Tx_input_rate_MHz * 0.82))   
    error('Tx Synthesis BW should be less than 82%% of Tx input rate. Tx syn BW was %0.2fMHz.', Tx_synthesis_RFBW_MHz);
end

if (Tx_prim_sgl_RFBW_MHz > (Tx_input_rate_MHz * 0.33))
    error('Tx primary signal BW should be less than %0.2f (33%% of Tx input rate). Tx primary sgl BW was %0.2fMHz.',... 
    (Tx_input_rate_MHz * 0.33), Tx_prim_sgl_RFBW_MHz); 
end

if (Tx_prim_sgl_RFBW_MHz > Tx_synthesis_RFBW_MHz)
    error('Tx primary signal BW should be less than or equal to the Tx RF BW');    
end

% Rx_RFBW should be greater than 5MHz and less than 100MHz (5MHz is
% arbitrary at this point. It can be lower)
if ((Rx_RFBW_MHz < 5) || (Rx_RFBW_MHz > 100))
    % return error to GUI
    error('Rx signal RF BW should be greater than 5MHz and less than 100MHz');
end

if ((Rx_RFBW_MHz < (Rx_output_rate_MHz * 0.40)) || ( Rx_RFBW_MHz > (Rx_output_rate_MHz * 0.82)))
    % This check is required based on filtering
    % ability and on the low side it is limited by RxQEC algorithm in ARM
    error('Rx RF BW should be greater than %0.2fMHz (40%%) and less than %0.2fMHz (82%%) of the Rx output rate. Rx RF BW was %0.2fMHz.',...
        (Rx_output_rate_MHz * 0.4),...
        (Rx_output_rate_MHz * 0.82),...
        Rx_RFBW_MHz);        
end

% ORx_RFBW should be greater than 5MHz and less than 240MHz 
if ((ORx_RFBW_MHz < 5) ||(ORx_RFBW_MHz > 240))
    % return error to GUI
    error('ORx signal RF BW should be greater than 5MHz and less than 240MHz');
end

if ((ORx_RFBW_MHz < (ORx_output_rate_MHz * 0.40)) || (ORx_RFBW_MHz > (ORx_output_rate_MHz * 0.82)))
    % This check is required based on filtering
    % ability and on the low side it is limited by RxQEC algorithm in ARM
    error('ORx RF BW should be greater than %0.2fMHz (40%%) and less than %0.2fMHz (82%%) of the ORx output rate. ORx RF BW was %0.2fMHz.',...
        (ORx_output_rate_MHz * 0.4),...
        (ORx_output_rate_MHz * 0.82),...
        ORx_RFBW_MHz);
end

if (snrx_enabled > 0)
    
    % Snf Rx output rate should be greater than 20MHz and less than 200MHz
    if ((Snf_output_rate_MHz < 20) || (Snf_output_rate_MHz > 200))
        % return error to GUI
        error('Sniffer Rx output rate should be greater than 20MHz and less than 200MHz. Rx output rate was %0.2f.',...
            Snf_output_rate_MHz);
    end

    % Snf_RFBW should be greater than 5MHz and less than 100MHz (5MHz is
    % arbitrary at this point. It can be lower)
    if ((Snf_RFBW_MHz < 5) || (Snf_RFBW_MHz > 20))
        % return error to GUI
        error('Sniffer Rx signal RF BW should be greater than 5MHz and less than 20MHz');
    end

    if ((Snf_RFBW_MHz < (Snf_output_rate_MHz * 0.40)) || ( Snf_RFBW_MHz > (Snf_output_rate_MHz * 0.82)))
        % This check is required based on filtering
        % ability and on the low side it is limited by RxQEC algorithm in ARM
        error('Sniffer RF BW should be greater than %0.2fMHz (40%%) and less than %0.2fMHz (82%%) of the Rx output rate. Sniffer RF BW was %0.2fMHz.',...
            (Snf_output_rate_MHz * 0.4),...
            (Snf_output_rate_MHz * 0.82),...
            Snf_RFBW_MHz);        
    end 
end




%% Determine ORx ADC rate, and datapath blocks to be used in the ORx datapath

adc_rate_mult_5 = [40 20 10 5];
adc_rate_5 = ORx_output_rate_MHz * adc_rate_mult_5;

adc_rate_mult_4 = [32 16 8 4];
adc_rate_4 = ORx_output_rate_MHz * adc_rate_mult_4;

valid_orx_adc_rate_5 = find(adc_rate_5 <= 1600);  % In DEC5 mode, max ORx_ADC_rate is 1600MHz
valid_orx_adc_rate_4 = find(adc_rate_4 <= 1280);  % In DEC4 mode, max ORx_ADC_rate is 1280MHz

max_lim_orx_adc_rate_5 = adc_rate_5(valid_orx_adc_rate_5);  % Min ORx_ADC_rate is 600MHz
max_lim_orx_adc_rate_4 = adc_rate_4(valid_orx_adc_rate_4);

valid_orx_adc_rate_5 = find(max_lim_orx_adc_rate_5 >= 600);
valid_orx_adc_rate_4 = find(max_lim_orx_adc_rate_4 >= 600);

hs_dig_clk_rate_5 = max_lim_orx_adc_rate_5(valid_orx_adc_rate_5(1));
hs_dig_clk_rate_4 = max_lim_orx_adc_rate_4(valid_orx_adc_rate_4(1));

if mykonos_config.ORx.Advanced == 1
    if mykonos_config.ORx.dec5_enable == 1
        ORx_DEC5_enable = 1;
        Rx_DEC5_enable = 1;
        Snf_DEC5_enable = 1;
        if isempty(hs_dig_clk_rate_5) == 1
            error('No valid VCO rate could be found for DEC5 mode');
        end
        hs_dig_clk_rate_MHz = hs_dig_clk_rate_5;
    else
        ORx_DEC5_enable = 0;
        Rx_DEC5_enable = 0;
        Snf_DEC5_enable = 0;
        if isempty(hs_dig_clk_rate_4) == 1
            error('No valid VCO rate could be found for DEC4 mode');
        end
        hs_dig_clk_rate_MHz = hs_dig_clk_rate_4;
    end
else
    if hs_dig_clk_rate_5 > hs_dig_clk_rate_4
        hs_dig_clk_rate_MHz = hs_dig_clk_rate_5;
        ORx_DEC5_enable = 1;    % Rx and ORx modes are both either DEC4 or DEC5
        Rx_DEC5_enable = 1;
        Snf_DEC5_enable = 1;
    else
        hs_dig_clk_rate_MHz = hs_dig_clk_rate_4;
        ORx_DEC5_enable = 0;
        Rx_DEC5_enable = 0;
        Snf_DEC5_enable = 0;
    end
end

% adc_rate is common for Rx and ORx path in almost all cases and is the
% same as the hs_dig_clk_rate. Rx_ADC has a rx_adc_clk_rate_divider that
% can be either 1 or 2, but this may require some more thought since we
% will need to confirm that FW will work with varying ADC rates on Rx/ORx
% paths. THis non-equal rate is only possible when we are in DEC4 mode
ORX_Rx_adc_rate_MHz = hs_dig_clk_rate_MHz;



%% Determine the filters to be enabled in the ORx path
total_ORx_dec = ORX_Rx_adc_rate_MHz/ORx_output_rate_MHz;

if total_ORx_dec > 10
    ORx_RHB1_enable = 1;    % PFIR decimates by 2 for path decimation > 5
                           % Anything > 10 we use the RHB1 filter
else
    ORx_RHB1_enable = 0;     
end

if total_ORx_dec > 20
    ORx_PFIR_decimation = 4;    
elseif total_ORx_dec > 5
    ORx_PFIR_decimation = 2;    
else
    ORx_PFIR_decimation = 1;
end

% check to confirm that the adc_rate is < 1600 for DEC5 mode and < 1280 for
% DEC4 mode
if (ORx_DEC5_enable == 1)
    if ((ORX_Rx_adc_rate_MHz > 1600) || (ORX_Rx_adc_rate_MHz < 800))
        error('ADC clk rate is out of valid range (800 <= ADC_CLK <= 1600MHz, DEC5 mode). Calculated ADC_CLK rate is %0.2f. ERROR_CODE1', ...
            ORX_Rx_adc_rate_MHz);
    end
else
    if ((ORX_Rx_adc_rate_MHz > 1280) || (ORX_Rx_adc_rate_MHz < 800))
        error('ADC clk rate is out of valid range (800 <= ADC_CLK <= 1280MHz, DEC4 mode). Calculated ADC_CLK rate is %0.2f. ERROR_CODE1', ...
            ORX_Rx_adc_rate_MHz);
    end
end    
    

%% determine the filters that need to be active/enabled in the Rx path
total_Rx_dec = ORX_Rx_adc_rate_MHz/Rx_output_rate_MHz;

if total_Rx_dec>40
    error('Decimation on Rx cannot exceed 40. Calculated decimation %d.', total_Rx_dec);
end

if total_Rx_dec > 10
    Rx_RHB1_enable = 1;     % PFIR decimates by 2 for path decimation > 5
                           % Anything > 10 we use the RHB1 filter
else
    Rx_RHB1_enable = 0;     
end


if total_Rx_dec > 20
    Rx_PFIR_decimation = 4;
elseif total_Rx_dec > 5
    Rx_PFIR_decimation = 2;
else
    Rx_PFIR_decimation = 1;
end

%% determine the filters that need to be active/enabled in the Sniffer Rx path
total_Snf_dec = ORX_Rx_adc_rate_MHz/Snf_output_rate_MHz;

if (snrx_enabled) && (total_Snf_dec>40)
    error('Decimation on Rx cannot exceed 40. Calculated decimation %d.', total_Rx_dec);
end

if total_Snf_dec > 10
    Snf_RHB1_enable = 1;     % PFIR decimates by 2 for path decimation > 5
                           % Anything > 10 we use the RHB1 filter
else
    Snf_RHB1_enable = 0;     
end


if total_Snf_dec > 20
    Snf_PFIR_decimation = 4;
elseif total_Snf_dec > 5
    Snf_PFIR_decimation = 2;
else
    Snf_PFIR_decimation = 1;
end

%% determine DAC CLK rate and Tx datapath active filters

% since Tx datapath has only interpolation by power of 2, a decimate by
% DEC5 neccesitates the use of the dac_clk divider ratio of 2.5. If DEC4
% mode is used, then dac_clk_divider is 2. Max DAC_CLK rate should be less
% than 640MHz
if ORx_DEC5_enable == 1
    dac_clk_divider = 2.5;
else
    dac_clk_divider = 2;
end

dac_clk_rate_MHz = hs_dig_clk_rate_MHz/dac_clk_divider;

% check for max dac clk rate
if dac_clk_rate_MHz > 640
    error('Max DAC clk rate should be less than 640MHz. Calculated DAC_CLK rate is %0.2f.', ...
        dac_clk_rate_MHz);
end
total_interpolation = dac_clk_rate_MHz/Tx_input_rate_MHz;

if total_interpolation == 16
    Tx_PFIR_interpolation = 4;
    thb2_enable = 1;
    thb1_enable = 1;    
elseif total_interpolation == 8
    Tx_PFIR_interpolation = 2;
    thb2_enable = 1;
    thb1_enable = 1;
elseif total_interpolation == 4
    Tx_PFIR_interpolation = 1;
    thb2_enable = 1;
    thb1_enable = 1;
elseif total_interpolation == 2
    Tx_PFIR_interpolation = 1;
    thb2_enable = 0;
    thb1_enable = 1;
else
    error('Total Interpolation should be 2, 4, 8 or 16. Calculated Tx interpolation was %d.', ...
        total_interpolation);
end

if (Tx_PFIR_interpolation == 4)
    error('Tx 4x PFIR interpolation is not currently supported.');
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
VCO_max_rate = 12500;
if HS_CLK_rate_MHz < VCO_max_rate/3
    VCO_CLK_divider = 3;
elseif HS_CLK_rate_MHz < VCO_max_rate/2
    VCO_CLK_divider = 2;
elseif HS_CLK_rate_MHz < VCO_max_rate/1.5
    VCO_CLK_divider = 1.5;
else
    VCO_CLK_divider = 1;
end

VCO_CLK_rate_MHz = HS_CLK_rate_MHz * VCO_CLK_divider;

% check to confirm that VCO clk rate is within bounds
if VCO_CLK_rate_MHz < 6250 || VCO_CLK_rate_MHz > 12500
    error('VCO clock rate should be greater than 6.25GHz and less than 12.5GHz. VCO clk rate is %0.2gMHz. ERROR_CODE2',...
        VCO_CLK_rate_MHz);
end

% Determine the possible DEV_CLK rates here
ref_clk_div_from_hs_dig_clk = 5:1:156;
ref_clk_rate = hs_dig_clk_rate_MHz./ref_clk_div_from_hs_dig_clk;

% REF_CLK rate can be b/w 10Mhz and 80MHz. Divider values from DEV_CLK to
% REF_CLK is 1,2 or 4. THerefore max_DEV_CLK can be 240MHz
ref_clk_index_min = find(ref_clk_rate > 20);
valid_ref_clk_rate = ref_clk_rate(ref_clk_index_min);
ref_clk_index_max = find( valid_ref_clk_rate < 80 );
valid_ref_clk_rate = valid_ref_clk_rate(ref_clk_index_max);


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
mykonos_config.Tx.thb1_enable = thb1_enable;
mykonos_config.Tx.PFIR_interp = Tx_PFIR_interpolation;

mykonos_config.CLK.HS_CLK_divider = HS_CLK_divider;
mykonos_config.CLK.HS_DIG_CLK_rate_MHz = hs_dig_clk_rate_MHz;
mykonos_config.CLK.VCO_CLK_divider = VCO_CLK_divider;
mykonos_config.CLK.VCO_CLK_rate_MHz = VCO_CLK_rate_MHz;
mykonos_config.CLK.DEV_CLK_rate_MHz = valid_ref_clk_rate;
mykonos_config.CLK.REF_CLK_rate_MHz = valid_ref_clk_rate;
mykonos_config.CLK.REF_CLK_divider = 1;




%% call the Tx PFIR generation function
tx_profile = generate_TxPFIR(mykonos_config.Tx, tx_fhandle);

%% call the RxPFIR generation function
rx_profile = generate_RxORxPFIR('Rx', mykonos_config.Rx, rx_fhandle);


%% call the ORxPFIR generation function 
orx_profile = generate_RxORxPFIR('ORx', mykonos_config.ORx, orx_fhandle);

%% call the LPBK_ADC_code generate function
orx_with_lpbk_profile = generate_LPBK_ADC_codes(Tx_prim_sgl_RFBW_MHz, orx_profile);

%% call the SnfRxPFIR generation function
if snrx_enabled
    snf_profile = generate_RxORxPFIR('Rx', mykonos_config.Snf, snf_fhandle);
else
    snf_profile = [];
    snf_profile.profileEnabled = 0;
    axes(snf_fhandle);
    cla;
    legend('hide');

    
end


%% generate the structure to be returned

mykonos_config.Tx = tx_profile;
mykonos_config.Rx = rx_profile;
mykonos_config.ORx = orx_with_lpbk_profile;
mykonos_config.Snf = snf_profile;
mykonos_config_updated = mykonos_config;



return

end

