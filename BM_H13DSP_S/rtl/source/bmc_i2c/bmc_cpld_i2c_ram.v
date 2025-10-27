
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


/*YRS36B12L RAM START*/
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
input  wire  [7:0] i_nc_pin                         ,//addr 0x000a
input  wire  [7:0] i_cpld_compa_version            ,//addr 0x000b
input  wire  [7:0] i_cpld_debug_version            ,//addr 0x000c

/*CPLD SYSTEM Register*/
//0x000d
input   wire        i_uid_btn_evt			       ,//addr 0x000d
output wire        o_uid_btn_evt_clr		       ,//addr 0x000d
input   wire        i_uid_rstbmc_evt		       ,//addr 0x000d
output wire        o_uid_rstbmc_evt_clr	       ,//addr 0x000d
//0x000e
output wire  [7:0] o_uid_led_ctl	               , //addr 0x000e		

input  wire        i_intruder_cable_inst_r_n       , //addr 0x000f bit7

input  wire        i_pal_pch_intruder              , //addr 0x000f bit4
//rst--0x0010
output wire        o_ctl_rst_i2c1_mux_n_r          , //addr 0x0010 bit7  default 1
output wire        o_ctl_rst_i2c4_mux_n_r         , //addr 0x0010 bit6  default 1
output wire        o_ctl_rst_i2c7_mux_n_r          , //addr 0x0010 bit5  default 1
output wire        o_ctl_rst_i2c10_mux_n_r          , //addr 0x0010 bit4  default 1
output wire        o_ctl_rst_i2c11_mux_n_r          , //addr 0x0010 bit3  default 1
//0x0011
input  wire        i_P0_MCIOP1A_NVME0_PRSNT_N_R      , //addr 0x0011 bit7
input  wire        i_P0_MCIOP1C_NVME0_PRSNT_N_R  , //addr 0x0011 bit6
input  wire        i_P0_MCIOP2A_NVME0_PRSNT_N_R       , //addr 0x0011 bit5
input  wire        i_P0_MCIOP2C_NVME0_PRSNT_N_R       , //addr 0x0011 bit4
input  wire        i_P0_MCIOP3A_NVME0_PRSNT_N_R       , //addr 0x0011 bit3
input  wire        i_P0_MCIOP3C_NVME0_PRSNT_N_R       , //addr 0x0011 bit2
input  wire        i_P0_MCIOG3A_NVME0_PRSNT_N_R      , //addr 0x0011 bit1
input  wire        i_P0_MCIOG3C_NVME0_PRSNT_N_R      , //addr 0x0011 bit0
//0x0012
input  wire        i_P1_MCIOP0A_NVME0_PRSNT_N_R      , //addr 0x0012 bit7
input  wire        i_P1_MCIOP0C_NVME0_PRSNT_N_R      , //addr 0x0012 bit6
input  wire        i_P1_MCIOP1A_NVME0_PRSNT_N_R      , //addr 0x0012 bit5
input  wire        i_P1_MCIOP1C_NVME0_PRSNT_N_R      , //addr 0x0012 bit4
input  wire        i_P1_MCIOP2A_NVME0_PRSNT_N_R   , //addr 0x0012 bit3
input  wire        i_P1_MCIOP2C_NVME0_PRSNT_N_R   , //addr 0x0012 bit2
input  wire        i_P1_MCIOP3A_NVME0_PRSNT_N_R       , //addr 0x0012 bit1
input  wire        i_P1_MCIOP3C_NVME0_PRSNT_N_R       , //addr 0x0012 bit0
//0x0013
input  wire        i_P1_MCIOG1A_NVME0_PRSNT_N_R       , //addr 0x0013 bit7
input  wire        i_P1_MCIOG1C_NVME0_PRSNT_N_R       , //addr 0x0013 bit6
input  wire        i_P1_MCIOP4A_NVME0_PRSNT_N_R	   , //addr 0x0013 bit5 

//PSU--0x0015
input  wire        i_PS3_PRSNT                     , //addr 0x0015 bit7
input  wire        i_PS4_PRSNT                     , //addr 0x0015 bit6
input  wire        i_PS3_ACFAIL                    , //addr 0x0015 bit5
input  wire        i_PS4_ACFAIL                    , //addr 0x0015 bit4
input  wire        i_PS3_DCOK                      , //addr 0x0015 bit3
input  wire        i_PS4_DCOK                      , //addr 0x0015 bit2
//PSU--0x0016
input  wire        i_PS3_ALERT                     , //addr 0x0016 bit7
input  wire        i_PS4_ALERT                     , //addr 0x0016 bit6
input  wire        i_PS3_P12V_ON                   , //addr 0x0016 bit5
input  wire        i_PS4_P12V_ON                   , //addr 0x0016 bit4

