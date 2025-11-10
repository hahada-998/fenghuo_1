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
input   wire  [7:0] i_product_id                            ,//addr 0x0000
input   wire  [7:0] i_vender_id                              ,//addr 0x0001
input   wire  [7:0] i_board_id                                ,//addr 0x0002
input   wire  [7:0] i_pcb_version                          ,//addr 0x0003
input   wire  [7:0] i_bom_id                                    ,//addr 0x0004
input   wire  [7:0] i_cpld_version                        ,//addr 0x0005
output wire  [7:0] o_test_reg                                ,//addr 0x0006
input   wire  [7:0] i_year                                        ,//addr 0x0007
input   wire  [7:0] i_month                                      ,//addr 0x0008
input   wire  [7:0] i_day                                          ,//addr 0x0009
input   wire  [7:0] i_nc_pin                                    ,//addr 0x000a bit0
input   wire  [7:0] i_cpld_compa_version            ,//addr 0x000b
input   wire  [7:0] i_cpld_debug_version            ,//addr 0x000c
//PSU--0x000D
input  wire        i_PS1_PRSNT                      , //addr 0x000D bit7
input  wire        i_PS2_PRSNT                      , //addr 0x000D bit6
input  wire        i_PS3_PRSNT                      , //addr 0x000D bit5
input  wire        i_PS4_PRSNT                      , //addr 0x000D bit4
input  wire        i_PS1_ACFAIL                    , //addr 0x000D bit3
input  wire        i_PS2_ACFAIL                    , //addr 0x000D bit2
input  wire        i_PS1_DCOK                        , //addr 0x000D bit1
input  wire        i_PS2_DCOK                        , //addr 0x000D bit0
//PSU--0x000E
input  wire        i_PS1_ALERT                      , //addr 0x000E bit7
input  wire        i_PS2_ALERT                      , //addr 0x000E bit6
input  wire        i_PS1_P12V_ON                  , //addr 0x000E bit5
input  wire        i_PS2_P12V_ON                  , //addr 0x000E bit4
input  wire        i_PS_OFF                            , //addr 0x000E bit3
input  wire        i_DUAL_EN                          , //addr 0x000E bit2
input  wire        i_P12V_DROOP                    , //addr 0x000E bit1
input  wire        i_P12V_STBY_DROOP          , //addr 0x000E bit0
//P12V --0x000F
input  wire        i_P12V_DISCHARGE            , //addr 0x000F bit7


//POL PGD --0x0010
input  wire        i_PGD_P5V_MB                               , //addr 0x0010 bit7
input  wire        i_PGD_P5V_STBY_MB                     , //addr 0x0010 bit6
input  wire        i_PGD_P3V3_STBY_MB                   , //addr 0x0010 bit5
input  wire        i_PGD_P3V3_STBY_B_MB               , //addr 0x0010 bit4
input  wire        i_PGD_P1V8_PCH_STBY_MB           , //addr 0x0010 bit3
input  wire        i_PGD_P1V2_STBY_MB                   , //addr 0x0010 bit2
input  wire        i_PGD_P1V05_PCH_STBY_MB         , //addr 0x0010 bit1
input  wire        i_PGD_PVNN_PCH_STBY_MB           , //addr 0x0010 bit0
//POL OC --0x0011
input  wire        i_USB_INNER_OVERCUR3               , //addr 0x0011 bit7
input  wire        i_USB2_LCD_OC_N                         , //addr 0x0011 bit6

//POL PGD --0x0012
input  wire        i_PAL_P5V_EN_R_MB               , //addr 0x0012 bit7
input  wire        i_PAL_P5V_STBY_EN_R_MB          , //addr 0x0012 bit6
input  wire        i_P5V_STBY_USB_EN        , //addr 0x0012 bit5
input  wire        i_P5V_EN         , //addr 0x0012 bit4
input  wire        i_ncsi_main_pwr_en             , //addr 0x0012 bit3
input  wire        i_ncsi_aux_pwr_en        , //addr 0x0012 bit2
input  wire        i_PAL_PVNN_STBY_EN_R_MB         , //addr 0x0012 bit1
input  wire        i_PAL_EN_PWM_CTRL_VCC_R_MB      , //addr 0x0012 bit0

//0x0013
output wire        o_BMC_JTAG_MUX_S                  , //addr 0x0013 bit7  //default 1


//CPU0 PGD --0x0020
input  wire        i_pwrgd_vdd_33_stby0	       , //addr 0x0020 bit7
input  wire        i_pwrgd_vdd_18_stby0	       , //addr 0x0020 bit6
input  wire        i_pal_pgd_p0_vdd_core_1     , //addr 0x0020 bit5
input  wire        i_pal_pgd_p0_vdd_core_0     , //addr 0x0020 bit4
input  wire        i_pal_pgd_p0_vdd_soc_0       , //addr 0x0020 bit3
input  wire        i_pal_pgd_p0_vddio	       , //addr 0x0020 bit2
input  wire        i_pal_pgd_p0_vdd_sus_0       , //addr 0x0020 bit1
input  wire        i_pal_cpu_sys_pwrok             , //addr 0x0020 bit0

//CPU0 ALERT --0x0021
input  wire        i_p0_pwrgd_out_r	           , //addr 0x0021 bit7
input  wire        i_p0_pwrok_r		           , //addr 0x0021 bit6
input  wire        i_p0_pwr_good_r	           , //addr 0x0021 bit5

//CPU0 PWR EN --0x0022
input  wire        i_p0_vddc_en			        , //addr 0x0022 bit7
input  wire        i_p0_vdd_18_stby_en	        , //addr 0x0022 bit6
input  wire        i_pal_p0_vdd_11_sus_en	, //addr 0x0022 bit5
input  wire        i_pal_p0_vddio_en_r	        , //addr 0x0022 bit4
input  wire        i_pal_p0_vdd_soc_en	        , //addr 0x0022 bit3
input  wire        i_pal_p0_vdd_core_0_en_r    , //addr 0x0022 bit2
input  wire        i_pal_p0_vdd_core_1_en_r    , //addr 0x0022 bit1

//CPU1 PGD --0x0023
input  wire        i_pwrgd_vdd_18_stby1	       , //addr 0x0023 bit7
input  wire        i_pwrgd_vdd_33_stby1	       , //addr 0x0023 bit6
input  wire        i_pal_pgd_p1_vdd_core_1     , //addr 0x0023 bit5
input  wire        i_pal_pgd_p1_vdd_core_0     , //addr 0x0023 bit4
input  wire        i_pal_pgd_p1_vdd_soc_0       , //addr 0x0023 bit3
input  wire        i_pal_pgd_p1_vddio	       , //addr 0x0023 bit2
input  wire        i_pal_pgd_p1_vdd_sus_0       , //addr 0x0023 bit1

//CPU1 ALERT --0x0024
input  wire        i_p1_pwrgd_out_r	            , //addr 0x0024 bit7
input  wire        i_p1_pwrok_r		            , //addr 0x0024 bit6
input  wire        i_p1_pwr_good_r	            , //addr 0x0024 bit5

//CPU0 PWR EN --0x0025
input  wire        i_p1_vdd_18_stby_en	        , //addr 0x0025 bit7
input  wire        i_p1_vddc_en			        , //addr 0x0025 bit6
input  wire        i_pal_p1_vdd_11_sus_en	, //addr 0x0025 bit5
input  wire        i_pal_p1_vddio_en_r	        , //addr 0x0025 bit4
input  wire        i_pal_p1_vdd_soc_en	        , //addr 0x0025 bit3
input  wire        i_pal_p1_vdd_core_0_en_r    , //addr 0x0025 bit2
input  wire        i_pal_p1_vdd_core_1_en_r    , //addr 0x0025 bit1

//CPU PRSNT --0x0030
input  wire        i_PAL_CPU0_PRSNT_N              , //addr 0x0030 bit7
input  wire        i_PAL_CPU1_PRSNT_N              , //addr 0x0030 bit6

//CPU PROC_ID --0x0031

//CPU ERR --0x0032
input  wire        i_P0_SMERR_N                , //addr 0x0032 bit7
input  wire        i_P1_SMERR_N                , //addr 0x0032 bit6
input  wire        i_FM_CPU_SMERR_LVC3_N_R     , //addr 0x0032 bit5
//CPU THERM --0x0033
input  wire        i_PAL_CPU0_MEMHOT_OUT_N        , //addr 0x0033 bit7
input  wire        i_PAL_CPU0_MEMTRIP_N              , //addr 0x0033 bit6
input  wire        i_PAL_CPU0_THERMTRIP_N          , //addr 0x0033 bit5
input  wire        i_PAL_CPU0_PROCHOT_N              , //addr 0x0033 bit4 
input  wire        i_PAL_CPU1_MEMHOT_OUT_N        , //addr 0x0033 bit3 
input  wire        i_PAL_CPU1_MEMTRIP_N              , //addr 0x0033 bit2
input  wire        i_PAL_CPU1_THERMTRIP_N          , //addr 0x0033 bit1
input  wire        i_PAL_CPU1_PROCHOT_N              , //addr 0x0033 bit0 

//pwr_flt_clr --0x0034
output wire        o_bmc_clr_tmout_n                  , //addr 0x0034 bit7  //default 1
output wire        o_pal_cpu0_forcepr_r            , //addr 0x0034 bit6  //default 0
output wire        o_pal_cpu1_forcepr_r            , //addr 0x0034 bit5  //default 0
output wire        o_clear_register                    , //addr 0x0034 bit4  //default 0

//pwr_flt_code --0x0035
input  wire  [7:0] i_pwr_flt_code                   , //addr 0x0035  //default 8'h00

/*CPLD System Register*/
//btn_press_flag --0x0050
input  wire        i_btn_press_flag          , //addr 0x0050 bit7
input  wire        i_slps5_sts                    , //addr 0x0050 bit6
input  wire        i_slps3_sts                    , //addr 0x0050 bit5

//btn_evt --0x0051
input  wire        i_sbtn_pwron_evt                , //addr 0x0051 bit7
input  wire        i_lbtn_pwrdown_evt            , //addr 0x0051 bit6
input  wire        i_sbtn_sysrst_evt              , //addr 0x0051 bit5

//bmc_clr_btn_evt --0x0052
output wire        o_bmc_clr_sbtn_n                , //addr 0x0052 bit7
output wire        o_bmc_clr_lbtn_n                , //addr 0x0052 bit6
output wire        o_bmc_clr_sbtn_sys_n        , //addr 0x0052 bit5

//bmc_btn_ctl --0x0053
output wire        o_pwr_btn_lock                        , //addr 0x0053 bit7
output wire        o_bmc_power_soft_ctl            , //addr 0x0053 bit6
output wire        o_bmc_lbtn_pwrdown_ctl        , //addr 0x0053 bit5
output wire        o_bmc_sbtn_pwron_ctl            , //addr 0x0053 bit4
output wire        o_bmc_sbtn_sysrst_ctl          , //addr 0x0053 bit3

//bmc_btn_done --0x0054
input  wire        i_bmc_power_soft_done           , //addr 0x0054 bit7
input  wire        i_bmc_lbtn_pwrdown_done       , //addr 0x0054 bit6
input  wire        i_bmc_sbtn_pwron_done           , //addr 0x0054 bit5
input  wire        i_bmc_sbtn_sysrst_done         , //addr 0x0054 bit4

//bmc_uid --0x0056
input  wire        i_pal_bmcuid_button             , //addr 0x0056 bit7  //default 0


