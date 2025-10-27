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
  .RST       (~i_PAL2_PROGRAM_N   ), //in  
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
  .pgd_p3v3_stby		        (i_PAL2_PROGRAM_N	        ),	//in
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
.i2c1_scl	(io_I2C7_2_UPDATE_SCL	),
.i2c1_sda	(io_I2C7_2_UPDATE_SDA	)
); 
/************************************************************************************************************************************************************************/
//--------------------------------------------------------------------------------------------------------------------------------------------------
//I2C Update End
//--------------------------------------------------------------------------------------------------------------------------------------------------
/************************************************************************************************************************************************************************/
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
wire    w_ctl_rst_i2c10_mux_n_r    ;
wire    w_ctl_rst_i2c11_mux_n_r    ;
wire    w_ctl_rst_i2c4_mux_n_r     ;
wire    w_ctl_rst_i2c7_mux_n_r     ;
wire    w_usb_sw_s_r;

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
wire    w_P1_MCIOG1C_CB_ID1_R;
wire    w_P1_MCIOG1C_CB_ID0_R;
wire    w_P1_MCIOG1A_CB_ID1_R;
wire    w_P1_MCIOG1A_CB_ID0_R;
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
wire    w_P0_MCIOG3C_CB_ID1_R;
wire    w_P0_MCIOG3C_CB_ID0_R;
wire    w_P0_MCIOG3A_CB_ID1_R;
wire    w_P0_MCIOG3A_CB_ID0_R;
wire    w_p1_pcie_wake_n_r        ;
wire    w_p0_pcie_wake_n_r        ;
//
wire    w_p1_pcie_rst_n_1;
wire    w_p1_pcie_rst_n_0;
wire    w_p0_pcie_rst_n_1;
wire    w_p0_pcie_rst_n_0;
wire    w_p12v_discharge_r;
wire    w_uid_sw_in_n;
wire    w_ocp_prsnt_n;
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

//-------------------------------------------------------------------------------------------------
// for PSU Signal DEBOUNCE        8 Signal
// ------------------------------------------------------------------------------------------------
PGM_DEBOUNCE #(.SIGCNT(8), .NBITS(2'b10), .ENABLE(1'b1)) db_inst_psu (
  .clk(clk_50m),
  .rst(~pon_reset_n),
  .timer_tick(t64ms_tick),
  .din({
                 i_PS3_PRSNT                    ,   //1
                 i_PS3_DCOK_N                  ,   //2
                 i_PS3_SMB_ALERT            ,   //3
                 i_PS3_ACFAIL_N              ,   //4
                 i_PS4_PRSNT                    ,   //5
                 i_PS4_DCOK_N                  ,   //6
                 i_PS4_SMB_ALERT            ,   //7
                 i_PS4_ACFAIL_N                 //8

  }),
  .dout({
                 db_i_ps3_prsnt              ,   //1
                 db_i_ps3_dcok_n            ,   //2
                 db_i_ps3_smb_alert      ,   //3
                 db_i_ps3_acfail_n        ,   //4
                 db_i_ps4_prsnt              ,   //5
                 db_i_ps4_dcok_n            ,   //6
                 db_i_ps4_smb_alert      ,   //7
                 db_i_ps4_acfail_n           //8

  })
);
//--------------------------------------------------------------------------------------------------------------------------------------------------
// PWRGOOD DEBOUNCE
//--------------------------------------------------------------------------------------------------------------------------------------------------
PGM_DEBOUNCE_N #(.SIGCNT(2), .NBITS(2'b11), .ENABLE(1'b1)) db_inst_pwrgood (
  .clk			(clk_50m),
  .rst_n		(pon_reset_n),
  .timer_tick	(1'b1),
  .din({
                i_PAL_OCP1_PWRGD        ,//01
                i_PAL_OCP1_PGD              //02
	 }),             
  .dout({
                db_i_pal_ocp1_pwrgd        ,//01
                db_i_pal_ocp1_pgd              //02
	  }) 
);

PGM_DEBOUNCE #(.SIGCNT(1), .NBITS(2'b10), .ENABLE(1'b1)) db_inst_uid_btn(
  .clk(clk_50m),
  .rst(~pon_reset_n),
  .timer_tick(t32ms_tick),
  .din({
		i_UID_SW_IN_N &&w_uid_sw_in_n    //01

	   }),             
  .dout({
		db_i_uid_sw_in_n //01

       }) 
);

//-----------------------------------------------------------------------------------------------//
// SGPIO SN74LV165ADR DATA
//-----------------------------------------------------------------------------------------------//
//U259 DATA
wire    w_PCA_REVISION_2;
wire    w_U259_NC_B;
wire    w_TPM_MODULE_PRSNT_N;
wire    w_PAL_BP2_PRSNT_N;
wire    w_BOARD_ID2;
wire    w_BOARD_ID3;
wire    w_BOARD_ID0;
wire    w_BOARD_ID1;
//U260 DATA
wire    w_PAL_BP6_AUX_PG;
wire    w_PAL_BP1_PRSNT_N;
wire    w_PCA_REVISION_1;
wire    w_PCA_REVISION_0;
wire    w_PAL_BP4_PRSNT_N;
wire    w_PCB_REVISION_2;
wire    w_PAL_BP1_AUX_PG;
wire    w_PCB_REVISION_1;
//U261 DATA
wire    w_P1_MCIOP1A_CB_ID0_R;
wire    w_P1_MCIOP1C_CB_ID1_R;
wire    w_P1_MCIOP1C_CB_ID0_R;
wire    w_P1_MCIOP1A_CB_ID1_R;
wire    w_P1_MCIOP0A_CB_ID1_R;
wire    w_P1_MCIOP0C_CB_ID0_R;
wire    w_P1_MCIOP0C_CB_ID1_R;
wire    w_P1_MCIOP0A_CB_ID0_R;
//U264 DATA
wire    w_P1_MCIOP2C_CB_ID1_R;
wire    w_PG_P12V_SLOT_4;
wire    w_PG_P12V_SLOT_5;
wire    w_P1_MCIOP2A_CB_ID0_R;
wire    w_P1_MCIOP2A_CB_ID1_R;
wire    w_P1_MCIOP2C_CB_ID0_R;
wire    w_PAL_OCP1_PRSNT_B3_N;
wire    w_PG_P12V_SLOT_8;
//U160 DATA
wire    w_PAL_BP8_PRSNT_N;
wire    w_PAL_BP3_AUX_PG;
wire    w_PAL_BP5_AUX_PG;
wire    w_PAL_BP8_AUX_PG;
wire    w_PG_P12V_SLOT_2;
wire    w_U160_NC_F;
wire    w_OCP1_CB_ID0_R;
wire    w_OCP1_CB_ID1_R;
//U161 DATA
wire    w_FAN_PRSNT_INTR;
wire    w_PAL_BP3_PRSNT_N;
wire    w_PAL_BP5_PRSNT_N;
wire    w_FAN_PWR_PG;
wire    w_PAL_BP2_AUX_PG;
wire    w_PCB_REVISION_0;
wire    w_PG_P12V_SLOT_0;
wire    w_PG_P12V_SLOT_1;

wire [5:0]pvti_ss_count;

pvt_gpi #(
  .TOTAL_BIT_COUNT(48),
  .DEFAULT_STATE(48'h0),
  .NUMBER_OF_COUNTER_BITS(6)
) pvt_gpi_MB_inst (
  .clk           (clk_50m),          //in
  .reset_n       (pon_reset_n),      //in
  .clk_ena       (t16us_tick),       //in
  .serclk_in     (o_PVT2_SS_CLK_R),   //in
  .par_load_in_n (o_PVT2_SS_LD_N_R),  //in
  .sdi           (i_PVT2_SS_DATI  ),  //in
  .bit_idx_in    (pvti_ss_count),    //in
  .bit_idx_out   (pvti_ss_count),    //out
  .serclk_out    (o_PVT2_SS_CLK_R ),  //out
  .par_load_out_n(o_PVT2_SS_LD_N_R),  //out

  .par_data      ({w_PCA_REVISION_2,w_U259_NC_B,w_TPM_MODULE_PRSNT_N,w_PAL_BP2_PRSNT_N,  
                              w_BOARD_ID2,w_BOARD_ID3,w_BOARD_ID0,w_BOARD_ID1,                                          //U259_DATA
                              
                              w_PAL_BP6_AUX_PG,w_PAL_BP1_PRSNT_N,w_PCA_REVISION_1,w_PCA_REVISION_0,
                              w_PAL_BP4_PRSNT_N,w_PCB_REVISION_2,w_PAL_BP1_AUX_PG,w_PCB_REVISION_1,//U260_DATA
                              
                              w_P1_MCIOP1A_CB_ID0_R,w_P1_MCIOP1C_CB_ID1_R,w_P1_MCIOP1C_CB_ID0_R,w_P1_MCIOP1A_CB_ID1_R,
                              w_P1_MCIOP0A_CB_ID1_R,w_P1_MCIOP0C_CB_ID0_R,w_P1_MCIOP0C_CB_ID1_R,w_P1_MCIOP0A_CB_ID0_R,//U261_DATA
                              
                              w_P1_MCIOP2C_CB_ID1_R,w_PG_P12V_SLOT_4,w_PG_P12V_SLOT_5,w_P1_MCIOP2A_CB_ID0_R,
                              w_P1_MCIOP2A_CB_ID1_R,w_P1_MCIOP2C_CB_ID0_R,w_PAL_OCP1_PRSNT_B3_N,w_PG_P12V_SLOT_8,//U264_DATA
                              
                              w_PAL_BP8_PRSNT_N,w_PAL_BP3_AUX_PG,w_PAL_BP5_AUX_PG,w_PAL_BP8_AUX_PG,
                              w_PG_P12V_SLOT_2,w_U160_NC_F,w_OCP1_CB_ID0_R,w_OCP1_CB_ID1_R,                     //U160_DATA
                              
                              w_FAN_PRSNT_INTR,w_PAL_BP3_PRSNT_N,w_PAL_BP5_PRSNT_N,w_FAN_PWR_PG,
                              w_PAL_BP2_AUX_PG,w_PCB_REVISION_0,w_PG_P12V_SLOT_0,w_PG_P12V_SLOT_1           //U161_DATA

                              })
);

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
assign  scpld_to_mcpld_p2s_data[173]        = ~i_LEAKAGE0_PRSNT_N   ;
assign  scpld_to_mcpld_p2s_data[172]        = ~i_LEAKAGE_DET_DO_N   ;
assign  scpld_to_mcpld_p2s_data[171]        = ~i_BREAK_DET1_DO_N     ;
assign  scpld_to_mcpld_p2s_data[170]        = ~i_LEAKAGE_PRSNT1_N   ;
assign  scpld_to_mcpld_p2s_data[169]        = ~i_LEAKAGE_DET1_DO_N ;

assign  scpld_to_mcpld_p2s_data[168]        = w_PAL_OCP1_PRSNT_B3_N    ;
assign  scpld_to_mcpld_p2s_data[167]        = db_i_uid_sw_in_n    ;
assign  scpld_to_mcpld_p2s_data[166]        = w_PAL_BP1_PRSNT_N ;
assign  scpld_to_mcpld_p2s_data[165]        = w_PAL_BP2_PRSNT_N ;
assign  scpld_to_mcpld_p2s_data[164]        = w_PAL_BP3_PRSNT_N ;
assign  scpld_to_mcpld_p2s_data[163]        = w_PAL_BP4_PRSNT_N ;
assign  scpld_to_mcpld_p2s_data[162]        = w_PAL_BP5_PRSNT_N ;
assign  scpld_to_mcpld_p2s_data[161]        = w_PAL_BP8_PRSNT_N ;

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

assign  scpld_to_mcpld_p2s_data[12]        = i_USB2_LCD_OC_N;
assign  scpld_to_mcpld_p2s_data[11]        = i_USB_INNER_OVERCUR3;
assign  scpld_to_mcpld_p2s_data[10]        = w_bmc_extrst_uid;
assign  scpld_to_mcpld_p2s_data[9]          = w_p1_pcie_wake_n_r        ;
assign  scpld_to_mcpld_p2s_data[8]          = w_p0_pcie_wake_n_r        ;
assign  scpld_to_mcpld_p2s_data[7]          = w_PWRGD_P12V_PS3_PS4        ;
assign  scpld_to_mcpld_p2s_data[6]          = w_PS3_PS4_ACFAIL        ;
assign  scpld_to_mcpld_p2s_data[5]          = db_i_ps4_prsnt        ;
assign  scpld_to_mcpld_p2s_data[4]          = db_i_ps3_prsnt        ;

assign  scpld_to_mcpld_p2s_data[3]          = 1'b0                                ;
assign  scpld_to_mcpld_p2s_data[2]          = 1'b1                                ;
assign  scpld_to_mcpld_p2s_data[1]          = 1'b0                                ;
assign  scpld_to_mcpld_p2s_data[0]          = 1'b1                                ;


//mcpld ---> scpld

wire    w_SW_2;

assign  w_SW_2             = mcpld_to_scpld_data_filter[51]            ;

