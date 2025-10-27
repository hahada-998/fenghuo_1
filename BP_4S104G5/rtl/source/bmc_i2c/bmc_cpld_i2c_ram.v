
module bmc_cpld_i2c_ram #( 
parameter DLY_LEN       = 3   //24.18MHz,330ns
)
(
input  i_rst_n      , 
input  i_clk        ,
input  i_1ms_clk    ,	
input  i_rst_i2c_n  ,
input  i_scl        , 
inout  io_sda       ,



/*CPLD Common Register*/
input  wire  [7:0] i_product_id                    ,//addr 0x0000
input  wire  [7:0] i_vender_id                     ,//addr 0x0001
input  wire  [7:0] i_board_id                      ,//addr 0x0002
input  wire  [7:0] i_pcb_version                   ,//addr 0x0003
input  wire  [7:0] i_bom_id                        ,//addr 0x0004
input  wire  [7:0] i_cpld_version                  ,//addr 0x0005
output wire  [7:0] o_test_reg                      ,//addr 0x0006
input  wire  [7:0] i_year                          ,//addr 0x0007
input  wire  [7:0] i_month                         ,//addr 0x0008
input  wire  [7:0] i_day                           ,//addr 0x0009
input  wire        i_ncpin                         ,//addr 0x000a bit0
input  wire  [7:0] i_cpld_compa_version            ,//addr 0x000b
input  wire  [7:0] i_cpld_debug_version            ,//addr 0x000c


input  wire  [7:0] i_nic_board_id		           , //addr 0x0010
input  wire  [7:0] i_nic_pcb_version	           , //addr 0x0011

//I2C
input  wire        i_I2C1_ALERT_N_R	               , //addr 0x0012  bit7
input  wire        i_I2C2_ALERT_N_R	               , //addr 0x0012  bit6
input  wire        i_I2C9_9548_CH4_ALERT           , //addr 0x0012  bit5

//pol
input  wire        i_PAL_RAA_CFP_R                 , //addr 0x0013  bit7
input  wire        i_p0v8_sw0_pwrgd_db             , //addr 0x0013  bit6
input  wire        i_p0v8_sw1_pwrgd_db             , //addr 0x0013  bit5
input  wire        i_p0v8_sw2_pwrgd_db             , //addr 0x0013  bit4
input  wire        i_p0v8_sw3_pwrgd_db             , //addr 0x0013  bit3
input  wire        i_PG_P5V0_R                     , //addr 0x0013  bit2
input  wire        i_PG_P1V8_R	                   , //addr 0x0013  bit1  //2024-6-29 add
input  wire        i_PG_P1V8_PLL_R                 , //addr 0x0013  bit0  //2024-6-29 add


input  wire        i_P5V_VGA_OC                    , //addr 0x0014  bit7
input  wire        i_P5V_RIGHTEAR_USB_OC           , //addr 0x0014  bit6
input  wire        i_P5V_STBY_USB_OC               , //addr 0x0014  bit5

input  wire        i_SMB_PSU0_ALERT_R              , //addr 0x0015  bit7
input  wire        i_SMB_PSU1_ALERT_R              , //addr 0x0015  bit6
input  wire        i_SMB_PSU2_ALERT_R              , //addr 0x0015  bit5
input  wire        i_SMB_PSU3_ALERT_R              , //addr 0x0015  bit4
input  wire        i_SMB_PSU4_ALERT_R              , //addr 0x0015  bit3
input  wire        i_SMB_PSU5_ALERT_R              , //addr 0x0015  bit2

//NIC
input  wire        i_NIC_3P3V_A_PG_R               , //addr 0x0016  bit7
input  wire        i_NIC_3P3V_B_PG_R               , //addr 0x0016  bit6

input  wire        i_RETIMER1_INT_N_R              , //addr 0x0017  bit7
input  wire        i_RETIMER2_INT_N_R              , //addr 0x0017  bit6
input  wire        i_RETIMER3_INT_N_R              , //addr 0x0017  bit5
input  wire        i_RETIMER4_INT_N_R              , //addr 0x0017  bit4
input  wire        i_RETIMER5_INT_N_R              , //addr 0x0017  bit3
input  wire        i_RETIMER6_INT_N_R              , //addr 0x0017  bit2
input  wire        i_RETIMER7_INT_N_R              , //addr 0x0017  bit1
input  wire        i_RETIMER8_INT_N_R              , //addr 0x0017  bit0

//BP
input  wire        i_BP1_PWR_PG_R                  , //addr 0x0018  bit7
input  wire        i_BP2_PWR_PG_R                  , //addr 0x0018  bit6
input  wire        i_BPTB_RE_DONE_R                , //addr 0x0018  bit5

//UBB
input  wire        i_GPU_BASE_PWR_GD_R	           , //addr 0x0019  bit7
input  wire        i_THERM_OVERT_N_R	           , //addr 0x0019  bit6
input  wire        i_FPGA_EROT_FATALERR_N_R        , //addr 0x0019  bit5
input  wire        i_FPGA_OVERT_N_R                , //addr 0x0019  bit4
input  wire        i_GPU_BASE_HMC_READY_R          , //addr 0x0019  bit3
input  wire        i_HMC_PRSNT_N_R                 , //addr 0x0019  bit2
input  wire        i_BASE_PRSNT_N_R                , //addr 0x0019  bit1 //2024-5-29 ADD

//REDRIVER
input  wire        i_PAL_SAS_ALL_DONE_N            , //addr 0x001a  bit7
input  wire        i_DS160_TX_ALL_DONE_N           , //addr 0x001a  bit6
input  wire        i_DS160_RX_ALL_DONE_N           , //addr 0x001a  bit5

//BP
output wire        o_bptb_eep_wp_r                 , //addr 0x001b  bit7 //default 0
output wire        o_bp_eeprom_wp_r                , //addr 0x001b  bit6 //default 0

//NIC
output wire        o_slot1_thorttle_r              , //addr 0x001c  bit7 //default 0
output wire        o_slot2_thorttle_r              , //addr 0x001c  bit6 //default 0
output wire        o_slot3_thorttln_r              , //addr 0x001c  bit5 //default 0
output wire        o_slot4_thorttle_r              , //addr 0x001c  bit4 //default 0
output wire        o_slot5_thorttle_r              , //addr 0x001c  bit3 //default 0
output wire        o_slot6_thorttle_r              , //addr 0x001c  bit2 //default 0
output wire        o_slot7_thorttle_r              , //addr 0x001c  bit1 //default 0
output wire        o_slot8_thorttle_r              , //addr 0x001c  bit0 //default 0

//USB
output wire        o_pal_usbmux_sel                , //addr 0x001d  bit7 //default 0

//UBB
output wire        o_pwr_brake_n_r                 , //addr 0x001e  bit7 //default 1
output wire        o_wp_hw_ctrl_n                  , //addr 0x001e  bit6 //default 1

input  wire        i_sw0_spi_cs_sel_err_flag       , //addr 0x001f  bit7 
input  wire        i_sw1_spi_cs_sel_err_flag       , //addr 0x001f  bit6 
input  wire        i_sw2_spi_cs_sel_err_flag       , //addr 0x001f  bit5 
input  wire        i_sw3_spi_cs_sel_err_flag       , //addr 0x001f  bit4 

//165_data
input  wire        i_TEMP_ALERT_0_R                , //addr 0x0020  bit7 
input  wire        i_TEMP_ALERT_1_R                , //addr 0x0020  bit6 
input  wire        i_TEMP_ALERT_2_R                , //addr 0x0020  bit5 
input  wire        i_TEMP_ALERT_3_R                , //addr 0x0020  bit4 

input  wire        i_SW0_CLKREQ_N_R                , //addr 0x0021  bit7 
input  wire        i_SW1_CLKREQ_N_R                , //addr 0x0021  bit6 
input  wire        i_SW2_CLKREQ_N_R                , //addr 0x0021  bit5 
input  wire        i_SW3_CLKREQ_N_R                , //addr 0x0021  bit4 
input  wire        i_P0V8_SW0_ALERT_N              , //addr 0x0021  bit3 
input  wire        i_P0V8_SW1_ALERT_N              , //addr 0x0021  bit2 
input  wire        i_P0V8_SW2_ALERT_N              , //addr 0x0021  bit1 
input  wire        i_P0V8_SW3_ALERT_N              , //addr 0x0021  bit0 

input  wire        i_P0V8_SW0_VRHOT_N              , //addr 0x0022  bit7 
input  wire        i_P0V8_SW1_VRHOT_N              , //addr 0x0022  bit6 
input  wire        i_P0V8_SW2_VRHOT_N              , //addr 0x0022  bit5 
input  wire        i_P0V8_SW3_VRHOT_N              , //addr 0x0022  bit4 
input  wire        i_P0V8_SW0_FAULT_N              , //addr 0x0022  bit3 
input  wire        i_P0V8_SW1_FAULT_N              , //addr 0x0022  bit2 
input  wire        i_P0V8_SW2_FAULT_N              , //addr 0x0022  bit1 
input  wire        i_P0V8_SW3_FAULT_N              , //addr 0x0022  bit0 

input  wire        i_SLOT1_WAKE_N                  , //addr 0x0023  bit7 
input  wire        i_SLOT2_WAKE_N                  , //addr 0x0023  bit6 
input  wire        i_SLOT3_WAKE_N                  , //addr 0x0023  bit5 
input  wire        i_SLOT4_WAKE_N                  , //addr 0x0023  bit4 
input  wire        i_SLOT5_WAKE_N                  , //addr 0x0023  bit3 
input  wire        i_SLOT6_WAKE_N                  , //addr 0x0023  bit2 
input  wire        i_SLOT7_WAKE_N                  , //addr 0x0023  bit1 
input  wire        i_SLOT8_WAKE_N                  , //addr 0x0023  bit0 

input  wire        i_psu0_pwrok_n                  , //addr 0x0024 bit7 
input  wire        i_psu1_pwrok_n                  , //addr 0x0024 bit6 
input  wire        i_psu2_pwrok_n                  , //addr 0x0024 bit5 
input  wire        i_psu3_pwrok_n                  , //addr 0x0024 bit4 
input  wire        i_psu4_pwrok_n                  , //addr 0x0024 bit3 
input  wire        i_psu5_pwrok_n                  , //addr 0x0024 bit2 

input  wire        i_PSU0_PRSNT_R                  , //addr 0x0025 bit7 
input  wire        i_PSU1_PRSNT_R                  , //addr 0x0025 bit6 
input  wire        i_PSU2_PRSNT_R                  , //addr 0x0025 bit5 
input  wire        i_PSU3_PRSNT_R                  , //addr 0x0025 bit4 
input  wire        i_PSU4_PRSNT_R                  , //addr 0x0025 bit3 
input  wire        i_PSU5_PRSNT_R                  , //addr 0x0025 bit2 

output wire        o_psu0_ctl                      , //addr 0x0026 bit7  //default 1
output wire        o_psu1_ctl                      , //addr 0x0026 bit6  //default 1
output wire        o_psu2_ctl                      , //addr 0x0026 bit5  //default 1
output wire        o_psu3_ctl                      , //addr 0x0026 bit4  //default 1
output wire        o_psu4_ctl                      , //addr 0x0026 bit3  //default 1
output wire        o_psu5_ctl                      , //addr 0x0026 bit2  //default 1

input  wire        i_HSC0_PG                       , //addr 0x0027  bit7  //2024-6-29 add
input  wire        i_P12V_PG                       , //addr 0x0027  bit6  //2024-6-29 add
input  wire        i_RETIMER1_1P8_PG               , //addr 0x0027  bit5  //2024-6-29 add
input  wire        i_RETIMER2_1P8_PG               , //addr 0x0027  bit4  //2024-6-29 add
input  wire        i_CT_P1V25_SW0_PG               , //addr 0x0027  bit3  //2024-6-29 add
input  wire        i_CT_P1V25_SW1_PG               , //addr 0x0027  bit2  //2024-6-29 add
input  wire        i_CT_P1V25_SW2_PG               , //addr 0x0027  bit1  //2024-6-29 add
input  wire        i_CT_P1V25_SW3_PG               , //addr 0x0027  bit0  //2024-6-29 add

input  wire        i_RETIMER1_0P9_PG               , //addr 0x0028  bit7  //2024-6-29 add
input  wire        i_RETIMER2_0P9_PG               , //addr 0x0028  bit6  //2024-6-29 add
input  wire        i_RETIMER3_0P9_PG               , //addr 0x0028  bit5  //2024-6-29 add
input  wire        i_RETIMER4_0P9_PG               , //addr 0x0028  bit4  //2024-6-29 add
input  wire        i_RETIMER5_0P9_PG               , //addr 0x0028  bit3  //2024-6-29 add
input  wire        i_RETIMER6_0P9_PG               , //addr 0x0028  bit2  //2024-6-29 add
input  wire        i_RETIMER7_0P9_PG               , //addr 0x0028  bit1  //2024-6-29 add
input  wire        i_RETIMER8_0P9_PG               , //addr 0x0028  bit0  //2024-6-29 add

input  wire        i_3V3IO_RSVD0_FFU_R             , //addr 0x0029  bit7  //2024-8-16 add
input  wire        i_3V3IO_RSVD1_FFU_R             , //addr 0x0029  bit6  //2024-8-16 add
input  wire        i_3V3IO_RSVD2_FFU_R             , //addr 0x0029  bit5  //2024-8-16 add
input  wire        i_3V3IO_RSVD3_FFU_R             , //addr 0x0029  bit4  //2024-8-16 add

output wire  [3:0] o_bmc_ctrl_sw_mode              , //addr 0x0033 bit3-0    //default 0000
output wire  [3:0] o_bmc_ctrl_sw_mode_mask         , //addr 0x0034 bit3-0    //default 0000

output wire  [7:0] o_bmc_ctrl_nic_rst              , //addr 0x0035 bit7-0  //2024-10-10 add //default ff

//fan_prsnt--0x0101
input  wire        i_fan0_present_n                , //addr 0x0101 bit7 
input  wire        i_fan1_present_n                , //addr 0x0101 bit6  
input  wire        i_fan2_present_n                , //addr 0x0101 bit5  
input  wire        i_fan3_present_n                , //addr 0x0101 bit4  
input  wire        i_fan4_present_n                , //addr 0x0101 bit3 
input  wire        i_fan5_present_n                , //addr 0x0101 bit2  
input  wire        i_fan6_present_n                , //addr 0x0101 bit1  
input  wire        i_fan7_present_n                , //addr 0x0101 bit0  

input  wire        i_fan8_present_n                , //addr 0x0102 bit7
input  wire        i_fan9_present_n                , //addr 0x0102 bit6
input  wire        i_fan10_present_n               , //addr 0x0102 bit5 
input  wire        i_fan11_present_n               , //addr 0x0102 bit4 
input  wire        i_fan12_present_n               , //addr 0x0102 bit3 
input  wire        i_fan13_present_n               , //addr 0x0102 bit2 
input  wire        i_fan14_present_n               , //addr 0x0102 bit1
input  wire        i_fan15_present_n               , //addr 0x0102 bit0

//FAN tach --0x0103~0x0122                         
input  wire  [7:0] i_fan1_tach0_reg                , //addr 0x0103
input  wire  [7:0] i_fan1_tach1_reg                , //addr 0x0104
input  wire  [7:0] i_fan2_tach0_reg                , //addr 0x0105
input  wire  [7:0] i_fan2_tach1_reg                , //addr 0x0106
input  wire  [7:0] i_fan3_tach0_reg                , //addr 0x0107
input  wire  [7:0] i_fan3_tach1_reg                , //addr 0x0108
input  wire  [7:0] i_fan4_tach0_reg                , //addr 0x0109
input  wire  [7:0] i_fan4_tach1_reg                , //addr 0x010a
input  wire  [7:0] i_fan5_tach0_reg                , //addr 0x010b
input  wire  [7:0] i_fan5_tach1_reg                , //addr 0x010c
input  wire  [7:0] i_fan6_tach0_reg                , //addr 0x010d
input  wire  [7:0] i_fan6_tach1_reg                , //addr 0x010e
input  wire  [7:0] i_fan7_tach0_reg                , //addr 0x010f
input  wire  [7:0] i_fan7_tach1_reg                , //addr 0x0110
input  wire  [7:0] i_fan8_tach0_reg                , //addr 0x0111
input  wire  [7:0] i_fan8_tach1_reg                , //addr 0x0112
input  wire  [7:0] i_fan9_tach0_reg                , //addr 0x0113
input  wire  [7:0] i_fan9_tach1_reg                , //addr 0x0114
input  wire  [7:0] i_fan10_tach0_reg               , //addr 0x0115
input  wire  [7:0] i_fan10_tach1_reg               , //addr 0x0116
input  wire  [7:0] i_fan11_tach0_reg               , //addr 0x0117
input  wire  [7:0] i_fan11_tach1_reg               , //addr 0x0118
input  wire  [7:0] i_fan12_tach0_reg               , //addr 0x0119
input  wire  [7:0] i_fan12_tach1_reg               , //addr 0x011a
input  wire  [7:0] i_fan13_tach0_reg               , //addr 0x011b
input  wire  [7:0] i_fan13_tach1_reg               , //addr 0x011c
input  wire  [7:0] i_fan14_tach0_reg               , //addr 0x011d
input  wire  [7:0] i_fan14_tach1_reg               , //addr 0x011e
input  wire  [7:0] i_fan15_tach0_reg               , //addr 0x011f
input  wire  [7:0] i_fan15_tach1_reg               , //addr 0x0120
input  wire  [7:0] i_fan16_tach0_reg               , //addr 0x0121
input  wire  [7:0] i_fan16_tach1_reg               , //addr 0x0122

//FAN PWM--0x0123~0x0132
output wire  [7:0] o_pwm_bmc_fan1                  , //addr 0x0123          
output wire  [7:0] o_pwm_bmc_fan2                  , //addr 0x0124
output wire  [7:0] o_pwm_bmc_fan3                  , //addr 0x0125
output wire  [7:0] o_pwm_bmc_fan4                  , //addr 0x0126
output wire  [7:0] o_pwm_bmc_fan5                  , //addr 0x0127
output wire  [7:0] o_pwm_bmc_fan6                  , //addr 0x0128
output wire  [7:0] o_pwm_bmc_fan7                  , //addr 0x0129
output wire  [7:0] o_pwm_bmc_fan8                  , //addr 0x012a
output wire  [7:0] o_pwm_bmc_fan9                  , //addr 0x012b
output wire  [7:0] o_pwm_bmc_fan10                 , //addr 0x012c
output wire  [7:0] o_pwm_bmc_fan11                 , //addr 0x012d
output wire  [7:0] o_pwm_bmc_fan12                 , //addr 0x012e
output wire  [7:0] o_pwm_bmc_fan13                 , //addr 0x012f
output wire  [7:0] o_pwm_bmc_fan14                 , //addr 0x0130
output wire  [7:0] o_pwm_bmc_fan15                 , //addr 0x0131
output wire  [7:0] o_pwm_bmc_fan16                 , //addr 0x0132

//FAN real tach --0x0133~0x013a                    
input  wire  [7:0] i_fan1_tach0_real_h             , //addr 0x0133
input  wire  [2:0] i_fan1_tach0_real_l             , //addr 0x0134
input  wire  [7:0] i_fan1_tach1_real_h             , //addr 0x0135
input  wire  [2:0] i_fan1_tach1_real_l             , //addr 0x0136
input  wire  [7:0] i_fan2_tach0_real_h             , //addr 0x0137
input  wire  [2:0] i_fan2_tach0_real_l             , //addr 0x0138
input  wire  [7:0] i_fan2_tach1_real_h             , //addr 0x0139
input  wire  [2:0] i_fan2_tach1_real_l             , //addr 0x013a

//FAN real tach --0x013b~0x0142                    
input  wire  [7:0] i_fan3_tach0_real_h             , //addr 0x013b
input  wire  [2:0] i_fan3_tach0_real_l             , //addr 0x013c
input  wire  [7:0] i_fan3_tach1_real_h             , //addr 0x013d
input  wire  [2:0] i_fan3_tach1_real_l             , //addr 0x013e
input  wire  [7:0] i_fan4_tach0_real_h             , //addr 0x013f
input  wire  [2:0] i_fan4_tach0_real_l             , //addr 0x0140
input  wire  [7:0] i_fan4_tach1_real_h             , //addr 0x0141
input  wire  [2:0] i_fan4_tach1_real_l             , //addr 0x0142

//FAN real tach --0x0143~0x014a                    
input  wire  [7:0] i_fan5_tach0_real_h             , //addr 0x0143
input  wire  [2:0] i_fan5_tach0_real_l             , //addr 0x0144
input  wire  [7:0] i_fan5_tach1_real_h             , //addr 0x0145
input  wire  [2:0] i_fan5_tach1_real_l             , //addr 0x0146
input  wire  [7:0] i_fan6_tach0_real_h             , //addr 0x0147
input  wire  [2:0] i_fan6_tach0_real_l             , //addr 0x0148
input  wire  [7:0] i_fan6_tach1_real_h             , //addr 0x0149
input  wire  [2:0] i_fan6_tach1_real_l             , //addr 0x014a

//FAN real tach --0x014b~0x0152                    
input  wire  [7:0] i_fan7_tach0_real_h             , //addr 0x014b
input  wire  [2:0] i_fan7_tach0_real_l             , //addr 0x014c
input  wire  [7:0] i_fan7_tach1_real_h             , //addr 0x014d
input  wire  [2:0] i_fan7_tach1_real_l             , //addr 0x014e
input  wire  [7:0] i_fan8_tach0_real_h             , //addr 0x014f
input  wire  [2:0] i_fan8_tach0_real_l             , //addr 0x0150
input  wire  [7:0] i_fan8_tach1_real_h             , //addr 0x0151
input  wire  [2:0] i_fan8_tach1_real_l             , //addr 0x0152

//FAN real tach --0x0153~0x015a                    
input  wire  [7:0] i_fan9_tach0_real_h             , //addr 0x0153
input  wire  [2:0] i_fan9_tach0_real_l             , //addr 0x0154
input  wire  [7:0] i_fan9_tach1_real_h             , //addr 0x0155
input  wire  [2:0] i_fan9_tach1_real_l             , //addr 0x0156
input  wire  [7:0] i_fan10_tach0_real_h            , //addr 0x0157
input  wire  [2:0] i_fan10_tach0_real_l            , //addr 0x0158
input  wire  [7:0] i_fan10_tach1_real_h            , //addr 0x0159
input  wire  [2:0] i_fan10_tach1_real_l            , //addr 0x015a

//FAN real tach --0x015b~0x0162                    
input  wire  [7:0] i_fan11_tach0_real_h            , //addr 0x015b
input  wire  [2:0] i_fan11_tach0_real_l            , //addr 0x015c
input  wire  [7:0] i_fan11_tach1_real_h            , //addr 0x015d
input  wire  [2:0] i_fan11_tach1_real_l            , //addr 0x015e
input  wire  [7:0] i_fan12_tach0_real_h            , //addr 0x015f
input  wire  [2:0] i_fan12_tach0_real_l            , //addr 0x0160
input  wire  [7:0] i_fan12_tach1_real_h            , //addr 0x0161
input  wire  [2:0] i_fan12_tach1_real_l            , //addr 0x0162

//FAN real tach --0x0163~0x016a                    
input  wire  [7:0] i_fan13_tach0_real_h            , //addr 0x0163
input  wire  [2:0] i_fan13_tach0_real_l            , //addr 0x0164
input  wire  [7:0] i_fan13_tach1_real_h            , //addr 0x0165
input  wire  [2:0] i_fan13_tach1_real_l            , //addr 0x0166
input  wire  [7:0] i_fan14_tach0_real_h            , //addr 0x0167
input  wire  [2:0] i_fan14_tach0_real_l            , //addr 0x0168
input  wire  [7:0] i_fan14_tach1_real_h            , //addr 0x0169
input  wire  [2:0] i_fan14_tach1_real_l            , //addr 0x016a

//FAN real tach --0x016b~0x0172                    
input  wire  [7:0] i_fan15_tach0_real_h            , //addr 0x016b
input  wire  [2:0] i_fan15_tach0_real_l            , //addr 0x016c
input  wire  [7:0] i_fan15_tach1_real_h            , //addr 0x016d
input  wire  [2:0] i_fan15_tach1_real_l            , //addr 0x016e
input  wire  [7:0] i_fan16_tach0_real_h            , //addr 0x016f
input  wire  [2:0] i_fan16_tach0_real_l            , //addr 0x0170
input  wire  [7:0] i_fan16_tach1_real_h            , //addr 0x0171
input  wire  [2:0] i_fan16_tach1_real_l            , //addr 0x0172

//FAN TYPE--0x0173~0x0182
input  wire  [7:0] i_fan1_type                     , //addr 0x0173        
input  wire  [7:0] i_fan2_type                     , //addr 0x0174
input  wire  [7:0] i_fan3_type                     , //addr 0x0175
input  wire  [7:0] i_fan4_type                     , //addr 0x0176
input  wire  [7:0] i_fan5_type                     , //addr 0x0177
input  wire  [7:0] i_fan6_type                     , //addr 0x0178
input  wire  [7:0] i_fan7_type                     , //addr 0x0179
input  wire  [7:0] i_fan8_type                     , //addr 0x017a
input  wire  [7:0] i_fan9_type                     , //addr 0x017b
input  wire  [7:0] i_fan10_type                    , //addr 0x017c
input  wire  [7:0] i_fan11_type                    , //addr 0x017d
input  wire  [7:0] i_fan12_type                    , //addr 0x017e
input  wire  [7:0] i_fan13_type                    , //addr 0x017f
input  wire  [7:0] i_fan14_type                    , //addr 0x0180
input  wire  [7:0] i_fan15_type                    , //addr 0x0181
input  wire  [7:0] i_fan16_type                    , //addr 0x0182

//FAN LED--0x0183~0x0186                           
output wire        o_fan1_led_g                    , //addr 0x0183 bit7 //default 0
output wire        o_fan2_led_g                    , //addr 0x0183 bit6 //default 0
output wire        o_fan3_led_g                    , //addr 0x0183 bit5 //default 0
output wire        o_fan4_led_g                    , //addr 0x0183 bit4 //default 0
output wire        o_fan5_led_g                    , //addr 0x0183 bit3 //default 0
output wire        o_fan6_led_g                    , //addr 0x0183 bit2 //default 0
output wire        o_fan7_led_g                    , //addr 0x0183 bit1 //default 0
output wire        o_fan8_led_g                    , //addr 0x0183 bit0 //default 0

output wire        o_fan9_led_g                    , //addr 0x0184 bit7 //default 0
output wire        o_fan10_led_g                   , //addr 0x0184 bit6 //default 0
output wire        o_fan11_led_g                   , //addr 0x0184 bit5 //default 0
output wire        o_fan12_led_g                   , //addr 0x0184 bit4 //default 0
output wire        o_fan13_led_g                   , //addr 0x0184 bit3 //default 0
output wire        o_fan14_led_g                   , //addr 0x0184 bit2 //default 0
output wire        o_fan15_led_g                   , //addr 0x0184 bit1 //default 0
output wire        o_fan16_led_g                   , //addr 0x0184 bit0 //default 0

output wire        o_fan1_led_r                    , //addr 0x0185 bit7 //default 1
output wire        o_fan2_led_r                    , //addr 0x0185 bit6 //default 1
output wire        o_fan3_led_r                    , //addr 0x0185 bit5 //default 1
output wire        o_fan4_led_r                    , //addr 0x0185 bit4 //default 1
output wire        o_fan5_led_r                    , //addr 0x0185 bit3 //default 1
output wire        o_fan6_led_r                    , //addr 0x0185 bit2 //default 1
output wire        o_fan7_led_r                    , //addr 0x0185 bit1 //default 1
output wire        o_fan8_led_r                    , //addr 0x0185 bit0 //default 1

output wire        o_fan9_led_r                    , //addr 0x0186 bit7 //default 1
output wire        o_fan10_led_r                   , //addr 0x0186 bit6 //default 1
output wire        o_fan11_led_r                   , //addr 0x0186 bit5 //default 1
output wire        o_fan12_led_r                   , //addr 0x0186 bit4 //default 1
output wire        o_fan13_led_r                   , //addr 0x0186 bit3 //default 1
output wire        o_fan14_led_r                   , //addr 0x0186 bit2 //default 1
output wire        o_fan15_led_r                   , //addr 0x0186 bit1 //default 1
output wire        o_fan16_led_r                     //addr 0x0186 bit0 //default 1



);
	

