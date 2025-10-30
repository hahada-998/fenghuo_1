//=================================================================================================
// Copyright(c) 
// Filename   : BM_H13DSP_S_TOP
// Project    : BM_H13DSP_S
// Author     : 
// Date       : 2024-08-28
//Simulator   : Lattice Diamond 3.12
//FPGA        : LCMXO2_4000HC_4BG256C
// Email      : cloudnineinfo.com
// Company    : 
// Description: BM_H13DSP_S Top Code
// History    :
// Date      By          Revision  Change Description
//------------------------------------------------------------------------------
//-- Principle of Naming:
//-- In BM_H13DSP_S  : ONE CPLD,this Code for Master CPLD_U1
//-- CPLD     BOARD NAME            PCB CODE        BOARD ID     TAG NO    JTAG CON

//-- CPLD     BM_H13DSP_S      

//-------------------------------------------------------------------------------
//=================================================================================================
`include "BM_H13DSP_S_VA_PORT.v"
//`include "BM_H13SSP_define.vh" 
// `include "pwrseq_define.vh" 
//---------------------------------------------------------
// define parameter
//--------------------------------------------------------
`define PRODUCT_ID             8'h33
`define VENDER_ID               8'h08

`define Year                         8'h25
`define Month                       8'h03
`define Day                           8'h13
`define CPLD_VERSION         8'h01
`define DEBUG_VERSION       8'h00

//--------------------------------------------------------------------------------------------------------------------------------------------------
//For pll_inst
//--------------------------------------------------------------------------------------------------------------------------------------------------
wire clk_50m ;
wire clk_25m ;
wire clk_2p5m ;
wire pll_lock;
//--------------------------------------------------------------------------------------------------------------------------------------------------
//For timer_gen_inst
//--------------------------------------------------------------------------------------------------------------------------------------------------
wire t40ns_tick		;
wire t1us_tick		;
wire t2us_tick		; 
wire t16us_tick		;
wire t32us_tick		;
wire t128us_tick	;
wire t512us_tick	;
wire t1ms_tick		;
wire t2ms_tick		;
wire t16ms_tick		;
wire t32ms_tick		;
wire t64ms_tick		;
wire t128ms_tick	;
wire t256ms_tick	;
wire t512ms_tick	;
wire t1s_tick		;
wire t1hz_clk		;
wire t0p5hz_clk		;
wire t2p5hz_clk		;
wire t4hz_clk		;
wire t16khz_clk		;
wire t6m25_clk		;
wire t16m6_clk		;
 
//-------------------------------------------------------------------------------------------------
//For clk tree
//-------------------------------------------------------------------------------------------------
wire       w1uSCE                                             ;
wire       w10uSCE                                            ;
wire       w50uSCE                                            ;
wire       w500uSCE                                           ;
wire       w1mSCE                                             ;
wire       w250mSCE                                           ;
wire       w10mSCE                                            ;
wire       w20mSCE                                            ;
wire       w1SCE                                              ;
//--------------------------------------------------------------------------------------------------------------------------------------------------
//For pon_reset_inst
//--------------------------------------------------------------------------------------------------------------------------------------------------
wire pon_reset_n			; 
wire pon_reset_db_n			;      
wire pgd_aux_system			; 
wire pgd_aux_system_sasd	; 
wire pgd_aux_bmc			;		//From CMU 
wire done_booting_delayed = 1'b1;	//input; define constant 1

assign pgd_aux_bmc = 1'b1	;
										   
//--------------------------------------------------------------------------------------------------------------------------------------
// sys clock
//--------------------------------------------------------------------------------------------------------------------------------------
pll_i25M_o50M_o25M pll_inst(
  .CLKI     (i_CLK_PAL2_IN_25M         ), //in
  .RST       (~i_CPLD2_PROGRAM_N   ), //in  
  .CLKOP   (clk_50m                       ), //out
  .CLKOS   (clk_25m                       ), //out
  // .CLKOS2 (clk_2p5m                     ),
  .LOCK     (pll_lock                     )  //out
);
//------------------------------------------------------------------------------------------------------------------------------------------
// SYS RST
//------------------------------------------------------------------------------------------------------------------------------------------
pon_reset pon_reset_inst(
  .clk					(clk_50m				),	//in
  .pll_lock				(pll_lock				),	//in
  .pgd_p3v3_stby		        (i_CPLD2_PROGRAM_N	        ),	//in
  .pgd_aux_gmt			(pgd_aux_bmc			),	//in, all BMC power ok
  .done_booting			(1'b1					),	//in
  .done_booting_delayed	(done_booting_delayed	),	//in;  delayed version of done_booting (if not used, set to 1'b1)
  .pon_reset_n			(pon_reset_n			),	//out; master AUX power-on reset (based on pgd_p3v3_stby)
  .pon_reset_db_n		(pon_reset_db_n			),	//out; when done_booting_delayed not usd;  pon_reset_db_n = pon_reset_n. 
  .pgd_aux_system		(pgd_aux_system			),	//out; AUX pgood indicator (based on both pgd_p3v3_stby and pgd_aux_gmt) pgd_aux_gmt means BMC p2v5/ BMC p1v2/ BMC p1v1/ BMC p1v0 pgd power good.
  .pgd_aux_system_sasd	(pgd_aux_system_sasd	),	//out; SASD version of pgd_aux_system; pgd_aux_system_sasd = pgd_aux_system
  .cpld_ready			(	)
);
//--------------------------------------------------------------------------------------------------------------------------------------------------
// Generate timer ticks (1-clk wide pulse) and slow 50% duty cycle clock
//--------------------------------------------------------------------------------------------------------------------------------------------------
timer_gen timer_gen_inst(
  .clk               (clk_50m          ),
  .reset           (~pon_reset_n),
  .t40ns           (t40ns_tick    ),
  .t80ns           (),
  .t160ns         (),
  .t1us             (t1us_tick     ),
  .t2us             (t2us_tick     ),
  .t16us           (t16us_tick   ),
  .t32us           (t32us_tick   ),
  .t128us         (t128us_tick ),
  .t512us         (t512us_tick ),
  .t1ms             (t1ms_tick     ),
  .t2ms             (t2ms_tick     ),
  .t16ms           (),
  .t32ms           (t32ms_tick   ),
  .t64ms           (t64ms_tick   ),
  .t128ms         (t128ms_tick ),
  .t256ms         (t256ms_tick ),
  .t512ms         (t512ms_tick ),
  .t1s               (t1s_tick       ),
  .clk_1hz       (t1hz_clk       ),
  .clk_0p5hz   (t0p5hz_clk	  ),
  .clk_2p5hz   (t2p5hz_clk   ),
  .clk_4hz       (t4hz_clk       ),
  .clk_16khz   (t16khz_clk   ),
  .clk_6m25     (t6m25_clk     ),
  .clk_16m6	 (t16m6_clk	  )
);
//-------------------------------------------------------------------------------------------------
//Clock generation and CE
//-------------------------------------------------------------------------------------------------
//% Clock divider three - Generates the following synchronous clock enables: 10uS, 50uS, 500uS, 1mS, 20mS and 250mS
ClkDivTree mClkDivTree
(
    .iClk           ( clk_50m            ),
    .iRst           ( ~pon_reset_n  ),
    .o1uSCE       ( w1uSCE              ),
    .o10uSCE     ( w10uSCE            ),
    .o50uSCE     ( w50uSCE            ),
    .o500uSCE   ( w500uSCE          ),
    .o1mSCE       ( w1mSCE              ),
    .o250mSCE   ( w250mSCE          ),
    .o10mSCE     ( w10mSCE            ),
    .o20mSCE     ( w20mSCE            ),
    .o1SCE         ( w1SCE                )
);
/************************************************************************************************************************************************************************/
//--------------------------------------------------------------------------------------------------------------------------------------------------
//I2C Update Start
//--------------------------------------------------------------------------------------------------------------------------------------------------
/************************************************************************************************************************************************************************/
wire wb_clk;
defparam inst_osch.NOM_FREQ = "4.29";
OSCH inst_osch(
.STDBY		(1'b0		),
.OSC		(wb_clk		),
.SEDSTDBY	(			)
);
I2C_UPDATE inst_i2c_update_flash_config(
.wb_clk_i	(wb_clk	),
.wb_rst_i	(		),
.wb_cyc_i	(		),
.wb_stb_i	(		),
.wb_we_i	(		),
.wb_adr_i	(		),
.wb_dat_i	(		),
.wb_dat_o	(		),
.wb_ack_o	(		),
.i2c1_irqo	(		),
.wbc_ufm_irq(              ),
.i2c1_scl	(io_I2C2_2_UPDATE_SCL	),
.i2c1_sda	(io_I2C2_2_UPDATE_SDA	)
); 
/************************************************************************************************************************************************************************/
//--------------------------------------------------------------------------------------------------------------------------------------------------
//I2C Update End
//--------------------------------------------------------------------------------------------------------------------------------------------------
/************************************************************************************************************************************************************************/
wire    w_p0_mciop0a_gpu_throttle_n_r;
wire    w_p0_mciop0c_gpu_throttle_n_r;
wire    w_p0_mciop1a_gpu_throttle_n_r;
wire    w_p0_mciop1c_gpu_throttle_n_r;
wire    w_p0_mciop2a_gpu_throttle_n_r;
wire    w_p0_mciop2c_gpu_throttle_n_r;
wire    w_p0_mciop3a_gpu_throttle_n_r;
wire    w_p0_mciop3c_gpu_throttle_n_r;
wire    w_p0_mciog3a_gpu_throttle_n_r;
wire    w_p0_mciog3c_gpu_throttle_n_r;
wire    w_p1_mciop0a_gpu_throttle_n_r;
wire    w_p1_mciop0c_gpu_throttle_n_r;
wire    w_p1_mciop1a_gpu_throttle_n_r;
wire    w_p1_mciop1c_gpu_throttle_n_r;
wire    w_p1_mciop2a_gpu_throttle_n_r;
wire    w_p1_mciop2c_gpu_throttle_n_r;
wire    w_p1_mciop3a_gpu_throttle_n_r;
wire    w_p1_mciop3c_gpu_throttle_n_r;
wire    w_p1_mciog1a_gpu_throttle_n_r;
wire    w_p1_mciog1c_gpu_throttle_n_r;

wire    w_ctl_rst_i2c1_mux_n_r    ;
wire    w_ctl_rst_i2c2_mux_n_r    ;
wire    w_ctl_rst_i2c3_mux_n_r    ;
// wire    w_ctl_rst_i2c4_mux_n_r     ;
// wire    w_ctl_rst_i2c7_mux_n_r     ;
// wire    w_usb_sw_s_r;
wire    w_pal_p12v_cpu0_dimm_on;
wire    w_pal_p12v_cpu1_dimm_on;

wire    w_sw_bios_flash_spi_s_r;
wire    w_sw_bios_qspi_s_r;
wire    w_sw_bios_spi_oe;
wire    w_sw_qspi_oe_r;
wire    w_bios_flash_reset_r_n;

wire    db_i_ps1_prsnt                    ;
wire    db_i_ps1_dcok_n                  ;
wire    db_i_ps1_smb_alert            ;
wire    db_i_ps1_acfail_n              ;
wire    db_i_ps2_prsnt                    ;
wire    db_i_ps2_dcok_n                  ;
wire    db_i_ps2_smb_alert            ;
wire    db_i_ps2_acfail_n              ;
wire    db_i_ps3_prsnt                    ;
wire    db_i_ps4_prsnt                    ;
wire    db_i_pal_ocp1_pwrgd;
wire    db_i_pal_ocp1_pgd;
wire    db_i_uid_sw_in_n;

//
wire    w_PWRGD_P12V_PS3_PS4;
wire    w_PWRGD_P12V;
wire    w_PS3_PS4_ACFAIL;
wire    w_FM_P12V_EN;
wire    w_P0_SLP_S5_N;
wire    w_P0_SLP_S3_N;
wire    w_pgd_p3v3_stby;
wire    w_pgd_p1v2_stby;
wire    w_bmc_ready_flag;
wire    w_PAL_OCP1_PRSNT_B2_N;
wire    w_PAL_OCP1_PRSNT_B1_N;
wire    w_PAL_OCP1_PRSNT_B0_N;
wire    [7:0]   w_led_control;
wire    w_pgd_p5v;
wire    w_PAL_BP6_PRSNT_N;
wire    w_P1_MCIOP3C_CB_ID1_R;
wire    w_P1_MCIOP3C_CB_ID0_R;
wire    w_P1_MCIOP3A_CB_ID1_R;
wire    w_P1_MCIOP3A_CB_ID0_R;
wire    w_P1_MCIOP2C_CB_ID1_R;
wire    w_P1_MCIOP2C_CB_ID0_R;
wire    w_P1_MCIOP2A_CB_ID1_R;
wire    w_P1_MCIOP2A_CB_ID0_R;
wire    w_P1_MCIOP1C_CB_ID1_R;
wire    w_P1_MCIOP1C_CB_ID0_R;
wire    w_P1_MCIOP1A_CB_ID1_R;
wire    w_P1_MCIOP1A_CB_ID0_R;
wire    w_P1_MCIOP0C_CB_ID1_R;
wire    w_P1_MCIOP0C_CB_ID0_R;
wire    w_P1_MCIOP0A_CB_ID1_R;
wire    w_P1_MCIOP0A_CB_ID0_R;
wire    w_P1_MCIOG1C_CB_ID1_R;
wire    w_P1_MCIOG1C_CB_ID0_R;
wire    w_P1_MCIOG1A_CB_ID1_R;
wire    w_P1_MCIOG1A_CB_ID0_R;
wire    w_P1_MCIOP4A_CB_ID1_R;

wire    w_P0_MCIOP3C_CB_ID1_R;
wire    w_P0_MCIOP3C_CB_ID0_R;
wire    w_P0_MCIOP3A_CB_ID1_R;
wire    w_P0_MCIOP3A_CB_ID0_R;
wire    w_P0_MCIOP2C_CB_ID1_R;
wire    w_P0_MCIOP2C_CB_ID0_R;
wire    w_P0_MCIOP2A_CB_ID1_R;
wire    w_P0_MCIOP2A_CB_ID0_R;
wire    w_P0_MCIOP1C_CB_ID1_R;
wire    w_P0_MCIOP1C_CB_ID0_R;
wire    w_P0_MCIOP1A_CB_ID1_R;
wire    w_P0_MCIOP1A_CB_ID0_R;
wire    w_P0_MCIOP0C_CB_ID1_R;
wire    w_P0_MCIOP0C_CB_ID0_R;
wire    w_P0_MCIOP0A_CB_ID1_R;
wire    w_P0_MCIOP0A_CB_ID0_R;
wire    w_P0_MCIOG3C_CB_ID1_R;
wire    w_P0_MCIOG3C_CB_ID0_R;
wire    w_P0_MCIOG3A_CB_ID1_R;
wire    w_P0_MCIOG3A_CB_ID0_R;
wire    w_P0_MCIOP4A_CB_ID1_R;
wire    w_p1_pcie_wake_n_r        ;
wire    w_p0_pcie_wake_n_r        ;
//
wire    w_p1_pcie_rst_n_1;
wire    w_p1_pcie_rst_n_0;
wire    w_p0_pcie_rst_n_1;
wire    w_p0_pcie_rst_n_0;
wire    w_p12v_discharge_r;
wire    w_uid_sw_in_n;
// wire    w_ocp_prsnt_n;
wire    w_cpld2_jtagen;
wire    w_p12v_slot_3_on;
wire    w_p12v_slot_4_on;
wire    w_p12v_slot_5_on;
wire    w_p12v_slot_6_on;
wire    w_p12v_slot_7_on;
wire    w_p12v_slot_8_on;
wire    w_p12v_slot_9_on;
wire    w_p12v_slot_3_on_r;
wire    w_p12v_slot_4_on_r;
wire    w_p12v_slot_5_on_r;
wire    w_p12v_slot_6_on_r;
wire    w_p12v_slot_7_on_r;
wire    w_p12v_slot_8_on_r;
wire    w_p12v_slot_9_on_r;
wire    w_slot_3_on_dly_10ms;
wire    w_slot_4_on_dly_10ms;
wire    w_slot_5_on_dly_10ms;
wire    w_slot_6_on_dly_10ms;
wire    w_slot_7_on_dly_10ms;
wire    w_slot_8_on_dly_10ms;
wire    w_slot_9_on_dly_10ms;
wire    w_pal_ocp1_mainpwr_on_r      ;
wire    w_pal_ocp1_auxpwr_on_r       ;
wire    w_ps3_p12v_on_r ;
wire    w_ps4_p12v_on_r ;
wire    w_clk_db2000_2_1_oe_n  ;
wire    w_clk_db2000_2_2_oe_n  ;
wire    w_pal_pwr_lom_en_r;


wire    [7:0]   w_p0_mciop1a_slot_id;//0
wire    [7:0]   w_p0_mciop1c_slot_id;//1
wire    [7:0]   w_p0_mciop2a_slot_id;//2
wire    [7:0]   w_p0_mciop2c_slot_id;//3
wire    [7:0]   w_p0_mciop3a_slot_id;//4
wire    [7:0]   w_p0_mciop3c_slot_id;//5
wire    [7:0]   w_p0_mciog3a_slot_id;//6
wire    [7:0]   w_p0_mciog3c_slot_id;//7
wire    [7:0]   w_p1_mciog1a_slot_id;//8
wire    [7:0]   w_p1_mciog1c_slot_id;//9
wire    [7:0]   w_p1_mciop0a_slot_id;//10
wire    [7:0]   w_p1_mciop0c_slot_id;//11
wire    [7:0]   w_p1_mciop1a_slot_id;//12
wire    [7:0]   w_p1_mciop1c_slot_id;//13
wire    [7:0]   w_p1_mciop2a_slot_id;//14
wire    [7:0]   w_p1_mciop2c_slot_id;//15
wire    [7:0]   w_p1_mciop3a_slot_id;//16
wire    [7:0]   w_p1_mciop3c_slot_id;//17

wire    w_uid_btn_evt_wc;
wire    w_uid_rstbmc_evt_wc;
wire    uid_btn_all_invert;
wire    uid_button_long_evt;
wire    uid_button_short_evt;
wire    [7:0]   w_uid_led_ctl;
wire    w_bmc_extrst_uid;

wire	w_clk_gen_intr_n_r;
wire    w_clk_gen_lol_n_r;
wire    w_clk_gen_finc_r;
wire    w_clk_gen_rst_n_r;
wire    w_clk_gen_oe_nr_r;
wire    w_clk_gen_fdec_r;
wire    w_clk_i2c_sel_r;
//-------------------------------------------------------------------------------------------------
// MCIO ID  Assign
// ------------------------------------------------------------------------------------------------
assign w_P0_MCIOP0A_CB_ID0_R = i_P0_MCIOP0A_CB_ID0_R;
assign w_P0_MCIOP0A_CB_ID1_R = i_P0_MCIOP0A_CB_ID1_R;
assign w_P0_MCIOP0C_CB_ID0_R = i_P0_MCIOP0C_CB_ID0_R;
assign w_P0_MCIOP0C_CB_ID1_R = i_P0_MCIOP0C_CB_ID1_R;
assign w_P0_MCIOP1A_CB_ID0_R = i_P0_MCIOP1A_CB_ID0_R;
assign w_P0_MCIOP1A_CB_ID1_R = i_P0_MCIOP1A_CB_ID1_R;
assign w_P0_MCIOP1C_CB_ID0_R = i_P0_MCIOP1C_CB_ID0_R;
assign w_P0_MCIOP1C_CB_ID1_R = i_P0_MCIOP1C_CB_ID1_R;
assign w_P0_MCIOP2A_CB_ID0_R = i_P0_MCIOP2A_CB_ID0_R;
assign w_P0_MCIOP2A_CB_ID1_R = i_P0_MCIOP2A_CB_ID1_R;
assign w_P0_MCIOP2C_CB_ID0_R = i_P0_MCIOP2C_CB_ID0_R;
assign w_P0_MCIOP2C_CB_ID1_R = i_P0_MCIOP2C_CB_ID1_R;
assign w_P0_MCIOP3A_CB_ID0_R = i_P0_MCIOP3A_CB_ID0_R;
assign w_P0_MCIOP3A_CB_ID1_R = i_P0_MCIOP3A_CB_ID1_R;
assign w_P0_MCIOP3C_CB_ID0_R = i_P0_MCIOP3C_CB_ID0_R;
assign w_P0_MCIOP3C_CB_ID1_R = i_P0_MCIOP3C_CB_ID1_R;
assign w_P0_MCIOG3A_CB_ID0_R = i_P0_MCIOG3A_CB_ID0_R;
assign w_P0_MCIOG3A_CB_ID1_R = i_P0_MCIOG3A_CB_ID1_R;
assign w_P0_MCIOG3C_CB_ID0_R = i_P0_MCIOG3C_CB_ID0_R;
assign w_P0_MCIOG3C_CB_ID1_R = i_P0_MCIOG3C_CB_ID1_R;
assign w_P0_MCIOP4A_CB_ID1_R = i_P0_MCIOP4A_CB_ID1_R;

assign w_P1_MCIOP0A_CB_ID0_R = i_P1_MCIOP0A_CB_ID0_R;
assign w_P1_MCIOP0A_CB_ID1_R = i_P1_MCIOP0A_CB_ID1_R;
assign w_P1_MCIOP0C_CB_ID0_R = i_P1_MCIOP0C_CB_ID0_R;
assign w_P1_MCIOP0C_CB_ID1_R = i_P1_MCIOP0C_CB_ID1_R;
assign w_P1_MCIOP1A_CB_ID0_R = i_P1_MCIOP1A_CB_ID0_R;
assign w_P1_MCIOP1A_CB_ID1_R = i_P1_MCIOP1A_CB_ID1_R;
assign w_P1_MCIOP1C_CB_ID0_R = i_P1_MCIOP1C_CB_ID0_R;
assign w_P1_MCIOP1C_CB_ID1_R = i_P1_MCIOP1C_CB_ID1_R;
assign w_P1_MCIOP2A_CB_ID0_R = i_P1_MCIOP2A_CB_ID0_R;
assign w_P1_MCIOP2A_CB_ID1_R = i_P1_MCIOP2A_CB_ID1_R;
assign w_P1_MCIOP2C_CB_ID0_R = i_P1_MCIOP2C_CB_ID0_R;
assign w_P1_MCIOP2C_CB_ID1_R = i_P1_MCIOP2C_CB_ID1_R;
assign w_P1_MCIOP3A_CB_ID0_R = i_P1_MCIOP3A_CB_ID0_R;
assign w_P1_MCIOP3A_CB_ID1_R = i_P1_MCIOP3A_CB_ID1_R;
assign w_P1_MCIOP3C_CB_ID0_R = i_P1_MCIOP3C_CB_ID0_R;
assign w_P1_MCIOP3C_CB_ID1_R = i_P1_MCIOP3C_CB_ID1_R;
assign w_P1_MCIOG1A_CB_ID0_R = i_P1_MCIOG1A_CB_ID0_R;
assign w_P1_MCIOG1A_CB_ID1_R = i_P1_MCIOG1A_CB_ID1_R;
assign w_P1_MCIOG1C_CB_ID0_R = i_P1_MCIOG1C_CB_ID0_R;
assign w_P1_MCIOG1C_CB_ID1_R = i_P1_MCIOG1C_CB_ID1_R;
assign w_P1_MCIOP4A_CB_ID1_R = i_P1_MCIOP4A_CB_ID1_R;


//-------------------------------------------------------------------------------------------------
// for PSU Signal DEBOUNCE        8 Signal   PSU（电源模块）
// ------------------------------------------------------------------------------------------------
// PGM_DEBOUNCE #(.SIGCNT(8), .NBITS(2'b10), .ENABLE(1'b1)) db_inst_psu (
//   .clk(clk_50m),                          // 输入时钟：50MHz系统时钟，用于去抖逻辑同步
//   .rst(~pon_reset_n),                     // 复位信号：低电平有效（取反pon_reset_n，即pon_reset_n=0时复位生效）
//                                           // - 复位时，去抖模块输出默认值，避免复位期间误判
//   .timer_tick(t64ms_tick),                // 定时器脉冲：64ms周期的脉冲信号，用于控制去抖时长
//                                           // - 每64ms触发一次采样，确保信号稳定至少64ms后才更新输出
//   .din({                                  // 输入信号集合（8路PSU原始信号，未去抖）
//                  i_PS3_PRSNT,             // 1. PS3电源模块存在检测信号（高/低电平表示是否插入）
//                  i_PS3_DCOK_N,            // 2. PS3直流输出正常信号（低电平有效：0=输出正常，1=异常）
//                  i_PS3_SMB_ALERT,         // 3. PS3的SMBus告警信号（高电平表示存在通信或故障告警）
//                  i_PS3_ACFAIL_N,          // 4. PS3交流输入故障信号（低电平有效：0=交流输入故障，1=正常）
//                  i_PS4_PRSNT,             // 5. PS4电源模块存在检测信号（同PS3，对应第4个电源模块）
//                  i_PS4_DCOK_N,            // 6. PS4直流输出正常信号（同PS3）
//                  i_PS4_SMB_ALERT,         // 7. PS4的SMBus告警信号（同PS3）
//                  i_PS4_ACFAIL_N           // 8. PS4交流输入故障信号（同PS3）
//   }),
//   .dout({                                  // 输出信号集合（8路去抖后信号，稳定可靠）
//                  db_i_ps3_prsnt,          // 1. 去抖后的PS3存在信号
//                  db_i_ps3_dcok_n,         // 2. 去抖后的PS3直流输出正常信号
//                  db_i_ps3_smb_alert,      // 3. 去抖后的PS3 SMBus告警信号
//                  db_i_ps3_acfail_n,       // 4. 去抖后的PS3交流输入故障信号
//                  db_i_ps4_prsnt,          // 5. 去抖后的PS4存在信号
//                  db_i_ps4_dcok_n,         // 6. 去抖后的PS4直流输出正常信号
//                  db_i_ps4_smb_alert,      // 7. 去抖后的PS4 SMBus告警信号
//                  db_i_ps4_acfail_n        // 8. 去抖后的PS4交流输入故障信号
//   })
// );

//--------------------------------------------------------------------------------------------------------------------------------------------------
// PWRGOOD DEBOUNCE
//--------------------------------------------------------------------------------------------------------------------------------------------------
// PGM_DEBOUNCE_N #(.SIGCNT(2), .NBITS(2'b11), .ENABLE(1'b1)) db_inst_pwrgood (
//   .clk			(clk_50m),
//   .rst_n		(pon_reset_n),
//   .timer_tick	(1'b1),
//   .din({
//                 i_PAL_OCP1_PWRGD        ,//01
//                 i_PAL_OCP1_PGD              //02
// 	 }),             
//   .dout({
//                 db_i_pal_ocp1_pwrgd        ,//01
//                 db_i_pal_ocp1_pgd              //02
// 	  }) 
// );

// PGM_DEBOUNCE #(.SIGCNT(1), .NBITS(2'b10), .ENABLE(1'b1)) db_inst_uid_btn(
//   .clk(clk_50m),
//   .rst(~pon_reset_n),
//   .timer_tick(t32ms_tick),
//   .din({
// 		i_UID_SW_IN_N &&w_uid_sw_in_n    //01

// 	   }),             
//   .dout({
// 		db_i_uid_sw_in_n //01

//        }) 
// );

//-----------------------------------------------------------------------------------------------//
// Version and Board ID Signals Assignment
//-----------------------------------------------------------------------------------------------//
wire    w_PCA_REVISION_2;
wire    w_TPM_MODULE_PRSNT_N;
wire    w_BOARD_ID2;
wire    w_BOARD_ID3;
wire    w_BOARD_ID0;
wire    w_BOARD_ID1;
wire    w_PCA_REVISION_1;
wire    w_PCA_REVISION_0;
wire    w_PCB_REVISION_2;
wire    w_PCB_REVISION_1;
wire    w_PCB_REVISION_0;
wire    w_PAL_NODE1_TYPE;
wire    w_PAL_MEN_CPU_SHTDN_R;
wire    w_PAL_S5_CPU_SHTDN;	

wire [5:0]pvti_ss_count;


assign    w_BOARD_ID2 = i_BOARD_ID2;
assign    w_BOARD_ID3 = i_BOARD_ID3;
assign    w_BOARD_ID0 = i_BOARD_ID0;
assign    w_BOARD_ID1 = i_BOARD_ID1;
assign w_PCA_REVISION_0 = i_PCA_REVISION_0;
assign w_PCA_REVISION_1 = i_PCA_REVISION_1;	
assign w_PCA_REVISION_2 = i_PCA_REVISION_2;	
assign w_PCB_REVISION_0 = i_PCB_REVISION_0;
assign w_PCB_REVISION_1 = i_PCB_REVISION_1;	
assign w_PCB_REVISION_2 = i_PCB_REVISION_2;	
assign w_TPM_MODULE_PRSNT_N = i_PAL_TPM_MODULE_PRSNT_N;	
assign w_PAL_NODE1_TYPE = i_PAL_NODE1_TYPE;	
assign w_PAL_MEN_CPU_SHTDN_R = i_PAL_MEN_CPU_SHTDN_R;
assign w_PAL_S5_CPU_SHTDN = i_PAL_S5_CPU_SHTDN_R;	
// 并行转串行（PVT GPI）接口模块：用于读取板载多个硬件状态信号（如存在检测、版本信息、电源良好等），通过串行接口传输并转换为并行数据
// 参数说明：
// - .TOTAL_BIT_COUNT(48)：总数据位数为48位（对应6组8位数据，分别来自不同硬件检测芯片）
// - .DEFAULT_STATE(48'h0)：复位时默认输出48位全0
// - .NUMBER_OF_COUNTER_BITS(6)：位索引计数器位宽为6位（可计数0~63，覆盖48位数据需求）
// pvt_gpi #(
//   .TOTAL_BIT_COUNT(48),
//   .DEFAULT_STATE(48'h0),
//   .NUMBER_OF_COUNTER_BITS(6)
// ) pvt_gpi_MB_inst (
//   .clk           (clk_50m),          // 输入时钟：50MHz系统时钟，用于模块内部逻辑同步
//   .reset_n       (pon_reset_n),      // 复位信号：高电平有效（pon_reset_n=1时正常工作，0时复位至默认状态）
//   .clk_ena       (t16us_tick),       // 时钟使能信号：16us周期的脉冲，控制串行数据传输速率
//   .serclk_in     (o_PVT2_SS_CLK_R),   // 串行时钟输入：来自PVT2模块的同步时钟（经同步处理，_R表示去抖/同步）
//   .par_load_in_n (o_PVT2_SS_LD_N_R),  // 并行加载使能输入（低电平有效）：控制数据锁存（_R表示同步处理）
//   .sdi           (i_PVT2_SS_DATI  ),  // 串行数据输入：从PVT2模块接收的串行数据流（硬件状态信号的串行形式）
//   .bit_idx_in    (pvti_ss_count),    // 位索引输入：当前传输的位编号（0~47），用于定位数据位
//   .bit_idx_out   (pvti_ss_count),    // 位索引输出：与输入一致（反馈当前位编号，用于闭环控制）
//   .serclk_out    (o_PVT2_SS_CLK_R ),  // 串行时钟输出：驱动PVT2模块的时钟信号（与输入复用，确保时序同步）
//   .par_load_out_n(o_PVT2_SS_LD_N_R),  // 并行加载使能输出：输出到PVT2模块的锁存控制信号（与输入复用）

//   .par_data      ({                  // 并行数据输出：48位并行数据，对应各硬件状态信号（按顺序拼接）
//                               // 第一组（U259芯片数据）
//                               w_PCA_REVISION_2,    // PCA版本号bit2
//                               w_U259_NC_B,         // U259芯片预留引脚B（未使用）
//                               w_TPM_MODULE_PRSNT_N,// TPM安全模块存在检测（低电平有效：0=已插入）
//                               w_PAL_BP2_PRSNT_N,   // PAL子板BP2存在检测（低电平有效：0=已安装）
//                               w_BOARD_ID2,         // 主板ID标识bit2
//                               w_BOARD_ID3,         // 主板ID标识bit3
//                               w_BOARD_ID0,         // 主板ID标识bit0
//                               w_BOARD_ID1,         // 主板ID标识bit1
                              
//                               // 第二组（U260芯片数据）
//                               w_PAL_BP6_AUX_PG,    // PAL子板BP6辅助电源良好（高电平：电源稳定）
//                               w_PAL_BP1_PRSNT_N,   // PAL子板BP1存在检测（低电平有效）
//                               w_PCA_REVISION_1,    // PCA版本号bit1
//                               w_PCA_REVISION_0,    // PCA版本号bit0
//                               w_PAL_BP4_PRSNT_N,   // PAL子板BP4存在检测（低电平有效）
//                               w_PCB_REVISION_2,    // PCB版本号bit2
//                               w_PAL_BP1_AUX_PG,    // PAL子板BP1辅助电源良好
//                               w_PCB_REVISION_1,    // PCB版本号bit1
                              
//                               // 第三组（U261芯片数据：MCIO接口连接器状态）
//                               w_P1_MCIOP1A_CB_ID0_R,// MCIO接口P1A连接器ID0（_R表示同步处理）
//                               w_P1_MCIOP1C_CB_ID1_R,// MCIO接口P1C连接器ID1
//                               w_P1_MCIOP1C_CB_ID0_R,// MCIO接口P1C连接器ID0
//                               w_P1_MCIOP1A_CB_ID1_R,// MCIO接口P1A连接器ID1
//                               w_P1_MCIOP0A_CB_ID1_R,// MCIO接口P0A连接器ID1
//                               w_P1_MCIOP0C_CB_ID0_R,// MCIO接口P0C连接器ID0
//                               w_P1_MCIOP0C_CB_ID1_R,// MCIO接口P0C连接器ID1
//                               w_P1_MCIOP0A_CB_ID0_R,// MCIO接口P0A连接器ID0
                              
//                               // 第四组（U264芯片数据：电源槽位与OCP接口状态）
//                               w_P1_MCIOP2C_CB_ID1_R,// MCIO接口P2C连接器ID1
//                               w_PG_P12V_SLOT_4,    // 12V电源槽位4电源良好
//                               w_PG_P12V_SLOT_5,    // 12V电源槽位5电源良好
//                               w_P1_MCIOP2A_CB_ID0_R,// MCIO接口P2A连接器ID0
//                               w_P1_MCIOP2A_CB_ID1_R,// MCIO接口P2A连接器ID1
//                               w_P1_MCIOP2C_CB_ID0_R,// MCIO接口P2C连接器ID0
//                               w_PAL_OCP1_PRSNT_B3_N,// OCP接口1 B3子卡存在检测（低电平有效）
//                               w_PG_P12V_SLOT_8,    // 12V电源槽位8电源良好
                              
//                               // 第五组（U160芯片数据：子板电源与OCP ID）
//                               w_PAL_BP8_PRSNT_N,   // PAL子板BP8存在检测（低电平有效）
//                               w_PAL_BP3_AUX_PG,    // PAL子板BP3辅助电源良好
//                               w_PAL_BP5_AUX_PG,    // PAL子板BP5辅助电源良好
//                               w_PAL_BP8_AUX_PG,    // PAL子板BP8辅助电源良好
//                               w_PG_P12V_SLOT_2,    // 12V电源槽位2电源良好
//                               w_U160_NC_F,         // U160芯片预留引脚F（未使用）
//                               w_OCP1_CB_ID0_R,     // OCP接口1子卡ID0（_R表示同步处理）
//                               w_OCP1_CB_ID1_R,     // OCP接口1子卡ID1
                              
//                               // 第六组（U161芯片数据：风扇与电源槽位状态）
//                               w_FAN_PRSNT_INTR,    // 风扇存在告警（高电平：风扇未插入）
//                               w_PAL_BP3_PRSNT_N,   // PAL子板BP3存在检测（低电平有效）
//                               w_PAL_BP5_PRSNT_N,   // PAL子板BP5存在检测（低电平有效）
//                               w_FAN_PWR_PG,        // 风扇电源良好（高电平：供电正常）
//                               w_PAL_BP2_AUX_PG,    // PAL子板BP2辅助电源良好
//                               w_PCB_REVISION_0,    // PCB版本号bit0
//                               w_PG_P12V_SLOT_0,    // 12V电源槽位0电源良好
//                               w_PG_P12V_SLOT_1     // 12V电源槽位1电源良好
//                               })
// );

//-------------------------------------------------------------------------------------------------
// SGPIO data
//-------------------------------------------------------------------------------------------------
wire [199:0] mcpld_to_scpld_s2p_data; //2024-8-2 chg 159 to 199
wire [199:0] scpld_to_mcpld_p2s_data;

reg [191:0] mcpld_to_scpld_data_filter;
reg mb_sgpio_fail;

wire    [1:0]  w_bf_type;//10:6U
//scpld ---> mcpld
assign  scpld_to_mcpld_p2s_data[199]      = 1'b1                                ;
assign  scpld_to_mcpld_p2s_data[198]      = 1'b0                                ;
assign  scpld_to_mcpld_p2s_data[197]      = 1'b1                                ;
assign  scpld_to_mcpld_p2s_data[196]      = 1'b0                                ;
assign  scpld_to_mcpld_p2s_data[195:177]  = 'b0                                 ;

assign  scpld_to_mcpld_p2s_data[176]        = w_bf_type[1];
assign  scpld_to_mcpld_p2s_data[175]        = w_bf_type[0];
assign  scpld_to_mcpld_p2s_data[174]        = ~i_BREAK_DET_DO_N       ;
assign  scpld_to_mcpld_p2s_data[173]        = ~i_LEAKAGE_PRSNT_N   ;
assign  scpld_to_mcpld_p2s_data[172]        = ~i_LEAKAGE_DET_DO_N   ;
assign  scpld_to_mcpld_p2s_data[171]        = ~i_BREAK_DET1_DO_N     ;
assign  scpld_to_mcpld_p2s_data[170]        = ~i_LEAKAGE_PRSNT1_N   ;
assign  scpld_to_mcpld_p2s_data[169]        = ~i_LEAKAGE_DET1_DO_N ;

assign  scpld_to_mcpld_p2s_data[168]        = 1'b0    ;
assign  scpld_to_mcpld_p2s_data[167]        = db_i_uid_sw_in_n    ;
// assign  scpld_to_mcpld_p2s_data[166]        = w_PAL_BP1_PRSNT_N ;
// assign  scpld_to_mcpld_p2s_data[165]        = w_PAL_BP2_PRSNT_N ;
// assign  scpld_to_mcpld_p2s_data[164]        = w_PAL_BP3_PRSNT_N ;
// assign  scpld_to_mcpld_p2s_data[163]        = w_PAL_BP4_PRSNT_N ;
// assign  scpld_to_mcpld_p2s_data[162]        = w_PAL_BP5_PRSNT_N ;
// assign  scpld_to_mcpld_p2s_data[161]        = w_PAL_BP8_PRSNT_N ;

assign  scpld_to_mcpld_p2s_data[160]        = w_p0_mciop1a_slot_id[7];
assign  scpld_to_mcpld_p2s_data[159]        = w_p0_mciop1a_slot_id[6];
assign  scpld_to_mcpld_p2s_data[158]        = w_p0_mciop1a_slot_id[5];
assign  scpld_to_mcpld_p2s_data[157]        = w_p0_mciop1a_slot_id[4];
assign  scpld_to_mcpld_p2s_data[156]        = w_p0_mciop1a_slot_id[3];
assign  scpld_to_mcpld_p2s_data[155]        = w_p0_mciop1a_slot_id[2];
assign  scpld_to_mcpld_p2s_data[154]        = w_p0_mciop1a_slot_id[1];

assign  scpld_to_mcpld_p2s_data[153]        = w_p0_mciop1c_slot_id[7];
assign  scpld_to_mcpld_p2s_data[152]        = w_p0_mciop1c_slot_id[6];
assign  scpld_to_mcpld_p2s_data[151]        = w_p0_mciop1c_slot_id[5];
assign  scpld_to_mcpld_p2s_data[150]        = w_p0_mciop1c_slot_id[4];
assign  scpld_to_mcpld_p2s_data[149]        = w_p0_mciop1c_slot_id[3];
assign  scpld_to_mcpld_p2s_data[148]        = w_p0_mciop1c_slot_id[2];
assign  scpld_to_mcpld_p2s_data[147]        = w_p0_mciop1c_slot_id[1];

assign  scpld_to_mcpld_p2s_data[146]        = w_p0_mciop2a_slot_id[7];
assign  scpld_to_mcpld_p2s_data[145]        = w_p0_mciop2a_slot_id[6];
assign  scpld_to_mcpld_p2s_data[144]        = w_p0_mciop2a_slot_id[5];
assign  scpld_to_mcpld_p2s_data[143]        = w_p0_mciop2a_slot_id[4];
assign  scpld_to_mcpld_p2s_data[142]        = w_p0_mciop2a_slot_id[3];
assign  scpld_to_mcpld_p2s_data[141]        = w_p0_mciop2a_slot_id[2];
assign  scpld_to_mcpld_p2s_data[140]        = w_p0_mciop2a_slot_id[1];

assign  scpld_to_mcpld_p2s_data[139]        = w_p0_mciop2c_slot_id[7];
assign  scpld_to_mcpld_p2s_data[138]        = w_p0_mciop2c_slot_id[6];
assign  scpld_to_mcpld_p2s_data[137]        = w_p0_mciop2c_slot_id[5];
assign  scpld_to_mcpld_p2s_data[136]        = w_p0_mciop2c_slot_id[4];
assign  scpld_to_mcpld_p2s_data[135]        = w_p0_mciop2c_slot_id[3];
assign  scpld_to_mcpld_p2s_data[134]        = w_p0_mciop2c_slot_id[2];
assign  scpld_to_mcpld_p2s_data[133]        = w_p0_mciop2c_slot_id[1];

assign  scpld_to_mcpld_p2s_data[132]        = w_p0_mciop3a_slot_id[7];
assign  scpld_to_mcpld_p2s_data[131]        = w_p0_mciop3a_slot_id[6];
assign  scpld_to_mcpld_p2s_data[130]        = w_p0_mciop3a_slot_id[5];
assign  scpld_to_mcpld_p2s_data[129]        = w_p0_mciop3a_slot_id[4];
assign  scpld_to_mcpld_p2s_data[128]        = w_p0_mciop3a_slot_id[3];
assign  scpld_to_mcpld_p2s_data[127]        = w_p0_mciop3a_slot_id[2];
assign  scpld_to_mcpld_p2s_data[126]        = w_p0_mciop3a_slot_id[1];

assign  scpld_to_mcpld_p2s_data[125]        = w_p0_mciop3c_slot_id[7];
assign  scpld_to_mcpld_p2s_data[124]        = w_p0_mciop3c_slot_id[6];
assign  scpld_to_mcpld_p2s_data[123]        = w_p0_mciop3c_slot_id[5];
assign  scpld_to_mcpld_p2s_data[122]        = w_p0_mciop3c_slot_id[4];
assign  scpld_to_mcpld_p2s_data[121]        = w_p0_mciop3c_slot_id[3];
assign  scpld_to_mcpld_p2s_data[120]        = w_p0_mciop3c_slot_id[2];
assign  scpld_to_mcpld_p2s_data[119]        = w_p0_mciop3c_slot_id[1];

assign  scpld_to_mcpld_p2s_data[118]        = w_p0_mciog3a_slot_id[7];
assign  scpld_to_mcpld_p2s_data[117]        = w_p0_mciog3a_slot_id[6];
assign  scpld_to_mcpld_p2s_data[116]        = w_p0_mciog3a_slot_id[5];
assign  scpld_to_mcpld_p2s_data[115]        = w_p0_mciog3a_slot_id[4];
assign  scpld_to_mcpld_p2s_data[114]        = w_p0_mciog3a_slot_id[3];
assign  scpld_to_mcpld_p2s_data[113]        = w_p0_mciog3a_slot_id[2];
assign  scpld_to_mcpld_p2s_data[112]        = w_p0_mciog3a_slot_id[1];

assign  scpld_to_mcpld_p2s_data[111]        = w_p0_mciog3c_slot_id[7];
assign  scpld_to_mcpld_p2s_data[110]        = w_p0_mciog3c_slot_id[6];
assign  scpld_to_mcpld_p2s_data[109]        = w_p0_mciog3c_slot_id[5];
assign  scpld_to_mcpld_p2s_data[108]        = w_p0_mciog3c_slot_id[4];
assign  scpld_to_mcpld_p2s_data[107]        = w_p0_mciog3c_slot_id[3];
assign  scpld_to_mcpld_p2s_data[106]        = w_p0_mciog3c_slot_id[2];
assign  scpld_to_mcpld_p2s_data[105]        = w_p0_mciog3c_slot_id[1];

assign  scpld_to_mcpld_p2s_data[104]        = w_p1_mciog1a_slot_id[7];
assign  scpld_to_mcpld_p2s_data[103]        = w_p1_mciog1a_slot_id[6];
assign  scpld_to_mcpld_p2s_data[102]        = w_p1_mciog1a_slot_id[5];
assign  scpld_to_mcpld_p2s_data[101]        = w_p1_mciog1a_slot_id[4];
assign  scpld_to_mcpld_p2s_data[100]        = w_p1_mciog1a_slot_id[3];
assign  scpld_to_mcpld_p2s_data[99]        = w_p1_mciog1a_slot_id[2];
assign  scpld_to_mcpld_p2s_data[98]        = w_p1_mciog1a_slot_id[1];

assign  scpld_to_mcpld_p2s_data[97]        = w_p1_mciog1c_slot_id[7];
assign  scpld_to_mcpld_p2s_data[96]        = w_p1_mciog1c_slot_id[6];
assign  scpld_to_mcpld_p2s_data[95]        = w_p1_mciog1c_slot_id[5];
assign  scpld_to_mcpld_p2s_data[94]        = w_p1_mciog1c_slot_id[4];
assign  scpld_to_mcpld_p2s_data[93]        = w_p1_mciog1c_slot_id[3];
assign  scpld_to_mcpld_p2s_data[92]        = w_p1_mciog1c_slot_id[2];
assign  scpld_to_mcpld_p2s_data[91]        = w_p1_mciog1c_slot_id[1];

assign  scpld_to_mcpld_p2s_data[90]        = w_p1_mciop0a_slot_id[7];
assign  scpld_to_mcpld_p2s_data[89]        = w_p1_mciop0a_slot_id[6];
assign  scpld_to_mcpld_p2s_data[88]        = w_p1_mciop0a_slot_id[5];
assign  scpld_to_mcpld_p2s_data[87]        = w_p1_mciop0a_slot_id[4];
assign  scpld_to_mcpld_p2s_data[86]        = w_p1_mciop0a_slot_id[3];
assign  scpld_to_mcpld_p2s_data[85]        = w_p1_mciop0a_slot_id[2];
assign  scpld_to_mcpld_p2s_data[84]        = w_p1_mciop0a_slot_id[1];

assign  scpld_to_mcpld_p2s_data[83]        = w_p1_mciop0c_slot_id[7];
assign  scpld_to_mcpld_p2s_data[82]        = w_p1_mciop0c_slot_id[6];
assign  scpld_to_mcpld_p2s_data[81]        = w_p1_mciop0c_slot_id[5];
assign  scpld_to_mcpld_p2s_data[80]        = w_p1_mciop0c_slot_id[4];
assign  scpld_to_mcpld_p2s_data[79]        = w_p1_mciop0c_slot_id[3];
assign  scpld_to_mcpld_p2s_data[78]        = w_p1_mciop0c_slot_id[2];
assign  scpld_to_mcpld_p2s_data[77]        = w_p1_mciop0c_slot_id[1];

assign  scpld_to_mcpld_p2s_data[76]        = w_p1_mciop1a_slot_id[7];
assign  scpld_to_mcpld_p2s_data[75]        = w_p1_mciop1a_slot_id[6];
assign  scpld_to_mcpld_p2s_data[74]        = w_p1_mciop1a_slot_id[5];
assign  scpld_to_mcpld_p2s_data[73]        = w_p1_mciop1a_slot_id[4];
assign  scpld_to_mcpld_p2s_data[72]        = w_p1_mciop1a_slot_id[3];
assign  scpld_to_mcpld_p2s_data[71]        = w_p1_mciop1a_slot_id[2];
assign  scpld_to_mcpld_p2s_data[70]        = w_p1_mciop1a_slot_id[1];

assign  scpld_to_mcpld_p2s_data[69]        = w_p1_mciop1c_slot_id[7];
assign  scpld_to_mcpld_p2s_data[68]        = w_p1_mciop1c_slot_id[6];
assign  scpld_to_mcpld_p2s_data[67]        = w_p1_mciop1c_slot_id[5];
assign  scpld_to_mcpld_p2s_data[66]        = w_p1_mciop1c_slot_id[4];
assign  scpld_to_mcpld_p2s_data[65]        = w_p1_mciop1c_slot_id[3];
assign  scpld_to_mcpld_p2s_data[64]        = w_p1_mciop1c_slot_id[2];
assign  scpld_to_mcpld_p2s_data[63]        = w_p1_mciop1c_slot_id[1];

assign  scpld_to_mcpld_p2s_data[62]        = w_p1_mciop2a_slot_id[7];
assign  scpld_to_mcpld_p2s_data[61]        = w_p1_mciop2a_slot_id[6];
assign  scpld_to_mcpld_p2s_data[60]        = w_p1_mciop2a_slot_id[5];
assign  scpld_to_mcpld_p2s_data[59]        = w_p1_mciop2a_slot_id[4];
assign  scpld_to_mcpld_p2s_data[58]        = w_p1_mciop2a_slot_id[3];
assign  scpld_to_mcpld_p2s_data[57]        = w_p1_mciop2a_slot_id[2];
assign  scpld_to_mcpld_p2s_data[56]        = w_p1_mciop2a_slot_id[1];

assign  scpld_to_mcpld_p2s_data[55]        = w_p1_mciop2c_slot_id[7];
assign  scpld_to_mcpld_p2s_data[54]        = w_p1_mciop2c_slot_id[6];
assign  scpld_to_mcpld_p2s_data[53]        = w_p1_mciop2c_slot_id[5];
assign  scpld_to_mcpld_p2s_data[52]        = w_p1_mciop2c_slot_id[4];
assign  scpld_to_mcpld_p2s_data[51]        = w_p1_mciop2c_slot_id[3];
assign  scpld_to_mcpld_p2s_data[50]        = w_p1_mciop2c_slot_id[2];
assign  scpld_to_mcpld_p2s_data[49]        = w_p1_mciop2c_slot_id[1];

assign  scpld_to_mcpld_p2s_data[48]        = w_p1_mciop3a_slot_id[7];
assign  scpld_to_mcpld_p2s_data[47]        = w_p1_mciop3a_slot_id[6];
assign  scpld_to_mcpld_p2s_data[46]        = w_p1_mciop3a_slot_id[5];
assign  scpld_to_mcpld_p2s_data[45]        = w_p1_mciop3a_slot_id[4];
assign  scpld_to_mcpld_p2s_data[44]        = w_p1_mciop3a_slot_id[3];
assign  scpld_to_mcpld_p2s_data[43]        = w_p1_mciop3a_slot_id[2];
assign  scpld_to_mcpld_p2s_data[42]        = w_p1_mciop3a_slot_id[1];

assign  scpld_to_mcpld_p2s_data[41]        = w_p1_mciop3c_slot_id[7];
assign  scpld_to_mcpld_p2s_data[40]        = w_p1_mciop3c_slot_id[6];
assign  scpld_to_mcpld_p2s_data[39]        = w_p1_mciop3c_slot_id[5];
assign  scpld_to_mcpld_p2s_data[38]        = w_p1_mciop3c_slot_id[4];
assign  scpld_to_mcpld_p2s_data[37]        = w_p1_mciop3c_slot_id[3];
assign  scpld_to_mcpld_p2s_data[36]        = w_p1_mciop3c_slot_id[2];
assign  scpld_to_mcpld_p2s_data[35]        = w_p1_mciop3c_slot_id[1];

assign  scpld_to_mcpld_p2s_data[34]        = w_P1_MCIOP2C_CB_ID1_R        ;
assign  scpld_to_mcpld_p2s_data[33]        = w_P1_MCIOP2C_CB_ID0_R        ;
assign  scpld_to_mcpld_p2s_data[32]        = w_P1_MCIOP2A_CB_ID1_R        ;
assign  scpld_to_mcpld_p2s_data[31]        = w_P1_MCIOP2A_CB_ID0_R        ;

assign  scpld_to_mcpld_p2s_data[30]        = w_P1_MCIOP1C_CB_ID1_R        ;
assign  scpld_to_mcpld_p2s_data[29]        = w_P1_MCIOP1C_CB_ID0_R        ;
assign  scpld_to_mcpld_p2s_data[28]        = w_P1_MCIOP1A_CB_ID1_R        ;
assign  scpld_to_mcpld_p2s_data[27]        = w_P1_MCIOP1A_CB_ID0_R        ;

assign  scpld_to_mcpld_p2s_data[26]        = w_P1_MCIOP0C_CB_ID1_R        ;
assign  scpld_to_mcpld_p2s_data[25]        = w_P1_MCIOP0C_CB_ID0_R        ;
assign  scpld_to_mcpld_p2s_data[24]        = w_P1_MCIOP0A_CB_ID1_R        ;
assign  scpld_to_mcpld_p2s_data[23]        = w_P1_MCIOP0A_CB_ID0_R        ;

assign  scpld_to_mcpld_p2s_data[22]        = w_PCB_REVISION_2        ;
assign  scpld_to_mcpld_p2s_data[21]        = w_PCB_REVISION_1        ;
assign  scpld_to_mcpld_p2s_data[20]        = w_PCB_REVISION_0        ;

assign  scpld_to_mcpld_p2s_data[19]        = w_PCA_REVISION_2        ;
assign  scpld_to_mcpld_p2s_data[18]        = w_PCA_REVISION_1        ;
assign  scpld_to_mcpld_p2s_data[17]        = w_PCA_REVISION_0        ;

assign  scpld_to_mcpld_p2s_data[16]        = w_BOARD_ID3        ;
assign  scpld_to_mcpld_p2s_data[15]        = w_BOARD_ID2        ;
assign  scpld_to_mcpld_p2s_data[14]        = w_BOARD_ID1        ;
assign  scpld_to_mcpld_p2s_data[13]        = w_BOARD_ID0        ;

// assign  scpld_to_mcpld_p2s_data[12]        = i_USB2_LCD_OC_N;
// assign  scpld_to_mcpld_p2s_data[11]        = i_USB_INNER_OVERCUR3;
assign  scpld_to_mcpld_p2s_data[10]        = w_bmc_extrst_uid;
assign  scpld_to_mcpld_p2s_data[9]          = w_p1_pcie_wake_n_r        ;
assign  scpld_to_mcpld_p2s_data[8]          = w_p0_pcie_wake_n_r        ;
// assign  scpld_to_mcpld_p2s_data[7]          = w_PWRGD_P12V_PS3_PS4        ;
// assign  scpld_to_mcpld_p2s_data[6]          = w_PS3_PS4_ACFAIL        ;
// assign  scpld_to_mcpld_p2s_data[5]          = db_i_ps4_prsnt        ;
// assign  scpld_to_mcpld_p2s_data[4]          = db_i_ps3_prsnt        ;

assign  scpld_to_mcpld_p2s_data[3]          = 1'b0                                ;
assign  scpld_to_mcpld_p2s_data[2]          = 1'b1                                ;
assign  scpld_to_mcpld_p2s_data[1]          = 1'b0                                ;
assign  scpld_to_mcpld_p2s_data[0]          = 1'b1                                ;


//mcpld ---> scpld
wire    w_SW_1;	 // 开关 1 信号，用于获取开关 1 的状态（如开启/关闭）
wire    w_SW_2;
wire    w_SW_3;
wire    w_SW_4;
wire    w_SW_5;
wire    w_SW_6;
wire    w_SW_7;
wire    w_SW_8;


assign w_SW_2 = i_SW_2;


assign  w_SW_2             = mcpld_to_scpld_data_filter[51]            ;

// assign  w_P1_MCIOP3C_CB_ID1_R             = mcpld_to_scpld_data_filter[50]            ;
// assign  w_P1_MCIOP3C_CB_ID0_R             = mcpld_to_scpld_data_filter[49]            ;
// assign  w_P1_MCIOP3A_CB_ID1_R             = mcpld_to_scpld_data_filter[48]            ;
// assign  w_P1_MCIOP3A_CB_ID0_R             = mcpld_to_scpld_data_filter[47]            ;

// assign  w_P1_MCIOG1C_CB_ID1_R             = mcpld_to_scpld_data_filter[46]            ;
// assign  w_P1_MCIOG1C_CB_ID0_R             = mcpld_to_scpld_data_filter[45]            ;
// assign  w_P1_MCIOG1A_CB_ID1_R             = mcpld_to_scpld_data_filter[44]            ;
// assign  w_P1_MCIOG1A_CB_ID0_R             = mcpld_to_scpld_data_filter[43]            ;

// assign  w_P0_MCIOP3C_CB_ID1_R             = mcpld_to_scpld_data_filter[42]            ;
// assign  w_P0_MCIOP3C_CB_ID0_R             = mcpld_to_scpld_data_filter[41]            ;
// assign  w_P0_MCIOP3A_CB_ID1_R             = mcpld_to_scpld_data_filter[40]            ;
// assign  w_P0_MCIOP3A_CB_ID0_R             = mcpld_to_scpld_data_filter[39]            ;

// assign  w_P0_MCIOP2C_CB_ID1_R             = mcpld_to_scpld_data_filter[38]            ;
// assign  w_P0_MCIOP2C_CB_ID0_R             = mcpld_to_scpld_data_filter[37]            ;
// assign  w_P0_MCIOP2A_CB_ID1_R             = mcpld_to_scpld_data_filter[36]            ;
// assign  w_P0_MCIOP2A_CB_ID0_R             = mcpld_to_scpld_data_filter[35]            ;

// assign  w_P0_MCIOP1C_CB_ID1_R             = mcpld_to_scpld_data_filter[34]            ;
// assign  w_P0_MCIOP1C_CB_ID0_R             = mcpld_to_scpld_data_filter[33]            ;
// assign  w_P0_MCIOP1A_CB_ID1_R             = mcpld_to_scpld_data_filter[32]            ;
// assign  w_P0_MCIOP1A_CB_ID0_R             = mcpld_to_scpld_data_filter[31]            ;

// assign  w_P0_MCIOG3C_CB_ID1_R             = mcpld_to_scpld_data_filter[30]            ;
// assign  w_P0_MCIOG3C_CB_ID0_R             = mcpld_to_scpld_data_filter[29]            ;
// assign  w_P0_MCIOG3A_CB_ID1_R             = mcpld_to_scpld_data_filter[28]            ;
// assign  w_P0_MCIOG3A_CB_ID0_R             = mcpld_to_scpld_data_filter[27]            ;

assign  w_led_control[7]                       = mcpld_to_scpld_data_filter[26]       ;
assign  w_led_control[6]                       = mcpld_to_scpld_data_filter[25]       ;
assign  w_led_control[5]                       = mcpld_to_scpld_data_filter[24]       ;
assign  w_led_control[4]                       = mcpld_to_scpld_data_filter[23]       ;
assign  w_led_control[3]                       = mcpld_to_scpld_data_filter[22]       ;
assign  w_led_control[2]                       = mcpld_to_scpld_data_filter[21]       ;
assign  w_led_control[1]                       = mcpld_to_scpld_data_filter[20]       ;
assign  w_led_control[0]                       = mcpld_to_scpld_data_filter[19]       ;

// assign  w_usb_sw_s_r                               = mcpld_to_scpld_data_filter[18]       ;
assign  w_uid_sw_in_n                             = mcpld_to_scpld_data_filter[17]       ;
assign  w_p12v_discharge_r                   = mcpld_to_scpld_data_filter[16]       ;
assign  w_p1_pcie_rst_n_1                     = mcpld_to_scpld_data_filter[15]       ;
assign  w_p1_pcie_rst_n_0                     = mcpld_to_scpld_data_filter[14]       ;
assign  w_p0_pcie_rst_n_1                     = mcpld_to_scpld_data_filter[13]       ;
assign  w_p0_pcie_rst_n_0                     = mcpld_to_scpld_data_filter[12]       ;
assign  w_PAL_OCP1_PRSNT_B2_N             = mcpld_to_scpld_data_filter[11]       ;//2025-03-06 DEL ~
assign  w_PAL_OCP1_PRSNT_B1_N             = mcpld_to_scpld_data_filter[10]       ;
assign  w_PAL_OCP1_PRSNT_B0_N             = mcpld_to_scpld_data_filter[9]       ;
assign  w_pgd_p5v                                     = mcpld_to_scpld_data_filter[8]       ;
assign  w_P0_SLP_S3_N                             = mcpld_to_scpld_data_filter[7]       ;
assign  w_P0_SLP_S5_N                             = mcpld_to_scpld_data_filter[6]       ;
assign  w_pgd_p3v3_stby                         = mcpld_to_scpld_data_filter[5]       ;
assign  w_pgd_p1v2_stby                         = mcpld_to_scpld_data_filter[4]       ;
assign  w_bmc_ready_flag                       = mcpld_to_scpld_data_filter[3]       ;
assign  w_PAL_BP6_PRSNT_N                     = mcpld_to_scpld_data_filter[2]       ;
assign  w_PWRGD_P12V                               = mcpld_to_scpld_data_filter[1]       ;
assign  w_FM_P12V_EN                               = mcpld_to_scpld_data_filter[0]       ;

//-------------------------------------------------------------------------------------------------
// CPLD_U247 SGPIO Moudule       CPLD_U247 is slave
// CPLD_U247的SGPIO模块（从CPLD侧）：实现主CPLD（M CPLD）与从CPLD（S CPLD，即CPLD_U247）之间的SGPIO串行通信
//-------------------------------------------------------------------------------------------------
// 主CPLD到从CPLD的数据校验与滤波逻辑：验证接收数据的有效性并输出过滤后的数据
always@(posedge clk_50m or negedge pon_reset_n)
	begin
		if(~pon_reset_n)  // 复位状态（低电平有效）
			begin
				mcpld_to_scpld_data_filter <= {192{1'b0}};  // 初始化过滤后的数据为192位全0
				mb_sgpio_fail <= 1'b0;  // 初始化通信故障标志为0（无故障）
			end
		// 数据校验：检查帧头和帧尾是否匹配（自定义协议：帧头0101，帧尾1010）
		else if((mcpld_to_scpld_s2p_data[3:0] == 4'b0101) && (mcpld_to_scpld_s2p_data[199:196] == 4'b1010))
			begin
				// 校验通过：提取有效数据（去掉4位帧头和4位帧尾，保留中间192位）
				mcpld_to_scpld_data_filter <= mcpld_to_scpld_s2p_data[195:4];
				mb_sgpio_fail <= 1'b0;  // 清除故障标志（通信正常）
			end
		else  // 校验失败（帧头/帧尾不匹配）
			begin
				mcpld_to_scpld_data_filter <= mcpld_to_scpld_data_filter;  // 保持上一次有效数据
				mb_sgpio_fail <= 1'b1;  // 置位故障标志（通信异常）
			end
end

// 主CPLD到从CPLD的串并转换模块（从设备侧）：将串行数据转换为并行数据
// 参数说明：.NBIT(200)表示传输的数据总位数为200位（4位帧头 + 192位有效数据 + 4位帧尾）
s2p_slave #(.NBIT(200)) inst_mb_to_slv_s2p(
	.clk(clk_50m                  ),  // 输入时钟：50MHz系统时钟，用于串并转换同步
	.rst(~pon_reset_n             ),  // 复位信号：低电平有效（与系统复位同步）
	.si(i_CPLD_SGPIO0_MOSI	          ),  // 串行数据输入：主CPLD通过SGPIO_MOSI发送的串行数据
	.po(mcpld_to_scpld_s2p_data),  // 并行数据输出：转换后的200位并行数据（含帧头、有效数据、帧尾）
	.sld_n(i_CPLD_SGPIO0_LD_N	  ),  // 加载使能信号（低电平有效）：主CPLD发送的帧同步信号，指示数据传输开始
	.sclk(i_CPLD_SGPIO0_CLK		  )   // 串行时钟：主CPLD提供的同步时钟，控制数据采样节奏
);

// 从CPLD到主CPLD的并串转换模块（从设备侧）：将并行数据转换为串行数据
// 参数说明：.NBIT(200)表示传输的数据总位数为200位（与主到从方向保持一致）
p2s_slave #(.NBIT(200)) inst_slv_to_mb_p2s(
	.clk(clk_50m					),  // 输入时钟：50MHz系统时钟，用于并串转换同步
	.rst(~pon_reset_n				),  // 复位信号：低电平有效（与系统复位同步）
	.pi(scpld_to_mcpld_p2s_data	),  // 并行数据输入：从CPLD需要发送给主CPLD的200位并行数据
	.so(o_CPLD_SGPIO0_MISO				),  // 串行数据输出：通过SGPIO_MISO发送给主CPLD的串行数据
	.sld_n(i_CPLD_SGPIO0_LD_N   	),  // 加载使能信号（低电平有效）：复用主CPLD的帧同步信号，确保双方时序对齐
	.sclk(i_CPLD_SGPIO0_CLK			)   // 串行时钟：复用主CPLD的同步时钟，保证收发时钟一致
);
//-----------------------------------------------------------------------------------------------//
//M_CPLD <---> S_CPLD SGPIO END
//-----------------------------------------------------------------------------------------------//
//------------------------------------------------------------------------------------------------
//aux//2024-3-25 add
// wire    [15:0]    w_mb_to_bp_aux1_data;
// wire    [15:0]    w_mb_to_bp_aux2_data;
// wire    [15:0]    w_mb_to_bp_aux3_data;
// wire    [15:0]    w_mb_to_bp_aux4_data;
// wire    [15:0]    w_mb_to_bp_aux5_data;
// wire    [15:0]    w_mb_to_bp_aux6_data;
// wire    [15:0]    w_mb_to_bp_aux7_data;

// wire    [15:0]    w_bp_to_mb_aux1_data;
// wire    [15:0]    w_bp_to_mb_aux2_data;
// wire    [15:0]    w_bp_to_mb_aux3_data;
// wire    [15:0]    w_bp_to_mb_aux4_data;
// wire    [15:0]    w_bp_to_mb_aux5_data;
// wire    [15:0]    w_bp_to_mb_aux6_data;
// wire    [15:0]    w_bp_to_mb_aux7_data;

// wire    [7:0]   w_espi_ram_1055;
// wire    [7:0]   w_espi_ram_1056;
// wire    [7:0]   w_espi_ram_1057;
// wire    [7:0]   w_espi_ram_1058;

// //bit[7:6] rsv bit5:locate en bit[4:1]:locate bit0:pwr en
// wire    [5:0]   w_aux_rsvd_bit15_10;
// wire    [1:0]   w_mb_type;//mb_type 00:ICX  01:EGS  10:EGS 4U   11:ICX 4U
// wire    [3:0]   w_aux_rsvd_bit7_4;
// wire    [2:0]   w_aux_num_aux1;
// wire    [2:0]   w_aux_num_aux2;
// wire    [2:0]   w_aux_num_aux3;
// wire    [2:0]   w_aux_num_aux4;
// wire    [2:0]   w_aux_num_aux5;
// wire    [2:0]   w_aux_num_aux6;
// wire    [2:0]   w_aux_num_aux7;

// wire    w_pal_bp8_pwr_on_r;
// wire    w_pal_bp2_pwr_on_r;
// wire    w_pal_bp1_pwr_on_r;
// wire    w_pal_bp4_pwr_on_r;
// wire    w_pal_bp5_pwr_on_r;
// wire    w_pal_bp6_pwr_on_r;
// wire    w_pal_bp3_pwr_on_r;

// assign  w_aux_rsvd_bit15_10     =   6'b0;
// assign  w_mb_type     =   2'b01;
// assign  w_aux_rsvd_bit7_4     =   4'b0;
// assign  w_aux_num_aux1     =   3'b001;
// assign  w_aux_num_aux2     =   3'b010;
// assign  w_aux_num_aux3     =   3'b011;
// assign  w_aux_num_aux4     =   3'b100;
// assign  w_aux_num_aux5     =   3'b101;
// assign  w_aux_num_aux6     =   3'b110;
// assign  w_aux_num_aux7     =   3'b111;

// assign  w_pal_bp1_pwr_on_r  =   w_PWRGD_P12V&& ~w_PAL_BP1_PRSNT_N && w_P0_SLP_S5_N ;
// assign  w_pal_bp2_pwr_on_r  =   w_PWRGD_P12V&& ~w_PAL_BP2_PRSNT_N && w_P0_SLP_S5_N ;
// assign  w_pal_bp3_pwr_on_r  =   w_PWRGD_P12V&& ~w_PAL_BP3_PRSNT_N && w_P0_SLP_S5_N ;
// assign  w_pal_bp4_pwr_on_r  =   w_PWRGD_P12V&& ~w_PAL_BP4_PRSNT_N && w_P0_SLP_S5_N ;
// // assign  w_pal_bp5_pwr_on_r  =   w_PWRGD_P12V&& ~w_PAL_BP5_PRSNT_N && w_P0_SLP_S5_N ;
// assign  w_pal_bp5_pwr_on_r  =   (~w_ocp_prsnt_n || w_P0_SLP_S5_N) && ~w_PAL_BP5_PRSNT_N ? 1'b1 : 1'b0 ; 
// assign  w_pal_bp6_pwr_on_r  =   w_PWRGD_P12V&& ~w_PAL_BP6_PRSNT_N && w_P0_SLP_S5_N ;
// assign  w_pal_bp8_pwr_on_r  =   w_PWRGD_P12V&& ~w_PAL_BP8_PRSNT_N && w_P0_SLP_S5_N ;

// assign  w_mb_to_bp_aux1_data   =   {w_aux_rsvd_bit15_10,w_mb_type,w_aux_rsvd_bit7_4,w_aux_num_aux1,w_pal_bp8_pwr_on_r};
// assign  w_mb_to_bp_aux2_data   =   {w_aux_rsvd_bit15_10,w_mb_type,w_aux_rsvd_bit7_4,w_aux_num_aux2,w_pal_bp2_pwr_on_r};
// assign  w_mb_to_bp_aux3_data   =   {w_aux_rsvd_bit15_10,w_mb_type,w_aux_rsvd_bit7_4,w_aux_num_aux3,w_pal_bp1_pwr_on_r};
// assign  w_mb_to_bp_aux4_data   =   {w_aux_rsvd_bit15_10,w_mb_type,w_aux_rsvd_bit7_4,w_aux_num_aux4,w_pal_bp4_pwr_on_r};
// assign  w_mb_to_bp_aux5_data   =   {w_aux_rsvd_bit15_10,w_mb_type,w_aux_rsvd_bit7_4,w_aux_num_aux5,w_pal_bp5_pwr_on_r};
// assign  w_mb_to_bp_aux6_data   =   {w_aux_rsvd_bit15_10,w_mb_type,w_aux_rsvd_bit7_4,w_aux_num_aux6,w_pal_bp6_pwr_on_r};
// assign  w_mb_to_bp_aux7_data   =   {w_aux_rsvd_bit15_10,w_mb_type,w_aux_rsvd_bit7_4,w_aux_num_aux7,w_pal_bp3_pwr_on_r};

// assign  w_espi_ram_1055 =   8'hff;
// assign  w_espi_ram_1056 =   8'hff;
// assign  w_espi_ram_1057 =   8'hff;
// assign  w_espi_ram_1058 =   8'hff;

// assign  w_bf_type   =   (w_bp_to_mb_aux5_data[7:0]==8'h1e)?2'b10:2'b00;
// //--------------------------------------------------------------------------------------------------------------------------------------------------
// //AUX1  J192    Board_ID
// // -------------------------------------------------------------------------------------------------------------------------------------------------
// AUX_UART_MASTER #(.NBIT_IN(16), .NBIT_OUT(16), .BPS_COUNT_NUM(48), .START_COUNT_NUM(24)) aux_uart_master_u1 (
// 	.clk             (clk_50m)  ,                //input
// 	.rst             (~pon_reset_n)  ,           //input
// 	.tick            (t16us_tick)  ,             //input
//         .t128ms_tick     (t128ms_tick)  ,            //input
// //Physical Pin        
//         .ser_data        (  io_PAL_BP8_PWR_ON_R  )  ,    //inout//2024-4-7 del o_PAL_BP8_CPU_IP2P//2024-4-17 del io_PAL_BP8_AUX_PG
// //Physical Data
// 	.par_data_in     (w_mb_to_bp_aux1_data)  ,    //input 
// 	.par_data_out    (w_bp_to_mb_aux1_data)  ,                       //output
// 	.send_enable     (1'b1)  ,                   //input
//         .pass_through    (w_pal_bp8_pwr_on_r)  ,    //input

// 	.error_flag      ()                          //output
// );

// //--------------------------------------------------------------------------------------------------------------------------------------------------
// // AUX2接口（J144连接器）：用于主板与BP2子板的UART通信，传输子板控制与状态信息
// // -------------------------------------------------------------------------------------------------------------------------------------------------
// // 实例化AUX UART主模块（控制BP2子板）
// // 参数说明：
// // - .NBIT_IN(16)/.NBIT_OUT(16)：输入/输出并行数据宽度为16位
// // - .BPS_COUNT_NUM(48)：波特率计数参数（配合16us时钟 ticks 生成特定波特率，如50MHz/48≈1.04MHz，用于UART时序分频）
// // - .START_COUNT_NUM(24)：起始位检测计数参数（用于识别UART起始位的同步阈值）
// AUX_UART_MASTER #(.NBIT_IN(16), .NBIT_OUT(16), .BPS_COUNT_NUM(48), .START_COUNT_NUM(24)) aux_uart_master_u2 (
// 	.clk             (clk_50m)  ,                // 输入时钟：50MHz系统时钟，用于UART模块内部逻辑同步
// 	.rst             (~pon_reset_n)  ,           // 复位信号：低电平有效（pon_reset_n=0时模块复位，初始化状态）
// 	.tick            (t16us_tick)  ,             // 时钟 ticks 信号：16us周期脉冲，用于波特率生成和数据采样
//         .t128ms_tick     (t128ms_tick)  ,            // 128ms周期脉冲：用于超时检测或周期性通信触发
// // 物理引脚信号
//         .ser_data        (io_PAL_BP2_PWR_ON_R)  ,    // 串行数据双向接口：复用为UART数据传输线（TX/RX）和BP2子板电源使能控制
//                                                     // - 通信时传输UART串行数据（主从双向）
//                                                     // - 控制时通过特定电平使能BP2子板电源（_R表示信号经同步/去抖处理）
// // 并行数据信号（内部逻辑交互）
// 	.par_data_in      (w_mb_to_bp_aux2_data)  ,   // 主板到BP2子板的并行数据：16位控制指令（如电源控制、模式配置）
// 	.par_data_out    (w_bp_to_mb_aux2_data)  ,    // BP2子板到主板的并行数据：16位状态信息（如电源状态、故障告警）
// 	.send_enable     (1'b1)  ,                   // 发送使能：固定为高电平（始终允许发送数据）
//         .pass_through    (w_pal_bp2_pwr_on_r)  ,     // 直通控制信号：BP2子板电源使能状态（高电平表示电源开启，用于关联通信使能）
// 	.error_flag      ()                          // 错误标志：未使用（预留用于通信错误上报，如校验失败、超时）
// );

// //--------------------------------------------------------------------------------------------------------------------------------------------------
// //AUX3  J143    Board_ID
// // -------------------------------------------------------------------------------------------------------------------------------------------------
// AUX_UART_MASTER #(.NBIT_IN(16), .NBIT_OUT(16), .BPS_COUNT_NUM(48), .START_COUNT_NUM(24)) aux_uart_master_u3 (
// 	.clk             (clk_50m)  ,                //input
// 	.rst             (~pon_reset_n)  ,           //input
// 	.tick            (t16us_tick)  ,             //input
//         .t128ms_tick     (t128ms_tick)  ,            //input
// //Physical Pin         
// 	.ser_data        (  io_PAL_BP1_PWR_ON_R  )  ,    //inout//2024-4-7 del o_PAL_BP1_CPU_IP2P//2024-4-17 del io_PAL_BP1_AUX_PG
// //Physical Data
// 	.par_data_in     (w_mb_to_bp_aux3_data)  ,    //input 
// 	.par_data_out    (w_bp_to_mb_aux3_data)  ,                       //output
// 	.send_enable     (1'b1)  ,                   //input
//         .pass_through    (w_pal_bp1_pwr_on_r)  ,    //input

// 	.error_flag      ()                          //output
// );
// //--------------------------------------------------------------------------------------------------------------------------------------------------
// //AUX4  JA703    Board_ID
// // -------------------------------------------------------------------------------------------------------------------------------------------------
// AUX_UART_MASTER #(.NBIT_IN(16), .NBIT_OUT(16), .BPS_COUNT_NUM(48), .START_COUNT_NUM(24)) aux_uart_master_u4 (
// 	.clk             (clk_50m)  ,                //input
// 	.rst             (~pon_reset_n)  ,           //input
// 	.tick            (t16us_tick)  ,             //input
//         .t128ms_tick     (t128ms_tick)  ,            //input
// //Physical Pin
// 	.ser_data        (  io_PAL_BP4_PWR_ON_R  )  ,    //inout//2024-4-7 del o_PAL_BP4_CPU_IP2P//2024-4-17 del io_PAL_BP4_AUX_PG
// //Physical Data
// 	.par_data_in     (w_mb_to_bp_aux4_data)  ,    //input 
// 	.par_data_out    (w_bp_to_mb_aux4_data)  ,                       //output
// 	.send_enable     (1'b1)  ,                   //input
//         .pass_through    (w_pal_bp4_pwr_on_r)  ,    //input

// 	.error_flag      ()                          //output
// );
// //--------------------------------------------------------------------------------------------------------------------------------------------------
// //AUX5  JA702    Board_ID
// // -------------------------------------------------------------------------------------------------------------------------------------------------
// AUX_UART_MASTER #(.NBIT_IN(16), .NBIT_OUT(16), .BPS_COUNT_NUM(48), .START_COUNT_NUM(24)) aux_uart_master_u5 (
// 	.clk             (clk_50m)  ,                //input
// 	.rst             (~pon_reset_n)  ,           //input
// 	.tick            (t16us_tick)  ,             //input
//         .t128ms_tick     (t128ms_tick)  ,            //input
// //Physical Pin
// 	.ser_data        (  io_PAL_BP5_PWR_ON_R  )  ,    //inout//2024-4-7 del o_PAL_BP5_CPU_IP2P//2024-4-17 del io_PAL_BP5_AUX_PG
// //Physical Data
// 	.par_data_in     (w_mb_to_bp_aux5_data)  ,    //input 
// 	.par_data_out    (w_bp_to_mb_aux5_data)  ,                       //output
// 	.send_enable     (1'b1)  ,                   //input
//         .pass_through    (w_pal_bp5_pwr_on_r)  ,    //input

// 	.error_flag      ()                          //output
// );
// //--------------------------------------------------------------------------------------------------------------------------------------------------
// //AUX6  JA601    Board_ID
// // -------------------------------------------------------------------------------------------------------------------------------------------------
// AUX_UART_MASTER #(.NBIT_IN(16), .NBIT_OUT(16), .BPS_COUNT_NUM(48), .START_COUNT_NUM(24)) aux_uart_master_u6 (
// 	.clk             (clk_50m)  ,                //input
// 	.rst             (~pon_reset_n)  ,           //input
// 	.tick            (t16us_tick)  ,             //input
//         .t128ms_tick     (t128ms_tick)  ,            //input
// //Physical Pin
// 	.ser_data        (  io_PAL_BP6_PWR_ON_R  )  ,    //inout//2024-4-7 del o_PAL_BP6_CPU_IP2P//2024-4-17 del io_PAL_BP6_AUX_PG
// //Physical Data
// 	.par_data_in     (w_mb_to_bp_aux6_data)  ,    //input 
// 	.par_data_out    (w_bp_to_mb_aux6_data)  ,                       //output
// 	.send_enable     (1'b1)  ,                   //input
//         .pass_through    (w_pal_bp6_pwr_on_r)  ,    //input

// 	.error_flag      ()                          //output
// );
// //--------------------------------------------------------------------------------------------------------------------------------------------------
// //AUX7  JA602    Board_ID
// // -------------------------------------------------------------------------------------------------------------------------------------------------
// AUX_UART_MASTER #(.NBIT_IN(16), .NBIT_OUT(16), .BPS_COUNT_NUM(48), .START_COUNT_NUM(24)) aux_uart_master_u7 (
// 	.clk             (clk_50m)  ,                //input
// 	.rst             (~pon_reset_n)  ,           //input
// 	.tick            (t16us_tick)  ,             //input
//         .t128ms_tick     (t128ms_tick)  ,            //input
// //Physical Pin
// 	.ser_data        (  io_PAL_BP3_PWR_ON_R  )  ,    //inout
// //Physical Data
// 	.par_data_in     (w_mb_to_bp_aux7_data)  ,    //input 
// 	.par_data_out    (w_bp_to_mb_aux7_data)  ,                       //output
// 	.send_enable     (1'b1)  ,                   //input
//         .pass_through    (w_pal_bp3_pwr_on_r)  ,    //input

// 	.error_flag      ()                          //output
// );
// 1.模块作用：
// 实例化了 6 个AUX_UART_MASTER模块，分别对应主板的 AUX2~AUX7 接口，用于实现主板与 BP1~BP6 子板（Board Pod，子板模块）的双向 UART 通信。
// 核心功能是传输子板的控制指令（主板→子板）和状态信息（子板→主板），同时复用物理引脚实现子板电源使能控制。
// 2.关键参数解析:
// .NBIT_IN/.NBIT_OUT(16)：定义每次通信传输 16 位并行数据（包含指令 opcode、数据 payload 等），平衡通信效率与硬件资源。
// .BPS_COUNT_NUM(48)和.START_COUNT_NUM(24)：配合16us_tick生成 UART 波特率（如 50MHz / (48×16us⁻¹) ≈ 65536 波特率），确保主从设备通信速率一致；起始位计数参数用于准确识别 UART 帧的起始信号（低电平）。
// 3.核心接口信号功能：
// ser_data（如io_PAL_BP2_PWR_ON_R）：
// ① UART 串行数据传输（TX/RX）：主板与子板通过该引脚收发串行数据（遵循 UART 协议：起始位 + 数据位 + 校验位 + 停止位）；
// ② 子板电源使能控制：通过特定电平（如高电平）使能子板电源（_PWR_ON_R），_R表示信号经过同步 / 去抖处理，避免噪声导致误触发。
// par_data_in/par_data_out（如w_mb_to_bp_aux2_data/w_bp_to_mb_aux2_data）：
// par_data_in：主板发送给子板的 16 位控制指令（如 “开启子板风扇”“设置功耗等级为 L1”）；
// par_data_out：子板返回给主板的 16 位状态信息（如 “子板温度 65℃”“电源良好”“风扇故障”）。
// pass_through（如w_pal_bp2_pwr_on_r）：
// 子板电源使能状态反馈信号，高电平表示子板电源已开启。该信号用于关联通信使能（如仅当电源开启时，UART 通信才有效），避免无效通信。
// 4.应用场景：
// 主板通过 AUX 接口向子板发送电源控制、模式切换等指令；子板通过 AUX 接口向主板上报温度、电压、故障等状态；复用引脚设计减少硬件接口数量，降低主板与子板的连接器复杂度。

//MCIO

// ------------------------------
// 主板（MB）到子板（BP）的控制数据（16位并行数据，共20组，对应不同MCIO接口）
// ------------------------------
wire    [15:0]    w_mb_to_bp_mciop0p0a_data;//0
wire    [15:0]    w_mb_to_bp_mciop0p0c_data;//1
wire    [15:0]    w_mb_to_bp_mciop0p1a_data;//2
wire    [15:0]    w_mb_to_bp_mciop0p1c_data;//3
wire    [15:0]    w_mb_to_bp_mciop0p2a_data;//4
wire    [15:0]    w_mb_to_bp_mciop0p2c_data;//5
wire    [15:0]    w_mb_to_bp_mciop0p3a_data;//6
wire    [15:0]    w_mb_to_bp_mciop0p3c_data;//7
wire    [15:0]    w_mb_to_bp_mciop0g3a_data;//8
wire    [15:0]    w_mb_to_bp_mciop0g3c_data;//9
wire    [15:0]    w_mb_to_bp_mciop1g1a_data;//10
wire    [15:0]    w_mb_to_bp_mciop1g1c_data;//11
wire    [15:0]    w_mb_to_bp_mciop1p0a_data;//12
wire    [15:0]    w_mb_to_bp_mciop1p0c_data;//13
wire    [15:0]    w_mb_to_bp_mciop1p1a_data;//14
wire    [15:0]    w_mb_to_bp_mciop1p1c_data;//15
wire    [15:0]    w_mb_to_bp_mciop1p2a_data;//16
wire    [15:0]    w_mb_to_bp_mciop1p2c_data;//17
wire    [15:0]    w_mb_to_bp_mciop1p3a_data;//18
wire    [15:0]    w_mb_to_bp_mciop1p3c_data;//19

// ------------------------------
// 子板（BP）到主板（MB）的状态数据（16位并行数据，共20组，与控制数据一一对应）
// ------------------------------
wire    [15:0]    w_bp_to_mb_mciop0p0a_data;//0
wire    [15:0]    w_bp_to_mb_mciop0p0c_data;//1
wire    [15:0]    w_bp_to_mb_mciop0p1a_data;//2
wire    [15:0]    w_bp_to_mb_mciop0p1c_data;//3
wire    [15:0]    w_bp_to_mb_mciop0p2a_data;//4
wire    [15:0]    w_bp_to_mb_mciop0p2c_data;//5
wire    [15:0]    w_bp_to_mb_mciop0p3a_data;//6
wire    [15:0]    w_bp_to_mb_mciop0p3c_data;//7
wire    [15:0]    w_bp_to_mb_mciop0g3a_data;//8
wire    [15:0]    w_bp_to_mb_mciop0g3c_data;//9
wire    [15:0]    w_bp_to_mb_mciop1g1a_data;//10
wire    [15:0]    w_bp_to_mb_mciop1g1c_data;//11
wire    [15:0]    w_bp_to_mb_mciop1p0a_data;//12
wire    [15:0]    w_bp_to_mb_mciop1p0c_data;//13
wire    [15:0]    w_bp_to_mb_mciop1p1a_data;//14
wire    [15:0]    w_bp_to_mb_mciop1p1c_data;//15
wire    [15:0]    w_bp_to_mb_mciop1p2a_data;//16
wire    [15:0]    w_bp_to_mb_mciop1p2c_data;//17
wire    [15:0]    w_bp_to_mb_mciop1p3a_data;//18
wire    [15:0]    w_bp_to_mb_mciop1p3c_data;//19

// ------------------------------
// MCIO子板电源使能信号（共20组，控制对应接口的子板供电）
// ------------------------------
wire    w_pal_p0_mciop0a_pwr_en;//0
wire    w_pal_p0_mciop0c_pwr_en;//1
wire    w_pal_p0_mciop1a_pwr_en;//2
wire    w_pal_p0_mciop1c_pwr_en;//3
wire    w_pal_p0_mciop2a_pwr_en;//4
wire    w_pal_p0_mciop2c_pwr_en;//5
wire    w_pal_p0_mciop3a_pwr_en;//6
wire    w_pal_p0_mciop3c_pwr_en;//7
wire    w_pal_p0_mciog3a_pwr_en;//8
wire    w_pal_p0_mciog3c_pwr_en;//9
wire    w_pal_p1_mciog1a_pwr_en;//10
wire    w_pal_p1_mciog1c_pwr_en;//11
wire    w_pal_p1_mciop0a_pwr_en;//12
wire    w_pal_p1_mciop0c_pwr_en;//13
wire    w_pal_p1_mciop1a_pwr_en;//14
wire    w_pal_p1_mciop1c_pwr_en;//15
wire    w_pal_p1_mciop2a_pwr_en;//16
wire    w_pal_p1_mciop2c_pwr_en;//17
wire    w_pal_p1_mciop3a_pwr_en;//18
wire    w_pal_p1_mciop3c_pwr_en;//19

// ------------------------------
// MCIO控制数据的固定字段定义（用于填充16位控制数据的高15位，最低位为电源使能信号）
// ------------------------------
wire    [5:0]   w_mcio_rsvd_bit15_10;       // 16位数据的[15:10]位：预留（固定为0）
wire    [1:0]   w_mcio_rsvd_bit9_8;         // 16位数据的[9:8]位：预留（固定为11）
wire    [2:0]   w_mcio_rsvd_bit7_5;         // 16位数据的[7:5]位：预留（固定为100）
wire    [3:0]   w_mcio_vpp_addr_bit4_1;     // 16位数据的[4:1]位：VPP地址（固定为0000，未启用）

// 固定字段赋值（硬件设计中暂不使用，固定为特定值确保协议兼容性）
assign  w_mcio_rsvd_bit15_10       =    6'b0;
assign  w_mcio_rsvd_bit9_8          =    2'b11;
assign  w_mcio_rsvd_bit7_5           =    3'b100;
assign  w_mcio_vpp_addr_bit4_1  =   4'b0000;

// ------------------------------
// 拼接16位控制数据：固定字段（高15位）+ 电源使能信号（最低位）
// 每个MCIO接口的控制数据格式统一，仅电源使能信号对应不同接口
// ------------------------------
assign  w_mb_to_bp_mciop0p0a_data     =   {w_mcio_rsvd_bit15_10,w_mcio_rsvd_bit9_8,w_mcio_rsvd_bit7_5,w_mcio_vpp_addr_bit4_1,w_pal_p0_mciop0a_pwr_en};
assign  w_mb_to_bp_mciop0p0c_data     =   {w_mcio_rsvd_bit15_10,w_mcio_rsvd_bit9_8,w_mcio_rsvd_bit7_5,w_mcio_vpp_addr_bit4_1,w_pal_p0_mciop0c_pwr_en};
assign  w_mb_to_bp_mciop0p1a_data     =   {w_mcio_rsvd_bit15_10,w_mcio_rsvd_bit9_8,w_mcio_rsvd_bit7_5,w_mcio_vpp_addr_bit4_1,w_pal_p0_mciop1a_pwr_en};
assign  w_mb_to_bp_mciop0p1c_data     =   {w_mcio_rsvd_bit15_10,w_mcio_rsvd_bit9_8,w_mcio_rsvd_bit7_5,w_mcio_vpp_addr_bit4_1,w_pal_p0_mciop1c_pwr_en};
assign  w_mb_to_bp_mciop0p2a_data     =   {w_mcio_rsvd_bit15_10,w_mcio_rsvd_bit9_8,w_mcio_rsvd_bit7_5,w_mcio_vpp_addr_bit4_1,w_pal_p0_mciop2a_pwr_en};
assign  w_mb_to_bp_mciop0p2c_data     =   {w_mcio_rsvd_bit15_10,w_mcio_rsvd_bit9_8,w_mcio_rsvd_bit7_5,w_mcio_vpp_addr_bit4_1,w_pal_p0_mciop2c_pwr_en};
assign  w_mb_to_bp_mciop0p3a_data     =   {w_mcio_rsvd_bit15_10,w_mcio_rsvd_bit9_8,w_mcio_rsvd_bit7_5,w_mcio_vpp_addr_bit4_1,w_pal_p0_mciop3a_pwr_en};
assign  w_mb_to_bp_mciop0p3c_data     =   {w_mcio_rsvd_bit15_10,w_mcio_rsvd_bit9_8,w_mcio_rsvd_bit7_5,w_mcio_vpp_addr_bit4_1,w_pal_p0_mciop3c_pwr_en};
assign  w_mb_to_bp_mciop0g3a_data     =   {w_mcio_rsvd_bit15_10,w_mcio_rsvd_bit9_8,w_mcio_rsvd_bit7_5,w_mcio_vpp_addr_bit4_1,w_pal_p0_mciog3a_pwr_en};
assign  w_mb_to_bp_mciop0g3c_data     =   {w_mcio_rsvd_bit15_10,w_mcio_rsvd_bit9_8,w_mcio_rsvd_bit7_5,w_mcio_vpp_addr_bit4_1,w_pal_p0_mciog3c_pwr_en};
assign  w_mb_to_bp_mciop1g1a_data     =   {w_mcio_rsvd_bit15_10,w_mcio_rsvd_bit9_8,w_mcio_rsvd_bit7_5,w_mcio_vpp_addr_bit4_1,w_pal_p1_mciog1a_pwr_en};
assign  w_mb_to_bp_mciop1g1c_data     =   {w_mcio_rsvd_bit15_10,w_mcio_rsvd_bit9_8,w_mcio_rsvd_bit7_5,w_mcio_vpp_addr_bit4_1,w_pal_p1_mciog1c_pwr_en};
assign  w_mb_to_bp_mciop1p0a_data     =   {w_mcio_rsvd_bit15_10,w_mcio_rsvd_bit9_8,w_mcio_rsvd_bit7_5,w_mcio_vpp_addr_bit4_1,w_pal_p1_mciop0a_pwr_en};
assign  w_mb_to_bp_mciop1p0c_data     =   {w_mcio_rsvd_bit15_10,w_mcio_rsvd_bit9_8,w_mcio_rsvd_bit7_5,w_mcio_vpp_addr_bit4_1,w_pal_p1_mciop0c_pwr_en};
assign  w_mb_to_bp_mciop1p1a_data     =   {w_mcio_rsvd_bit15_10,w_mcio_rsvd_bit9_8,w_mcio_rsvd_bit7_5,w_mcio_vpp_addr_bit4_1,w_pal_p1_mciop1a_pwr_en};
assign  w_mb_to_bp_mciop1p1c_data     =   {w_mcio_rsvd_bit15_10,w_mcio_rsvd_bit9_8,w_mcio_rsvd_bit7_5,w_mcio_vpp_addr_bit4_1,w_pal_p1_mciop1c_pwr_en};
assign  w_mb_to_bp_mciop1p2a_data     =   {w_mcio_rsvd_bit15_10,w_mcio_rsvd_bit9_8,w_mcio_rsvd_bit7_5,w_mcio_vpp_addr_bit4_1,w_pal_p1_mciop2a_pwr_en};
assign  w_mb_to_bp_mciop1p2c_data     =   {w_mcio_rsvd_bit15_10,w_mcio_rsvd_bit9_8,w_mcio_rsvd_bit7_5,w_mcio_vpp_addr_bit4_1,w_pal_p1_mciop2c_pwr_en};
assign  w_mb_to_bp_mciop1p3a_data     =   {w_mcio_rsvd_bit15_10,w_mcio_rsvd_bit9_8,w_mcio_rsvd_bit7_5,w_mcio_vpp_addr_bit4_1,w_pal_p1_mciop3a_pwr_en};
assign  w_mb_to_bp_mciop1p3c_data     =   {w_mcio_rsvd_bit15_10,w_mcio_rsvd_bit9_8,w_mcio_rsvd_bit7_5,w_mcio_vpp_addr_bit4_1,w_pal_p1_mciop3c_pwr_en};

// ------------------------------
// 从子板状态数据中提取槽位ID（低8位）：用于识别子板型号和位置
// ------------------------------
assign  w_p0_mciop0a_slot_id    =   w_bp_to_mb_mciop0p0a_data[7:0];
assign  w_p0_mciop0c_slot_id    =   w_bp_to_mb_mciop0p0c_data[7:0];
assign  w_p0_mciop1a_slot_id    =   w_bp_to_mb_mciop0p1a_data[7:0];
assign  w_p0_mciop1c_slot_id    =   w_bp_to_mb_mciop0p1c_data[7:0];
assign  w_p0_mciop2a_slot_id    =   w_bp_to_mb_mciop0p2a_data[7:0];
assign  w_p0_mciop2c_slot_id    =   w_bp_to_mb_mciop0p2c_data[7:0];
assign  w_p0_mciop3a_slot_id    =   w_bp_to_mb_mciop0p3a_data[7:0];
assign  w_p0_mciop3c_slot_id    =   w_bp_to_mb_mciop0p3c_data[7:0];
assign  w_p0_mciog3a_slot_id    =   w_bp_to_mb_mciop0g3a_data[7:0];
assign  w_p0_mciog3c_slot_id    =   w_bp_to_mb_mciop0g3c_data[7:0];
assign  w_p1_mciog1a_slot_id    =   w_bp_to_mb_mciop1g1a_data[7:0];
assign  w_p1_mciog1c_slot_id    =   w_bp_to_mb_mciop1g1c_data[7:0];
assign  w_p1_mciop0a_slot_id    =   w_bp_to_mb_mciop1p0a_data[7:0];
assign  w_p1_mciop0c_slot_id    =   w_bp_to_mb_mciop1p0c_data[7:0];
assign  w_p1_mciop1a_slot_id    =   w_bp_to_mb_mciop1p1a_data[7:0];
assign  w_p1_mciop1c_slot_id    =   w_bp_to_mb_mciop1p1c_data[7:0];
assign  w_p1_mciop2a_slot_id    =   w_bp_to_mb_mciop1p2a_data[7:0];
assign  w_p1_mciop2c_slot_id    =   w_bp_to_mb_mciop1p2c_data[7:0];
assign  w_p1_mciop3a_slot_id    =   w_bp_to_mb_mciop1p3a_data[7:0];
assign  w_p1_mciop3c_slot_id    =   w_bp_to_mb_mciop1p3c_data[7:0];

// ------------------------------
// MCIO子板电源使能逻辑：仅当12V电源稳定且系统处于S0状态（非待机）时，才允许开启子板电源
// ------------------------------
assign w_pal_p0_mciop0a_pwr_en    = (w_PWRGD_P12V && w_P0_SLP_S5_N) ? 1'b1 : 1'b0   ;  
assign w_pal_p0_mciop0c_pwr_en    = (w_PWRGD_P12V && w_P0_SLP_S5_N) ? 1'b1 : 1'b0   ;  
assign w_pal_p0_mciop1a_pwr_en    = (w_PWRGD_P12V && w_P0_SLP_S5_N) ? 1'b1 : 1'b0   ;  
assign w_pal_p0_mciop1c_pwr_en    = (w_PWRGD_P12V && w_P0_SLP_S5_N) ? 1'b1 : 1'b0   ;  
assign w_pal_p0_mciop2a_pwr_en    = (w_PWRGD_P12V && w_P0_SLP_S5_N) ? 1'b1 : 1'b0   ;  
assign w_pal_p0_mciop2c_pwr_en    = (w_PWRGD_P12V && w_P0_SLP_S5_N) ? 1'b1 : 1'b0   ;  
assign w_pal_p0_mciop3a_pwr_en    = (w_PWRGD_P12V && w_P0_SLP_S5_N) ? 1'b1 : 1'b0   ;  
assign w_pal_p0_mciop3c_pwr_en    = (w_PWRGD_P12V && w_P0_SLP_S5_N) ? 1'b1 : 1'b0   ;  
assign w_pal_p0_mciog3a_pwr_en    = (w_PWRGD_P12V && w_P0_SLP_S5_N) ? 1'b1 : 1'b0   ;  
assign w_pal_p0_mciog3c_pwr_en    = (w_PWRGD_P12V && w_P0_SLP_S5_N) ? 1'b1 : 1'b0   ;  
assign w_pal_p1_mciog1a_pwr_en    = (w_PWRGD_P12V && w_P0_SLP_S5_N) ? 1'b1 : 1'b0   ;  
assign w_pal_p1_mciog1c_pwr_en    = (w_PWRGD_P12V && w_P0_SLP_S5_N) ? 1'b1 : 1'b0   ;  
assign w_pal_p1_mciop0a_pwr_en    = (w_PWRGD_P12V && w_P0_SLP_S5_N) ? 1'b1 : 1'b0   ;  
assign w_pal_p1_mciop0c_pwr_en    = (w_PWRGD_P12V && w_P0_SLP_S5_N) ? 1'b1 : 1'b0   ;  
assign w_pal_p1_mciop1a_pwr_en    = (w_PWRGD_P12V && w_P0_SLP_S5_N) ? 1'b1 : 1'b0   ;  
assign w_pal_p1_mciop1c_pwr_en    = (w_PWRGD_P12V && w_P0_SLP_S5_N) ? 1'b1 : 1'b0   ;  
assign w_pal_p1_mciop2a_pwr_en    = (w_PWRGD_P12V && w_P0_SLP_S5_N) ? 1'b1 : 1'b0   ;  
assign w_pal_p1_mciop2c_pwr_en    = (w_PWRGD_P12V && w_P0_SLP_S5_N) ? 1'b1 : 1'b0   ;  
assign w_pal_p1_mciop3a_pwr_en    = (w_PWRGD_P12V && w_P0_SLP_S5_N) ? 1'b1 : 1'b0   ;  
assign w_pal_p1_mciop3c_pwr_en    = (w_PWRGD_P12V && w_P0_SLP_S5_N) ? 1'b1 : 1'b0   ;  

//--------------------------------------------------------------------------------------------------------------------------------------------------
// CPU0 P0A接口（J185连接器）：MCIOP0A，用于CPU0与P0A槽位子板的UART通信
// -------------------------------------------------------------------------------------------------------------------------------------------------
// 实例化UART主模块，负责CPU0的P0A接口通信
// 参数说明：
// - .NBIT_IN(16)/.NBIT_OUT(16)：输入/输出并行数据宽度为16位
// - .BPS_COUNT_NUM(48)/.START_COUNT_NUM(24)：波特率配置参数（配合16us_tick生成通信速率）
UART_MASTER #(.NBIT_IN(16), .NBIT_OUT(16), .BPS_COUNT_NUM(48), .START_COUNT_NUM(24)) uart_master_u00 (
	.clk                        (clk_50m            )  ,             // 输入时钟：50MHz系统时钟，用于UART时序同步
	.rst                        (~pon_reset_n  )  ,             // 复位信号：低电平有效（模块初始化/故障时复位）
	.tick                      (t16us_tick      )  ,             // 16us周期脉冲：用于波特率分频（生成UART采样时钟）
	.send_enable        (1'b1                  )  ,             // 发送使能：固定为高电平（始终允许发送数据）
         .t128ms_tick       (t128ms_tick    )  ,             // 128ms周期脉冲：用于周期性通信触发（如定时查询子板状态）
	.par_data_in        (w_mb_to_bp_mciop0p0a_data)  , // 主板到子板的并行控制数据（16位）
	.par_data_out      (w_bp_to_mb_mciop0p0a_data)  , // 子板到主板的并行状态数据（16位）
	.ser_data              (io_P0_MCIOP0A_PWR_EN_R      )  , // 串行数据双向接口：复用为UART通信线和子板电源使能控制（_R表示同步/去抖）
         .riser_en_out     (w_pal_p0_mciop0a_pwr_en    )  , // output：子板电源使能输出（控制P0C槽位子板供电）
	.mcio_cable_id0  (w_P0_MCIOP0A_CB_ID0_R        )  , // 子板连接器ID0：识别P0A接口插入的子板型号（_R表示同步）
	.mcio_cable_id1  (w_P0_MCIOP0A_CB_ID1_R        )  , // 子板连接器ID1：与ID0组合，唯一标识子板

	.error_flag          (  )                          // 错误标志：未使用（预留用于通信错误上报）
);
//--------------------------------------------------------------------------------------------------------------------------------------------------
// CPU0 P0C  --> J48    MCIOP0C
// -------------------------------------------------------------------------------------------------------------------------------------------------
UART_MASTER #(.NBIT_IN(16), .NBIT_OUT(16), .BPS_COUNT_NUM(48), .START_COUNT_NUM(24)) uart_master_u0 (
	.clk                        (clk_50m            )  ,             //input
	.rst                        (~pon_reset_n  )  ,             //input
	.tick                      (t16us_tick      )  ,             //input
	.send_enable        (1'b1                  )  ,             //input
         .t128ms_tick       (t128ms_tick    )  ,             //input
	.par_data_in        (w_mb_to_bp_mciop0p0c_data)  , //input 
	.par_data_out      (w_bp_to_mb_mciop0p0c_data)  , //output
	.ser_data              (io_P0_MCIOP0C_PWR_EN_R      )  , //inout
         .riser_en_out     (w_pal_p0_mciop0c_pwr_en    )  , //output
	.mcio_cable_id0  (w_P0_MCIOP0C_CB_ID0_R        )  , //input
	.mcio_cable_id1  (w_P0_MCIOP0C_CB_ID1_R        )  , //input

	.error_flag          (  )                          //output
);
//--------------------------------------------------------------------------------------------------------------------------------------------------
// CPU0 P1A  --> J75    MCIOP1A
// -------------------------------------------------------------------------------------------------------------------------------------------------
UART_MASTER #(.NBIT_IN(16), .NBIT_OUT(16), .BPS_COUNT_NUM(48), .START_COUNT_NUM(24)) uart_master_u1 (
	.clk                        (clk_50m            )  ,             //input
	.rst                        (~pon_reset_n  )  ,             //input
	.tick                      (t16us_tick      )  ,             //input
	.send_enable        (1'b1                  )  ,             //input
         .t128ms_tick       (t128ms_tick    )  ,             //input
	.par_data_in        (w_mb_to_bp_mciop0p1a_data)  , //input 
	.par_data_out      (w_bp_to_mb_mciop0p1a_data)  , //output
	.ser_data              (io_P0_MCIOP1A_PWR_EN_R      )  , //inout
         .riser_en_out     (w_pal_p0_mciop1a_pwr_en    )  , //output
	.mcio_cable_id0  (w_P0_MCIOP1A_CB_ID0_R        )  , //input
	.mcio_cable_id1  (w_P0_MCIOP1A_CB_ID1_R        )  , //input

	.error_flag          (  )                          //output
);
//--------------------------------------------------------------------------------------------------------------------------------------------------
// CPU0 P1C  --> J76    MCIOP1C
// -------------------------------------------------------------------------------------------------------------------------------------------------
UART_MASTER #(.NBIT_IN(16), .NBIT_OUT(16), .BPS_COUNT_NUM(48), .START_COUNT_NUM(24)) uart_master_u2 (
	.clk                        (clk_50m            )  ,             //input
	.rst                        (~pon_reset_n  )  ,             //input
	.tick                      (t16us_tick      )  ,             //input
	.send_enable        (1'b1                  )  ,             //input
         .t128ms_tick       (t128ms_tick    )  ,             //input
	.par_data_in        (w_mb_to_bp_mciop0p1c_data)  , //input 
	.par_data_out      (w_bp_to_mb_mciop0p1c_data)  , //output
	.ser_data              (io_P0_MCIOP1C_PWR_EN_R      )  , //inout
         .riser_en_out     (w_pal_p0_mciop1c_pwr_en    )  , //output
	.mcio_cable_id0  (w_P0_MCIOP1C_CB_ID0_R        )  , //input
	.mcio_cable_id1  (w_P0_MCIOP1C_CB_ID1_R        )  , //input

	.error_flag          (  )                          //output
);

//--------------------------------------------------------------------------------------------------------------------------------------------------
// CPU0 P2A  --> J40    MCIOP2A
// -------------------------------------------------------------------------------------------------------------------------------------------------
UART_MASTER #(.NBIT_IN(16), .NBIT_OUT(16), .BPS_COUNT_NUM(48), .START_COUNT_NUM(24)) uart_master_u3 (
	.clk                        (clk_50m            )  ,             //input
	.rst                        (~pon_reset_n  )  ,             //input
	.tick                      (t16us_tick      )  ,             //input
	.send_enable        (1'b1                  )  ,             //input
         .t128ms_tick       (t128ms_tick    )  ,             //input
	.par_data_in        (w_mb_to_bp_mciop0p2a_data)  , //input 
	.par_data_out      (w_bp_to_mb_mciop0p2a_data)  , //output
	.ser_data              (io_P0_MCIOP2A_PWR_EN_R      )  , //inout
         .riser_en_out     (w_pal_p0_mciop2a_pwr_en    )  , //output
	.mcio_cable_id0  (w_P0_MCIOP2A_CB_ID0_R        )  , //input
	.mcio_cable_id1  (w_P0_MCIOP2A_CB_ID1_R        )  , //input

	.error_flag          (  )                          //output
);
//--------------------------------------------------------------------------------------------------------------------------------------------------
// CPU0 P2C  --> J41    MCIOP2C
// -------------------------------------------------------------------------------------------------------------------------------------------------
UART_MASTER #(.NBIT_IN(16), .NBIT_OUT(16), .BPS_COUNT_NUM(48), .START_COUNT_NUM(24)) uart_master_u4 (
	.clk                        (clk_50m            )  ,             //input
	.rst                        (~pon_reset_n  )  ,             //input
	.tick                      (t16us_tick      )  ,             //input
	.send_enable        (1'b1                  )  ,             //input
         .t128ms_tick       (t128ms_tick    )  ,             //input
	.par_data_in        (w_mb_to_bp_mciop0p2c_data)  , //input 
	.par_data_out      (w_bp_to_mb_mciop0p2c_data)  , //output
	.ser_data              (io_P0_MCIOP2C_PWR_EN_R      )  , //inout
         .riser_en_out     (w_pal_p0_mciop2c_pwr_en    )  , //output
	.mcio_cable_id0  (w_P0_MCIOP2C_CB_ID0_R        )  , //input
	.mcio_cable_id1  (w_P0_MCIOP2C_CB_ID1_R        )  , //input

	.error_flag          (  )                          //output
);

//--------------------------------------------------------------------------------------------------------------------------------------------------
// CPU0 P3A  --> J42    MCIOP3A
// -------------------------------------------------------------------------------------------------------------------------------------------------
UART_MASTER #(.NBIT_IN(16), .NBIT_OUT(16), .BPS_COUNT_NUM(48), .START_COUNT_NUM(24)) uart_master_u5 (
	.clk                        (clk_50m            )  ,             //input
	.rst                        (~pon_reset_n  )  ,             //input
	.tick                      (t16us_tick      )  ,             //input
	.send_enable        (1'b1                  )  ,             //input
         .t128ms_tick       (t128ms_tick    )  ,             //input
	.par_data_in        (w_mb_to_bp_mciop0p3a_data)  , //input 
	.par_data_out      (w_bp_to_mb_mciop0p3a_data)  , //output
	.ser_data              (io_P0_MCIOP3A_PWR_EN_R      )  , //inout
         .riser_en_out     (w_pal_p0_mciop3a_pwr_en    )  , //output
	.mcio_cable_id0  (w_P0_MCIOP3A_CB_ID0_R        )  , //input
	.mcio_cable_id1  (w_P0_MCIOP3A_CB_ID1_R        )  , //input

	.error_flag          (  )                          //output
);
//--------------------------------------------------------------------------------------------------------------------------------------------------
// CPU0 P3C  --> J43    MCIOP3C
// -------------------------------------------------------------------------------------------------------------------------------------------------
UART_MASTER #(.NBIT_IN(16), .NBIT_OUT(16), .BPS_COUNT_NUM(48), .START_COUNT_NUM(24)) uart_master_u6 (
	.clk                        (clk_50m            )  ,             //input
	.rst                        (~pon_reset_n  )  ,             //input
	.tick                      (t16us_tick      )  ,             //input
	.send_enable        (1'b1                  )  ,             //input
         .t128ms_tick       (t128ms_tick    )  ,             //input
	.par_data_in        (w_mb_to_bp_mciop0p3c_data)  , //input 
	.par_data_out      (w_bp_to_mb_mciop0p3c_data)  , //output
	.ser_data              (io_P0_MCIOP3C_PWR_EN_R      )  , //inout
         .riser_en_out     (w_pal_p0_mciop3c_pwr_en    )  , //output
	.mcio_cable_id0  (w_P0_MCIOP3C_CB_ID0_R        )  , //input
	.mcio_cable_id1  (w_P0_MCIOP3C_CB_ID1_R        )  , //input

	.error_flag          (  )                          //output
);
//--------------------------------------------------------------------------------------------------------------------------------------------------
// CPU0 G3A  --> J45    MCIOG3A
// -------------------------------------------------------------------------------------------------------------------------------------------------
UART_MASTER #(.NBIT_IN(16), .NBIT_OUT(16), .BPS_COUNT_NUM(48), .START_COUNT_NUM(24)) uart_master_u7 (
	.clk                        (clk_50m            )  ,             //input
	.rst                        (~pon_reset_n  )  ,             //input
	.tick                      (t16us_tick      )  ,             //input
	.send_enable        (1'b1                  )  ,             //input
         .t128ms_tick       (t128ms_tick    )  ,             //input
	.par_data_in        (w_mb_to_bp_mciop0g3a_data)  , //input 
	.par_data_out      (w_bp_to_mb_mciop0g3a_data)  , //output
	.ser_data              (io_P0_MCIOG3A_PWR_EN_R      )  , //inout
         .riser_en_out     (w_pal_p0_mciog3a_pwr_en    )  , //output
	.mcio_cable_id0  (w_P0_MCIOG3A_CB_ID0_R        )  , //input
	.mcio_cable_id1  (w_P0_MCIOG3A_CB_ID1_R        )  , //input

	.error_flag          (  )                          //output
);
//--------------------------------------------------------------------------------------------------------------------------------------------------
// CPU0 G3C  --> J44    MCIOG3C
// -------------------------------------------------------------------------------------------------------------------------------------------------
UART_MASTER #(.NBIT_IN(16), .NBIT_OUT(16), .BPS_COUNT_NUM(48), .START_COUNT_NUM(24)) uart_master_u8 (
	.clk                        (clk_50m            )  ,             //input
	.rst                        (~pon_reset_n  )  ,             //input
	.tick                      (t16us_tick      )  ,             //input
	.send_enable        (1'b1                  )  ,             //input
         .t128ms_tick       (t128ms_tick    )  ,             //input
	.par_data_in        (w_mb_to_bp_mciop0g3c_data)  , //input 
	.par_data_out      (w_bp_to_mb_mciop0g3c_data)  , //output
	.ser_data              (io_P0_MCIOG3C_PWR_EN_R      )  , //inout
         .riser_en_out     (w_pal_p0_mciog3c_pwr_en    )  , //output
	.mcio_cable_id0  (w_P0_MCIOG3C_CB_ID0_R        )  , //input
	.mcio_cable_id1  (w_P0_MCIOG3C_CB_ID1_R        )  , //input

	.error_flag          (  )                          //output
);
//--------------------------------------------------------------------------------------------------------------------------------------------------
// CPU1 G1A  --> J210    MCIOG1A
// -------------------------------------------------------------------------------------------------------------------------------------------------
UART_MASTER #(.NBIT_IN(16), .NBIT_OUT(16), .BPS_COUNT_NUM(48), .START_COUNT_NUM(24)) uart_master_u9 (
	.clk                        (clk_50m            )  ,             //input
	.rst                        (~pon_reset_n  )  ,             //input
	.tick                      (t16us_tick      )  ,             //input
	.send_enable        (1'b1                  )  ,             //input
         .t128ms_tick       (t128ms_tick    )  ,             //input
	.par_data_in        (w_mb_to_bp_mciop1g1a_data)  , //input 
	.par_data_out      (w_bp_to_mb_mciop1g1a_data)  , //output
	.ser_data              (io_P1_MCIOG1A_PWR_EN_R      )  , //inout
         .riser_en_out     (w_pal_p1_mciog1a_pwr_en    )  , //output
	.mcio_cable_id0  (w_P1_MCIOG1A_CB_ID0_R        )  , //input
	.mcio_cable_id1  (w_P1_MCIOG1A_CB_ID1_R        )  , //input

	.error_flag          (  )                          //output
);
//--------------------------------------------------------------------------------------------------------------------------------------------------
// CPU1 G1C  --> J209    MCIOG1C
// -------------------------------------------------------------------------------------------------------------------------------------------------
UART_MASTER #(.NBIT_IN(16), .NBIT_OUT(16), .BPS_COUNT_NUM(48), .START_COUNT_NUM(24)) uart_master_u10 (
	.clk                        (clk_50m            )  ,             //input
	.rst                        (~pon_reset_n  )  ,             //input
	.tick                      (t16us_tick      )  ,             //input
	.send_enable        (1'b1                  )  ,             //input
         .t128ms_tick       (t128ms_tick    )  ,             //input
	.par_data_in        (w_mb_to_bp_mciop1g1c_data)  , //input 
	.par_data_out      (w_bp_to_mb_mciop1g1c_data)  , //output
	.ser_data              (io_P1_MCIOG1C_PWR_EN_R      )  , //inout
         .riser_en_out     (w_pal_p1_mciog1c_pwr_en    )  , //output
	.mcio_cable_id0  (w_P1_MCIOG1C_CB_ID0_R        )  , //input
	.mcio_cable_id1  (w_P1_MCIOG1C_CB_ID1_R        )  , //input

	.error_flag          (  )                          //output
);


//--------------------------------------------------------------------------------------------------------------------------------------------------
// CPU1 P0A  --> J73    MCIOP0A
// -------------------------------------------------------------------------------------------------------------------------------------------------
UART_MASTER #(.NBIT_IN(16), .NBIT_OUT(16), .BPS_COUNT_NUM(48), .START_COUNT_NUM(24)) uart_master_u11 (
	.clk                        (clk_50m            )  ,             //input
	.rst                        (~pon_reset_n  )  ,             //input
	.tick                      (t16us_tick      )  ,             //input
	.send_enable        (1'b1                  )  ,             //input
         .t128ms_tick       (t128ms_tick    )  ,             //input
	.par_data_in        (w_mb_to_bp_mciop1p0a_data)  , //input 
	.par_data_out      (w_bp_to_mb_mciop1p0a_data)  , //output
	.ser_data              (io_P1_MCIOP0A_PWR_EN_R      )  , //inout
         .riser_en_out     (w_pal_p1_mciop0a_pwr_en    )  , //output
	.mcio_cable_id0  (w_P1_MCIOP0A_CB_ID0_R        )  , //input
	.mcio_cable_id1  (w_P1_MCIOP0A_CB_ID1_R        )  , //input

	.error_flag          (  )                          //output
);
//--------------------------------------------------------------------------------------------------------------------------------------------------
// CPU1 P0C  --> J74    MCIOP0C
// -------------------------------------------------------------------------------------------------------------------------------------------------
UART_MASTER #(.NBIT_IN(16), .NBIT_OUT(16), .BPS_COUNT_NUM(48), .START_COUNT_NUM(24)) uart_master_u12 (
	.clk                        (clk_50m            )  ,             //input
	.rst                        (~pon_reset_n  )  ,             //input
	.tick                      (t16us_tick      )  ,             //input
	.send_enable        (1'b1                  )  ,             //input
         .t128ms_tick       (t128ms_tick    )  ,             //input
	.par_data_in        (w_mb_to_bp_mciop1p0c_data)  , //input 
	.par_data_out      (w_bp_to_mb_mciop1p0c_data)  , //output
	.ser_data              (io_P1_MCIOP0C_PWR_EN_R      )  , //inout
         .riser_en_out     (w_pal_p1_mciop0c_pwr_en    )  , //output
	.mcio_cable_id0  (w_P1_MCIOP0C_CB_ID0_R        )  , //input
	.mcio_cable_id1  (w_P1_MCIOP0C_CB_ID1_R        )  , //input

	.error_flag          (  )                          //output
);

//--------------------------------------------------------------------------------------------------------------------------------------------------
// CPU1 P1A  --> J204    MCIOP1A
// -------------------------------------------------------------------------------------------------------------------------------------------------
UART_MASTER #(.NBIT_IN(16), .NBIT_OUT(16), .BPS_COUNT_NUM(48), .START_COUNT_NUM(24)) uart_master_u13 (
	.clk                        (clk_50m            )  ,             //input
	.rst                        (~pon_reset_n  )  ,             //input
	.tick                      (t16us_tick      )  ,             //input
	.send_enable        (1'b1                  )  ,             //input
         .t128ms_tick       (t128ms_tick    )  ,             //input
	.par_data_in        (w_mb_to_bp_mciop1p1a_data)  , //input 
	.par_data_out      (w_bp_to_mb_mciop1p1a_data)  , //output
	.ser_data              (io_P1_MCIOP1A_PWR_EN_R      )  , //inout
         .riser_en_out     (w_pal_p1_mciop1a_pwr_en    )  , //output
	.mcio_cable_id0  (w_P1_MCIOP1A_CB_ID0_R        )  , //input
	.mcio_cable_id1  (w_P1_MCIOP1A_CB_ID1_R        )  , //input

	.error_flag          (  )                          //output
);
//--------------------------------------------------------------------------------------------------------------------------------------------------
// CPU1 P1C  --> J203    MCIOP1C
// -------------------------------------------------------------------------------------------------------------------------------------------------
UART_MASTER #(.NBIT_IN(16), .NBIT_OUT(16), .BPS_COUNT_NUM(48), .START_COUNT_NUM(24)) uart_master_u14 (
	.clk                        (clk_50m            )  ,             //input
	.rst                        (~pon_reset_n  )  ,             //input
	.tick                      (t16us_tick      )  ,             //input
	.send_enable        (1'b1                  )  ,             //input
         .t128ms_tick       (t128ms_tick    )  ,             //input
	.par_data_in        (w_mb_to_bp_mciop1p1c_data)  , //input 
	.par_data_out      (w_bp_to_mb_mciop1p1c_data)  , //output
	.ser_data              (io_P1_MCIOP1C_PWR_EN_R      )  , //inout
         .riser_en_out     (w_pal_p1_mciop1c_pwr_en    )  , //output
	.mcio_cable_id0  (w_P1_MCIOP1C_CB_ID0_R        )  , //input
	.mcio_cable_id1  (w_P1_MCIOP1C_CB_ID1_R        )  , //input

	.error_flag          (  )                          //output
);

//--------------------------------------------------------------------------------------------------------------------------------------------------
// CPU1 P2A  --> J205    MCIOP2A
// -------------------------------------------------------------------------------------------------------------------------------------------------
UART_MASTER #(.NBIT_IN(16), .NBIT_OUT(16), .BPS_COUNT_NUM(48), .START_COUNT_NUM(24)) uart_master_u15 (
	.clk                        (clk_50m            )  ,             //input
	.rst                        (~pon_reset_n  )  ,             //input
	.tick                      (t16us_tick      )  ,             //input
	.send_enable        (1'b1                  )  ,             //input
         .t128ms_tick       (t128ms_tick    )  ,             //input
	.par_data_in        (w_mb_to_bp_mciop1p2a_data)  , //input 
	.par_data_out      (w_bp_to_mb_mciop1p2a_data)  , //output
	.ser_data              (io_P1_MCIOP2A_PWR_EN_R      )  , //inout
         .riser_en_out     (w_pal_p1_mciop2a_pwr_en    )  , //output
	.mcio_cable_id0  (w_P1_MCIOP2A_CB_ID0_R        )  , //input
	.mcio_cable_id1  (w_P1_MCIOP2A_CB_ID1_R        )  , //input

	.error_flag          (  )                          //output
);
//--------------------------------------------------------------------------------------------------------------------------------------------------
// CPU1 P2C  --> J206    MCIOP2C
// -------------------------------------------------------------------------------------------------------------------------------------------------
UART_MASTER #(.NBIT_IN(16), .NBIT_OUT(16), .BPS_COUNT_NUM(48), .START_COUNT_NUM(24)) uart_master_u16 (
	.clk                        (clk_50m            )  ,             //input
	.rst                        (~pon_reset_n  )  ,             //input
	.tick                      (t16us_tick      )  ,             //input
	.send_enable        (1'b1                  )  ,             //input
         .t128ms_tick       (t128ms_tick    )  ,             //input
	.par_data_in        (w_mb_to_bp_mciop1p2c_data)  , //input 
	.par_data_out      (w_bp_to_mb_mciop1p2c_data)  , //output
	.ser_data              (io_P1_MCIOP2C_PWR_EN_R      )  , //inout
         .riser_en_out     (w_pal_p1_mciop2c_pwr_en    )  , //output
	.mcio_cable_id0  (w_P1_MCIOP2C_CB_ID0_R        )  , //input
	.mcio_cable_id1  (w_P1_MCIOP2C_CB_ID1_R        )  , //input

	.error_flag          (  )                          //output
);

//--------------------------------------------------------------------------------------------------------------------------------------------------
// CPU1 P3A  --> J207    MCIOP3A
// -------------------------------------------------------------------------------------------------------------------------------------------------
UART_MASTER #(.NBIT_IN(16), .NBIT_OUT(16), .BPS_COUNT_NUM(48), .START_COUNT_NUM(24)) uart_master_u17 (
	.clk                        (clk_50m            )  ,             //input
	.rst                        (~pon_reset_n  )  ,             //input
	.tick                      (t16us_tick      )  ,             //input
	.send_enable        (1'b1                  )  ,             //input
         .t128ms_tick       (t128ms_tick    )  ,             //input
	.par_data_in        (w_mb_to_bp_mciop1p3a_data)  , //input 
	.par_data_out      (w_bp_to_mb_mciop1p3a_data)  , //output
	.ser_data              (io_P1_MCIOP3A_PWR_EN_R      )  , //inout
         .riser_en_out     (w_pal_p1_mciop3a_pwr_en    )  , //output
	.mcio_cable_id0  (w_P1_MCIOP3A_CB_ID0_R        )  , //input
	.mcio_cable_id1  (w_P1_MCIOP3A_CB_ID1_R        )  , //input

	.error_flag          (  )                          //output
);
//--------------------------------------------------------------------------------------------------------------------------------------------------
// CPU1 P3C  --> J208    MCIOP3C
// -------------------------------------------------------------------------------------------------------------------------------------------------
UART_MASTER #(.NBIT_IN(16), .NBIT_OUT(16), .BPS_COUNT_NUM(48), .START_COUNT_NUM(24)) uart_master_u18 (
	.clk                        (clk_50m            )  ,             //input
	.rst                        (~pon_reset_n  )  ,             //input
	.tick                      (t16us_tick      )  ,             //input
	.send_enable        (1'b1                  )  ,             //input
         .t128ms_tick       (t128ms_tick    )  ,             //input
	.par_data_in        (w_mb_to_bp_mciop1p3c_data)  , //input 
	.par_data_out      (w_bp_to_mb_mciop1p3c_data)  , //output
	.ser_data              (io_P1_MCIOP3C_PWR_EN_R      )  , //inout
         .riser_en_out     (w_pal_p1_mciop3c_pwr_en    )  , //output
	.mcio_cable_id0  (w_P1_MCIOP3C_CB_ID0_R        )  , //input
	.mcio_cable_id1  (w_P1_MCIOP3C_CB_ID1_R        )  , //input

	.error_flag          (  )                          //output
);
// 1.双向通信：
// 主板→子板：通过w_mb_to_bp_mciopxx_data传输 16 位控制数据（如电源控制、模式配置），格式为 “固定字段（15 位）+ 电源使能（1 位）”。
// 子板→主板：通过w_bp_to_mb_mciopxx_data传输 16 位状态数据（如子板温度、故障告警），其中低 8 位为slot_id（子板唯一标识）。
// 2.电源控制逻辑:
// 使能条件：子板电源使能信号（如w_pal_p0_mciop0a_pwr_en）仅在以下条件满足时为高：
// w_PWRGD_P12V=1（12V 主电源稳定）；
// w_P0_SLP_S5_N=1（系统处于 S0 运行状态，非待机）。
// 该逻辑确保子板仅在主板供电正常且系统运行时上电，避免无效功耗或电源波动损坏设备。
// 物理引脚（如io_P0_MCIOP0A_PWR_EN_R）同时承担 “UART 串行数据” 和 “电源使能控制” 功能，通过时序区分（通信时传输数据，空闲时输出使能电平）
// 3. 子板识别机制
// 通过mcio_cable_id0和mcio_cable_id1（如w_P0_MCIOP0A_CB_ID0_R）组合识别子板型号，确保主板能根据子板类型加载对应配置（如 PCIe 速率、功耗阈值）。
// 子板返回的slot_id（如w_p0_mciop0a_slot_id）用于定位具体子板位置，便于故障诊断（如 “P0A 槽位子板温度过高”）。

//-------------------------------------------------------------------------------------------------
// OCP1 START
//-------------------------------------------------------------------------------------------------
/**************************************************************************************************/

//-------------------------------------------------------------------------------------------------
// PVT_DATA   74lv165      
//-------------------------------------------------------------------------------------------------
// wire    w_ocp0_LINK_SPDB_P5 ;//31：OCP0 P5通道B链路速度信号
// wire    w_ocp0_ACT_P5       ;//30：OCP0 P5通道活动状态（高电平表示有数据传输）
// wire    w_ocp0_LINK_SPDA_P6 ;//29
// wire    w_ocp0_LINK_SPDB_P6 ;//28
// wire    w_ocp0_ACT_P6       ;//27
// wire    w_ocp0_LINK_SPDA_P7 ;//26
// wire    w_ocp0_LINK_SPDB_P7 ;//25
// wire    w_ocp0_ACT_P7       ;//24
// wire    w_ocp0_ACT_P2       ;//23
// wire    w_ocp0_LINK_SPDA_P3 ;//22
// wire    w_ocp0_LINK_SPDB_P3 ;//21
// wire    w_ocp0_ACT_P3       ;//20
// wire    w_ocp0_LINK_SPDA_P4 ;//19
// wire    w_ocp0_LINK_SPDB_P4 ;//18
// wire    w_ocp0_ACT_P4       ;//17
// wire    w_ocp0_LINK_SPDA_P5 ;//16
// wire    w_ocp0_LINK_SPDA_P0 ;//15
// wire    w_ocp0_LINK_SPDB_P0 ;//14
// wire    w_ocp0_ACT_P0       ;//13
// wire    w_ocp0_LINK_SPDA_P1 ;//12
// wire    w_ocp0_LINK_SPDB_P1 ;//11
// wire    w_ocp0_ACT_P1       ;//10
// wire    w_ocp0_LINK_SPDA_P2 ;//9
// wire    w_ocp0_LINK_SPDB_P2 ;//8
// wire    w_ocp0_PRSNTB_0     ;//7：OCP0子卡0存在检测（高电平表示插入）
// wire    w_ocp0_PRSNTB_1     ;//6
// wire    w_ocp0_PRSNTB_2     ;//5
// wire    w_ocp0_PRSNTB_3     ;//4
// wire    w_ocp0_WAKE_N       ;//3：OCP0唤醒信号（低电平有效）
// wire    w_ocp0_TEMP_WARN_N  ;//2：OCP0温度警告（低电平表示警告）
// wire    w_ocp0_TEMP_CRIT_N  ;//1：OCP0温度临界告警（低电平表示严重过温）
// wire    w_ocp0_FAN_ON_AUX   ;//0：OCP0辅助风扇使能（高电平表示开启）

// wire    [5:0]   pvti_ocp0_count; // OCP0状态采集位索引计数器（0~31）
wire    w_nic_act_flag      ;// NIC活动标志
// wire    w_pal_led_nic_act_r;// OCP0 NIC活动指示灯控制信号

// // 实例化pvt_gpi模块（串并转换）：将32路串行状态信号转换为并行数据
// pvt_gpi #(
//   .TOTAL_BIT_COUNT(32),
//   .DEFAULT_STATE(32'h0),
//   .NUMBER_OF_COUNTER_BITS(6)                        // 计数器位宽：6位（支持0~63计数）
// ) pvt_ocp0_inst (
//   .clk           (clk_50m),                 // 工作时钟：50MHz
//   .reset_n       (pon_reset_n),             // 复位信号：高电平有效
//   .clk_ena       (t16us_tick),              // 时钟使能：16us周期脉冲（控制采样速率）
//   .serclk_in     (o_PAL_OCP_SS_CLK_R),      // 串行时钟输入：OCP接口同步时钟（经同步处理）
//   .par_load_in_n (o_PAL_OCP_SS_LD_N_R),     // 并行加载使能（低电平有效）：触发数据锁存
//   .sdi           (i_PAL_OCP1_SS_DATA_IN  ), // 串行数据输入：来自74LV165的串行状态流
//   .bit_idx_in    (pvti_ocp0_count),         // 位索引输入：当前采集的位编号
//   .bit_idx_out   (pvti_ocp0_count),         // 位索引输出：反馈当前位编号（闭环控制）
//   .serclk_out    (o_PAL_OCP_SS_CLK_R ),     // 串行时钟输出：驱动74LV165的时钟信号
//   .par_load_out_n(o_PAL_OCP_SS_LD_N_R),     // 并行加载输出：控制74LV165的数据锁存
//                    //last bit
//   .par_data      ({     w_ocp0_LINK_SPDB_P5, w_ocp0_ACT_P5, w_ocp0_LINK_SPDA_P6, w_ocp0_LINK_SPDB_P6,    //74LV165 #3
// 				   w_ocp0_ACT_P6, w_ocp0_LINK_SPDA_P7, w_ocp0_LINK_SPDB_P7, w_ocp0_ACT_P7,                       

// 				   w_ocp0_ACT_P2, w_ocp0_LINK_SPDA_P3, w_ocp0_LINK_SPDB_P3, w_ocp0_ACT_P3,          //74LV165 #2
// 				   w_ocp0_LINK_SPDA_P4, w_ocp0_LINK_SPDB_P4, w_ocp0_ACT_P4, w_ocp0_LINK_SPDA_P5,               

// 				   w_ocp0_LINK_SPDA_P0, w_ocp0_LINK_SPDB_P0, w_ocp0_ACT_P0, w_ocp0_LINK_SPDA_P1,    //74LV165 #1
// 				   w_ocp0_LINK_SPDB_P1, w_ocp0_ACT_P1, w_ocp0_LINK_SPDA_P2, w_ocp0_LINK_SPDB_P2,                      

// 				   w_ocp0_PRSNTB_0, w_ocp0_PRSNTB_1, w_ocp0_PRSNTB_2, w_ocp0_PRSNTB_3,              //74LV165 #0
// 				   w_ocp0_WAKE_N, w_ocp0_TEMP_WARN_N, w_ocp0_TEMP_CRIT_N, w_ocp0_FAN_ON_AUX                                  
//                })                                                                    //first bit
// );

// // OCP0 NIC活动指示灯控制逻辑：根据链路和活动状态动态闪烁
// assign w_pal_led_nic_act_r =    w_nic_act_flag ? t4hz_clk :                                    // 若NIC活动，以4Hz频率闪烁
//                                                          (w_ocp_prsnt_n ) ? 1'b0 :             // 若OCP子卡未插入，指示灯灭
//                                                          ~(w_ocp0_ACT_P0 & w_ocp0_ACT_P1 & w_ocp0_ACT_P2 & w_ocp0_ACT_P3 & 
//                                                          w_ocp0_ACT_P4 & w_ocp0_ACT_P5 & w_ocp0_ACT_P6 & w_ocp0_ACT_P7 ) ? t1hz_clk: // 若任一通道无活动，以1Hz闪烁
//                                                          ~(w_ocp0_LINK_SPDA_P0 & w_ocp0_LINK_SPDB_P0 &
//                                                           w_ocp0_LINK_SPDA_P1 & w_ocp0_LINK_SPDB_P1 &
//                                                           w_ocp0_LINK_SPDA_P2 & w_ocp0_LINK_SPDB_P2 &
//                                                           w_ocp0_LINK_SPDA_P3 & w_ocp0_LINK_SPDB_P3 &
//                                                           w_ocp0_LINK_SPDA_P4 & w_ocp0_LINK_SPDB_P4 &
//                                                           w_ocp0_LINK_SPDA_P5 & w_ocp0_LINK_SPDB_P5 &
//                                                           w_ocp0_LINK_SPDA_P6 & w_ocp0_LINK_SPDB_P6 &
//                                                           w_ocp0_LINK_SPDA_P7 & w_ocp0_LINK_SPDB_P7   ) ? 1'b1 : 1'b0 ; // 若任一链路异常，指示灯常亮


// //-------------------------------------------------------------------------------------------------
// // OCP RISER  2024-4-10 add
// //功能：采集OCP Riser子卡的板级信息（板ID、PCB版本），判断子卡是否存在
// //-------------------------------------------------------------------------------------------------

// wire [2:0] pvti_ocp_riser_count;      // Riser子卡采集位索引计数器（0~7）
// // OCP Riser子卡状态信号
// wire    w_OCP_RISER_BOARD_ID0     ;          // Riser子卡ID bit0
// wire    w_OCP_RISER_BOARD_ID1     ;          // Riser子卡ID bit1
// wire    w_OCP_RISER_BOARD_ID2     ;          // Riser子卡ID bit2
// wire    w_OCP_RISER_BOARD_ID3     ;          // Riser子卡ID bit3
// wire    w_OCP_RISER_BOARD_ID4     ;          // Riser子卡ID bit4
// wire    w_OCP_RISER_BOARD_ID5     ;          // Riser子卡ID bit5
// wire    w_OCP_RISER_PCB_REVISION_0;          // Riser子卡PCB版本 bit0
// wire    w_OCP_RISER_PCB_REVISION_1;          // Riser子卡PCB版本 bit1
// wire    [5:0]   w_ocp_riser_board_id;        // 6位Riser子卡ID（唯一标识子卡型号）
// wire    w_ocp_riser_prsnt;                   // Riser子卡存在标志（高电平表示插入）

// // 拼接6位Riser子卡ID
// assign  w_ocp_riser_board_id = {w_OCP_RISER_BOARD_ID5,
//                                                            w_OCP_RISER_BOARD_ID4,
//                                                            w_OCP_RISER_BOARD_ID3,
//                                                            w_OCP_RISER_BOARD_ID2,
//                                                            w_OCP_RISER_BOARD_ID1,
//                                                            w_OCP_RISER_BOARD_ID0};

// // Riser子卡存在判断：ID为010101时视为有效插入
// assign  w_ocp_riser_prsnt = (w_ocp_riser_board_id == 6'b010101) ? 1'b1 : 1'b0 ;

// // 实例化pvt_gpi模块：采集8位Riser子卡信息（串并转换）
// pvt_gpi #(
//   .TOTAL_BIT_COUNT(8),
//   .DEFAULT_STATE(8'h0),
//   .NUMBER_OF_COUNTER_BITS(3) 
// ) pvt_ocp_riser_inst (
//   .clk                      (clk_50m),       // 工作时钟：50MHz
//   .reset_n              (pon_reset_n),       // 复位信号：高电平有效
//   .clk_ena              (t16us_tick),        // 时钟使能：16us周期脉冲
//   .serclk_in          (o_OCP1_CLK_R),        // 串行时钟输入：OCP1接口时钟
//   .par_load_in_n  (o_OCP1_LD_R),            // 并行加载使能：触发数据锁存
//   .sdi                      (i_OCP1_DATA_IN_R  ), // 串行数据输入：Riser子卡信息
//   .bit_idx_in        (pvti_ocp_riser_count), // 位索引输入：当前采集位编号
//   .bit_idx_out      (pvti_ocp_riser_count), // 位索引输出：反馈当前位编号
//   .serclk_out        (o_OCP1_CLK_R ),        // 串行时钟输出：驱动子卡时钟
//   .par_load_out_n(o_OCP1_LD_R),            // 并行加载输出：控制子卡数据锁存
//                    //last bit
//   .par_data      ({                         // 并行数据输出：8位子卡信息
//                                 w_OCP_RISER_BOARD_ID0,w_OCP_RISER_BOARD_ID1,w_OCP_RISER_BOARD_ID2,w_OCP_RISER_BOARD_ID3,    
//                                 w_OCP_RISER_BOARD_ID4,w_BOARD_ID5,w_OCP_RISER_PCB_REVISION_0,w_OCP_RISER_PCB_REVISION_1
//                             })                                                                    //first bit
// );

// //-------------------------------------------------------------------------------------------------
// // OCP1_HOT PLUG  //2023-2-11 add ocp_vpp
// //-------------------------------------------------------------------------------------------------
// // wire  [15:0]  ocp1_vpp_state;
// // wire          ocp1_vpp_int_n;

// // PCA9555_SIM #(.CHIP_NUM(1'b1), .CLK_FREQ(2500000)) inst01_pca9555_sim (
//     // .rst_n       (pon_reset_n               ),
//     //// .sys_clk     (clk                       ),
//     // .sys_clk     (clk_2p5m                  ),
//     // .scl         (i_PAL_SMB_CPU1_OCP2_SCL    ),
//     // .sda         (io_PAL_SMB_CPU1_OCP2_SDA   ),

//     // .addr        (8'h42                     ), //input

//     // .i2c_idle    (                          ), //output

//     // .port00      ( ocp1_vpp_state[0] ), //inout
//     // .port01      ( ocp1_vpp_state[1] ), //inout
//     // .port02      ( ocp1_vpp_state[2] ), //inout
//     // .port03      ( ocp1_vpp_state[3] ), //inout
//     // .port04      ( ocp1_vpp_state[4] ), //inout
//     // .port05      ( ocp1_vpp_state[5] ), //inout
//     // .port06      ( ocp1_vpp_state[6] ), //inout
//     // .port07      ( ocp1_vpp_state[7] ), //inout

//     // .port10      ( ocp1_vpp_state[8]  ), //inout
//     // .port11      ( ocp1_vpp_state[9]  ), //inout
//     // .port12      ( ocp1_vpp_state[10] ), //inout
//     // .port13      ( ocp1_vpp_state[11] ), //inout
//     // .port14      ( ocp1_vpp_state[12] ), //inout
//     // .port15      ( ocp1_vpp_state[13] ), //inout
//     // .port16      ( ocp1_vpp_state[14] ), //inout
//     // .port17      ( ocp1_vpp_state[15] ), //inout
//     // .int         ( ocp1_vpp_int_n     )  //output
// // );

// // assign  ocp1_vpp_state[4]  = w_PAL_OCP1_PRSNT_B0_N & w_PAL_OCP1_PRSNT_B1_N 
//                            // & w_PAL_OCP1_PRSNT_B2_N & w_PAL_OCP1_PRSNT_B3_N  ; //prsnt 

// OCP1子卡存在检测：高电平表示无子卡插入
// assign  w_ocp_prsnt_n   =   w_PAL_OCP1_PRSNT_B0_N & w_PAL_OCP1_PRSNT_B1_N & w_PAL_OCP1_PRSNT_B2_N & w_PAL_OCP1_PRSNT_B3_N  ; //prsnt 

// // OCP1子卡插入状态跳变检测
wire    w_ocp1_prsnt_invert;                // 存在状态反转信号（高电平表示状态变化）
wire    w_ocp1_prsnt_invert_dly100ms;       // 状态变化后100ms延时信号
reg      r_ocp1_alert;                      // OCP1告警标志
reg      r_ocp1_test;                       // OCP1测试标志

// 边缘检测模块：检测OCP1子卡存在状态的跳变
// Edge_Detect Edge_Detect_u1(
// .i_clk           (clk_50m),           //input Clk
// .i_rst_n         (pon_reset_n),         //Global rst,Active Low
// .i_signal        (w_ocp_prsnt_n),//ocp1_vpp_state[4]

// .o_signal_pos    (),
// .o_signal_neg    (),
// .o_signal_invert (w_ocp1_prsnt_invert)
// );

//100ms delay  100ms延时模块：状态变化后延时100ms
delay #(.COUNT(5_000_000))    //  20ns--50Mhz   50MHz时钟下计数500万次≈100ms
     ocp1_prsnt_invert_dly100ms(
                   .iClk(clk_50m),
                   .iRst(pon_reset_n),
                   .iStart(r_ocp1_test),  //it should be a level signal not edge signal
                   .iClrCnt(1'b0),
                   .oDone(w_ocp1_prsnt_invert_dly100ms)
                   );
				   
// OCP1告警逻辑：状态变化时触发告警，100ms后清除
always@(posedge clk_50m or negedge pon_reset_n) begin
	if(~pon_reset_n) begin
        r_ocp1_alert <= 1'b1 ;                // 复位时告警有效
		r_ocp1_test  <= 1'b0 ;                // 测试标志清零
	end
	else if(w_ocp1_prsnt_invert) begin        // 检测到状态变化
        r_ocp1_alert <= 1'b0 ;                // 触发告警（低电平有效）
		r_ocp1_test  <= 1'b1 ;                // 启动延时计数
    end
	else if(w_ocp1_prsnt_invert_dly100ms) begin // 100ms延时完成
        r_ocp1_alert <= 1'b1 ;                // 清除告警
		r_ocp1_test  <= 1'b0 ;                // 停止延时计数
    end
end
// //-------------------------------------------------------------------------------------------------
// // OCP1_HP_SW_EN（热插拔开关使能）
// //-------------------------------------------------------------------------------------------------
// wire  w_ctl_pal_ocp_hp_sw_en_r ;             // 热插拔开关控制信号（延时后）
// reg   r_pal_ocp_hp_sw_en_r ;                 // 热插拔开关使能寄存器（输出）
// wire  w_ocp1_aux_pwr_en ;                    // OCP1辅助电源使能信号
// //50ms delay
// delay #(.COUNT(2_500_000))    //  20ns--50Mhz
//      ocp_hp_sw_en_dly50ms(
//                    .iClk(clk_50m),
//                    .iRst(pon_reset_n),
//                    .iStart(~w_ocp_prsnt_n),   
//                    .iClrCnt(1'b0),
//                    .oDone(w_ctl_pal_ocp_hp_sw_en_r)// 50ms完成信号
//                    );
				   
// // 热插拔开关使能逻辑：辅助电源使能且延时完成后，使能开关
// always@(posedge clk_50m or negedge pon_reset_n)
// begin
// 	if(~pon_reset_n)
// 	  begin
//          r_pal_ocp_hp_sw_en_r <= 1'b1 ;
// 	  end
// 	else if(w_ctl_pal_ocp_hp_sw_en_r & w_ocp1_aux_pwr_en )
// 	  begin
//          r_pal_ocp_hp_sw_en_r <= 1'b0 ;
//       end
//    else if(~(w_ctl_pal_ocp_hp_sw_en_r & w_ocp1_aux_pwr_en))   
// 	  begin
//          r_pal_ocp_hp_sw_en_r <= 1'b1 ;
//       end
// end
// //-------------------------------------------------------------------------------------------------
// // OCP1_AUXPWR_ON_EN（辅助电源使能）
// //-------------------------------------------------------------------------------------------------
// reg  r_pal_ocp1_auxpwr_on_r    ;
// //50ms delay
// delay #(.COUNT(2_500_000))    //  20ns--50Mhz
//      ocp1_aux_pwr_en_dly50ms(
//                    .iClk(clk_50m),
//                    .iRst(pon_reset_n),
//                    .iStart(w_pgd_p3v3_stby ),   
//                    .iClrCnt(1'b0),
//                    .oDone(w_ocp1_aux_pwr_en)// 50ms完成信号
//                    );	

// // 辅助电源使能逻辑：延时完成后开启辅助电源
// always@(posedge clk_50m or negedge pon_reset_n)
// begin
// 	if(~pon_reset_n)
// 	  begin
// 		 r_pal_ocp1_auxpwr_on_r  <= 1'b0 ;
// 	  end
// 	else if(w_ocp1_aux_pwr_en)
// 	  begin
// 		 r_pal_ocp1_auxpwr_on_r  <= 1'b1 ;
//       end
//     else if(~w_ocp1_aux_pwr_en)     
// 	  begin
// 		 r_pal_ocp1_auxpwr_on_r  <= 1'b0 ;
//       end
// end				   

// //-------------------------------------------------------------------------------------------------
// // OCP1_MAIN_PWR_ON（主电源使能）
// //-------------------------------------------------------------------------------------------------	
// wire w_ocp1_main_pwr_on ;                    // 主电源使能信号（延时后）
// reg  r_pal_ocp1_mainpwr_on_r   ;             // 主电源使能寄存器（输出）

// //50ms delay
// delay #(.COUNT(2_500_000))    //  20ns--50Mhz
//      ocp1_main_pwr_en_dly50ms(
//                    .iClk(clk_50m),
//                    .iRst(pon_reset_n),
//                    .iStart(w_PWRGD_P12V & w_ctl_pal_ocp_hp_sw_en_r),   
//                    .iClrCnt(1'b0),
//                    .oDone(w_ocp1_main_pwr_on)
//                    );		

// // 主电源使能逻辑：延时完成后开启主电源
// always@(posedge clk_50m or negedge pon_reset_n)
// begin
// 	if(~pon_reset_n)
// 	  begin
// 		 r_pal_ocp1_mainpwr_on_r <= 1'b0 ;
// 	  end
// 	else if(w_ocp1_main_pwr_on)
// 	  begin
// 		 r_pal_ocp1_mainpwr_on_r <= 1'b1 ;
//       end
// 	else if(~w_ocp1_main_pwr_on)                
// 	  begin
// 		 r_pal_ocp1_mainpwr_on_r <= 1'b0 ;
//       end
// end

// //-------------------------------------------------------------------------------------------------
// // OCP1_STBY_PWR_EN（待机电源使能）
// //-------------------------------------------------------------------------------------------------	
// wire w_ocp1_stby_pwr_en ;                    // 待机电源使能信号（延时后）
// reg  r_pal_ocp1_stby_pwr_en_r   ;            // 待机电源使能寄存器（输出）


// //50ms delay
// delay #(.COUNT(2_500_000))    //  20ns--50Mhz
//      ocp1_stby_pwr_en_dly50ms(
//                    .iClk(clk_50m),
//                    .iRst(pon_reset_n),
//                    .iStart(db_i_pal_ocp1_pgd),   //
//                    .iClrCnt(1'b0),
//                    .oDone(w_ocp1_stby_pwr_en)
//                    );			

// // 待机电源使能逻辑：延时完成后开启待机电源
// always@(posedge clk_50m or negedge pon_reset_n)
// begin
// 	if(~pon_reset_n)
// 	  begin
//          r_pal_ocp1_stby_pwr_en_r <= 1'b0 ;
// 	  end
// 	else if(w_ocp1_stby_pwr_en)
// 	  begin
//          r_pal_ocp1_stby_pwr_en_r <= 1'b1 ;
//       end
// 	else if(~w_ocp1_stby_pwr_en)          
// 	  begin
//          r_pal_ocp1_stby_pwr_en_r <= 1'b0 ;
//       end
// end

// //-------------------------------------------------------------------------------------------------
// // OCP1_MAIN_PWR_EN（主电源使能扩展，与上述主电源控制复用）
// //-------------------------------------------------------------------------------------------------
// wire  w_ocp1_main_pwr_en;                    // 主电源使能信号（100ms延时后）
// reg   r_pal_ocp_main_pwr_en_r;               // 主电源使能寄存器（输出）

// //100ms delay
// delay #(.COUNT(5_000_000))    //  20ns--50Mhz
//      ocp_main_pwr_en_dly100ms(
//                    .iClk(clk_50m),
//                    .iRst(pon_reset_n),
//                    .iStart(w_P0_SLP_S3_N),   
//                    .iClrCnt(1'b0),
//                    .oDone(w_ocp1_main_pwr_en)
//                    );

// // 主电源使能逻辑：延时完成后开启主电源		   
// always@(posedge clk_50m or negedge pon_reset_n)
// begin
//     if(~pon_reset_n)
//         begin
//         r_pal_ocp_main_pwr_en_r <= 1'b0 ;
//         end
//     else if(w_ocp1_main_pwr_en)
//         begin
//         r_pal_ocp_main_pwr_en_r <= 1'b1 ;
//         end
//     else if(~w_ocp1_main_pwr_en)          
//         begin
//         r_pal_ocp_main_pwr_en_r <= 1'b0 ;
//         end
// end

// //-------------------------------------------------------------------------------------------------
// // OCP1_PWRBRK_OD_N（电源中断开漏输出）
// //-------------------------------------------------------------------------------------------------
// wire    w_pal_ocp_pwrbrk_od_n_flag ;         // 电源中断标志（未使用）
// reg      r_pal_ocp_pwrbrk_od_n_r    ;        // 电源中断寄存器（输出）

// // 电源中断控制逻辑：反向输出标志信号
// always@(posedge clk_50m or negedge pon_reset_n)
// begin
// 	if(~pon_reset_n)
// 	  begin
//          r_pal_ocp_pwrbrk_od_n_r <= 1'b1 ;      // 复位时无中断（高电平）
// 	  end
// 	else
// 	  begin
//          r_pal_ocp_pwrbrk_od_n_r <= ~w_pal_ocp_pwrbrk_od_n_flag ;  // 标志取反输出
//       end
// end

// //-------------------------------------------------------------------------------------------------
// // OCP1_SWITCH_EN_N（开关使能）
// //-------------------------------------------------------------------------------------------------
// reg  r_pal_ocp1_switch_en_n_r;               // 开关使能寄存器（输出）
// wire w_ctl_pal_ocp1_switch_en_n_r;           // 开关控制信号（未使用，来自BMC）

// // 开关使能逻辑：跟随BMC控制信号
// always@(posedge clk_50m or negedge pon_reset_n)
// begin
// 	if(~pon_reset_n)
// 	  begin
//          r_pal_ocp1_switch_en_n_r <= 1'b1 ;      // 复位时开关禁用（高电平）
// 	  end
// 	else
// 	  begin
//          r_pal_ocp1_switch_en_n_r <= w_ctl_pal_ocp1_switch_en_n_r ;  // 跟随BMC控制
//       end
// end

// //-------------------------------------------------------------------------------------------------
// // OCP1_SMRST_N（系统管理复位）
// //-------------------------------------------------------------------------------------------------

// wire w_pal_ocp_smrst_n_flag         ;         // SMRST复位标志（未使用）
// wire w_ocp_smrst_flag_posedge       ;         // SMRST标志上升沿
// reg  r_pal_ocp_smrst_n_r            ;         // SMRST复位寄存器（输出）
// reg [8:0] r_ocp_smrst_n_dly_time_cnt;         // SMRST复位延时计数器（0~500ms）
// reg [2:0] r_ocp_smrst_flag_dly      ;         // SMRST标志延时寄存器（用于边沿检测）

// //detect ocp_smrst_flag posedge 边沿检测：捕捉SMRST标志的上升沿
// always@(posedge clk_50m or negedge pon_reset_n)
// begin
// 	if(~pon_reset_n)
// 		r_ocp_smrst_flag_dly <= 3'd0;
// 	else
// 		r_ocp_smrst_flag_dly <= {r_ocp_smrst_flag_dly[2:0],w_pal_ocp_smrst_n_flag}; 
// end

// assign w_ocp_smrst_flag_posedge = (!r_ocp_smrst_flag_dly[2]) & r_ocp_smrst_flag_dly[1];// 上升沿检测

// // SMRST复位逻辑：收到上升沿后拉低复位500ms，然后释放
// always @(posedge clk_50m or negedge pon_reset_n) begin
// 	  if (~pon_reset_n) begin
// 		  r_pal_ocp_smrst_n_r <= 1'b1;          // 复位时释放复位（高电平）
// 		  r_ocp_smrst_n_dly_time_cnt <= 9'd0;   // 计数器清零
// 	  end
// 	  else if (w_ocp_smrst_flag_posedge) begin  // 检测到上升沿
// 		  r_pal_ocp_smrst_n_r <= 1'b0;          // 拉低复位（低电平有效）
// 		  r_ocp_smrst_n_dly_time_cnt <= 9'd0;   // 计数器清零
// 	  end
// 	else if (r_ocp_smrst_n_dly_time_cnt == 9'd500) begin  // 计数到500ms
// 	  	  r_pal_ocp_smrst_n_r <= 1'b1;          // 释放复位
// 	  end
// 	else if (t1ms_tick) begin                  // 每1ms计数一次
// 		  r_ocp_smrst_n_dly_time_cnt <= r_ocp_smrst_n_dly_time_cnt + 1'b1;
// 	  end
// end

// //-------------------------------------------------------------------------------------------------
// // OCP1_PERST_N（PCIe复位）
// //-------------------------------------------------------------------------------------------------

// // reg  r_pal_ocp_perst0_n_r ;
// // reg  r_pal_ocp_perst1_n_r ;
// reg  r_pal_ocp_perst2_n_r ;                  // PERST2复位寄存器（输出）
// reg  r_pal_ocp_perst3_n_r ;                  // PERST3复位寄存器（输出）
// wire w_ocp1_pwrgd_dly1s;                     // OCP1电源稳定后1s延时信号

// //1000ms delay
// delay #(.COUNT(50_000_000))    //  20ns--50Mhz  
//      ocp_perst_dly1000ms(
//                    .iClk(clk_50m),
//                    .iRst(pon_reset_n),
//                    .iStart(db_i_pal_ocp1_pwrgd ),   // 
//                    .iClrCnt(1'b0),
//                    .oDone(w_ocp1_pwrgd_dly1s)
//                    );
	
// // PCIe复位逻辑：电源稳定1s且系统PCIe复位释放后，释放OCP1的PERST复位	
// always @(posedge clk_50m or negedge pon_reset_n) begin
// 	  if (~pon_reset_n) 
// 	    begin
// 		    // r_pal_ocp_perst0_n_r <= 1'b0;
// 		    // r_pal_ocp_perst1_n_r <= 1'b0;
//                     r_pal_ocp_perst2_n_r <= 1'b0;
// 		    r_pal_ocp_perst3_n_r <= 1'b0;			
// 	    end
// 	else if (w_ocp1_pwrgd_dly1s & w_p0_pcie_rst_n_0) // 1s延时完成且系统PCIe复位释放
// 	    begin
//                     // r_pal_ocp_perst0_n_r <= 1'b1;
// 		    // r_pal_ocp_perst1_n_r <= 1'b1;
//                     r_pal_ocp_perst2_n_r <= 1'b1;
// 		    r_pal_ocp_perst3_n_r <= 1'b1;
// 	    end
// 	else if (~(w_ocp1_pwrgd_dly1s & w_p0_pcie_rst_n_0)) // 条件不满足
// 	    begin
//                     // r_pal_ocp_perst0_n_r <= 1'b0;
// 		    // r_pal_ocp_perst1_n_r <= 1'b0;
//                     r_pal_ocp_perst2_n_r <= 1'b0;
// 		    r_pal_ocp_perst3_n_r <= 1'b0;
// 	    end
// end
// //-------------------------------------------------------------------------------------------------
// // output clk（输出时钟生成）
// //-------------------------------------------------------------------------------------------------
// reg r_PAL_BMC_RMII_CLK_50M_R   ;             // BMC RMII接口50MHz时钟
// reg r_PAL_OCP_NCSI_CLK_50M_R   ;             // OCP NCSI接口50MHz时钟
// reg r_PAL_NCSI_50M_REF_CLK_R   ;             // NCSI参考50MHz时钟

// // 时钟输出逻辑：将50MHz系统时钟分配到各接口
// always@(*)
// 	begin
// 		if(~pon_reset_n)
// 			begin
// 				r_PAL_BMC_RMII_CLK_50M_R  <= 1'b0    ;  // 复位时时钟关闭
// 				r_PAL_OCP_NCSI_CLK_50M_R  <= 1'b0    ;
// 				r_PAL_NCSI_50M_REF_CLK_R  <= 1'b0    ;
// 			end                                      
// 		else                                         
// 			begin                                    
// 				r_PAL_BMC_RMII_CLK_50M_R  <= clk_50m ;  // 输出50MHz时钟
// 				r_PAL_OCP_NCSI_CLK_50M_R  <= clk_50m ;
// 				r_PAL_NCSI_50M_REF_CLK_R  <= clk_50m ;
// 			end
// end

// 时钟输出赋值
// assign  o_PAL_BMC_RMII_CLK_50M_R  = r_PAL_BMC_RMII_CLK_50M_R   ;
// assign  o_PAL_OCP_NCSI_CLK_50M_R  = r_PAL_OCP_NCSI_CLK_50M_R   ;
// assign  o_PAL_NCSI_50M_REF_CLK_R  = r_PAL_NCSI_50M_REF_CLK_R   ;

// 该模块是OCP（Open Compute Project）接口的控制与状态管理模块，主要功能包括：
// 状态采集：通过串并转换芯片（74LV165）采集 OCP 接口的链路状态（速度、活动）、子卡存在检测、温度告警等 32 路信号。
// 子卡识别：读取 OCP Riser 子卡的板 ID 和 PCB 版本，判断子卡是否有效插入。
// 电源控制：实现 OCP 子卡的热插拔电源管理，包括辅助电源、主电源、待机电源的时序控制（延时开启 / 关闭）。
// 复位管理：生成 OCP 子卡的系统管理复位（SMRST）和 PCIe 复位（PERST），确保子卡上电时序安全。
// 时钟分配：提供 50MHz 参考时钟给 BMC RMII、OCP NCSI 等接口。



//-------------------------------------------------------------------------------------------------
// UID LED 模块：控制UID（Unique Identifier）指示灯，用于设备定位和BMC复位触发
// 说明：UID灯通过按钮或BMC控制，实现设备物理定位（常亮/闪烁）及BMC复位功能
//-------------------------------------------------------------------------------------------------

// 实例化UID功能模块，处理按钮输入和LED控制逻辑
// 参数说明：.LONG_PRESS(4'd5) 表示长按判定阈值为5个1ms周期（即5ms）
UID_Function#(
.LONG_PRESS        (4'd5)
)UID_Function_u0(
.i_clk                    (clk_50m		),		// 输入时钟：50MHz系统时钟
.i_1mSEC                  (t1ms_tick	),		// 1ms周期脉冲：用于计时和长按判定
.i_20mSEC                 (t32ms_tick	),		// 32ms周期脉冲：用于状态机同步
.i_rst_n                  (pon_reset_n	),		// 复位信号：高电平有效（系统复位时初始化模块）
.i_clr_flag_short         (~w_uid_btn_evt_wc),       // 短按标志清除信号（低电平有效，来自事件清除）
.i_clr_flag_long          (~w_uid_rstbmc_evt_wc),    // 长按标志清除信号（低电平有效）
.i_UID_BMC_BTN_N          (1'b1),                    // BMC侧UID按钮输入（固定为高，未使用）
.i_UID_BTN_RP_CPLD_N      (db_i_uid_sw_in_n	),	// CPLD侧UID按钮输入（去抖后，低电平表示按下）
.i_UID_BTN_FP_CPLD_N      (1'b1),                    // 前面板UID按钮输入（固定为高，未使用）

// 输出信号
.o_BMC_UID_CPLD_N         (),   // 预留：BMC控制UID灯的信号（未使用）
.o_BMC_EXTRST_CPLD_OUT_N  (w_bmc_extrst_uid		),	// BMC外部复位信号（低电平有效，长按按钮触发）
.o_UID_BTN_short_pos      (uid_btn_all_invert	),	// UID按钮短按上升沿标志（短按触发）

.o_uid_button_long        (uid_button_long_evt ),	// 长按事件标志（高电平表示长按发生）
.o_uid_button_short       (uid_button_short_evt),	// 短按事件标志（高电平表示短按发生）

.i_uid_valid              (1'b0),  // 预留：UID有效标志（未使用）
.i_uid_status             (8'h00), // 预留：UID状态（未使用）
.o_uid_act_st             ()       // 预留：UID活动状态（未使用）
);

//bmc control uid led when bmc active, or uid button will control uid led when bmc die;
// BMC与按钮协同控制UID灯逻辑：BMC正常时由BMC控制，BMC故障时由按钮控制
reg r_BMC_UID_CPLD_N;                // UID灯控制寄存器（低电平点亮）
reg [7:0] r_uid_led_ctl;             // UID灯控制模式寄存器
//assign o_uid_led_ctl    = r_uid_led_ctl;

always@(posedge clk_50m or negedge pon_reset_n)
begin
    if(~pon_reset_n)
	begin
            r_BMC_UID_CPLD_N  <= 1'b1;    // 复位时灯灭（高电平）
            r_uid_led_ctl     <= 8'h00;   // 复位时控制模式为0
	end
	else if(w_bmc_ready_flag)  // BMC就绪（正常工作）：由BMC控制UID灯
    begin
		r_uid_led_ctl  <= w_uid_led_ctl;  // 同步BMC的控制命令
	    case (w_uid_led_ctl)              // 根据BMC命令设置灯状态
                8'h00: r_BMC_UID_CPLD_N  <= 1'b1;    // 模式0：灯灭
                8'h01: r_BMC_UID_CPLD_N  <= t0p5hz_clk; // 模式1：0.5Hz闪烁（慢闪）
                8'h02: r_BMC_UID_CPLD_N  <= t1hz_clk;   // 模式2：1Hz闪烁
                8'h04: r_BMC_UID_CPLD_N  <= t4hz_clk;   // 模式4：4Hz闪烁（快闪）
                8'hff: r_BMC_UID_CPLD_N  <= 1'b0;    // 模式ff：常亮
                default: r_BMC_UID_CPLD_N  <= 1'b1;    // 默认：灯灭
	    endcase
	end
	else  // BMC未就绪（故障）：由物理按钮控制UID灯
	begin
		case (r_uid_led_ctl)
		8'h00: 	// 当前模式：灯灭
		begin
			r_BMC_UID_CPLD_N  <= 1'b1;    // 灯灭
			if(uid_btn_all_invert) 	    // 检测到短按：切换为常亮
		        r_uid_led_ctl     <= 8'hff;
		end
		8'h01,8'h02,8'h04: 	// 当前模式：闪烁
		begin
			if(uid_btn_all_invert)        // 检测到短按：切换为常亮
			    r_uid_led_ctl     <= 8'hff;
		end		
		8'hff:	// 当前模式：常亮
		begin
			r_BMC_UID_CPLD_N  <= 1'b0;    // 常亮
			if(uid_btn_all_invert) 	    // 检测到短按：切换为灯灭
		        r_uid_led_ctl     <= 8'h00;
		end
		default: 	// 异常模式：复位为灯灭
		begin 
		    r_uid_led_ctl     <= 8'h00; 
       	end	
		endcase	 
	end
end
//-------------------------------------------------------------------------------------------------
// NIC & SYSTEM HEALTHY LED 模块：控制网络接口（NIC）和系统健康状态指示灯
// 说明：通过红/绿双色灯表示系统健康状态（正常、故障等）
//-------------------------------------------------------------------------------------------------
wire    w_sys_healthy_red   ;         // 系统健康红色灯控制信号（高电平有效）
wire    w_sys_healthy_grn   ;         // 系统健康绿色灯控制信号（高电平有效）
reg      r_pal_led_hel_red_r  ;        // 红色健康灯输出寄存器（驱动硬件LED）
reg      r_pal_led_hel_gr_r   ;        // 绿色健康灯输出寄存器（驱动硬件LED）

// 健康灯控制逻辑：根据系统健康信号组合控制红绿灯状态
always@(posedge clk_50m or negedge pon_reset_n)
begin
	if(~pon_reset_n)
            begin
                r_pal_led_hel_red_r  <= 1'b0;    // 复位时红灯灭
                r_pal_led_hel_gr_r   <= 1'b0;    // 复位时绿灯灭
            end
	else 
            begin
                case({w_sys_healthy_red,w_sys_healthy_grn}) 	// 按红绿信号组合控制
                    2'b00: begin                   // 00：系统未就绪
                        r_pal_led_hel_red_r  <= 1'b0;
                        r_pal_led_hel_gr_r   <= 1'b0;
                    end
                    2'b01: begin                   // 01：系统正常
                        r_pal_led_hel_red_r  <= 1'b0;
                        r_pal_led_hel_gr_r   <= 1'b1;    // 绿灯常亮
                    end
                    2'b10: begin                   // 10：系统故障
                        r_pal_led_hel_red_r  <= t1hz_clk; // 红灯1Hz闪烁
                        r_pal_led_hel_gr_r   <= 1'b0;
                    end
                    2'b11: begin                   // 11：系统警告
                        r_pal_led_hel_red_r  <= t1hz_clk; // 红绿灯同时1Hz闪烁
                        r_pal_led_hel_gr_r   <= t1hz_clk;
                    end
                    default: 	// 默认：灯灭
                        begin
                            r_pal_led_hel_red_r  <= 1'b0;
                            r_pal_led_hel_gr_r   <= 1'b0;
                        end
                endcase
            end
end
//-------------------------------------------------------------------------------------------------
// S5_S0 LED 模块：控制电源按钮指示灯，反映系统电源状态（S5待机/S0运行）
// 说明：通过绿色和琥珀色灯表示系统当前处于待机还是运行状态
//-------------------------------------------------------------------------------------------------
reg      r_led_pwrbtn_gr ;     // 电源按钮绿色灯寄存器
reg      r_led_pwrbtn_amb;     // 电源按钮琥珀色灯寄存器

// 电源状态灯控制逻辑：根据系统电源状态（S5/S0）和5V电源状态控制灯色
always@(posedge clk_50m or negedge pon_reset_n) begin
	if(~pon_reset_n) begin
			r_led_pwrbtn_gr  <= 1'b0 ;    // 复位时绿灯灭
			r_led_pwrbtn_amb <= 1'b1 ;    // 复位时琥珀灯亮（默认待机）
		end
	else begin
	    // w_P0_SLP_S5_N：S5待机状态标志（高电平=S0运行，低电平=S5待机）
	    // w_pgd_p5v：5V电源良好标志（高电平=5V稳定）
	    if (w_P0_SLP_S5_N == 1'b0 && w_pgd_p5v == 1'b0 ) begin
		    // 状态1：S5待机且5V电源未就绪→琥珀灯亮
		    r_led_pwrbtn_gr  <= 1'b0 ;
		    r_led_pwrbtn_amb <= 1'b1 ;
		end
		else if (w_P0_SLP_S5_N == 1'b1 && w_pgd_p5v == 1'b0) begin
		    // 状态2：S0运行但5V电源未就绪→绿灯2.5Hz闪烁（异常）
		    r_led_pwrbtn_gr  <= t2p5hz_clk ;
		    r_led_pwrbtn_amb <= 1'b0 ;
		end
		else if (w_P0_SLP_S5_N == 1'b1 && w_pgd_p5v == 1'b1) begin
		    // 状态3：S0运行且5V电源就绪→绿灯常亮（正常）
		    r_led_pwrbtn_gr  <= 1'b1 ;
		    r_led_pwrbtn_amb <= 1'b0 ;
		end
		else begin
		    // 其他状态→琥珀灯亮（默认待机）
		    r_led_pwrbtn_gr  <= 1'b0 ;
		    r_led_pwrbtn_amb <= 1'b1 ;
		end
	end
end  

// 1. UID LED 模块:
// BMC 正常工作时，由 BMC 通过w_uid_led_ctl指令控制灯的状态（灭、0.5Hz 慢闪、1Hz 闪烁、4Hz 快闪、常亮）。
// BMC 故障时，自动切换为物理按钮控制（短按切换常亮 / 灭）。
// 长按按钮触发w_bmc_extrst_uid（低电平有效），用于强制复位 BMC。
// 2. 系统健康指示灯（NIC & SYSTEM HEALTHY LED）
// 绿灯常亮：系统正常（w_sys_healthy_grn=1）。
// 红灯 1Hz 闪烁：系统故障（w_sys_healthy_red=1）。
// 红绿灯同时闪烁：系统警告（w_sys_healthy_red=1且w_sys_healthy_grn=1）。
// 灯灭：系统未就绪（默认状态）。
// 3. 电源状态灯（S5_S0 LED）
// 琥珀灯亮：系统处于 S5 待机模式（w_P0_SLP_S5_N=0）。
// 绿灯常亮：系统处于 S0 运行模式且 5V 电源稳定（w_P0_SLP_S5_N=1且w_pgd_p5v=1）。
// 绿灯 2.5Hz 闪烁：系统尝试进入 S0 模式但 5V 电源异常（w_P0_SLP_S5_N=1且w_pgd_p5v=0），提示电源故障。

//-------------------------------------------------------------------------------------------------
// MISC（杂项控制）模块：包含主板开关使能、BIOS控制等辅助功能信号的寄存器映射
// 说明：通过寄存器缓存控制信号，实现对主板外设和BIOS的状态管理
//-------------------------------------------------------------------------------------------------
reg      r_pal_mb_switch_en_n_r         ;         // 主板开关使能寄存器（低电平有效）
// // reg r_remote_xdp_tck_sel_r         ;         // 远程XDP调试时钟选择寄存器（未使用）
// // reg r_remote_xdp_debug_n_r         ;         // 远程XDP调试使能寄存器（未使用）
reg      r_pal_biosrom_io11             ;         // BIOS ROM的IO11引脚控制寄存器
reg      r_pal_bios_online_update_en    ;         // BIOS在线更新使能寄存器（高电平有效）
wire    w_pal_mb_switch_en_n_r        ;         // 主板开关使能输入信号
// // wire w_remote_xdp_tck_sel_r        ;         // 远程XDP时钟选择输入（未使用）
// // wire w_remote_xdp_debug_n_r        ;         // 远程XDP调试使能输入（未使用）

// 杂项控制寄存器逻辑：同步输入信号到寄存器，实现缓存和延迟输出
always@(posedge clk_50m or negedge pon_reset_n)
begin
	if(~pon_reset_n)
	  begin
	    r_pal_mb_switch_en_n_r       <= 1'b0;    // 复位时开关使能有效（低电平）
		// r_remote_xdp_tck_sel_r       <= 1'b0;    // 复位时默认时钟选择（未使用）
		// r_remote_xdp_debug_n_r       <= 1'b1;    // 复位时禁用远程调试（未使用）
		r_pal_biosrom_io11           <= 1'b1;    // 复位时BIOS ROM IO11引脚默认高电平
		r_pal_bios_online_update_en  <= 1'b0;    // 复位时禁用BIOS在线更新
	  end
	else
	  begin
	    r_pal_mb_switch_en_n_r       <= w_pal_mb_switch_en_n_r;  // 同步主板开关使能信号
		// r_remote_xdp_tck_sel_r       <= w_remote_xdp_tck_sel_r  ;  // 同步XDP时钟选择（未使用）
		// r_remote_xdp_debug_n_r       <= w_remote_xdp_debug_n_r  ;  // 同步XDP调试使能（未使用）
		r_pal_biosrom_io11           <= w_pal_biosrom_io11      ;  // 同步BIOS ROM IO11控制信号
		r_pal_bios_online_update_en  <= ~w_pal_biosrom_io11 ;     // IO11低电平时使能BIOS在线更新
    end
end
// assign o_PAL_MB_SWITCH_EN_N_R       = r_pal_mb_switch_en_n_r        ;
// assign o_REMOTE_XDP_TCK_SEL_R       = r_remote_xdp_tck_sel_r        ;
// assign o_REMOTE_XDP_DEBUG_N_R       = r_remote_xdp_debug_n_r        ;
// assign o_PAL_BIOSROM_IO11           = r_pal_biosrom_io11            ;
// assign o_PAL_BIOS_ONLINE_UPDATE_EN  = r_pal_bios_online_update_en   ;

// //-------------------------------------------------------------------------------------------------
// // USB_HUB_PWR_EN（USB集线器电源使能）模块：控制USB集线器的3.3V电源时序
// // 说明：在1.2V待机电源稳定后，延迟使能USB集线器电源，确保供电安全
// //-------------------------------------------------------------------------------------------------
// wire w_ctl_pal_usb_hub2_p3v3_en_r ;         // USB集线器电源使能控制信号（延迟后）
// reg  r_pal_usb_hub2_p3v3_en_r ;             // USB集线器电源使能寄存器（输出）
// // 50ms延时模块：1.2V待机电源稳定后，延迟50ms使能USB集线器电源
// delay #(.COUNT(2_500_000))    //  20ns--50Mhz
//      USB_PWR_EN_DLY100ms(
//                    .iClk(clk_50m),
//                    .iRst(pon_reset_n),
//                    .iStart(w_pgd_p1v2_stby),   //
//                    .iClrCnt(1'b0),
//                    .oDone(w_ctl_pal_usb_hub2_p3v3_en_r)
//                    );

// // USB集线器电源使能逻辑：延时完成后开启3.3V电源
// always@(posedge clk_50m or negedge pon_reset_n)
// begin
// 	if(~pon_reset_n)
// 	  begin
//          r_pal_usb_hub2_p3v3_en_r <= 1'b0 ;    // 复位时电源关闭
// 	  end
// 	else if(w_ctl_pal_usb_hub2_p3v3_en_r)
// 	  begin
//          r_pal_usb_hub2_p3v3_en_r <= 1'b1 ;    // 延时完成，开启电源
//       end
// 	else
// 	  begin
//          r_pal_usb_hub2_p3v3_en_r <= 1'b0 ;    // 其他情况关闭电源
//       end
// end
//-----------------------------------------------------------------------------------

//-------------------------------------------------------------------------------------------------
// CPU0 PE0 --- PVT_DATA：CPU0 MCIO接口的调试数据传输模块（用于开关调试）
// 说明：通过串并转换模块（s2p_164）将并行测试数据转换为串行信号，输出到MCIO接口引脚
//-------------------------------------------------------------------------------------------------
// wire [7:0]  w_164_test_data ;         // 8位并行测试数据（未明确赋值，默认测试值）
// wire w_164_mr_n;                      // 主复位信号（未使用，高电平有效）

// // 实例化串并转换模块s2p_164：将8位并行数据转换为串行输出
// s2p_164  s2p_164_u1(   // 注：原参数NBIT=8（8位数据）
//   .i_clk     (clk_50m)  ,              // 工作时钟：50MHz
//   .i_rst     (~pon_reset_n)  ,         // 复位信号：低电平有效
//   .tick      (t1us_tick)  ,            // 1us周期脉冲：控制串行传输速率
//   .CLK_1ms  (w1mSCE) ,                 // 1ms周期脉冲：用于时序同步
  
//   .i_mr_n    (w_164_mr_n)  ,           // 主复位（未使用，默认高电平）
//   .pi        (w_164_test_data)  ,      // 8位并行输入数据（测试数据）
//   .so        (o_P0_MCIOP1C_WAKE_N_R)  , // 串行数据输出：复用MCIOP1C的WAKE_N引脚
//   .sld_n     (o_P0_MCIOP1A_WAKE_N_R)  , // 加载使能输出：复用MCIOP1A的WAKE_N引脚
//   .o_sclk    (o_P0_MCIOP1C_RSV_R)      // 串行时钟输出：复用MCIOP1C的预留引脚
// ) ;
// // assign o_CPU0_MCIO0C_RSV_R = 1'b1 ; //2024-2-22 CHG TO USE AS EN , ALWAYS SET HIGH



//-------------------------------------------------------------------------------------------------
// edge_delay（边沿延迟）模块：生成一系列延迟10ms的级联信号，用于控制电源槽位的上电时序
// 说明：通过对系统状态信号（S0运行模式）的边沿延迟，实现多个电源槽位按顺序上电
//-------------------------------------------------------------------------------------------------
// 槽位3上电延迟：系统进入S0模式后延迟10ms
edge_delay #(.CNTR_NBITS(6), .DELAY_MODE(1'b0)) edge_delay_slot_3_on_dly_10ms (   // DELAY_MODE=0：检测上升沿
    .clk         (clk_50m),                // 时钟：50MHz
    .reset       (~pon_reset_n),           // 复位：低电平有效
    .cnt_size    (6'd10),                  // 计数阈值：10（配合1ms脉冲实现10ms延迟）
    .cnt_step    (t1ms_tick),              // 计数步长：1ms脉冲
    .signal_in   (w_P0_SLP_S5_N),          // 输入信号：系统S0模式标志（高电平=S0运行）
    .delay_output(w_slot_3_on_dly_10ms)    // 输出：槽位3上电延迟信号
);
// 槽位4上电延迟：在槽位3延迟信号基础上再延迟10ms
edge_delay #(.CNTR_NBITS(6), .DELAY_MODE(1'b0)) edge_delay_slot_4_on_dly_10ms (
    .clk         (clk_50m),
    .reset       (~pon_reset_n),
    .cnt_size    (6'd10),
    .cnt_step    (t1ms_tick),
    .signal_in   (w_slot_3_on_dly_10ms),   // 输入：槽位3延迟信号
    .delay_output(w_slot_4_on_dly_10ms)    // 输出：槽位4上电延迟信号
);
// 槽位5上电延迟：在槽位4延迟信号基础上再延迟10ms
edge_delay #(.CNTR_NBITS(6), .DELAY_MODE(1'b0)) edge_delay_slot_5_on_dly_10ms (
    .clk         (clk_50m),
    .reset       (~pon_reset_n),
    .cnt_size    (6'd10),
    .cnt_step    (t1ms_tick),
    .signal_in   (w_slot_4_on_dly_10ms),   // 输入：槽位4延迟信号
    .delay_output(w_slot_5_on_dly_10ms)    // 输出：槽位5上电延迟信号
);
// 槽位6上电延迟：在槽位5延迟信号基础上再延迟10ms
edge_delay #(.CNTR_NBITS(6), .DELAY_MODE(1'b0)) edge_delay_slot_6_on_dly_10ms (
    .clk         (clk_50m),
    .reset       (~pon_reset_n),
    .cnt_size    (6'd10),
    .cnt_step    (t1ms_tick),
    .signal_in   (w_slot_5_on_dly_10ms),   // 输入：槽位5延迟信号
    .delay_output(w_slot_6_on_dly_10ms)    // 输出：槽位6上电延迟信号
);
edge_delay #(.CNTR_NBITS(6), .DELAY_MODE(1'b0)) edge_delay_slot_7_on_dly_10ms (   //DELAY_MODE =0 for rise edge
    .clk         (clk_50m),
    .reset       (~pon_reset_n),
    .cnt_size    (6'd10),
    .cnt_step    (t1ms_tick),
    .signal_in   (w_slot_6_on_dly_10ms),//2024-4-10 chg w_PWRGD_P12V to w_pch_slp5_n
    .delay_output(w_slot_7_on_dly_10ms)
);
edge_delay #(.CNTR_NBITS(6), .DELAY_MODE(1'b0)) edge_delay_slot_8_on_dly_10ms (   //DELAY_MODE =0 for rise edge
    .clk         (clk_50m),
    .reset       (~pon_reset_n),
    .cnt_size    (6'd10),
    .cnt_step    (t1ms_tick),
    .signal_in   (w_slot_7_on_dly_10ms),//2024-4-10 chg w_PWRGD_P12V to w_pch_slp5_n
    .delay_output(w_slot_8_on_dly_10ms)
);
edge_delay #(.CNTR_NBITS(6), .DELAY_MODE(1'b0)) edge_delay_slot_9_on_dly_10ms (   //DELAY_MODE =0 for rise edge
    .clk         (clk_50m),
    .reset       (~pon_reset_n),
    .cnt_size    (6'd10),
    .cnt_step    (t1ms_tick),
    .signal_in   (w_slot_8_on_dly_10ms),//2024-4-10 chg w_PWRGD_P12V to w_pch_slp5_n
    .delay_output(w_slot_9_on_dly_10ms)
);

//---------------------------------------------------------------------------------------------
// 12V电源良好标志（PS3和PS4电源模块）：PS3/PS4存在且直流输出正常时有效
// assign  w_PWRGD_P12V_PS3_PS4    =   (~i_PS3_DCOK_N & i_PS3_PRSNT) || (~i_PS4_DCOK_N & i_PS4_PRSNT);
// assign  w_PS3_PS4_ACFAIL    =   db_i_ps3_acfail_n&&db_i_ps4_acfail_n;
// assign  w_ps3_p12v_on_r  = w_FM_P12V_EN & db_i_ps3_prsnt ;
// assign  w_ps4_p12v_on_r  = w_FM_P12V_EN & db_i_ps4_prsnt ;
assign  w_cpld2_jtagen  =   i_HDR_PAL2_N ? 1'b0 : 1'b1 ;

// assign  w_p12v_slot_3_on  =   w_p12v_slot_3_on_r & (w_slot_3_on_dly_10ms ||(~w_SW_2 && w_P0_SLP_S5_N));
// assign  w_p12v_slot_4_on  =   w_p12v_slot_4_on_r & (w_slot_4_on_dly_10ms ||(~w_SW_2 && w_P0_SLP_S5_N));
// assign  w_p12v_slot_5_on  =   w_p12v_slot_5_on_r & (w_slot_5_on_dly_10ms ||(~w_SW_2 && w_P0_SLP_S5_N));
// assign  w_p12v_slot_6_on  =   w_p12v_slot_6_on_r & (w_slot_6_on_dly_10ms ||(~w_SW_2 && w_P0_SLP_S5_N));
// assign  w_p12v_slot_7_on  =   w_p12v_slot_7_on_r & (w_slot_7_on_dly_10ms ||(~w_SW_2 && w_P0_SLP_S5_N));
// assign  w_p12v_slot_8_on  =   w_p12v_slot_8_on_r & (w_slot_8_on_dly_10ms ||(~w_SW_2 && w_P0_SLP_S5_N));
// assign  w_p12v_slot_9_on  =   w_p12v_slot_9_on_r & (w_slot_9_on_dly_10ms ||(~w_SW_2 && w_P0_SLP_S5_N));

// CPU0/CPU1的PCIe唤醒信号：所有MCIO接口的唤醒信号均为高时有效（高电平表示无唤醒请求）
assign  w_p0_pcie_wake_n_r  =   i_PAL_PE_WAKE_N                  &
                                                         i_P0_MCIOP0A_WAKE_N_R      &
                                                         i_P0_MCIOP0C_WAKE_N_R      &                                                         
                                                         i_P0_MCIOP1A_WAKE_N_R      &
                                                         i_P0_MCIOP1C_WAKE_N_R      &
                                                         i_P0_MCIOP2A_WAKE_N_R      &
                                                         i_P0_MCIOP2C_WAKE_N_R      &
                                                         i_P0_MCIOP3A_WAKE_N_R      &
                                                         i_P0_MCIOP3C_WAKE_N_R      &
                                                         i_P0_MCIOG3A_WAKE_N_R      &
                                                         i_P0_MCIOG3C_WAKE_N_R      
                                                         ;
assign  w_p1_pcie_wake_n_r  =                            i_P1_MCIOP0A_WAKE_N_R      &
                                                         i_P1_MCIOP0C_WAKE_N_R      &
                                                         i_P1_MCIOP1A_WAKE_N_R      &
                                                         i_P1_MCIOP1C_WAKE_N_R      &
                                                         i_P1_MCIOP2A_WAKE_N_R      &
                                                         i_P1_MCIOP2C_WAKE_N_R      &
                                                         i_P1_MCIOP3A_WAKE_N_R      &
                                                         i_P1_MCIOP3C_WAKE_N_R      &
                                                         i_P1_MCIOG1A_WAKE_N_R      &
                                                         i_P1_MCIOG1C_WAKE_N_R
                                                        ;
// DB2000时钟输出使能：5V电源稳定时使能（低电平有效）
assign  w_clk_db2000_2_1_oe_n    = w_pgd_p5v ? 1'b0 : 1'b1 ;  // 时钟1输出使能
assign  w_clk_db2000_2_2_oe_n    = w_pgd_p5v ? 1'b0 : 1'b1 ;  // 时钟2输出使能
// LOM（LAN On Motherboard）电源使能：12V稳定、BMC就绪且系统未进入S3待机时有效
assign  w_pal_pwr_lom_en_r  =   (w_PWRGD_P12V & w_bmc_ready_flag & ~w_P0_SLP_S3_N)? 1'b1 : 1'b0;


//-------------------------------------------------------------------------------------------------
// NC_PIN
//-------------------------------------------------------------------------------------------------
wire    w_nc_pin;
assign  w_nc_pin    =   			   i_HDR_PAL2_N      &
                                       i_CPLD2_DONE     &
                                       i_CPLD2_INIT_N       &
									   i_CPLD2_HOLD_N_R     &
									   i_CPLD2_SN           &
                                       i_JTAG_BMC_TRST_R        &
									   i_SW_1     &
									   i_SW_3     &
									   i_SW_4     &
									   i_SW_5     &
									   i_SW_6     &
									   i_SW_7     &
									   i_SW_8     &
									   i_P0_MCIOP0A_DATAIN     &
                                      //  i_OCP1_BIF0_N           & 
                                      //  i_OCP1_BIF1_N           & 
                                      //  i_OCP1_BIF2_N           & 
                                      //  i_OCP1_UART_RX_R     &
                                       i_CPLD_SGPIO1_CLK        &
                                       i_CPLD_SGPIO1_LD_N       &
                                       i_CPLD_SGPIO1_MOSI       &
                                      //  i_PDB_SPGIO_DATAIN       &
                                      //  i_TYPEC_PRST     &
                                      //  i_NCSI_RSVD_CPLD     &
                                      //  i_CHASSIS_ID1_N      &
                                      //  i_PAL_MAIN_PWR_OK_R      &
                                      //  i_OCP1_DATA_IN_R       &
                                      //  i_BMC_UART1_TX       &
                                      //  i_UART1_TXD_CPLD     &
                                      //  i_CPLD1_CPLD2_RSV1_R     &
                                      //  i_CPLD1_CPLD2_RSV2_R     &
									  i_PAL_SLIMSAS1_PRSNT_N    	
                                       
                                       ;

//-----------------------------------------------------------------------------------------------//
//Output SIGNAL
//-----------------------------------------------------------------------------------------------//
assign  o_CLK_GEN_FINC_R    =   w_clk_gen_finc_r;
assign  o_CLK_GEN_LOL_N_R   =   w_clk_gen_lol_n_r;
assign  o_CLK_GEN_INTR_N_R  =   w_clk_gen_intr_n_r;
assign  o_CLK_GEN_RST_N_R   =   w_clk_gen_rst_n_r;
assign  o_CLK_GEN_OE_N_R    =   w_clk_gen_oe_nr_r;
assign  o_CLK_GEN_FDEC_R    =   w_clk_gen_fdec_r;
assign  o_CLK_GEN_I2C_SEL_R =   w_clk_i2c_sel_r;


assign  o_P0_MCIOP0A_CLK  =   1'bz;
assign  o_P0_MCIOP0A_LD  =   1'bz;
assign  o_CPLD2_JTAGEN  =   w_cpld2_jtagen;
// assign  o_PAL_BMC_RMII_CLK_50M_R    =   r_PAL_BMC_RMII_CLK_50M_R;
// assign  o_P12V_SLOT_3_ON    =   w_p12v_slot_3_on;
// assign  o_P12V_SLOT_4_ON    =   w_p12v_slot_4_on;
// assign  o_P12V_SLOT_5_ON    =   w_p12v_slot_5_on;
// assign  o_P12V_SLOT_6_ON    =   w_p12v_slot_6_on;
// assign  o_P12V_SLOT_7_ON    =   w_p12v_slot_7_on;
// assign  o_P12V_SLOT_8_ON    =   w_p12v_slot_8_on;
// assign  o_P12V_SLOT_9_ON    =   w_p12v_slot_9_on;
// assign  o_PAL_OCP_SS_DATA_OUT_R =   1'b1;

// assign  o_PAL_OCP1_MAINPWR_ON_R       = r_pal_ocp1_mainpwr_on_r      ;
// assign  o_PAL_OCP1_AUXPWR_ON_R         = r_pal_ocp1_auxpwr_on_r  ;  //P3V3_OCP1
// assign  o_PAL_OCP_MAIN_PWR_EN_R       = r_pal_ocp_main_pwr_en_r      ;//48
// assign  o_PAL_OCP_STBY_PWR_EN_R       = r_pal_ocp1_stby_pwr_en_r      ;//47
// assign  o_PAL_OCP_NCSI_CLK_50M_R     = r_PAL_OCP_NCSI_CLK_50M_R     ;//46
// assign  o_PAL_OCP_PERST0_N_R             = r_pal_ocp_smrst_n_r         ;//45

// assign  o_PAL_OCP1_PERST2_R         = r_pal_ocp_perst2_n_r         ;
// assign  o_PAL_OCP1_PERST3_R         = r_pal_ocp_perst3_n_r         ;
// assign  o_PAL_OCP1_SWITCH_EN_N_R = r_pal_ocp1_switch_en_n_r ;
// assign  o_PAL_OCP_PWRBRK_OD_N_R = r_pal_ocp_pwrbrk_od_n_r ;
// assign  o_PAL_OCP_HP_SW_EN_R = r_pal_ocp_hp_sw_en_r ;
// assign  o_OCP1_UART_TX_R     =  1'bz;
// assign  o_OCP1_ATNT_LED_R   =   1'bz;
// assign  o_OCP1_GREEN_LED_R =    1'bz;
assign  o_SMB_PEHP_CPU0_OCP_ALERT = r_ocp1_alert  ;
assign  o_SMB_PEHP_CPU1_OCP_ALERT = r_ocp1_alert  ;
// assign  o_PS3_P12V_ON_R =   w_ps3_p12v_on_r;//1
// assign  o_PS4_P12V_ON_R =   w_ps4_p12v_on_r;//2
assign  o_CPLD_SGPIO1_MISO  =   1'bz;

// assign  o_PAL_LED_UID_R = ~r_BMC_UID_CPLD_N;
// assign  o_LED_PWRBTN_GR_R   = r_led_pwrbtn_gr  ;
// assign  o_LED_PWRBTN_AMB_R  = r_led_pwrbtn_amb ;
// assign  o_PAL_LED_NIC_ACT_R  = w_pal_led_nic_act_r;
// assign  o_PAL_LED_HEL_RED_R  = r_pal_led_hel_red_r   ;
// assign  o_PAL_LED_HEL_GR_R   = r_pal_led_hel_gr_r    ;
// assign  o_PAL_OCP_HP_ATN_LED_R  =   1'bz;
// DEBUG LED
assign  o_LED1_N = w_led_control[0] ? 1'b0 : 1'b1  ;
assign  o_LED2_N = w_led_control[1] ? 1'b0 : 1'b1  ;
assign  o_LED3_N = w_led_control[2] ? 1'b0 : 1'b1  ;
assign  o_LED4_N = w_led_control[3] ? 1'b0 : 1'b1  ;
assign  o_LED5_N = w_led_control[4] ? 1'b0 : 1'b1  ;
assign  o_LED6_N = w_led_control[5] ? 1'b0 : 1'b1  ;
assign  o_LED7_N = w_led_control[6] ? 1'b0 : 1'b1  ;
assign  o_LED8_N = w_led_control[7] ? 1'b0 : 1'b1  ;
// assign  o_PAL_BP1_CPU_IP2P  =   1'b1;
// assign  o_PAL_BP2_CPU_IP2P  =   1'b1;
// assign  o_PAL_BP4_CPU_IP2P  =   1'b1;
// assign  o_PAL_BP5_CPU_IP2P  =   1'b1;
// assign  o_PAL_BP6_CPU_IP2P  =   1'b1;
// assign  o_PAL_BP8_CPU_IP2P  =   1'b1;

assign  o_P0_MCIOP0A_PERST_N_R  =   w_p0_pcie_rst_n_0;
assign  o_P0_MCIOP0C_PERST_N_R  =   w_p0_pcie_rst_n_0;
assign  o_P0_MCIOP1A_PERST_N_R  =   w_p0_pcie_rst_n_0;
assign  o_P0_MCIOP1C_PERST_N_R  =   w_p0_pcie_rst_n_0;
assign  o_P0_MCIOP2A_PERST_N_R  =   w_p0_pcie_rst_n_0;
assign  o_P0_MCIOP2C_PERST_N_R  =   w_p0_pcie_rst_n_0;
assign  o_P0_MCIOP3A_PERST_N_R  =   w_p0_pcie_rst_n_0;
assign  o_P0_MCIOP3C_PERST_N_R  =   w_p0_pcie_rst_n_0;
assign  o_P0_MCIOG3A_PERST_N_R  =   w_p0_pcie_rst_n_0;
assign  o_P0_MCIOG3C_PERST_N_R  =   w_p0_pcie_rst_n_0;
assign  o_P0_MCIOP4A_PERST_N_R  =   w_p0_pcie_rst_n_0;

assign  o_P1_MCIOP0A_PERST_N_R  =   w_p0_pcie_rst_n_0;
assign  o_P1_MCIOP0C_PERST_N_R  =   w_p0_pcie_rst_n_0;
assign  o_P1_MCIOP1A_PERST_N_R  =   w_p0_pcie_rst_n_0;
assign  o_P1_MCIOP1C_PERST_N_R  =   w_p0_pcie_rst_n_0;
assign  o_P1_MCIOP2A_PERST_N_R  =   w_p0_pcie_rst_n_0;
assign  o_P1_MCIOP2C_PERST_N_R  =   w_p0_pcie_rst_n_0;
assign  o_P1_MCIOP3A_PERST_N_R  =   w_p0_pcie_rst_n_0;
assign  o_P1_MCIOP3C_PERST_N_R  =   w_p0_pcie_rst_n_0;
assign  o_P1_MCIOG1A_PERST_N_R  =   w_p0_pcie_rst_n_0;
assign  o_P1_MCIOG1C_PERST_N_R  =   w_p0_pcie_rst_n_0;
assign  o_P1_MCIOP4A_PERST_N_R  =   w_p0_pcie_rst_n_0;


assign  o_P0_MCIOP0A_GPU_THROTTLE_N_R   =   w_p0_mciop0a_gpu_throttle_n_r;
assign  o_P0_MCIOP0C_GPU_THROTTLE_N_R   =   w_p0_mciop0c_gpu_throttle_n_r;
assign  o_P0_MCIOP1A_GPU_THROTTLE_N_R   =   w_p0_mciop1a_gpu_throttle_n_r;
assign  o_P0_MCIOP1C_GPU_THROTTLE_N_R   =   w_p0_mciop1c_gpu_throttle_n_r;
assign  o_P0_MCIOP2A_GPU_THROTTLE_N_R   =   w_p0_mciop2a_gpu_throttle_n_r;
assign  o_P0_MCIOP2C_GPU_THROTTLE_N_R   =   w_p0_mciop2c_gpu_throttle_n_r;
assign  o_P0_MCIOP3A_GPU_THROTTLE_N_R   =   w_p0_mciop3a_gpu_throttle_n_r;
assign  o_P0_MCIOP3C_GPU_THROTTLE_N_R   =   w_p0_mciop3c_gpu_throttle_n_r;
assign  o_P0_MCIOG3A_GPU_THROTTLE_N_R   =   w_p0_mciog3a_gpu_throttle_n_r;
assign  o_P0_MCIOG3C_GPU_THROTTLE_N_R   =   w_p0_mciog3c_gpu_throttle_n_r;

assign  o_P1_MCIOP0A_GPU_THROTTLE_N_R   =   w_p1_mciop0a_gpu_throttle_n_r;
assign  o_P1_MCIOP0C_GPU_THROTTLE_N_R   =   w_p1_mciop0c_gpu_throttle_n_r;
assign  o_P1_MCIOP1A_GPU_THROTTLE_N_R   =   w_p1_mciop1a_gpu_throttle_n_r;
assign  o_P1_MCIOP1C_GPU_THROTTLE_N_R   =   w_p1_mciop1c_gpu_throttle_n_r;
assign  o_P1_MCIOP2A_GPU_THROTTLE_N_R   =   w_p1_mciop2a_gpu_throttle_n_r;
assign  o_P1_MCIOP2C_GPU_THROTTLE_N_R   =   w_p1_mciop2c_gpu_throttle_n_r;
assign  o_P1_MCIOP3A_GPU_THROTTLE_N_R   =   w_p1_mciop3a_gpu_throttle_n_r;
assign  o_P1_MCIOP3C_GPU_THROTTLE_N_R   =   w_p1_mciop3c_gpu_throttle_n_r;
assign  o_P1_MCIOG1A_GPU_THROTTLE_N_R   =   w_p1_mciog1a_gpu_throttle_n_r;
assign  o_P1_MCIOG1C_GPU_THROTTLE_N_R   =   w_p1_mciog1c_gpu_throttle_n_r;


assign  o_P0_MCIOP0A_RSV_R  =   1'bz;
assign  o_P0_MCIOP0C_RSV_R  =   1'bz;
assign  o_P0_MCIOP1A_RSV_R  =   1'b1;
assign  o_P0_MCIOP1C_RSV_R  =   1'bz;
assign  o_P0_MCIOP2A_RSV_R  =   1'bz;
assign  o_P0_MCIOP2C_RSV_R  =   1'bz;
assign  o_P0_MCIOP3A_RSV_R  =   1'bz;
assign  o_P0_MCIOP3C_RSV_R  =   1'bz;
assign  o_P0_MCIOG3A_RSV_R  =   1'bz;
assign  o_P0_MCIOG3C_RSV_R  =   1'bz;

assign  o_P1_MCIOP0A_RSV_R  =   1'bz;
assign  o_P1_MCIOP0C_RSV_R  =   1'bz;
assign  o_P1_MCIOP1A_RSV_R  =   1'bz;
assign  o_P1_MCIOP1C_RSV_R  =   1'bz;
assign  o_P1_MCIOP2A_RSV_R  =   1'bz;
assign  o_P1_MCIOP2C_RSV_R  =   1'bz;
assign  o_P1_MCIOP3A_RSV_R  =   1'bz;
assign  o_P1_MCIOP3C_RSV_R  =   1'bz;
assign  o_P1_MCIOG1A_RSV_R  =   1'bz;
assign  o_P1_MCIOG1C_RSV_R  =   1'bz;

assign  o_SATA1_RSV  =   1'bz;
assign  o_CLK_DB2000_2_1_OE_N   =   w_clk_db2000_2_1_oe_n;
assign  o_CLK_DB2000_2_2_OE_N   =   w_clk_db2000_2_2_oe_n;
// assign  o_PDB_SPGIO_LD               =   1'bz;
// assign  o_PDB_SPGIO_DATAOUT     =   1'bz;
// assign  o_PDB_SPGIO_CLK             =   1'bz;
assign  o_RST_I2C1_MUX_N_R      = w_ctl_rst_i2c1_mux_n_r    ;
assign  o_RST_I2C2_MUX_N_R      = w_ctl_rst_i2c2_mux_n_r    ;
assign  o_RST_I2C3_MUX_N_R      = w_ctl_rst_i2c3_mux_n_r    ;
// assign  o_RST_I2C4_MUX_N_R      = w_ctl_rst_i2c4_mux_n_r     ;
// assign  o_RST_I2C7_MUX_N_R      = w_ctl_rst_i2c7_mux_n_r     ;
assign  o_PCIE_SATA_WAKE_R_N   =   1'bz;
// assign  o_PCIE_SATA_RST_N   =   w_p0_pcie_rst_n_0;
assign  o_SW_BIOS_FLASH_SPI_S_R    =    r_pal_bios_online_update_en;  
assign  o_SW_BIOS_SPI_OE                   =    1'b0;
assign  o_BIOS_FLASH_RESET_R_N      =   1'bz;
assign  o_SW_BIOS_QSPI_S_R    =    0;  
assign  o_SW_QSPI_OE_R    =    0;  
assign  o_PAL_SPI_BIOS_UPDATA_EN    =    r_pal_bios_online_update_en;  
// assign  o_SW_MB_TPM_OE                       =  1'b0;
// assign  o_PAL_PCIE_M2_0_PERST_N_R   =    w_p0_pcie_rst_n_0;
// assign  o_PAL_PCIE_M2_1_PERST_N_R   =    w_p0_pcie_rst_n_0;
// assign  o_PAL_NCSI_50M_REF_CLK_R  = r_PAL_NCSI_50M_REF_CLK_R   ;   
// assign  o_PAL_MB_SWITCH_EN_N_R       = r_pal_mb_switch_en_n_r        ;       
// assign  o_USB_SW_S_R                           =    w_usb_sw_s_r;
// assign  o_M_2_SATAPCIE_SEL_R           =    1'bz;

// assign  o_BMC_UART5_CPLD_TX             =   i_BMC_UART5_TX ;
// assign  o_BMC_UART5_RX                      =   i_BMC_UART5_CPLD_RX;
// assign  o_BMC_UART1_CPLD_TX             =   i_BMC_UART1_TX ;
// assign  o_BMC_UART1_RX                      =   i_BMC_UART1_CPLD_RX;
// assign  o_BMC_UART1_RX                      =   i_CPLD1_CPLD2_RSV2_R;
// assign  o_UART1_RXD_CPLD                =   1'bz;
// assign  o_BMC_UART1_CPLD_TX             =   i_CPLD1_CPLD2_RSV2_R ;
// assign  o_CPLD1_CPLD2_RSV1_R        =   i_BMC_UART1_CPLD_RX&i_BMC_UART1_TX;


// assign  o_PAL_USB_HUB2_RST_N_R          =    w_p0_pcie_rst_n_0;
// assign  o_PAL_USB_HUB2_VBUS_DET_R   =    w_p0_pcie_rst_n_0;
// assign  o_PAL_USB_HUB2_P3V3_EN_R    =   r_pal_usb_hub2_p3v3_en_r ;
assign  o_M2_GPIO6_R                            =   1'bz;
assign  o_M2_GPIO7_R                            =   1'bz;
// assign  o_CHASSIS_ID0_N =   1'bz;
// assign  o_PAL_PWR_LOM_EN_R  =   w_pal_pwr_lom_en_r;
assign  o_P0_SPI_TPM_CS_N_3V3   =   1'bz;
assign  o_P0_I2C5_9617_EN   =   1'b1;
assign  o_P12V_DISCHARGE_R  =   w_p12v_discharge_r;
assign  o_PAL_SPI1_BMC_HOLD =  1'bz;
assign  o_PAL_P12V_CPU1_DIMM_ON =  w_pal_p12v_cpu1_dimm_on;
assign  o_PAL_P12V_CPU0_DIMM_ON =  w_pal_p12v_cpu0_dimm_on;

//--------------------------------------------------------------------------------------------------------------------------------------------------
//I2C RAM  Start
//--------------------------------------------------------------------------------------------------------------------------------------------------
/************************************************************************************************************************************************************************/
bmc_cpld_i2c_ram #(
.DLY_LEN       (16)   //50MHz,330ns
)bmc_cpld_i2c_ram_u0
(
.i_rst_n		(pon_reset_n	),  
.i_clk			(clk_25m		),
.i_1ms_clk		(t1ms_tick		),	          
.i_rst_i2c_n	(1'b1			),		
.i_scl			(i_I2C2_PAL2_SCL	), 
.io_sda			(io_I2C2_PAL2_SDA	),

.i_product_id			                (`PRODUCT_ID	),	                        //addr 0x0000	
.i_vender_id			                (`VENDER_ID	        ),				//addr 0x0001
.i_board_id				                (8'h00   ),	        //addr 0x0002	
.i_pcb_version			                (8'h00   ),	        //addr 0x0003	
.i_bom_id				                (8'h00   ),	        //addr 0x0004
.i_cpld_version			                (`CPLD_VERSION	),				//addr 0x0005
.o_test_reg				                (		),                                 		//addr 0x0006
.i_year					                (`Year	),						//addr 0x0007
.i_month				                (`Month	),						//addr 0x0008
.i_day					                (`Day	),						//addr 0x0009
.i_nc_pin                               ({7'b0,w_nc_pin}),                            //addr 0x000a 
.i_cpld_compa_version	                (8'h00	),  					   	//addr 0x000b
.i_cpld_debug_version	                (`DEBUG_VERSION	),  				//addr 0x000c
//0x000d
.i_uid_btn_evt					(uid_button_short_evt), //addr 0x000d bit1 
.o_uid_btn_evt_clr				(w_uid_btn_evt_wc	  ), //addr 0x000d bit1 
.i_uid_rstbmc_evt				(uid_button_long_evt  ), //addr 0x000d bit0
.o_uid_rstbmc_evt_clr			(w_uid_rstbmc_evt_wc  ), //addr 0x000d bit0
//0x000e
.o_uid_led_ctl				        (w_uid_led_ctl  	          ),  //addr 0x000e
//0x000f
.i_intruder_cable_inst_r_n            (i_PCH_INTRUDER_CABLE_INST_R_N), //addr 0x000f bit7  