assign  w_P1_MCIOP3C_CB_ID1_R             = mcpld_to_scpld_data_filter[50]            ;
assign  w_P1_MCIOP3C_CB_ID0_R             = mcpld_to_scpld_data_filter[49]            ;
assign  w_P1_MCIOP3A_CB_ID1_R             = mcpld_to_scpld_data_filter[48]            ;
assign  w_P1_MCIOP3A_CB_ID0_R             = mcpld_to_scpld_data_filter[47]            ;

assign  w_P1_MCIOG1C_CB_ID1_R             = mcpld_to_scpld_data_filter[46]            ;
assign  w_P1_MCIOG1C_CB_ID0_R             = mcpld_to_scpld_data_filter[45]            ;
assign  w_P1_MCIOG1A_CB_ID1_R             = mcpld_to_scpld_data_filter[44]            ;
assign  w_P1_MCIOG1A_CB_ID0_R             = mcpld_to_scpld_data_filter[43]            ;

assign  w_P0_MCIOP3C_CB_ID1_R             = mcpld_to_scpld_data_filter[42]            ;
assign  w_P0_MCIOP3C_CB_ID0_R             = mcpld_to_scpld_data_filter[41]            ;
assign  w_P0_MCIOP3A_CB_ID1_R             = mcpld_to_scpld_data_filter[40]            ;
assign  w_P0_MCIOP3A_CB_ID0_R             = mcpld_to_scpld_data_filter[39]            ;

assign  w_P0_MCIOP2C_CB_ID1_R             = mcpld_to_scpld_data_filter[38]            ;
assign  w_P0_MCIOP2C_CB_ID0_R             = mcpld_to_scpld_data_filter[37]            ;
assign  w_P0_MCIOP2A_CB_ID1_R             = mcpld_to_scpld_data_filter[36]            ;
assign  w_P0_MCIOP2A_CB_ID0_R             = mcpld_to_scpld_data_filter[35]            ;

assign  w_P0_MCIOP1C_CB_ID1_R             = mcpld_to_scpld_data_filter[34]            ;
assign  w_P0_MCIOP1C_CB_ID0_R             = mcpld_to_scpld_data_filter[33]            ;
assign  w_P0_MCIOP1A_CB_ID1_R             = mcpld_to_scpld_data_filter[32]            ;
assign  w_P0_MCIOP1A_CB_ID0_R             = mcpld_to_scpld_data_filter[31]            ;

assign  w_P0_MCIOG3C_CB_ID1_R             = mcpld_to_scpld_data_filter[30]            ;
assign  w_P0_MCIOG3C_CB_ID0_R             = mcpld_to_scpld_data_filter[29]            ;
assign  w_P0_MCIOG3A_CB_ID1_R             = mcpld_to_scpld_data_filter[28]            ;
assign  w_P0_MCIOG3A_CB_ID0_R             = mcpld_to_scpld_data_filter[27]            ;

assign  w_led_control[7]                       = mcpld_to_scpld_data_filter[26]       ;
assign  w_led_control[6]                       = mcpld_to_scpld_data_filter[25]       ;
assign  w_led_control[5]                       = mcpld_to_scpld_data_filter[24]       ;
assign  w_led_control[4]                       = mcpld_to_scpld_data_filter[23]       ;
assign  w_led_control[3]                       = mcpld_to_scpld_data_filter[22]       ;
assign  w_led_control[2]                       = mcpld_to_scpld_data_filter[21]       ;
assign  w_led_control[1]                       = mcpld_to_scpld_data_filter[20]       ;
assign  w_led_control[0]                       = mcpld_to_scpld_data_filter[19]       ;

assign  w_usb_sw_s_r                               = mcpld_to_scpld_data_filter[18]       ;
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
//-------------------------------------------------------------------------------------------------
always@(posedge clk_50m or negedge pon_reset_n)
	begin
		if(~pon_reset_n)
			begin
				mcpld_to_scpld_data_filter <= {192{1'b0}};
				mb_sgpio_fail <= 1'b0; 
			end
		else if
			((mcpld_to_scpld_s2p_data[3:0] == 4'b0101)&& (mcpld_to_scpld_s2p_data[199:196] == 4'b1010))
			begin
				mcpld_to_scpld_data_filter <= mcpld_to_scpld_s2p_data[195:4];
				mb_sgpio_fail <= 1'b0;
			end
		else
			begin
				mcpld_to_scpld_data_filter <= mcpld_to_scpld_data_filter;
				mb_sgpio_fail <= 1'b1;
			end
end

//M CPLD ---> S CPLD
s2p_slave #(.NBIT(200)) inst_mb_to_slv_s2p(
	.clk(clk_50m                  ),
	.rst(~pon_reset_n             ),
	.si(i_CPLD_SGPIO0_MOSI	          ),//SGPIO_MOSI Serial Signal input
	.po(mcpld_to_scpld_s2p_data),//Parallel Signal output
	.sld_n(i_CPLD_SGPIO0_LD_N	  ),//SGPIO_LOAD
	.sclk(i_CPLD_SGPIO0_CLK		  ) //SGPIO_CLK
);

// S CPLD ---> M CPLD
p2s_slave #(.NBIT(200)) inst_slv_to_mb_p2s(
	.clk(clk_50m					),
	.rst(~pon_reset_n				),
	.pi(scpld_to_mcpld_p2s_data	),//Parallel Signal input
	.so(o_CPLD_SGPIO0_MISO				),//SGPIO_MISO Serial Signal output
	.sld_n(i_CPLD_SGPIO0_LD_N   	),//SGPIO_LOAD
	.sclk(i_CPLD_SGPIO0_CLK			) //SGPIO_CLK
);
//-----------------------------------------------------------------------------------------------//
//M_CPLD <---> S_CPLD SGPIO END
//-----------------------------------------------------------------------------------------------//
//------------------------------------------------------------------------------------------------
//aux//2024-3-25 add
wire    [15:0]    w_mb_to_bp_aux1_data;
wire    [15:0]    w_mb_to_bp_aux2_data;
wire    [15:0]    w_mb_to_bp_aux3_data;
wire    [15:0]    w_mb_to_bp_aux4_data;
wire    [15:0]    w_mb_to_bp_aux5_data;
wire    [15:0]    w_mb_to_bp_aux6_data;
wire    [15:0]    w_mb_to_bp_aux7_data;

wire    [15:0]    w_bp_to_mb_aux1_data;
wire    [15:0]    w_bp_to_mb_aux2_data;
wire    [15:0]    w_bp_to_mb_aux3_data;
wire    [15:0]    w_bp_to_mb_aux4_data;
wire    [15:0]    w_bp_to_mb_aux5_data;
wire    [15:0]    w_bp_to_mb_aux6_data;
wire    [15:0]    w_bp_to_mb_aux7_data;

wire    [7:0]   w_espi_ram_1055;
wire    [7:0]   w_espi_ram_1056;
wire    [7:0]   w_espi_ram_1057;
wire    [7:0]   w_espi_ram_1058;

//bit[7:6] rsv bit5:locate en bit[4:1]:locate bit0:pwr en
wire    [5:0]   w_aux_rsvd_bit15_10;
wire    [1:0]   w_mb_type;//mb_type 00:ICX  01:EGS  10:EGS 4U   11:ICX 4U
wire    [3:0]   w_aux_rsvd_bit7_4;
wire    [2:0]   w_aux_num_aux1;
wire    [2:0]   w_aux_num_aux2;
wire    [2:0]   w_aux_num_aux3;
wire    [2:0]   w_aux_num_aux4;
wire    [2:0]   w_aux_num_aux5;
wire    [2:0]   w_aux_num_aux6;
wire    [2:0]   w_aux_num_aux7;

wire    w_pal_bp8_pwr_on_r;
wire    w_pal_bp2_pwr_on_r;
wire    w_pal_bp1_pwr_on_r;
wire    w_pal_bp4_pwr_on_r;
wire    w_pal_bp5_pwr_on_r;
wire    w_pal_bp6_pwr_on_r;
wire    w_pal_bp3_pwr_on_r;

assign  w_aux_rsvd_bit15_10     =   6'b0;
assign  w_mb_type     =   2'b01;
assign  w_aux_rsvd_bit7_4     =   4'b0;
assign  w_aux_num_aux1     =   3'b001;
assign  w_aux_num_aux2     =   3'b010;
assign  w_aux_num_aux3     =   3'b011;
assign  w_aux_num_aux4     =   3'b100;
assign  w_aux_num_aux5     =   3'b101;
assign  w_aux_num_aux6     =   3'b110;
assign  w_aux_num_aux7     =   3'b111;

assign  w_pal_bp1_pwr_on_r  =   w_PWRGD_P12V&& ~w_PAL_BP1_PRSNT_N && w_P0_SLP_S5_N ;
assign  w_pal_bp2_pwr_on_r  =   w_PWRGD_P12V&& ~w_PAL_BP2_PRSNT_N && w_P0_SLP_S5_N ;
assign  w_pal_bp3_pwr_on_r  =   w_PWRGD_P12V&& ~w_PAL_BP3_PRSNT_N && w_P0_SLP_S5_N ;
assign  w_pal_bp4_pwr_on_r  =   w_PWRGD_P12V&& ~w_PAL_BP4_PRSNT_N && w_P0_SLP_S5_N ;
// assign  w_pal_bp5_pwr_on_r  =   w_PWRGD_P12V&& ~w_PAL_BP5_PRSNT_N && w_P0_SLP_S5_N ;
assign  w_pal_bp5_pwr_on_r  =   (~w_ocp_prsnt_n || w_P0_SLP_S5_N) && ~w_PAL_BP5_PRSNT_N ? 1'b1 : 1'b0 ; 
assign  w_pal_bp6_pwr_on_r  =   w_PWRGD_P12V&& ~w_PAL_BP6_PRSNT_N && w_P0_SLP_S5_N ;
assign  w_pal_bp8_pwr_on_r  =   w_PWRGD_P12V&& ~w_PAL_BP8_PRSNT_N && w_P0_SLP_S5_N ;

assign  w_mb_to_bp_aux1_data   =   {w_aux_rsvd_bit15_10,w_mb_type,w_aux_rsvd_bit7_4,w_aux_num_aux1,w_pal_bp8_pwr_on_r};
assign  w_mb_to_bp_aux2_data   =   {w_aux_rsvd_bit15_10,w_mb_type,w_aux_rsvd_bit7_4,w_aux_num_aux2,w_pal_bp2_pwr_on_r};
assign  w_mb_to_bp_aux3_data   =   {w_aux_rsvd_bit15_10,w_mb_type,w_aux_rsvd_bit7_4,w_aux_num_aux3,w_pal_bp1_pwr_on_r};
assign  w_mb_to_bp_aux4_data   =   {w_aux_rsvd_bit15_10,w_mb_type,w_aux_rsvd_bit7_4,w_aux_num_aux4,w_pal_bp4_pwr_on_r};
assign  w_mb_to_bp_aux5_data   =   {w_aux_rsvd_bit15_10,w_mb_type,w_aux_rsvd_bit7_4,w_aux_num_aux5,w_pal_bp5_pwr_on_r};
assign  w_mb_to_bp_aux6_data   =   {w_aux_rsvd_bit15_10,w_mb_type,w_aux_rsvd_bit7_4,w_aux_num_aux6,w_pal_bp6_pwr_on_r};
assign  w_mb_to_bp_aux7_data   =   {w_aux_rsvd_bit15_10,w_mb_type,w_aux_rsvd_bit7_4,w_aux_num_aux7,w_pal_bp3_pwr_on_r};

assign  w_espi_ram_1055 =   8'hff;
assign  w_espi_ram_1056 =   8'hff;
assign  w_espi_ram_1057 =   8'hff;
assign  w_espi_ram_1058 =   8'hff;