//pwr_fault    --0x0065
input  wire        i_p1_vr_i2c_alert_n        , //addr 0x0065 bit7
input  wire        i_p0_vr_i2c_alert_n        , //addr 0x0065 bit5
// input  wire        i_cpu0_vr_fault_pvccd           , //addr 0x0065 bit4
// input  wire        i_cpu0_vr_fault_pvccin          , //addr 0x0065 bit3
//0x0066
input  wire        i_P0_MCIOP0A_NVME0_PRSNT_N_R   ,//addr 0x0066 bit7
input  wire        i_P0_MCIOP0C_NVME0_PRSNT_N_R   ,//addr 0x0066 bit6
input  wire        i_P0_MCIOP0A_NVME1_PRSNT_N_R   ,//addr 0x0066 bit5
input  wire        i_P0_MCIOP0C_NVME1_PRSNT_N_R   ,//addr 0x0066 bit4

input  wire        i_pal_m2_0_prsnt_n             , //addr 0x006a bit7  
input  wire        i_pal_m2_1_prsnt_n             , //addr 0x006a bit6  
input  wire        i_pal_bp1_prsnt_n               , //addr 0x006a bit5
input  wire        i_pal_bp2_prsnt_n               , //addr 0x006a bit4
input  wire        i_pal_bp3_prsnt_n               , //addr 0x006a bit3
input  wire        i_pal_bp4_prsnt_n               , //addr 0x006a bit2
input  wire        i_pal_bp5_prsnt_n               , //addr 0x006a bit1
input  wire        i_pal_bp6_prsnt_n               , //addr 0x006a bit0

//u68_data5      --0x006b
input  wire        i_pal_bp8_prsnt_n               , //addr 0x006b bit7

//gpu_throttle_n--0x006c
output wire        o_p0_mciop0a_gpu_throttle_n_r    , //addr 0x006c bit7     //default 0
output wire        o_p0_mciop0c_gpu_throttle_n_r	   , //addr 0x006c bit6     //default 0

//scpld_data --0x0070
input  wire        i_p1_pcie_wake_n_r              , //addr 0x0070 bit3
input  wire        i_p0_pcie_wake_n_r              , //addr 0x0070 bit2

output wire        o_i3c_mux_en                       , //addr 0x0073 bit7  //default 0
output wire        o_i3c_remote_cs                 , //addr 0x0073 bit4  //default 0

//EEP WR--0x0074	
output wire        o_eeprom_wp                         , //addr 0x0074 bit7	//default 0 
output wire        o_scaled_bat_test_en_r   , //addr 0x0074 bit6	//default 0 
output wire        o_bmc_nmi_event                 , //addr 0x0074 bit5	//default 0
output wire        o_rtc_senor_sw                   , //addr 0x0074 bit4	//default 0

//pcycle--0x0076
output wire        o_aux_pcycle                    , //addr 0x0076 bit7  //default 0
output wire        o_usb_sw_s                      , //addr 0x0076 bit6  //default 0

output wire        o_p0_vpp_9545_4_rst_n                , //addr 0x0077 bit7  //default 1
output wire        o_p0_vpp_9545_5_rst_n                , //addr 0x0077 bit6  //default 1
output wire        o_p0_vpp_9545_6_rst_n                , //addr 0x0077 bit5  //default 1

output wire        o_bmc_i2c5_9548_rst_n	               , //addr 0x0078 bit7  //default 1
output wire        o_bmc_i2c4_9548_1_rst_n            , //addr 0x0078 bit6  //default 1
output wire        o_bmc_i2c4_9548_2_rst_n            , //addr 0x0078 bit5  //default 1
output wire        o_bmc_i2c4_9548_3_rst_n            , //addr 0x0078 bit4  //default 1
output wire        o_bmc_i2c4_9548_4_rst_n            , //addr 0x0078 bit3  //default 1
output wire        o_p0_vpp_9545_1_rst_n	               , //addr 0x0078 bit2  //default 1
output wire        o_p0_vpp_9545_2_rst_n	               , //addr 0x0078 bit1  //default 1
output wire        o_p0_vpp_9545_3_rst_n	               , //addr 0x0078 bit0  //default 1

input  wire  [7:0] i_switch_mode                   , //addr 0x0089    //default 0xff
output wire        o_164_mr_n                      ,  //addr 0x008a bit7 //2025-1-16 del

input  wire        i_pch_bios_post_cmplt_n         , //addr 0x008b bit7

output wire  [7:0] o_164_test_data                 , //addr 0x008c
input  wire  [7:0] i_switch2_mode                   , //addr 0x008d    //default 0xff


input  wire        i_LEAKAGE0_PRSNT_N               ,  //0x008e bit7
input  wire        i_BREAK_DET_DO_N                   ,  //0x008e bit6
input  wire        i_LEAKAGE_DET_DO_N               ,  //0x008e bit5
input  wire        i_LEAKAGE_PRSNT1_N               ,  //0x008e bit4
input  wire        i_BREAK_DET1_DO_N                 ,  //0x008e bit3
input  wire        i_LEAKAGE_DET1_DO_N             ,  //0x008e bit2

output wire        o_leakage_int_mask              ,  //0x008f bit7  //2024-5-25 add //default 1

input    wire  i_p0_spd_host_ctrl_n,			//addr 0x0090 bit6

//////////////////////////////////0x00C0-0x00D0 for FIX REG/////////////////////////////////////////////////////////////////////////////
input  wire  [7:0] i_PRODUCT_LINE_C2	           , //addr 0x00C2
input  wire  [7:0] i_PRODUCT_GEN_ID_C3             , //addr 0x00C3
input  wire  [7:0] i_SERVER_ID_C5                  , //addr 0x00C5
input  wire  [7:0] i_BOARD_ID_C6                   , //addr 0x00C6

//////////////////////////////////0x00C0-0x00D0 for FIX REG/////////////////////////////////////////////////////////////////////////////
input   wire  i_power_alarm_flag,             //addr 0x0200 bit0

input   wire  i_stb_pwron_tmout_fail,         //addr 0x0201 bit7 
output wire  o_bmc_clr_stby_tmout_n,         //addr 0x0201 bit7
input   wire  i_stb_pwrdown_ukwn_fail,       //addr 0x0201 bit6
output wire  o_bmc_clr_stby_pwr_drop_n,   //addr 0x0201 bit6
input   wire  i_poweron_tmout_fail,             //addr 0x0201 bit5
output wire  o_bmc_clr_core_tmout_n,         //addr 0x0201 bit5
input   wire  i_powerdown_ukwn_fail,           //addr 0x0201 bit4
input   wire  i_st_aux_fail_recovery   ,      //addr 0x0201 bit3
input   wire  i_system_pwr_sts,                     //addr 0x0201 bit0

input    wire  [7:0]i_power_on_fail_err_code,      //addr 0x0032 //202
output  wire  o_power_on_fail_err_code_clr,        //addr 0x0032
input    wire  [7:0]i_power_down_fail_err_code,  //addr 0x0033//203
output  wire  o_power_down_fail_err_code_clr,    //addr 0x0033
input   wire  [7:0] i_power_seq_state_machine,	//addr 0x0035 //205
input   wire  [7:0] i_power_seq_fault_latch	,	//addr 0x0036   //206

input   wire  i_p12v_stby_fault_det			,//addr 0x0091 bit7 //206
input   wire  i_p5v_stby_fault_det				,//addr 0x0091 bit6
input   wire  i_grp_b_p0_33_s5_fault_det		,//addr 0x0091 bit3
input   wire  i_grp_b_p1_33_s5_fault_det		,//addr 0x0091 bit2
input   wire  i_grp_b_p0_18_s5_fault_det		,//addr 0x0091 bit1
input   wire  i_grp_b_p1_18_s5_fault_det		,//addr 0x0091 bit0

input   wire  i_p5v_fault_det					,//addr 0x0092 bit6 //207
input   wire  i_p12v_efuse_fault_det			,//addr 0x0092 bit5
input   wire  i_p12v_ssd_efuse_fault_det		,//addr 0x0092 bit4
input   wire  i_p12v_p0_dimm_fault_det			,//addr 0x0092 bit3
input   wire  i_p12v_p1_dimm_fault_det			,//addr 0x0092 bit2
input   wire  i_grp_c_p0_fault_det				,//addr 0x0092 bit1
input   wire  i_grp_c_p1_fault_det				,//addr 0x0092 bit0
  
input   wire  i_grp_d_vddio_p0_fault_det		,//addr 0x0093 bit7 //208
input   wire  i_grp_d_vddio_p1_fault_det		,//addr 0x0093 bit6   
input   wire  i_grp_d_soc_p0_fault_det			,//addr 0x0093 bit5 
input   wire  i_grp_d_soc_p1_fault_det			,//addr 0x0093 bit4  
input   wire  i_grp_d_p0_vddcore0_fault_det	,//addr 0x0093 bit3
input   wire  i_grp_d_p1_vddcore0_fault_det	,//addr 0x0093 bit2 
input   wire  i_grp_d_p0_vddcore1_fault_det	,//addr 0x0093 bit1
input   wire  i_grp_d_p1_vddcore1_fault_det	,//addr 0x0093 bit0   
  
input  wire  i_p1_vdd_core_1_ocp_n,           //addr 0x009D bit7    //209
input  wire  i_p1_vdd_core_0_ocp_n,           //addr 0x009D bit6
input  wire  i_p1_vddio_ocp_n,                //addr 0x009D bit5
input  wire  i_p1_efuse_fault_n,              //addr 0x009D bit4
input  wire  i_p0_vdd_core_1_ocp_n,           //addr 0x009D bit3
input  wire  i_p0_vdd_core_0_ocp_n,           //addr 0x009D bit2
input  wire  i_p0_vddio_ocp_n,                //addr 0x009D bit1
// input  wire  i_p0_efuse_fault_n,              //addr 0x009D bit0

// input  wire  i_rtc_sqw,                       //addr 0x009E bit7  
output wire  o_pal_rst_rtc, // addr 0x009E bit7             
input  wire  i_rtc_inta_n,                    //addr 0x009E bit6
// input  wire  i_p0_u112_alert_od_r_n,          //addr 0x009E bit5
input  wire  i_p1_i3c_apml_alert_n,           //addr 0x009E bit4
input  wire  i_p0_i3c_apml_alert_n,           //addr 0x009E bit3
input  wire  i_clk_gen_en_r_n,                //addr 0x009E bit2
input  wire  i_clk_gen_alert_r_n,             //addr 0x009E bit1
// input  wire  i_thermsensor_alert1_n,          //addr 0x009E bit0

output  wire  o_force_allpwron_ctl,           //addr 0x00A0 bit0
output  wire  o_fm_pld_db800_3_clks_dev_en,   //addr 0x00D1 bit6
output  wire  o_jtag_cpld_bmc_ntrst_r,        //addr 0x0105 bit4
output  wire  o_bmc_warm_reset_ctl,           //addr 0x0130 bit5
output  wire  o_sys_debug_mode,               //addr 0x02C0 bit0 ;20220106 c00268;idms:202201040006


input   wire  i_p1_vdd_core_0_soc_rst_l_n,    //addr 0x0103 bit7
input   wire  i_p1_vdd_core_1_11_sus_rst_l_n, //addr 0x0103 bit6
input   wire  i_p1_vddio_rst_l_n,             //addr 0x0103 bit5
input   wire  i_p0_vddio_rst_l_n,             //addr 0x0103 bit4
input   wire  i_p0_vdd_core_0_soc_rst_l_n,    //addr 0x0103 bit3
input   wire  i_p0_vdd_core_1_11_sus_rst_l_n, //addr 0x0103 bit2
input   wire  i_cpu_sys_reset_r_n,            //addr 0x0103 bit1
input   wire  i_cpu_rsmrst_r_n,               //addr 0x0103 bit0