.i_pal_pch_intruder                          (i_PAL_PCH_INTRUDER                      ), //addr 0x000f bit4 
//rst_n -- 0x0010
.o_ctl_rst_i2c1_mux_n_r                  (w_ctl_rst_i2c1_mux_n_r  ),      //addr 0x0010 bit7 default 1
.o_ctl_rst_i2c2_mux_n_r                (w_ctl_rst_i2c2_mux_n_r),      //addr 0x0010 bit6 default 1
.o_ctl_rst_i2c3_mux_n_r                (w_ctl_rst_i2c3_mux_n_r),      //addr 0x0010 bit5 default 1

//--0x0011
.i_P0_MCIOP0A_NVME0_PRSNT_N_R       (i_P0_MCIOP0A_NVME0_PRSNT_N_R),//addr 0x0011 bit7
.i_P0_MCIOP0C_NVME0_PRSNT_N_R       (i_P0_MCIOP0C_NVME0_PRSNT_N_R),//addr 0x0011 bit6
//--0x0012
.i_P0_MCIOP1A_NVME0_PRSNT_N_R       (i_P0_MCIOP1A_NVME0_PRSNT_N_R),//addr 0x0011 bit7
.i_P0_MCIOP1C_NVME0_PRSNT_N_R       (i_P0_MCIOP1C_NVME0_PRSNT_N_R),//addr 0x0011 bit6
.i_P0_MCIOP2A_NVME0_PRSNT_N_R       (i_P0_MCIOP2A_NVME0_PRSNT_N_R),//addr 0x0011 bit5
.i_P0_MCIOP2C_NVME0_PRSNT_N_R       (i_P0_MCIOP2C_NVME0_PRSNT_N_R),//addr 0x0011 bit4
.i_P0_MCIOP3A_NVME0_PRSNT_N_R       (i_P0_MCIOP3A_NVME0_PRSNT_N_R),//addr 0x0011 bit3
.i_P0_MCIOP3C_NVME0_PRSNT_N_R       (i_P0_MCIOP3C_NVME0_PRSNT_N_R),//addr 0x0011 bit2
.i_P0_MCIOG3A_NVME0_PRSNT_N_R       (i_P0_MCIOG3A_NVME0_PRSNT_N_R),//addr 0x0011 bit1
.i_P0_MCIOG3C_NVME0_PRSNT_N_R       (i_P0_MCIOG3C_NVME0_PRSNT_N_R),//addr 0x0011 bit0
//0x0013
.i_P1_MCIOP0A_NVME0_PRSNT_N_R       (i_P1_MCIOP0A_NVME0_PRSNT_N_R),//addr 0x0012 bit7
.i_P1_MCIOP0C_NVME0_PRSNT_N_R       (i_P1_MCIOP0C_NVME0_PRSNT_N_R),//addr 0x0012 bit6
.i_P1_MCIOP1A_NVME0_PRSNT_N_R       (i_P1_MCIOP1A_NVME0_PRSNT_N_R),//addr 0x0012 bit5
.i_P1_MCIOP1C_NVME0_PRSNT_N_R       (i_P1_MCIOP1C_NVME0_PRSNT_N_R),//addr 0x0012 bit4
.i_P1_MCIOP2A_NVME0_PRSNT_N_R       (i_P1_MCIOP2A_NVME0_PRSNT_N_R),//addr 0x0012 bit3
.i_P1_MCIOP2C_NVME0_PRSNT_N_R       (i_P1_MCIOP2C_NVME0_PRSNT_N_R),//addr 0x0012 bit2
.i_P1_MCIOP3A_NVME0_PRSNT_N_R       (i_P1_MCIOP3A_NVME0_PRSNT_N_R),//addr 0x0012 bit1
.i_P1_MCIOP3C_NVME0_PRSNT_N_R       (i_P1_MCIOP3C_NVME0_PRSNT_N_R),//addr 0x0012 bit0
//0x0014
.i_P1_MCIOG1A_NVME0_PRSNT_N_R       (i_P1_MCIOG1A_NVME0_PRSNT_N_R),//addr 0x0013 bit7
.i_P1_MCIOG1C_NVME0_PRSNT_N_R       (i_P1_MCIOG1C_NVME0_PRSNT_N_R),//addr 0x0013 bit6
.i_P1_MCIOP4A_NVME0_PRSNT_N_R       (i_P1_MCIOP4A_NVME0_PRSNT_N_R),//addr 0x0013 bit5