assign  w_bf_type   =   (w_bp_to_mb_aux5_data[7:0]==8'h1e)?2'b10:2'b00;
//--------------------------------------------------------------------------------------------------------------------------------------------------
//AUX1  J192    Board_ID
// -------------------------------------------------------------------------------------------------------------------------------------------------
AUX_UART_MASTER #(.NBIT_IN(16), .NBIT_OUT(16), .BPS_COUNT_NUM(48), .START_COUNT_NUM(24)) aux_uart_master_u1 (
	.clk             (clk_50m)  ,                //input
	.rst             (~pon_reset_n)  ,           //input
	.tick            (t16us_tick)  ,             //input
        .t128ms_tick     (t128ms_tick)  ,            //input
//Physical Pin        
        .ser_data        (  io_PAL_BP8_PWR_ON_R  )  ,    //inout//2024-4-7 del o_PAL_BP8_CPU_IP2P//2024-4-17 del io_PAL_BP8_AUX_PG
//Physical Data
	.par_data_in     (w_mb_to_bp_aux1_data)  ,    //input 
	.par_data_out    (w_bp_to_mb_aux1_data)  ,                       //output
	.send_enable     (1'b1)  ,                   //input
        .pass_through    (w_pal_bp8_pwr_on_r)  ,    //input

	.error_flag      ()                          //output
);

//--------------------------------------------------------------------------------------------------------------------------------------------------
//AUX2  J144    Board_ID
// -------------------------------------------------------------------------------------------------------------------------------------------------
AUX_UART_MASTER #(.NBIT_IN(16), .NBIT_OUT(16), .BPS_COUNT_NUM(48), .START_COUNT_NUM(24)) aux_uart_master_u2 (
	.clk             (clk_50m)  ,                //input
	.rst             (~pon_reset_n)  ,           //input
	.tick            (t16us_tick)  ,             //input
        .t128ms_tick     (t128ms_tick)  ,            //input
//Physical Pin        
        .ser_data        (  io_PAL_BP2_PWR_ON_R  )  ,    //inout//2024-4-7 del o_PAL_BP8_CPU_IP2P//2024-4-17 del io_PAL_BP8_AUX_PG
//Physical Data
	.par_data_in      (w_mb_to_bp_aux2_data)  ,    //input 
	.par_data_out    (w_bp_to_mb_aux2_data)  ,                       //output
	.send_enable     (1'b1)  ,                   //input
        .pass_through    (w_pal_bp2_pwr_on_r)  ,    //input

	.error_flag      ()                          //output
);

//--------------------------------------------------------------------------------------------------------------------------------------------------
//AUX3  J143    Board_ID
// -------------------------------------------------------------------------------------------------------------------------------------------------
AUX_UART_MASTER #(.NBIT_IN(16), .NBIT_OUT(16), .BPS_COUNT_NUM(48), .START_COUNT_NUM(24)) aux_uart_master_u3 (
	.clk             (clk_50m)  ,                //input
	.rst             (~pon_reset_n)  ,           //input
	.tick            (t16us_tick)  ,             //input
        .t128ms_tick     (t128ms_tick)  ,            //input
//Physical Pin         
	.ser_data        (  io_PAL_BP1_PWR_ON_R  )  ,    //inout//2024-4-7 del o_PAL_BP1_CPU_IP2P//2024-4-17 del io_PAL_BP1_AUX_PG
//Physical Data
	.par_data_in     (w_mb_to_bp_aux3_data)  ,    //input 
	.par_data_out    (w_bp_to_mb_aux3_data)  ,                       //output
	.send_enable     (1'b1)  ,                   //input
        .pass_through    (w_pal_bp1_pwr_on_r)  ,    //input

	.error_flag      ()                          //output
);
//--------------------------------------------------------------------------------------------------------------------------------------------------
//AUX4  JA703    Board_ID
// -------------------------------------------------------------------------------------------------------------------------------------------------
AUX_UART_MASTER #(.NBIT_IN(16), .NBIT_OUT(16), .BPS_COUNT_NUM(48), .START_COUNT_NUM(24)) aux_uart_master_u4 (
	.clk             (clk_50m)  ,                //input
	.rst             (~pon_reset_n)  ,           //input
	.tick            (t16us_tick)  ,             //input
        .t128ms_tick     (t128ms_tick)  ,            //input
//Physical Pin
	.ser_data        (  io_PAL_BP4_PWR_ON_R  )  ,    //inout//2024-4-7 del o_PAL_BP4_CPU_IP2P//2024-4-17 del io_PAL_BP4_AUX_PG
//Physical Data
	.par_data_in     (w_mb_to_bp_aux4_data)  ,    //input 
	.par_data_out    (w_bp_to_mb_aux4_data)  ,                       //output
	.send_enable     (1'b1)  ,                   //input
        .pass_through    (w_pal_bp4_pwr_on_r)  ,    //input

	.error_flag      ()                          //output
);
//--------------------------------------------------------------------------------------------------------------------------------------------------
//AUX5  JA702    Board_ID
// -------------------------------------------------------------------------------------------------------------------------------------------------
AUX_UART_MASTER #(.NBIT_IN(16), .NBIT_OUT(16), .BPS_COUNT_NUM(48), .START_COUNT_NUM(24)) aux_uart_master_u5 (
	.clk             (clk_50m)  ,                //input
	.rst             (~pon_reset_n)  ,           //input
	.tick            (t16us_tick)  ,             //input
        .t128ms_tick     (t128ms_tick)  ,            //input
//Physical Pin
	.ser_data        (  io_PAL_BP5_PWR_ON_R  )  ,    //inout//2024-4-7 del o_PAL_BP5_CPU_IP2P//2024-4-17 del io_PAL_BP5_AUX_PG
//Physical Data
	.par_data_in     (w_mb_to_bp_aux5_data)  ,    //input 
	.par_data_out    (w_bp_to_mb_aux5_data)  ,                       //output
	.send_enable     (1'b1)  ,                   //input
        .pass_through    (w_pal_bp5_pwr_on_r)  ,    //input

	.error_flag      ()                          //output
);
//--------------------------------------------------------------------------------------------------------------------------------------------------
//AUX6  JA601    Board_ID
// -------------------------------------------------------------------------------------------------------------------------------------------------
AUX_UART_MASTER #(.NBIT_IN(16), .NBIT_OUT(16), .BPS_COUNT_NUM(48), .START_COUNT_NUM(24)) aux_uart_master_u6 (
	.clk             (clk_50m)  ,                //input
	.rst             (~pon_reset_n)  ,           //input
	.tick            (t16us_tick)  ,             //input
        .t128ms_tick     (t128ms_tick)  ,            //input
//Physical Pin
	.ser_data        (  io_PAL_BP6_PWR_ON_R  )  ,    //inout//2024-4-7 del o_PAL_BP6_CPU_IP2P//2024-4-17 del io_PAL_BP6_AUX_PG
//Physical Data
	.par_data_in     (w_mb_to_bp_aux6_data)  ,    //input 
	.par_data_out    (w_bp_to_mb_aux6_data)  ,                       //output
	.send_enable     (1'b1)  ,                   //input
        .pass_through    (w_pal_bp6_pwr_on_r)  ,    //input

	.error_flag      ()                          //output
);
//--------------------------------------------------------------------------------------------------------------------------------------------------
//AUX7  JA602    Board_ID
// -------------------------------------------------------------------------------------------------------------------------------------------------
AUX_UART_MASTER #(.NBIT_IN(16), .NBIT_OUT(16), .BPS_COUNT_NUM(48), .START_COUNT_NUM(24)) aux_uart_master_u7 (
	.clk             (clk_50m)  ,                //input
	.rst             (~pon_reset_n)  ,           //input
	.tick            (t16us_tick)  ,             //input
        .t128ms_tick     (t128ms_tick)  ,            //input
//Physical Pin
	.ser_data        (  io_PAL_BP3_PWR_ON_R  )  ,    //inout
//Physical Data
	.par_data_in     (w_mb_to_bp_aux7_data)  ,    //input 
	.par_data_out    (w_bp_to_mb_aux7_data)  ,                       //output
	.send_enable     (1'b1)  ,                   //input
        .pass_through    (w_pal_bp3_pwr_on_r)  ,    //input

	.error_flag      ()                          //output
);


//MCIO
wire    [15:0]    w_mb_to_bp_mciop0p1a_data;//0
wire    [15:0]    w_mb_to_bp_mciop0p1c_data;//1
wire    [15:0]    w_mb_to_bp_mciop0p2a_data;//2
wire    [15:0]    w_mb_to_bp_mciop0p2c_data;//3
wire    [15:0]    w_mb_to_bp_mciop0p3a_data;//4
wire    [15:0]    w_mb_to_bp_mciop0p3c_data;//5
wire    [15:0]    w_mb_to_bp_mciop0g3a_data;//6
wire    [15:0]    w_mb_to_bp_mciop0g3c_data;//7
wire    [15:0]    w_mb_to_bp_mciop1g1a_data;//8
wire    [15:0]    w_mb_to_bp_mciop1g1c_data;//9
wire    [15:0]    w_mb_to_bp_mciop1p0a_data;//10
wire    [15:0]    w_mb_to_bp_mciop1p0c_data;//11
wire    [15:0]    w_mb_to_bp_mciop1p1a_data;//12
wire    [15:0]    w_mb_to_bp_mciop1p1c_data;//13
wire    [15:0]    w_mb_to_bp_mciop1p2a_data;//14
wire    [15:0]    w_mb_to_bp_mciop1p2c_data;//15
wire    [15:0]    w_mb_to_bp_mciop1p3a_data;//16
wire    [15:0]    w_mb_to_bp_mciop1p3c_data;//17

wire    [15:0]    w_bp_to_mb_mciop0p1a_data;//0
wire    [15:0]    w_bp_to_mb_mciop0p1c_data;//1
wire    [15:0]    w_bp_to_mb_mciop0p2a_data;//2
wire    [15:0]    w_bp_to_mb_mciop0p2c_data;//3
wire    [15:0]    w_bp_to_mb_mciop0p3a_data;//4
wire    [15:0]    w_bp_to_mb_mciop0p3c_data;//5
wire    [15:0]    w_bp_to_mb_mciop0g3a_data;//6
wire    [15:0]    w_bp_to_mb_mciop0g3c_data;//7
wire    [15:0]    w_bp_to_mb_mciop1g1a_data;//8
wire    [15:0]    w_bp_to_mb_mciop1g1c_data;//9
wire    [15:0]    w_bp_to_mb_mciop1p0a_data;//10
wire    [15:0]    w_bp_to_mb_mciop1p0c_data;//11
wire    [15:0]    w_bp_to_mb_mciop1p1a_data;//12
wire    [15:0]    w_bp_to_mb_mciop1p1c_data;//13
wire    [15:0]    w_bp_to_mb_mciop1p2a_data;//14
wire    [15:0]    w_bp_to_mb_mciop1p2c_data;//15
wire    [15:0]    w_bp_to_mb_mciop1p3a_data;//16
wire    [15:0]    w_bp_to_mb_mciop1p3c_data;//17


wire    w_pal_p0_mciop1a_pwr_en;//0
wire    w_pal_p0_mciop1c_pwr_en;//1
wire    w_pal_p0_mciop2a_pwr_en;//2
wire    w_pal_p0_mciop2c_pwr_en;//3
wire    w_pal_p0_mciop3a_pwr_en;//4
wire    w_pal_p0_mciop3c_pwr_en;//5
wire    w_pal_p0_mciog3a_pwr_en;//6
wire    w_pal_p0_mciog3c_pwr_en;//7
wire    w_pal_p1_mciog1a_pwr_en;//8
wire    w_pal_p1_mciog1c_pwr_en;//9
wire    w_pal_p1_mciop0a_pwr_en;//10
wire    w_pal_p1_mciop0c_pwr_en;//11
wire    w_pal_p1_mciop1a_pwr_en;//12
wire    w_pal_p1_mciop1c_pwr_en;//13
wire    w_pal_p1_mciop2a_pwr_en;//14
wire    w_pal_p1_mciop2c_pwr_en;//15
wire    w_pal_p1_mciop3a_pwr_en;//16
wire    w_pal_p1_mciop3c_pwr_en;//17

wire    [5:0]   w_mcio_rsvd_bit15_10;
wire    [1:0]   w_mcio_rsvd_bit9_8;
wire    [2:0]   w_mcio_rsvd_bit7_5;
wire    [3:0]   w_mcio_vpp_addr_bit4_1;

assign  w_mcio_rsvd_bit15_10       =    6'b0;
assign  w_mcio_rsvd_bit9_8          =    2'b11;
assign  w_mcio_rsvd_bit7_5           =    3'b100;
assign  w_mcio_vpp_addr_bit4_1  =   4'b0000;

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
         .riser_en_out     (w_pal_p0_mciop1a_pwr_en    )  , //input
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
         .riser_en_out     (w_pal_p0_mciop1c_pwr_en    )  , //input
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
         .riser_en_out     (w_pal_p0_mciop2a_pwr_en    )  , //input
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
         .riser_en_out     (w_pal_p0_mciop2c_pwr_en    )  , //input
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
         .riser_en_out     (w_pal_p0_mciop3a_pwr_en    )  , //input
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
         .riser_en_out     (w_pal_p0_mciop3c_pwr_en    )  , //input
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
         .riser_en_out     (w_pal_p0_mciog3a_pwr_en    )  , //input
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
         .riser_en_out     (w_pal_p0_mciog3c_pwr_en    )  , //input
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
         .riser_en_out     (w_pal_p1_mciog1a_pwr_en    )  , //input
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
         .riser_en_out     (w_pal_p1_mciog1c_pwr_en    )  , //input
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
         .riser_en_out     (w_pal_p1_mciop0a_pwr_en    )  , //input
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
         .riser_en_out     (w_pal_p1_mciop0c_pwr_en    )  , //input
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
         .riser_en_out     (w_pal_p1_mciop1a_pwr_en    )  , //input
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
         .riser_en_out     (w_pal_p1_mciop1c_pwr_en    )  , //input
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
         .riser_en_out     (w_pal_p1_mciop2a_pwr_en    )  , //input
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
         .riser_en_out     (w_pal_p1_mciop2c_pwr_en    )  , //input
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
         .riser_en_out     (w_pal_p1_mciop3a_pwr_en    )  , //input
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
         .riser_en_out     (w_pal_p1_mciop3c_pwr_en    )  , //input
	.mcio_cable_id0  (w_P1_MCIOP3C_CB_ID0_R        )  , //input
	.mcio_cable_id1  (w_P1_MCIOP3C_CB_ID1_R        )  , //input

	.error_flag          (  )                          //output
);

/**************************************************************************************************/
//-------------------------------------------------------------------------------------------------
// OCP1 START
//-------------------------------------------------------------------------------------------------
/**************************************************************************************************/