////////////////////////////////////////////////////////////////////////
//for  i2c slave
///////////////////////////////////////////////////////////////////////
wire w_i2c_start;
wire w_WR       ;
wire w_data_vld_pos;
wire [15:0]w_i2c_command ;
wire [7:0] w_i2c_data_out;
reg  [7:0] r_i2c_data_in;


////////////////////////////////////////////////////////////////////////////////////
//read only register
////////////////////////////////////////////////////////////////////////////////////
wire [7:0] w_ram_0000                                ;
wire [7:0] w_ram_0001                                ;
wire [7:0] w_ram_0002                                ;
wire [7:0] w_ram_0003                                ;
wire [7:0] w_ram_0004                                ;
wire [7:0] w_ram_0005                                ;
wire [7:0] w_ram_0007                                ;
wire [7:0] w_ram_0008                                ;
wire [7:0] w_ram_0009                                ;
wire [7:0] w_ram_000a                                ;
wire [7:0] w_ram_000b                                ;
wire [7:0] w_ram_000c                                ;
// wire [7:0] w_ram_000e                                ;


wire [7:0] w_ram_0010                                ;
wire [7:0] w_ram_0011                                ;
wire [7:0] w_ram_0012                                ;
wire [7:0] w_ram_0013                                ;
wire [7:0] w_ram_0014                                ;
wire [7:0] w_ram_0015                                ;
wire [7:0] w_ram_0016                                ;
wire [7:0] w_ram_0017                                ;
wire [7:0] w_ram_0018                                ;
wire [7:0] w_ram_0019                                ;
wire [7:0] w_ram_001a                                ;
wire [7:0] w_ram_001f                                ;