//0x0017
input  wire         i_P0_MCIOP1A_NVME1_PRSNT_N_R    ,   //addr 0x0017 bit7
input  wire         i_P0_MCIOP1C_NVME1_PRSNT_N_R    ,   //addr 0x0017 bit6
input  wire         i_P0_MCIOP2A_NVME1_PRSNT_N_R    ,   //addr 0x0017 bit5
input  wire         i_P0_MCIOP2C_NVME1_PRSNT_N_R    ,   //addr 0x0017 bit4
input  wire         i_P0_MCIOP3A_NVME1_PRSNT_N_R    ,   //addr 0x0017 bit3
input  wire         i_P0_MCIOP3C_NVME1_PRSNT_N_R    ,   //addr 0x0017 bit2
input  wire         i_P0_MCIOG3A_NVME1_PRSNT_N_R    ,   //addr 0x0017 bit1
input  wire         i_P0_MCIOG3C_NVME1_PRSNT_N_R    ,   //addr 0x0017 bit0
//0x0018
input  wire         i_P1_MCIOP0A_NVME1_PRSNT_N_R    ,   //addr 0x0018 bit7
input  wire         i_P1_MCIOP0C_NVME1_PRSNT_N_R    ,   //addr 0x0018 bit6
input  wire         i_P1_MCIOP1A_NVME1_PRSNT_N_R    ,   //addr 0x0018 bit5
input  wire         i_P1_MCIOP1C_NVME1_PRSNT_N_R    ,   //addr 0x0018 bit4
input  wire         i_P1_MCIOP2A_NVME1_PRSNT_N_R    ,   //addr 0x0018 bit3
input  wire         i_P1_MCIOP2C_NVME1_PRSNT_N_R    ,   //addr 0x0018 bit2
input  wire         i_P1_MCIOP3A_NVME1_PRSNT_N_R    ,   //addr 0x0018 bit1
input  wire         i_P1_MCIOP3C_NVME1_PRSNT_N_R    ,   //addr 0x0018 bit0
//0x0019
input  wire         i_P1_MCIOG1A_NVME1_PRSNT_N_R    ,   //addr 0x0019 bit7
input  wire         i_P1_MCIOG1C_NVME1_PRSNT_N_R    ,   //addr 0x0019 bit6

//ocp_prsnt--0x0021
input  wire        i_ocp1_prsnt_n                  , //addr 0x0021 bit7

//CPU1 PGD --0x0023
// input  wire        i_CPU1_PGD_PVCCIN               , //addr 0x0023 bit7
// input  wire        i_CPU1_PGD_PVCCFIVRA            , //addr 0x0023 bit6
// input  wire        i_CPU1_PGD_PVCCINFAON           , //addr 0x0023 bit5
// input  wire        i_CPU1_PGD_PVCCFA_EHV           , //addr 0x0023 bit4
// input  wire        i_CPU1_PGD_PVCCD                , //addr 0x0023 bit3
// input  wire        i_PGD_PVNN_MAIN_CPU1            , //addr 0x0023 bit2
// input  wire        i_PGD_PVPP_HBM_CPU1             , //addr 0x0023 bit1

//CPU0 ALERT --0x0024
input  wire        i_PAL_TMP1_ALERT_N             , //addr 0x0024 bit7
input  wire        i_PAL_TMP2_ALERT_N            , //addr 0x0024 bit6
input  wire        i_PAL_TMP3_ALERT_N             , //addr 0x0024 bit5
input  wire        i_PAL_TMP4_ALERT_N           , //addr 0x0024 bit4
input  wire        i_OCP1_AUX_TMPALT_R         , //addr 0x0024 bit3
input  wire        i_NCSI_620F_THERMEL_ALERT_N     , //addr 0x0024 bit2
input  wire        i_NCSI_620F_PG                  , //addr 0x0024 bit1
//0x0025
output wire        o_p0_mciop1a_gpu_throttle_n_r    , //addr 0x0025 default 0
output wire        o_p0_mciop1c_gpu_throttle_n_r    , //addr 0x0025 default 0
output wire        o_p0_mciop2a_gpu_throttle_n_r    , //addr 0x0025 default 0
output wire        o_p0_mciop2c_gpu_throttle_n_r    , //addr 0x0025 default 0
output wire        o_p0_mciop3a_gpu_throttle_n_r    , //addr 0x0025 default 0
output wire        o_p0_mciop3c_gpu_throttle_n_r    , //addr 0x0025 default 0
output wire        o_p0_mciog3a_gpu_throttle_n_r    , //addr 0x0025 default 0
output wire        o_p0_mciog3c_gpu_throttle_n_r    , //addr 0x0025 default 0
//0x0026
output wire        o_p1_mciop0a_gpu_throttle_n_r     , //addr 0x0026 default 0
output wire        o_p1_mciop0c_gpu_throttle_n_r     , //addr 0x0026 default 0
output wire        o_p1_mciop1a_gpu_throttle_n_r     , //addr 0x0026 default 0
output wire        o_p1_mciop1c_gpu_throttle_n_r     , //addr 0x0026 default 0
output wire        o_p1_mciop2a_gpu_throttle_n_r     , //addr 0x0026 default 0
output wire        o_p1_mciop2c_gpu_throttle_n_r     , //addr 0x0026 default 0
output wire        o_p1_mciop3a_gpu_throttle_n_r     , //addr 0x0026 default 0
output wire        o_p1_mciop3c_gpu_throttle_n_r     , //addr 0x0026 default 0
//0x0027
output wire        o_p1_mciog1a_gpu_throttle_n_r    , //addr 0x0027 default 0
output wire        o_p1_mciog1c_gpu_throttle_n_r    , //addr 0x0027 default 0