//-------------------------------------------------------------------------------------------------
// PVT_DATA   74lv165      
//-------------------------------------------------------------------------------------------------
wire    w_ocp0_LINK_SPDB_P5 ;//31
wire    w_ocp0_ACT_P5       ;//30
wire    w_ocp0_LINK_SPDA_P6 ;//29
wire    w_ocp0_LINK_SPDB_P6 ;//28
wire    w_ocp0_ACT_P6       ;//27
wire    w_ocp0_LINK_SPDA_P7 ;//26
wire    w_ocp0_LINK_SPDB_P7 ;//25
wire    w_ocp0_ACT_P7       ;//24
wire    w_ocp0_ACT_P2       ;//23
wire    w_ocp0_LINK_SPDA_P3 ;//22
wire    w_ocp0_LINK_SPDB_P3 ;//21
wire    w_ocp0_ACT_P3       ;//20
wire    w_ocp0_LINK_SPDA_P4 ;//19
wire    w_ocp0_LINK_SPDB_P4 ;//18
wire    w_ocp0_ACT_P4       ;//17
wire    w_ocp0_LINK_SPDA_P5 ;//16
wire    w_ocp0_LINK_SPDA_P0 ;//15
wire    w_ocp0_LINK_SPDB_P0 ;//14
wire    w_ocp0_ACT_P0       ;//13
wire    w_ocp0_LINK_SPDA_P1 ;//12
wire    w_ocp0_LINK_SPDB_P1 ;//11
wire    w_ocp0_ACT_P1       ;//10
wire    w_ocp0_LINK_SPDA_P2 ;//9
wire    w_ocp0_LINK_SPDB_P2 ;//8
wire    w_ocp0_PRSNTB_0     ;//7
wire    w_ocp0_PRSNTB_1     ;//6
wire    w_ocp0_PRSNTB_2     ;//5
wire    w_ocp0_PRSNTB_3     ;//4
wire    w_ocp0_WAKE_N       ;//3
wire    w_ocp0_TEMP_WARN_N  ;//2
wire    w_ocp0_TEMP_CRIT_N  ;//1
wire    w_ocp0_FAN_ON_AUX   ;//0

wire    [5:0]   pvti_ocp0_count;
wire    w_nic_act_flag      ;
wire    w_pal_led_nic_act_r;

pvt_gpi #(
  .TOTAL_BIT_COUNT(32),
  .DEFAULT_STATE(32'h0),
  .NUMBER_OF_COUNTER_BITS(6)
) pvt_ocp0_inst (
  .clk           (clk_50m),                        //in
  .reset_n       (pon_reset_n),                    //in
  .clk_ena       (t16us_tick),                     //in
  .serclk_in     (o_PAL_OCP_SS_CLK_R),         //in   
  .par_load_in_n (o_PAL_OCP_SS_LD_N_R),          //in   
  .sdi           (i_PAL_OCP1_SS_DATA_IN  ),  //in   
  .bit_idx_in    (pvti_ocp0_count),                  //in
  .bit_idx_out   (pvti_ocp0_count),                  //out
  .serclk_out    (o_PAL_OCP_SS_CLK_R ),        //out
  .par_load_out_n(o_PAL_OCP_SS_LD_N_R),          //out
                   //last bit
  .par_data      ({     w_ocp0_LINK_SPDB_P5, w_ocp0_ACT_P5, w_ocp0_LINK_SPDA_P6, w_ocp0_LINK_SPDB_P6,    //74LV165 #3
				   w_ocp0_ACT_P6, w_ocp0_LINK_SPDA_P7, w_ocp0_LINK_SPDB_P7, w_ocp0_ACT_P7,                       

				   w_ocp0_ACT_P2, w_ocp0_LINK_SPDA_P3, w_ocp0_LINK_SPDB_P3, w_ocp0_ACT_P3,          //74LV165 #2
				   w_ocp0_LINK_SPDA_P4, w_ocp0_LINK_SPDB_P4, w_ocp0_ACT_P4, w_ocp0_LINK_SPDA_P5,               

				   w_ocp0_LINK_SPDA_P0, w_ocp0_LINK_SPDB_P0, w_ocp0_ACT_P0, w_ocp0_LINK_SPDA_P1,    //74LV165 #1
				   w_ocp0_LINK_SPDB_P1, w_ocp0_ACT_P1, w_ocp0_LINK_SPDA_P2, w_ocp0_LINK_SPDB_P2,                      

				   w_ocp0_PRSNTB_0, w_ocp0_PRSNTB_1, w_ocp0_PRSNTB_2, w_ocp0_PRSNTB_3,              //74LV165 #0
				   w_ocp0_WAKE_N, w_ocp0_TEMP_WARN_N, w_ocp0_TEMP_CRIT_N, w_ocp0_FAN_ON_AUX                                  
               })                                                                    //first bit
);

assign w_pal_led_nic_act_r =    w_nic_act_flag ? t4hz_clk :
                                                         (w_ocp_prsnt_n ) ? 1'b0 :
                                                         ~(w_ocp0_ACT_P0 & w_ocp0_ACT_P1 & w_ocp0_ACT_P2 & w_ocp0_ACT_P3 & 
                                                         w_ocp0_ACT_P4 & w_ocp0_ACT_P5 & w_ocp0_ACT_P6 & w_ocp0_ACT_P7 ) ? t1hz_clk:
                                                         ~(w_ocp0_LINK_SPDA_P0 & w_ocp0_LINK_SPDB_P0 &
                                                          w_ocp0_LINK_SPDA_P1 & w_ocp0_LINK_SPDB_P1 &
                                                          w_ocp0_LINK_SPDA_P2 & w_ocp0_LINK_SPDB_P2 &
                                                          w_ocp0_LINK_SPDA_P3 & w_ocp0_LINK_SPDB_P3 &
                                                          w_ocp0_LINK_SPDA_P4 & w_ocp0_LINK_SPDB_P4 &
                                                          w_ocp0_LINK_SPDA_P5 & w_ocp0_LINK_SPDB_P5 &
                                                          w_ocp0_LINK_SPDA_P6 & w_ocp0_LINK_SPDB_P6 &
                                                          w_ocp0_LINK_SPDA_P7 & w_ocp0_LINK_SPDB_P7   ) ? 1'b1 : 1'b0 ; 


//-------------------------------------------------------------------------------------------------
// OCP RISER  2024-4-10 add
//-------------------------------------------------------------------------------------------------

wire [2:0] pvti_ocp_riser_count;
//u66
wire    w_OCP_RISER_BOARD_ID0     ;
wire    w_OCP_RISER_BOARD_ID1     ;
wire    w_OCP_RISER_BOARD_ID2     ;
wire    w_OCP_RISER_BOARD_ID3     ;
wire    w_OCP_RISER_BOARD_ID4     ;
wire    w_OCP_RISER_BOARD_ID5     ;
wire    w_OCP_RISER_PCB_REVISION_0;
wire    w_OCP_RISER_PCB_REVISION_1;
wire    [5:0]   w_ocp_riser_board_id;
wire    w_ocp_riser_prsnt;

assign  w_ocp_riser_board_id = {w_OCP_RISER_BOARD_ID5,
                                                           w_OCP_RISER_BOARD_ID4,
                                                           w_OCP_RISER_BOARD_ID3,
                                                           w_OCP_RISER_BOARD_ID2,
                                                           w_OCP_RISER_BOARD_ID1,
                                                           w_OCP_RISER_BOARD_ID0};