input    wire  i_cpu0_thermtrip ,              //addr 0x02A1 bit7 ;20220106 c00268;idms:202201040006
output  wire  o_cpu0_thermtrip_clr ,          //addr 0x02A1 bit7 ;20220106 c00268;idms:202201040006
input    wire  i_cpu1_thermtrip,               //addr 0x02A8 bit7
output  wire  o_cpu1_thermtrip_clr,           //addr 0x02A8 bit7 ;20220106 c00268;idms:202201040006

// output  wire  o_cpu0_prochot,                 //addr 0x02A2 bit2 c00268 rdc:3706081
// output  wire  o_cpu1_prochot,                 //addr 0x02A2 bit2 c00268 rdc:3706081

input   wire  i_dimm_alarm_flag,              //addr 0x0300 bit0

input   wire  i_cpu1_reset_n,					//addr 0x00F4 bit1
input   wire  i_cpu0_reset_n,					//addr 0x00F4 bit0

/*CPU ID Record Register*/
input   wire  i_p0_coretype2,                 //addr 0x02E0 bit6
input   wire  i_p0_coretype1,                 //addr 0x02E0 bit5
input   wire  i_p0_coretype0,                 //addr 0x02E0 bit4
input   wire  i_p0_sp5r4,                     //addr 0x02E0 bit3
input   wire  i_p0_sp5r3,                     //addr 0x02E0 bit2
input   wire  i_p0_sp5r2,                     //addr 0x02E0 bit1
input   wire  i_p0_sp5r1,                     //addr 0x02E0 bit0

input   wire  i_p1_coretype2,                 //addr 0x02E8 bit6
input   wire  i_p1_coretype1,                 //addr 0x02E8 bit5
input   wire  i_p1_coretype0,                 //addr 0x02E8 bit4
input   wire  i_p1_sp5r4,                     //addr 0x02E8 bit3
input   wire  i_p1_sp5r3,                     //addr 0x02E8 bit2
input   wire  i_p1_sp5r2,                     //addr 0x02E8 bit1
input   wire  i_p1_sp5r1,                     //addr 0x02E8 bit0


input    wire  i_p1_dimm_gl_pwrgd_fail_event		, //addr 0x0312 bit3
output  wire  o_p1_dimm_gl_pwrgd_fail_event_clr	, //addr 0x0312 bit3
input    wire  i_p1_dimm_af_pwrgd_fail_event		, //addr 0x0312 bit2
output  wire  o_p1_dimm_af_pwrgd_fail_event_clr	, //addr 0x0312 bit2
input    wire  i_p0_dimm_gl_pwrgd_fail_event		, //addr 0x0312 bit1
output  wire  o_p0_dimm_gl_pwrgd_fail_event_clr	, //addr 0x0312 bit1
input    wire  i_p0_dimm_af_pwrgd_fail_event		, //addr 0x0312 bit0
output  wire  o_p0_dimm_af_pwrgd_fail_event_clr	, //addr 0x0312 bit0

output wire  o_bmc_nmi_ctl                        , //addr 0x03A0 bit6 
input   wire  i_bmc_nmi_ctl                        , //addr 0x03A0 bit6 
output wire  o_clr_cmos_ctl                       , //addr 0x03A0 bit4 
input   wire  i_bmc_clr_cmos                       , //addr 0x03A0 bit4 



output wire  [7:0] o_espi_ram_1050                 , //addr 0x1050 //default 0xff  //2023-9-6 add 
output wire  [7:0] o_espi_ram_1051                 , //addr 0x1051 //default 0xff
output wire  [7:0] o_espi_ram_1052                 , //addr 0x1052 //default 0xff
output wire  [7:0] o_espi_ram_1053                 , //addr 0x1053 //default 0xff //2023-11-8 add 
output wire  [7:0] o_espi_ram_1054                 , //addr 0x1054 //default 0xff //2023-11-8 add 
input   wire  [7:0] i_espi_ram_1055                 , //addr 0x1055 //default 0xff
input   wire  [7:0] i_espi_ram_1056                 , //addr 0x1056 //default 0xff
input   wire  [7:0] i_espi_ram_1057                 , //addr 0x1057 //default 0xff //2023-11-8 add 
input   wire  [7:0] i_espi_ram_1058                    //addr 0x1058 //default 0xff //2023-11-8 add 

/*YRS36M2C4S RAM END */


);
////////////////////////////////////////////////////////////////////////
//for i2c slave
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
wire [7:0] w_ram_0000                                                        ;
wire [7:0] w_ram_0001                                                        ;
wire [7:0] w_ram_0002                                                        ;
wire [7:0] w_ram_0003                                                        ;
wire [7:0] w_ram_0004                                                        ;
wire [7:0] w_ram_0005                                                        ;
wire [7:0] w_ram_0007                                                        ;
wire [7:0] w_ram_0008                                                        ;
wire [7:0] w_ram_0009                                                        ;
wire [7:0] w_ram_000a                                                        ;
wire [7:0] w_ram_000b                                                        ;
wire [7:0] w_ram_000c                                                        ;
wire [7:0] w_ram_000d                                                        ;
wire [7:0] w_ram_000e                                                        ;
wire [7:0] w_ram_000f                                                        ;

wire [7:0] w_ram_0010                                                        ;
wire [7:0] w_ram_0011                                                        ;
wire [7:0] w_ram_0012                                                        ;

wire [7:0] w_ram_0020                                                        ;
wire [7:0] w_ram_0021                                                        ;
wire [7:0] w_ram_0022                                                        ;
wire [7:0] w_ram_0023                                                        ;
wire [7:0] w_ram_0024                                                        ;
wire [7:0] w_ram_0025                                                        ;

wire [7:0] w_ram_0030                                                        ;
// wire [7:0] w_ram_0031                                                        ;
wire [7:0] w_ram_0032                                                        ;
wire [7:0] w_ram_0033                                                        ;
wire [7:0] w_ram_0035                                                        ;

wire [7:0] w_ram_0050                                                        ;
wire [7:0] w_ram_0051                                                        ;
wire [7:0] w_ram_0054                                                        ;
wire [7:0] w_ram_0056                                                        ;
// wire [7:0] w_ram_0057                                                        ;
// wire [7:0] w_ram_0060                                                        ;
// wire [7:0] w_ram_0061                                                        ;
// wire [7:0] w_ram_0062                                                        ;
// wire [7:0] w_ram_0063                                                        ;
// wire [7:0] w_ram_0064                                                        ;
wire [7:0] w_ram_0065                                                        ;
wire [7:0] w_ram_0066                                                        ;
// wire [7:0] w_ram_0067                                                        ;
// wire [7:0] w_ram_0068                                                        ;
// wire [7:0] w_ram_0069                                                        ;
wire [7:0] w_ram_006a                                                        ;
wire [7:0] w_ram_006b                                                        ;

// wire [7:0] w_ram_006f                                                        ;
wire [7:0] w_ram_0070                                                        ;
// wire [7:0] w_ram_0071                                                        ;
// wire [7:0] w_ram_0075                                                        ;

// wire [7:0] w_ram_0077                                                        ;
// wire [7:0] w_ram_0078                                                        ;

// wire [7:0] w_ram_0079                                                        ;
// wire [7:0] w_ram_007a                                                        ;
// wire [7:0] w_ram_007b                                                        ;
// wire [7:0] w_ram_007c                                                        ;
// wire [7:0] w_ram_007d                                                        ;
// wire [7:0] w_ram_007e                                                        ;
// wire [7:0] w_ram_007f                                                        ;
// wire [7:0] w_ram_0080                                                        ;
// wire [7:0] w_ram_0081                                                        ;
// wire [7:0] w_ram_0082                                                        ;
// wire [7:0] w_ram_0083                                                        ;
// wire [7:0] w_ram_0084                                                        ;
// wire [7:0] w_ram_0085                                                        ;
// wire [7:0] w_ram_0086                                                        ;
// wire [7:0] w_ram_0087                                                        ;
// wire [7:0] w_ram_0088                                                        ;
wire [7:0] w_ram_0089                                                        ;
wire [7:0] w_ram_008b                                                        ;
wire [7:0] w_ram_0090                                                        ;
wire [7:0] w_ram_008d                                                        ;
wire [7:0] w_ram_008e                                                        ;

//////////////////////////////////0x00C0-0x00D0 for FIX REG/////////////////////////////////////////////////////////////////////////////
wire [7:0] w_ram_00C2                                                        ;
wire [7:0] w_ram_00C3                                                        ;
wire [7:0] w_ram_00C5                                                        ;
wire [7:0] w_ram_00C6                                                        ;

//////////////////////////////////0x00C0-0x00D0 for FIX REG/////////////////////////////////////////////////////////////////////////////

wire [7:0] w_ram_0200                                                        ;
wire [7:0] w_ram_0201                                                        ;
wire [7:0] w_ram_0202                                                        ;
wire [7:0] w_ram_0203                                                        ;
wire [7:0] w_ram_0205                                                        ;
wire [7:0] w_ram_0206                                                        ;
wire [7:0] w_ram_0091                                                        ;
wire [7:0] w_ram_0092                                                        ;
wire [7:0] w_ram_0093                                                        ;
wire [7:0] w_ram_009d                                                        ;
wire [7:0] w_ram_009e                                                        ;
wire [7:0] w_ram_00f4                                                        ;
wire [7:0] w_ram_0103                                                        ;
wire [7:0] w_ram_020d                                                        ;
wire [7:0] w_ram_0300                                                        ;

wire [7:0] w_ram_02e0                                                        ;
wire [7:0] w_ram_02e8                                                        ;
wire [7:0] w_ram_0312                                                        ;
// wire [7:0] w_ram_0117                                                        ;
// wire [7:0] w_ram_0118                                                        ;
// wire [7:0] w_ram_0119                                                        ;
// wire [7:0] w_ram_011a                                                        ;
// wire [7:0] w_ram_011b                                                        ;

// wire [7:0] w_ram_011c                                                        ;
// wire [7:0] w_ram_011d                                                        ;
// wire [7:0] w_ram_011e                                                        ;
// wire [7:0] w_ram_011f                                                        ;
// wire [7:0] w_ram_0120                                                        ;
// wire [7:0] w_ram_0121                                                        ;
// wire [7:0] w_ram_0122                                                        ;
// wire [7:0] w_ram_0123                                                        ;

// wire [7:0] w_ram_0124                                                        ;
// wire [7:0] w_ram_0125                                                        ;
// wire [7:0] w_ram_0126                                                        ;
// wire [7:0] w_ram_0127                                                        ;
// wire [7:0] w_ram_0128                                                        ;
// wire [7:0] w_ram_0129                                                        ;
// wire [7:0] w_ram_012a                                                        ;
// wire [7:0] w_ram_012b                                                        ;

// wire [7:0] w_ram_012d                                                        ;
// wire [7:0] w_ram_012e                                                        ;
// wire [7:0] w_ram_012f                                                        ;
// wire [7:0] w_ram_0130                                                        ;
// wire [7:0] w_ram_0131                                                        ;
// wire [7:0] w_ram_0132                                                        ;

// wire [7:0] w_ram_0133                                                        ;

wire [7:0] w_ram_1055                                                        ;
wire [7:0] w_ram_1056                                                        ;
wire [7:0] w_ram_1057                                                        ;
wire [7:0] w_ram_1058                                                        ;