wire [7:0] w_ram_0020                                ;
wire [7:0] w_ram_0021                                ;
wire [7:0] w_ram_0022                                ;
wire [7:0] w_ram_0023                                ;
wire [7:0] w_ram_0024                                ;
wire [7:0] w_ram_0025                                ;

wire [7:0] w_ram_0027                                ; //2024-6-29 add
wire [7:0] w_ram_0028                                ; //2024-6-29 add
wire [7:0] w_ram_0029                                ; //2024-8-16 add

wire [7:0] w_ram_0101                                ;
wire [7:0] w_ram_0102                                ;

wire [7:0] w_ram_0103                                ;
wire [7:0] w_ram_0104                                ;
wire [7:0] w_ram_0105                                ;
wire [7:0] w_ram_0106                                ;
wire [7:0] w_ram_0107                                ;
wire [7:0] w_ram_0108                                ;
wire [7:0] w_ram_0109                                ;
wire [7:0] w_ram_010a                                ;
wire [7:0] w_ram_010b                                ;
wire [7:0] w_ram_010c                                ;
wire [7:0] w_ram_010d                                ;
wire [7:0] w_ram_010e                                ;
wire [7:0] w_ram_010f                                ;
wire [7:0] w_ram_0110                                ;
wire [7:0] w_ram_0111                                ;
wire [7:0] w_ram_0112                                ;
wire [7:0] w_ram_0113                                ;
wire [7:0] w_ram_0114                                ;
wire [7:0] w_ram_0115                                ;
wire [7:0] w_ram_0116                                ;
wire [7:0] w_ram_0117                                ;
wire [7:0] w_ram_0118                                ;
wire [7:0] w_ram_0119                                ;
wire [7:0] w_ram_011a                                ;
wire [7:0] w_ram_011b                                ;
wire [7:0] w_ram_011c                                ;
wire [7:0] w_ram_011d                                ;
wire [7:0] w_ram_011e                                ;
wire [7:0] w_ram_011f                                ;
wire [7:0] w_ram_0120                                ;
wire [7:0] w_ram_0121                                ;
wire [7:0] w_ram_0122                                ;