//0x0028
output wire        o_nic_act_flag                  , //addr 0x0028 bit6 default 0
output wire        o_sys_healthy_red               , //addr 0x0028 bit5 default 0
output wire        o_pal_mb_switch_en_n_r          , //addr 0x0028 bit4 default 1
// output wire        o_remote_xdp_debug_n_r          , //addr 0x0028 bit3 default 1
// output wire        o_remote_xdp_tck_sel_r          , //addr 0x0028 bit2 default 0
output wire        o_pal_biosrom_io11              , //addr 0x0028 bit1 default 1
output wire        o_sys_healthy_grn               , //addr 0x0028 bit0 default 0


// output wire        o_pch_gpp_e4                    , //addr 0x002a bit7 default 0
// output wire        o_pch_gpp_e5                    , //addr 0x002a bit6 default 0
// output wire        o_pch_gpp_e6                    , //addr 0x002a bit5 default 0
// output wire        o_pch_gpp_e7                    , //addr 0x002a bit4 default 0
//0x002b
output wire        o_p12v_slot_3_on                , //addr 0x002b bit7 default 1
output wire        o_p12v_slot_4_on                , //addr 0x002b bit6 default 1
output wire        o_p12v_slot_5_on                , //addr 0x002b bit5 default 1
output wire        o_p12v_slot_6_on                , //addr 0x002b bit4 default 1
output wire        o_p12v_slot_7_on                , //addr 0x002b bit3 default 1
output wire        o_p12v_slot_8_on                , //addr 0x002b bit2 default 1
output wire        o_p12v_slot_9_on                  ,//addr 0x002b bit1 default 1

// input  wire     [7:0]   i_debug_ocp_riser_board_id   //addr 0x002c          //2024-4-10 add for debug    

// //2024-3-8 add for debug
// input  wire     [7:0]   i_debug_ram_0030               , //addr 0x0030
// input  wire     [7:0]   i_debug_ram_0031               , //addr 0x0031
// input  wire     [7:0]   i_debug_ram_0032               , //addr 0x0032
// input  wire     [7:0]   i_debug_ram_0033               , //addr 0x0033
// input  wire     [7:0]   i_debug_ram_0034               , //addr 0x0034
// input  wire     [7:0]   i_debug_ram_0035               , //addr 0x0035
// input  wire     [7:0]   i_debug_ram_0036               , //addr 0x0036
// input  wire     [7:0]   i_debug_ram_0037               , //addr 0x0037
// input  wire     [7:0]   i_debug_ram_0038               , //addr 0x0038
// input  wire     [7:0]   i_debug_ram_0039               , //addr 0x0039
// input  wire     [7:0]   i_debug_ram_003a                ,//addr 0x003a
// input  wire     [7:0]   i_debug_ram_003b                ,//addr 0x003b
// input  wire     [7:0]   i_debug_ram_003c                ,//addr 0x003c
// input  wire     [7:0]   i_debug_ram_003d                ,//addr 0x003d
// input  wire     [7:0]   i_debug_ram_003e                ,//addr 0x003e
// input  wire     [7:0]   i_debug_ram_003f                //addr 0x003f




//////////////////////////////////0x00C0-0x00D0 for FIX REG/////////////////////////////////////////////////////////////////////////////

// input  wire  [7:0] i_PRODUCT_LINE_C2	              , //addr 0x00C2
// input  wire  [7:0] i_PRODUCT_GEN_ID_C3             , //addr 0x00C3
// input  wire  [7:0] i_SERVER_ID_C5                  , //addr 0x00C5
// input  wire  [7:0] i_BOARD_ID_C6                   , //addr 0x00C6


