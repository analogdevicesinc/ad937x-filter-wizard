function [ valid_rates_MHz, valid_M1, valid_N2, valid_out_div] = AD9528_rates( VCOX , DEV_clk_rate_MHz)
% Function to find all possible rate using AD9528 as external oscillator

MIN_VCO_FREQ_MHZ    = 3450;
MAX_VCO_FREQ_MHZ    = 4025;
MIN_VCOX_MHZ        = 50;
MAX_VCOX_MHZ        = 250;
MHz                 = 1e6;

if ((VCOX < MIN_VCOX_MHZ) || (VCOX > MAX_VCOX_MHZ))
    error('VCOX frequency must be between %dMHz and %dMHz',MIN_VCOX_MHZ,MAX_VCOX_MHZ);
end

VCOX_freq_MHz = VCOX;
output_div = 3:50;
M1 = [3 4 5];
N2 = floor(4025/VCOX_freq_MHz./M1);
M1 = [M1 M1 M1];
N2 = [N2-2 N2-1 N2];

VCO_freq = VCOX_freq_MHz.*M1.*N2;
invalid_case = find(VCO_freq < MIN_VCO_FREQ_MHZ);
VCO_freq(invalid_case) = 0;

Output_div_form = VCO_freq./M1;

possible_rates_MHz = zeros(length(output_div),length(M1));
for i = 1:1:length(M1)
    possible_rates_MHz(:,i) = (Output_div_form(i)./output_div)';
end

possible_rates_Hz = round(possible_rates_MHz*MHz);
DEV_clk_rate_Hz = round(DEV_clk_rate_MHz*MHz);
valid_rates_MHz = [];
valid_M1 = [];
valid_N2 = [];
valid_out_div = [];
for j = 1:1:length(DEV_clk_rate_MHz)
    [row,col] = find(possible_rates_Hz == DEV_clk_rate_Hz(j));
    if isempty(row) == 0
        valid_rates_MHz = [valid_rates_MHz DEV_clk_rate_MHz(j)];
        valid_M1 = [valid_M1 M1(col(1))];
        valid_N2 = [valid_N2 N2(col(1))];
        valid_out_div = [valid_out_div output_div(row(1))];
    end
end

if isempty(valid_rates_MHz) == 1
    error('No possible device clocks can be generated with the current VCOX rate');
end

end