wire [7:0] w_ram_0133                                ;
wire [7:0] w_ram_0134                                ;
wire [7:0] w_ram_0135                                ;
wire [7:0] w_ram_0136                                ;
wire [7:0] w_ram_0137                                ;
wire [7:0] w_ram_0138                                ;
wire [7:0] w_ram_0139                                ;
wire [7:0] w_ram_013a                                ;

wire [7:0] w_ram_013b                                ;
wire [7:0] w_ram_013c                                ;
wire [7:0] w_ram_013d                                ;
wire [7:0] w_ram_013e                                ;
wire [7:0] w_ram_013f                                ;
wire [7:0] w_ram_0140                                ;
wire [7:0] w_ram_0141                                ;
wire [7:0] w_ram_0142                                ;

wire [7:0] w_ram_0143                                ;
wire [7:0] w_ram_0144                                ;
wire [7:0] w_ram_0145                                ;
wire [7:0] w_ram_0146                                ;
wire [7:0] w_ram_0147                                ;
wire [7:0] w_ram_0148                                ;
wire [7:0] w_ram_0149                                ;
wire [7:0] w_ram_014a                                ;

wire [7:0] w_ram_014b                                ;
wire [7:0] w_ram_014c                                ;
wire [7:0] w_ram_014d                                ;
wire [7:0] w_ram_014e                                ;
wire [7:0] w_ram_014f                                ;
wire [7:0] w_ram_0150                                ;
wire [7:0] w_ram_0151                                ;
wire [7:0] w_ram_0152                                ;

wire [7:0] w_ram_0153                                ;
wire [7:0] w_ram_0154                                ;
wire [7:0] w_ram_0155                                ;
wire [7:0] w_ram_0156                                ;
wire [7:0] w_ram_0157                                ;
wire [7:0] w_ram_0158                                ;
wire [7:0] w_ram_0159                                ;
wire [7:0] w_ram_015a                                ;

wire [7:0] w_ram_015b                                ;
wire [7:0] w_ram_015c                                ;
wire [7:0] w_ram_015d                                ;
wire [7:0] w_ram_015e                                ;
wire [7:0] w_ram_015f                                ;
wire [7:0] w_ram_0160                                ;
wire [7:0] w_ram_0161                                ;
wire [7:0] w_ram_0162                                ;

wire [7:0] w_ram_0163                                ;
wire [7:0] w_ram_0164                                ;
wire [7:0] w_ram_0165                                ;
wire [7:0] w_ram_0166                                ;
wire [7:0] w_ram_0167                                ;
wire [7:0] w_ram_0168                                ;
wire [7:0] w_ram_0169                                ;
wire [7:0] w_ram_016a                                ;

wire [7:0] w_ram_016b                                ;
wire [7:0] w_ram_016c                                ;
wire [7:0] w_ram_016d                                ;
wire [7:0] w_ram_016e                                ;
wire [7:0] w_ram_016f                                ;
wire [7:0] w_ram_0170                                ;
wire [7:0] w_ram_0171                                ;
wire [7:0] w_ram_0172                                ;

wire [7:0] w_ram_0173                                ;
wire [7:0] w_ram_0174                                ;
wire [7:0] w_ram_0175                                ;
wire [7:0] w_ram_0176                                ;
wire [7:0] w_ram_0177                                ;
wire [7:0] w_ram_0178                                ;
wire [7:0] w_ram_0179                                ;
wire [7:0] w_ram_017a                                ;
wire [7:0] w_ram_017b                                ;
wire [7:0] w_ram_017c                                ;
wire [7:0] w_ram_017d                                ;
wire [7:0] w_ram_017e                                ;
wire [7:0] w_ram_017f                                ;
wire [7:0] w_ram_0180                                ;
wire [7:0] w_ram_0181                                ;
wire [7:0] w_ram_0182                                ;


////////////////////////////////////////////////////////////////////////////////////
//raed & write  register
////////////////////////////////////////////////////////////////////////////////////
reg [7:0] r_reg_0006                                 ;
// reg [7:0] r_reg_000d                                 ;

reg [7:0] r_reg_001b                                 ;
reg [7:0] r_reg_001c                                 ;
reg [7:0] r_reg_001d                                 ;
reg [7:0] r_reg_001e                                 ;

reg [7:0] r_reg_0026                                 ;
reg [7:0] r_reg_0033                                 ; //2024-9-9 add
reg [7:0] r_reg_0034                                 ; //2024-9-12 add

reg [7:0] r_reg_0035                                 ; //2024-10-10 add

reg [7:0] r_reg_0123                                 ;
reg [7:0] r_reg_0124                                 ;
reg [7:0] r_reg_0125                                 ;
reg [7:0] r_reg_0126                                 ;
reg [7:0] r_reg_0127                                 ;
reg [7:0] r_reg_0128                                 ;
reg [7:0] r_reg_0129                                 ;
reg [7:0] r_reg_012a                                 ;
reg [7:0] r_reg_012b                                 ;
reg [7:0] r_reg_012c                                 ;
reg [7:0] r_reg_012d                                 ;
reg [7:0] r_reg_012e                                 ;
reg [7:0] r_reg_012f                                 ;
reg [7:0] r_reg_0130                                 ;
reg [7:0] r_reg_0131                                 ;
reg [7:0] r_reg_0132                                 ;

reg [7:0] r_reg_0183                                 ;
reg [7:0] r_reg_0184                                 ;
reg [7:0] r_reg_0185                                 ;
reg [7:0] r_reg_0186                                 ;

////////////////////////////////////////////////////////////////////////////////////
//RW REG assignment
////////////////////////////////////////////////////////////////////////////////////
assign  o_test_reg                   = r_reg_0006    ;

assign  o_bptb_eep_wp_r              = r_reg_001b[7] ;
assign  o_bp_eeprom_wp_r             = r_reg_001b[6] ;


assign  o_slot1_thorttle_r           = r_reg_001c[7] ;
assign  o_slot2_thorttle_r           = r_reg_001c[6] ;
assign  o_slot3_thorttln_r           = r_reg_001c[5] ;
assign  o_slot4_thorttle_r           = r_reg_001c[4] ;
assign  o_slot5_thorttle_r           = r_reg_001c[3] ;
assign  o_slot6_thorttle_r           = r_reg_001c[2] ;
assign  o_slot7_thorttle_r           = r_reg_001c[1] ;
assign  o_slot8_thorttle_r           = r_reg_001c[0] ;


assign  o_pal_usbmux_sel             = r_reg_001d[7] ;


assign  o_pwr_brake_n_r              = r_reg_001e[7] ;
assign  o_wp_hw_ctrl_n               = r_reg_001e[6] ;


assign  o_psu0_ctl                   = r_reg_0026[7] ;
assign  o_psu1_ctl                   = r_reg_0026[6] ;
assign  o_psu2_ctl                   = r_reg_0026[5] ;
assign  o_psu3_ctl                   = r_reg_0026[4] ;
assign  o_psu4_ctl                   = r_reg_0026[3] ;
assign  o_psu5_ctl                   = r_reg_0026[2] ;

assign  o_bmc_ctrl_sw_mode           = r_reg_0033[3:0] ;
assign  o_bmc_ctrl_sw_mode_mask      = r_reg_0034[3:0] ;

assign  o_bmc_ctrl_nic_rst           = r_reg_0035    ;

assign  o_pwm_bmc_fan1               = r_reg_0123    ;
assign  o_pwm_bmc_fan2               = r_reg_0124    ;
assign  o_pwm_bmc_fan3               = r_reg_0125    ;
assign  o_pwm_bmc_fan4               = r_reg_0126    ;
assign  o_pwm_bmc_fan5               = r_reg_0127    ;
assign  o_pwm_bmc_fan6               = r_reg_0128    ;
assign  o_pwm_bmc_fan7               = r_reg_0129    ;
assign  o_pwm_bmc_fan8               = r_reg_012a    ;
assign  o_pwm_bmc_fan9               = r_reg_012b    ;
assign  o_pwm_bmc_fan10              = r_reg_012c    ;
assign  o_pwm_bmc_fan11              = r_reg_012d    ;
assign  o_pwm_bmc_fan12              = r_reg_012e    ;
assign  o_pwm_bmc_fan13              = r_reg_012f    ;
assign  o_pwm_bmc_fan14              = r_reg_0130    ;
assign  o_pwm_bmc_fan15              = r_reg_0131    ;
assign  o_pwm_bmc_fan16              = r_reg_0132    ;