////////////////////////////////////////////////////////////////////////////////////
//raed & write  register
////////////////////////////////////////////////////////////////////////////////////
reg [7:0] r_reg_0006                                                         ;
reg [7:0] r_reg_0013                                                         ;
reg [7:0] r_reg_0034                                                         ;
reg [7:0] r_reg_0052                                                         ;
reg [7:0] r_reg_0053                                                         ;
// reg [7:0] r_reg_0055                                                         ;
reg [7:0] r_reg_006c                                                         ;
// reg [7:0] r_reg_006d                                                         ;
// reg [7:0] r_reg_006e                                                         ;
// reg [7:0] r_reg_0072                                                         ;
reg [7:0] r_reg_0073                                                         ;
reg [7:0] r_reg_0074                                                         ;
reg [7:0] r_reg_0076                                                         ;
reg [7:0] r_reg_0077                                                         ;
reg [7:0] r_reg_0078                                                         ;

reg [7:0] r_reg_008a                                                         ;
reg [7:0] r_reg_008c                                                         ;
reg [7:0] r_reg_008f                                                         ;
// reg [7:0] r_reg_0079                                                         ;
reg [7:0] r_reg_0201                                                         ;
reg [7:0] r_reg_0202                                                         ;
reg [7:0] r_reg_0203                                                         ;
reg [7:0] r_reg_00a0                                                         ;
reg [7:0] r_reg_00d1                                                         ;
reg [7:0] r_reg_0105                                                         ;
reg [7:0] r_reg_0130                                                         ;
reg [7:0] r_reg_02c0                                                         ;


reg [7:0] r_reg_020d                                                         ;
// reg [7:0] r_reg_020e                                                         ;
// reg [7:0] r_reg_0111                                                         ;
reg [7:0] r_reg_0312                                                         ;
reg [7:0] r_reg_03a0                                                         ;
// reg [7:0] r_reg_012c                                                         ;


reg [7:0] r_reg_1050                                                         ;
reg [7:0] r_reg_1051                                                         ;
reg [7:0] r_reg_1052                                                         ;
reg [7:0] r_reg_1053                                                         ;
reg [7:0] r_reg_1054                                                         ;

////////////////////////////////////////////////////////////////////////////////////
//RW REG assignment
////////////////////////////////////////////////////////////////////////////////////
assign  o_test_reg                   = r_reg_0006                            ;

assign  o_BMC_JTAG_MUX_S            = r_reg_0013[7]                         ; //default 1

assign  o_bmc_clr_tmout_n            = r_reg_0034[7]                         ; //default 1
assign  o_pal_cpu0_forcepr_r         = r_reg_0034[6]                         ; //default 0
assign  o_pal_cpu1_forcepr_r         = r_reg_0034[5]                         ; //default 0
assign  o_clear_register             = r_reg_0034[4]                         ; //default 0

assign  o_bmc_clr_sbtn_n             = r_reg_0052[7]                         ; //default 1
assign  o_bmc_clr_lbtn_n             = r_reg_0052[6]                         ; //default 1
assign  o_bmc_clr_sbtn_sys_n         = r_reg_0052[5]                         ; //default 1

assign  o_pwr_btn_lock               = r_reg_0053[7]                         ; //default 1
assign  o_bmc_power_soft_ctl         = r_reg_0053[6]                         ; //default 0
assign  o_bmc_lbtn_pwrdown_ctl       = r_reg_0053[5]                         ; //default 0
assign  o_bmc_sbtn_pwron_ctl         = r_reg_0053[4]                         ; //default 0
assign  o_bmc_sbtn_sysrst_ctl        = r_reg_0053[3]                         ; //default 0

// assign  o_memhot_ctl                 = r_reg_0055[7]                         ; //default 1
// assign  o_throttle                   = r_reg_0055[6]                         ; //default 1


assign  o_p0_mciop0a_gpu_throttle_n_r   = r_reg_006c[7]                         ; //default 0
assign  o_p0_mciop0c_gpu_throttle_n_r   = r_reg_006c[6]                         ; //default 0
// assign  o_pal_mcio2_gpu_throttle_n	    = r_reg_006c[5]                         ; //default 0
// assign  o_pal_mcio3_gpu_throttle_n	    = r_reg_006c[4]                         ; //default 0
// assign  o_pal_mcio4_gpu_throttle_n	    = r_reg_006c[3]                         ; //default 0
// assign  o_pal_mcio5_gpu_throttle_n	    = r_reg_006c[2]                         ; //default 0
// assign  o_pal_mcio6_gpu_throttle_n	    = r_reg_006c[1]                         ; //default 0
// assign  o_pal_mcio8_gpu_throttle_n	    = r_reg_006c[0]                         ; //default 0

// assign  o_pal_mcio10_gpu_throttle_n     = r_reg_006d[7]                         ; //default 0
// assign  o_mcio11a_gpu_throttle_n_r	    = r_reg_006d[6]                         ; //default 0
// assign  o_mcio11c_gpu_throttle_n_r      = r_reg_006d[5]                         ; //default 0
// assign  o_pal_mcio13_gpu_throttle_n     = r_reg_006d[4]                         ; //default 0
// assign  o_pal_mcio14_gpu_throttle_n     = r_reg_006d[3]                         ; //default 0

assign  o_i3c_mux_en                    = r_reg_0073[7]                         ; //default 0
assign  o_i3c_remote_cs              = r_reg_0073[4]                         ; //default 0

assign  o_eeprom_wp    = r_reg_0074[7]                         ; //default 0
assign  o_scaled_bat_test_en_r	     = r_reg_0074[6]                         ; //default 0
assign  o_bmc_nmi_event              = r_reg_0074[5]                         ; //default 0
assign  o_rtc_senor_sw              = r_reg_0074[4]                         ; //default 0

//pcycle--0x0076
assign  o_aux_pcycle                 = r_reg_0076[7]                         ; //default 0   
assign  o_usb_sw_s                   = r_reg_0076[6]                         ; //default 0 


assign  o_p0_vpp_9545_4_rst_n             = r_reg_0077[7]                         ; //default 1 
assign  o_p0_vpp_9545_5_rst_n             = r_reg_0077[6]                         ; //default 1 
assign  o_p0_vpp_9545_6_rst_n             = r_reg_0077[5]                         ; //default 1 


assign  o_bmc_i2c5_9548_rst_n	          = r_reg_0078[7]                         ; //default 1
assign  o_bmc_i2c4_9548_1_rst_n         = r_reg_0078[6]                         ; //default 1
assign  o_bmc_i2c4_9548_2_rst_n         = r_reg_0078[5]                         ; //default 1
assign  o_bmc_i2c4_9548_3_rst_n          = r_reg_0078[4]                         ; //default 1
assign  o_bmc_i2c4_9548_4_rst_n         = r_reg_0078[3]                         ; //default 1
assign  o_p0_vpp_9545_1_rst_n	         = r_reg_0078[2]                         ; //default 1
assign  o_p0_vpp_9545_2_rst_n	         = r_reg_0078[1]                         ; //default 1
assign  o_p0_vpp_9545_3_rst_n	         = r_reg_0078[0]                         ; //default 1







assign  o_164_mr_n                   = r_reg_008a[7]                         ; //default 1

assign  o_164_test_data              = r_reg_008c                            ;

assign  o_leakage_int_mask           = r_reg_008f[7]                         ; //default 1

assign  o_bmc_clr_stby_tmout_n       = r_reg_0201[7];    //20220109 c00268;idms:202201060004
assign  o_bmc_clr_stby_pwr_drop_n = r_reg_0201[6];    //20220109 c00268;idms:202201060004
assign  o_bmc_clr_core_tmout_n       = r_reg_0201[5];    //20220109 c00268;idms:202201060004

assign  o_power_on_fail_err_code_clr   = r_reg_0202[0];  //20220109 c00268;idms:202201060004
assign  o_power_down_fail_err_code_clr = r_reg_0203[0];  //20220109 c00268;idms:202201060004

assign  o_force_allpwron_ctl                = r_reg_00a0[7];  

assign  o_fm_pld_db800_3_clks_dev_en = r_reg_00d1[6]; 

assign  o_jtag_cpld_bmc_ntrst_r             = r_reg_0105[4];

assign  o_bmc_warm_reset_ctl                    = r_reg_0130[5];  

assign  o_cpu0_thermtrip_clr     = r_reg_020d[7];
assign  o_cpu1_thermtrip_clr     = r_reg_020d[6];

// assign  o_cpu0_prochot     = r_reg_020e[7];
// assign  o_cpu1_prochot     = r_reg_020e[6];

assign  o_sys_debug_mode                            = r_reg_02c0[3]; 

assign o_p1_dimm_gl_pwrgd_fail_event_clr	= r_reg_0312[3];
assign o_p1_dimm_af_pwrgd_fail_event_clr	= r_reg_0312[2];
assign o_p0_dimm_gl_pwrgd_fail_event_clr	= r_reg_0312[1];
assign o_p0_dimm_af_pwrgd_fail_event_clr	= r_reg_0312[0];

assign  o_bmc_nmi_ctl            = r_reg_03a0[6];
assign  o_clr_cmos_ctl	    = r_reg_03a0[4];

assign  o_espi_ram_1050 = r_reg_1050 ;
assign  o_espi_ram_1051 = r_reg_1051 ;
assign  o_espi_ram_1052 = r_reg_1052 ;
assign  o_espi_ram_1053 = r_reg_1053 ;
assign  o_espi_ram_1054 = r_reg_1054 ;

// Example: Assign a default value or control logic
assign o_pal_rst_rtc = 1'b0; // 默认值为低电平，或根据需要添加逻辑
////////////////////////////////////////////////////////////////////////////////////
//RO REG assignment
////////////////////////////////////////////////////////////////////////////////////	
assign w_ram_0000    = i_product_id	;
assign w_ram_0001    = i_vender_id	        ;
assign w_ram_0002    = i_board_id	        ;
assign w_ram_0003    = i_pcb_version      ;
assign w_ram_0004    = i_bom_id                ;
assign w_ram_0005    = i_cpld_version    ;
assign w_ram_0007    = i_year                    ;
assign w_ram_0008    = i_month                  ;
assign w_ram_0009    = i_day                      ;
assign w_ram_000a    = i_nc_pin                ;
assign w_ram_000b    = i_cpld_compa_version ;
assign w_ram_000c    = i_cpld_debug_version ;
assign w_ram_000d = {
                                         i_PS1_PRSNT                   ,
                                         i_PS2_PRSNT                   ,
                                         i_PS3_PRSNT                   ,
                                         i_PS4_PRSNT                   ,
                                         i_PS1_ACFAIL                 ,
                                         i_PS2_ACFAIL                 ,
                                         i_PS1_DCOK                     ,
                                         i_PS2_DCOK                     
                                         };
assign w_ram_000e = {
                                         i_PS1_ALERT                  ,
                                         i_PS2_ALERT                  ,
                                         i_PS1_P12V_ON              ,
                                         i_PS2_P12V_ON              ,
                                         i_PS_OFF                        ,
                                         i_DUAL_EN                      ,
                                         i_P12V_DROOP                ,
                                         i_P12V_STBY_DROOP
                                         };
assign w_ram_000f = {
                                         i_P12V_DISCHARGE    ,
                                         1'b0                            ,
                                         1'b0                            ,
                                         1'b0                            ,
                                         1'b0                            ,
                                         1'b0                            ,
                                         1'b0                            ,
                                         1'b0
                                         };