//////////////////////////////////0x00C0-0x00D0 for FIX REG/////////////////////////////////////////////////////////////////////////////

output wire        o_pal_ocp_pwrbrk_od_n_flag      , //addr 0x0029 bit7 default 0
output wire        o_pal_ocp1_switch_en_n_r        , //addr 0x0029 bit6 default 0
output wire        o_pal_ocp_smrst_n_flag          , //addr 0x0029 bit5 default 0

output wire        o_164_mr_n      , //addr 0x008A bit7 default 1

output wire   [7:0]     o_164_test_data      , //addr 0x008C  default FF

input  wire         i_LEAKAGE0_PRSNT_N    , //addr 0x008e
input  wire         i_BREAK_DET_DO_N         ,//addr 0x008e
input  wire         i_LEAKAGE_DET_DO_N    , //addr 0x008e
input  wire         i_LEAKAGE_PRSNT1_N    , //addr 0x008e
input  wire         i_BREAK_DET1_DO_N       ,//addr 0x008e
input  wire         i_LEAKAGE_DET1_DO_N     //addr 0x008e


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
wire [7:0] w_ram_000f                                                        ;

wire [7:0] w_ram_0011                                                        ;
wire [7:0] w_ram_0012                                                        ;
wire [7:0] w_ram_0013                                                        ;
// wire [7:0] w_ram_0014                                                        ;
wire [7:0] w_ram_0015                                                        ;
wire [7:0] w_ram_0016                                                        ;
wire [7:0] w_ram_0017                                                        ;
wire [7:0] w_ram_0018                                                        ;
wire [7:0] w_ram_0019                                                        ;

wire [7:0] w_ram_0021                                                        ;

// wire [7:0] w_ram_0023                                                        ;
wire [7:0] w_ram_0024                                                        ;
// wire [7:0] w_ram_0025                                                        ;
// wire [7:0] w_ram_0026                                                        ;
// wire [7:0] w_ram_002c                                                        ;

// //2024-3-8 add for debug
// wire [7:0] w_ram_0030                                                        ;
// wire [7:0] w_ram_0031                                                        ;
// wire [7:0] w_ram_0032                                                        ;
// wire [7:0] w_ram_0033                                                        ;
// wire [7:0] w_ram_0034                                                        ;
// wire [7:0] w_ram_0035                                                        ;
// wire [7:0] w_ram_0036                                                        ;
// wire [7:0] w_ram_0037                                                        ;
// wire [7:0] w_ram_0038                                                        ;
// wire [7:0] w_ram_0039                                                        ;
// wire [7:0] w_ram_003a                                                        ;
// wire [7:0] w_ram_003b                                                        ;
// wire [7:0] w_ram_003c                                                        ;
// wire [7:0] w_ram_003d                                                        ;
// wire [7:0] w_ram_003e                                                        ;
// wire [7:0] w_ram_003f                                                        ;

wire [7:0] w_ram_008e                                                        ;


////////////////////////////////////////////////////////////////////////////////////
//raed & write  register
////////////////////////////////////////////////////////////////////////////////////
reg [7:0] r_reg_0006                                                         ;
reg [7:0] r_reg_000d                                                         ;
reg [7:0] r_reg_000e                                                         ;
reg [7:0] r_reg_0010                                                         ;
reg [7:0] r_reg_0011                                                         ;

reg [7:0] r_reg_0025                                                         ;
reg [7:0] r_reg_0026                                                         ;
reg [7:0] r_reg_0027                                                         ;
reg [7:0] r_reg_0028                                                         ;
// reg [7:0] r_reg_0029                                                         ;
// reg [7:0] r_reg_002a                                                         ;
reg [7:0] r_reg_002b                                                         ;

reg [7:0] r_reg_0072                                                         ;

reg [7:0] r_reg_008a                                                         ;
reg [7:0] r_reg_008c                                                         ;

////////////////////////////////////////////////////////////////////////////////////
//RW REG assignment
////////////////////////////////////////////////////////////////////////////////////
assign  o_test_reg                   = r_reg_0006                            ;

assign  o_uid_btn_evt_clr            = r_reg_000d[1]                         ;       
assign  o_uid_rstbmc_evt_clr         = r_reg_000d[0]                         ; 

assign  o_uid_led_ctl                = r_reg_000e                            ; 