assign  o_fan1_led_g                 = r_reg_0183[7] ;
assign  o_fan2_led_g                 = r_reg_0183[6] ;
assign  o_fan3_led_g                 = r_reg_0183[5] ;
assign  o_fan4_led_g                 = r_reg_0183[4] ;
assign  o_fan5_led_g                 = r_reg_0183[3] ;
assign  o_fan6_led_g                 = r_reg_0183[2] ;
assign  o_fan7_led_g                 = r_reg_0183[1] ;
assign  o_fan8_led_g                 = r_reg_0183[0] ;

assign  o_fan9_led_g                 = r_reg_0184[7] ;
assign  o_fan10_led_g                = r_reg_0184[6] ;
assign  o_fan11_led_g                = r_reg_0184[5] ;
assign  o_fan12_led_g                = r_reg_0184[4] ;
assign  o_fan13_led_g                = r_reg_0184[3] ;
assign  o_fan14_led_g                = r_reg_0184[2] ;
assign  o_fan15_led_g                = r_reg_0184[1] ;
assign  o_fan16_led_g                = r_reg_0184[0] ;

assign  o_fan1_led_r                 = r_reg_0185[7] ;
assign  o_fan2_led_r                 = r_reg_0185[6] ;
assign  o_fan3_led_r                 = r_reg_0185[5] ;
assign  o_fan4_led_r                 = r_reg_0185[4] ;
assign  o_fan5_led_r                 = r_reg_0185[3] ;
assign  o_fan6_led_r                 = r_reg_0185[2] ;
assign  o_fan7_led_r                 = r_reg_0185[1] ;
assign  o_fan8_led_r                 = r_reg_0185[0] ;

assign  o_fan9_led_r                 = r_reg_0186[7] ;
assign  o_fan10_led_r                = r_reg_0186[6] ;
assign  o_fan11_led_r                = r_reg_0186[5] ;
assign  o_fan12_led_r                = r_reg_0186[4] ;
assign  o_fan13_led_r                = r_reg_0186[3] ;
assign  o_fan14_led_r                = r_reg_0186[2] ;
assign  o_fan15_led_r                = r_reg_0186[1] ;
assign  o_fan16_led_r                = r_reg_0186[0] ;


////////////////////////////////////////////////////////////////////////////////////
//RO REG assignment
////////////////////////////////////////////////////////////////////////////////////
assign w_ram_0000    = i_product_id	                 ;
assign w_ram_0001    = i_vender_id	                 ;
assign w_ram_0002    = i_board_id	                 ;
assign w_ram_0003    = i_pcb_version                 ;
assign w_ram_0004    = i_bom_id                      ;
assign w_ram_0005    = i_cpld_version                ;
assign w_ram_0007    = i_year                        ;
assign w_ram_0008    = i_month                       ;
assign w_ram_0009    = i_day                         ;
assign w_ram_000a = {
                     1'b0                            ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0                            ,
                     i_ncpin
					 };
assign w_ram_000b	 = i_cpld_compa_version          ;
assign w_ram_000c	 = i_cpld_debug_version          ;


assign w_ram_0010    = i_nic_board_id	             ;
assign w_ram_0011    = i_nic_pcb_version             ;


assign w_ram_0012 = {
                     i_I2C1_ALERT_N_R	             ,
                     i_I2C2_ALERT_N_R	             ,
                     i_I2C9_9548_CH4_ALERT           ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0
					 };

assign w_ram_0013 = {
                     i_PAL_RAA_CFP_R                 ,
                     i_p0v8_sw0_pwrgd_db             ,
                     i_p0v8_sw1_pwrgd_db             ,
                     i_p0v8_sw2_pwrgd_db             ,
                     i_p0v8_sw3_pwrgd_db             ,
                     i_PG_P5V0_R                     ,
                     i_PG_P1V8_R	                 ,
                     i_PG_P1V8_PLL_R
					 };

assign w_ram_0014 = {
                     i_P5V_VGA_OC                    ,
                     i_P5V_RIGHTEAR_USB_OC           ,
                     i_P5V_STBY_USB_OC               ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0
					 };

assign w_ram_0015 = {
                     i_SMB_PSU0_ALERT_R              ,
                     i_SMB_PSU1_ALERT_R              ,
                     i_SMB_PSU2_ALERT_R              ,
                     i_SMB_PSU3_ALERT_R              ,
                     i_SMB_PSU4_ALERT_R              ,
                     i_SMB_PSU5_ALERT_R              ,
                     1'b0                            ,
                     1'b0
					 };

assign w_ram_0016 = {
                     i_NIC_3P3V_A_PG_R               ,
                     i_NIC_3P3V_B_PG_R               ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0
					 };

assign w_ram_0017 = {
                     i_RETIMER1_INT_N_R              ,
                     i_RETIMER2_INT_N_R              ,
                     i_RETIMER3_INT_N_R              ,
                     i_RETIMER4_INT_N_R              ,
                     i_RETIMER5_INT_N_R              ,
                     i_RETIMER6_INT_N_R              ,
                     i_RETIMER7_INT_N_R              ,
                     i_RETIMER8_INT_N_R
					 };

assign w_ram_0018 = {
                     i_BP1_PWR_PG_R                  ,
                     i_BP2_PWR_PG_R                  ,
                     i_BPTB_RE_DONE_R                ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0
					 };

assign w_ram_0019 = {
                     i_GPU_BASE_PWR_GD_R	         ,
                     i_THERM_OVERT_N_R	             ,
                     i_FPGA_EROT_FATALERR_N_R        ,
                     i_FPGA_OVERT_N_R                ,
                     i_GPU_BASE_HMC_READY_R          ,
                     i_HMC_PRSNT_N_R                 ,
                     i_BASE_PRSNT_N_R                ,
                     1'b0
					 };

assign w_ram_001a = {
                     i_PAL_SAS_ALL_DONE_N            ,
                     i_DS160_TX_ALL_DONE_N           ,
                     i_DS160_RX_ALL_DONE_N           ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0
					 };

assign w_ram_001f = {
                     i_sw0_spi_cs_sel_err_flag       ,
                     i_sw1_spi_cs_sel_err_flag       ,
                     i_sw2_spi_cs_sel_err_flag       ,
                     i_sw3_spi_cs_sel_err_flag       ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0
					 };

assign w_ram_0020 = {
                     i_TEMP_ALERT_0_R                ,
                     i_TEMP_ALERT_1_R                ,
                     i_TEMP_ALERT_2_R                ,
                     i_TEMP_ALERT_3_R                ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0
					 };

assign w_ram_0021 = {
                     i_SW0_CLKREQ_N_R               ,
                     i_SW1_CLKREQ_N_R               ,
                     i_SW2_CLKREQ_N_R               ,
                     i_SW3_CLKREQ_N_R               ,
                     i_P0V8_SW0_ALERT_N             ,
                     i_P0V8_SW1_ALERT_N             ,
                     i_P0V8_SW2_ALERT_N             ,
                     i_P0V8_SW3_ALERT_N            
					 };
					 
assign w_ram_0022 = {
                     i_P0V8_SW0_VRHOT_N             ,
                     i_P0V8_SW1_VRHOT_N             ,
                     i_P0V8_SW2_VRHOT_N             ,
                     i_P0V8_SW3_VRHOT_N             ,
                     i_P0V8_SW0_FAULT_N             ,
                     i_P0V8_SW1_FAULT_N             ,
                     i_P0V8_SW2_FAULT_N             ,
                     i_P0V8_SW3_FAULT_N            
					 };

assign w_ram_0023 = {
                     i_SLOT1_WAKE_N                 ,
                     i_SLOT2_WAKE_N                 ,
                     i_SLOT3_WAKE_N                 ,
                     i_SLOT4_WAKE_N                 ,
                     i_SLOT5_WAKE_N                 ,
                     i_SLOT6_WAKE_N                 ,
                     i_SLOT7_WAKE_N                 ,
                     i_SLOT8_WAKE_N                
					 };

assign w_ram_0024 = {
                     i_psu0_pwrok_n                  ,
                     i_psu1_pwrok_n                  ,
                     i_psu2_pwrok_n                  ,
                     i_psu3_pwrok_n                  ,
                     i_psu4_pwrok_n                  ,
                     i_psu5_pwrok_n                  ,
                     1'b0                            ,
                     1'b0
					 };

assign w_ram_0025 = {
                     i_PSU0_PRSNT_R                  ,
                     i_PSU1_PRSNT_R                  ,
                     i_PSU2_PRSNT_R                  ,
                     i_PSU3_PRSNT_R                  ,
                     i_PSU4_PRSNT_R                  ,
                     i_PSU5_PRSNT_R                  ,
                     1'b0                            ,
                     1'b0
					 };

assign w_ram_0027 = {
                     i_HSC0_PG                       ,
                     i_P12V_PG                       ,
                     i_RETIMER1_1P8_PG               ,
                     i_RETIMER2_1P8_PG               ,
                     i_CT_P1V25_SW0_PG               ,
                     i_CT_P1V25_SW1_PG               ,
                     i_CT_P1V25_SW2_PG               ,
                     i_CT_P1V25_SW3_PG               
					 };

assign w_ram_0028 = {
                     i_RETIMER1_0P9_PG               ,
                     i_RETIMER2_0P9_PG               ,
                     i_RETIMER3_0P9_PG               ,
                     i_RETIMER4_0P9_PG               ,
                     i_RETIMER5_0P9_PG               ,
                     i_RETIMER6_0P9_PG               ,
                     i_RETIMER7_0P9_PG               ,
                     i_RETIMER8_0P9_PG               
					 };
					 
assign w_ram_0029 = {
                     i_3V3IO_RSVD0_FFU_R             ,
                     i_3V3IO_RSVD1_FFU_R             ,
                     i_3V3IO_RSVD2_FFU_R             ,
                     i_3V3IO_RSVD3_FFU_R             ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0
					 };					 
					 
assign w_ram_0101 = {
                     i_fan0_present_n                ,
                     i_fan1_present_n                ,
                     i_fan2_present_n                ,
                     i_fan3_present_n                ,
                     i_fan4_present_n                ,
                     i_fan5_present_n                ,
                     i_fan6_present_n                ,
                     i_fan7_present_n               
					 };