//0x0015
.i_PAL_PE_WAKE_N                                         (i_PAL_PE_WAKE_N      )              , //addr 0x0015 bit7
.i_PAL_NODE1_TYPE                                        (w_PAL_NODE1_TYPE     )              , //addr 0x0015 bit6
.i_PWRGD_SYS_PWROK_R                                     (i_PWRGD_SYS_PWROK_R  )              , //addr 0x0015 bit5

//--0x0016
.i_P0_MCIOP0A_NVME1_PRSNT_N_R       (i_P0_MCIOP0A_NVME1_PRSNT_N_R),//addr 0x0017 bit1
.i_P0_MCIOP0C_NVME1_PRSNT_N_R       (i_P0_MCIOP0C_NVME1_PRSNT_N_R),//addr 0x0017 bit0
//--0x0017
.i_P0_MCIOP1A_NVME1_PRSNT_N_R       (i_P0_MCIOP1A_NVME1_PRSNT_N_R),//addr 0x0017 bit7
.i_P0_MCIOP1C_NVME1_PRSNT_N_R       (i_P0_MCIOP1C_NVME1_PRSNT_N_R),//addr 0x0017 bit6
.i_P0_MCIOP2A_NVME1_PRSNT_N_R       (i_P0_MCIOP2A_NVME1_PRSNT_N_R),//addr 0x0017 bit5
.i_P0_MCIOP2C_NVME1_PRSNT_N_R       (i_P0_MCIOP2C_NVME1_PRSNT_N_R),//addr 0x0017 bit4
.i_P0_MCIOP3A_NVME1_PRSNT_N_R       (i_P0_MCIOP3A_NVME1_PRSNT_N_R),//addr 0x0017 bit3
.i_P0_MCIOP3C_NVME1_PRSNT_N_R       (i_P0_MCIOP3C_NVME1_PRSNT_N_R),//addr 0x0017 bit2
.i_P0_MCIOG3A_NVME1_PRSNT_N_R       (i_P0_MCIOG3A_NVME1_PRSNT_N_R),//addr 0x0017 bit1
.i_P0_MCIOG3C_NVME1_PRSNT_N_R       (i_P0_MCIOG3C_NVME1_PRSNT_N_R),//addr 0x0017 bit0
//--0x0018
.i_P1_MCIOP0A_NVME1_PRSNT_N_R       (i_P1_MCIOP0A_NVME1_PRSNT_N_R),//addr 0x0018 bit7
.i_P1_MCIOP0C_NVME1_PRSNT_N_R       (i_P1_MCIOP0C_NVME1_PRSNT_N_R),//addr 0x0018 bit6
.i_P1_MCIOP1A_NVME1_PRSNT_N_R       (i_P1_MCIOP1A_NVME1_PRSNT_N_R),//addr 0x0018 bit5
.i_P1_MCIOP1C_NVME1_PRSNT_N_R       (i_P1_MCIOP1C_NVME1_PRSNT_N_R),//addr 0x0018 bit4
.i_P1_MCIOP2A_NVME1_PRSNT_N_R       (i_P1_MCIOP2A_NVME1_PRSNT_N_R),//addr 0x0018 bit3
.i_P1_MCIOP2C_NVME1_PRSNT_N_R       (i_P1_MCIOP2C_NVME1_PRSNT_N_R),//addr 0x0018 bit2
.i_P1_MCIOP3A_NVME1_PRSNT_N_R       (i_P1_MCIOP3A_NVME1_PRSNT_N_R),//addr 0x0018 bit1
.i_P1_MCIOP3C_NVME1_PRSNT_N_R       (i_P1_MCIOP3C_NVME1_PRSNT_N_R),//addr 0x0018 bit0
//--0x0019
.i_P1_MCIOG1A_NVME1_PRSNT_N_R       (i_P1_MCIOG1A_NVME1_PRSNT_N_R),//addr 0x0019 bit7
.i_P1_MCIOG1C_NVME1_PRSNT_N_R       (i_P1_MCIOG1C_NVME1_PRSNT_N_R),//addr 0x0019 bit6
//--0x0023
.i_PAL_P12V_CPU0_DIMM_OC                       (i_PAL_P12V_CPU0_DIMM_OC               )    , //addr 0x0023 bit7 default 0
.i_PAL_P12V_CPU1_DIMM_OC                       (i_PAL_P12V_CPU1_DIMM_OC               )    , //addr 0x0023 bit6 default 0
.i_PAL_P12V_CPU0_DIMM_GOK                      (i_PAL_P12V_CPU0_DIMM_GOK              )    , //addr 0x0023 bit5 default 1
.i_PAL_P12V_CPU1_DIMM_GOK                      (i_PAL_P12V_CPU1_DIMM_GOK              )    , //addr 0x0023 bit4 default 1
//--0x0024
.i_PAL_TMP1_ALERT_N                             (i_PAL_TMP1_ALERT_N                   ),//addr 0x0024   bit7
.i_PAL_TMP2_ALERT_N                             (i_PAL_TMP2_ALERT_N                   ),//addr 0x0024   bit6
.i_PAL_TMP3_ALERT_N                             (i_PAL_TMP3_ALERT_N                   ),//addr 0x0024   bit5
.i_PAL_TMP4_ALERT_N                             (i_PAL_TMP4_ALERT_N                   ),//addr 0x0024   bit4
.i_SMB_CPU0_ALERT_N_R                           (i_SMB_CPU0_ALERT_N_R                 ), //addr 0x0024   bit3