assign  o_ctl_rst_i2c1_mux_n_r       = r_reg_0010[7]                         ;
assign  o_ctl_rst_i2c4_mux_n_r        = r_reg_0010[6]                         ;
assign  o_ctl_rst_i2c7_mux_n_r       = r_reg_0010[5]                         ;
assign  o_ctl_rst_i2c10_mux_n_r     = r_reg_0010[4]                         ;
assign  o_ctl_rst_i2c11_mux_n_r     = r_reg_0010[3]                         ;

assign  o_p0_mciop1a_gpu_throttle_n_r  = r_reg_0025[7]                         ;
assign  o_p0_mciop1c_gpu_throttle_n_r  = r_reg_0025[6]                         ;
assign  o_p0_mciop2a_gpu_throttle_n_r  = r_reg_0025[5]                         ;
assign  o_p0_mciop2c_gpu_throttle_n_r  = r_reg_0025[4]                         ;
assign  o_p0_mciop3a_gpu_throttle_n_r  = r_reg_0025[3]                         ;
assign  o_p0_mciop3c_gpu_throttle_n_r  = r_reg_0025[2]                         ;
assign  o_p0_mciog3a_gpu_throttle_n_r  = r_reg_0025[1]                         ;
assign  o_p0_mciog3c_gpu_throttle_n_r  = r_reg_0025[0]                         ;

assign  o_p1_mciop0a_gpu_throttle_n_r  = r_reg_0026[7]                         ;
assign  o_p1_mciop0c_gpu_throttle_n_r  = r_reg_0026[6]                         ;
assign  o_p1_mciop1a_gpu_throttle_n_r  = r_reg_0026[5]                         ;
assign  o_p1_mciop1c_gpu_throttle_n_r  = r_reg_0026[4]                         ;
assign  o_p1_mciop2a_gpu_throttle_n_r  = r_reg_0026[3]                         ;
assign  o_p1_mciop2c_gpu_throttle_n_r  = r_reg_0026[2]                         ;
assign  o_p1_mciop3a_gpu_throttle_n_r  = r_reg_0026[1]                         ;
assign  o_p1_mciop3c_gpu_throttle_n_r  = r_reg_0026[0]                         ;

assign  o_p1_mciog1a_gpu_throttle_n_r  = r_reg_0027[7]                         ;
assign  o_p1_mciog1c_gpu_throttle_n_r  = r_reg_0027[6]                         ;

assign  o_nic_act_flag               = r_reg_0028[6]                         ;
assign  o_sys_healthy_red            = r_reg_0028[5]                         ;
assign  o_pal_mb_switch_en_n_r       = r_reg_0028[4]                         ;
// assign  o_remote_xdp_debug_n_r       = r_reg_0028[3]                         ;
// assign  o_remote_xdp_tck_sel_r       = r_reg_0028[2]                         ;
assign  o_pal_biosrom_io11           = r_reg_0028[1]                         ;
assign  o_sys_healthy_grn            = r_reg_0028[0]                         ;

assign  o_p12v_slot_3_on             = r_reg_002b[7]                         ;
assign  o_p12v_slot_4_on             = r_reg_002b[6]                         ;
assign  o_p12v_slot_5_on             = r_reg_002b[5]                         ;
assign  o_p12v_slot_6_on             = r_reg_002b[4]                         ;
assign  o_p12v_slot_7_on             = r_reg_002b[3]                         ;
assign  o_p12v_slot_8_on             = r_reg_002b[2]                         ;
assign  o_p12v_slot_9_on             = r_reg_002b[1]                         ;

assign  o_pal_ocp_pwrbrk_od_n_flag   = r_reg_0072[7]                         ;
assign  o_pal_ocp1_switch_en_n_r     = r_reg_0072[6]                         ;
assign  o_pal_ocp_smrst_n_flag       = r_reg_0072[5]                         ;

assign  o_164_mr_n                   = r_reg_008a[7]                         ; //default 1

assign  o_164_test_data              = r_reg_008c                            ;




////////////////////////////////////////////////////////////////////////////////////
//RO REG assignment
////////////////////////////////////////////////////////////////////////////////////
assign w_ram_0000    = i_product_id	                                         ;
assign w_ram_0001    = i_vender_id	                                         ;
assign w_ram_0002    = i_board_id	                                         ;
assign w_ram_0003    = i_pcb_version                                         ;
assign w_ram_0004    = i_bom_id                                              ;
assign w_ram_0005    = i_cpld_version                                        ;
assign w_ram_0007    = i_year                                                ;
assign w_ram_0008    = i_month                                               ;
assign w_ram_0009    = i_day                                                 ;
assign w_ram_000a= i_nc_pin;

assign w_ram_000b	 = i_cpld_compa_version                                  ;
assign w_ram_000c	 = i_cpld_debug_version                                  ;