assign w_ram_0010 = {
                                         i_PGD_P5V_MB                          ,
                                         i_PGD_P5V_STBY_MB                ,
                                         i_PGD_P3V3_STBY_MB              ,
                                         i_PGD_P3V3_STBY_B_MB          ,
                                         i_PGD_P1V8_PCH_STBY_MB      ,
                                         i_PGD_P1V2_STBY_MB              ,
                                         i_PGD_P1V05_PCH_STBY_MB    ,
                                         i_PGD_PVNN_PCH_STBY_MB
                                         };

assign w_ram_0011 = {
                                         i_USB_INNER_OVERCUR3  ,
                                         i_USB2_LCD_OC_N            ,
                                         1'b0                                  ,
                                         1'b0                                  ,
                                         1'b0                                  ,
                                         1'b0                                  ,
                                         1'b0                                  ,
                                         1'b0
                                         };
assign w_ram_0012 = {
                                         i_PAL_P5V_EN_R_MB                     ,
                                         i_PAL_P5V_STBY_EN_R_MB           ,
                                         i_P5V_STBY_USB_EN       ,
                                         i_P5V_EN         ,
                                         i_ncsi_main_pwr_en                 ,
                                         i_ncsi_aux_pwr_en       ,
                                         i_PAL_PVNN_STBY_EN_R_MB         ,
                                         i_PAL_EN_PWM_CTRL_VCC_R_MB
                                         };
assign w_ram_0020 = {
                                         i_pwrgd_vdd_33_stby0	      ,
                                         i_pwrgd_vdd_18_stby0	      ,
                                         i_pal_pgd_p0_vdd_core_1       ,
                                         i_pal_pgd_p0_vdd_core_0       ,
                                         i_pal_pgd_p0_vdd_soc_0	      ,
                                         i_pal_pgd_p0_vddio		      ,
                                         i_pal_pgd_p0_vdd_sus_0	      ,
                                         i_pal_cpu_sys_pwrok        
                                         };
assign w_ram_0021 = {
                                         i_p0_pwrgd_out_r    ,
                                         i_p0_pwrok_r	     ,
                                         i_p0_pwr_good_r	     ,
                                         1'b0                            ,
                                         1'b0                            ,
                                         1'b0                            ,
                                         1'b0                            ,
                                         1'b0
                                         };
assign w_ram_0022 = {
                                         i_p0_vddc_en			     ,
                                         i_p0_vdd_18_stby_en	             ,
                                         i_pal_p0_vdd_11_sus_en	     ,
                                         i_pal_p0_vddio_en_r	             ,
                                         i_pal_p0_vdd_soc_en	             ,
                                         i_pal_p0_vdd_core_0_en_r    ,
                                         i_pal_p0_vdd_core_1_en_r    ,
                                         1'b0
                                         };
assign w_ram_0023 = {
                                         i_pwrgd_vdd_18_stby1	    ,
                                         i_pwrgd_vdd_33_stby1	    ,
                                         i_pal_pgd_p1_vdd_core_1     ,
                                         i_pal_pgd_p1_vdd_core_0     ,
                                         i_pal_pgd_p1_vdd_soc_0	    ,
                                         i_pal_pgd_p1_vddio		    ,
                                         i_pal_pgd_p1_vdd_sus_0	    ,
                                         1'b0
                                         };
assign w_ram_0024 = {
                                         i_p1_pwrgd_out_r    ,
                                         i_p1_pwrok_r	     ,
                                         i_p1_pwr_good_r	     ,
                                         1'b0                            ,
                                         1'b0                            ,
                                         1'b0                            ,
                                         1'b0                            ,
                                         1'b0
                                         };
assign w_ram_0025 = {
                                         i_p1_vdd_18_stby_en	             ,
                                         i_p1_vddc_en			     ,
                                         i_pal_p1_vdd_11_sus_en	     ,
                                         i_pal_p1_vddio_en_r	             ,
                                         i_pal_p1_vdd_soc_en	             ,
                                         i_pal_p1_vdd_core_0_en_r    ,
                                         i_pal_p1_vdd_core_1_en_r    ,
                                         1'b0
                                         };
                                         
assign w_ram_0030 = {
                                         i_PAL_CPU0_PRSNT_N              ,
                                         i_PAL_CPU1_PRSNT_N              ,
                                         1'b0                ,
                                         1'b0                ,
                                         1'b0                ,
                                         1'b0                ,
                                         1'b0                ,
                                         1'b0
                                         };

assign w_ram_0032 = {
                                         i_P0_SMERR_N              ,
                                         i_P1_SMERR_N              ,
                                         i_FM_CPU_SMERR_LVC3_N_R   ,
                                         1'b0                ,
                                         1'b0                ,
                                         1'b0                ,
                                         1'b0                ,
                                         1'b0
                                         };
assign w_ram_0033 = {
                                         i_PAL_CPU0_MEMHOT_OUT_N         ,
                                         i_PAL_CPU0_MEMTRIP_N               ,
                                         i_PAL_CPU0_THERMTRIP_N           ,
                                         i_PAL_CPU0_PROCHOT_N               ,
                                         i_PAL_CPU1_MEMHOT_OUT_N         ,
                                         i_PAL_CPU1_MEMTRIP_N               ,
                                         i_PAL_CPU1_THERMTRIP_N           ,
                                         i_PAL_CPU1_PROCHOT_N            
                                         };

assign w_ram_0035    = i_pwr_flt_code	             ;


assign w_ram_0050 = {
                                         i_btn_press_flag  ,
                                         i_slps5_sts            ,
                                         i_slps3_sts            ,
                                         1'b0                          ,
                                         1'b0                          ,
                                         1'b0                          ,
                                         1'b0                          ,
                                         1'b0
                                         };
assign w_ram_0051 = {
                                         i_sbtn_pwron_evt    , 
                                         i_lbtn_pwrdown_evt,
                                         i_sbtn_sysrst_evt  ,
                                         1'b0                            ,
                                         1'b0                            ,
                                         1'b0                            ,
                                         1'b0                            ,
                                         1'b0
                                         };
assign w_ram_0054 = {
                                         i_bmc_power_soft_done      ,
                                         i_bmc_lbtn_pwrdown_done  ,
                                         i_bmc_sbtn_pwron_done      ,
                                         i_bmc_sbtn_sysrst_done    ,
                                         1'b0                                        ,
                                         1'b0                                        ,
                                         1'b0                                        ,
                                         1'b0
                                         };

assign w_ram_0056 = {
                     i_pal_bmcuid_button             ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0                            ,
                     1'b0
					 };

// assign w_ram_0060 = {
                     // i_pal_mcio1_cable_id0           ,
                     // i_pal_mcio1_cable_id1           ,
                     // i_pal_mcio2_cable_id0           ,
                     // i_pal_mcio2_cable_id1           ,
                     // i_pal_mcio3_cable_id0           ,
                     // i_pal_mcio3_cable_id1           ,
                     // i_pal_mcio4_cable_id0           ,
                     // i_pal_mcio4_cable_id1
					 // };

// assign w_ram_0061 = {
                     // i_pal_mcio5_cable_id0           ,
                     // i_pal_mcio5_cable_id1           ,
                     // i_pal_mcio6_cable_id0           ,
                     // i_pal_mcio6_cable_id1           ,
                     // i_pal_mcio7_cable_id0           ,
                     // i_pal_mcio7_cable_id1           ,
                     // i_pal_mcio8_cable_id0           ,
                     // i_pal_mcio8_cable_id1
					 // };


// assign w_ram_0063 = {
                     // i_pal_mcio13_cable_id0          ,
                     // i_pal_mcio13_cable_id1          ,
                     // i_pal_mcio14_cable_id0          ,
                     // i_pal_mcio14_cable_id1          ,
                     // i_pal_mcio17_cable_id0          ,
                     // i_pal_mcio17_cable_id1          ,
                     // i_pal_mcio18_cable_id0          ,
                     // i_pal_mcio18_cable_id1
					 // };

// assign w_ram_0064 = {
                     // i_pal_mcio19_cable_id0          ,
                     // i_pal_mcio19_cable_id1          ,
                     // i_pal_mcio20_cable_id0          ,
                     // i_pal_mcio20_cable_id1          ,
                     // 1'b0                            ,
                     // 1'b0                            ,
                     // 1'b0                            ,
                     // 1'b0
					 // };
assign w_ram_0065 = {
                                         i_p1_vr_i2c_alert_n  ,
                                         i_p0_vr_i2c_alert_n  ,
                                         1'b0                                  ,
                                         1'b0                                  ,
                                         1'b0                                  ,
                                         1'b0                                  ,
                                         1'b0                                  ,
                                         1'b0                      
                                         }; 
assign w_ram_0066 = {
                                         i_P0_MCIOP0A_NVME0_PRSNT_N_R   ,
                                         i_P0_MCIOP0C_NVME0_PRSNT_N_R   ,
                                         i_P0_MCIOP0A_NVME1_PRSNT_N_R   ,
                                         i_P0_MCIOP0C_NVME1_PRSNT_N_R   ,
                                         1'b0                                                   ,
                                         1'b0                                                   ,
                                         1'b0                                                   ,
                                         1'b0   
                                         };

// assign w_ram_0067 = {
                     // i_PAL_MCIO13_NVME0_PRSNT_N      ,
                     // i_CPU0_MCIO0C_NVME1_PRSNT_N_R   ,
                     // i_MCIO1A_NVME1_PRSNT_N_R        ,
                     // i_MCIO1C_NVME1_PRSNT_N_R        ,
                     // i_PAL_MCIO10_NVME1_PRSNT_N      ,
                     // i_PAL_MCIO13_NVME1_PRSNT_N      ,
                     // 1'b0                            ,
                     // 1'b0                      
					 // };

assign w_ram_006a = {
                                         i_pal_m2_0_prsnt_n             ,
                                         i_pal_m2_1_prsnt_n             ,
                                         i_pal_bp1_prsnt_n               ,
                                         i_pal_bp2_prsnt_n               ,
                                         i_pal_bp3_prsnt_n               ,
                                         i_pal_bp4_prsnt_n               ,
                                         i_pal_bp5_prsnt_n               ,
                                         i_pal_bp6_prsnt_n
                                         };

assign w_ram_006b = {
                                         i_pal_bp8_prsnt_n  ,
                                         1'b0                            ,
                                         1'b0                            ,
                                         1'b0                            ,
                                         1'b0                            ,
                                         1'b0                            ,
                                         1'b0                            ,
                                         1'b0
                                         };

// assign w_ram_006f = {
                     // i_rightear_cable_id_r           ,
                     // 1'b0                            ,
                     // 1'b0                            ,
                     // 1'b0                            ,
                     // 1'b0                            ,
                     // i_tpm_module_prsnt_n            ,
                     // 1'b0                            ,
                     // 1'b0                       
					 // };

assign w_ram_0070 = {
                                         1'b0                             ,
                                         1'b0                             ,
                                         1'b0                             ,
                                         1'b0                             ,
                                         i_p1_pcie_wake_n_r ,
                                         i_p0_pcie_wake_n_r ,
                                         1'b0                             ,
                                         1'b0
                                         };

					 
// assign w_ram_0075 = {
                     // i_pch_slp3_n                    ,
                     // i_pch_slp4_n                    ,
                     // 1'b0                            ,
                     // 1'b0                            ,
                     // 1'b0                            ,
                     // 1'b0                            ,
                     // 1'b0                            ,
                     // 1'b0
					 // };					 