//0X0028
.o_nic_act_flag                                     (w_nic_act_flag               )    , //addr 0x0028 bit6 default 0
.o_sys_healthy_red                               (w_sys_healthy_red               )    , //addr 0x0028 bit5 default 0
.o_pal_mb_switch_en_n_r                         (w_pal_mb_switch_en_n_r           )    , //addr 0x0028 bit4 default 1
.o_pal_biosrom_io11                             (w_pal_biosrom_io11               )    , //addr 0x0028 bit1 default 1
.o_sys_healthy_grn                               (w_sys_healthy_grn               )    , //addr 0x0028 bit0 default 0


//--0x002b
.o_pal_p12v_cpu0_dimm_on                             (w_pal_p12v_cpu0_dimm_on             )    , //addr 0x002b   bit7   default 1
.o_pal_p12v_cpu1_dimm_on                             (w_pal_p12v_cpu1_dimm_on             )    , //addr 0x002b   bit6   default 1


//gpu_throttle -- 0x0025
.o_p0_mciop1a_gpu_throttle_n_r       (w_p0_mciop1a_gpu_throttle_n_r),    //addr 0x0030   bit7   default 1
.o_p0_mciop1c_gpu_throttle_n_r       (w_p0_mciop1c_gpu_throttle_n_r),    //addr 0x0030   bit6   default 1
.o_p0_mciop2a_gpu_throttle_n_r       (w_p0_mciop2a_gpu_throttle_n_r),    //addr 0x0030   bit5   default 1
.o_p0_mciop2c_gpu_throttle_n_r       (w_p0_mciop2c_gpu_throttle_n_r),    //addr 0x0030   bit4   default 1
.o_p0_mciop3a_gpu_throttle_n_r       (w_p0_mciop3a_gpu_throttle_n_r),    //addr 0x0030   bit3   default 1
.o_p0_mciop3c_gpu_throttle_n_r       (w_p0_mciop3c_gpu_throttle_n_r),    //addr 0x0030   bit2   default 1
.o_p0_mciog3a_gpu_throttle_n_r       (w_p0_mciog3a_gpu_throttle_n_r),    //addr 0x0030   bit1   default 1
.o_p0_mciog3c_gpu_throttle_n_r       (w_p0_mciog3c_gpu_throttle_n_r),    //addr 0x0030   bit0   default 1
//gpu_throttle -- 0x0026
.o_p1_mciop0a_gpu_throttle_n_r       (w_p1_mciop0a_gpu_throttle_n_r),    //addr 0x0031   bit7   default 1
.o_p1_mciop0c_gpu_throttle_n_r       (w_p1_mciop0c_gpu_throttle_n_r),    //addr 0x0031   bit6   default 1
.o_p1_mciop1a_gpu_throttle_n_r       (w_p1_mciop1a_gpu_throttle_n_r),    //addr 0x0031   bit5   default 1
.o_p1_mciop1c_gpu_throttle_n_r       (w_p1_mciop1c_gpu_throttle_n_r),    //addr 0x0031   bit4   default 1
.o_p1_mciop2a_gpu_throttle_n_r       (w_p1_mciop2a_gpu_throttle_n_r),    //addr 0x0031   bit3   default 1
.o_p1_mciop2c_gpu_throttle_n_r       (w_p1_mciop2c_gpu_throttle_n_r),    //addr 0x0031   bit2   default 1
.o_p1_mciop3a_gpu_throttle_n_r       (w_p1_mciop3a_gpu_throttle_n_r),    //addr 0x0031   bit1   default 1
.o_p1_mciop3c_gpu_throttle_n_r       (w_p1_mciop3c_gpu_throttle_n_r),    //addr 0x0031   bit0   default 1
//gpu_throttle -- 0x0027
.o_p1_mciog1a_gpu_throttle_n_r       (w_p1_mciog1a_gpu_throttle_n_r),    //addr 0x0032   bit7   default 1
.o_p1_mciog1c_gpu_throttle_n_r       (w_p1_mciog1c_gpu_throttle_n_r),    //addr 0x0032   bit6   default 1
.o_p0_mciop0a_gpu_throttle_n_r       (w_p0_mciop0a_gpu_throttle_n_r),    //addr 0x0030   bit1   default 1
.o_p0_mciop0c_gpu_throttle_n_r       (w_p0_mciop0c_gpu_throttle_n_r),    //addr 0x0030   bit0   default 1