assign  w_ocp_riser_prsnt = (w_ocp_riser_board_id == 6'b010101) ? 1'b1 : 1'b0 ;

pvt_gpi #(
  .TOTAL_BIT_COUNT(8),
  .DEFAULT_STATE(8'h0),
  .NUMBER_OF_COUNTER_BITS(3) 
) pvt_ocp_riser_inst (
  .clk                      (clk_50m),                            //in
  .reset_n              (pon_reset_n),                    //in
  .clk_ena              (t16us_tick),                      //in
  .serclk_in          (o_OCP1_CLK_R),                   //in   
  .par_load_in_n  (o_OCP1_LD_R),                     //in   
  .sdi                      (i_OCP1_DATA_IN_R  ),         //in   
  .bit_idx_in        (pvti_ocp_riser_count),   //in
  .bit_idx_out      (pvti_ocp_riser_count),   //out
  .serclk_out        (o_OCP1_CLK_R ),                  //out
  .par_load_out_n(o_OCP1_LD_R),                     //out
                   //last bit
  .par_data      ({
                                w_OCP_RISER_BOARD_ID0,w_OCP_RISER_BOARD_ID1,w_OCP_RISER_BOARD_ID2,w_OCP_RISER_BOARD_ID3,    
                                w_OCP_RISER_BOARD_ID4,w_BOARD_ID5,w_OCP_RISER_PCB_REVISION_0,w_OCP_RISER_PCB_REVISION_1
                            })                                                                    //first bit
);

//-------------------------------------------------------------------------------------------------
// OCP1_HOT PLUG  //2023-2-11 add ocp_vpp
//-------------------------------------------------------------------------------------------------
// wire  [15:0]  ocp1_vpp_state;
// wire          ocp1_vpp_int_n;

// PCA9555_SIM #(.CHIP_NUM(1'b1), .CLK_FREQ(2500000)) inst01_pca9555_sim (
    // .rst_n       (pon_reset_n               ),
    //// .sys_clk     (clk                       ),
    // .sys_clk     (clk_2p5m                  ),
    // .scl         (i_PAL_SMB_CPU1_OCP2_SCL    ),
    // .sda         (io_PAL_SMB_CPU1_OCP2_SDA   ),

    // .addr        (8'h42                     ), //input

    // .i2c_idle    (                          ), //output

    // .port00      ( ocp1_vpp_state[0] ), //inout
    // .port01      ( ocp1_vpp_state[1] ), //inout
    // .port02      ( ocp1_vpp_state[2] ), //inout
    // .port03      ( ocp1_vpp_state[3] ), //inout
    // .port04      ( ocp1_vpp_state[4] ), //inout
    // .port05      ( ocp1_vpp_state[5] ), //inout
    // .port06      ( ocp1_vpp_state[6] ), //inout
    // .port07      ( ocp1_vpp_state[7] ), //inout

    // .port10      ( ocp1_vpp_state[8]  ), //inout
    // .port11      ( ocp1_vpp_state[9]  ), //inout
    // .port12      ( ocp1_vpp_state[10] ), //inout
    // .port13      ( ocp1_vpp_state[11] ), //inout
    // .port14      ( ocp1_vpp_state[12] ), //inout
    // .port15      ( ocp1_vpp_state[13] ), //inout
    // .port16      ( ocp1_vpp_state[14] ), //inout
    // .port17      ( ocp1_vpp_state[15] ), //inout
    // .int         ( ocp1_vpp_int_n     )  //output
// );

// assign  ocp1_vpp_state[4]  = w_PAL_OCP1_PRSNT_B0_N & w_PAL_OCP1_PRSNT_B1_N 
                           // & w_PAL_OCP1_PRSNT_B2_N & w_PAL_OCP1_PRSNT_B3_N  ; //prsnt 

assign  w_ocp_prsnt_n   =   w_PAL_OCP1_PRSNT_B0_N & w_PAL_OCP1_PRSNT_B1_N & w_PAL_OCP1_PRSNT_B2_N & w_PAL_OCP1_PRSNT_B3_N  ; //prsnt 

wire    w_ocp1_prsnt_invert;
wire    w_ocp1_prsnt_invert_dly100ms;
reg      r_ocp1_alert;
reg      r_ocp1_test;

Edge_Detect Edge_Detect_u1(
.i_clk           (clk_50m),           //input Clk
.i_rst_n         (pon_reset_n),         //Global rst,Active Low
.i_signal        (w_ocp_prsnt_n),//ocp1_vpp_state[4]

.o_signal_pos    (),
.o_signal_neg    (),
.o_signal_invert (w_ocp1_prsnt_invert)
);
//100ms delay
delay #(.COUNT(5_000_000))    //  20ns--50Mhz
     ocp1_prsnt_invert_dly100ms(
                   .iClk(clk_50m),
                   .iRst(pon_reset_n),
                   .iStart(r_ocp1_test),  //it should be a level signal not edge signal
                   .iClrCnt(1'b0),
                   .oDone(w_ocp1_prsnt_invert_dly100ms)
                   );
				   
always@(posedge clk_50m or negedge pon_reset_n) begin
	if(~pon_reset_n) begin
        r_ocp1_alert <= 1'b1 ;
		r_ocp1_test  <= 1'b0 ;
	end
	else if(w_ocp1_prsnt_invert) begin  
        r_ocp1_alert <= 1'b0 ;
		r_ocp1_test  <= 1'b1 ;
    end
	else if(w_ocp1_prsnt_invert_dly100ms) begin
        r_ocp1_alert <= 1'b1 ;
		r_ocp1_test  <= 1'b0 ;
    end
end
//-------------------------------------------------------------------------------------------------
// OCP1_HP_SW_EN
//-------------------------------------------------------------------------------------------------
wire  w_ctl_pal_ocp_hp_sw_en_r ;
reg   r_pal_ocp_hp_sw_en_r ;
wire  w_ocp1_aux_pwr_en ;
//50ms delay
delay #(.COUNT(2_500_000))    //  20ns--50Mhz
     ocp_hp_sw_en_dly50ms(
                   .iClk(clk_50m),
                   .iRst(pon_reset_n),
                   .iStart(~w_ocp_prsnt_n),   
                   .iClrCnt(1'b0),
                   .oDone(w_ctl_pal_ocp_hp_sw_en_r)
                   );
				   
always@(posedge clk_50m or negedge pon_reset_n)
begin
	if(~pon_reset_n)
	  begin
         r_pal_ocp_hp_sw_en_r <= 1'b1 ;
	  end
	else if(w_ctl_pal_ocp_hp_sw_en_r & w_ocp1_aux_pwr_en )
	  begin
         r_pal_ocp_hp_sw_en_r <= 1'b0 ;
      end
   else if(~(w_ctl_pal_ocp_hp_sw_en_r & w_ocp1_aux_pwr_en))   
	  begin
         r_pal_ocp_hp_sw_en_r <= 1'b1 ;
      end
end
//-------------------------------------------------------------------------------------------------
// OCP1_AUXPWR_ON_EN
//-------------------------------------------------------------------------------------------------
reg  r_pal_ocp1_auxpwr_on_r    ;
//50ms delay
delay #(.COUNT(2_500_000))    //  20ns--50Mhz
     ocp1_aux_pwr_en_dly50ms(
                   .iClk(clk_50m),
                   .iRst(pon_reset_n),
                   .iStart(w_pgd_p3v3_stby ),   
                   .iClrCnt(1'b0),
                   .oDone(w_ocp1_aux_pwr_en)
                   );	

always@(posedge clk_50m or negedge pon_reset_n)
begin
	if(~pon_reset_n)
	  begin
		 r_pal_ocp1_auxpwr_on_r  <= 1'b0 ;
	  end
	else if(w_ocp1_aux_pwr_en)
	  begin
		 r_pal_ocp1_auxpwr_on_r  <= 1'b1 ;
      end
    else if(~w_ocp1_aux_pwr_en)     
	  begin
		 r_pal_ocp1_auxpwr_on_r  <= 1'b0 ;
      end
end				   

//-------------------------------------------------------------------------------------------------
// OCP1_MAIN_PWR_ON
//-------------------------------------------------------------------------------------------------	
wire w_ocp1_main_pwr_on ;
reg  r_pal_ocp1_mainpwr_on_r   ;
//50ms delay
delay #(.COUNT(2_500_000))    //  20ns--50Mhz
     ocp1_main_pwr_en_dly50ms(
                   .iClk(clk_50m),
                   .iRst(pon_reset_n),
                   .iStart(w_PWRGD_P12V & w_ctl_pal_ocp_hp_sw_en_r),   
                   .iClrCnt(1'b0),
                   .oDone(w_ocp1_main_pwr_on)
                   );		

always@(posedge clk_50m or negedge pon_reset_n)
begin
	if(~pon_reset_n)
	  begin
		 r_pal_ocp1_mainpwr_on_r <= 1'b0 ;
	  end
	else if(w_ocp1_main_pwr_on)
	  begin
		 r_pal_ocp1_mainpwr_on_r <= 1'b1 ;
      end
	else if(~w_ocp1_main_pwr_on)                
	  begin
		 r_pal_ocp1_mainpwr_on_r <= 1'b0 ;
      end
end

//-------------------------------------------------------------------------------------------------
// OCP1_STBY_PWR_EN
//-------------------------------------------------------------------------------------------------	
wire w_ocp1_stby_pwr_en ;
reg  r_pal_ocp1_stby_pwr_en_r   ;

//50ms delay
delay #(.COUNT(2_500_000))    //  20ns--50Mhz
     ocp1_stby_pwr_en_dly50ms(
                   .iClk(clk_50m),
                   .iRst(pon_reset_n),
                   .iStart(db_i_pal_ocp1_pgd),   //
                   .iClrCnt(1'b0),
                   .oDone(w_ocp1_stby_pwr_en)
                   );			

always@(posedge clk_50m or negedge pon_reset_n)
begin
	if(~pon_reset_n)
	  begin
         r_pal_ocp1_stby_pwr_en_r <= 1'b0 ;
	  end
	else if(w_ocp1_stby_pwr_en)
	  begin
         r_pal_ocp1_stby_pwr_en_r <= 1'b1 ;
      end
	else if(~w_ocp1_stby_pwr_en)          
	  begin
         r_pal_ocp1_stby_pwr_en_r <= 1'b0 ;
      end
end

//-------------------------------------------------------------------------------------------------
// OCP1_MAIN_PWR_EN
//-------------------------------------------------------------------------------------------------
wire  w_ocp1_main_pwr_en;
reg   r_pal_ocp_main_pwr_en_r;

//100ms delay
delay #(.COUNT(5_000_000))    //  20ns--50Mhz
     ocp_main_pwr_en_dly100ms(
                   .iClk(clk_50m),
                   .iRst(pon_reset_n),
                   .iStart(w_P0_SLP_S3_N),   
                   .iClrCnt(1'b0),
                   .oDone(w_ocp1_main_pwr_en)
                   );
				   
always@(posedge clk_50m or negedge pon_reset_n)
begin
    if(~pon_reset_n)
        begin
        r_pal_ocp_main_pwr_en_r <= 1'b0 ;
        end
    else if(w_ocp1_main_pwr_en)
        begin
        r_pal_ocp_main_pwr_en_r <= 1'b1 ;
        end
    else if(~w_ocp1_main_pwr_en)          
        begin
        r_pal_ocp_main_pwr_en_r <= 1'b0 ;
        end
end

//-------------------------------------------------------------------------------------------------
// OCP1_PWRBRK_OD_N
//-------------------------------------------------------------------------------------------------
wire    w_pal_ocp_pwrbrk_od_n_flag ;
reg      r_pal_ocp_pwrbrk_od_n_r    ;

always@(posedge clk_50m or negedge pon_reset_n)
begin
	if(~pon_reset_n)
	  begin
         r_pal_ocp_pwrbrk_od_n_r <= 1'b1 ;
	  end
	else
	  begin
         r_pal_ocp_pwrbrk_od_n_r <= ~w_pal_ocp_pwrbrk_od_n_flag ;
      end
end

//-------------------------------------------------------------------------------------------------
// OCP1_SWITCH_EN_N
//-------------------------------------------------------------------------------------------------
reg  r_pal_ocp1_switch_en_n_r;
wire w_ctl_pal_ocp1_switch_en_n_r;

always@(posedge clk_50m or negedge pon_reset_n)//2023-4-11 chg back to follow bmc ctl
begin
	if(~pon_reset_n)
	  begin
         r_pal_ocp1_switch_en_n_r <= 1'b1 ;
	  end
	else
	  begin
         r_pal_ocp1_switch_en_n_r <= w_ctl_pal_ocp1_switch_en_n_r ;
      end
end

//-------------------------------------------------------------------------------------------------
// OCP1_SMRST_N
//-------------------------------------------------------------------------------------------------

wire w_pal_ocp_smrst_n_flag         ;
wire w_ocp_smrst_flag_posedge       ;
reg  r_pal_ocp_smrst_n_r            ;
reg [8:0] r_ocp_smrst_n_dly_time_cnt;     //500
reg [2:0] r_ocp_smrst_flag_dly      ;

//detect ocp_smrst_flag posedge
always@(posedge clk_50m or negedge pon_reset_n)
begin
	if(~pon_reset_n)
		r_ocp_smrst_flag_dly <= 3'd0;
	else
		r_ocp_smrst_flag_dly <= {r_ocp_smrst_flag_dly[2:0],w_pal_ocp_smrst_n_flag}; //
end

assign w_ocp_smrst_flag_posedge = (!r_ocp_smrst_flag_dly[2]) & r_ocp_smrst_flag_dly[1];

always @(posedge clk_50m or negedge pon_reset_n) begin
	  if (~pon_reset_n) begin
		  r_pal_ocp_smrst_n_r <= 1'b1;
		  r_ocp_smrst_n_dly_time_cnt <= 9'd0;
	  end
	  else if (w_ocp_smrst_flag_posedge) begin
		  r_pal_ocp_smrst_n_r <= 1'b0;
		  r_ocp_smrst_n_dly_time_cnt <= 9'd0;
	  end
	else if (r_ocp_smrst_n_dly_time_cnt == 9'd500) begin
	  	  r_pal_ocp_smrst_n_r <= 1'b1;
	  end
	else if (t1ms_tick) begin
		  r_ocp_smrst_n_dly_time_cnt <= r_ocp_smrst_n_dly_time_cnt + 1'b1;
	  end
end

//-------------------------------------------------------------------------------------------------
// OCP1_PERST_N
//-------------------------------------------------------------------------------------------------

// reg  r_pal_ocp_perst0_n_r ;
// reg  r_pal_ocp_perst1_n_r ;
reg  r_pal_ocp_perst2_n_r ;//2024-6-5 ADD 
reg  r_pal_ocp_perst3_n_r ;//2024-6-5 ADD 

wire w_ocp1_pwrgd_dly1s; 

//1000ms delay
delay #(.COUNT(50_000_000))    //  20ns--50Mhz  
     ocp_perst_dly1000ms(
                   .iClk(clk_50m),
                   .iRst(pon_reset_n),
                   .iStart(db_i_pal_ocp1_pwrgd ),   // 
                   .iClrCnt(1'b0),
                   .oDone(w_ocp1_pwrgd_dly1s)
                   );
	
	
always @(posedge clk_50m or negedge pon_reset_n) begin
	  if (~pon_reset_n) 
	    begin
		    // r_pal_ocp_perst0_n_r <= 1'b0;
		    // r_pal_ocp_perst1_n_r <= 1'b0;
                    r_pal_ocp_perst2_n_r <= 1'b0;
		    r_pal_ocp_perst3_n_r <= 1'b0;			
	    end
	else if (w_ocp1_pwrgd_dly1s & w_p0_pcie_rst_n_0) 
	    begin
                    // r_pal_ocp_perst0_n_r <= 1'b1;
		    // r_pal_ocp_perst1_n_r <= 1'b1;
                    r_pal_ocp_perst2_n_r <= 1'b1;
		    r_pal_ocp_perst3_n_r <= 1'b1;
	    end
	else if (~(w_ocp1_pwrgd_dly1s & w_p0_pcie_rst_n_0)) 
	    begin
                    // r_pal_ocp_perst0_n_r <= 1'b0;
		    // r_pal_ocp_perst1_n_r <= 1'b0;
                    r_pal_ocp_perst2_n_r <= 1'b0;
		    r_pal_ocp_perst3_n_r <= 1'b0;
	    end
end
//-------------------------------------------------------------------------------------------------
// output clk
//-------------------------------------------------------------------------------------------------
reg r_PAL_BMC_RMII_CLK_50M_R   ;
reg r_PAL_OCP_NCSI_CLK_50M_R   ;
reg r_PAL_NCSI_50M_REF_CLK_R   ;

always@(*)
	begin
		if(~pon_reset_n)
			begin
				r_PAL_BMC_RMII_CLK_50M_R  <= 1'b0    ;
				r_PAL_OCP_NCSI_CLK_50M_R  <= 1'b0    ;
				r_PAL_NCSI_50M_REF_CLK_R  <= 1'b0    ;
			end                                      
		else                                         
			begin                                    
				r_PAL_BMC_RMII_CLK_50M_R  <= clk_50m ;
				r_PAL_OCP_NCSI_CLK_50M_R  <= clk_50m ;
				r_PAL_NCSI_50M_REF_CLK_R  <= clk_50m ;
			end

end

// assign  o_PAL_BMC_RMII_CLK_50M_R  = r_PAL_BMC_RMII_CLK_50M_R   ;
// assign  o_PAL_OCP_NCSI_CLK_50M_R  = r_PAL_OCP_NCSI_CLK_50M_R   ;
// assign  o_PAL_NCSI_50M_REF_CLK_R  = r_PAL_NCSI_50M_REF_CLK_R   ;


//-------------------------------------------------------------------------------------------------
// UID LED   
//-------------------------------------------------------------------------------------------------

UID_Function#(
.LONG_PRESS        (4'd5)
)UID_Function_u0(
.i_clk                    (clk_50m		),		//input Clk
.i_1mSEC                  (t1ms_tick	),
.i_20mSEC                 (t32ms_tick	),
.i_rst_n                  (pon_reset_n	),		//Global rst,Active Low
.i_clr_flag_short         (~w_uid_btn_evt_wc),       //Use the same signal on common design
.i_clr_flag_long          (~w_uid_rstbmc_evt_wc),    //Use the same signal on common design 
.i_UID_BMC_BTN_N          (1'b1),
.i_UID_BTN_RP_CPLD_N      (db_i_uid_sw_in_n	),//i_UID_BTN_CPLD_N
.i_UID_BTN_FP_CPLD_N      (1'b1), 

//Output Signal
.o_BMC_UID_CPLD_N         (),   // reserved, bmc control uid led via i2c
.o_BMC_EXTRST_CPLD_OUT_N  (w_bmc_extrst_uid		),
.o_UID_BTN_short_pos      (uid_btn_all_invert	),

.o_uid_button_long        (uid_button_long_evt ),
.o_uid_button_short       (uid_button_short_evt),

.i_uid_valid              (1'b0),  //reserved
.i_uid_status             (8'h00), //reserved
.o_uid_act_st             ()       //reserved
);

//bmc control uid led when bmc active, or uid button will control uid led when bmc die;
reg r_BMC_UID_CPLD_N;
reg [7:0] r_uid_led_ctl;
//assign o_uid_led_ctl    = r_uid_led_ctl;

always@(posedge clk_50m or negedge pon_reset_n)
begin
    if(~pon_reset_n)
	begin
            r_BMC_UID_CPLD_N  <= 1'b1;
            r_uid_led_ctl     <= 8'h00;
	end
	else if(w_bmc_ready_flag) 
    begin
		r_uid_led_ctl  <= w_uid_led_ctl;
	    case (w_uid_led_ctl)
                8'h00: r_BMC_UID_CPLD_N  <= 1'b1;
                8'h01: r_BMC_UID_CPLD_N  <= t0p5hz_clk;
                8'h02: r_BMC_UID_CPLD_N  <= t1hz_clk;
                8'h04: r_BMC_UID_CPLD_N  <= t4hz_clk;
                8'hff: r_BMC_UID_CPLD_N  <= 1'b0;
                default: r_BMC_UID_CPLD_N  <= 1'b1;
	    endcase
	end
	else  
	begin
		case (r_uid_led_ctl)
		8'h00: 	
		begin
			r_BMC_UID_CPLD_N  <= 1'b1;
			if(uid_btn_all_invert) 		        
		        r_uid_led_ctl     <= 8'hff;
		end
		8'h01: 
		begin
			if(uid_btn_all_invert)
			    r_uid_led_ctl     <= 8'hff;
		end
		8'h02: 
		begin
			if(uid_btn_all_invert)
			    r_uid_led_ctl     <= 8'hff;
		end
		8'h04: 
		begin
			if(uid_btn_all_invert)
			    r_uid_led_ctl     <= 8'hff;
		end		
		8'hff:
		begin
			r_BMC_UID_CPLD_N  <= 1'b0;
			if(uid_btn_all_invert) 			    
		        r_uid_led_ctl     <= 8'h00;
		end
		default: 
		begin 
		    r_uid_led_ctl     <= 8'h00; 
       	end	
		endcase	 
	end
end
//-------------------------------------------------------------------------------------------------
// NIC &SYSTEM HEALTHY LED
//-------------------------------------------------------------------------------------------------
wire    w_sys_healthy_red   ;
wire    w_sys_healthy_grn   ;
reg      r_pal_led_hel_red_r  ;
reg      r_pal_led_hel_gr_r   ;

always@(posedge clk_50m or negedge pon_reset_n)
begin
	if(~pon_reset_n)
            begin
                r_pal_led_hel_red_r  <= 1'b0;
                r_pal_led_hel_gr_r   <= 1'b0;
            end
	else 
            begin
                case({w_sys_healthy_red,w_sys_healthy_grn}) 		
                    2'b00: begin
                        r_pal_led_hel_red_r  <= 1'b0;
                        r_pal_led_hel_gr_r   <= 1'b0;
                    end
                    2'b01: begin
                        r_pal_led_hel_red_r  <= 1'b0;
                        r_pal_led_hel_gr_r   <= 1'b1;
                    end
                    2'b10: begin
                        r_pal_led_hel_red_r  <= t1hz_clk;
                        r_pal_led_hel_gr_r   <= 1'b0;
                    end
                    2'b11: begin
                        r_pal_led_hel_red_r  <= t1hz_clk;
                        r_pal_led_hel_gr_r   <= t1hz_clk;
                    end
                    default: 	
                        begin
                            r_pal_led_hel_red_r  <= 1'b0;
                            r_pal_led_hel_gr_r   <= 1'b0;
                        end
                endcase
            end
end
//-------------------------------------------------------------------------------------------------
//S5_S0 LED
//-------------------------------------------------------------------------------------------------
reg      r_led_pwrbtn_gr ;
reg      r_led_pwrbtn_amb;

always@(posedge clk_50m or negedge pon_reset_n) begin
	if(~pon_reset_n) begin
			r_led_pwrbtn_gr  <= 1'b0 ;
			r_led_pwrbtn_amb <= 1'b1 ;
		end
	else begin
	    if (w_P0_SLP_S5_N == 1'b0 && w_pgd_p5v == 1'b0 ) begin
		    r_led_pwrbtn_gr  <= 1'b0 ;
		    r_led_pwrbtn_amb <= 1'b1 ;
		end
		else if (w_P0_SLP_S5_N == 1'b1 && w_pgd_p5v == 1'b0) begin
		    r_led_pwrbtn_gr  <= t2p5hz_clk ;
		    r_led_pwrbtn_amb <= 1'b0 ;
		end
		else if (w_P0_SLP_S5_N == 1'b1 && w_pgd_p5v == 1'b1) begin
		    r_led_pwrbtn_gr  <= 1'b1 ;
		    r_led_pwrbtn_amb <= 1'b0 ;
		end
		else begin
		    r_led_pwrbtn_gr  <= 1'b0 ;
		    r_led_pwrbtn_amb <= 1'b1 ;
		end
	end
end
//-------------------------------------------------------------------------------------------------
// MISC
//-------------------------------------------------------------------------------------------------
reg      r_pal_mb_switch_en_n_r         ;
// reg r_remote_xdp_tck_sel_r         ;
// reg r_remote_xdp_debug_n_r         ;
reg      r_pal_biosrom_io11             ;
reg      r_pal_bios_online_update_en    ;
wire    w_pal_mb_switch_en_n_r        ;
// wire w_remote_xdp_tck_sel_r        ;
// wire w_remote_xdp_debug_n_r        ;

always@(posedge clk_50m or negedge pon_reset_n)
begin
	if(~pon_reset_n)
	  begin
	    r_pal_mb_switch_en_n_r       <= 1'b0;
		// r_remote_xdp_tck_sel_r       <= 1'b0;
		// r_remote_xdp_debug_n_r       <= 1'b1;
		r_pal_biosrom_io11           <= 1'b1;
		r_pal_bios_online_update_en  <= 1'b0;
	  end
	else
	  begin
	    r_pal_mb_switch_en_n_r       <= w_pal_mb_switch_en_n_r;
		// r_remote_xdp_tck_sel_r       <= w_remote_xdp_tck_sel_r  ;
		// r_remote_xdp_debug_n_r       <= w_remote_xdp_debug_n_r  ;
		r_pal_biosrom_io11           <= w_pal_biosrom_io11      ;
		r_pal_bios_online_update_en  <= ~w_pal_biosrom_io11 ;
      end
end
// assign o_PAL_MB_SWITCH_EN_N_R       = r_pal_mb_switch_en_n_r        ;
// assign o_REMOTE_XDP_TCK_SEL_R       = r_remote_xdp_tck_sel_r        ;
// assign o_REMOTE_XDP_DEBUG_N_R       = r_remote_xdp_debug_n_r        ;
// assign o_PAL_BIOSROM_IO11           = r_pal_biosrom_io11            ;
// assign o_PAL_BIOS_ONLINE_UPDATE_EN  = r_pal_bios_online_update_en   ;

//-------------------------------------------------------------------------------------------------
// USB_HUB_PWR_EN
//-------------------------------------------------------------------------------------------------
wire w_ctl_pal_usb_hub2_p3v3_en_r ;
reg  r_pal_usb_hub2_p3v3_en_r ;
//50ms delay
delay #(.COUNT(2_500_000))    //  20ns--50Mhz
     USB_PWR_EN_DLY100ms(
                   .iClk(clk_50m),
                   .iRst(pon_reset_n),
                   .iStart(w_pgd_p1v2_stby),   //
                   .iClrCnt(1'b0),
                   .oDone(w_ctl_pal_usb_hub2_p3v3_en_r)
                   );

always@(posedge clk_50m or negedge pon_reset_n)
begin
	if(~pon_reset_n)
	  begin
         r_pal_usb_hub2_p3v3_en_r <= 1'b0 ;
	  end
	else if(w_ctl_pal_usb_hub2_p3v3_en_r)
	  begin
         r_pal_usb_hub2_p3v3_en_r <= 1'b1 ;
      end
	else
	  begin
         r_pal_usb_hub2_p3v3_en_r <= 1'b0 ;
      end
end
//-----------------------------------------------------------------------------------

//-------------------------------------------------------------------------------------------------
// CPU0 PE0 --- PVT_DATA    //2024-1-16 add for switch debug
//-------------------------------------------------------------------------------------------------
wire [7:0]  w_164_test_data ;
wire w_164_mr_n;

s2p_164  s2p_164_u1(   //#(parameter NBIT = 8)
  .i_clk     (clk_50m)  ,
  .i_rst     (~pon_reset_n)  ,
  .tick      (t1us_tick)  ,
  .CLK_1ms  (w1mSCE) ,
  
  .i_mr_n    (w_164_mr_n)  ,
  .pi        (w_164_test_data)  ,   //2024-2-18 chg w_164_test_data to 8'h55
  .so        (o_P0_MCIOP1C_WAKE_N_R)  ,    //2024-2-22 chg J48  B29  o_CPU0_MCIO0_WAKE_N_R  TO J185 B29  o_CPU0_MCIO0A_WAKE_N_R
  .sld_n     (o_P0_MCIOP1A_WAKE_N_R)  ,    //2024-2-22 chg J185 B29  o_CPU0_MCIO0A_WAKE_N_R TO J48  B29  o_CPU0_MCIO0_WAKE_N_R
  .o_sclk    (o_P0_MCIOP1C_RSV_R)        //2024-2-22 chg J48  B30  o_CPU0_MCIO0C_RSV_R    TO J185 B30  o_CPU0_MCIO0A_RSV_R
) ;
// assign o_CPU0_MCIO0C_RSV_R = 1'b1 ; //2024-2-22 CHG TO USE AS EN , ALWAYS SET HIGH



//-------------------------------------------------------------------------------------------------
// edge_delay
//-------------------------------------------------------------------------------------------------
edge_delay #(.CNTR_NBITS(6), .DELAY_MODE(1'b0)) edge_delay_slot_3_on_dly_10ms (   //DELAY_MODE =0 for rise edge
    .clk         (clk_50m),
    .reset       (~pon_reset_n),
    .cnt_size    (6'd10),
    .cnt_step    (t1ms_tick),
    .signal_in   (w_P0_SLP_S5_N),//2024-4-10 chg w_PWRGD_P12V to w_pch_slp5_n
    .delay_output(w_slot_3_on_dly_10ms)
);
edge_delay #(.CNTR_NBITS(6), .DELAY_MODE(1'b0)) edge_delay_slot_4_on_dly_10ms (   //DELAY_MODE =0 for rise edge
    .clk         (clk_50m),
    .reset       (~pon_reset_n),
    .cnt_size    (6'd10),
    .cnt_step    (t1ms_tick),
    .signal_in   (w_slot_3_on_dly_10ms),//2024-4-10 chg w_PWRGD_P12V to w_pch_slp5_n
    .delay_output(w_slot_4_on_dly_10ms)
);
edge_delay #(.CNTR_NBITS(6), .DELAY_MODE(1'b0)) edge_delay_slot_5_on_dly_10ms (   //DELAY_MODE =0 for rise edge
    .clk         (clk_50m),
    .reset       (~pon_reset_n),
    .cnt_size    (6'd10),
    .cnt_step    (t1ms_tick),
    .signal_in   (w_slot_4_on_dly_10ms),//2024-4-10 chg w_PWRGD_P12V to w_pch_slp5_n
    .delay_output(w_slot_5_on_dly_10ms)
);
edge_delay #(.CNTR_NBITS(6), .DELAY_MODE(1'b0)) edge_delay_slot_6_on_dly_10ms (   //DELAY_MODE =0 for rise edge
    .clk         (clk_50m),
    .reset       (~pon_reset_n),
    .cnt_size    (6'd10),
    .cnt_step    (t1ms_tick),
    .signal_in   (w_slot_5_on_dly_10ms),//2024-4-10 chg w_PWRGD_P12V to w_pch_slp5_n
    .delay_output(w_slot_6_on_dly_10ms)
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
assign  w_PWRGD_P12V_PS3_PS4    =   (~i_PS3_DCOK_N & i_PS3_PRSNT) || (~i_PS4_DCOK_N & i_PS4_PRSNT);
assign  w_PS3_PS4_ACFAIL    =   db_i_ps3_acfail_n&&db_i_ps4_acfail_n;
assign  w_ps3_p12v_on_r  = w_FM_P12V_EN & db_i_ps3_prsnt ;
assign  w_ps4_p12v_on_r  = w_FM_P12V_EN & db_i_ps4_prsnt ;
assign  w_cpld2_jtagen  =   i_HDR_PAL2_N_R ? 1'b0 : 1'b1 ;

assign  w_p12v_slot_3_on  =   w_p12v_slot_3_on_r & (w_slot_3_on_dly_10ms ||(~w_SW_2 && w_P0_SLP_S5_N));
assign  w_p12v_slot_4_on  =   w_p12v_slot_4_on_r & (w_slot_4_on_dly_10ms ||(~w_SW_2 && w_P0_SLP_S5_N));
assign  w_p12v_slot_5_on  =   w_p12v_slot_5_on_r & (w_slot_5_on_dly_10ms ||(~w_SW_2 && w_P0_SLP_S5_N));
assign  w_p12v_slot_6_on  =   w_p12v_slot_6_on_r & (w_slot_6_on_dly_10ms ||(~w_SW_2 && w_P0_SLP_S5_N));
assign  w_p12v_slot_7_on  =   w_p12v_slot_7_on_r & (w_slot_7_on_dly_10ms ||(~w_SW_2 && w_P0_SLP_S5_N));
assign  w_p12v_slot_8_on  =   w_p12v_slot_8_on_r & (w_slot_8_on_dly_10ms ||(~w_SW_2 && w_P0_SLP_S5_N));
assign  w_p12v_slot_9_on  =   w_p12v_slot_9_on_r & (w_slot_9_on_dly_10ms ||(~w_SW_2 && w_P0_SLP_S5_N));
assign  w_p0_pcie_wake_n_r  =   i_PAL_PE_WAKE_N                  &
                                                         // i_P0_MCIOP1A_WAKE_N_R      &
                                                         // i_P0_MCIOP1C_WAKE_N_R      &
                                                         i_P0_MCIOP2A_WAKE_N_R      &
                                                         i_P0_MCIOP2C_WAKE_N_R      &
                                                         i_P0_MCIOP3A_WAKE_N_R      &
                                                         i_P0_MCIOP3C_WAKE_N_R      &
                                                         i_P0_MCIOG3A_WAKE_N_R      &
                                                         i_P0_MCIOG3C_WAKE_N_R      
                                                         ;
assign  w_p1_pcie_wake_n_r  =   i_P1_MCIOP0A_WAKE_N_R      &
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
assign  w_clk_db2000_2_1_oe_n    = w_pgd_p5v ? 1'b0 : 1'b1 ;
assign  w_clk_db2000_2_2_oe_n    = w_pgd_p5v ? 1'b0 : 1'b1 ;
assign  w_pal_pwr_lom_en_r  =   (w_PWRGD_P12V & w_bmc_ready_flag & ~w_P0_SLP_S3_N)? 1'b1 : 1'b0;


//-------------------------------------------------------------------------------------------------
// NC_PIN
//-------------------------------------------------------------------------------------------------
wire    w_nc_pin;
assign  w_nc_pin    =   i_HDR_PAL2_N_R      &
                                       i_CPLD2_DONE     &
                                       i_CPLD2_INIT_N       &
                                       i_JTAG_BMC_TRST_R        &
                                       i_PAL_CPLD_TDI_R     &
                                       i_PAL_CPLD_TCK_R     &
                                       i_PAL_CPLD_TMS_R     &
                                       i_OCP1_BIF0_N           & 
                                       i_OCP1_BIF1_N           & 
                                       i_OCP1_BIF2_N           & 
                                       i_OCP1_UART_RX_R     &
                                       i_CPLD_SGPIO1_CLK        &
                                       i_CPLD_SGPIO1_LD_N       &
                                       i_CPLD_SGPIO1_MOSI       &
                                       i_PDB_SPGIO_DATAIN       &
                                       i_TYPEC_PRST     &
                                       i_NCSI_RSVD_CPLD     &
                                       i_CHASSIS_ID1_N      &
                                       i_PAL_MAIN_PWR_OK_R      &
                                       i_OCP1_DATA_IN_R       &
                                       i_BMC_UART1_TX       &
                                       i_UART1_TXD_CPLD     &
                                       // i_CPLD1_CPLD2_RSV1_R     &
                                       // i_CPLD1_CPLD2_RSV2_R     &
                                       i_SHORT_DET
                                       
                                       ;

//-----------------------------------------------------------------------------------------------//
//Output SIGNAL
//-----------------------------------------------------------------------------------------------//
assign  o_CPLD2_JTAGEN  =   w_cpld2_jtagen;
assign  o_PAL_BMC_RMII_CLK_50M_R    =   r_PAL_BMC_RMII_CLK_50M_R;
assign  o_PAL_CPLD_TDO  =   1'bz;
assign  o_P12V_SLOT_3_ON    =   w_p12v_slot_3_on;
assign  o_P12V_SLOT_4_ON    =   w_p12v_slot_4_on;
assign  o_P12V_SLOT_5_ON    =   w_p12v_slot_5_on;
assign  o_P12V_SLOT_6_ON    =   w_p12v_slot_6_on;
assign  o_P12V_SLOT_7_ON    =   w_p12v_slot_7_on;
assign  o_P12V_SLOT_8_ON    =   w_p12v_slot_8_on;
assign  o_P12V_SLOT_9_ON    =   w_p12v_slot_9_on;
assign  o_PAL_OCP_SS_DATA_OUT_R =   1'b1;

assign  o_PAL_OCP1_MAINPWR_ON_R       = r_pal_ocp1_mainpwr_on_r      ;
assign  o_PAL_OCP1_AUXPWR_ON_R         = r_pal_ocp1_auxpwr_on_r  ;  //P3V3_OCP1
assign  o_PAL_OCP_MAIN_PWR_EN_R       = r_pal_ocp_main_pwr_en_r      ;//48
assign  o_PAL_OCP_STBY_PWR_EN_R       = r_pal_ocp1_stby_pwr_en_r      ;//47
assign  o_PAL_OCP_NCSI_CLK_50M_R     = r_PAL_OCP_NCSI_CLK_50M_R     ;//46
assign  o_PAL_OCP_PERST0_N_R             = r_pal_ocp_smrst_n_r         ;//45

assign  o_PAL_OCP1_PERST2_R         = r_pal_ocp_perst2_n_r         ;
assign  o_PAL_OCP1_PERST3_R         = r_pal_ocp_perst3_n_r         ;
assign  o_PAL_OCP1_SWITCH_EN_N_R = r_pal_ocp1_switch_en_n_r ;
assign  o_PAL_OCP_PWRBRK_OD_N_R = r_pal_ocp_pwrbrk_od_n_r ;
assign  o_PAL_OCP_HP_SW_EN_R = r_pal_ocp_hp_sw_en_r ;
assign  o_OCP1_UART_TX_R     =  1'bz;
assign  o_OCP1_ATNT_LED_R   =   1'bz;
assign  o_OCP1_GREEN_LED_R =    1'bz;
assign  o_SMB_PEHP_CPU0_OCP_ALERT = r_ocp1_alert  ;
assign  o_SMB_PEHP_CPU1_OCP_ALERT = r_ocp1_alert  ;
assign  o_PS3_P12V_ON_R =   w_ps3_p12v_on_r;//1
assign  o_PS4_P12V_ON_R =   w_ps4_p12v_on_r;//2
assign  o_CPLD_SGPIO1_MISO  =   1'bz;

assign  o_PAL_LED_UID_R = ~r_BMC_UID_CPLD_N;
assign  o_LED_PWRBTN_GR_R   = r_led_pwrbtn_gr  ;
assign  o_LED_PWRBTN_AMB_R  = r_led_pwrbtn_amb ;
assign  o_PAL_LED_NIC_ACT_R  = w_pal_led_nic_act_r;
assign  o_PAL_LED_HEL_RED_R  = r_pal_led_hel_red_r   ;
assign  o_PAL_LED_HEL_GR_R   = r_pal_led_hel_gr_r    ;
assign  o_PAL_OCP_HP_ATN_LED_R  =   1'bz;
// DEBUG LED
assign  o_LED1_N = w_led_control[0] ? 1'b0 : 1'b1  ;
assign  o_LED2_N = w_led_control[1] ? 1'b0 : 1'b1  ;
assign  o_LED3_N = w_led_control[2] ? 1'b0 : 1'b1  ;
assign  o_LED4_N = w_led_control[3] ? 1'b0 : 1'b1  ;
assign  o_LED5_N = w_led_control[4] ? 1'b0 : 1'b1  ;
assign  o_LED6_N = w_led_control[5] ? 1'b0 : 1'b1  ;
assign  o_LED7_N = w_led_control[6] ? 1'b0 : 1'b1  ;
assign  o_LED8_N = w_led_control[7] ? 1'b0 : 1'b1  ;
assign  o_PAL_BP1_CPU_IP2P  =   1'b1;
assign  o_PAL_BP2_CPU_IP2P  =   1'b1;
assign  o_PAL_BP4_CPU_IP2P  =   1'b1;
assign  o_PAL_BP5_CPU_IP2P  =   1'b1;
assign  o_PAL_BP6_CPU_IP2P  =   1'b1;
assign  o_PAL_BP8_CPU_IP2P  =   1'b1;

assign  o_P0_MCIOP1A_PERST_N_R  =   w_p0_pcie_rst_n_0;
assign  o_P0_MCIOP1C_PERST_N_R  =   w_p0_pcie_rst_n_0;
assign  o_P0_MCIOP2A_PERST_N_R  =   w_p0_pcie_rst_n_0;
assign  o_P0_MCIOP2C_PERST_N_R  =   w_p0_pcie_rst_n_0;
assign  o_P0_MCIOP3A_PERST_N_R  =   w_p0_pcie_rst_n_0;
assign  o_P0_MCIOP3C_PERST_N_R  =   w_p0_pcie_rst_n_0;
assign  o_P0_MCIOG3A_PERST_N_R  =   w_p0_pcie_rst_n_0;
assign  o_P0_MCIOG3C_PERST_N_R  =   w_p0_pcie_rst_n_0;

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

assign  o_P0_MCIOP1A_RSV_R  =   1'b1;
// assign  o_P0_MCIOP1C_RSV_R  =   1'bz;
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

assign  o_CLK_DB2000_2_1_OE_N   =   w_clk_db2000_2_1_oe_n;
assign  o_CLK_DB2000_2_2_OE_N   =   w_clk_db2000_2_2_oe_n;
assign  o_PDB_SPGIO_LD               =   1'bz;
assign  o_PDB_SPGIO_DATAOUT     =   1'bz;
assign  o_PDB_SPGIO_CLK             =   1'bz;
assign  o_RST_I2C1_MUX_N_R      = w_ctl_rst_i2c1_mux_n_r    ;
assign  o_RST_I2C10_MUX_N_R    = w_ctl_rst_i2c10_mux_n_r    ;
assign  o_RST_I2C11_MUX_N_R    = w_ctl_rst_i2c11_mux_n_r    ;
assign  o_RST_I2C4_MUX_N_R      = w_ctl_rst_i2c4_mux_n_r     ;
assign  o_RST_I2C7_MUX_N_R      = w_ctl_rst_i2c7_mux_n_r     ;
assign  o_PCIE_SATA_WAKE_HOST_R_N   =   1'bz;
assign  o_PCIE_SATA_RST_N   =   w_p0_pcie_rst_n_0;
assign  o_SW_BIOS_FLASH_SPI_S_R    =    r_pal_bios_online_update_en;  
assign  o_SW_BIOS_SPI_OE                   =    1'b0;
assign  o_BIOS_FLASH_RESET_R_N      =   1'bz;      
assign  o_SW_MB_TPM_OE                       =  1'b0;
assign  o_PAL_PCIE_M2_0_PERST_N_R   =    w_p0_pcie_rst_n_0;
assign  o_PAL_PCIE_M2_1_PERST_N_R   =    w_p0_pcie_rst_n_0;
assign  o_PAL_NCSI_50M_REF_CLK_R  = r_PAL_NCSI_50M_REF_CLK_R   ;   
assign  o_PAL_MB_SWITCH_EN_N_R       = r_pal_mb_switch_en_n_r        ;       
assign  o_USB_SW_S_R                           =    w_usb_sw_s_r;
assign  o_M_2_SATAPCIE_SEL_R           =    1'bz;

assign  o_BMC_UART5_CPLD_TX             =   i_BMC_UART5_TX ;
assign  o_BMC_UART5_RX                      =   i_BMC_UART5_CPLD_RX;
// assign  o_BMC_UART1_CPLD_TX             =   i_BMC_UART1_TX ;
// assign  o_BMC_UART1_RX                      =   i_BMC_UART1_CPLD_RX;
assign  o_BMC_UART1_RX                      =   i_CPLD1_CPLD2_RSV2_R;
assign  o_UART1_RXD_CPLD                =   1'bz;
assign  o_BMC_UART1_CPLD_TX             =   i_CPLD1_CPLD2_RSV2_R ;
assign  o_CPLD1_CPLD2_RSV1_R        =   i_BMC_UART1_CPLD_RX&i_BMC_UART1_TX;


assign  o_PAL_USB_HUB2_RST_N_R          =    w_p0_pcie_rst_n_0;
assign  o_PAL_USB_HUB2_VBUS_DET_R   =    w_p0_pcie_rst_n_0;
assign  o_PAL_USB_HUB2_P3V3_EN_R    =   r_pal_usb_hub2_p3v3_en_r ;
assign  o_M2_GPIO6_R                            =   1'bz;
assign  o_M2_GPIO7_R                            =   1'bz;
assign  o_CHASSIS_ID0_N =   1'bz;
assign  o_PAL_PWR_LOM_EN_R  =   w_pal_pwr_lom_en_r;
assign  o_P0_SPI_TPM_CS_N_3V3   =   1'bz;
assign  o_P0_I2C5_9617_EN   =   1'b1;
assign  o_P12V_DISCHARGE_R  =   w_p12v_discharge_r;


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
.i_scl			(i_I2C7_PAL2_SCL	), 
.io_sda			(io_I2C7_PAL2_SDA	),

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
.i_nc_pin                                              ({7'b0,w_nc_pin}),                            //addr 0x000a 
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
.o_ctl_rst_i2c4_mux_n_r                  (w_ctl_rst_i2c4_mux_n_r  ),      //addr 0x0010 bit6 default 1
.o_ctl_rst_i2c7_mux_n_r                  (w_ctl_rst_i2c7_mux_n_r  ),      //addr 0x0010 bit5 default 1
.o_ctl_rst_i2c10_mux_n_r                (w_ctl_rst_i2c10_mux_n_r),      //addr 0x0010 bit4 default 1
.o_ctl_rst_i2c11_mux_n_r                (w_ctl_rst_i2c11_mux_n_r),      //addr 0x0010 bit3 default 1

//--0x0011
.i_P0_MCIOP1A_NVME0_PRSNT_N_R       (i_P0_MCIOP1A_NVME0_PRSNT_N_R),//addr 0x0011 bit7
.i_P0_MCIOP1C_NVME0_PRSNT_N_R       (i_P0_MCIOP1C_NVME0_PRSNT_N_R),//addr 0x0011 bit6
.i_P0_MCIOP2A_NVME0_PRSNT_N_R       (i_P0_MCIOP2A_NVME0_PRSNT_N_R),//addr 0x0011 bit5
.i_P0_MCIOP2C_NVME0_PRSNT_N_R       (i_P0_MCIOP2C_NVME0_PRSNT_N_R),//addr 0x0011 bit4
.i_P0_MCIOP3A_NVME0_PRSNT_N_R       (i_P0_MCIOP3A_NVME0_PRSNT_N_R),//addr 0x0011 bit3
.i_P0_MCIOP3C_NVME0_PRSNT_N_R       (i_P0_MCIOP3C_NVME0_PRSNT_N_R),//addr 0x0011 bit2
.i_P0_MCIOG3A_NVME0_PRSNT_N_R       (i_P0_MCIOG3A_NVME0_PRSNT_N_R),//addr 0x0011 bit1
.i_P0_MCIOG3C_NVME0_PRSNT_N_R       (i_P0_MCIOG3C_NVME0_PRSNT_N_R),//addr 0x0011 bit0
//0x0012
.i_P1_MCIOP0A_NVME0_PRSNT_N_R       (i_P1_MCIOP0A_NVME0_PRSNT_N_R),//addr 0x0012 bit7
.i_P1_MCIOP0C_NVME0_PRSNT_N_R       (i_P1_MCIOP0C_NVME0_PRSNT_N_R),//addr 0x0012 bit6
.i_P1_MCIOP1A_NVME0_PRSNT_N_R       (i_P1_MCIOP1A_NVME0_PRSNT_N_R),//addr 0x0012 bit5
.i_P1_MCIOP1C_NVME0_PRSNT_N_R       (i_P1_MCIOP1C_NVME0_PRSNT_N_R),//addr 0x0012 bit4
.i_P1_MCIOP2A_NVME0_PRSNT_N_R       (i_P1_MCIOP2A_NVME0_PRSNT_N_R),//addr 0x0012 bit3
.i_P1_MCIOP2C_NVME0_PRSNT_N_R       (i_P1_MCIOP2C_NVME0_PRSNT_N_R),//addr 0x0012 bit2
.i_P1_MCIOP3A_NVME0_PRSNT_N_R       (i_P1_MCIOP3A_NVME0_PRSNT_N_R),//addr 0x0012 bit1
.i_P1_MCIOP3C_NVME0_PRSNT_N_R       (i_P1_MCIOP3C_NVME0_PRSNT_N_R),//addr 0x0012 bit0
//0x0013
.i_P1_MCIOG1A_NVME0_PRSNT_N_R       (i_P1_MCIOG1A_NVME0_PRSNT_N_R),//addr 0x0013 bit7
.i_P1_MCIOG1C_NVME0_PRSNT_N_R       (i_P1_MCIOG1C_NVME0_PRSNT_N_R),//addr 0x0013 bit6
.i_P1_MCIOP4A_NVME0_PRSNT_N_R       (i_P1_MCIOP4A_NVME0_PRSNT_N_R),//addr 0x0013 bit5

//PSU--0x0015
.i_PS3_PRSNT                                         (db_i_ps3_prsnt      )              , //addr 0x0015 bit7
.i_PS4_PRSNT                                         (db_i_ps4_prsnt      )              , //addr 0x0015 bit6
.i_PS3_ACFAIL                                       (db_i_ps3_acfail_n)              , //addr 0x0015 bit5
.i_PS4_ACFAIL                                       (db_i_ps4_acfail_n)              , //addr 0x0015 bit4
.i_PS3_DCOK                                           (db_i_ps3_dcok_n    )              , //addr 0x0015 bit3
.i_PS4_DCOK                                           (db_i_ps4_dcok_n    )              , //addr 0x0015 bit2
//PSU--0x0016
.i_PS3_ALERT                                         (i_PS3_SMB_ALERT)                  , //addr 0x0016 bit7
.i_PS4_ALERT                                         (i_PS4_SMB_ALERT)                  , //addr 0x0016 bit6
.i_PS3_P12V_ON                                     (w_ps3_p12v_on_r)                  , //addr 0x0016 bit5
.i_PS4_P12V_ON                                     (w_ps4_p12v_on_r)                  , //addr 0x0016 bit4
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

//0x0021 //ocp_prsnt_n      //2024-6-3 add
.i_ocp1_prsnt_n                                    ( w_ocp_prsnt_n  ),                      //add 0x0021 bit7 default 1
// .i_ocp2_prsnt_n                                    ( w_ocp2_prsnt_n  ),                      //add 0x0021 bit6 default 1

//--0x0024
.i_PAL_TMP1_ALERT_N                             (i_PAL_TMP1_ALERT_N                   ),//addr 0x0024   bit7
.i_PAL_TMP2_ALERT_N                             (i_PAL_TMP2_ALERT_N                   ),//addr 0x0024   bit6
.i_PAL_TMP3_ALERT_N                             (i_PAL_TMP3_ALERT_N                   ),//addr 0x0024   bit5
.i_PAL_TMP4_ALERT_N                             (i_PAL_TMP4_ALERT_N                   ),//addr 0x0024   bit4
.i_OCP1_AUX_TMPALT_R                           (i_OCP1_AUX_TMPALT_R                ), //addr 0x0024   bit3
.i_NCSI_620F_THERMEL_ALERT_N           (i_NCSI_620F_THERMEL_ALERT_N), //addr 0x0024   bit2
.i_NCSI_620F_PG                                     (i_NCSI_620F_PG                          ), //addr 0x0024   bit1


//0X0028
.o_nic_act_flag                                     (w_nic_act_flag                     )    , //addr 0x0028 bit6 default 0
.o_sys_healthy_red                               (w_sys_healthy_red               )    , //addr 0x0028 bit5 default 0
.o_pal_mb_switch_en_n_r                     (w_pal_mb_switch_en_n_r     )    , //addr 0x0028 bit4 default 1
// .o_remote_xdp_debug_n_r                     (w_remote_xdp_debug_n_r     )    , //addr 0x0028 bit3 default 1
// .o_remote_xdp_tck_sel_r                     (w_remote_xdp_tck_sel_r     )    , //addr 0x0028 bit2 default 0
.o_pal_biosrom_io11                             (w_pal_biosrom_io11             )    , //addr 0x0028 bit1 default 1
.o_sys_healthy_grn                               (w_sys_healthy_grn               )    , //addr 0x0028 bit0 default 0

//--0x002b
.o_p12v_slot_3_on                                 (w_p12v_slot_3_on_r             )    , //addr 0x002b   bit7   default 1
.o_p12v_slot_4_on                                 (w_p12v_slot_4_on_r             )    , //addr 0x002b   bit6   default 1
.o_p12v_slot_5_on                                 (w_p12v_slot_5_on_r             )    , //addr 0x002b   bit5   default 1
.o_p12v_slot_6_on                                 (w_p12v_slot_6_on_r             )    , //addr 0x002b   bit4   default 1
.o_p12v_slot_7_on                                 (w_p12v_slot_7_on_r             )    , //addr 0x002b   bit3   default 1
.o_p12v_slot_8_on                                 (w_p12v_slot_8_on_r             )    , //addr 0x002b   bit2   default 1
.o_p12v_slot_9_on                                 (w_p12v_slot_9_on_r             )    , //addr 0x002b   bit1   default 1

//gpu_throttle -- 0x0030
.o_p0_mciop1a_gpu_throttle_n_r       (w_p0_mciop1a_gpu_throttle_n_r),    //addr 0x0030   bit7   default 1
.o_p0_mciop1c_gpu_throttle_n_r       (w_p0_mciop1c_gpu_throttle_n_r),    //addr 0x0030   bit6   default 1
.o_p0_mciop2a_gpu_throttle_n_r       (w_p0_mciop2a_gpu_throttle_n_r),    //addr 0x0030   bit5   default 1
.o_p0_mciop2c_gpu_throttle_n_r       (w_p0_mciop2c_gpu_throttle_n_r),    //addr 0x0030   bit4   default 1
.o_p0_mciop3a_gpu_throttle_n_r       (w_p0_mciop3a_gpu_throttle_n_r),    //addr 0x0030   bit3   default 1
.o_p0_mciop3c_gpu_throttle_n_r       (w_p0_mciop3c_gpu_throttle_n_r),    //addr 0x0030   bit2   default 1
.o_p0_mciog3a_gpu_throttle_n_r       (w_p0_mciog3a_gpu_throttle_n_r),    //addr 0x0030   bit1   default 1
.o_p0_mciog3c_gpu_throttle_n_r       (w_p0_mciog3c_gpu_throttle_n_r),    //addr 0x0030   bit0   default 1
//gpu_throttle -- 0x0031
.o_p1_mciop0a_gpu_throttle_n_r       (w_p1_mciop0a_gpu_throttle_n_r),    //addr 0x0031   bit7   default 1
.o_p1_mciop0c_gpu_throttle_n_r       (w_p1_mciop0c_gpu_throttle_n_r),    //addr 0x0031   bit6   default 1
.o_p1_mciop1a_gpu_throttle_n_r       (w_p1_mciop1a_gpu_throttle_n_r),    //addr 0x0031   bit5   default 1
.o_p1_mciop1c_gpu_throttle_n_r       (w_p1_mciop1c_gpu_throttle_n_r),    //addr 0x0031   bit4   default 1
.o_p1_mciop2a_gpu_throttle_n_r       (w_p1_mciop2a_gpu_throttle_n_r),    //addr 0x0031   bit3   default 1
.o_p1_mciop2c_gpu_throttle_n_r       (w_p1_mciop2c_gpu_throttle_n_r),    //addr 0x0031   bit2   default 1
.o_p1_mciop3a_gpu_throttle_n_r       (w_p1_mciop3a_gpu_throttle_n_r),    //addr 0x0031   bit1   default 1
.o_p1_mciop3c_gpu_throttle_n_r       (w_p1_mciop3c_gpu_throttle_n_r),    //addr 0x0031   bit0   default 1
//gpu_throttle -- 0x0032
.o_p1_mciog1a_gpu_throttle_n_r       (w_p1_mciog1a_gpu_throttle_n_r),    //addr 0x0032   bit7   default 1
.o_p1_mciog1c_gpu_throttle_n_r       (w_p1_mciog1c_gpu_throttle_n_r),    //addr 0x0032   bit6   default 1

//ocp ctl --0x0072
.o_pal_ocp_pwrbrk_od_n_flag             (w_pal_ocp_pwrbrk_od_n_flag     ) , //addr 0x0072 bit7   //default 0
.o_pal_ocp1_switch_en_n_r                 (w_ctl_pal_ocp1_switch_en_n_r ) , //addr 0x0072 bit6   //default 0 //2023-4-11
.o_pal_ocp_smrst_n_flag                     (w_pal_ocp_smrst_n_flag             ) , //addr 0x0072 bit5   //default 0
// .o_pal_ocp2_pwrbrk_od_n_flag            (w_pal_ocp2_pwrbrk_od_n_flag )                               , //addr 0x0072 bit4   //default 0 
// .o_pal_ocp2_switch_en_n_r               (w_ctl_pal_ocp2_switch_en_n_r    )                               , //addr 0x0072 bit3	//default 1
// .o_pal_ocp2_smrst_n_flag                (w_pal_ocp2_smrst_n_flag     )                               , //addr 0x0072 bit2	//default 0

.o_164_mr_n                             (w_164_mr_n           )             ,  //addr 0x008a bit7   //default 1

.o_164_test_data                        (w_164_test_data      )             ,  //addr 0x008c   //default 0x55

//0x008e
.i_LEAKAGE0_PRSNT_N                            (i_LEAKAGE0_PRSNT_N          ),    //addr 0x008e   bit6
.i_BREAK_DET_DO_N                                (i_BREAK_DET_DO_N              ),    //addr 0x008e   bit7
.i_LEAKAGE_DET_DO_N                            (i_LEAKAGE_DET_DO_N          ),    //addr 0x008e   bit5
.i_LEAKAGE_PRSNT1_N                            (i_LEAKAGE_PRSNT1_N          ),    //addr 0x008e   bit3
.i_BREAK_DET1_DO_N                              (i_BREAK_DET1_DO_N            ),    //addr 0x008e   bit4
.i_LEAKAGE_DET1_DO_N                          (i_LEAKAGE_DET1_DO_N        )      //addr 0x008e   bit2



);


endmodule