assign w_ram_000d = {
                                             1'b0                            ,
                                             1'b0                            ,
                                             1'b0                            ,
                                             1'b0                            ,
                                             1'b0                            ,
                                             1'b0                            ,
                                             i_uid_btn_evt                   ,
                                             i_uid_rstbmc_evt
                                             };
			
assign w_ram_000f = {
                                             i_intruder_cable_inst_r_n       ,
                                             1'b0                            ,
                                             1'b0                   ,
                                             i_pal_pch_intruder              ,
                                             1'b0                            ,
                                             1'b0                            ,
                                             1'b0                            ,
                                             1'b0                            
                                             };		
 
assign w_ram_0011 = {
                                             i_P0_MCIOP1A_NVME0_PRSNT_N_R ,
                                             i_P0_MCIOP1C_NVME0_PRSNT_N_R ,
                                             i_P0_MCIOP2A_NVME0_PRSNT_N_R ,
                                             i_P0_MCIOP2C_NVME0_PRSNT_N_R ,
                                             i_P0_MCIOP3A_NVME0_PRSNT_N_R ,
                                             i_P0_MCIOP3C_NVME0_PRSNT_N_R ,
                                             i_P0_MCIOG3A_NVME0_PRSNT_N_R ,
                                             i_P0_MCIOG3C_NVME0_PRSNT_N_R
                                             };	
  
assign w_ram_0012 = {
                                             i_P1_MCIOP0A_NVME0_PRSNT_N_R  ,
                                             i_P1_MCIOP0C_NVME0_PRSNT_N_R  ,
                                             i_P1_MCIOP1A_NVME0_PRSNT_N_R  ,
                                             i_P1_MCIOP1C_NVME0_PRSNT_N_R  ,
                                             i_P1_MCIOP2A_NVME0_PRSNT_N_R  ,
                                             i_P1_MCIOP2C_NVME0_PRSNT_N_R  ,
                                             i_P1_MCIOP3A_NVME0_PRSNT_N_R  ,
                                             i_P1_MCIOP3C_NVME0_PRSNT_N_R
                                             };	
     
assign w_ram_0013 = {
                                             i_P1_MCIOG1A_NVME0_PRSNT_N_R      ,
                                             i_P1_MCIOG1C_NVME0_PRSNT_N_R      ,
                                             i_P1_MCIOP4A_NVME0_PRSNT_N_R      ,
                                             1'b0      ,
                                             1'b0      ,
                                             1'b0      ,
                                             1'b0     ,
                                             1'b0     
                                             };	

// assign w_ram_0014 = {
                     // i_PAL_MCIO18_NVME1_PRSNT_N      ,
                     // i_PAL_MCIO19_NVME1_PRSNT_N      ,
                     // i_PAL_MCIO20_NVME1_PRSNT_N      ,
                     // 1'b0                            ,
                     // 1'b0                            ,
                     // 1'b0                            ,
					 // 1'b0                            ,
					 // 1'b0                            
					 // };	

assign w_ram_0015 = {
                                             i_PS3_PRSNT                     ,
                                             i_PS4_PRSNT                     ,
                                             i_PS3_ACFAIL                    ,
                                             i_PS4_ACFAIL                    ,
                                             i_PS3_DCOK                      ,
                                             i_PS4_DCOK                      ,
                                             1'b0                            ,
                                             1'b0                            
                                             };	
					 
assign w_ram_0016 = {
                                             i_PS3_ALERT                     ,
                                             i_PS4_ALERT                     ,
                                             i_PS3_P12V_ON                   ,
                                             i_PS4_P12V_ON                   ,
                                             1'b0                            ,
                                             1'b0                            ,
                                             1'b0                            ,
                                             1'b0                            
                                             };					 

assign  w_ram_0017 = {
                                            i_P0_MCIOP1A_NVME1_PRSNT_N_R    ,
                                            i_P0_MCIOP1C_NVME1_PRSNT_N_R    ,
                                            i_P0_MCIOP2A_NVME1_PRSNT_N_R    ,
                                            i_P0_MCIOP2C_NVME1_PRSNT_N_R    ,
                                            i_P0_MCIOP3A_NVME1_PRSNT_N_R    ,
                                            i_P0_MCIOP3C_NVME1_PRSNT_N_R    ,
                                            i_P0_MCIOG3A_NVME1_PRSNT_N_R    ,
                                            i_P0_MCIOG3C_NVME1_PRSNT_N_R    
                                            };