// assign w_ram_0079 = {
                     // i_tpm431_alert_n_sw             ,
                     // i_ina3221_pwr_alert_sw          ,
                     // i_pal_3v3_pgd1_r_sw             ,
                     // i_pal_3v3_pgd2_r_sw             ,
                     // i_pal_3v3_pgd3_r_sw             ,
                     // i_pal_3v3_pgd4_r_sw             ,
                     // i_pal_3v3_pgd5_r_sw             ,
                     // i_u3_nc7_sw           
					 // };		

// assign w_ram_007a = {
                     // i_slot1_prsnt_n_sw              ,
                     // i_slot2_prsnt_n_sw              ,
                     // i_slot3_prsnt_n_sw              ,
                     // i_slot4_prsnt_n_sw              ,
                     // i_slot5_prsnt_n_sw              ,
                     // i_slot6_prsnt_n_sw              ,
                     // i_slot7_prsnt_n_sw              ,
                     // i_slot8_prsnt_n_sw             
					 // };	

// assign w_ram_007b = {
                     // i_slot9_prsnt_n_sw              ,
                     // i_slot10_prsnt_n_sw             ,
                     // i_slot11_prsnt_n_sw             ,
                     // i_slot12_prsnt_n_sw             ,
                     // i_slot13_prsnt_n_sw             ,
                     // i_mcio1_prsnt_n_sw              ,
                     // i_mcio2_prsnt_n_sw              ,
                     // i_mcio3_prsnt_n_sw              
					 // };	

// assign w_ram_007c = {
                     // i_mcio4_prsnt_n_sw              ,
                     // i_mcio5_prsnt_n_sw              ,
                     // i_mcio6_prsnt_n_sw              ,
                     // i_mcio7_prsnt_n_sw              ,
                     // i_mcio8_prsnt_n_sw              ,
                     // i_mcio9_prsnt_n_sw              ,
                     // i_mcio10_prsnt_n_sw             ,
                     // i_mcio11_prsnt_n_sw          
					 // };	

// assign w_ram_007d = {
                     // i_mcio12_prsnt_n_sw             ,
                     // i_mcio13_prsnt_n_sw             ,
                     // i_pcb_version2_sw               ,
                     // i_pcb_version1_sw               ,
                     // i_pcb_version0_sw               ,
                     // i_pca_version2_sw               ,
                     // i_pca_version1_sw               ,
                     // i_pca_version0_sw           
					 // };	

// assign w_ram_007e = {
                     // i_board_id0_sw                  ,
                     // i_board_id1_sw                  ,
                     // i_board_id2_sw                  ,
                     // i_board_id3_sw                  ,
                     // i_board_id4_sw                  ,
                     // i_board_id5_sw                  ,
                     // i_board_id6_sw                  ,
                     // i_board_id7_sw         
					 // };	

// assign w_ram_007f = {
                     // i_pal_p12v_drop_sw              ,
                     // i_pg_p5v0_r_sw                  ,
                     // i_pg_p1v8_r_sw                  ,
                     // i_pg_p1v8_pll_r_sw              ,
                     // i_db2000_pwrgd0_sw              ,
                     // i_db2000_pwrgd1_sw              ,
                     // i_mcio_slot13_prsnt_n_1_sw      ,
                     // i_u40_nc7_sw                    
					 // };	

// assign w_ram_0080 = {
                     // i_ct_p1v25_sw0_pg_sw            ,
                     // i_ct_p1v25_sw1_pg_sw            ,
                     // i_p0v8_sw0_pwrgd_sw             ,
                     // i_p0v8_sw1_pwrgd_sw             ,
                     // i_slot1_wake_n_sw               ,
                     // i_slot2_wake_n_sw               ,
                     // i_slot3_wake_n_sw               ,
                     // i_slot4_wake_n_sw               
					 // };	

// assign w_ram_0081 = {
                     // i_slot5_wake_n_sw               ,
                     // i_slot6_wake_n_sw               ,
                     // i_slot7_wake_n_sw               ,
                     // i_slot8_wake_n_sw               ,
                     // i_slot9_wake_n_sw               ,
                     // i_slot10_wake_n_sw              ,
                     // i_slot11_wake_n_sw              ,
                     // i_slot12_wake_n_sw              
					 // };

// assign w_ram_0082 = {
                     // i_tpm431_alert_n_zt             ,
                     // i_ina3221_pwr_alert_zt          ,
                     // i_pal_3v3_pgd1_r_zt             ,
                     // i_pal_3v3_pgd2_r_zt             ,
                     // i_pal_3v3_pgd3_r_zt             ,
                     // i_pal_3v3_pgd4_r_zt             ,
                     // i_pal_3v3_pgd5_r_zt             ,
                     // i_u3_nc7_zt                        
					 // };

// assign w_ram_0083 = {
                     // i_slot1_prsnt_n_zt              ,
                     // i_slot2_prsnt_n_zt              ,
                     // i_slot3_prsnt_n_zt              ,
                     // i_slot4_prsnt_n_zt              ,
                     // i_slot5_prsnt_n_zt              ,
                     // i_slot6_prsnt_n_zt              ,
                     // i_slot7_prsnt_n_zt              ,
                     // i_slot8_prsnt_n_zt             
					 // };

// assign w_ram_0084 = {
                     // i_slot9_prsnt_n_zt              ,
                     // i_slot10_prsnt_n_zt             ,
                     // i_slot11_prsnt_n_zt             ,
                     // i_slot12_prsnt_n_zt             ,
                     // i_slot13_prsnt_n_zt             ,
                     // i_mcio1_prsnt_n_zt              ,
                     // i_mcio2_prsnt_n_zt              ,
                     // i_mcio3_prsnt_n_zt              
					 // };

// assign w_ram_0085 = {
                     // i_mcio4_prsnt_n_zt             ,
                     // i_mcio5_prsnt_n_zt             ,
                     // i_mcio6_prsnt_n_zt             ,
                     // i_mcio7_prsnt_n_zt             ,
                     // i_mcio8_prsnt_n_zt             ,
                     // i_mcio9_prsnt_n_zt             ,
                     // i_mcio10_prsnt_n_zt            ,
                     // i_mcio11_prsnt_n_zt            
					 // };

// assign w_ram_0086 = {
                     // i_mcio12_prsnt_n_zt            ,
                     // i_mcio13_prsnt_n_zt            ,
                     // i_pcb_version2_zt              ,
                     // i_pcb_version1_zt              ,
                     // i_pcb_version0_zt              ,
                     // i_pca_version2_zt              ,
                     // i_pca_version1_zt              ,
                     // i_pca_version0_zt              
					 // };

// assign w_ram_0087 = {
                     // i_board_id0_zt                 ,
                     // i_board_id1_zt                 ,
                     // i_board_id2_zt                 ,
                     // i_board_id3_zt                 ,
                     // i_board_id4_zt                 ,
                     // i_board_id5_zt                 ,
                     // i_board_id6_zt                 ,
                     // i_board_id7_zt                 
					 // };

// assign w_ram_0088 = {
                     // i_mcio1_prsnt_n_1_zt           ,
                     // i_mcio2_prsnt_n_1_zt           ,
                     // i_mcio3_prsnt_n_1_zt           ,
                     // i_mcio4_prsnt_n_1_zt           ,
                     // i_mcio5_prsnt_n_1_zt           ,
                     // i_mcio7_prsnt_n_1_zt           ,
                     // i_mcio9_prsnt_n_1_zt           ,
                     // i_mcio10_prsnt_n_1_zt          
					 // };

// assign w_ram_0089 = {
                     // i_mcio11_prsnt_n_1_zt          ,
                     // i_mcio12_prsnt_n_1_zt          ,
                     // i_u19_nc2_zt                   ,
                     // i_u19_nc3_zt                   ,
                     // i_u19_nc4_zt                   ,
                     // i_u19_nc5_zt                   ,
                     // i_u19_nc6_zt                   ,
                     // i_u19_nc7_zt                   
					 // };
assign w_ram_0089 = i_switch_mode;
assign w_ram_008b = {
                                         i_pch_bios_post_cmplt_n         ,
                                         1'b0                            ,
                                         1'b0                            ,
                                         1'b0                            ,
                                         1'b0                            ,
                                         1'b0                            ,
                                         1'b0                            ,
                                         1'b0
                                         };	
assign w_ram_008d = i_switch2_mode;
assign w_ram_0090 = {
                                         1'b0                           ,
                                         i_p0_spd_host_ctrl_n         ,
                                         1'b0                            ,
                                         1'b0                            ,
                                         1'b0                            ,
                                         1'b0                            ,
                                         1'b0                            ,
                                         1'b0
                                         };	

assign w_ram_008e = {
                                         i_LEAKAGE0_PRSNT_N       ,
                                         i_BREAK_DET_DO_N           ,
                                         i_LEAKAGE_DET_DO_N       ,
                                         i_LEAKAGE_PRSNT1_N       ,
                                         i_BREAK_DET1_DO_N         ,
                                         i_LEAKAGE_DET1_DO_N     ,
                                         1'b0                                   ,
                                         1'b0
                                         };	

//////////////////////////////////0x00C0-0x00D0 for FIX REG/////////////////////////////////////////////////////////////////////////////
assign w_ram_00C2 = i_PRODUCT_LINE_C2	             ;
assign w_ram_00C3 = i_PRODUCT_GEN_ID_C3              ;
assign w_ram_00C5 = i_SERVER_ID_C5                   ;
assign w_ram_00C6 = i_BOARD_ID_C6                    ;

//////////////////////////////////0x00C0-0x00D0 for FIX REG/////////////////////////////////////////////////////////////////////////////
assign w_ram_0200 = {
                                         1'b0     ,
                                         1'b0     ,
                                         1'b0     ,
                                         1'b0     ,
                                         1'b0     ,
                                         1'b0     ,
                                         1'b0     ,
                                         i_power_alarm_flag
                                         };	
assign w_ram_0201 = {
                                         i_stb_pwron_tmout_fail,
                                         i_stb_pwrdown_ukwn_fail,
                                         i_poweron_tmout_fail,
                                         i_powerdown_ukwn_fail,
                                         3'b0,
                                         i_system_pwr_sts
                                         };	

assign w_ram_0202 = i_power_on_fail_err_code  ;
assign w_ram_0203 = i_power_down_fail_err_code;
assign w_ram_0205 = i_power_seq_state_machine;
assign w_ram_0206 = i_power_seq_fault_latch;
assign w_ram_0091 = {
					i_p12v_stby_fault_det			,
					i_p5v_stby_fault_det			,
					1'b0                            ,
					1'b0                            ,
					i_grp_b_p0_33_s5_fault_det		,
					i_grp_b_p1_33_s5_fault_det		,
					i_grp_b_p0_18_s5_fault_det		,
					i_grp_b_p1_18_s5_fault_det		
					};

assign w_ram_0092 = {
					1'b0,
					i_p5v_fault_det				,
					i_p12v_efuse_fault_det			,
					i_p12v_ssd_efuse_fault_det		,
					i_p12v_p0_dimm_fault_det		,
					i_p12v_p1_dimm_fault_det		,
					i_grp_c_p0_fault_det			,
					i_grp_c_p1_fault_det
					};					
assign w_ram_0093 = { 
					i_grp_d_vddio_p0_fault_det		,
					i_grp_d_vddio_p1_fault_det		,
					i_grp_d_soc_p0_fault_det		,
					i_grp_d_soc_p1_fault_det		,
					i_grp_d_p0_vddcore0_fault_det	,
					i_grp_d_p1_vddcore0_fault_det	, 
					i_grp_d_p0_vddcore1_fault_det	,
					i_grp_d_p1_vddcore1_fault_det	
					};