//--0x002c
.o_clk_gen_intr_n_r                            (w_clk_gen_intr_n_r             )    , //addr 0x002b   bit7   default 1
.o_clk_gen_lol_n_r                             (w_clk_gen_lol_n_r             )    , //addr 0x002b   bit6   default 1
.o_clk_gen_finc_r                              (w_clk_gen_finc_r             )    , //addr 0x002b   bit5   default 1
.o_clk_gen_rst_n_r                             (w_clk_gen_rst_n_r             )    , //addr 0x002b   bit4   default 1
.o_clk_gen_oe_n_r                              (w_clk_gen_oe_nr_r             )    , //addr 0x002b   bit3   default 1
.o_clk_gen_fdec_r                              (w_clk_gen_fdec_r             )    , //addr 0x002b   bit2   default 1
.o_clk_i2c_sel_r                               (w_clk_i2c_sel_r             )    , //addr 0x002b   bit1   default 1


//0x0072
.o_sw_bios_flash_spi_s_r               (w_sw_bios_flash_spi_s_r     ) , //addr 0x0072 bit7   //default 0
.o_sw_bios_qspi_s_r                    (w_sw_bios_qspi_s_r          ) , //addr 0x0072 bit6   //default 0 
.o_sw_bios_spi_oe                      (w_sw_bios_spi_oe            ) , //addr 0x0072 bit5   //default 0
.o_sw_qspi_oe_r                        (w_sw_qspi_oe_r              ) , //addr 0x0072 bit4   //default 0 
.o_bios_flash_reset_r_n                (w_bios_flash_reset_r_n      ) , //addr 0x0072 bit3	 //default 1

// .o_164_mr_n                             (w_164_mr_n           )             ,  //addr 0x008a bit7   //default 1

// .o_164_test_data                        (w_164_test_data      )             ,  //addr 0x008c   //default 0x55

//0x008e
.i_LEAKAGE_PRSNT_N                            (i_LEAKAGE_PRSNT_N          ),    //addr 0x008e   bit6
.i_BREAK_DET_DO_N                                (i_BREAK_DET_DO_N              ),    //addr 0x008e   bit7
.i_LEAKAGE_DET_DO_N                            (i_LEAKAGE_DET_DO_N          ),    //addr 0x008e   bit5
.i_LEAKAGE_PRSNT1_N                            (i_LEAKAGE_PRSNT1_N          ),    //addr 0x008e   bit3
.i_BREAK_DET1_DO_N                              (i_BREAK_DET1_DO_N            ),    //addr 0x008e   bit4
.i_LEAKAGE_DET1_DO_N                          (i_LEAKAGE_DET1_DO_N        )      //addr 0x008e   bit2

);


endmodule