assign  w_ram_0018 = {
                                            i_P1_MCIOP0A_NVME1_PRSNT_N_R    ,
                                            i_P1_MCIOP0C_NVME1_PRSNT_N_R    ,
                                            i_P1_MCIOP1A_NVME1_PRSNT_N_R    ,
                                            i_P1_MCIOP1C_NVME1_PRSNT_N_R    ,
                                            i_P1_MCIOP2A_NVME1_PRSNT_N_R    ,
                                            i_P1_MCIOP2C_NVME1_PRSNT_N_R    ,
                                            i_P1_MCIOP3A_NVME1_PRSNT_N_R    ,
                                            i_P1_MCIOP3C_NVME1_PRSNT_N_R    
                                            };

assign  w_ram_0019 = {
                                            i_P1_MCIOG1A_NVME1_PRSNT_N_R    ,
                                            i_P1_MCIOG1C_NVME1_PRSNT_N_R    ,
                                            1'b0    ,
                                            1'b0    ,
                                            1'b0    ,
                                            1'b0    ,
                                            1'b0    ,
                                            1'b0    
                                            };

		
assign w_ram_0021 = {
                                             i_ocp1_prsnt_n                  ,
                                             1'b0                            ,
                                             1'b0                            ,
                                             1'b0                            ,
                                             1'b0                            ,
                                             1'b0                            ,
                                             1'b0                            ,
                                             1'b0                            
                                             };
		
// assign w_ram_0023 = {
                     // i_CPU1_PGD_PVCCIN               ,
                     // i_CPU1_PGD_PVCCFIVRA            ,
                     // i_CPU1_PGD_PVCCINFAON           ,
                     // i_CPU1_PGD_PVCCFA_EHV           ,
                     // i_CPU1_PGD_PVCCD                ,
                     // i_PGD_PVNN_MAIN_CPU1            ,
					 // i_PGD_PVPP_HBM_CPU1             ,
					 // 1'b0                            
					 // };

assign w_ram_0024 = {
                                             i_PAL_TMP1_ALERT_N             ,
                                             i_PAL_TMP2_ALERT_N             ,
                                             i_PAL_TMP3_ALERT_N             ,
                                             i_PAL_TMP4_ALERT_N           ,
                                             i_OCP1_AUX_TMPALT_R         ,
                                             i_NCSI_620F_THERMEL_ALERT_N     ,
                                             i_NCSI_620F_PG                  ,
                                             1'b0                            
                                             };

// assign w_ram_0025 = {
                     // i_CPU1_PAL_PVCCIN_EN_R          ,
                     // i_CPU1_PAL_PVCCFIVRA_EN_R       ,
                     // i_CPU1_PAL_PVCCINFAON_EN_R      ,
                     // i_CPU1_PAL_PVCCFA_EHV_EN_R      ,
                     // i_CPU1_PAL_PVCCD_EN_R           ,
                     // i_PVNN_MAIN_CPU1_EN_R           ,
					 // i_PAL_PVPP_HBM_CPU1_EN_R        ,
					 // 1'b0                            
					 // };

// assign w_ram_0026 = {
                     // i_PU_CPU1_TXT_AGENT_R           ,
                     // i_PD_CPU1_TXT_PLTEN_R           ,
                     // i_FM_CPU1_INIT_ERROR_R          ,
                     // i_PAL_CPU1_MEMHOT_OUT_N         ,
                     // i_pch_bios_post_cmplt_n         ,
                     // 1'b0                            ,
					 // 1'b0                            ,
					 // 1'b0                            
					 // };