assign w_ram_0102 = {
                     i_fan8_present_n                ,
                     i_fan9_present_n                ,
                     i_fan10_present_n               ,
                     i_fan11_present_n               ,
                     i_fan12_present_n               ,
                     i_fan13_present_n               ,
                     i_fan14_present_n               ,
                     i_fan15_present_n              
					 };

assign w_ram_0103 = i_fan1_tach0_reg                 ;
assign w_ram_0104 = i_fan1_tach1_reg                 ;
assign w_ram_0105 = i_fan2_tach0_reg                 ;
assign w_ram_0106 = i_fan2_tach1_reg                 ;
assign w_ram_0107 = i_fan3_tach0_reg                 ;
assign w_ram_0108 = i_fan3_tach1_reg                 ;
assign w_ram_0109 = i_fan4_tach0_reg                 ;
assign w_ram_010a = i_fan4_tach1_reg                 ;
assign w_ram_010b = i_fan5_tach0_reg                 ;
assign w_ram_010c = i_fan5_tach1_reg                 ;
assign w_ram_010d = i_fan6_tach0_reg                 ;
assign w_ram_010e = i_fan6_tach1_reg                 ;
assign w_ram_010f = i_fan7_tach0_reg                 ;
assign w_ram_0110 = i_fan7_tach1_reg                 ;
assign w_ram_0111 = i_fan8_tach0_reg                 ;
assign w_ram_0112 = i_fan8_tach1_reg                 ;
assign w_ram_0113 = i_fan9_tach0_reg                 ;
assign w_ram_0114 = i_fan9_tach1_reg                 ;
assign w_ram_0115 = i_fan10_tach0_reg                ;
assign w_ram_0116 = i_fan10_tach1_reg                ;
assign w_ram_0117 = i_fan11_tach0_reg                ;
assign w_ram_0118 = i_fan11_tach1_reg                ;
assign w_ram_0119 = i_fan12_tach0_reg                ;
assign w_ram_011a = i_fan12_tach1_reg                ;
assign w_ram_011b = i_fan13_tach0_reg                ;
assign w_ram_011c = i_fan13_tach1_reg                ;
assign w_ram_011d = i_fan14_tach0_reg                ;
assign w_ram_011e = i_fan14_tach1_reg                ;
assign w_ram_011f = i_fan15_tach0_reg                ;
assign w_ram_0120 = i_fan15_tach1_reg                ;
assign w_ram_0121 = i_fan16_tach0_reg                ;
assign w_ram_0122 = i_fan16_tach1_reg                ;


assign w_ram_0133 = i_fan1_tach0_real_h	             ;
assign w_ram_0134 = {
                     i_fan1_tach0_real_l             ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0
					 };
					 
assign w_ram_0135 = i_fan1_tach1_real_h	             ;
assign w_ram_0136 = {
                     i_fan1_tach1_real_l             ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0
					 };
					 
assign w_ram_0137 = i_fan2_tach0_real_h	             ;
assign w_ram_0138 = {
                     i_fan2_tach0_real_l             ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0
					 };
					 
assign w_ram_0139 = i_fan2_tach1_real_h	             ;
assign w_ram_013a = {
                     i_fan2_tach1_real_l             ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0
					 };

assign w_ram_013b = i_fan3_tach0_real_h	             ;
assign w_ram_013c = {
                     i_fan3_tach0_real_l             ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0
					 };
					 
assign w_ram_013d = i_fan3_tach1_real_h	             ;
assign w_ram_013e = {
                     i_fan3_tach1_real_l             ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0
					 };

assign w_ram_013f = i_fan4_tach0_real_h	             ;
assign w_ram_0140 = {
                     i_fan4_tach0_real_l             ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0
					 };
					 
assign w_ram_0141 = i_fan4_tach1_real_h	             ;
assign w_ram_0142 = {
                     i_fan4_tach1_real_l             ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0
					 };

assign w_ram_0143 = i_fan5_tach0_real_h	             ;
assign w_ram_0144 = {
                     i_fan5_tach0_real_l             ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0
					 };
					 
assign w_ram_0145 = i_fan5_tach1_real_h	             ;
assign w_ram_0146 = {
                     i_fan5_tach1_real_l             ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0
					 };

assign w_ram_0147 = i_fan6_tach0_real_h	             ;
assign w_ram_0148 = {
                     i_fan6_tach0_real_l             ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0
					 };
					 
assign w_ram_0149 = i_fan6_tach1_real_h	             ;
assign w_ram_014a = {
                     i_fan6_tach1_real_l             ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0
					 };

assign w_ram_014b = i_fan7_tach0_real_h	             ;
assign w_ram_014c = {
                     i_fan7_tach0_real_l             ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0
					 };
					 
assign w_ram_014d = i_fan7_tach1_real_h	             ;
assign w_ram_014e = {
                     i_fan7_tach1_real_l             ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0
					 };

assign w_ram_014f = i_fan8_tach0_real_h	             ;
assign w_ram_0150 = {
                     i_fan8_tach0_real_l             ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0
					 };
					 
assign w_ram_0151 = i_fan8_tach1_real_h	             ;
assign w_ram_0152 = {
                     i_fan8_tach1_real_l             ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0
					 };

assign w_ram_0153 = i_fan9_tach0_real_h	             ;
assign w_ram_0154 = {
                     i_fan9_tach0_real_l             ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0
					 };
					 
assign w_ram_0155 = i_fan9_tach1_real_h	             ;
assign w_ram_0156 = {
                     i_fan9_tach1_real_l             ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0
					 };

assign w_ram_0157 = i_fan10_tach0_real_h	         ;
assign w_ram_0158 = {
                     i_fan10_tach0_real_l            ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0
					 };
					 
assign w_ram_0159 = i_fan10_tach1_real_h	         ;
assign w_ram_015a = {
                     i_fan10_tach1_real_l            ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0
					 };

assign w_ram_015b = i_fan11_tach0_real_h	         ;
assign w_ram_015c = {
                     i_fan11_tach0_real_l            ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0
					 };
					 
assign w_ram_015d = i_fan11_tach1_real_h	         ;
assign w_ram_015e = {
                     i_fan11_tach1_real_l            ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0
					 };

assign w_ram_015f = i_fan12_tach0_real_h	         ;
assign w_ram_0160 = {
                     i_fan12_tach0_real_l            ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0
					 };
					 
assign w_ram_0161 = i_fan12_tach1_real_h	         ;
assign w_ram_0162 = {
                     i_fan12_tach1_real_l            ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0
					 };

assign w_ram_0163 = i_fan13_tach0_real_h	         ;
assign w_ram_0164 = {
                     i_fan13_tach0_real_l            ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0
					 };
					 
assign w_ram_0165 = i_fan13_tach1_real_h	         ;
assign w_ram_0166 = {
                     i_fan13_tach1_real_l            ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0
					 };

assign w_ram_0167 = i_fan14_tach0_real_h	         ;
assign w_ram_0168 = {
                     i_fan14_tach0_real_l            ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0
					 };
					 
assign w_ram_0169 = i_fan14_tach1_real_h	         ;
assign w_ram_016a = {
                     i_fan14_tach1_real_l            ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0
					 };

assign w_ram_016b = i_fan15_tach0_real_h	         ;
assign w_ram_016c = {
                     i_fan15_tach0_real_l            ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0
					 };
					 
assign w_ram_016d = i_fan15_tach1_real_h	         ;
assign w_ram_016e = {
                     i_fan15_tach1_real_l            ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0
					 };

assign w_ram_016f = i_fan16_tach0_real_h	         ;
assign w_ram_0170 = {
                     i_fan16_tach0_real_l            ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0
					 };
					 
assign w_ram_0171 = i_fan16_tach1_real_h	         ;
assign w_ram_0172 = {
                     i_fan16_tach1_real_l            ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0
					 };

assign w_ram_0173 = i_fan1_type                      ;
assign w_ram_0174 = i_fan2_type                      ;
assign w_ram_0175 = i_fan3_type                      ;
assign w_ram_0176 = i_fan4_type                      ;
assign w_ram_0177 = i_fan5_type                      ;
assign w_ram_0178 = i_fan6_type                      ;
assign w_ram_0179 = i_fan7_type                      ;
assign w_ram_017a = i_fan8_type                      ;
assign w_ram_017b = i_fan9_type                      ;
assign w_ram_017c = i_fan10_type                     ;
assign w_ram_017d = i_fan11_type                     ;
assign w_ram_017e = i_fan12_type                     ;
assign w_ram_017f = i_fan13_type                     ;
assign w_ram_0180 = i_fan14_type                     ;
assign w_ram_0181 = i_fan15_type                     ;
assign w_ram_0182 = i_fan16_type                     ;



//////////////////////////////////////Read data/////////////////////////////////////
					 