assign w_ram_009d = {
                                          i_p1_vdd_core_1_ocp_n,
                                          i_p1_vdd_core_0_ocp_n,
                                          i_p1_vddio_ocp_n,
                                          i_p1_efuse_fault_n,
                                          i_p0_vdd_core_1_ocp_n,
                                          i_p0_vdd_core_0_ocp_n,
                                          i_p0_vddio_ocp_n,
                                          1'b0
                                           };	
assign w_ram_009e = {                         
                                          o_pal_rst_rtc, 
                                          i_rtc_inta_n,
                                          1'b0,
                                          i_p1_i3c_apml_alert_n,
                                          i_p0_i3c_apml_alert_n,
                                          i_clk_gen_en_r_n,
                                          i_clk_gen_alert_r_n,
                                          1'b0
                                           };
assign w_ram_00f4 = {                         
                                          6'b0              ,
                                          i_cpu1_reset_n,
                                          i_cpu0_reset_n
                                           };
assign w_ram_0103 = {
                                          i_p1_vdd_core_0_soc_rst_l_n,   
                                          i_p1_vdd_core_1_11_sus_rst_l_n,
                                          i_p1_vddio_rst_l_n,            
                                          i_p0_vddio_rst_l_n,            
                                          i_p0_vdd_core_0_soc_rst_l_n,   
                                          i_p0_vdd_core_1_11_sus_rst_l_n,
                                          i_cpu_sys_reset_r_n,            
                                          i_cpu_rsmrst_r_n              
                                         }; 
assign w_ram_020d = {                   
                                         i_cpu0_thermtrip,
                                         i_cpu1_thermtrip,
                                         6'b0					 
                                         };

assign w_ram_02e0 = {
                                         1'b0,
                                         i_p0_coretype2,
                                         i_p0_coretype1,
                                         i_p0_coretype0,
                                         i_p0_sp5r4,
                                         i_p0_sp5r3,
                                         i_p0_sp5r2,
                                         i_p0_sp5r1
                                         };
assign w_ram_02e8 = {
                                         1'b0,
                                         i_p1_coretype2,
                                         i_p1_coretype1,
                                         i_p1_coretype0,
                                         i_p1_sp5r4,
                                         i_p1_sp5r3,
                                         i_p1_sp5r2,
                                         i_p1_sp5r1
                                         };
assign w_ram_0300 = {
                                         7'b0,
                                         i_dimm_alarm_flag
                                         };
assign w_ram_0312 = {
                                         4'b0,
                                         i_p1_dimm_gl_pwrgd_fail_event,
                                         i_p1_dimm_af_pwrgd_fail_event,
                                         i_p0_dimm_gl_pwrgd_fail_event,
                                         i_p0_dimm_af_pwrgd_fail_event
                                         };

assign  w_ram_1055  =   i_espi_ram_1055;
assign  w_ram_1056  =   i_espi_ram_1056;
assign  w_ram_1057  =   i_espi_ram_1057;
assign  w_ram_1058  =   i_espi_ram_1058;

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
                16'h000d: r_i2c_data_in <= w_ram_000d;//RO
                16'h000e: r_i2c_data_in <= w_ram_000e;//RO
                16'h000f: r_i2c_data_in <= w_ram_000f;//RO
                
                16'h0010: r_i2c_data_in <= w_ram_0010;//RO
                16'h0011: r_i2c_data_in <= w_ram_0011;//RO
                16'h0012: r_i2c_data_in <= w_ram_0012;//RO
                16'h0013: r_i2c_data_in <= r_reg_0013;//RW
        
                16'h0020: r_i2c_data_in <= w_ram_0020;//RO
                16'h0021: r_i2c_data_in <= w_ram_0021;//RO
                16'h0022: r_i2c_data_in <= w_ram_0022;//RO
                16'h0023: r_i2c_data_in <= w_ram_0023;//RO
                16'h0024: r_i2c_data_in <= w_ram_0024;//RO
                16'h0025: r_i2c_data_in <= w_ram_0025;//RO
                
                16'h0030: r_i2c_data_in <= w_ram_0030;//RO
                // 16'h0031: r_i2c_data_in <= w_ram_0031;//RO
                16'h0032: r_i2c_data_in <= w_ram_0032;//RO
		16'h0033: r_i2c_data_in <= w_ram_0033;//RO
		16'h0034: r_i2c_data_in <= r_reg_0034;//RW
		16'h0035: r_i2c_data_in <= w_ram_0035;//RO
        
                16'h0050: r_i2c_data_in <= w_ram_0050;//RO
                16'h0051: r_i2c_data_in <= w_ram_0051;//RO
                16'h0052: r_i2c_data_in <= r_reg_0052;//RW
                16'h0053: r_i2c_data_in <= r_reg_0053;//RW
                16'h0054: r_i2c_data_in <= w_ram_0054;//RO
                // 16'h0055: r_i2c_data_in <= r_reg_0055;//RW
                16'h0056: r_i2c_data_in <= w_ram_0056;//RO
        
		// 16'h005f: r_i2c_data_in <= w_ram_005f;//RO
                // 16'h0060: r_i2c_data_in <= w_ram_0060;//RO
                // 16'h0061: r_i2c_data_in <= w_ram_0061;//RO
                // 16'h0063: r_i2c_data_in <= w_ram_0063;//RO
                // 16'h0064: r_i2c_data_in <= w_ram_0064;//RO
                16'h0065: r_i2c_data_in <= w_ram_0065;//RO
		16'h0066: r_i2c_data_in <= w_ram_0066;//RO
		// 16'h0067: r_i2c_data_in <= w_ram_0067;//RO
                16'h006a: r_i2c_data_in <= w_ram_006a;//RO
                16'h006b: r_i2c_data_in <= w_ram_006b;//RO
                16'h006c: r_i2c_data_in <= r_reg_006c;//RW
                // 16'h006d: r_i2c_data_in <= r_reg_006d;//RW
                // 16'h006f: r_i2c_data_in <= w_ram_006f;//RO
		
                16'h0070: r_i2c_data_in <= w_ram_0070;//RO
                16'h0073: r_i2c_data_in <= r_reg_0073;//RW
                16'h0074: r_i2c_data_in <= r_reg_0074;//RW
                // 16'h0075: r_i2c_data_in <= w_ram_0075;//RO
                16'h0076: r_i2c_data_in <= r_reg_0076;//RW
		16'h0077: r_i2c_data_in <= r_reg_0077;//RW
		16'h0078: r_i2c_data_in <= r_reg_0078;//RW
		
		// 16'h0079: r_i2c_data_in <= w_ram_0079;//RO  //2024-2-18 add 
		// 16'h007a: r_i2c_data_in <= w_ram_007a;//RO
		// 16'h007b: r_i2c_data_in <= w_ram_007b;//RO
		// 16'h007c: r_i2c_data_in <= w_ram_007c;//RO
		// 16'h007d: r_i2c_data_in <= w_ram_007d;//RO
		// 16'h007e: r_i2c_data_in <= w_ram_007e;//RO
		// 16'h007f: r_i2c_data_in <= w_ram_007f;//RO
		// 16'h0080: r_i2c_data_in <= w_ram_0080;//RO
		// 16'h0081: r_i2c_data_in <= w_ram_0081;//RO
		// 16'h0082: r_i2c_data_in <= w_ram_0082;//RO
		// 16'h0083: r_i2c_data_in <= w_ram_0083;//RO
		// 16'h0084: r_i2c_data_in <= w_ram_0084;//RO
		// 16'h0085: r_i2c_data_in <= w_ram_0085;//RO
		// 16'h0086: r_i2c_data_in <= w_ram_0086;//RO
		// 16'h0087: r_i2c_data_in <= w_ram_0087;//RO
		// 16'h0088: r_i2c_data_in <= w_ram_0088;//RO
		16'h0089: r_i2c_data_in <= w_ram_0089;//RO
		
		16'h008a: r_i2c_data_in <= r_reg_008a;//RW
		16'h008b: r_i2c_data_in <= w_ram_008b;//RO
		16'h008c: r_i2c_data_in <= r_reg_008c;//RW
		16'h008d: r_i2c_data_in <= w_ram_008d;//RO
		16'h008e: r_i2c_data_in <= w_ram_008e;//RO
		16'h0090: r_i2c_data_in <= w_ram_0090;//RO

//////////////////////////////////0x00C0-0x00D0 for FIX REG/////////////////////////////////////////////////////////////////////////////
                16'h00C2: r_i2c_data_in <= w_ram_00C2;//RW
                16'h00C3: r_i2c_data_in <= w_ram_00C3;//RW
                16'h00C5: r_i2c_data_in <= w_ram_00C5;//RW
                16'h00C6: r_i2c_data_in <= w_ram_00C6;//RW
//////////////////////////////////0x00C0-0x00D0 for FIX REG/////////////////////////////////////////////////////////////////////////////
		16'h0200: r_i2c_data_in <= w_ram_0200;//RO
		16'h0201: r_i2c_data_in <= w_ram_0201;//RO
		16'h0202: r_i2c_data_in <= w_ram_0202;//RO
		16'h0203: r_i2c_data_in <= w_ram_0203;//RO
		16'h0205: r_i2c_data_in <= w_ram_0205;//RO
		16'h0206: r_i2c_data_in <= w_ram_0206;//RO
		16'h0091: r_i2c_data_in <= w_ram_0091;//RO
		16'h0092: r_i2c_data_in <= w_ram_0092;//RO
		16'h0093: r_i2c_data_in <= w_ram_0093;//RO
		16'h009d: r_i2c_data_in <= w_ram_009d;//RO
		16'h009e: r_i2c_data_in <= w_ram_009e;//RO
		16'h00a0: r_i2c_data_in <= r_reg_00a0;//RW
		16'h00d1: r_i2c_data_in <= r_reg_00d1;//RW
		16'h00f4: r_i2c_data_in <= w_ram_00f4;//RO
		16'h0103: r_i2c_data_in <= w_ram_0103;//RO
		16'h0105: r_i2c_data_in <= r_reg_0105;//RW
		16'h0130: r_i2c_data_in <= r_reg_0130;//RW
		16'h020d: r_i2c_data_in <= w_ram_020d;//RO
		16'h02c0: r_i2c_data_in <= r_reg_02c0;//RW
		// 16'h020e: r_i2c_data_in <= r_reg_020e;//RW
		16'h02e0: r_i2c_data_in <= w_ram_02e0;//RO
		16'h02e8: r_i2c_data_in <= w_ram_02e8;//RO
		16'h0300: r_i2c_data_in <= w_ram_0300;//RO
		16'h0312: r_i2c_data_in <= r_reg_0312;//RW
		16'h03a0: r_i2c_data_in <= r_reg_03a0;//RW
				
		16'h1050: r_i2c_data_in <= r_reg_1050;//RW
		16'h1051: r_i2c_data_in <= r_reg_1051;//RW
		16'h1052: r_i2c_data_in <= r_reg_1052;//RW
		16'h1053: r_i2c_data_in <= r_reg_1053;//RW
		16'h1054: r_i2c_data_in <= r_reg_1054;//RW
		16'h1055: r_i2c_data_in <= w_ram_1055;//RO
		16'h1056: r_i2c_data_in <= w_ram_1056;//RO
		16'h1057: r_i2c_data_in <= w_ram_1057;//RO
		16'h1058: r_i2c_data_in <= w_ram_1058;//RO
                                
		
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

//0x0013
always@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n)  begin
        r_reg_0013  <=8'h80;
    end
    else if((w_WR==1'b0)&&(w_i2c_command==16'h0013) && w_data_vld_pos)  begin
        r_reg_0013  <= w_i2c_data_out;
    end