assign  w_ram_008e = {
                                            i_LEAKAGE0_PRSNT_N      ,
                                            i_BREAK_DET_DO_N          ,
                                            i_LEAKAGE_DET_DO_N      ,
                                            i_LEAKAGE_PRSNT1_N      ,
                                            i_BREAK_DET1_DO_N        ,
                                            i_LEAKAGE_DET1_DO_N    ,
                                            1'b0    ,
                                            1'b0    
                                            };

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
		16'h000d: r_i2c_data_in <= w_ram_000d;//Rw
		16'h000e: r_i2c_data_in <= r_reg_000e;//RW
		16'h000f: r_i2c_data_in <= w_ram_000f;//RO
		16'h0010: r_i2c_data_in <= r_reg_0010;//RW		
		16'h0011: r_i2c_data_in <= w_ram_0011;//RO
		16'h0012: r_i2c_data_in <= w_ram_0012;//RO
		16'h0013: r_i2c_data_in <= w_ram_0013;//RO
		// 16'h0014: r_i2c_data_in <= w_ram_0014;//RO
		16'h0015: r_i2c_data_in <= w_ram_0015;//RO
		16'h0016: r_i2c_data_in <= w_ram_0016;//RO
		16'h0017: r_i2c_data_in <= w_ram_0017;//RO
		16'h0018: r_i2c_data_in <= w_ram_0018;//RO
		16'h0019: r_i2c_data_in <= w_ram_0019;//RO
				
		16'h0021: r_i2c_data_in <= w_ram_0021;//RO //2024-5-31 add
		// 16'h0023: r_i2c_data_in <= w_ram_0023;//RO
		16'h0024: r_i2c_data_in <= w_ram_0024;//RO
		16'h0025: r_i2c_data_in <= r_reg_0025;//RO
		16'h0026: r_i2c_data_in <= r_reg_0026;//RO
		16'h0027: r_i2c_data_in <= r_reg_0027;//RW
		16'h0028: r_i2c_data_in <= r_reg_0028;//RW
		// 16'h0029: r_i2c_data_in <= r_reg_0029;//RW
		// 16'h002a: r_i2c_data_in <= r_reg_002a;//RW
		16'h002b: r_i2c_data_in <= r_reg_002b;//RW
		// 16'h002c: r_i2c_data_in <= w_ram_002c;//RO //2024-4-10 add for debug
		16'h0072: r_i2c_data_in <= r_reg_0072;//RW
		16'h008a: r_i2c_data_in <= r_reg_008a;//RW
		16'h008c: r_i2c_data_in <= r_reg_008c;//RW

		16'h008e: r_i2c_data_in <= w_ram_008e;//RO	
		
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

//0x000d
always@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n)  begin
        r_reg_000d  <=8'hff;
    end
    else if((w_WR==1'b0)&&(w_i2c_command==16'h000d) && w_data_vld_pos)  begin
        r_reg_000d  <= w_i2c_data_out;
    end
	else if(~i_uid_btn_evt) begin
		r_reg_000d[1] <= 1'b1;
    end
	else if(~i_uid_rstbmc_evt) begin
		r_reg_000d[0] <= 1'b1;
	end	
end

//0x000e
always@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n)  begin
        r_reg_000e  <=8'h00;
    end
    else if((w_WR==1'b0)&&(w_i2c_command==16'h000e) && w_data_vld_pos)  begin
        r_reg_000e  <= w_i2c_data_out;
    end
end

//0x0010
always@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n)  begin
        r_reg_0010  <=8'hf8;
    end
    else if((w_WR==1'b0)&&(w_i2c_command==16'h0010) && w_data_vld_pos)  begin
        r_reg_0010  <= w_i2c_data_out;
    end
end

//0x0025
always@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n)  begin
        r_reg_0025  <=8'h00;
    end
    else if((w_WR==1'b0)&&(w_i2c_command==16'h0025) && w_data_vld_pos)  begin
        r_reg_0025  <= w_i2c_data_out;
    end
end

//0x0026
always@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n)  begin
        r_reg_0026  <=8'h00;
    end
    else if((w_WR==1'b0)&&(w_i2c_command==16'h0026) && w_data_vld_pos)  begin
        r_reg_0026  <= w_i2c_data_out;
    end
end

//0x0027
always@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n)  begin
        r_reg_0027  <=8'h00;
    end
    else if((w_WR==1'b0)&&(w_i2c_command==16'h0027) && w_data_vld_pos)  begin
        r_reg_0027  <= w_i2c_data_out;
    end
end

//0x0028
always@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n)  begin
        r_reg_0028  <=8'h1a;
    end
    else if((w_WR==1'b0)&&(w_i2c_command==16'h0028) && w_data_vld_pos)  begin
        r_reg_0028  <= w_i2c_data_out;
    end
end

//0x0072
always@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n)  begin
        r_reg_0072  <=8'h00;
    end
    else if((w_WR==1'b0)&&(w_i2c_command==16'h0072) && w_data_vld_pos)  begin
        r_reg_0072  <= w_i2c_data_out;
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
        r_reg_008c  <=8'hff;
    end
    else if((w_WR==1'b0)&&(w_i2c_command==16'h008c) && w_data_vld_pos)  begin
        r_reg_008c  <= w_i2c_data_out;
    end
end




//0x002a
// always@(posedge i_clk or negedge i_rst_n) begin
    // if(~i_rst_n)  begin
        // r_reg_002a  <=8'h00;
    // end
    // else if((w_WR==1'b0)&&(w_i2c_command==16'h002a) && w_data_vld_pos)  begin
        // r_reg_002a  <= w_i2c_data_out;
    // end
// end

//0x002b
always@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n)  begin
        r_reg_002b  <=8'hff;
    end
    else if((w_WR==1'b0)&&(w_i2c_command==16'h002b) && w_data_vld_pos)  begin
        r_reg_002b  <= w_i2c_data_out;
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