always@(posedge i_clk or negedge i_rst_n)
begin
    if(~i_rst_n)
	begin
	    r_i2c_data_in  <= 8'h00;
	end
	else 
	begin
	case(w_i2c_command) 		
        16'h0000: r_i2c_data_in <= w_ram_0000;//RO
		16'h0001: r_i2c_data_in <= w_ram_0001;//RO
		16'h0002: r_i2c_data_in <= w_ram_0002;//RO
		16'h0003: r_i2c_data_in <= w_ram_0003;//RO
		16'h0004: r_i2c_data_in <= w_ram_0004;//RO
		16'h0005: r_i2c_data_in <= w_ram_0005;//RO
		16'h0006: r_i2c_data_in <= r_reg_0006;//RW
		16'h0007: r_i2c_data_in <= w_ram_0007;//RO
		16'h0008: r_i2c_data_in <= w_ram_0008;//RO
		16'h0009: r_i2c_data_in <= w_ram_0009;//RO
		16'h000a: r_i2c_data_in <= w_ram_000a;//RO
		16'h000b: r_i2c_data_in <= w_ram_000b;//RO
		16'h000c: r_i2c_data_in <= w_ram_000c;//RO
			
		16'h0010: r_i2c_data_in <= w_ram_0010;//RO	
		16'h0011: r_i2c_data_in <= w_ram_0011;//RO	
		16'h0012: r_i2c_data_in <= w_ram_0012;//RO	
		16'h0013: r_i2c_data_in <= w_ram_0013;//RO	
		16'h0014: r_i2c_data_in <= w_ram_0014;//RO	
		16'h0015: r_i2c_data_in <= w_ram_0015;//RO	
		16'h0016: r_i2c_data_in <= w_ram_0016;//RO	
		16'h0017: r_i2c_data_in <= w_ram_0017;//RO	
		16'h0018: r_i2c_data_in <= w_ram_0018;//RO	
		16'h0019: r_i2c_data_in <= w_ram_0019;//RO	
		16'h001a: r_i2c_data_in <= w_ram_001a;//RO	
		16'h001f: r_i2c_data_in <= w_ram_001f;//RO	
		16'h0020: r_i2c_data_in <= w_ram_0020;//RO
		16'h0021: r_i2c_data_in <= w_ram_0021;//RO
		16'h0022: r_i2c_data_in <= w_ram_0022;//RO
		16'h0023: r_i2c_data_in <= w_ram_0023;//RO
		16'h0024: r_i2c_data_in <= w_ram_0024;//RO
		16'h0025: r_i2c_data_in <= w_ram_0025;//RO
		16'h0027: r_i2c_data_in <= w_ram_0027;//RO
		16'h0028: r_i2c_data_in <= w_ram_0028;//RO
		16'h0029: r_i2c_data_in <= w_ram_0029;//RO
		
		
		16'h0101: r_i2c_data_in <= w_ram_0101;//RO
		16'h0102: r_i2c_data_in <= w_ram_0102;//RO
		16'h0103: r_i2c_data_in <= w_ram_0103;//RO
		16'h0104: r_i2c_data_in <= w_ram_0104;//RO
		16'h0105: r_i2c_data_in <= w_ram_0105;//RO
		16'h0106: r_i2c_data_in <= w_ram_0106;//RO
		16'h0107: r_i2c_data_in <= w_ram_0107;//RO
		16'h0108: r_i2c_data_in <= w_ram_0108;//RO
		16'h0109: r_i2c_data_in <= w_ram_0109;//RO
		16'h010a: r_i2c_data_in <= w_ram_010a;//RO
		16'h010b: r_i2c_data_in <= w_ram_010b;//RO
		16'h010c: r_i2c_data_in <= w_ram_010c;//RO
		16'h010d: r_i2c_data_in <= w_ram_010d;//RO
		16'h010e: r_i2c_data_in <= w_ram_010e;//RO
		16'h010f: r_i2c_data_in <= w_ram_010f;//RO
		16'h0110: r_i2c_data_in <= w_ram_0110;//RO
		16'h0111: r_i2c_data_in <= w_ram_0111;//RO
		16'h0112: r_i2c_data_in <= w_ram_0112;//RO
		16'h0113: r_i2c_data_in <= w_ram_0113;//RO
		16'h0114: r_i2c_data_in <= w_ram_0114;//RO
		16'h0115: r_i2c_data_in <= w_ram_0115;//RO
		16'h0116: r_i2c_data_in <= w_ram_0116;//RO
		16'h0117: r_i2c_data_in <= w_ram_0117;//RO
		16'h0118: r_i2c_data_in <= w_ram_0118;//RO
		16'h0119: r_i2c_data_in <= w_ram_0119;//RO
		16'h011a: r_i2c_data_in <= w_ram_011a;//RO
		16'h011b: r_i2c_data_in <= w_ram_011b;//RO
		16'h011c: r_i2c_data_in <= w_ram_011c;//RO
		16'h011d: r_i2c_data_in <= w_ram_011d;//RO
		16'h011e: r_i2c_data_in <= w_ram_011e;//RO
		16'h011f: r_i2c_data_in <= w_ram_011f;//RO
		16'h0120: r_i2c_data_in <= w_ram_0120;//RO
		16'h0121: r_i2c_data_in <= w_ram_0121;//RO
		16'h0122: r_i2c_data_in <= w_ram_0122;//RO
		16'h0133: r_i2c_data_in <= w_ram_0133;//RO
		16'h0134: r_i2c_data_in <= w_ram_0134;//RO
		16'h0135: r_i2c_data_in <= w_ram_0135;//RO
		16'h0136: r_i2c_data_in <= w_ram_0136;//RO
		16'h0137: r_i2c_data_in <= w_ram_0137;//RO
		16'h0138: r_i2c_data_in <= w_ram_0138;//RO
		16'h0139: r_i2c_data_in <= w_ram_0139;//RO
		16'h013a: r_i2c_data_in <= w_ram_013a;//RO
		16'h013b: r_i2c_data_in <= w_ram_013b;//RO
		16'h013c: r_i2c_data_in <= w_ram_013c;//RO
		16'h013d: r_i2c_data_in <= w_ram_013d;//RO
		16'h013e: r_i2c_data_in <= w_ram_013e;//RO
		16'h013f: r_i2c_data_in <= w_ram_013f;//RO
		16'h0140: r_i2c_data_in <= w_ram_0140;//RO
		16'h0141: r_i2c_data_in <= w_ram_0141;//RO
		16'h0142: r_i2c_data_in <= w_ram_0142;//RO
		16'h0143: r_i2c_data_in <= w_ram_0143;//RO
		16'h0144: r_i2c_data_in <= w_ram_0144;//RO
		16'h0145: r_i2c_data_in <= w_ram_0145;//RO
		16'h0146: r_i2c_data_in <= w_ram_0146;//RO
		16'h0147: r_i2c_data_in <= w_ram_0147;//RO
		16'h0148: r_i2c_data_in <= w_ram_0148;//RO
		16'h0149: r_i2c_data_in <= w_ram_0149;//RO
		16'h014a: r_i2c_data_in <= w_ram_014a;//RO
		16'h014b: r_i2c_data_in <= w_ram_014b;//RO
		16'h014c: r_i2c_data_in <= w_ram_014c;//RO
		16'h014d: r_i2c_data_in <= w_ram_014d;//RO
		16'h014e: r_i2c_data_in <= w_ram_014e;//RO
		16'h014f: r_i2c_data_in <= w_ram_014f;//RO
		16'h0150: r_i2c_data_in <= w_ram_0150;//RO
		16'h0151: r_i2c_data_in <= w_ram_0151;//RO
		16'h0152: r_i2c_data_in <= w_ram_0152;//RO
		16'h0153: r_i2c_data_in <= w_ram_0153;//RO
		16'h0154: r_i2c_data_in <= w_ram_0154;//RO
		16'h0155: r_i2c_data_in <= w_ram_0155;//RO
		16'h0156: r_i2c_data_in <= w_ram_0156;//RO
		16'h0157: r_i2c_data_in <= w_ram_0157;//RO
		16'h0158: r_i2c_data_in <= w_ram_0158;//RO
		16'h0159: r_i2c_data_in <= w_ram_0159;//RO
		16'h015a: r_i2c_data_in <= w_ram_015a;//RO
		16'h015b: r_i2c_data_in <= w_ram_015b;//RO
		16'h015c: r_i2c_data_in <= w_ram_015c;//RO
		16'h015d: r_i2c_data_in <= w_ram_015d;//RO
		16'h015e: r_i2c_data_in <= w_ram_015e;//RO
		16'h015f: r_i2c_data_in <= w_ram_015f;//RO
		16'h0160: r_i2c_data_in <= w_ram_0160;//RO
		16'h0161: r_i2c_data_in <= w_ram_0161;//RO
		16'h0162: r_i2c_data_in <= w_ram_0162;//RO
		16'h0163: r_i2c_data_in <= w_ram_0163;//RO
		16'h0164: r_i2c_data_in <= w_ram_0164;//RO
		16'h0165: r_i2c_data_in <= w_ram_0165;//RO
		16'h0166: r_i2c_data_in <= w_ram_0166;//RO
		16'h0167: r_i2c_data_in <= w_ram_0167;//RO
		16'h0168: r_i2c_data_in <= w_ram_0168;//RO
		16'h0169: r_i2c_data_in <= w_ram_0169;//RO
		16'h016a: r_i2c_data_in <= w_ram_016a;//RO
		16'h016b: r_i2c_data_in <= w_ram_016b;//RO
		16'h016c: r_i2c_data_in <= w_ram_016c;//RO
		16'h016d: r_i2c_data_in <= w_ram_016d;//RO
		16'h016e: r_i2c_data_in <= w_ram_016e;//RO
		16'h016f: r_i2c_data_in <= w_ram_016f;//RO
		16'h0170: r_i2c_data_in <= w_ram_0170;//RO
		16'h0171: r_i2c_data_in <= w_ram_0171;//RO
		16'h0172: r_i2c_data_in <= w_ram_0172;//RO
		16'h0173: r_i2c_data_in <= w_ram_0173;//RO
		16'h0174: r_i2c_data_in <= w_ram_0174;//RO
		16'h0175: r_i2c_data_in <= w_ram_0175;//RO
		16'h0176: r_i2c_data_in <= w_ram_0176;//RO
		16'h0177: r_i2c_data_in <= w_ram_0177;//RO
		16'h0178: r_i2c_data_in <= w_ram_0178;//RO
		16'h0179: r_i2c_data_in <= w_ram_0179;//RO
		16'h017a: r_i2c_data_in <= w_ram_017a;//RO
		16'h017b: r_i2c_data_in <= w_ram_017b;//RO
		16'h017c: r_i2c_data_in <= w_ram_017c;//RO
		16'h017d: r_i2c_data_in <= w_ram_017d;//RO
		16'h017e: r_i2c_data_in <= w_ram_017e;//RO
		16'h017f: r_i2c_data_in <= w_ram_017f;//RO
		16'h0180: r_i2c_data_in <= w_ram_0180;//RO
		16'h0181: r_i2c_data_in <= w_ram_0181;//RO
		16'h0182: r_i2c_data_in <= w_ram_0182;//RO


		16'h001b: r_i2c_data_in <= r_reg_001b;//RW	
		16'h001c: r_i2c_data_in <= r_reg_001c;//RW
		16'h001d: r_i2c_data_in <= r_reg_001d;//RW
		16'h001e: r_i2c_data_in <= r_reg_001e;//RW
		16'h0026: r_i2c_data_in <= r_reg_0026;//RW
		16'h0033: r_i2c_data_in <= r_reg_0033;//RW
		16'h0034: r_i2c_data_in <= r_reg_0034;//RW
		16'h0035: r_i2c_data_in <= r_reg_0035;//RW
		
		16'h0123: r_i2c_data_in <= r_reg_0123;//RW
		16'h0124: r_i2c_data_in <= r_reg_0124;//RW
		16'h0125: r_i2c_data_in <= r_reg_0125;//RW
		16'h0126: r_i2c_data_in <= r_reg_0126;//RW
		16'h0127: r_i2c_data_in <= r_reg_0127;//RW
		16'h0128: r_i2c_data_in <= r_reg_0128;//RW
		16'h0129: r_i2c_data_in <= r_reg_0129;//RW
		16'h012a: r_i2c_data_in <= r_reg_012a;//RW
		16'h012b: r_i2c_data_in <= r_reg_012b;//RW
		16'h012c: r_i2c_data_in <= r_reg_012c;//RW
		16'h012d: r_i2c_data_in <= r_reg_012d;//RW
		16'h012e: r_i2c_data_in <= r_reg_012e;//RW
		16'h012f: r_i2c_data_in <= r_reg_012f;//RW
		16'h0130: r_i2c_data_in <= r_reg_0130;//RW
		16'h0131: r_i2c_data_in <= r_reg_0131;//RW
		16'h0132: r_i2c_data_in <= r_reg_0132;//RW
		16'h0183: r_i2c_data_in <= r_reg_0183;//RW
		16'h0184: r_i2c_data_in <= r_reg_0184;//RW
		16'h0185: r_i2c_data_in <= r_reg_0185;//RW
		16'h0186: r_i2c_data_in <= r_reg_0186;//RW
		

	default: r_i2c_data_in <= 8'h00;
	endcase
	end
