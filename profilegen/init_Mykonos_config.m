function [ Mykonos_config ] = init_Mykonos_config( )
%INIT_MYKONOS_CONFIG   Use this function to create a structure with default
%values for the Mykonos configuration parameters
%   

Mykonos_config.Tx.input_rate_MHz = 245.76;
Mykonos_config.Tx.prim_sgl_RFBW_MHz = 40;
Mykonos_config.Tx.synthesis_RFBW_MHz = 200;
%Mykonos_config.Tx.Fp_MHz = 200/2;
Mykonos_config.Tx.DAC_clk_rate_MHz = 491.52;
Mykonos_config.Tx.DAC_clk_divider = 2.5;    % possible values are 2 or 2.5
Mykonos_config.Tx.thb1_enable = 0;
Mykonos_config.Tx.thb2_enable = 0;
Mykonos_config.Tx.PFIR_interp = 1;
Mykonos_config.Tx.pfir_no_of_coefs = 32;
Mykonos_config.Tx.pfir_gain = 1;        % gain can be [0 1 2 3]
Mykonos_config.Tx.pfir_coefs = [0 0 0 0 0 0 0 1 0 0 0 0 0 0];
Mykonos_config.Tx.real_pole_fc = 200;
Mykonos_config.Tx.BBF_fc = 200;
Mykonos_config.Tx.pfir_passband_weight = 1;
Mykonos_config.Tx.pfir_stopband_weight = 1;


Mykonos_config.Rx.output_rate_MHz = 122.88;
Mykonos_config.Rx.RFBW_MHz = 80;
%Mykonos_config.Rx.Fp_MHz = 80/2;   % SSB BW (passband) for digital filter design
Mykonos_config.Rx.ADC_clk_rate_MHz = 245.76*5;
Mykonos_config.Rx.ADC_clk_divider = 1;
Mykonos_config.Rx.ADC_codes = [0];
Mykonos_config.Rx.dec5_enable = 1;
Mykonos_config.Rx.rhb1_enable = 0;
Mykonos_config.Rx.tia_fc_MHz = 0;
Mykonos_config.Rx.pfir_decimation = 2;
Mykonos_config.Rx.pfir_no_of_coefs = 48;
Mykonos_config.Rx.pfir_gain = 1;    
Mykonos_config.Rx.pfir_coefs = [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 ...
    0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
Mykonos_config.Rx.pfir_passband_weight = 1;
Mykonos_config.Rx.pfir_stopband_weight = 1;


Mykonos_config.ORx.output_rate_MHz = 245.76;
Mykonos_config.ORx.RFBW_MHz = 200;
%Mykonos_config.ORx.Fp_MHz = 200/2;
Mykonos_config.ORx.ADC_clk_rate_MHz = 245.76*5;
Mykonos_config.ORx.ADC_clk_divider = 1;
Mykonos_config.ORx.ADC_codes = [0];
Mykonos_config.ORx.dec5_enable = 1;
Mykonos_config.ORx.rhb1_enable = 0;
Mykonos_config.ORx.tia_fc_MHz = 0;
Mykonos_config.ORx.pfir_decimation = 1;
Mykonos_config.ORx.pfir_no_of_coefs = 48;
Mykonos_config.ORx.pfir_gain = 1;
Mykonos_config.ORx.pfir_coefs = [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 ...
    0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
Mykonos_config.ORx.pfir_passband_weight = 1;
Mykonos_config.ORx.pfir_stopband_weight = 1;

Mykonos_config.Snf.profileEnabled = 0;
Mykonos_config.Snf.output_rate_MHz = 30.72;
Mykonos_config.Snf.RFBW_MHz = 10;
Mykonos_config.Snf.ADC_clk_rate_MHz = 30.72*20;
Mykonos_config.Snf.ADC_clk_divider = 1;
Mykonos_config.Snf.ADC_codes = [0];
Mykonos_config.Snf.dec5_enable = 1;
Mykonos_config.Snf.rhb1_enable = 1;
Mykonos_config.Snf.tia_fc_MHz = 0;
Mykonos_config.Snf.pfir_decimation = 2;
Mykonos_config.Snf.pfir_no_of_coefs = 48;
Mykonos_config.Snf.pfir_gain = 1;    
Mykonos_config.Snf.pfir_coefs = [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 ...
    0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
Mykonos_config.Snf.pfir_passband_weight = 1;
Mykonos_config.Snf.pfir_stopband_weight = 1;


Mykonos_config.CLK.HS_DIG_CLK_rate_MHz = 245.76*5;
Mykonos_config.CLK.HS_CLK_divider = 4;          % [4,5]
Mykonos_config.CLK.VCO_CLK_divider = 2;         % [1, 1.5, 2, 3]
Mykonos_config.CLK.VCO_CLK_rate_MHz = 9830.4; 
Mykonos_config.CLK.REF_CLK_rate_MHz = 61.44;    % REF_CLK rate needs to be b/w 10MHz and 80MHz
Mykonos_config.CLK.DEV_CLK_rate_MHz = [245.76 122.88 61.44]; %updated by the profile generation
Mykonos_config.CLK.selectedDEV_CLK_rate_MHz = 245.76; %Selected by user after generating profile, but before outputting profile file
Mykonos_config.CLK.REF_CLK_divider = 2;         %[ 1, 2, 4]

end