end

//0x0034
always@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n)  begin
        r_reg_0034  <=8'h80;
    end
    else if((w_WR==1'b0)&&(w_i2c_command==16'h0034) && w_data_vld_pos)  begin
        r_reg_0034  <= w_i2c_data_out;
    end
end

//0x0052
always@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n)  begin
        r_reg_0052  <=8'he0;
    end
    else if((w_WR==1'b0)&&(w_i2c_command==16'h0052) && w_data_vld_pos)  begin
        r_reg_0052  <= w_i2c_data_out;
    end
end

//0x0053
always@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n)  begin
        r_reg_0053  <= 8'h80;
    end
	else if(i_bmc_power_soft_done)  begin  //2023-2-16 add  cause BMC don't care 0x0054 done signal,so we need to clear the bmc_btn_ctl
        r_reg_0053[6]  <= 1'b0;
    end
	else if(i_bmc_lbtn_pwrdown_done)  begin
        r_reg_0053[5]  <= 1'b0;
    end
	else if(i_bmc_sbtn_pwron_done)  begin
       r_reg_0053[4]  <= 1'b0;
    end
	else if(i_bmc_sbtn_sysrst_done)  begin
       r_reg_0053[3]  <= 1'b0;
    end
    else if((w_WR==1'b0)&&(w_i2c_command==16'h0053) && w_data_vld_pos)  begin
        r_reg_0053  <= w_i2c_data_out;
    end
end

//0x0055
// always@(posedge i_clk or negedge i_rst_n) begin
    // if(~i_rst_n)  begin
        // r_reg_0055  <=8'hc0; //2023-2-3 chg  default value from 8'h00 to 8'hc0      for memhot prochot test fail 
    // end
    // else if((w_WR==1'b0)&&(w_i2c_command==16'h0055) && w_data_vld_pos)  begin
        // r_reg_0055  <= w_i2c_data_out;
    // end
// end

//0x006c
always@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n)  begin
        r_reg_006c  <=8'h00;
    end
    else if((w_WR==1'b0)&&(w_i2c_command==16'h006c) && w_data_vld_pos)  begin
        r_reg_006c  <= w_i2c_data_out;
    end
end

//0x006d
// always@(posedge i_clk or negedge i_rst_n) begin
    // if(~i_rst_n)  begin
        // r_reg_006d  <=8'h00;
    // end
    // else if((w_WR==1'b0)&&(w_i2c_command==16'h006d) && w_data_vld_pos)  begin
        // r_reg_006d  <= w_i2c_data_out;
    // end
// end

//0x0073
always@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n)  begin
        r_reg_0073  <=8'h00;
    end
    else if((w_WR==1'b0)&&(w_i2c_command==16'h0073) && w_data_vld_pos)  begin
        r_reg_0073  <= w_i2c_data_out;
    end
end

//0x0074
always@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n)  begin
        r_reg_0074  <=8'h00;
    end
    else if((w_WR==1'b0)&&(w_i2c_command==16'h0074) && w_data_vld_pos)  begin
        r_reg_0074  <= w_i2c_data_out;
    end
end

//0x0076
always@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n)  begin
        r_reg_0076  <=8'h00;
    end
    else if((w_WR==1'b0)&&(w_i2c_command==16'h0076) && w_data_vld_pos)  begin
        r_reg_0076  <= w_i2c_data_out;
    end
end

//0x0077
always@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n)  begin
        r_reg_0077  <=8'hff;//2024-2-4 chg for debug
    end
    else if((w_WR==1'b0)&&(w_i2c_command==16'h0077) && w_data_vld_pos)  begin
        r_reg_0077  <= w_i2c_data_out;
    end
end

//0x0078
always@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n)  begin
        r_reg_0078  <=8'hff;
    end
    else if((w_WR==1'b0)&&(w_i2c_command==16'h0078) && w_data_vld_pos)  begin
        r_reg_0078  <= w_i2c_data_out;
    end
end

//0x008a
always@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n)  begin
        r_reg_008a  <=8'hff;
    end
    else if((w_WR==1'b0)&&(w_i2c_command==16'h008a) && w_data_vld_pos)  begin
        r_reg_008a  <= w_i2c_data_out;
    end
end

//0x008c
always@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n)  begin
        r_reg_008c  <=8'hff; //2024-4-30 sw vb chg 0f to 4f  //2024-5-14 chg to 8'hff
    end
    else if((w_WR==1'b0)&&(w_i2c_command==16'h008c) && w_data_vld_pos)  begin
        r_reg_008c  <= w_i2c_data_out;
    end
end

//0x0201 
always@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n)  begin
        r_reg_0201  <=8'hFF;
    end
	else if(i_st_aux_fail_recovery)  begin //add 
        r_reg_0201  <= 8'hFF;              //add 
    end
    else if((w_WR==1'b0)&&(w_i2c_command==16'h0201) && w_data_vld_pos)  begin
        r_reg_0201  <= w_i2c_data_out;
    end
end
//0x0202 20220110 c00268;idms:202201060004
always@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n)  begin
        r_reg_0202  <=8'hFF;
    end
    else if((w_WR==1'b0)&&(w_i2c_command==16'h0202) && w_data_vld_pos)  begin
        r_reg_0202  <= w_i2c_data_out;
    end
end
//0x0203 20220110 c00268;idms:202201060004
always@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n)  begin
        r_reg_0203  <=8'hFF;
    end
    else if((w_WR==1'b0)&&(w_i2c_command==16'h0203) && w_data_vld_pos)  begin
        r_reg_0203  <= w_i2c_data_out;
    end
end
//0x00a0 
always@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n)  begin
        r_reg_00a0  <=8'h00;
    end
    else if((w_WR==1'b0)&&(w_i2c_command==16'h00a0) && w_data_vld_pos)  begin
        r_reg_00a0  <= w_i2c_data_out;
    end                                             
end

//0x00d1 
always@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n)  begin
        r_reg_00d1  <=8'hff;
    end
    else if((w_WR==1'b0)&&(w_i2c_command==16'h00d1) && w_data_vld_pos)  begin
        r_reg_00d1  <= w_i2c_data_out;
    end                                             
end

//0x0105 
always@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n)  begin
        r_reg_0105  <=8'hff;
    end
    else if((w_WR==1'b0)&&(w_i2c_command==16'h0105) && w_data_vld_pos)  begin
        r_reg_0105  <= w_i2c_data_out;
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

//0x02c0 
always@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n)  begin
        r_reg_02c0  <=8'h00;
    end
    else if((w_WR==1'b0)&&(w_i2c_command==16'h02c0) && w_data_vld_pos)  begin
        r_reg_02c0  <= w_i2c_data_out;
    end                                             
end

//0x020d 
always@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n)  begin
        r_reg_020d  <=8'hff;
	end
    else if((w_WR==1'b0)&&(w_i2c_command==16'h020d) && w_data_vld_pos) begin
        r_reg_020d  <= w_i2c_data_out;
    end
end
//0x020e 
// always@(posedge i_clk or negedge i_rst_n) begin
    // if(~i_rst_n)  begin
        // r_reg_020e  <=8'h00;
	// end
    // else if((w_WR==1'b0)&&(w_i2c_command==16'h020e) && w_data_vld_pos) begin
        // r_reg_020e  <= w_i2c_data_out;
    // end
// end
//0X0312
always@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n)  begin
        r_reg_0312  <=8'hFF;
	end
    else if((w_WR==1'b0)&&(w_i2c_command==16'h0312) && w_data_vld_pos)  begin
        r_reg_0312  <= w_i2c_data_out;
    end
	else if(~(i_p1_dimm_gl_pwrgd_fail_event  & i_p1_dimm_af_pwrgd_fail_event & i_p0_dimm_gl_pwrgd_fail_event & i_p0_dimm_af_pwrgd_fail_event)) begin
		if(~i_p1_dimm_gl_pwrgd_fail_event) begin //write 0 to clear flag
			r_reg_0312[3]  <=1'b1;
		end
		if(~i_p1_dimm_af_pwrgd_fail_event) begin //write 0 to clear flag
			r_reg_0312[2]  <=1'b1;
		end
		if(~i_p0_dimm_gl_pwrgd_fail_event) begin //write 0 to clear flag
			r_reg_0312[1]  <=1'b1;
		end
		if(~i_p0_dimm_af_pwrgd_fail_event) begin //write 0 to clear flag
			r_reg_0312[0]  <=1'b1;
		end
	end
end
//0X03a0 
always@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n)  begin
        r_reg_03a0  <=8'h00;
    end
    else if((w_WR==1'b0)&&(w_i2c_command==16'h03a0) && w_data_vld_pos)  begin
        r_reg_03a0  <= w_i2c_data_out;
	end
	else if(i_bmc_clr_cmos | i_bmc_nmi_ctl) begin  //20220425 d50092 rdc:3743734
	    if(i_bmc_clr_cmos)  begin                  //20220425 d50092 rdc:3743734
	        r_reg_03a0[4]  <= 1'b0;
	    end 
	    if(i_bmc_nmi_ctl )  begin                  //20220425 d50092 rdc:3743734
	        r_reg_03a0[6]  <= 1'b0;                                       
        end                                
    end 
end



//0x1050
always@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n)  begin
        r_reg_1050  <=8'hff; 
    end
    else if((w_WR==1'b0)&&(w_i2c_command==16'h1050) && w_data_vld_pos)  begin
        r_reg_1050  <= w_i2c_data_out;
    end
end

//0x1051
always@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n)  begin
        r_reg_1051  <=8'hff; 
    end
    else if((w_WR==1'b0)&&(w_i2c_command==16'h1051) && w_data_vld_pos)  begin
        r_reg_1051  <= w_i2c_data_out;
    end
end

//0x1052
always@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n)  begin
        r_reg_1052  <=8'hff; 
    end
    else if((w_WR==1'b0)&&(w_i2c_command==16'h1052) && w_data_vld_pos)  begin
        r_reg_1052  <= w_i2c_data_out;
    end
end

//0x1053
always@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n)  begin
        r_reg_1053  <=8'hff; 
    end
    else if((w_WR==1'b0)&&(w_i2c_command==16'h1053) && w_data_vld_pos)  begin
        r_reg_1053  <= w_i2c_data_out;
    end
end

//0x1054
always@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n)  begin
        r_reg_1054  <=8'hff; 
    end
    else if((w_WR==1'b0)&&(w_i2c_command==16'h1054) && w_data_vld_pos)  begin
        r_reg_1054  <= w_i2c_data_out;
    end
end


///////////////////////////////////////////////////////////////////////
//i2c slave
///////////////////////////////////////////////////////////////////////
i2c_slave_bmc  #(
.DLY_LEN                 (DLY_LEN)      //3   //24.18MHz,330ns
)i2c_slave_bmc_u0(
    .i_rst_n                        (i_rst_n                  ), 
    .i_clk                            (i_clk                      ),
    .i_1ms_clk                    (i_1ms_clk              ),
    .i_rst_i2c_n                (i_rst_i2c_n          ),
    
    .i_scl                            (i_scl                      ),
    .io_sda                          (io_sda                    ),
    
    .i_i2c_address            (7'h10                      ),
    .o_i2c_start                (w_i2c_start          ),
    .o_WR                              (w_WR                        ),
    .o_data_vld_pos          (w_data_vld_pos    ),
    .o_i2c_command            (w_i2c_command      ),
    .i_i2c_data_in            (r_i2c_data_in      ),
    .o_i2c_data_out          (w_i2c_data_out    )
); 
	
endmodule 