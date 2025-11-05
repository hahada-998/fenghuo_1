[ActiveSupport MAP]
Device = LCMXO2-2000HC;
Package = CABGA256;
Performance = 4;
LUTS_avail = 2112;
LUTS_used = 1369;
FF_avail = 2319;
FF_used = 756;
INPUT_LVCMOS25 = 107;
OUTPUT_LVCMOS25 = 17;
BIDI_LVCMOS25 = 19;
IO_avail = 207;
IO_used = 143;
EBR_avail = 8;
EBR_used = 0;
; Begin PLL Section
Instance_Name = pll_inst/PLLInst_0;
Type = EHXPLLJ;
CLKOP_Post_Divider_A_Input = DIVA;
CLKOS_Post_Divider_B_Input = DIVB;
CLKOS2_Post_Divider_C_Input = DIVC;
CLKOS3_Post_Divider_D_Input = DIVD;
Pre_Divider_A_Input = VCO_PHASE;
Pre_Divider_B_Input = VCO_PHASE;
Pre_Divider_C_Input = VCO_PHASE;
Pre_Divider_D_Input = VCO_PHASE;
VCO_Bypass_A_Input = VCO_PHASE;
VCO_Bypass_B_Input = VCO_PHASE;
VCO_Bypass_C_Input = VCO_PHASE;
VCO_Bypass_D_Input = VCO_PHASE;
FB_MODE = CLKOP;
CLKI_Divider = 1;
CLKFB_Divider = 2;
CLKOP_Divider = 10;
CLKOS_Divider = 20;
CLKOS2_Divider = 1;
CLKOS3_Divider = 1;
Fractional_N_Divider = 0;
CLKOP_Desired_Phase_Shift(degree) = 0;
CLKOP_Trim_Option_Rising/Falling = RISING;
CLKOP_Trim_Option_Delay = 0;
CLKOS_Desired_Phase_Shift(degree) = 0;
CLKOS_Trim_Option_Rising/Falling = RISING;
CLKOS_Trim_Option_Delay = 0;
CLKOS2_Desired_Phase_Shift(degree) = 0;
CLKOS3_Desired_Phase_Shift(degree) = 0;
; End PLL Section
;
; start of EFB statistics
I2C = 1;
SPI = 0;
TimerCounter = 0;
UFM = 0;
PLL = 0;
; end of EFB statistics
;