end
 

///////////////////////////////////////////////////////////////////////
//write data to cpld
///////////////////////////////////////////////////////////////////////
//0x0006
always@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n)  begin
        r_reg_0006  <=8'h55;
    end
    else if((w_WR==1'b0)&&(w_i2c_command==16'h0006) && w_data_vld_pos)  begin
        r_reg_0006  <= ~w_i2c_data_out;
    end
end

//0x001b
always@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n)  begin
        r_reg_001b  <=8'h00;
    end
    else if((w_WR==1'b0)&&(w_i2c_command==16'h001b) && w_data_vld_pos)  begin
        r_reg_001b  <= w_i2c_data_out;
    end
end

//0x001c
always@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n)  begin
        r_reg_001c  <=8'h00;
    end
    else if((w_WR==1'b0)&&(w_i2c_command==16'h001c) && w_data_vld_pos)  begin
        r_reg_001c  <= w_i2c_data_out;
    end
end

//0x001d
always@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n)  begin
        r_reg_001d  <=8'h00;
    end
    else if((w_WR==1'b0)&&(w_i2c_command==16'h001d) && w_data_vld_pos)  begin
        r_reg_001d  <= w_i2c_data_out;
    end
end

//0x001e
always@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n)  begin
        r_reg_001e  <=8'hc0;
    end
    else if((w_WR==1'b0)&&(w_i2c_command==16'h001e) && w_data_vld_pos)  begin
        r_reg_001e  <= w_i2c_data_out;
    end
end

//0x0026
always@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n)  begin
        r_reg_0026  <=8'hff;
    end
    else if((w_WR==1'b0)&&(w_i2c_command==16'h0026) && w_data_vld_pos)  begin
        r_reg_0026  <= w_i2c_data_out;
    end
end

//0x0033
always@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n)  begin
        r_reg_0033  <=8'h00; //2024-11-19 8'h00 --> 8'hff
    end
    else if((w_WR==1'b0)&&(w_i2c_command==16'h0033) && w_data_vld_pos)  begin
        r_reg_0033  <= w_i2c_data_out;
    end
end

//0x0034
always@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n)  begin
        r_reg_0034  <=8'h00;
    end
    else if((w_WR==1'b0)&&(w_i2c_command==16'h0034) && w_data_vld_pos)  begin
        r_reg_0034  <= w_i2c_data_out;
    end
end

//0x0035
always@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n)  begin
        r_reg_0035  <=8'hff;
    end
    else if((w_WR==1'b0)&&(w_i2c_command==16'h0035) && w_data_vld_pos)  begin
        r_reg_0035  <= w_i2c_data_out;
    end
end

//0x0123
always@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n)  begin
        r_reg_0123  <=8'h00;
    end
    else if((w_WR==1'b0)&&(w_i2c_command==16'h0123) && w_data_vld_pos)  begin
        r_reg_0123  <= w_i2c_data_out;
    end
end

//0x0124
always@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n)  begin
        r_reg_0124  <=8'h00;
    end
    else if((w_WR==1'b0)&&(w_i2c_command==16'h0124) && w_data_vld_pos)  begin
        r_reg_0124  <= w_i2c_data_out;
    end
end

//0x0125
always@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n)  begin
        r_reg_0125  <=8'h00;
    end
    else if((w_WR==1'b0)&&(w_i2c_command==16'h0125) && w_data_vld_pos)  begin
        r_reg_0125  <= w_i2c_data_out;
    end
end

//0x0126
always@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n)  begin
        r_reg_0126  <=8'h00;
    end
    else if((w_WR==1'b0)&&(w_i2c_command==16'h0126) && w_data_vld_pos)  begin
        r_reg_0126  <= w_i2c_data_out;
    end
end

//0x0127
always@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n)  begin
        r_reg_0127  <=8'h00;
    end
    else if((w_WR==1'b0)&&(w_i2c_command==16'h0127) && w_data_vld_pos)  begin
        r_reg_0127  <= w_i2c_data_out;
    end
end

//0x0128
always@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n)  begin
        r_reg_0128  <=8'h00;
    end
    else if((w_WR==1'b0)&&(w_i2c_command==16'h0128) && w_data_vld_pos)  begin
        r_reg_0128  <= w_i2c_data_out;
    end
end

//0x0129
always@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n)  begin
        r_reg_0129  <=8'h00;
    end
    else if((w_WR==1'b0)&&(w_i2c_command==16'h0129) && w_data_vld_pos)  begin
        r_reg_0129  <= w_i2c_data_out;
    end
end

//0x012a
always@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n)  begin
        r_reg_012a  <=8'h00;
    end
    else if((w_WR==1'b0)&&(w_i2c_command==16'h012a) && w_data_vld_pos)  begin
        r_reg_012a  <= w_i2c_data_out;
    end
end

//0x012b
always@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n)  begin
        r_reg_012b  <=8'h00;
    end
    else if((w_WR==1'b0)&&(w_i2c_command==16'h012b) && w_data_vld_pos)  begin
        r_reg_012b  <= w_i2c_data_out;
    end
end

//0x012c
always@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n)  begin
        r_reg_012c  <=8'h00;
    end
    else if((w_WR==1'b0)&&(w_i2c_command==16'h012c) && w_data_vld_pos)  begin
        r_reg_012c  <= w_i2c_data_out;
    end
end

//0x012d
always@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n)  begin
        r_reg_012d  <=8'h00;
    end
    else if((w_WR==1'b0)&&(w_i2c_command==16'h012d) && w_data_vld_pos)  begin
        r_reg_012d  <= w_i2c_data_out;
    end
end

//0x012e
always@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n)  begin
        r_reg_012e  <=8'h00;
    end
    else if((w_WR==1'b0)&&(w_i2c_command==16'h012e) && w_data_vld_pos)  begin
        r_reg_012e  <= w_i2c_data_out;
    end
end

//0x012f
always@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n)  begin
        r_reg_012f  <=8'h00;
    end
    else if((w_WR==1'b0)&&(w_i2c_command==16'h012f) && w_data_vld_pos)  begin
        r_reg_012f  <= w_i2c_data_out;
    end
end

//0x0130
always@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n)  begin
        r_reg_0130  <=8'h00;
    end
    else if((w_WR==1'b0)&&(w_i2c_command==16'h0130) && w_data_vld_pos)  begin
        r_reg_0130  <= w_i2c_data_out;
    end
end

//0x0131
always@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n)  begin
        r_reg_0131  <=8'h00;
    end
    else if((w_WR==1'b0)&&(w_i2c_command==16'h0131) && w_data_vld_pos)  begin
        r_reg_0131  <= w_i2c_data_out;
    end
end

//0x0132
always@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n)  begin
        r_reg_0132  <=8'h00;
    end
    else if((w_WR==1'b0)&&(w_i2c_command==16'h0132) && w_data_vld_pos)  begin
        r_reg_0132  <= w_i2c_data_out;
    end
end

//0x0183
always@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n)  begin
        r_reg_0183  <=8'h00;
    end
    else if((w_WR==1'b0)&&(w_i2c_command==16'h0183) && w_data_vld_pos)  begin
        r_reg_0183  <= w_i2c_data_out;
    end
end

//0x0184
always@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n)  begin
        r_reg_0184  <=8'h00;
    end
    else if((w_WR==1'b0)&&(w_i2c_command==16'h0184) && w_data_vld_pos)  begin
        r_reg_0184  <= w_i2c_data_out;
    end
end

//0x0185
always@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n)  begin
        r_reg_0185  <=8'hff;
    end
    else if((w_WR==1'b0)&&(w_i2c_command==16'h0185) && w_data_vld_pos)  begin
        r_reg_0185  <= w_i2c_data_out;
    end
end

//0x0186
always@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n)  begin
        r_reg_0186  <=8'hff;
    end
    else if((w_WR==1'b0)&&(w_i2c_command==16'h0186) && w_data_vld_pos)  begin
        r_reg_0186  <= w_i2c_data_out;
    end
end

///////////////////////////////////////////////////////////////////////
//i2c slave
///////////////////////////////////////////////////////////////////////

i2c_slave_bmc  #(
.DLY_LEN                 (DLY_LEN)      //3   //24.18MHz,330ns
)i2c_slave_bmc_u0(
.i_rst_n                 (i_rst_n    ), 
.i_clk                   (i_clk      ),
.i_1ms_clk               (i_1ms_clk  ),
.i_rst_i2c_n             (i_rst_i2c_n),

.i_scl                   (i_scl         ),
.io_sda                  (io_sda        ),

.i_i2c_address           (7'h10         ),
.o_i2c_start             (w_i2c_start   ),
.o_WR                    (w_WR          ),
.o_data_vld_pos          (w_data_vld_pos),
.o_i2c_command           (w_i2c_command ),
.i_i2c_data_in           (r_i2c_data_in),
.o_i2c_data_out          (w_i2c_data_out)
); 


	
	
	
endmodule 