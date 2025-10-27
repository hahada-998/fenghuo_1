//=================================================================================================
// Copyright(c) 
// Filename   : BM_H13DSP_M_TOP
// Project    : BM_H13DSP_M
// Author     : 
// Date       : 2025-01-07
//Simulator   : Lattice Diamond 3.12
//FPGA        : LCMXO3LF_6900C_5BG400C
// Email      : cloudnineinfo.com
// Company    : 
// Description: BM_H13DSP_M Top Code
// History    :
// Date      By          Revision  Change Description
//------------------------------------------------------------------------------
//-- Principle of Naming:
//-- In BM_H13DSP_M  : ONE CPLD,this Code for Master CPLD_U1
//-- CPLD     BOARD NAME            PCB CODE        BOARD ID     TAG NO    JTAG CON

//-- CPLD     BM_H13DSP_M      

//-------------------------------------------------------------------------------
//=================================================================================================
`include "BM_H13DSP_M_VA_PORT.v"
// `include "BM_H13DSP_define.vh" 
`include "pwrseq_define.vh" 
//---------------------------------------------------------
// define parameter
//--------------------------------------------------------
//Device Number 
`define NUM_CPU 2'h02		
`define NUM_PSU 3'h04

`define PRODUCT_ID                     8'h33
`define VENDER_ID                       8'h08

`define Year                                   8'h25
`define Month                                 8'h03
`define Day                                      8'h13
`define CPLD_VERSION                 8'h01
`define DEBUG_VERSION               8'h00

`define PRODUCT_LINE_C2	       8'h48
`define PRODUCT_GEN_ID_C3      8'h06
`define SERVER_ID_C5                  8'h41  //G7466
`define BOARD_ID_C6                    8'h01  

// `define PRODUCT_LINE_C2	       8'h48
// `define PRODUCT_GEN_ID_C3      8'h06
// `define SERVER_ID_C5                  8'h60  //G7666
// `define BOARD_ID_C6                    8'h01  

// `define PRODUCT_LINE_C2	         8'h40
// `define PRODUCT_GEN_ID_C3        8'h06
// `define SERVER_ID_C5                  8'h41  //G7466
// `define BOARD_ID_C6                    8'h01  
  
//--------------------------------------------------------------------------------------------------------------------------------------------------
//For pll_inst
//--------------------------------------------------------------------------------------------------------------------------------------------------
wire clk_50m ;
wire clk_25m ;
// wire clk_2p5m ;
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
  .CLKI     (i_CLK_25M_CPLD         ), //in
  .RST       (~i_PWRGD_P3V3_STBY ), //in  
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
  .pgd_p3v3_stby		        (i_PWRGD_P3V3_STBY	        ),	//in
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
.i2c1_scl	(io_I2C7_UPDATE_SCL	),
.i2c1_sda	(io_I2C7_UPDATE_SDA	)
); 
/************************************************************************************************************************************************************************/
//--------------------------------------------------------------------------------------------------------------------------------------------------
//I2C Update End
//--------------------------------------------------------------------------------------------------------------------------------------------------
/************************************************************************************************************************************************************************/
										   
//--------------------------------------------------------------------------------------------------------------------------------------------------
//For db_inst_amd_cpu_prsnt
//--------------------------------------------------------------------------------------------------------------------------------------------------
wire    [1:0]  db_cpu_prsnt_n			; 
wire    db_i_p0_spd_host_ctrl_n;
//--------------------------------------------------------------------------------------------------------------------------------------------------
//For cpu_module_u1:Assume the CPU is Present
//--------------------------------------------------------------------------------------------------------------------------------------------------
wire    w_cpu_module_en_n		;
wire    w_cpu_module_p0_pwrok	;
wire    w_cpu_module_p1_pwrok	;
wire    w_cpu_module_p0_pwrgdout	;
wire    w_cpu_module_p1_pwrgdout	;
wire    w_cpu_module_p0_slp_s3_n	;
wire    w_cpu_module_p0_slp_s5_n	;
wire    w_cpu_module_p0_prsnt_n	;
wire    w_cpu_module_p1_prsnt_n	;
//--------------------------------------------------------------------------------------------------------------------------------------------------
//for sync_cpu_data_low
//--------------------------------------------------------------------------------------------------------------------------------------------------
wire    db_i_p0_slp_s3_n	 ; 
wire    db_i_p0_slp_s5_n	 ;
wire    db_i_p1_slp_s3_n	 ; 
wire    db_i_p1_slp_s5_n	 ;
wire    db_i_p0_pwrok		 ;
wire    db_i_p1_pwrok		 ;
wire    db_i_p0_reset_n	 ;
wire    db_i_p1_reset_n	 ;
wire    db_i_p0_pwrgd_out	 ;
wire    db_i_p1_pwrgd_out	 ;
wire    db_i_p0_smerr_n	 ;  //unused
wire    db_i_p1_smerr_n	 ;  //unused
wire    db_i_p0_pcie_rst_n_0;
wire    db_i_p0_pcie_rst_n_1;
wire    db_i_p1_pcie_rst_n_0;
wire    db_i_p1_pcie_rst_n_1;
wire    db_i_p0_bios_post_stage_r_n;
//btn
wire    db_i_pal_pwr_btn_n	  ;
wire    db_i_pal_ext_rst_n	  ;
wire    db_i_pal_bmcuid_button;
//--------------------------------------------------------------------------------------------------------------------------------------------------
//for db_vr_ocp_low
//--------------------------------------------------------------------------------------------------------------------------------------------------
wire    db_i_p0_vdd_core_0_ocp_n_r	;
wire    db_i_pal_p0_vdd_core_1_ocp_n	;
wire    db_i_p0_vddio_ocp_n			;
wire    db_i_p1_vdd_core_0_ocp_n_r	;
wire    db_i_pal_p1_vdd_core_1_ocp_n	;
wire    db_i_p1_vddio_ocp_n			;
//psu
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
wire    w_ps4_prsnt                       ;
wire    w_ps3_prsnt                       ;
//--------------------------------------------------------------------------------------------------------------------------------------------------
//for db_alert  
//--------------------------------------------------------------------------------------------------------------------------------------------------
//I2C7 VR_Alert
wire    db_i_p0_vr_i2c7_alert_n		;
wire    db_i_p1_vr_i2c7_alert_n		;
//--------------------------------------------------------------------------------------------------------------------------------------------------
//for db_inst_pwrgood
//--------------------------------------------------------------------------------------------------------------------------------------------------
wire    db_i_pg_p12v_ssd_efuse			;
wire    db_i_p1v8_stby_pg				;//01
wire    db_i_pwrgd_p3v3_stby			;//02
wire    db_i_pg_p5v_stby				;//03
wire    db_i_pgd_p0_vdd_18_stby              ;//04
wire    db_i_pgd_p1_vdd_18_stby		;//05
wire    db_i_pgd_p0_vddc				;//06
wire    db_i_pgd_p1_vddc                            ;//07
wire    db_i_pgd_p0_vdd_11_sus		;//08
wire    db_i_pgd_p1_vdd_11_sus                ;//09
wire    db_i_pgd_p0_vdd_core_0		;//10
wire    db_i_pgd_p1_vdd_core_0		;//11
wire    db_i_pgd_p0_vdd_core_1		;//12
wire    db_i_pgd_p1_vdd_core_1		;//13
wire    db_i_pgd_p0_vdd_soc_0			;//14
wire    db_i_pgd_p1_vdd_soc_0			;//15
wire    db_i_pgd_p0_vddio				;//16
wire    db_i_pgd_p1_vddio				;//17
wire    db_i_pgd_p3v3_stby_b                    ;//18
wire    db_i_pgd_p1v2_stby                        ;//19
wire    db_i_pgd_p5v                                    ;//20
wire    w_p0_dimm_af_pcamp_r				;	
wire    w_p0_dimm_gl_pcamp_r				;	
wire    w_p1_dimm_af_pcamp_r				;	
wire    w_p1_dimm_gl_pcamp_r				;	
//--------------------------------------------------------------------------------------------------------------------------------------------------
//for cup_thermtrip 
//--------------------------------------------------------------------------------------------------------------------------------------------------   
wire    [1:0]   db_cpu_thermaltrip_n			; 
wire    [1:0]   cpu_thermtrip_fault_det		;
// wire amd_cpu_thrmtrip				;    
wire    w_cpu0_thermaltrip_clr			;
wire    w_cpu1_thermaltrip_clr			;
wire    w_cpupwrok_rise_dly2ms			;
wire    [1:0]   w_cpu_thermtrip_event			;
wire    w_cpu0_prochot					;	
wire    w_cpu1_prochot					;	
wire    w_force_allpwron_ctl			;	

//--------------------------------------------------------------------------------------------------------------------------------------------------
//for pwrseq_master_inst
//--------------------------------------------------------------------------------------------------------------------------------------------------
wire    [5:0]   w_power_seq_sm			;
wire    w_st_reset_state					;
wire    w_st_off_standby					;
wire    w_st_steady_pwrok				;
wire    w_st_halt_power_cycle			;
wire    w_st_aux_fail_recovery			;
wire    w_st_disable_grp_d_vddio			;	
wire    w_st_critical_fail				;	
wire    w_force_pwrbtn_n					;
wire    w_pgd_raw						;
wire    w_s5dev_aux_pwren_request		;
wire    w_s5dev_aux_pwrdis_request		;
wire    w_pgd_so_far						;
wire    w_any_pwr_fault_det				;
wire    w_any_lim_recov_fault			;
wire    w_any_non_recov_fault			;
wire    w_any_recov_fault				;
wire    w_dc_on_wait_complete			;	//out, TO SLAVE,
wire    w_rt_critical_fail_store		;
wire    w_fault_clear					;
wire    w_cmu_fault_clear				;	
wire    w_power_fault					;
wire    w_stby_failure_detected			;
wire    w_stb_pwron_tmout_fail_clr		;	
wire    w_stb_pwrdown_ukwn_fail_clr		;	
wire    w_poweron_tmout_fail_clr			;	
wire    w_dc_failure_detected			;
wire    w_rt_failure_detected			;
wire    w_cpld_latch_sys_off				;
wire    w_turn_on_wait					;
wire    w_power_on_fail_err_code_clr		;	
wire    w_power_down_fail_err_code_clr	;	
wire    w_keep_alive_on_fault			;

//--------------------------------------------------------------------------------------------------------------------------------------------------
//for pwrseq_slave_inst
//--------------------------------------------------------------------------------------------------------------------------------------------------
wire    w_all_power_pg			        ;
wire    w_all_stby_power_pg			    ;
wire    w_all_main_power_pg			    ;
wire    w_any_aux_vrm_fault			    ;
wire    w_cpu_sys_pwrok					;
wire    w_p5v_stby_en 					;
wire    w_p5v_stby_usb_en				;	
wire    w_grp_b_p0_33_s5_en				;
wire    w_grp_b_p1_33_s5_en				;
wire    w_grp_b_p0_18_s5_en				;
wire    w_grp_b_p1_18_s5_en				;
wire    w_p12_en							;
wire    w_p5v_en						;
wire    w_grp_c_p0_vdd11_en				;
wire    w_grp_c_p1_vdd11_en				;
wire    w_grp_d_p0_vddio_en				;
wire    w_grp_d_p1_vddio_en				;
wire    w_grp_d_p0_soc_en				;
wire    w_grp_d_p1_soc_en				;
wire    w_grp_d_p0_vddcore0_en			;
wire    w_grp_d_p1_vddcore0_en			;
wire    w_grp_d_p0_vddcore1_en			;
wire    w_grp_d_p1_vddcore1_en			;
wire    [5:0]   w_pwrseq_sm_fault_det		;
wire    w_p5v_stby_fault_det				;
wire    w_grp_c_p0_fault_det				;
wire    w_grp_d_vddio_p0_fault_det		;
wire    w_grp_d_soc_p0_fault_det			;
wire    w_grp_d_p0_vddcore0_fault_det	;
wire    w_grp_d_p0_vddcore1_fault_det	;
wire    w_grp_c_p1_fault_det				;
wire    w_grp_d_vddio_p1_fault_det		;
wire    w_grp_d_soc_p1_fault_det			;
wire    w_grp_d_p1_vddcore0_fault_det	;
wire    w_grp_d_p1_vddcore1_fault_det	;
wire    w_grp_b_p0_33_s5_fault_det		;
wire    w_grp_b_p0_18_s5_fault_det		;
wire    w_p3v3_stby_fault_det			;	
wire    w_p1v0_stby_m2_fault_det			;	
wire    w_p5v_fault_det					;
wire    [1:0]   w_cpu_pwrok					;
wire    w_cpu_pwr_good					;
wire    w_cpu1_pwr_good					;
wire    [1:0]   o_cpu_pwrok					;
wire    w_rsmrst_n						;
 
//--------------------------------------------------------------------------------------------------------------------------------------------------
//for bmc clear 
//--------------------------------------------------------------------------------------------------------------------------------------------------
wire    w_clr_cmos_done_rst		;
wire    w_clr_cmos_flg			;
wire    w_clr_cmos_done		;
wire    w_bmc_nmi_ctl			;
wire    w_bmc_nmi_ctl_done		;
wire    w_bmc_nmi_ctl_rst		;
wire    w_p0_nmi_sync_flood_n	;
wire    w_p1_nmi_sync_flood_n	;
wire    w_rtc_senor_sw			;
wire    w_ctl_scaled_bat_test_en_r;
wire    w_sys_debug_mode		;

//--------------------------------------------------------------------------------------------------------------------------------------------------
//for error code add 
//--------------------------------------------------------------------------------------------------------------------------------------------------
wire    [7:0]   r_pwrdrop_code			;
wire    [7:0]   r_timeout_code			;
wire    w_bmc_stby_failure_detected		;

//--------------------------------------------------------------------------------------------------------------------------------------------------
//for PCIe Rst
//--------------------------------------------------------------------------------------------------------------------------------------------------
wire    w_pcie_genz_rst_n_r			;

//--------------------------------------------------------------------------------------------------------------------------------------------------
//for Moc Rst
//--------------------------------------------------------------------------------------------------------------------------------------------------
wire    w_sm_steady_pwrok_state		;
wire    w_p0_prochot_n				;
wire    w_p1_prochot_n				;

//--------------------------------------------------------------------------------------------------------------------------------------------------
//for sgpio
//--------------------------------------------------------------------------------------------------------------------------------------------------
wire    w_uid_btn_n				;	
wire    w_eeprom_wp					; //disable write-protect 1:enable write-protect 0:disable write-protect
wire    w_ocp_aux_en					;
wire    w_ocp_main_en				;
wire    w_i3c_mux_en					; 
wire    w_i3c_remote_cs					; 
wire    w_bmc_i2c5_9548_rst_n		;
wire    w_bmc_i2c9_9548_1_rst_n		;
wire    w_bmc_i2c9_9548_2_rst_n		;
wire    w_bmc_i2c9_9548_3_rst_n		;
wire    w_bmc_i2c9_9548_4_rst_n		;
wire    w_p0_vpp_9545_1_rst_n		;
wire    w_p0_vpp_9545_2_rst_n		;
wire    w_p12v_stby_fault_det		;
wire    w_usb_ponrst_r_n				;
wire    w_tpcm_reset_n_reg			;
wire    w_jtag_cpld_bmc_ntrst_reg	;
wire    w_dimm_alarm_flag			;

//--------------------------------------------------------------------------------------------------------------------------------------------------
//for hitless 
//--------------------------------------------------------------------------------------------------------------------------------------------------
reg      [5:0]  r_power_seq_sm_fb			;	
wire    w_mux_sel						;	
wire    w_p0_sys_reset_r_n				;
wire    w_p0_kbrst_n						; 	
wire    w_p1_kbrst_n						; 	
wire    w_bmc_jtag_trst_r_n			;
// wire    w_pal_i3c_mux_en_r_n			;
wire    w_p0_pcie_wake_n_r			;
wire    w_p1_pcie_wake_n_r			;	
wire    w_pal_p0_vdd_core_0_soc_rst_l_n	;
wire    w_pal_p1_vdd_core_0_soc_rst_l_n	;
wire    w_pal_p0_vdd_core_1_11_sus_rst_l_n	;
wire    w_p1_vdd_core_1_11_sus_rst_l_n;
wire    w_pal_p0_vddio_rst_n				;
wire    w_p1_vddio_rst_l_n;

wire    [7:0]   w_p0_mciop0a_slot_id;
wire    [7:0]   w_p0_mciop0c_slot_id;
wire    [7:0]   w_p0_mciop1a_slot_id;//0
wire    [7:0]   w_p0_mciop1c_slot_id;//1
wire    [7:0]   w_p0_mciop2a_slot_id;//2
wire    [7:0]   w_p0_mciop2c_slot_id;//3
wire    [7:0]   w_p0_mciop3a_slot_id;//4
wire    [7:0]   w_p0_mciop3c_slot_id;//5
wire    [7:0]   w_p0_mciog3a_slot_id;//6
wire    [7:0]   w_p0_mciog3c_slot_id;//7
wire    [7:0]   w_p1_mciop0a_slot_id;//10
wire    [7:0]   w_p1_mciop0c_slot_id;//11
wire    [7:0]   w_p1_mciop1a_slot_id;//12
wire    [7:0]   w_p1_mciop1c_slot_id;//13
wire    [7:0]   w_p1_mciop2a_slot_id;//14
wire    [7:0]   w_p1_mciop2c_slot_id;//15
wire    [7:0]   w_p1_mciop3a_slot_id;//16
wire    [7:0]   w_p1_mciop3c_slot_id;//17
wire    [7:0]   w_p1_mciog1a_slot_id;//8
wire    [7:0]   w_p1_mciog1c_slot_id;//9

wire db_i_pwr_btn_cpld_n_r				;	//PWR BUTTON 
wire w_bmc_sbtn_reset_ctl			;
//DATA from S_CPLD (U247)
wire    [3:0]   w_board_id;
wire    [2:0]   w_pcb_version;
wire    [2:0]   w_pca_version;
wire    w_P1_MCIOP0A_CB_ID0_R;
wire    w_P1_MCIOP0A_CB_ID1_R;
wire    w_P1_MCIOP0C_CB_ID0_R;
wire    w_P1_MCIOP0C_CB_ID1_R;
wire    w_P1_MCIOP1A_CB_ID0_R;
wire    w_P1_MCIOP1A_CB_ID1_R;
wire    w_P1_MCIOP1C_CB_ID0_R;
wire    w_P1_MCIOP1C_CB_ID1_R;
wire    w_P1_MCIOP2A_CB_ID0_R;
wire    w_P1_MCIOP2A_CB_ID1_R;
wire    w_P1_MCIOP2C_CB_ID0_R;
wire    w_P1_MCIOP2C_CB_ID1_R;

wire    w_bmc_extrst_uid;
wire    w_usb2_lcd_oc_n;
wire    w_usb_inner_overcur3;

wire    w_PAL_BP1_PRSNT_N;
wire    w_PAL_BP2_PRSNT_N;
wire    w_PAL_BP3_PRSNT_N;
wire    w_PAL_BP4_PRSNT_N;
wire    w_PAL_BP5_PRSNT_N;
wire    w_PAL_BP8_PRSNT_N;
wire    w_uid_sw_in_n;
wire    w_ps1_p12v_on_r;
wire    w_ps2_p12v_on_r;
wire    w_FM_P12V_EN;
wire    w_PWRGD_P12V_PS3_PS4;
wire    w_PWRGD_P12V;
wire    w_PS3_PS4_ACFAIL;
wire    w_pal_ps_off_r;
wire    w_pal_dual_en_r;
wire    w_clk_gen_en_r_n;
wire    w_pal_db2000_1_pwrgd_r;
wire    w_pal_db2000_2_pwrgd_r;
wire    w_clk_db2000_1_1_oe_n;
wire    w_clk_db2000_1_2_oe_n;
wire    w_fm_pld_db800_3_clks_dev_en_r;
wire    w_clk_db800_3_1_oe_n_r;
wire    w_clk_db800_3_2_oe_n_r;
wire    w_pal_bmc_srst_n_r;
wire    w_p12v_slot_0_on;
wire    w_p12v_slot_1_on;
wire    w_p12v_slot_2_on;
wire    w_slot_0_on_dly_10ms;
wire    w_slot_1_on_dly_10ms;
wire    w_slot_2_on_dly_10ms;
wire    w_p12v_slot_0_on_r;
wire    w_p12v_slot_1_on_r;
wire    w_p12v_slot_2_on_r;
wire    w_p0_mciop0a_gpu_throttle_n_r;
wire    w_p0_mciop0c_gpu_throttle_n_r;
wire    w_p0_pcie_wake_n;
wire    w_p1_pcie_wake_n;
wire    [7:0]   w_led_control;
wire    w_p5v_vga2_en_n_r;
wire    w_pal_p5v_en_r;
wire    w_pal_bmc_aux_pgd;
wire    w_p1v0_stby_m2_en;

wire    w_cpld_sgpio0_clk_r;
wire    w_cpld_sgpio0_ld_n_r;
wire    w_cpld_sgpio0_mosi_r;
wire    w_cpld_sgpio1_clk_r;
wire    w_cpld_sgpio1_ld_n_r;
wire    w_cpld_sgpio1_mosi_r;
wire    w_PAL_OCP1_PRSNT_B3_N;//2025-03-06 add

wire    w_BREAK_DET_DO_N      ;
wire    w_LEAKAGE0_PRSNT_N  ;
wire    w_LEAKAGE_DET_DO_N  ;
wire    w_BREAK_DET1_DO_N    ;
wire    w_LEAKAGE_PRSNT1_N  ;
wire    w_LEAKAGE_DET1_DO_N;
wire    [1:0]   w_bf_type;
//-------------------------------------------------------------------------------------------------
//Switch1 & ZT1 BOARD
//-------------------------------------------------------------------------------------------------
wire w_tpm431_alert_n_sw       ; //u7
wire w_ina3221_pwr_alert_sw    ; //u7
wire w_pal_3v3_pgd1_r_sw       ; //u7
wire w_pal_3v3_pgd2_r_sw       ; //u7
wire w_pal_3v3_pgd3_r_sw       ; //u7
wire w_pal_3v3_pgd4_r_sw       ; //u7
wire w_pal_3v3_pgd5_r_sw       ; //u7
wire w_u3_nc7_sw               ; //u7

wire w_slot1_prsnt_n_sw        ; //u9
wire w_slot2_prsnt_n_sw        ; //u9
wire w_slot3_prsnt_n_sw        ; //u9
wire w_slot4_prsnt_n_sw        ; //u9
wire w_slot5_prsnt_n_sw        ; //u9
wire w_slot6_prsnt_n_sw        ; //u9
wire w_slot7_prsnt_n_sw        ; //u9
wire w_slot8_prsnt_n_sw        ; //u9

wire w_slot9_prsnt_n_sw        ; //u10
wire w_slot10_prsnt_n_sw       ; //u10
wire w_slot11_prsnt_n_sw       ; //u10
wire w_slot12_prsnt_n_sw       ; //u10
wire w_slot13_prsnt_n_sw       ; //u10
wire w_mcio1_prsnt_n_sw        ; //u10
wire w_mcio2_prsnt_n_sw        ; //u10
wire w_mcio3_prsnt_n_sw        ; //u10

wire w_mcio4_prsnt_n_sw        ; //u38
wire w_mcio5_prsnt_n_sw        ; //u38
wire w_mcio6_prsnt_n_sw        ; //u38
wire w_mcio7_prsnt_n_sw        ; //u38
wire w_mcio8_prsnt_n_sw        ; //u38
wire w_mcio9_prsnt_n_sw        ; //u38
wire w_mcio10_prsnt_n_sw       ; //u38
wire w_mcio11_prsnt_n_sw       ; //u38

wire w_mcio12_prsnt_n_sw       ; //u5
wire w_mcio13_prsnt_n_sw       ; //u5
wire w_pcb_version2_sw         ; //u5
wire w_pcb_version1_sw         ; //u5
wire w_pcb_version0_sw         ; //u5
wire w_pca_version2_sw         ; //u5
wire w_pca_version1_sw         ; //u5
wire w_pca_version0_sw         ; //u5

wire w_board_id0_sw            ;  //u6
wire w_board_id1_sw            ;  //u6
wire w_board_id2_sw            ;  //u6
wire w_board_id3_sw            ;  //u6
wire w_board_id4_sw            ;  //u6
wire w_board_id5_sw            ;  //u6
wire w_board_id6_sw            ;  //u6
wire w_board_id7_sw            ;  //u6

wire w_ct_p1v25_sw0_pg_sw      ; //u41
wire w_ct_p1v25_sw1_pg_sw      ; //u41
wire w_p0v8_sw0_pwrgd_sw       ; //u41
wire w_p0v8_sw1_pwrgd_sw       ; //u41
wire w_slot1_wake_n_sw         ; //u41
wire w_slot2_wake_n_sw         ; //u41
wire w_slot3_wake_n_sw         ; //u41
wire w_slot4_wake_n_sw         ; //u41

wire w_slot5_wake_n_sw         ; //u44
wire w_slot6_wake_n_sw         ; //u44
wire w_slot7_wake_n_sw         ; //u44
wire w_slot8_wake_n_sw         ; //u44
wire w_slot9_wake_n_sw         ; //u44
wire w_slot10_wake_n_sw        ; //u44
wire w_slot11_wake_n_sw        ; //u44
wire w_slot12_wake_n_sw        ; //u44

// wire w_pal_p12v_drop_sw            ; //u40
// wire w_pg_p5v0_r_sw                ; //u40
// wire w_pg_p1v8_r_sw                ; //u40
// wire w_pg_p1v8_pll_r_sw            ; //u40
// wire w_db2000_pwrgd0_sw            ; //u40
// wire w_db2000_pwrgd1_sw            ; //u40
// wire w_mcio_slot13_prsnt_n_1_sw    ; //u40
// wire w_u40_nc7_sw                  ; //u40
//zt
wire w_tpm431_alert_n_zt       ;//u3
wire w_ina3221_pwr_alert_zt    ;//u3
wire w_pal_3v3_pgd1_r_zt       ;//u3
wire w_pal_3v3_pgd2_r_zt       ;//u3
wire w_pal_3v3_pgd3_r_zt       ;//u3
wire w_pal_3v3_pgd4_r_zt       ;//u3
wire w_pal_3v3_pgd5_r_zt       ;//u3
wire w_u3_nc7_zt               ;//u3

wire w_slot1_prsnt_n_zt        ;//u7
wire w_slot2_prsnt_n_zt        ;//u7
wire w_slot3_prsnt_n_zt        ;//u7
wire w_slot4_prsnt_n_zt        ;//u7
wire w_slot5_prsnt_n_zt        ;//u7
wire w_slot6_prsnt_n_zt        ;//u7
wire w_slot7_prsnt_n_zt        ;//u7
wire w_slot8_prsnt_n_zt        ;//u7
//in ZT BOARD                           
wire w_slot9_prsnt_n_zt        ;//u8    
wire w_slot10_prsnt_n_zt       ;//u8    
wire w_slot11_prsnt_n_zt       ;//u8    
wire w_slot12_prsnt_n_zt       ;//u8    
wire w_slot13_prsnt_n_zt       ;//u8    
wire w_mcio1_prsnt_n_zt        ;//u8    
wire w_mcio2_prsnt_n_zt        ;//u8    
wire w_mcio3_prsnt_n_zt        ;//u8    

wire w_mcio4_prsnt_n_zt        ;//u4    
wire w_mcio5_prsnt_n_zt        ;//u4    
wire w_mcio6_prsnt_n_zt        ;//u4    
wire w_mcio7_prsnt_n_zt        ;//u4    
wire w_mcio8_prsnt_n_zt        ;//u4    
wire w_mcio9_prsnt_n_zt        ;//u4    
wire w_mcio10_prsnt_n_zt       ;//u4    
wire w_mcio11_prsnt_n_zt       ;//u4    

wire w_mcio12_prsnt_n_zt       ;//u5    
wire w_mcio13_prsnt_n_zt       ;//u5    
wire w_pcb_version2_zt         ;//u5    
wire w_pcb_version1_zt         ;//u5    
wire w_pcb_version0_zt         ;//u5    
wire w_pca_version2_zt         ;//u5    
wire w_pca_version1_zt         ;//u5    
wire w_pca_version0_zt         ;//u5    
 
wire w_board_id0_zt            ;//u6    
wire w_board_id1_zt            ;//u6    
wire w_board_id2_zt            ;//u6    
wire w_board_id3_zt            ;//u6    
wire w_board_id4_zt            ;//u6    
wire w_board_id5_zt            ;//u6    
wire w_board_id6_zt            ;//u6    
wire w_board_id7_zt            ;//u6    
  
wire w_mcio1_prsnt_n_1_zt      ;//u18   
wire w_mcio2_prsnt_n_1_zt      ;//u18   
wire w_mcio3_prsnt_n_1_zt      ;//u18   
wire w_mcio4_prsnt_n_1_zt      ;//u18   
wire w_mcio5_prsnt_n_1_zt      ;//u18   
wire w_mcio7_prsnt_n_1_zt      ;//u18   
wire w_mcio9_prsnt_n_1_zt      ;//u18   
wire w_mcio10_prsnt_n_1_zt     ;//u18   

wire w_mcio11_prsnt_n_1_zt     ;//u19   
wire w_mcio12_prsnt_n_1_zt     ;//u19   
wire w_u19_nc2_zt              ;//u19   
wire w_u19_nc3_zt              ;//u19   
wire w_u19_nc4_zt              ;//u19   
wire w_u19_nc5_zt              ;//u19   
wire w_u19_nc6_zt              ;//u19   
wire w_u19_nc7_zt              ;//u19   

wire [5:0]pvti_zt_count;
wire w_pwr_on_dly2s;
wire w_pwr_on_dly1s5;  
wire [2:0]pvti_sw_u2_count1;

reg r_board_id0_zt     ;
reg r_board_id1_zt     ;
reg r_board_id2_zt     ;
reg r_board_id3_zt     ;
reg r_board_id4_zt     ;
reg r_board_id5_zt     ;
reg r_board_id6_zt     ;
reg r_board_id7_zt     ;

reg r_pcb_version2_zt  ;
reg r_pcb_version1_zt  ;
reg r_pcb_version0_zt  ;
reg r_pca_version2_zt  ;
reg r_pca_version1_zt  ;
reg r_pca_version0_zt  ;

reg r_mcio9_prsnt_n_zt ;
reg r_mcio7_prsnt_n_zt ;
reg r_mcio3_prsnt_n_zt ;
reg r_mcio1_prsnt_n_zt ;

reg r_mcio10_prsnt_n_zt ; //2024-9-24
reg r_mcio8_prsnt_n_zt  ; //2024-9-24
reg r_mcio6_prsnt_n_zt  ; //2024-9-24
reg r_mcio4_prsnt_n_zt  ; //2024-9-24
reg r_zt_board_prsnt_n      ;
reg     [7:0]   r_switch_mode;

wire [7:0]   w_zt_board_id;
wire [7:0]   w_sw_board_id;
wire    w_zt_board_prsnt_n;

wire w_mcio_slot11_prsnt_n_1 ;
wire w_mcio_slot9_prsnt_n    ;
wire w_mcio_slot9_prsnt_n_1  ;
wire w_mcio_slot11_prsnt_n   ;
wire w_mcio_slot13_prsnt_n_1 ;

//-------------------------------------------------------------------------------------------------
//Switch2 & ZT2 BOARD
//-------------------------------------------------------------------------------------------------
wire    w_tpm431_alert_n_sw2       ; //u7
wire    w_ina3221_pwr_alert_sw2    ; //u7
wire    w_pal_3v3_pgd1_r_sw2       ; //u7
wire    w_pal_3v3_pgd2_r_sw2       ; //u7
wire    w_pal_3v3_pgd3_r_sw2       ; //u7
wire    w_pal_3v3_pgd4_r_sw2       ; //u7
wire    w_pal_3v3_pgd5_r_sw2       ; //u7
wire    w_u3_nc7_sw2               ; //u7

wire    w_slot1_prsnt_n_sw2        ; //u9
wire    w_slot2_prsnt_n_sw2        ; //u9
wire    w_slot3_prsnt_n_sw2        ; //u9
wire    w_slot4_prsnt_n_sw2        ; //u9
wire    w_slot5_prsnt_n_sw2        ; //u9
wire    w_slot6_prsnt_n_sw2        ; //u9
wire    w_slot7_prsnt_n_sw2        ; //u9
wire    w_slot8_prsnt_n_sw2        ; //u9

wire    w_slot9_prsnt_n_sw2        ; //u10
wire    w_slot10_prsnt_n_sw2       ; //u10
wire    w_slot11_prsnt_n_sw2       ; //u10
wire    w_slot12_prsnt_n_sw2       ; //u10
wire    w_slot13_prsnt_n_sw2       ; //u10
wire    w_mcio1_prsnt_n_sw2        ; //u10
wire    w_mcio2_prsnt_n_sw2        ; //u10
wire    w_mcio3_prsnt_n_sw2        ; //u10

wire    w_mcio4_prsnt_n_sw2        ; //u38
wire    w_mcio5_prsnt_n_sw2        ; //u38
wire    w_mcio6_prsnt_n_sw2        ; //u38
wire    w_mcio7_prsnt_n_sw2        ; //u38
wire    w_mcio8_prsnt_n_sw2        ; //u38
wire    w_mcio9_prsnt_n_sw2        ; //u38
wire    w_mcio10_prsnt_n_sw2       ; //u38
wire    w_mcio11_prsnt_n_sw2       ; //u38

wire    w_mcio12_prsnt_n_sw2       ; //u5
wire    w_mcio13_prsnt_n_sw2       ; //u5
wire    w_pcb_version2_sw2         ; //u5
wire    w_pcb_version1_sw2         ; //u5
wire    w_pcb_version0_sw2         ; //u5
wire    w_pca_version2_sw2         ; //u5
wire    w_pca_version1_sw2         ; //u5
wire    w_pca_version0_sw2         ; //u5

wire    w_board_id0_sw2            ;  //u6
wire    w_board_id1_sw2            ;  //u6
wire    w_board_id2_sw2            ;  //u6
wire    w_board_id3_sw2            ;  //u6
wire    w_board_id4_sw2            ;  //u6
wire    w_board_id5_sw2            ;  //u6
wire    w_board_id6_sw2            ;  //u6
wire    w_board_id7_sw2            ;  //u6

wire    w_ct_p1v25_sw0_pg_sw2      ; //u41
wire    w_ct_p1v25_sw1_pg_sw2      ; //u41
wire    w_p0v8_sw0_pwrgd_sw2       ; //u41
wire    w_p0v8_sw1_pwrgd_sw2       ; //u41
wire    w_slot1_wake_n_sw2         ; //u41
wire    w_slot2_wake_n_sw2         ; //u41
wire    w_slot3_wake_n_sw2         ; //u41
wire    w_slot4_wake_n_sw2         ; //u41

wire    w_slot5_wake_n_sw2         ; //u44
wire    w_slot6_wake_n_sw2         ; //u44
wire    w_slot7_wake_n_sw2         ; //u44
wire    w_slot8_wake_n_sw2         ; //u44
wire    w_slot9_wake_n_sw2         ; //u44
wire    w_slot10_wake_n_sw2        ; //u44
wire    w_slot11_wake_n_sw2        ; //u44
wire    w_slot12_wake_n_sw2        ; //u44

wire    w_pal_p12v_drop_sw2            ; //u40
wire    w_pg_p5v0_r_sw2                ; //u40
wire    w_pg_p1v8_r_sw2                ; //u40
wire    w_pg_p1v8_pll_r_sw2            ; //u40
wire    w_db2000_pwrgd0_sw2            ; //u40
wire    w_db2000_pwrgd1_sw2            ; //u40
wire    w_mcio_slot13_prsnt_n_1_sw2    ; //u40
wire    w_u40_nc7_sw2                  ; //u40
//zt2
wire    w_tpm431_alert_n_zt2       ;//u3
wire    w_ina3221_pwr_alert_zt2    ;//u3
wire    w_pal_3v3_pgd1_r_zt2       ;//u3
wire    w_pal_3v3_pgd2_r_zt2       ;//u3
wire    w_pal_3v3_pgd3_r_zt2       ;//u3
wire    w_pal_3v3_pgd4_r_zt2       ;//u3
wire    w_pal_3v3_pgd5_r_zt2       ;//u3
wire    w_u3_nc7_zt2               ;//u3

wire    w_slot1_prsnt_n_zt2        ;//u7
wire    w_slot2_prsnt_n_zt2        ;//u7
wire    w_slot3_prsnt_n_zt2        ;//u7
wire    w_slot4_prsnt_n_zt2        ;//u7
wire    w_slot5_prsnt_n_zt2        ;//u7
wire    w_slot6_prsnt_n_zt2        ;//u7
wire    w_slot7_prsnt_n_zt2        ;//u7
wire    w_slot8_prsnt_n_zt2        ;//u7
//in ZT BOARD                           
wire    w_slot9_prsnt_n_zt2        ;//u8    
wire    w_slot10_prsnt_n_zt2       ;//u8    
wire    w_slot11_prsnt_n_zt2       ;//u8    
wire    w_slot12_prsnt_n_zt2       ;//u8    
wire    w_slot13_prsnt_n_zt2       ;//u8    
wire    w_mcio1_prsnt_n_zt2        ;//u8    
wire    w_mcio2_prsnt_n_zt2        ;//u8    
wire    w_mcio3_prsnt_n_zt2        ;//u8 
   
wire    w_mcio4_prsnt_n_zt2        ;//u4    
wire    w_mcio5_prsnt_n_zt2        ;//u4    
wire    w_mcio6_prsnt_n_zt2        ;//u4    
wire    w_mcio7_prsnt_n_zt2        ;//u4    
wire    w_mcio8_prsnt_n_zt2        ;//u4    
wire    w_mcio9_prsnt_n_zt2        ;//u4    
wire    w_mcio10_prsnt_n_zt2       ;//u4    
wire    w_mcio11_prsnt_n_zt2       ;//u4 
   
wire    w_mcio12_prsnt_n_zt2       ;//u5    
wire    w_mcio13_prsnt_n_zt2       ;//u5    
wire    w_pcb_version2_zt2         ;//u5    
wire    w_pcb_version1_zt2         ;//u5    
wire    w_pcb_version0_zt2         ;//u5    
wire    w_pca_version2_zt2         ;//u5    
wire    w_pca_version1_zt2         ;//u5    
wire    w_pca_version0_zt2         ;//u5  
  
wire    w_board_id0_zt2            ;//u6    
wire    w_board_id1_zt2            ;//u6    
wire    w_board_id2_zt2            ;//u6    
wire    w_board_id3_zt2            ;//u6    
wire    w_board_id4_zt2            ;//u6    
wire    w_board_id5_zt2            ;//u6    
wire    w_board_id6_zt2            ;//u6    
wire    w_board_id7_zt2            ;//u6   
  
wire    w_mcio1_prsnt_n_1_zt2      ;//u18   
wire    w_mcio2_prsnt_n_1_zt2      ;//u18   
wire    w_mcio3_prsnt_n_1_zt2      ;//u18   
wire    w_mcio4_prsnt_n_1_zt2      ;//u18   
wire    w_mcio5_prsnt_n_1_zt2      ;//u18   
wire    w_mcio7_prsnt_n_1_zt2      ;//u18   
wire    w_mcio9_prsnt_n_1_zt2      ;//u18   
wire    w_mcio10_prsnt_n_1_zt2     ;//u18 
  
wire    w_mcio11_prsnt_n_1_zt2     ;//u19   
wire    w_mcio12_prsnt_n_1_zt2     ;//u19   
wire    w_u19_nc2_zt2              ;//u19   
wire    w_u19_nc3_zt2              ;//u19   
wire    w_u19_nc4_zt2              ;//u19   
wire    w_u19_nc5_zt2              ;//u19   
wire    w_u19_nc6_zt2              ;//u19   
wire    w_u19_nc7_zt2              ;//u19   

reg      r_board_id0_zt2     ;
reg      r_board_id1_zt2     ;
reg      r_board_id2_zt2     ;
reg      r_board_id3_zt2     ;
reg      r_board_id4_zt2     ;
reg      r_board_id5_zt2     ;
reg      r_board_id6_zt2     ;
reg      r_board_id7_zt2     ;
reg      r_pcb_version2_zt2  ;
reg      r_pcb_version1_zt2  ;
reg      r_pcb_version0_zt2  ;
reg      r_pca_version2_zt2  ;
reg      r_pca_version1_zt2  ;
reg      r_pca_version0_zt2  ;
reg      r_mcio9_prsnt_n_zt2 ;
reg      r_mcio7_prsnt_n_zt2 ;
reg      r_mcio3_prsnt_n_zt2 ;
reg      r_mcio1_prsnt_n_zt2 ;
reg      r_mcio10_prsnt_n_zt2 ; //2024-9-24
reg      r_mcio8_prsnt_n_zt2  ; //2024-9-24
reg      r_mcio6_prsnt_n_zt2  ; //2024-9-24
reg      r_mcio4_prsnt_n_zt2  ; //2024-9-24

wire    w_zt2_mcio_slot11_prsnt_n_1 ;
wire    w_zt2_mcio_slot9_prsnt_n    ;
wire    w_zt2_mcio_slot9_prsnt_n_1  ;
wire    w_zt2_mcio_slot11_prsnt_n   ;
wire    w_zt2_mcio_slot13_prsnt_n_1 ;
wire    [5:0]   pvti_zt2_count;
wire    [2:0]   pvti_sw2_u2_count1;
wire    [7:0]   w_zt2_board_id;
wire    [7:0]   w_sw2_board_id;
reg      [7:0]   r_switch2_mode;
reg      r_zt2_board_prsnt_n      ;
wire    w_zt2_board_prsnt_n;

wire    w_bmc_jtag_mux_s;
//------------------------------------------------------------------------------------------------//
//SIGNAL DEBOUNCE
//------------------------------------------------------------------------------------------------//
PGM_DEBOUNCE #(.SIGCNT(3), .NBITS(2'b10), .ENABLE(1'b1)) db_inst_pwr_btn(
  .clk(clk_50m),
  .rst(~pon_reset_n),
  .timer_tick(t32ms_tick),
  .din({
		i_PAL_PWR_BTN_N     ,//01
                i_PAL_BUTTOPN_RST_N ,//02
                i_PAL_BMCUID_BUTTON //03
	   }),             
  .dout({
		db_i_pwr_btn_cpld_n_r ,//01
                db_i_pal_ext_rst_n  ,//02
                db_i_pal_bmcuid_button  //03
       }) 
);
//--------------------------------------------------------------------------------------------------------------------------------------------------
//VR OCP Signal DEBOUNCE
//--------------------------------------------------------------------------------------------------------------------------------------------------
PGM_DEBOUNCE #(.SIGCNT(6), .NBITS(2'b10), .ENABLE(1'b1)) db_vr_ocp_low (
  .clk(clk_50m),
  .rst(~pon_reset_n),
  .timer_tick(t64ms_tick),
  .din({
			i_P0_VDD_CORE_0_OCP_N_R			,//01
			i_PAL_P0_VDD_CORE_1_OCP_N		,//02
			i_P0_VDDIO_OCP_N			 	,//03
                        i_P1_VDD_CORE_0_OCP_N_R			,//04
			i_PAL_P1_VDD_CORE_1_OCP_N		,//05
			i_P1_VDDIO_OCP_N			 	  //06                 
  }),             
  .dout({
			db_i_p0_vdd_core_0_ocp_n_r		,//01
			db_i_pal_p0_vdd_core_1_ocp_n	,//02
			db_i_p0_vddio_ocp_n				,//03
                        db_i_p1_vdd_core_0_ocp_n_r		,//04
			db_i_pal_p1_vdd_core_1_ocp_n	,//05
			db_i_p1_vddio_ocp_n				  //06                      
  }) 
);
//-------------------------------------------------------------------------------------------------
// for PSU Signal DEBOUNCE        8 Signal
// ------------------------------------------------------------------------------------------------
PGM_DEBOUNCE #(.SIGCNT(10), .NBITS(2'b10), .ENABLE(1'b1)) db_inst_psu (
  .clk(clk_50m),
  .rst(~pon_reset_n),
  .timer_tick(t64ms_tick),
  .din({
                 i_PS1_PRSNT                    ,   //01
                 i_PS1_DCOK_N                  ,   //02
                 i_PS1_SMB_ALERT            ,   //03
                 i_PS1_ACFAIL_N              ,   //04
                 i_PS2_PRSNT                    ,   //05
                 i_PS2_DCOK_N                  ,   //06
                 i_PS2_SMB_ALERT            ,   //07
                 i_PS2_ACFAIL_N              ,   //08
                 w_ps3_prsnt                    ,   //09
                 w_ps4_prsnt                         //10
  }),
  .dout({
                 db_i_ps1_prsnt              ,   //01
                 db_i_ps1_dcok_n            ,   //02
                 db_i_ps1_smb_alert      ,   //03
                 db_i_ps1_acfail_n        ,   //04
                 db_i_ps2_prsnt              ,   //05
                 db_i_ps2_dcok_n            ,   //06
                 db_i_ps2_smb_alert      ,   //07
                 db_i_ps2_acfail_n        ,   //08
                 db_i_ps3_prsnt              ,   //09
                 db_i_ps4_prsnt                   //10
  })
);
//--------------------------------------------------------------------------------------------------------------------------------------------------
//CPU Signal DEBOUNCE
//--------------------------------------------------------------------------------------------------------------------------------------------------
//Active Low Reset
SYNC_DATA_N #(.SIGCNT(17)) sync_cpu_data_low (
  .clk    (clk_50m),
  .rst_n  (pon_reset_n),          
  .din    ({
			(i_P0_SLP_S3_N | w_cpu_module_p0_slp_s3_n)	,//01
			(i_P0_SLP_S5_N | w_cpu_module_p0_slp_s5_n)	,//02
                        i_P1_SLP_S3_N						        ,//03//unused
                        i_P1_SLP_S5_N						        ,//04//unused
			i_P0_PWROK								,//05//& cpu_module_p0_pwrok)	, 
 			i_P1_PWROK								,//06//& cpu_module_p1_pwrok)	, 
			i_P0_RESET_N							,//07
			i_P1_RESET_N							,//08
			i_P0_PWRGD_OUT							,//09//| cpu_module_p0_pwrgdout),           
			i_P1_PWRGD_OUT							,//10//| cpu_module_p1_pwrgdout), 
			i_P0_SMERR_N							,//11//unused
			i_P1_SMERR_N							,//12//unused
			i_P0_PCIE_RST_N_0						,//13
			i_P0_PCIE_RST_N_1						,//14
			i_P1_PCIE_RST_N_0						,//15
			i_P1_PCIE_RST_N_1						,//16
			i_P0_BIOS_POST_STAGE_R_N				  //17
			}),			
  .dout   ({
			db_i_p0_slp_s3_n			,//01
			db_i_p0_slp_s5_n			,//02
			db_i_p1_slp_s3_n			,//03//unused
			db_i_p1_slp_s5_n			,//04//unused            
			db_i_p0_pwrok				,//05
			db_i_p1_pwrok				,//06
			db_i_p0_reset_n				,//07
			db_i_p1_reset_n				,//08
			db_i_p0_pwrgd_out			,//09
			db_i_p1_pwrgd_out			,//10
			db_i_p0_smerr_n				,//11//unused
			db_i_p1_smerr_n				,//12//unused
			db_i_p0_pcie_rst_n_0		,//13
			db_i_p0_pcie_rst_n_1		,//14
			db_i_p1_pcie_rst_n_0		,//15
			db_i_p1_pcie_rst_n_1		,//16
			db_i_p0_bios_post_stage_r_n	  //17
			})      
);
//--------------------------------------------------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------------------------------------------------
//cpu thermtrip Signal DEBOUNCE															
//--------------------------------------------------------------------------------------------------------------------------------------------------
PGM_DEBOUNCE #(.SIGCNT(4), .NBITS(2'b10), .ENABLE(1'b1)) db_cpu_thermtrip (
  .clk(clk_50m),
  .rst(~pon_reset_n),
  .timer_tick(1'b1),
  .din({
		 i_P0_VR_I2C7_ALERT_N	,//01
                 i_P1_VR_I2C7_ALERT_N	,//02
	         i_P0_THERMTRIP_N               ,//03
	         i_P1_THERMTRIP_N                 //04

  }),             
  .dout({
		 db_i_p0_vr_i2c7_alert_n	        ,//01
		 db_i_p1_vr_i2c7_alert_n	        ,//02
                 db_cpu_thermaltrip_n[0]         ,//03 
                 db_cpu_thermaltrip_n[1]           //04 
  }) 
);
//--------------------------------------------------------------------------------------------------------------------------------------------------
// PWRGOOD DEBOUNCE
//--------------------------------------------------------------------------------------------------------------------------------------------------
PGM_DEBOUNCE_N #(.SIGCNT(21), .NBITS(2'b11), .ENABLE(1'b1)) db_inst_pwrgood (
  .clk			(clk_50m),
  .rst_n		(pon_reset_n),
  .timer_tick	(1'b1),
  .din({
             i_P1V8_STBY_PG				,//01
             i_PWRGD_P3V3_STBY			        ,//02
             i_PG_P5V_STBY				        ,//03
             i_PGD_P0_VDD_18_STBY                   ,//04
             i_PGD_P1_VDD_18_STBY		        ,//05
             i_PGD_P0_VDDC				        ,//06 	
             i_PGD_P1_VDDC                                 ,//07
             i_PGD_P0_VDD_11_SUS		        ,//08
             i_PGD_P1_VDD_11_SUS                     ,//09
             i_PGD_P0_VDD_CORE_0		        ,//10
             i_PGD_P1_VDD_CORE_0		        ,//11
             i_PGD_P0_VDD_CORE_1		        ,//12
             i_PGD_P1_VDD_CORE_1		        ,//13
             i_PGD_P0_VDD_SOC_0			,//14
             i_PGD_P1_VDD_SOC_0			,//15
             i_PGD_P0_VDDIO				,//16
             i_PGD_P1_VDDIO				,//17
             i_PGD_P3V3_STBY_B                         ,//18
             i_PGD_P1V2_STBY                             ,//19
             i_PGD_P5V                                         ,//20
             i_PG_P1V0_STBY_M2_R
	 }),             
  .dout({
             db_i_p1v8_stby_pg				,//01
             db_i_pwrgd_p3v3_stby			,//02
             db_i_pg_p5v_stby				,//03
             db_i_pgd_p0_vdd_18_stby             ,//04
             db_i_pgd_p1_vdd_18_stby		,//05
             db_i_pgd_p0_vddc				,//06
             db_i_pgd_p1_vddc                           ,//07
             db_i_pgd_p0_vdd_11_sus		,//08
             db_i_pgd_p1_vdd_11_sus               ,//09
             db_i_pgd_p0_vdd_core_0		,//10
             db_i_pgd_p1_vdd_core_0		,//11
             db_i_pgd_p0_vdd_core_1		,//12
             db_i_pgd_p1_vdd_core_1		,//13
             db_i_pgd_p0_vdd_soc_0			,//14
             db_i_pgd_p1_vdd_soc_0			,//15
             db_i_pgd_p0_vddio				,//16
             db_i_pgd_p1_vddio				,//17
             db_i_pgd_p3v3_stby_b                   ,//18
             db_i_pgd_p1v2_stby                       ,//19
             db_i_pgd_p5v                                   ,//20
             db_i_pg_p1v0_stby_m2_r
	  }) 
);
//--------------------------------------------------------------------------------------------------------------------------------------------------
// DEVICE PRSNT
//--------------------------------------------------------------------------------------------------------------------------------------------------
//Active High Reset
PGM_DEBOUNCE #(.SIGCNT(3), .NBITS (2'b11), .ENABLE(1'b1)) db_inst_amd_cpu_prsnt(   
  .clk(clk_50m),
  .timer_tick(t512us_tick),
  .rst(~pon_reset_n),
  .din({  
                (i_P0_PRSNT_N & cpu_module_p0_prsnt_n) ,	//01 
                (i_P1_PRSNT_N & cpu_module_p1_prsnt_n)  ,  //02 
                i_P0_SPD_HOST_CTRL_N				        //03
	  }),  
  .dout({	  
                db_cpu_prsnt_n[0],   //01
                db_cpu_prsnt_n[1],   //02
                db_i_p0_spd_host_ctrl_n            //03
		})
);
// --------------------------------------------------------------------------------------------------------------------------------------------------
// for P12V_DROOP DEBOUNCE  2 Signal
// --------------------------------------------------------------------------------------------------------------------------------------------------
PGM_DEBOUNCE #(.SIGCNT(2), .NBITS(2'b10), .ENABLE(1'b1)) db_p12v_droop (
  .clk(clk_50m),
  .rst(~pon_reset_n),
  .timer_tick(t64ms_tick),
  .din({
             i_PGD_P12V_DROOP            , //1
             i_PGD_P12V_STBY_DROOP         //2
  }),
  .dout({
             db_i_pgd_p12v_droop         , //1
             db_i_pgd_p12v_stby_droop      //2
  })
);

wire    w_pgd_p12v_droop_neg;
reg      r_p12v_discharge_r;
wire    w_p12v_discharge_r;

Edge_Detect Edge_Detect_U1(    //2023-3-9 add 
    .i_clk               (clk_50m),        
    .i_rst_n             (pon_reset_n),       
    .i_signal            (i_PGD_P12V_DROOP),//i_PGD_P12V_DROOP  w_PWRGD_P12V
    
    .o_signal_pos        (),
    .o_signal_neg        (w_pgd_p12v_droop_neg),
    .o_signal_invert     ()
);

always@(posedge clk_50m or negedge pon_reset_n) begin
	if(~pon_reset_n) begin
        r_p12v_discharge_r <= 1'b0;
	end
	else if(w_pgd_p12v_droop_neg) begin
        r_p12v_discharge_r <= 1'b1;
	end
end
assign  w_p12v_discharge_r = r_p12v_discharge_r;

//SN74LV165     PVT_DATA
//U152_DATA
wire    w_P0_MCIOP0C_CB_ID1_R;
wire    w_P0_MCIOP0C_CB_ID0_R;
wire    w_P0_MCIOP0A_CB_ID1_R;
wire    w_P0_MCIOP0A_CB_ID0_R;
wire    w_P0_MCIOP1C_CB_ID1_R;
wire    w_P0_MCIOP1C_CB_ID0_R;
wire    w_P0_MCIOP1A_CB_ID1_R;
wire    w_P0_MCIOP1A_CB_ID0_R;
//U153_DATA
wire    w_P0_MCIOP2A_CB_ID0_R;
wire    w_P0_MCIOP2A_CB_ID1_R;
wire    w_P0_MCIOP2C_CB_ID0_R;
wire    w_P0_MCIOP2C_CB_ID1_R;
wire    w_P0_MCIOP3C_CB_ID1_R;
wire    w_P0_MCIOP3C_CB_ID0_R;
wire    w_P0_MCIOP3A_CB_ID1_R;
wire    w_P0_MCIOP3A_CB_ID0_R;
//U154_DATA
wire    w_P1_MCIOG1A_CB_ID0_R;
wire    w_P1_MCIOG1A_CB_ID1_R;
wire    w_P1_MCIOG1C_CB_ID0_R;
wire    w_P1_MCIOG1C_CB_ID1_R;
wire    w_P0_MCIOG3A_CB_ID0_R;
wire    w_P0_MCIOG3A_CB_ID1_R;
wire    w_P0_MCIOG3C_CB_ID0_R;
wire    w_P0_MCIOG3C_CB_ID1_R;
//U155_DATA
wire    w_SW_1;
wire    w_SW_2;
wire    w_SW_3;
wire    w_SW_4;
wire    w_SW_5;
wire    w_SW_6;
wire    w_SW_7;
wire    w_SW_8;
//U156_DATA
wire    w_PAL_BP4_AUX_PG;
wire    w_PAL_STBY_FAN_SHTDN;
wire    w_PG_P12V_SLOT_9;
wire    w_PG_P12V_SLOT_7;
wire    w_PAL_BP6_PRSNT_N;
wire    w_P1_MCIOP4A_CB_ID1_R;
wire    w_PG_P12V_SLOT_3;
wire    w_PAL_OCP1_HP_BUTTON_N;
//U157_DATA
wire    w_PG_P12V_SLOT_6;
wire    w_FAN_PRSNT_R;
wire    w_PAL_SLIMSAS1_PRSNT_N;
wire    w_NODE1_TYPE;
wire    w_PAL_MEN_CPU_SHTDN;
wire    w_PAL_S5_CPU_SHTDN;
wire    w_U157_NC_G;
wire    w_U157_NC_H;
//U158_DATA
wire    w_P1_MCIOP3C_CB_ID1_R;
wire    w_P1_MCIOP3C_CB_ID0_R;
wire    w_P1_MCIOP3A_CB_ID1_R;
wire    w_P1_MCIOP3A_CB_ID0_R;
wire    w_OCP1_CABLE_PRSNT_R ;
wire    w_PAL_OCP1_PRSNT_B1_N;
wire    w_PAL_OCP1_PRSNT_B2_N;
wire    w_PAL_OCP1_PRSNT_B0_N;
//U159_DATA
wire    w_U159_NC_A;
wire    w_U159_NC_B;
wire    w_U159_NC_C;
wire    w_U159_NC_D;
wire    w_PAL_M2_0_PRSNT_N;
wire    w_NCSI_PRSNT_N;
wire    w_BMC_CARD_PRSNT_N;
wire    w_PAL_M2_1_PRSNT_N;

wire [6:0]pvti_ss_count;

pvt_gpi #(
  .TOTAL_BIT_COUNT(64),
  .DEFAULT_STATE(64'h0),
  .NUMBER_OF_COUNTER_BITS(7)
) pvt_gpi_MB_inst (
  .clk           (clk_50m),          //in
  .reset_n       (pon_reset_n),      //in
  .clk_ena       (t16us_tick),       //in
  .serclk_in     (o_PVT_SS_CLK_R),   //in
  .par_load_in_n (o_PVT_SS_LD_N_R),  //in
  .sdi           (i_PVT_SS_DATI  ),  //in
  .bit_idx_in    (pvti_ss_count),    //in
  .bit_idx_out   (pvti_ss_count),    //out
  .serclk_out    (o_PVT_SS_CLK_R ),  //out
  .par_load_out_n(o_PVT_SS_LD_N_R),  //out

  .par_data      ({w_P0_MCIOP0C_CB_ID1_R,w_P0_MCIOP0C_CB_ID0_R,w_P0_MCIOP0A_CB_ID1_R,w_P0_MCIOP0A_CB_ID0_R,
                              w_P0_MCIOP1C_CB_ID1_R,w_P0_MCIOP1C_CB_ID0_R,w_P0_MCIOP1A_CB_ID1_R,w_P0_MCIOP1A_CB_ID0_R,        //u152_data
                              
                              w_P0_MCIOP2A_CB_ID0_R,w_P0_MCIOP2A_CB_ID1_R,w_P0_MCIOP2C_CB_ID0_R,w_P0_MCIOP2C_CB_ID1_R,
                              w_P0_MCIOP3C_CB_ID1_R,w_P0_MCIOP3C_CB_ID0_R,w_P0_MCIOP3A_CB_ID1_R,w_P0_MCIOP3A_CB_ID0_R,      //u153_data
                              
                              w_P1_MCIOG1A_CB_ID0_R,w_P1_MCIOG1A_CB_ID1_R,w_P1_MCIOG1C_CB_ID0_R,w_P1_MCIOG1C_CB_ID1_R,
                              w_P0_MCIOG3A_CB_ID0_R,w_P0_MCIOG3A_CB_ID1_R,w_P0_MCIOG3C_CB_ID0_R,w_P0_MCIOG3C_CB_ID1_R,        //u154_data
                              
                              w_SW_1,w_SW_2,w_SW_3,w_SW_4,
                              w_SW_5,w_SW_6,w_SW_7,w_SW_8,      //u155_data
                              
                              w_PAL_BP4_AUX_PG,w_PAL_STBY_FAN_SHTDN,w_PG_P12V_SLOT_9,w_PG_P12V_SLOT_7,
                              w_PAL_BP6_PRSNT_N,w_P1_MCIOP4A_CB_ID1_R,w_PG_P12V_SLOT_3,w_PAL_OCP1_HP_BUTTON_N,      //u156_data
                              
                              w_PG_P12V_SLOT_6,w_FAN_PRSNT_R,w_PAL_SLIMSAS1_PRSNT_N,w_NODE1_TYPE,
                              w_PAL_MEN_CPU_SHTDN,w_PAL_S5_CPU_SHTDN,w_U157_NC_G,w_U157_NC_H,      //u157_data
                              
                              w_P1_MCIOP3C_CB_ID1_R,w_P1_MCIOP3C_CB_ID0_R,w_P1_MCIOP3A_CB_ID1_R,w_P1_MCIOP3A_CB_ID0_R,
                              w_OCP1_CABLE_PRSNT_R,w_PAL_OCP1_PRSNT_B1_N,w_PAL_OCP1_PRSNT_B2_N,w_PAL_OCP1_PRSNT_B0_N,      //u158_data
                              
                              w_U159_NC_A,w_U159_NC_B,w_U159_NC_C,w_U159_NC_D,
                              w_PAL_M2_0_PRSNT_N,w_NCSI_PRSNT_N,w_BMC_CARD_PRSNT_N,w_PAL_M2_1_PRSNT_N            //u159_data                              
                              
                              })
);
//-------------------------------------------------------------------------------------------------//
wire    w_ocp_prsnt_n;


//-------------------------------------------------------------------------------------------------
//M_CPLD TO S_CPLD SGPIO    START
//-------------------------------------------------------------------------------------------------
//DATA TO S_CPLD (U247)


//-------------------------------------------------------------------------------------------------
// CPLD_U247 SGPIO data
// ------------------------------------------------------------------------------------------------
wire [199:0] mcpld_to_scpld_p2s_data   ; //2024-8-2 chg 159 to 199
wire [199:0] scpld_to_mcpld_s2p_data   ;

reg [191:0]	scpld_to_mcpld_data_filter;
reg 	    scpld_sgpio_fail          ;


//scpld ---> mcpld
assign  w_bf_type[1]                               = scpld_to_mcpld_data_filter[172]            ;
assign  w_bf_type[0]                               = scpld_to_mcpld_data_filter[171]            ;
assign  w_BREAK_DET_DO_N                       = scpld_to_mcpld_data_filter[170]            ;
assign  w_LEAKAGE0_PRSNT_N                   = scpld_to_mcpld_data_filter[169]            ;
assign  w_LEAKAGE_DET_DO_N                   = scpld_to_mcpld_data_filter[168]            ;
assign  w_BREAK_DET1_DO_N                     = scpld_to_mcpld_data_filter[167]            ;
assign  w_LEAKAGE_PRSNT1_N                   = scpld_to_mcpld_data_filter[166]            ;
assign  w_LEAKAGE_DET1_DO_N                 = scpld_to_mcpld_data_filter[165]            ;

assign  w_PAL_OCP1_PRSNT_B3_N             = scpld_to_mcpld_data_filter[164]            ;
assign  w_uid_sw_in_n                             = scpld_to_mcpld_data_filter[163]            ;

assign  w_PAL_BP1_PRSNT_N                     = scpld_to_mcpld_data_filter[162]            ;
assign  w_PAL_BP2_PRSNT_N                     = scpld_to_mcpld_data_filter[161]            ;
assign  w_PAL_BP3_PRSNT_N                     = scpld_to_mcpld_data_filter[160]            ;
assign  w_PAL_BP4_PRSNT_N                     = scpld_to_mcpld_data_filter[159]            ;
assign  w_PAL_BP5_PRSNT_N                     = scpld_to_mcpld_data_filter[158]            ;
assign  w_PAL_BP8_PRSNT_N                     = scpld_to_mcpld_data_filter[157]            ;

assign  w_p0_mciop1a_slot_id[7]         = scpld_to_mcpld_data_filter[156]            ;
assign  w_p0_mciop1a_slot_id[6]         = scpld_to_mcpld_data_filter[155]            ;
assign  w_p0_mciop1a_slot_id[5]         = scpld_to_mcpld_data_filter[154]            ;
assign  w_p0_mciop1a_slot_id[4]         = scpld_to_mcpld_data_filter[153]            ;
assign  w_p0_mciop1a_slot_id[3]         = scpld_to_mcpld_data_filter[152]            ;
assign  w_p0_mciop1a_slot_id[2]         = scpld_to_mcpld_data_filter[151]            ;
assign  w_p0_mciop1a_slot_id[1]         = scpld_to_mcpld_data_filter[150]            ;

assign  w_p0_mciop1c_slot_id[7]         = scpld_to_mcpld_data_filter[149]            ;
assign  w_p0_mciop1c_slot_id[6]         = scpld_to_mcpld_data_filter[148]            ;
assign  w_p0_mciop1c_slot_id[5]         = scpld_to_mcpld_data_filter[147]            ;
assign  w_p0_mciop1c_slot_id[4]         = scpld_to_mcpld_data_filter[146]            ;
assign  w_p0_mciop1c_slot_id[3]         = scpld_to_mcpld_data_filter[145]            ;
assign  w_p0_mciop1c_slot_id[2]         = scpld_to_mcpld_data_filter[144]            ;
assign  w_p0_mciop1c_slot_id[1]         = scpld_to_mcpld_data_filter[143]            ;

assign  w_p0_mciop2a_slot_id[7]         = scpld_to_mcpld_data_filter[142]            ;
assign  w_p0_mciop2a_slot_id[6]         = scpld_to_mcpld_data_filter[141]            ;
assign  w_p0_mciop2a_slot_id[5]         = scpld_to_mcpld_data_filter[140]            ;
assign  w_p0_mciop2a_slot_id[4]         = scpld_to_mcpld_data_filter[139]            ;
assign  w_p0_mciop2a_slot_id[3]         = scpld_to_mcpld_data_filter[138]            ;
assign  w_p0_mciop2a_slot_id[2]         = scpld_to_mcpld_data_filter[137]            ;
assign  w_p0_mciop2a_slot_id[1]         = scpld_to_mcpld_data_filter[136]            ;

assign  w_p0_mciop2c_slot_id[7]         = scpld_to_mcpld_data_filter[135]            ;
assign  w_p0_mciop2c_slot_id[6]         = scpld_to_mcpld_data_filter[134]            ;
assign  w_p0_mciop2c_slot_id[5]         = scpld_to_mcpld_data_filter[133]            ;
assign  w_p0_mciop2c_slot_id[4]         = scpld_to_mcpld_data_filter[132]            ;
assign  w_p0_mciop2c_slot_id[3]         = scpld_to_mcpld_data_filter[131]            ;
assign  w_p0_mciop2c_slot_id[2]         = scpld_to_mcpld_data_filter[130]            ;
assign  w_p0_mciop2c_slot_id[1]         = scpld_to_mcpld_data_filter[129]            ;

assign  w_p0_mciop3a_slot_id[7]         = scpld_to_mcpld_data_filter[128]            ;
assign  w_p0_mciop3a_slot_id[6]         = scpld_to_mcpld_data_filter[127]            ;
assign  w_p0_mciop3a_slot_id[5]         = scpld_to_mcpld_data_filter[126]            ;
assign  w_p0_mciop3a_slot_id[4]         = scpld_to_mcpld_data_filter[125]            ;
assign  w_p0_mciop3a_slot_id[3]         = scpld_to_mcpld_data_filter[124]            ;
assign  w_p0_mciop3a_slot_id[2]         = scpld_to_mcpld_data_filter[123]            ;
assign  w_p0_mciop3a_slot_id[1]         = scpld_to_mcpld_data_filter[122]            ;

assign  w_p0_mciop3c_slot_id[7]         = scpld_to_mcpld_data_filter[121]            ;
assign  w_p0_mciop3c_slot_id[6]         = scpld_to_mcpld_data_filter[120]            ;
assign  w_p0_mciop3c_slot_id[5]         = scpld_to_mcpld_data_filter[119]            ;
assign  w_p0_mciop3c_slot_id[4]         = scpld_to_mcpld_data_filter[118]            ;
assign  w_p0_mciop3c_slot_id[3]         = scpld_to_mcpld_data_filter[117]            ;
assign  w_p0_mciop3c_slot_id[2]         = scpld_to_mcpld_data_filter[116]            ;
assign  w_p0_mciop3c_slot_id[1]         = scpld_to_mcpld_data_filter[115]            ;

assign  w_p0_mciog3a_slot_id[7]         = scpld_to_mcpld_data_filter[114]            ;
assign  w_p0_mciog3a_slot_id[6]         = scpld_to_mcpld_data_filter[113]            ;
assign  w_p0_mciog3a_slot_id[5]         = scpld_to_mcpld_data_filter[112]            ;
assign  w_p0_mciog3a_slot_id[4]         = scpld_to_mcpld_data_filter[111]            ;
assign  w_p0_mciog3a_slot_id[3]         = scpld_to_mcpld_data_filter[110]            ;
assign  w_p0_mciog3a_slot_id[2]         = scpld_to_mcpld_data_filter[109]            ;
assign  w_p0_mciog3a_slot_id[1]         = scpld_to_mcpld_data_filter[108]            ;

assign  w_p0_mciog3c_slot_id[7]         = scpld_to_mcpld_data_filter[107]            ;
assign  w_p0_mciog3c_slot_id[6]         = scpld_to_mcpld_data_filter[106]            ;
assign  w_p0_mciog3c_slot_id[5]         = scpld_to_mcpld_data_filter[105]            ;
assign  w_p0_mciog3c_slot_id[4]         = scpld_to_mcpld_data_filter[104]            ;
assign  w_p0_mciog3c_slot_id[3]         = scpld_to_mcpld_data_filter[103]            ;
assign  w_p0_mciog3c_slot_id[2]         = scpld_to_mcpld_data_filter[102]            ;
assign  w_p0_mciog3c_slot_id[1]         = scpld_to_mcpld_data_filter[101]            ;

assign  w_p1_mciog1a_slot_id[7]         = scpld_to_mcpld_data_filter[100]            ;
assign  w_p1_mciog1a_slot_id[6]         = scpld_to_mcpld_data_filter[99]            ;
assign  w_p1_mciog1a_slot_id[5]         = scpld_to_mcpld_data_filter[98]            ;
assign  w_p1_mciog1a_slot_id[4]         = scpld_to_mcpld_data_filter[97]            ;
assign  w_p1_mciog1a_slot_id[3]         = scpld_to_mcpld_data_filter[96]            ;
assign  w_p1_mciog1a_slot_id[2]         = scpld_to_mcpld_data_filter[95]            ;
assign  w_p1_mciog1a_slot_id[1]         = scpld_to_mcpld_data_filter[94]            ;

assign  w_p1_mciog1c_slot_id[7]         = scpld_to_mcpld_data_filter[93]            ;
assign  w_p1_mciog1c_slot_id[6]         = scpld_to_mcpld_data_filter[92]            ;
assign  w_p1_mciog1c_slot_id[5]         = scpld_to_mcpld_data_filter[91]            ;
assign  w_p1_mciog1c_slot_id[4]         = scpld_to_mcpld_data_filter[90]            ;
assign  w_p1_mciog1c_slot_id[3]         = scpld_to_mcpld_data_filter[89]            ;
assign  w_p1_mciog1c_slot_id[2]         = scpld_to_mcpld_data_filter[88]            ;
assign  w_p1_mciog1c_slot_id[1]         = scpld_to_mcpld_data_filter[87]            ;

assign  w_p1_mciop0a_slot_id[7]         = scpld_to_mcpld_data_filter[86]            ;
assign  w_p1_mciop0a_slot_id[6]         = scpld_to_mcpld_data_filter[85]            ;
assign  w_p1_mciop0a_slot_id[5]         = scpld_to_mcpld_data_filter[84]            ;
assign  w_p1_mciop0a_slot_id[4]         = scpld_to_mcpld_data_filter[83]            ;
assign  w_p1_mciop0a_slot_id[3]         = scpld_to_mcpld_data_filter[82]            ;
assign  w_p1_mciop0a_slot_id[2]         = scpld_to_mcpld_data_filter[81]            ;
assign  w_p1_mciop0a_slot_id[1]         = scpld_to_mcpld_data_filter[80]            ;

assign  w_p1_mciop0c_slot_id[7]         = scpld_to_mcpld_data_filter[79]            ;
assign  w_p1_mciop0c_slot_id[6]         = scpld_to_mcpld_data_filter[78]            ;
assign  w_p1_mciop0c_slot_id[5]         = scpld_to_mcpld_data_filter[77]            ;
assign  w_p1_mciop0c_slot_id[4]         = scpld_to_mcpld_data_filter[76]            ;
assign  w_p1_mciop0c_slot_id[3]         = scpld_to_mcpld_data_filter[75]            ;
assign  w_p1_mciop0c_slot_id[2]         = scpld_to_mcpld_data_filter[74]            ;
assign  w_p1_mciop0c_slot_id[1]         = scpld_to_mcpld_data_filter[73]            ;

assign  w_p1_mciop1a_slot_id[7]         = scpld_to_mcpld_data_filter[72]            ;
assign  w_p1_mciop1a_slot_id[6]         = scpld_to_mcpld_data_filter[71]            ;
assign  w_p1_mciop1a_slot_id[5]         = scpld_to_mcpld_data_filter[70]            ;
assign  w_p1_mciop1a_slot_id[4]         = scpld_to_mcpld_data_filter[69]            ;
assign  w_p1_mciop1a_slot_id[3]         = scpld_to_mcpld_data_filter[68]            ;
assign  w_p1_mciop1a_slot_id[2]         = scpld_to_mcpld_data_filter[67]            ;
assign  w_p1_mciop1a_slot_id[1]         = scpld_to_mcpld_data_filter[66]            ;

assign  w_p1_mciop1c_slot_id[7]         = scpld_to_mcpld_data_filter[65]            ;
assign  w_p1_mciop1c_slot_id[6]         = scpld_to_mcpld_data_filter[64]            ;
assign  w_p1_mciop1c_slot_id[5]         = scpld_to_mcpld_data_filter[63]            ;
assign  w_p1_mciop1c_slot_id[4]         = scpld_to_mcpld_data_filter[62]            ;
assign  w_p1_mciop1c_slot_id[3]         = scpld_to_mcpld_data_filter[61]            ;
assign  w_p1_mciop1c_slot_id[2]         = scpld_to_mcpld_data_filter[60]            ;
assign  w_p1_mciop1c_slot_id[1]         = scpld_to_mcpld_data_filter[59]            ;

assign  w_p1_mciop2a_slot_id[7]         = scpld_to_mcpld_data_filter[58]            ;
assign  w_p1_mciop2a_slot_id[6]         = scpld_to_mcpld_data_filter[57]            ;
assign  w_p1_mciop2a_slot_id[5]         = scpld_to_mcpld_data_filter[56]            ;
assign  w_p1_mciop2a_slot_id[4]         = scpld_to_mcpld_data_filter[55]            ;
assign  w_p1_mciop2a_slot_id[3]         = scpld_to_mcpld_data_filter[54]            ;
assign  w_p1_mciop2a_slot_id[2]         = scpld_to_mcpld_data_filter[53]            ;
assign  w_p1_mciop2a_slot_id[1]         = scpld_to_mcpld_data_filter[52]            ;

assign  w_p1_mciop2c_slot_id[7]         = scpld_to_mcpld_data_filter[51]            ;
assign  w_p1_mciop2c_slot_id[6]         = scpld_to_mcpld_data_filter[50]            ;
assign  w_p1_mciop2c_slot_id[5]         = scpld_to_mcpld_data_filter[49]            ;
assign  w_p1_mciop2c_slot_id[4]         = scpld_to_mcpld_data_filter[48]            ;
assign  w_p1_mciop2c_slot_id[3]         = scpld_to_mcpld_data_filter[47]            ;
assign  w_p1_mciop2c_slot_id[2]         = scpld_to_mcpld_data_filter[46]            ;
assign  w_p1_mciop2c_slot_id[1]         = scpld_to_mcpld_data_filter[45]            ;

assign  w_p1_mciop3a_slot_id[7]         = scpld_to_mcpld_data_filter[44]            ;
assign  w_p1_mciop3a_slot_id[6]         = scpld_to_mcpld_data_filter[43]            ;
assign  w_p1_mciop3a_slot_id[5]         = scpld_to_mcpld_data_filter[42]            ;
assign  w_p1_mciop3a_slot_id[4]         = scpld_to_mcpld_data_filter[41]            ;
assign  w_p1_mciop3a_slot_id[3]         = scpld_to_mcpld_data_filter[40]            ;
assign  w_p1_mciop3a_slot_id[2]         = scpld_to_mcpld_data_filter[39]            ;
assign  w_p1_mciop3a_slot_id[1]         = scpld_to_mcpld_data_filter[38]            ;

assign  w_p1_mciop3c_slot_id[7]         = scpld_to_mcpld_data_filter[37]            ;
assign  w_p1_mciop3c_slot_id[6]         = scpld_to_mcpld_data_filter[36]            ;
assign  w_p1_mciop3c_slot_id[5]         = scpld_to_mcpld_data_filter[35]            ;
assign  w_p1_mciop3c_slot_id[4]         = scpld_to_mcpld_data_filter[34]            ;
assign  w_p1_mciop3c_slot_id[3]         = scpld_to_mcpld_data_filter[33]            ;
assign  w_p1_mciop3c_slot_id[2]         = scpld_to_mcpld_data_filter[32]            ;
assign  w_p1_mciop3c_slot_id[1]         = scpld_to_mcpld_data_filter[31]            ;

assign  w_P1_MCIOP2C_CB_ID1_R             = scpld_to_mcpld_data_filter[30]            ;
assign  w_P1_MCIOP2C_CB_ID0_R             = scpld_to_mcpld_data_filter[29]            ;
assign  w_P1_MCIOP2A_CB_ID1_R             = scpld_to_mcpld_data_filter[28]            ;
assign  w_P1_MCIOP2A_CB_ID0_R             = scpld_to_mcpld_data_filter[27]            ;

assign  w_P1_MCIOP1C_CB_ID1_R             = scpld_to_mcpld_data_filter[26]            ;
assign  w_P1_MCIOP1C_CB_ID0_R             = scpld_to_mcpld_data_filter[25]            ;
assign  w_P1_MCIOP1A_CB_ID1_R             = scpld_to_mcpld_data_filter[24]            ;
assign  w_P1_MCIOP1A_CB_ID0_R             = scpld_to_mcpld_data_filter[23]            ;

assign  w_P1_MCIOP0C_CB_ID1_R             = scpld_to_mcpld_data_filter[22]            ;
assign  w_P1_MCIOP0C_CB_ID0_R             = scpld_to_mcpld_data_filter[21]            ;
assign  w_P1_MCIOP0A_CB_ID1_R             = scpld_to_mcpld_data_filter[20]            ;
assign  w_P1_MCIOP0A_CB_ID0_R             = scpld_to_mcpld_data_filter[19]            ;

assign  w_pcb_version[2]                       = scpld_to_mcpld_data_filter[18]            ;
assign  w_pcb_version[1]                       = scpld_to_mcpld_data_filter[17]            ;
assign  w_pcb_version[0]                       = scpld_to_mcpld_data_filter[16]            ;

assign  w_pca_version[2]                       = scpld_to_mcpld_data_filter[15]            ;
assign  w_pca_version[1]                       = scpld_to_mcpld_data_filter[14]            ;
assign  w_pca_version[0]                       = scpld_to_mcpld_data_filter[13]            ;

assign  w_board_id[3]                             = scpld_to_mcpld_data_filter[12]            ;
assign  w_board_id[2]                             = scpld_to_mcpld_data_filter[11]            ;
assign  w_board_id[1]                             = scpld_to_mcpld_data_filter[10]            ;
assign  w_board_id[0]                             = scpld_to_mcpld_data_filter[9]            ;

assign  w_usb2_lcd_oc_n                         = scpld_to_mcpld_data_filter[8]            ;
assign  w_usb_inner_overcur3               = scpld_to_mcpld_data_filter[7]            ;
assign  w_bmc_extrst_uid                       = scpld_to_mcpld_data_filter[6]            ;
assign  w_p1_pcie_wake_n_r                   = scpld_to_mcpld_data_filter[5]            ;
assign  w_p0_pcie_wake_n_r                   = scpld_to_mcpld_data_filter[4]            ;
assign  w_PWRGD_P12V_PS3_PS4               = scpld_to_mcpld_data_filter[3]            ;
assign  w_PS3_PS4_ACFAIL                       = scpld_to_mcpld_data_filter[2]            ;
assign  w_ps4_prsnt                                 = scpld_to_mcpld_data_filter[1]            ;
assign  w_ps3_prsnt                                 = scpld_to_mcpld_data_filter[0]            ;

wire    w_usb_sw_s;
wire    w_bmc_ready_flag                   ;
//mcpld ---> scpld
assign  mcpld_to_scpld_p2s_data[199]      = 1'b1                                       ;
assign  mcpld_to_scpld_p2s_data[198]      = 1'b0                                       ;
assign  mcpld_to_scpld_p2s_data[197]      = 1'b1                                       ;
assign  mcpld_to_scpld_p2s_data[196]      = 1'b0                                       ;
assign  mcpld_to_scpld_p2s_data[195:56]   = 'b0                                        ;

assign  mcpld_to_scpld_p2s_data[55]        = w_SW_2        ;

assign  mcpld_to_scpld_p2s_data[54]        = w_P1_MCIOP3C_CB_ID1_R        ;
assign  mcpld_to_scpld_p2s_data[53]        = w_P1_MCIOP3C_CB_ID0_R        ;
assign  mcpld_to_scpld_p2s_data[52]        = w_P1_MCIOP3A_CB_ID1_R        ;
assign  mcpld_to_scpld_p2s_data[51]        = w_P1_MCIOP3A_CB_ID0_R        ;

assign  mcpld_to_scpld_p2s_data[50]        = w_P1_MCIOG1C_CB_ID1_R        ;
assign  mcpld_to_scpld_p2s_data[49]        = w_P1_MCIOG1C_CB_ID0_R        ;
assign  mcpld_to_scpld_p2s_data[48]        = w_P1_MCIOG1A_CB_ID1_R        ;
assign  mcpld_to_scpld_p2s_data[47]        = w_P1_MCIOG1A_CB_ID0_R        ;

assign  mcpld_to_scpld_p2s_data[46]        = w_P0_MCIOP3C_CB_ID1_R        ;
assign  mcpld_to_scpld_p2s_data[45]        = w_P0_MCIOP3C_CB_ID0_R        ;
assign  mcpld_to_scpld_p2s_data[44]        = w_P0_MCIOP3A_CB_ID1_R        ;
assign  mcpld_to_scpld_p2s_data[43]        = w_P0_MCIOP3A_CB_ID0_R        ;
                                                              
assign  mcpld_to_scpld_p2s_data[42]        = w_P0_MCIOP2C_CB_ID1_R        ;
assign  mcpld_to_scpld_p2s_data[41]        = w_P0_MCIOP2C_CB_ID0_R        ;
assign  mcpld_to_scpld_p2s_data[40]        = w_P0_MCIOP2A_CB_ID1_R        ;
assign  mcpld_to_scpld_p2s_data[39]        = w_P0_MCIOP2A_CB_ID0_R        ;

assign  mcpld_to_scpld_p2s_data[38]        = w_P0_MCIOP1C_CB_ID1_R        ;
assign  mcpld_to_scpld_p2s_data[37]        = w_P0_MCIOP1C_CB_ID0_R        ;
assign  mcpld_to_scpld_p2s_data[36]        = w_P0_MCIOP1A_CB_ID1_R        ;
assign  mcpld_to_scpld_p2s_data[35]        = w_P0_MCIOP1A_CB_ID0_R        ;
                                                              
assign  mcpld_to_scpld_p2s_data[34]        = w_P0_MCIOG3C_CB_ID1_R        ;
assign  mcpld_to_scpld_p2s_data[33]        = w_P0_MCIOG3C_CB_ID0_R        ;
assign  mcpld_to_scpld_p2s_data[32]        = w_P0_MCIOG3A_CB_ID1_R        ;
assign  mcpld_to_scpld_p2s_data[31]        = w_P0_MCIOG3A_CB_ID0_R        ;

assign  mcpld_to_scpld_p2s_data[30]        = w_led_control[7];
assign  mcpld_to_scpld_p2s_data[29]        = w_led_control[6];
assign  mcpld_to_scpld_p2s_data[28]        = w_led_control[5];
assign  mcpld_to_scpld_p2s_data[27]        = w_led_control[4];
assign  mcpld_to_scpld_p2s_data[26]        = w_led_control[3];
assign  mcpld_to_scpld_p2s_data[25]        = w_led_control[2];
assign  mcpld_to_scpld_p2s_data[24]        = w_led_control[1];
assign  mcpld_to_scpld_p2s_data[23]        = w_led_control[0];

assign  mcpld_to_scpld_p2s_data[22]        = w_usb_sw_s                         ;
assign  mcpld_to_scpld_p2s_data[21]        = db_i_pal_bmcuid_button ;
assign  mcpld_to_scpld_p2s_data[20]        = w_p12v_discharge_r         ;
assign  mcpld_to_scpld_p2s_data[19]        = db_i_p1_pcie_rst_n_1     ;
assign  mcpld_to_scpld_p2s_data[18]        = db_i_p1_pcie_rst_n_0     ;
assign  mcpld_to_scpld_p2s_data[17]        = db_i_p0_pcie_rst_n_1     ;
assign  mcpld_to_scpld_p2s_data[16]        = db_i_p0_pcie_rst_n_0     ;
assign  mcpld_to_scpld_p2s_data[15]        = w_PAL_OCP1_PRSNT_B2_N   ;//2025-03-06 DEL ~
assign  mcpld_to_scpld_p2s_data[14]        = w_PAL_OCP1_PRSNT_B1_N   ;
assign  mcpld_to_scpld_p2s_data[13]        = w_PAL_OCP1_PRSNT_B0_N   ;
assign  mcpld_to_scpld_p2s_data[12]        = db_i_pgd_p5v                     ;
assign  mcpld_to_scpld_p2s_data[11]        = db_i_p0_slp_s3_n             ;
assign  mcpld_to_scpld_p2s_data[10]        = db_i_p0_slp_s5_n             ;
assign  mcpld_to_scpld_p2s_data[9]          = db_i_pwrgd_p3v3_stby     ;
assign  mcpld_to_scpld_p2s_data[8]          = db_i_pgd_p1v2_stby         ;
assign  mcpld_to_scpld_p2s_data[7]          = w_bmc_ready_flag             ;
assign  mcpld_to_scpld_p2s_data[6]          = w_PAL_BP6_PRSNT_N           ;
assign  mcpld_to_scpld_p2s_data[5]          = w_PWRGD_P12V                     ;
assign  mcpld_to_scpld_p2s_data[4]          = w_FM_P12V_EN                     ;

assign  mcpld_to_scpld_p2s_data[3]        = 1'b0                                       ;
assign  mcpld_to_scpld_p2s_data[2]        = 1'b1                                       ;
assign  mcpld_to_scpld_p2s_data[1]        = 1'b0                                       ;
assign  mcpld_to_scpld_p2s_data[0]        = 1'b1                                       ;

//-------------------------------------------------------------------------------------------------
// CPLD_U247 SGPIO Moudule       CPLD_U247 is slave
// ------------------------------------------------------------------------------------------------
always@(posedge clk_50m or negedge pon_reset_n)
	begin
		if(~pon_reset_n)
			begin
				scpld_to_mcpld_data_filter <= {192{1'b0}};
				scpld_sgpio_fail <=1'b0;
			end
		else if
			((scpld_to_mcpld_s2p_data[3:0] == 4'b0101)&& (scpld_to_mcpld_s2p_data[199:196] == 4'b1010))
			begin
				scpld_to_mcpld_data_filter <= scpld_to_mcpld_s2p_data[195:4];
				scpld_sgpio_fail <=1'b0;
			end
		else
			begin
				scpld_to_mcpld_data_filter <= scpld_to_mcpld_data_filter;
				scpld_sgpio_fail <=1'b1;
			end

end
//S CPLD ---> M CPLD
s2p_master #(.NBIT(200)) inst_scpld_to_mcpld_s2p(//96
  .clk  (clk_50m					), //in
  .rst  (~pon_reset_n				), //in
  .tick (t1us_tick					), //in
  .si   (i_CPLD_SGPIO0_MISO_R		), //in   //SGPIO_MISO  Serial Signal input
  .po   (scpld_to_mcpld_s2p_data	), //out  //Parallel Signal output
  .sld_n(w_cpld_sgpio0_ld_n_r	), //out  //SGPIO_LOAD
  .sclk (w_cpld_sgpio0_clk_r 	)  //out  //SGPIO_CLK
);

//M CPLD  ---> S CPLD
p2s_slave #(.NBIT(200)) inst_mcpld_to_scpld_p2s(//96
	.clk  (clk_50m					    ),//in
	.rst  (~pon_reset_n				    ),//in
	.pi   (mcpld_to_scpld_p2s_data	    ),//in   //Parallel Signal input
	.so   (w_cpld_sgpio0_mosi_r 	),//out  //SGPIO_MOSI Serial Signal output
	.sld_n(w_cpld_sgpio0_ld_n_r		),//in   //SGPIO_LOAD
	.sclk (w_cpld_sgpio0_clk_r		) //in   //SGPIO_CLK
);
//-------------------------------------------------------------------------------------------------
//M_CPLD TO S_CPLD SGPIO    END
//-------------------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------------------------------------------------------------------
// CMU CPLD SGPIO data
// --------------------------------------------------------------------------------------------------------------------------------------------------
wire [95:0] mbcpld_to_cmucpld_p2s_data;
wire [95:0] cmucpld_to_mcpld_s2p_data;

reg [19:0]	cmu_to_mb_data_filter;//2024-5-14 54-->19
reg 	cmucpld_sgpio_fail;

wire    w_ss_pal_clk_r;
wire    w_ss_pal_load_n_r;
wire    w_ss_pal_data_out_r;

wire    w_mb_type4                ;
wire    w_mb_type3                ;
wire    w_mb_type2                ;
wire    w_mb_type1                ;
wire    w_rfu_bit1              ;
wire    w_rfu_bit2              ;
wire    w_rfu_bit3              ;
wire    w_leakage_int             ;//2024-7-2 add 
wire    wBMC_PWR_OK;
wire    w_bmc_cpld_wdt_in;//2024-11-11 add
assign  w_mb_type4  =   1'b0    ;//mb_type: GENOA 2P4U = 4'b0110
assign  w_mb_type3  =   1'b1    ;
assign  w_mb_type2  =   1'b1    ;
assign  w_mb_type1  =   1'b0   ;

assign  w_rfu_bit1  =   1'b0    ;
assign  w_rfu_bit2  =   1'b0    ;
assign  w_rfu_bit3  =   1'b0    ;
assign  w_leakage_int  =   1'b0    ;

wire    w_bmc_active0_n                     ;
wire    w_pal_p12v_stby_drop           ;
wire    w_ale_tmp1_n                           ;
wire    w_pal_bmcuid_button_r         ;
wire    w_peci_master_sel                 ;
wire    w_pcie_pal_bmc_wake_n         ;
wire    w_password_clear                   ;
wire    w_fm_cpu1_disable_cod_n_r ;

wire    cmu_pg_p5v0_stby		       ; 
wire    cmu_pg_p3v3_stby		       ; 
wire    cmu_pg_p3v3_stby_rgm	       ; 
wire    cmu_pg_p2v5_stby		       ; 
wire    cmu_pg_p1v8_stby		       ; 
wire    cmu_pg_p1v2_stby		       ; 
wire    cmu_pg_p1v0_stby		       ; 

wire    w_bmc_onctl_n                         ;

//CMU CPLD ---> MB CPLD
assign w_bmc_cpld_wdt_in                             = cmu_to_mb_data_filter[18]; //2024-11-11 add 
assign w_bmc_active0_n                                 = cmu_to_mb_data_filter[17]; //USELESS 
assign w_pal_p12v_stby_drop                       = cmu_to_mb_data_filter[16];//USELESS
assign w_ale_tmp1_n                                       = cmu_to_mb_data_filter[15];//USELESS
assign w_pal_bmcuid_button_r                     = cmu_to_mb_data_filter[14];//USELESS
assign w_peci_master_sel                             = cmu_to_mb_data_filter[13];//USELESS
assign w_pcie_pal_bmc_wake_n                     = cmu_to_mb_data_filter[12];//USELESS
assign w_password_clear                               = cmu_to_mb_data_filter[11];//USELESS
assign w_fm_cpu1_disable_cod_n_r             = cmu_to_mb_data_filter[10];//USELESS
assign wBMC_PWR_OK                                         = cmu_to_mb_data_filter[9];
assign cmu_pg_p5v0_stby		                    = cmu_to_mb_data_filter[8];//USELESS
assign cmu_pg_p3v3_stby		                    = cmu_to_mb_data_filter[7];//USELESS
assign cmu_pg_p3v3_stby_rgm	                    = cmu_to_mb_data_filter[6];//USELESS
assign cmu_pg_p2v5_stby		                    = cmu_to_mb_data_filter[5];//USELESS
assign cmu_pg_p1v8_stby		                    = cmu_to_mb_data_filter[4];//USELESS
assign cmu_pg_p1v2_stby		                    = cmu_to_mb_data_filter[3];//USELESS
assign cmu_pg_p1v0_stby		                    = cmu_to_mb_data_filter[2];//USELESS
assign w_bmc_ready_flag                               = cmu_to_mb_data_filter[1];
assign w_bmc_onctl_n                                     = cmu_to_mb_data_filter[0];//USELESS

//MB CPLD ---> CMU CPLD
assign mbcpld_to_cmucpld_p2s_data[95]    = 1'b1                                ;
assign mbcpld_to_cmucpld_p2s_data[94]    = 1'b0                                ;
assign mbcpld_to_cmucpld_p2s_data[93]    = 1'b1                                ;
assign mbcpld_to_cmucpld_p2s_data[92]    = 1'b0                                ;
assign mbcpld_to_cmucpld_p2s_data[91:23]  = 'b0                                ;

assign mbcpld_to_cmucpld_p2s_data[22]    = w_mb_type4                     ;
assign mbcpld_to_cmucpld_p2s_data[21]    = w_mb_type3                     ;
assign mbcpld_to_cmucpld_p2s_data[20]    = w_mb_type2                     ;
assign mbcpld_to_cmucpld_p2s_data[19]    = w_mb_type1                     ;
assign mbcpld_to_cmucpld_p2s_data[18]    = w_rfu_bit3                    ;//w_rfu_bit3
assign mbcpld_to_cmucpld_p2s_data[17]    = w_rfu_bit2                     ;
assign mbcpld_to_cmucpld_p2s_data[16]    = w_rfu_bit1                     ;
assign mbcpld_to_cmucpld_p2s_data[15]    = w_leakage_int                     ;

assign mbcpld_to_cmucpld_p2s_data[14]    = ~w_bmc_extrst_uid                     ;  
assign mbcpld_to_cmucpld_p2s_data[13]    = i_FRONT_VGA_CABLE_PRSNT_N           ; 
assign mbcpld_to_cmucpld_p2s_data[12]    = i_PGD_P12V_STBY_DROOP               ;
assign mbcpld_to_cmucpld_p2s_data[11]    = w_PWRGD_P12V                        ;  
assign mbcpld_to_cmucpld_p2s_data[10]    = db_i_pwr_btn_cpld_n_r                      ;  
assign mbcpld_to_cmucpld_p2s_data[9]     = w_uid_sw_in_n                       ;  
assign mbcpld_to_cmucpld_p2s_data[8]     = 1'b1         ;//db_i_fm_plt_bmc_thermtrip_n
assign mbcpld_to_cmucpld_p2s_data[7]     = 1'b1                   ;//db_i_fm_pchhot_n
assign mbcpld_to_cmucpld_p2s_data[6]     = 1'b1          ;//db_i_fm_pch_glb_rst_warn_n
assign mbcpld_to_cmucpld_p2s_data[5]     = db_i_p0_slp_s5_n                     ;
assign mbcpld_to_cmucpld_p2s_data[4]     = db_i_p0_slp_s3_n                     ;

assign mbcpld_to_cmucpld_p2s_data[3]     = 1'b0                                ;
assign mbcpld_to_cmucpld_p2s_data[2]     = 1'b1                                ;
assign mbcpld_to_cmucpld_p2s_data[1]     = 1'b0                                ;
assign mbcpld_to_cmucpld_p2s_data[0]     = 1'b1                                ;
// --------------------------------------------------------------------------------------------------------------------------------------------------
// CMU CPLD SGPIO Moudule   CMU is slave
// --------------------------------------------------------------------------------------------------------------------------------------------------
always@(posedge clk_50m or negedge pon_reset_n)
	begin
		if(~pon_reset_n)
			begin
				cmu_to_mb_data_filter <= {20{1'b0}};
				cmucpld_sgpio_fail <=1'b0;
			end
		else if
			((cmucpld_to_mcpld_s2p_data[3:0] == 4'b0101)&& (cmucpld_to_mcpld_s2p_data[95:92] == 4'b1010))
			begin
				cmu_to_mb_data_filter <= cmucpld_to_mcpld_s2p_data[23:4];
				cmucpld_sgpio_fail <=1'b0;
			end
		else
			begin
				cmu_to_mb_data_filter <= cmu_to_mb_data_filter;
				cmucpld_sgpio_fail <=1'b1;
			end

end
//CMU CPLD ---> M CPLD
s2p_master #(.NBIT(96)) inst_cmucpld_to_mcpld_s2p(
  .clk  (clk_50m					), //in
  .rst  (~pon_reset_n				), //in
  .tick (t1us_tick					), //in
  .si   (i_SS_PAL_DATA_IN_R		    ), //in   //SGPIO_MISO  Serial Signal input
  .po   (cmucpld_to_mcpld_s2p_data	), //out  //Parallel Signal output
  .sld_n(w_ss_pal_load_n_r			), //out  //SGPIO_LOAD
  .sclk (w_ss_pal_clk_r 			)  //out  //SGPIO_CLK
);

//M CPLD  ---> CMU CPLD
p2s_slave #(.NBIT(96)) inst_mcpld_to_cmucpld_p2s(
	.clk(clk_50m					    ),//in
	.rst(~pon_reset_n				    ),//in
	.pi (mbcpld_to_cmucpld_p2s_data	    ),//in   //Parallel Signal input
	.so (w_ss_pal_data_out_r 		    ),//out  //SGPIO_MOSI Serial Signal output
	.sld_n(w_ss_pal_load_n_r		    ),//in   //SGPIO_LOAD
	.sclk(w_ss_pal_clk_r		        ) //in   //SGPIO_CLK
);
//-------------------------------------------------------------------------------------------------
// power_button
// ------------------------------------------------------------------------------------------------
//  BMC active CHECK   only bmc active can get into S0
wire    w_pwrbtn_to_pch_n ;
wire    w_bmc_ctl_pwrbtn_n;
wire    [1:0]   w_pwr_btn_state    ;
wire    w_pwr_btn_dly             ;

//from IIC_bmc
wire    w_bmc_pwrbtn_lock         ;  //bmc control,set 0 to disable physical btn
wire    w_bmc_sbtn_poweron        ; //bmc control,generate 500ms pulse       set 1 enable ______------_____
wire    w_bmc_lbtn_powerdown      ; //bmc control,generate 6s pulse
wire    w_bmc_sbtn_powerdown      ; //bmc control,generate 500ms pulse
wire    w_bmc_sbtn_wc             ; //bmc control,set 0 to clr  sbtn_pwron_evt
wire    w_bmc_lbtn_wc             ; //bmc control,set 0 to clr  lbtn_pwrdown_evt
wire    w_bmc_sbtn_sys_wc         ; //bmc control,set 0 to clr  sbtn_sysrst_evt
//To IIC_bmc
wire    w_bmc_sbtn_poweron_done   ; // virtual sbtn for pwrup event  push down more than 1s
wire    w_bmc_lbtn_powerdown_done ; // virtual lbtn  7s
wire    w_bmc_sbtn_powerdown_done ; // virtual sbtn  1s
wire    w_sbtn_pwron_evt          ; // sbtn for pwrup event push down for 500ms         in S5
wire    w_lbtn_pwrdown_evt        ; // lbtn for pwrdown event push down for 4s          in S0
wire    w_sbtn_sysrst_evt         ; // sbtn for rst event     push down for 500ms       in S0
wire    w_btn_press_flag          ;
wire    w_pal_pwrbtn_n_r          ;

Pwr_But_Ctrl #(
.PWRBTN_LONG                  (4)
)Pwr_But_Ctrl_U0
(
.i_clk                             (clk_50m),		//input Clk
.i_rst_n                         (pon_reset_n),		//Global rst,Active Low
.i_20mSEC                       (w20mSCE),  //w20mSCE

.i_PWRBTN_OUT_disable               (1'b0),
.i_disable_button                       (1'b0),	// 1'b1 is disable, 1'b0 is enable;  1'b1 for General items.  //w_bmc_pwrbtn_lock_n_ff from IIC_bmc        1'b0   2022-12-19 delete for debug  ~r_bmc_actived  || (~w_bmc_pwrbtn_lock)
.i_BMC_active0_n                         (1'b1), // 1'b1: BMC die,  1'b0: BMC active, default low when AC in;  if no function of BMC controled power on, this signal should 1'b1.
.i_FP_PWR_BTN_MUX_N                   (db_i_pwr_btn_cpld_n_r),			//Power Button  //MB  PWR_BTN db_i_pal_pwr_btn_n
.i_FM_BMC_PWRBTN_OUT_CPLD_N   (1'b1),	//Power on/off signal from BMC
.i_DBP_POWER_BTN_N                     (1'b1),	//Power on/off signal from DBP   //from ERA BP
.i_state_s0                                   (1'b1),
.i_state_s5                                   (1'b0),
.i_bmc_clear_data                       (1'b1),        //high pulse for BMC clear latch data
.i_BMC_active1_n                         (1'b0),        // 1'b1: BMC die,  1'b0: BMC active, default high when AC in

.o_pwrbtn_short                           (        ),
.o_pwrbtn_long                             (        ),
.o_PWRBTN_state                           (        ),
.o_pwr_btn_state                         (w_pwr_btn_state),
.o_pwr_btn_dly                             (w_pwr_btn_dly  ),
.o_FM_BMC_PWRBTN_OUT_B_N         (w_pwrbtn_to_pch_n)		//Power on/off signal to PCH
);

bmc_ctl_pwrbtn bmc_ctl_pwrbtn_u0(
.i_clk                                        (clk_50m),
.i_rst_n                                    (pon_reset_n),
.i_clk_20ms                              (w20mSCE), //w20mSCE
.i_pwrbtn_n                              (w_pwrbtn_to_pch_n),  // w_pwrbtn_to_pch_n 
.i_slps4_n                                (db_i_p0_slp_s5_n),   

.i_bmc_sbtn_poweron               (w_bmc_sbtn_poweron  ),     //generate 500ms pulse
.i_bmc_lbtn_powerdown           (w_bmc_lbtn_powerdown),   //generate 6s pulse
.i_bmc_sbtn_powerdown           (w_bmc_sbtn_powerdown),   //generate 500ms pulse
.i_bmc_sbtn_wc                         (w_bmc_sbtn_wc    ),
.i_bmc_lbtn_wc                         (w_bmc_lbtn_wc    ),
.i_bmc_sbtn_sys_wc                 (w_bmc_sbtn_sys_wc),

.o_bmc_sbtn_poweron_done     (w_bmc_sbtn_poweron_done  ),
.o_bmc_lbtn_powerdown_done (w_bmc_lbtn_powerdown_done),
.o_bmc_sbtn_powerdown_done (w_bmc_sbtn_powerdown_done),
.o_sbtn_pwron_evt                   (w_sbtn_pwron_evt  ),
.o_lbtn_pwrdown_evt               (w_lbtn_pwrdown_evt),
.o_sbtn_sysrst_evt                 (w_sbtn_sysrst_evt ),
.o_bmc_ctl_pwrbtn_n               (w_bmc_ctl_pwrbtn_n)
);

assign  w_btn_press_flag       = w_sbtn_pwron_evt || w_lbtn_pwrdown_evt || w_sbtn_sysrst_evt;
assign  w_pal_pwrbtn_n_r = w_pwrbtn_to_pch_n & w_bmc_ctl_pwrbtn_n ;  //o_FM_CPLD_PWRBTN_OUT_N    cpld TO pch

//--------------------------------------------------------------------------------------------------------------------------------------------------
//power_button end
//--------------------------------------------------------------------------------------------------------------------------------------------------
wire    [3:0]w_pal_ocp1_prsnt_n;
wire    w_ocp1_x8_prsnt_n;
wire    w_ocp1_x16_prsnt_n;
assign  w_ocp_prsnt_n   =   w_PAL_OCP1_PRSNT_B3_N & w_PAL_OCP1_PRSNT_B2_N & w_PAL_OCP1_PRSNT_B1_N & w_PAL_OCP1_PRSNT_B0_N;
assign  w_pal_ocp1_prsnt_n  =   {w_PAL_OCP1_PRSNT_B3_N,w_PAL_OCP1_PRSNT_B2_N,w_PAL_OCP1_PRSNT_B1_N,w_PAL_OCP1_PRSNT_B0_N};
assign  w_ocp1_x16_prsnt_n    =   ((w_pal_ocp1_prsnt_n==4'b0100)|(w_pal_ocp1_prsnt_n==4'b0101)|
                                                               (w_pal_ocp1_prsnt_n==4'b0111)|(w_pal_ocp1_prsnt_n==4'b1100))?1'b0:1'b1;
assign  w_ocp1_x8_prsnt_n   =   w_ocp_prsnt_n ? 1'b1 : (w_ocp1_x16_prsnt_n ? 1'b0 : 1'b1);



//-------------------------------------------------------------------------------------------------
// /system reset
// ------------------------------------------------------------------------------------------------
// wire w_bmc_ctl_sys_rst;
wire w_bmc_ctl_sys_rst_done;

system_rst system_rst_u0(
.i_clk                        (clk_50m),
.i_rst_n                    (pon_reset_n),
.i_clk_20ms              (w20mSCE), //w20mSCE

.i_RST_DBP_RST_CO_R_N       (db_i_pal_ext_rst_n     ), //PAL_EXT_RST_N
.i_bmc_ctl_sys_rst             (w_bmc_sbtn_reset_ctl ),    //to generate 500ms pulse

.o_bmc_ctl_sys_rst_done   (w_bmc_ctl_sys_rst_done),
.o_RST_SYS_BTN_OUT_PLD_N (w_pal_sys_reset_od_n_r)
);
// assign o_PAL_SYS_RESET_OD_N_R = w_pal_sys_reset_od_n_r ;

//--------------------------------------------------------------------------------------------------------------------------------------------------
// MB NC_PORT 
//-------------------------------------------------------------------------------------------------------------------------------------------------- 
wire    w_nc_pin ; 
assign  w_nc_pin  = i_HDR_N_R       &
                                   i_CPLD_SN        &
                                   i_CPLD_DONE      &
                                   i_CPLD_INIT_N        &
                                   i_CPLD2_JTAGEN_R     &
                                   i_PAL_PEOGRAM_N      &
                                   i_CPLD_JTAG_EN       &
                                   i_CLK_GEN_ALERT_R_N      &
                                   i_CPLD_SGPIO1_MISO_R     &
                                   i_FAN_SPGIO_DATAIN       &
                                   i_UART_CPLD_RX_R     &
                                   // i_P0_MCIOP0A_DATAIN_R        &
                                   // i_P0_MCIOP0C_DATAIN_R        &
                                   // i_P0_MCIOP1A_DATAIN_R        &
                                   i_P0_MCIOP1AC_VPPI2C_SCL     &
                                   i_P0_MCIOP1AC_VPPI2C_SDA     &
                                   i_P0_MCIOP3A_DATAIN_R        &
                                   i_P0_MCIOP3AC_VPPI2C_SCL     &
                                   i_P0_MCIOP3AC_VPPI2C_SDA     &
                                   i_SATA1_SDATAOUT0_R      &
                                   i_SATA1_BACKPLANE_TYPE       &
                                   i_P0_SGPIO_LD_R      &
                                   i_P0_SGPIO_DATA_R        &
                                   i_CPU0_SGPIO0_CLK        &
                                   i_CPU0_SGPIO1_CLK        &                                 
                                   i_CPU0_SGPIO2_CLK        &
                                   i_CPU0_SGPIO3_CLK        &
                                   i_P0_XTRIG_N_4       &
                                   i_P0_XTRIG_N_5       &
                                   i_P0_XTRIG_N_6       &
                                   i_P0_XTRIG_N_7       &
                                   i_P1_XTRIG_N_4       &
                                   i_P1_XTRIG_N_5       &
                                   i_P1_XTRIG_N_6       &
                                   i_P1_XTRIG_N_7       &
                                   i_P0_UART_TXD_0      &
                                   i_P0_CPLD_SPARE_0    &
                                   i_P0_CPLD_SPARE_1    &
                                   i_P0_CPLD_SPARE_2    &
                                   i_P0_CPLD_SPARE_3    &
                                   i_P0_SMERR_N             &
                                   i_P1_SMERR_N     &
                                   // i_P0_CPLD_SCL        &
                                   // i_P0_CPLD_SDA        &
                                   i_HDT_CONN_TESTEN        &
                                   i_P1_SLP_S3_N        &
                                   i_P1_SLP_S5_N        &
                                   i_IRQ_SPI_TPM_N      &
                                   i_PAL_LCD_CARD_IN        &
                                   i_P0_PRSNT_N     &
                                   i_P1_PRSNT_N     &
                                   i_PG_P1V0_STBY_M2_R      &
                                   i_BMC_JTAG_DBREQ_N       &
                                   // w_mcio_slot13_prsnt_n_1_sw       &
                                   w_mcio_slot13_prsnt_n_1_sw2      &
                                   w_u19_nc4_zt     &
                                   w_u19_nc4_zt2
                                   
				  ;

//inouts
assign  w_p0_dimm_af_pcamp_r = (w_power_seq_sm == SM_STEADY_PWROK) ? 1'b1 : 1'b0;
assign  w_p0_dimm_gl_pcamp_r = (w_power_seq_sm == SM_STEADY_PWROK) ? 1'b1 : 1'b0;
assign  w_p1_dimm_af_pcamp_r = (w_power_seq_sm == SM_STEADY_PWROK) ? 1'b1 : 1'b0;
assign  w_p1_dimm_gl_pcamp_r = (w_power_seq_sm == SM_STEADY_PWROK) ? 1'b1 : 1'b0;

// --------------------------------------------------------------------------------------------------------------------------------------------------
// bmc_ready for slp_s3 
// --------------------------------------------------------------------------------------------------------------------------------------------------
wire  w_bmc_ready_pos;
reg r_bmc_ready ;

Edge_Detect Edge_Detect_U2(    
    .i_clk               (clk_50m),        
    .i_rst_n             (pon_reset_n),       
    .i_signal            (w_bmc_ready_flag ),  
    
    .o_signal_pos        (w_bmc_ready_pos),
    .o_signal_neg        (),  
    .o_signal_invert     ()
);

always @(posedge clk_50m or negedge pon_reset_n) begin
    if( !pon_reset_n)
        begin
            r_bmc_ready <= 1'b0 ;
        end
    else if(w_bmc_ready_pos) 
        begin
            r_bmc_ready <= 1'b1 ;
        end
    else if(~db_i_p0_slp_s3_n & ~w_bmc_ready_flag) 
        begin
            r_bmc_ready <= 1'b0 ;
        end
    else
        begin
            r_bmc_ready <= r_bmc_ready ;
        end
end

wire    w_sys_pwrok;

assign  w_sys_pwrok 				= w_sm_steady_pwrok_state;					//pgd_aux_system	
assign  w_sm_steady_pwrok_state	= (w_power_seq_sm==SM_STEADY_PWROK	);		//

// //--------------------------------------------------------------------------------------------------------------------------------------------------
// //cpu_thermtrip 
// //--------------------------------------------------------------------------------------------------------------------------------------------------
assign  w_cpu_thermtrip_event  = (~db_cpu_thermaltrip_n) & {`NUM_CPU{w_cpupwrok_rise_dly2ms}} & (~db_cpu_prsnt_n); 
wire    [1:0]   w_cpu_thermtrip_fault_det;
edge_delay #(.CNTR_NBITS(2), .DELAY_MODE(1'b0)) edge_delay_inst_cpupwrok (
    .clk         (clk_50m),
    .reset       (~pgd_aux_system),
    .cnt_size    (2'b10),
    .cnt_step    (t1ms_tick),
    .signal_in   (w_cpu_sys_pwrok),
    .delay_output(w_cpupwrok_rise_dly2ms)
  );

cpu_thermtrip thermtrip_int(
    .i_clk					(clk_50m				),
    .i_reset					(~pon_reset_n			),

    .i_any_pwr_fault_det		(w_any_pwr_fault_det	    ),					//0
    .i_cpu_prsnt_n			(db_cpu_prsnt_n			    ),					//0
    .i_st_steady_pwrok		(w_st_steady_pwrok		    ),					//1->0
    .i_st_critical_fail		(w_st_critical_fail		    ),					//0 -> 1 1ms
    .i_st_disable_main_efuse	(w_st_disable_grp_d_vddio  ),					//0 -> 1 6.1ms
    .i_cpu_thermtrip			(w_cpu_thermtrip_event	    ),					//0 -> 1 0.42ms
    .i_cpu_thermaltrip_clr	(w_fault_clear | ~w_cpu0_thermaltrip_clr| ~w_cpu1_thermaltrip_clr	),	
        
    .cpu_thermtrip_fault_det	(w_cpu_thermtrip_fault_det )
);


//-------------------------------------------------------------------------------------------------
//cpu thermtrip Signal Latch //2023-9-20 add
//-------------------------------------------------------------------------------------------------
wire  w_clear_register;
wire  wFM_CPU0_THERMTRIP_LVT3_Fault_N;
wire  wFM_CPU1_THERMTRIP_LVT3_Fault_N;

Signal_Latch#(
.EDGE        			(1'b0),
.INIT        			(1'b1),
.LATCH       			(1'b0),
.POWER_JUDGE  		(1'b1)
)Signal_Latch_THERMTRIP0(

    .i_Clk				(clk_50m        ),
    .i_Rst_n				(pon_reset_n),

    .i_Clr_Flag			(w_clear_register),//w_clear_register  1'b0
    .i_PWRGD_OK			(w_cpu_pwr_good & db_i_p0_pcie_rst_n_0),
    .i_Signal				(db_cpu_thermaltrip_n[0]),
    .o_Signal_Latch		(wFM_CPU0_THERMTRIP_LVT3_Fault_N),
    .o_Fault				(       )
);

Signal_Latch#(
.EDGE        			(1'b0),
.INIT        			(1'b1),
.LATCH       			(1'b0),
.POWER_JUDGE  		(1'b1)
)Signal_Latch_THERMTRIP1(

    .i_Clk				(clk_50m        ),
    .i_Rst_n				(pon_reset_n),

    .i_Clr_Flag			(w_clear_register),//w_clear_register  1'b0
    .i_PWRGD_OK			(w_cpu_pwr_good & db_i_p1_pcie_rst_n_0),
    .i_Signal				(db_cpu_thermaltrip_n[1]),
    .o_Signal_Latch		(wFM_CPU1_THERMTRIP_LVT3_Fault_N),
    .o_Fault				(       )
);

//--------------------------------------------------------------------------------------------------------------------------------------------------
//CPU Module:Assume the CPU is Present
//--------------------------------------------------------------------------------------------------------------------------------------------------
assign w_cpu_module_en_n = w_SW_1  ;	//0:CPU Module Enable  1: CPU Module disable 	

//Assume the CPU is Present
cpu_module cpu_module_u1	(
.clk				(clk_50m							),
.reset				((~pon_reset_n) | w_cpu_module_en_n	),
.t512us				(t512us_tick					),

.i_p0_pwrgood		(w_cpu_pwr_good					),	//from pwr_seq_slave
.i_p1_pwrgood		(db_i_p0_pwrgd_out				),	//from pwr_seq_slave		
.i_p0_rsmrset		(w_rsmrst_n						),
.i_p1_rsmrset		(w_rsmrst_n						),
.i_p0_pwr_btn_n		(~w_pal_pwrbtn_n_r				),

.o_p0_pwrok			(w_cpu_module_p0_pwrok			),
.o_p1_pwrok			(w_cpu_module_p1_pwrok			),	
.o_p0_pwrgoodout	(w_cpu_module_p0_pwrgdout			),
.o_p1_pwrgoodout	(w_cpu_module_p1_pwrgdout			),	
.o_p0_slp_s3_n		(w_cpu_module_p0_slp_s3_n			),
.o_p0_slp_s5_n		(w_cpu_module_p0_slp_s5_n			),
.o_p0_prsnt_n		(w_cpu_module_p0_prsnt_n			),
.o_p1_prsnt_n		(w_cpu_module_p1_prsnt_n			)
);

/************************************************************************************************************************************************************************/
//--------------------------------------------------------------------------------------------------------------------------------------------------
//POWER Sequence  Start
//--------------------------------------------------------------------------------------------------------------------------------------------------
/************************************************************************************************************************************************************************/

assign  w_st_reset_state			        = (w_power_seq_sm==SM_RESET_STATE		);
assign  w_st_off_standby			        = (w_power_seq_sm==SM_OFF_STANDBY               );	//S5 
assign  w_st_steady_pwrok			= (w_power_seq_sm==SM_STEADY_PWROK		);	//S0
assign  w_st_halt_power_cycle		= (w_power_seq_sm==SM_HALT_POWER_CYCLE	);	//
assign  w_st_aux_fail_recovery		= (w_power_seq_sm==SM_AUX_FAIL_RECOVERY	);
assign  w_st_critical_fail			= (w_power_seq_sm==SM_CRITICAL_FAIL		);	
assign  w_st_disable_grp_d_vddio	        = (w_power_seq_sm==SM_DISABLE_GRP_D_VDDIO);	
  
//--------------------------------------------------------------------------------------------------------------------------------------------------
//POWER Sequencer - Master : In order to shift the state
//--------------------------------------------------------------------------------------------------------------------------------------------------

assign  w_keep_alive_on_fault	=  w_force_allpwron_ctl || (~w_SW_3);//0:Enable power protect 1:Disable power protect  

pwrseq_master pwrseq_master_inst (
  .clk						(clk_50m				),	//in
  .reset					        (~pon_reset_n			),	//in
  .cmu_fault_clear_rst		(~pon_reset_n                      ),	//
  .t1us						(t1us_tick				),	//in
  .t512us					(t512us_tick			),	//in edge_delay tick
  .sequence_tick			        (t2ms_tick				),	//in 
  .psu_on_tick				(t32ms_tick				),	//in  
  .t256ms					(t256ms_tick			),	//in watch dog tick
  .t512ms					(t512ms_tick			),	//in unused 
  .t1s_tick					(t1s_tick				),	//in unused 
  
  .allow_recovery			(1'b0	),					//in
  .aux_video_holdoff		        (1'b0	),					//in
  .pgood_rst_mask			(1'b0	),					//in
  .keep_alive_on_fault		(w_keep_alive_on_fault	),	//in
  .pwron_override_n			(1'b1			                ),	//in
  .bmc_clr_stby_tmout_n		(~(w_stb_pwron_tmout_fail_clr & w_stb_pwrdown_ukwn_fail_clr & w_poweron_tmout_fail_clr)),	
  .power_seq_sm_fb			(r_power_seq_sm_fb		),	//in; 
  .mux_sel					(w_mux_sel				),	//in; 
  
  .sys_sw_in_n				(db_i_pwr_btn_cpld_n_r            ), //in; power button in board; SB (south bridge) system sleep state
  .pch_slp4_n				(db_i_p0_slp_s5_n	& r_bmc_ready 	),	//in; SB (south bridge) system sleep state   //20241231 add  r_bmc_ready
  .p0_pwrbtn_n				(~w_pal_pwrbtn_n_r			),	//in; SB power button input (same signal driven to SB PWRBTN)
  .pch_thermtrip_n			(w_cpu_thermtrip_event		),	//~amd_cpu_thrmtrip),//in, power down from power_button AMD has no PCH 
  .cpu_thermtrip_fault_det	(w_cpu_thermtrip_fault_det	),	// 
  
  .xr_ps_en					(1'b1			),				//xr_ps_enable), //in, from BMC 
  .interlock_broken			(1'b0			),				//db_cpu_prsnt_n[0] | interlock_broken),//in
  .s5dev_pwren_request		(w_s5dev_aux_pwren_request	),	//in, from pwrweq_slave
  .s5dev_pwrdis_request		(w_s5dev_aux_pwrdis_request	),	//in, from pwrweq_slave
  .pgd_so_far				(w_pgd_so_far				),	//in, FROM pwrweq_slave
  .any_pwr_fault_det		        (w_any_pwr_fault_det                ),	//in, FROM pwrweq_slave 
  .any_lim_recov_fault		(w_any_lim_recov_fault		),	//in, FROM pwrweq_slave
  .any_non_recov_fault		(w_any_non_recov_fault		),	//in, FROM pwrweq_slave
//  .bmc_ready_out_n		(~bmc_ready_out_n_r			),	//in, FROM CMU 

  .force_pwrbtn_n			(w_force_pwrbtn_n			),	//out, TO PSU(no use); forces SB to switch to S5 after power shutdown due to fault
  .pgd_raw					(w_pgd_raw					),	//out, TO PWRBTN_LEDS(no use)
  .dc_on_wait_complete		(w_dc_on_wait_complete		),	//out, TO SLAVE,
  .rt_critical_fail_store	(w_rt_critical_fail_store	),	//out, TO SLAVE/ADR/SYSTEM_RESET
  .fault_clear				(w_fault_clear				),	//out, TO SLAVE/PSU/THERMAL 
  .cmu_fault_clear			(w_cmu_fault_clear			),	//out,  
  .power_seq_sm				(w_power_seq_sm				),	//out, FSM status
  .fault_power				(w_power_fault				),	//out, TO PF/XREG/PWRBTN_LED/HEALTH_LEDS/UID/POST_LEDS/NIC_LEDS
  .stby_failure_detected	         (w_stby_failure_detected	),	//out, TO PF/XREG
  .po_failure_detected		(w_dc_failure_detected		),	//out, TO PF/XREG
  .rt_failure_detected		(w_rt_failure_detected		),	//out, TO PF/XREG
  .cpld_latch_sys_off		(w_cpld_latch_sys_off		),	//out, TO XREG
  .turn_on_wait				(w_turn_on_wait				),	//out, TO PWRBTN_LEDS
  .po_failure_detected_set	(	)                         	//out
);


//--------------------------------------------------------------------------------------------------------------------------------------------------
//POWER Sequencer - Slave : 
//--------------------------------------------------------------------------------------------------------------------------------------------------
//wire pal_pvcc_hpmos_sw_r;   
// wire    [2:0]   pcb_id;
// assign  pcb_id = 3'b000;

pwrseq_slave #(
  .SHARED_P5V_STBY_HPMOS(1'b1),
  .S5DEV_STUCKON_FAULT_CHK(1'b0),
  .NUM_CPU(`NUM_CPU),
  .NUM_OPT_AUX(0)
 // .NUM_S5DEV(`NUM_S5DEV),
) pwrseq_slave_inst (
  //base signal
  .clk							(clk_50m		),             
  .reset						        (~pon_reset_n	),
  .t1us							(t1us_tick		),
  .t512us						(t512us_tick	),	//unused
  .t1ms							(t1ms_tick		),
  .t2ms							(t2ms_tick		),
  .t64ms						        (t64ms_tick		),
  .t1s							(t1s_tick		),	//unused 
  
  .keep_alive_on_fault			(w_keep_alive_on_fault		),
//from pwrseq_master
  .dc_on_wait_complete			(w_dc_on_wait_complete		),	//in FROM MASTER
  .rt_critical_fail_store		(w_rt_critical_fail_store	),	//in FROM MASTER
  .fault_clear					(w_fault_clear				),	//in FROM MASTER
  .power_seq_sm					(w_power_seq_sm				),	//in FROM MASTER
//to pwrseq_master
  .pgd_so_far					(w_pgd_so_far				),
  .s5dev_pwren_request			(w_s5dev_aux_pwren_request	),       	
  .s5dev_pwrdis_request			(w_s5dev_aux_pwrdis_request	),           
  .any_pwr_fault_det			        (w_any_pwr_fault_det		),    		
  .any_lim_recov_fault			(w_any_lim_recov_fault		),          	
  .any_non_recov_fault			(w_any_non_recov_fault		),
  .any_aux_vrm_fault			        (w_any_aux_vrm_fault		),
  .any_recov_fault				(w_any_recov_fault			),

//from Power Controller PG signal 
  .p5v_stby_pg					(db_i_pg_p5v_stby			),
  .grp_b_p0_33_s5_pg			        (db_i_pgd_p0_vddc			),
  .grp_b_p1_33_s5_pg			        (db_i_pgd_p1_vddc		        ),					
  .grp_b_p0_18_s5_pg			        (db_i_pgd_p0_vdd_18_stby	),
  .grp_b_p1_18_s5_pg			        (db_i_pgd_p1_vdd_18_stby	),						
  .p3v3_stby_pg					(db_i_pwrgd_p3v3_stby		),	
  .p12v_stby_pg					(/* db_i_pg_p12v_stby_efuse */	),	 
  .p12v_efuse_pg				        (/* db_i_pg_p12v_efuse */			),  
  .p12v_ssd_efuse_pg			        (/* db_i_pg_p12v_ssd_efuse */		),    
  .p12v_p0_dimm_pg				(/* pg_cpu0_dimm_efuse */			),	//Active-low, need ~ 
  .p12v_p1_dimm_pg			        (		),  					
  .p5v_pg						(db_i_pgd_p5v			),

  .i_pwrgd_ocp0_nic_pwrgd		(/* db_i_pwrgd_ocp0_nic_pwrgd */	),
  .grp_c_p0_pg					(db_i_pgd_p0_vdd_11_sus		),
  .grp_c_p1_pg				        (db_i_pgd_p1_vdd_11_sus		),	
  .grp_d_vddio_p0_pg			        (db_i_pgd_p0_vddio			),
  .grp_d_vddio_p1_pg			        (db_i_pgd_p1_vddio		        ),	
  .grp_d_soc_p0_pg				(db_i_pgd_p0_vdd_soc_0		),
  .grp_d_soc_p1_pg			        (db_i_pgd_p1_vdd_soc_0		),	
  
  .grp_d_p0_vddcore0_pg			(db_i_pgd_p0_vdd_core_0		),
  .grp_d_p1_vddcore0_pg		        (db_i_pgd_p1_vdd_core_0		),						
  .grp_d_p0_vddcore1_pg			(db_i_pgd_p0_vdd_core_1		),
  .grp_d_p1_vddcore1_pg		        (db_i_pgd_p1_vdd_core_1		),	
  
//to Power Controller Enable Pin
  .p5v_stby_en					(w_p5v_stby_en				),
  .p5v_stby_usb_en				(w_p5v_stby_usb_en			),	
  .grp_b_p0_33_s5_en			        (w_grp_b_p0_33_s5_en		),
  .grp_b_p1_33_s5_en			        (w_grp_b_p1_33_s5_en		),						
  .grp_b_p0_18_s5_en			        (w_grp_b_p0_18_s5_en		),
  .grp_b_p1_18_s5_en			        (w_grp_b_p1_18_s5_en		),	
  .power_supply_on				(w_p12_en					),
  // .p12_en_p0_dimm_1				(w_p12_en_p0_dimm			), 
  // .p12_en_p1_dimm_1				(w_p12_en_p1_dimm		        ),						
  // .p12_en_p0_dimm_2				(			), 
  // .p12_en_p1_dimm_2				(		        ),						
  .p5v_en						(w_p5v_en					),
  .grp_c_p0_vdd11_en			        (w_grp_c_p0_vdd11_en		),
  .grp_c_p1_vdd11_en			        (w_grp_c_p1_vdd11_en		),						
  .grp_d_p0_vddio_en			        (w_grp_d_p0_vddio_en		),
  .grp_d_p1_vddio_en			        (w_grp_d_p1_vddio_en	        ),	
  .grp_d_p0_soc_en				(w_grp_d_p0_soc_en			),
  .grp_d_p1_soc_en			        (w_grp_d_p1_soc_en		        ),					
  .grp_d_p0_vddcore0_en			(w_grp_d_p0_vddcore0_en		),
  .grp_d_p1_vddcore0_en		        (w_grp_d_p1_vddcore0_en		),					
  .grp_d_p0_vddcore1_en			(w_grp_d_p0_vddcore1_en		),
  .grp_d_p1_vddcore1_en		        (w_grp_d_p1_vddcore1_en		),					
  // .pcb_id						(pcb_id						),															   
//to CMU
  // .usb_ponrst_r_n				(w_usb_ponrst_r_n			),
  // .tpcm_reset_n				        (tpcm_reset_n				), 
//to OCP
  .ocp_aux_en					(w_ocp_aux_en				),
  .ocp_main_en					(w_ocp_main_en				),	
//fault detect
  .pwrseq_sm_fault_det			(w_pwrseq_sm_fault_det		),
  .p5v_stby_fault_det			(w_p5v_stby_fault_det		),
  .grp_c_p0_fault_det			(w_grp_c_p0_fault_det		),
  .grp_c_p1_fault_det			(w_grp_c_p1_fault_det		),	
  .grp_d_vddio_p0_fault_det		(w_grp_d_vddio_p0_fault_det	), 
  .grp_d_vddio_p1_fault_det	        (w_grp_d_vddio_p1_fault_det	),	
  .grp_d_soc_p0_fault_det		(w_grp_d_soc_p0_fault_det	),  
  .grp_d_soc_p1_fault_det		(w_grp_d_soc_p1_fault_det	),	
  .grp_d_p0_vddcore0_fault_det	(w_grp_d_p0_vddcore0_fault_det),
  .grp_d_p1_vddcore0_fault_det	(w_grp_d_p1_vddcore0_fault_det),	
  .grp_d_p0_vddcore1_fault_det	(w_grp_d_p0_vddcore1_fault_det),
  .grp_d_p1_vddcore1_fault_det	(w_grp_d_p1_vddcore1_fault_det),	

  .grp_b_p0_33_s5_fault_det		(w_grp_b_p0_33_s5_fault_det	),
  .grp_b_p1_33_s5_fault_det	        (grp_b_p1_33_s5_fault_det	),	
  .grp_b_p0_18_s5_fault_det		(w_grp_b_p0_18_s5_fault_det	),
  .grp_b_p1_18_s5_fault_det	        (grp_b_p1_18_s5_fault_det	),					

  .p3v3_stby_fault_det			(w_p3v3_stby_fault_det		),	
  // .p12v_stby_fault_det			(w_p12v_stby_fault_det		),	
  .p5v_fault_det				         (w_p5v_fault_det			),
  // .p12v_efuse_fault_det			(w_p12v_efuse_fault_det		),
  // .p12v_ssd_efuse_fault_det		(w_p12v_ssd_efuse_fault_det	),
  // .p12v_p0_dimm_fault_det		(w_p12v_p0_dimm_fault_det	),
  // .p12v_p1_dimm_fault_det		(w_p12v_p1_dimm_fault_det	),			

//from CPU
  .i_cpu_pwrok					(w_cpu_pwrok				),	//from CPU PWROK
  .i_cpu_prsnt_n				        (db_cpu_prsnt_n				),  //db_cpu_prsnt_n

//to CPU
  .o_p0_pwr_good				        (w_cpu_pwr_good				),	//for AMD BSP PWR_GOOD
  .o_cpu_pwrok					(o_cpu_pwrok				),	//for VR SVI RST
  .o_rsmrst_n					(w_rsmrst_n					),
  .reached_sm_wait_powerok		( )

  );


assign  w_all_stby_power_pg	= db_i_pg_p5v_stby								&
							  db_i_p1v8_stby_pg								&
							  db_i_pwrgd_p3v3_stby							&
							  // db_i_pg_p12v_stby_efuse						&
							  db_i_pgd_p0_vdd_18_stby						&
							 (db_i_pgd_p1_vdd_18_stby| db_cpu_prsnt_n[1])	&
							  db_i_pgd_p0_vddc								&
							 (db_i_pgd_p1_vddc		 | db_cpu_prsnt_n[1])	;

assign  w_all_main_power_pg	=db_i_pgd_p0_vdd_11_sus						&
							 (db_i_pgd_p1_vdd_11_sus | db_cpu_prsnt_n[1])	&
							  db_i_pgd_p0_vddio								&
							 (db_i_pgd_p1_vddio		 | db_cpu_prsnt_n[1])	&
							  db_i_pgd_p0_vdd_soc_0							&
							 (db_i_pgd_p1_vdd_soc_0  | db_cpu_prsnt_n[1])	&
							  db_i_pgd_p0_vdd_core_0						&
							 (db_i_pgd_p1_vdd_core_0 | db_cpu_prsnt_n[1])	&
							  db_i_pgd_p0_vdd_core_1						&
							 (db_i_pgd_p1_vdd_core_1 | db_cpu_prsnt_n[1])	;//no OCP PG
							 
assign  w_all_power_pg = w_all_stby_power_pg & w_all_main_power_pg;

assign  w_cpu_sys_pwrok = db_cpu_prsnt_n[1] ? db_i_p0_pwrgd_out : (db_i_p0_pwrgd_out & db_i_p1_pwrgd_out);  

//--------------------------------------------------------------------------------------------------------------------------------------------------
//WDT 
//--------------------------------------------------------------------------------------------------------------------------------------------------
wire    w_bmc_warm_reset_ctl     ;

//CPU SYS_RESET
assign  w_p0_kbrst_n = ~w_bmc_warm_reset_ctl;  
assign  w_p1_kbrst_n = ~w_bmc_warm_reset_ctl;  
assign  w_cpu_pwrok[0]	= db_i_p0_pwrok;
assign  w_cpu_pwrok[1]	= db_i_p1_pwrok;
//CPU Prochot
assign  w_p0_prochot_n		= ~w_cpu0_prochot;
assign  w_p1_prochot_n		= ~w_cpu1_prochot;

wire fm_pld_db800_3_clks_en	;

/************************************************************************************************************************************************************************/
//--------------------------------------------------------------------------------------------------------------------------------------------------
//POWER Sequence  End
//--------------------------------------------------------------------------------------------------------------------------------------------------
/************************************************************************************************************************************************************************/


//--------------------------------------------------------------------------------------------------------------------------------------------------
//DIMM Fault detect
//--------------------------------------------------------------------------------------------------------------------------------------------------
wire    w_p0_dimm_af_pwrgd_fail_event_clr;
wire    w_p0_dimm_gl_pwrgd_fail_event_clr;
wire    w_p1_dimm_af_pwrgd_fail_event_clr;
wire    w_p1_dimm_gl_pwrgd_fail_event_clr;

wire    w_p0_dimm_af_pwrgd_fail_event;
wire    w_p0_dimm_gl_pwrgd_fail_event;
wire    w_p1_dimm_af_pwrgd_fail_event;
wire    w_p1_dimm_gl_pwrgd_fail_event;


dimm_fail_event  cpu_dimm_fail_event(
.i_clk								(clk_50m 		),
.i_rst_n							(pon_reset_n	),
.i_dimm_pwrgd_fail_n	   		    ({
									 w_p0_dimm_af_pcamp_r | db_i_p0_bios_post_stage_r_n | (~w_st_steady_pwrok),	
									 w_p0_dimm_gl_pcamp_r | db_i_p0_bios_post_stage_r_n | (~w_st_steady_pwrok),
                                                                         w_p1_dimm_af_pcamp_r | db_i_p0_bios_post_stage_r_n | (~w_st_steady_pwrok),
                                                                         w_p1_dimm_gl_pcamp_r | db_i_p0_bios_post_stage_r_n | (~w_st_steady_pwrok) 
                                                                         }) ,
.i_dimm_pwrgd_fail_event_clr_n		 ({
									  w_p0_dimm_af_pwrgd_fail_event_clr,
									  w_p0_dimm_gl_pwrgd_fail_event_clr,
                                                                          w_p1_dimm_af_pwrgd_fail_event_clr,
									  w_p1_dimm_gl_pwrgd_fail_event_clr
									   }),
.o_dimm_pwrgd_fail_event			 ({
									  w_p0_dimm_af_pwrgd_fail_event,
									  w_p0_dimm_gl_pwrgd_fail_event,
                                                                          w_p1_dimm_af_pwrgd_fail_event,
									  w_p1_dimm_gl_pwrgd_fail_event                                                                         
									   })
);

//--------------------------------------------------------------------------------------------------------------------------------------------------
//error code 
//--------------------------------------------------------------------------------------------------------------------------------------------------
//2025-2-9 add
wire    w_bmc_clr_tmout_n;
wire    [7:0]  w_pwr_flt_code;
wire    w_p1v0_stby_m2_en_check;

edge_delay #(.CNTR_NBITS(2)) p1v0_stby_m2_check_inst (
  .clk                    (clk_50m          ),
  .reset                (~pon_reset_n),
  .cnt_size          (2'b10              ),
  .cnt_step          (t64ms_tick                          ),
  .signal_in        (w_p1v0_stby_m2_en            ),
  .delay_output  (w_p1v0_stby_m2_en_check)
);

fault_detectB_chklive #(.NUMBER_OF_VRM(1)) p1v0_stby_m2_fault_detect_inst (
  .clk                          (clk_50m            ),		//in
  .reset                      (~pon_reset_n  ),		//in
  .vrm_enable            (w_p1v0_stby_m2_en && w_p1v0_stby_m2_en_check),//in
  .vrm_pgood              (db_i_pg_p1v0_stby_m2_r       ),					//in
  .vrm_chklive_en    (w_p1v0_stby_m2_en_check     ),					//in
  .vrm_chklive_dis  (~w_p1v0_stby_m2_en_check   ),					//in
  .critical_fail      (w_st_critical_fail               ),					//in
  .fault_clear          (w_fault_clear                         ),					//in
  .lock                        (w_any_pwr_fault_det             ),				        //in
  .any_vrm_fault      ( ),									                //out
  .vrm_fault              (w_p1v0_stby_m2_fault_det   )					//out
);

error_code  error_code_int(
.i_clk								(clk_50m						),
.i_reset							(pon_reset_n					),
// .i_stby_failure_detected			(w_stby_failure_detected                ),
// .i_po_failure_detected				(w_dc_failure_detected			),
// .i_rt_failure_detected				(w_rt_failure_detected			),
// .i_any_pwr_fault_det				(w_any_pwr_fault_det			),
.i_power_fail_err_code_clr                   (~w_bmc_clr_tmout_n),

.i_p3v3_stby_fault_det				(w_p3v3_stby_fault_det			),	//0x02
.i_p5v0_stby_fault_det				(w_p5v_stby_fault_det			),	//0x03	//MB
.i_p12v_stby_fault_det				(1'b0			                                ),	//0x04  

.i_bmc_p3v3_bmc_rgm_fault_det		(1'b0	         ),	//0x0b	//from bmc 	
.i_bmc_p2v5_stby_fault_det			(1'b0		),	//0x0c	//from bmc
.i_bmc_p1v8_stby_fault_det			(1'b0		),	//0x0d	//from bmc
.i_bmc_p1v2_stby_fault_det			(1'b0		),	//0x0e	//from bmc
.i_cmu_p1v05_stby_fault_det			(1'b0		),	//0x0f	//from none 
.i_bmc_p1v0_stby_fault_det			(1'b0		),	//0x10	
.i_bmc_p3v3_stby_fault_det			(1'b0		),	//0x20
.i_bmc_p1v8_stby_pe_rc_fault_det	(1'b0	),	//0x21

.i_p1v0_stby_m2_fault_det			(w_p1v0_stby_m2_fault_det 	        ),	//0x22
// .i_p3v3_m2_fault_det				(1'b0		),//0x09	//from P3V3	//0x09	
.i_p5v_fault_det					(w_p5v_fault_det				),	//0x19

.i_grp_b_p0_18_s5_fault_det			(w_grp_b_p0_18_s5_fault_det		),	//0x05
.i_grp_b_p1_18_s5_fault_det			(w_grp_b_p1_18_s5_fault_det		),	//0x06	
.i_grp_b_p0_33_s5_fault_det			(w_grp_b_p0_33_s5_fault_det		),	//0x07
.i_grp_b_p1_33_s5_fault_det			(w_grp_b_p1_33_s5_fault_det		),	//0x08	 

.i_grp_c_p0_fault_det				(w_grp_c_p0_fault_det			),	//0x1e
.i_grp_c_p1_fault_det				(w_grp_c_p1_fault_det		        ),	//0x1f	 

.i_grp_d_vddio_p0_fault_det			(w_grp_d_vddio_p0_fault_det		),	//0x11
.i_grp_d_vddio_p1_fault_det			(w_grp_d_vddio_p1_fault_det		),						 
.i_grp_d_soc_p0_fault_det			(w_grp_d_soc_p0_fault_det		),  //0x13
.i_grp_d_soc_p1_fault_det			(w_grp_d_soc_p1_fault_det		),						 
.i_grp_d_p0_vddcore0_fault_det		(w_grp_d_p0_vddcore0_fault_det	),	//0x15
.i_grp_d_p0_vddcore1_fault_det		(w_grp_d_p0_vddcore1_fault_det	),	//0x16
.i_grp_d_p1_vddcore0_fault_det		(w_grp_d_p1_vddcore0_fault_det	),						 
.i_grp_d_p1_vddcore1_fault_det		(w_grp_d_p1_vddcore1_fault_det	),						 

 

    .o_pwr_flt_code                        (w_pwr_flt_code)
);

wire    w_power_fault_detected	;
assign  w_power_fault_detected	= w_rt_failure_detected | w_stby_failure_detected  ;	




//MCIO
wire    [15:0]    w_mb_to_bp_mciop0p0a_data;
wire    [15:0]    w_mb_to_bp_mciop0p0c_data;

wire    [15:0]    w_bp_to_mb_mciop0p0a_data;
wire    [15:0]    w_bp_to_mb_mciop0p0c_data;

wire    w_pal_p0_mciop0a_pwr_en;
wire    w_pal_p0_mciop0c_pwr_en;


wire    [5:0]   w_mcio_rsvd_bit15_10;
wire    [1:0]   w_mcio_rsvd_bit9_8;
wire    [2:0]   w_mcio_rsvd_bit7_5;
wire    [3:0]   w_mcio_vpp_addr_bit4_1;

assign  w_mcio_rsvd_bit15_10       =    6'b0;
assign  w_mcio_rsvd_bit9_8          =    2'b11;
assign  w_mcio_rsvd_bit7_5           =    3'b100;
assign  w_mcio_vpp_addr_bit4_1  =   4'b0000;

assign  w_mb_to_bp_mciop0p0a_data     =   {w_mcio_rsvd_bit15_10,w_mcio_rsvd_bit9_8,w_mcio_rsvd_bit7_5,w_mcio_vpp_addr_bit4_1,w_pal_p0_mciop0a_pwr_en};
assign  w_mb_to_bp_mciop0p0c_data     =   {w_mcio_rsvd_bit15_10,w_mcio_rsvd_bit9_8,w_mcio_rsvd_bit7_5,w_mcio_vpp_addr_bit4_1,w_pal_p0_mciop0c_pwr_en};

assign  w_p0_mciop0a_slot_id    =   w_bp_to_mb_mciop0p0a_data[7:0];
assign  w_p0_mciop0c_slot_id    =   w_bp_to_mb_mciop0p0c_data[7:0];

assign w_pal_p0_mciop0a_pwr_en    = (w_PWRGD_P12V && db_i_p0_slp_s5_n) ? 1'b1 : 1'b0   ;  
assign w_pal_p0_mciop0c_pwr_en    = (w_PWRGD_P12V && db_i_p0_slp_s5_n) ? 1'b1 : 1'b0   ;  

//--------------------------------------------------------------------------------------------------------------------------------------------------
// CPU0 P0A  --> J185    MCIOP0A
// -------------------------------------------------------------------------------------------------------------------------------------------------
UART_MASTER #(.NBIT_IN(16), .NBIT_OUT(16), .BPS_COUNT_NUM(48), .START_COUNT_NUM(24)) uart_master_u1 (
	.clk                        (clk_50m            )  ,             //input
	.rst                        (~pon_reset_n  )  ,             //input
	.tick                      (t16us_tick      )  ,             //input
	.send_enable        (1'b1                  )  ,             //input
         .t128ms_tick       (t128ms_tick    )  ,             //input
	.par_data_in        (w_mb_to_bp_mciop0p0a_data)  , //input 
	.par_data_out      (w_bp_to_mb_mciop0p0a_data)  , //output
	.ser_data              (io_P0_MCIOP0A_PWR_EN_R      )  , //inout
         .riser_en_out     (w_pal_p0_mciop0a_pwr_en    )  , //input
	.mcio_cable_id0  (w_P0_MCIOP0A_CB_ID0_R        )  , //input
	.mcio_cable_id1  (w_P0_MCIOP0A_CB_ID1_R        )  , //input

	.error_flag          (  )                          //output
);
//--------------------------------------------------------------------------------------------------------------------------------------------------
// CPU0 P0C  --> J48    MCIOP0C
// -------------------------------------------------------------------------------------------------------------------------------------------------
UART_MASTER #(.NBIT_IN(16), .NBIT_OUT(16), .BPS_COUNT_NUM(48), .START_COUNT_NUM(24)) uart_master_u2 (
	.clk                        (clk_50m            )  ,             //input
	.rst                        (~pon_reset_n  )  ,             //input
	.tick                      (t16us_tick      )  ,             //input
	.send_enable        (1'b1                  )  ,             //input
         .t128ms_tick       (t128ms_tick    )  ,             //input
	.par_data_in        (w_mb_to_bp_mciop0p0c_data)  , //input 
	.par_data_out      (w_bp_to_mb_mciop0p0c_data)  , //output
	.ser_data              (io_P0_MCIOP0C_PWR_EN_R      )  , //inout
         .riser_en_out     (w_pal_p0_mciop0c_pwr_en    )  , //input
	.mcio_cable_id0  (w_P0_MCIOP0C_CB_ID0_R        )  , //input
	.mcio_cable_id1  (w_P0_MCIOP0C_CB_ID1_R        )  , //input

	.error_flag          (  )                          //output
);

assign  w_p0_mciop1a_slot_id[0] =   1'b0;
assign  w_p0_mciop1c_slot_id[0] =   1'b0;
assign  w_p0_mciop2a_slot_id[0] =   1'b0;
assign  w_p0_mciop2c_slot_id[0] =   1'b0;
assign  w_p0_mciop3a_slot_id[0] =   1'b0;
assign  w_p0_mciop3c_slot_id[0] =   1'b0;
assign  w_p0_mciog3a_slot_id[0] =   1'b0;
assign  w_p0_mciog3c_slot_id[0] =   1'b0;
assign  w_p1_mciog1a_slot_id[0] =   1'b0;
assign  w_p1_mciog1c_slot_id[0] =   1'b0;
assign  w_p1_mciop3a_slot_id[0] =   1'b0;
assign  w_p1_mciop3c_slot_id[0] =   1'b0;
assign  w_p1_mciop3a_slot_id[0] =   1'b0;
assign  w_p1_mciop3c_slot_id[0] =   1'b0;
assign  w_p1_mciop3a_slot_id[0] =   1'b0;
assign  w_p1_mciop3c_slot_id[0] =   1'b0;
assign  w_p1_mciop3a_slot_id[0] =   1'b0;
assign  w_p1_mciop3c_slot_id[0] =   1'b0;
//SERVER_ID_C5
wire    [7:0]  w_server_id_c5;

assign  w_server_id_c5  =   (w_bf_type==2'b10)?8'h60:8'h41;

//------------------------------------------------------------------------------
//ESPI
// ------------------------------------------------------------------------------    
wire [15:0]  pch_espi_addr ;
wire [7:0]   pch_espi_wdata ;
wire [7:0]   pch_espi_rdata ;
wire         pch_smbus_wdata_en ;

wire [7:0]   w_espi_debug_ram_1000;
wire [7:0]   w_espi_debug_ram_1001;
wire [7:0]   w_espi_debug_ram_1002;
wire [7:0]   w_espi_debug_ram_1003;
wire [7:0]   w_espi_debug_ram_1004;
wire [7:0]   w_espi_debug_ram_1005;
wire [7:0]   w_espi_debug_ram_1006;

wire [7:0]   w_espi_ram_1050;
wire [7:0]   w_espi_ram_1051;
wire [7:0]   w_espi_ram_1052;
wire [7:0]   w_espi_ram_1053;  //2023-11-8 add
wire [7:0]   w_espi_ram_1054;  //2023-11-8 add
wire    [7:0]   w_espi_ram_1055;
wire    [7:0]   w_espi_ram_1056;
wire    [7:0]   w_espi_ram_1057;
wire    [7:0]   w_espi_ram_1058;

espi_link bios_espi_link(
    .ESPI_CLK    (i_CPLD_ESPI_CLK    ),                                            //input
    .ESPI_RST    (i_CPLD_ESPI_RESET_N    ),                                            //input
    .ESPI_CS1    (i_CPLD_ESPI_CS_N   ),                                            //input
    .ESPI_IO_IN  (i_CPLD_ESPI_D0     ),                                            //input
    .ESPI_IO_OUT (o_CPLD_ESPI_D1    ),                                            //output
    .pch_addr    (pch_espi_addr),//pch_espi_addr                                  //output
    .pch_smbus_wdata(pch_espi_wdata),//pch_espi_wdata                             //output
    .pch_smbus_rdata(pch_espi_rdata),//pch_espi_rdata                             //input
    .pch_smbus_wdata_en(pch_smbus_wdata_en), // pch_smbus_wdata_en      //output
    .debug_flag  (       ),//debug_flag                                           //output
    .debug_flag1 (      ),//debug_flag1                                           //output
    .debug_flag2 (      )//debug_flag2                                            //output
);

pch_cpld_espi_ram  pch_cpld_espi_ram_u1
(
    .i_rst_n                            (pon_reset_n),
    .i_clk                                (clk_50m),
    .i_clk_10ms                      (w10mSCE),//w10mSCE
    .i_espi_addr                    (pch_espi_addr),
    .i_espi_date_out            (pch_espi_wdata),
    .o_espi_date_in              (pch_espi_rdata),
    .i_espi_wdata_en            (pch_smbus_wdata_en),	

//////////////////////////////////pcie dync alloc start 0x1000-0x1005///////////////////////////
    .i_p0_mciog3a_cb_id0            (w_P0_MCIOG3A_CB_ID0_R),
    .i_p0_mciog3a_cb_id1            (w_P0_MCIOG3A_CB_ID1_R),
    .i_p0_mciog3c_cb_id0            (w_P0_MCIOG3C_CB_ID0_R),
    .i_p0_mciog3c_cb_id1            (w_P0_MCIOG3C_CB_ID1_R),

    .i_p0_mciop0a_cb_id0            (w_P0_MCIOP0A_CB_ID0_R),
    .i_p0_mciop0a_cb_id1            (w_P0_MCIOP0A_CB_ID1_R),
    .i_p0_mciop0c_cb_id0            (w_P0_MCIOP0C_CB_ID0_R),
    .i_p0_mciop0c_cb_id1            (w_P0_MCIOP0C_CB_ID1_R),
    
    .i_p0_mciop1a_cb_id0            (w_P0_MCIOP1A_CB_ID0_R),
    .i_p0_mciop1a_cb_id1            (w_P0_MCIOP1A_CB_ID1_R),
    .i_p0_mciop1c_cb_id0            (w_P0_MCIOP1C_CB_ID0_R),
    .i_p0_mciop1c_cb_id1            (w_P0_MCIOP1C_CB_ID1_R),
    
    .i_p0_mciop2a_cb_id0            (w_P0_MCIOP2A_CB_ID0_R),
    .i_p0_mciop2a_cb_id1            (w_P0_MCIOP2A_CB_ID1_R),
    .i_p0_mciop2c_cb_id0            (w_P0_MCIOP2C_CB_ID0_R),
    .i_p0_mciop2c_cb_id1            (w_P0_MCIOP2C_CB_ID1_R),

    .i_p0_mciop3a_cb_id0            (w_P0_MCIOP3A_CB_ID0_R),
    .i_p0_mciop3a_cb_id1            (w_P0_MCIOP3A_CB_ID1_R),
    .i_p0_mciop3c_cb_id0            (w_P0_MCIOP3C_CB_ID0_R),
    .i_p0_mciop3c_cb_id1            (w_P0_MCIOP3C_CB_ID1_R),

    .i_p1_mciog1a_cb_id0            (w_P1_MCIOG1A_CB_ID0_R),
    .i_p1_mciog1a_cb_id1            (w_P1_MCIOG1A_CB_ID1_R),
    .i_p1_mciog1c_cb_id0            (w_P1_MCIOG1C_CB_ID0_R),
    .i_p1_mciog1c_cb_id1            (w_P1_MCIOG1C_CB_ID1_R),

    .i_p1_mciop0a_cb_id0            (w_P1_MCIOP0A_CB_ID0_R),
    .i_p1_mciop0a_cb_id1            (w_P1_MCIOP0A_CB_ID1_R),
    .i_p1_mciop0c_cb_id0            (w_P1_MCIOP0C_CB_ID0_R),
    .i_p1_mciop0c_cb_id1            (w_P1_MCIOP0C_CB_ID1_R),

    .i_p1_mciop1a_cb_id0            (w_P1_MCIOP1A_CB_ID0_R),
    .i_p1_mciop1a_cb_id1            (w_P1_MCIOP1A_CB_ID1_R),
    .i_p1_mciop1c_cb_id0            (w_P1_MCIOP1C_CB_ID0_R),
    .i_p1_mciop1c_cb_id1            (w_P1_MCIOP1C_CB_ID1_R),

    .i_p1_mciop2a_cb_id0            (w_P1_MCIOP2A_CB_ID0_R),
    .i_p1_mciop2a_cb_id1            (w_P1_MCIOP2A_CB_ID1_R),
    .i_p1_mciop2c_cb_id0            (w_P1_MCIOP2C_CB_ID0_R),
    .i_p1_mciop2c_cb_id1            (w_P1_MCIOP2C_CB_ID1_R),

    .i_p1_mciop3a_cb_id0            (w_P1_MCIOP3A_CB_ID0_R),
    .i_p1_mciop3a_cb_id1            (w_P1_MCIOP3A_CB_ID1_R),
    .i_p1_mciop3c_cb_id0            (w_P1_MCIOP3C_CB_ID0_R),
    .i_p1_mciop3c_cb_id1            (w_P1_MCIOP3C_CB_ID1_R),

//////////////////////////////////0x00C0-0x00D0 for FIX REG/////////////////////////////////////////////////////////////////////////////
    .i_PRODUCT_LINE_C2	        (`PRODUCT_LINE_C2  ),
    .i_PRODUCT_GEN_ID_C3            (`PRODUCT_GEN_ID_C3),
    .i_SERVER_ID_C5                      ( w_server_id_c5    ),//2025-3-13  del`SERVER_ID_C5 
    .i_BOARD_ID_C6                        (`BOARD_ID_C6      ),
//////////////////////////////////0x00C0-0x00D0 for FIX REG/////////////////////////////////////////////////////////////////////////////

///////////////////////////////////pcie dync alloc end 0x1000-0x1005/////////////////////////
	//test 0x1006
    .o_espi_debug_ram_1000     (w_espi_debug_ram_1000),
    .o_espi_debug_ram_1001     (w_espi_debug_ram_1001),
    .o_espi_debug_ram_1002     (w_espi_debug_ram_1002),
    .o_espi_debug_ram_1003     (w_espi_debug_ram_1003),
    .o_espi_debug_ram_1004     (w_espi_debug_ram_1004),
    .o_espi_debug_ram_1005     (w_espi_debug_ram_1005),
    .o_test_reg                           (w_espi_debug_ram_1006),    //addr 0x1006

    .i_espi_ram_1050        (w_espi_ram_1050),
    .i_espi_ram_1051        (w_espi_ram_1051),
    .i_espi_ram_1052        (w_espi_ram_1052),
    .i_espi_ram_1053        (w_espi_ram_1053),

/////////////////2024-3-3 ADD/////////////////////////////////////         
    .i_espi_ram_1100            (w_p0_mciop0a_slot_id),//CPU0-P0A  J185    SLOT_ID
    .i_espi_ram_1101            (w_p0_mciop0c_slot_id),//CPU0-P0C  J48    SLOT_ID
    .i_espi_ram_1102            (w_p0_mciop1a_slot_id),//CPU0-P1A  J75    SLOT_ID
    .i_espi_ram_1103            (w_p0_mciop1c_slot_id),//CPU0-P1C  J76    SLOT_ID
    .i_espi_ram_1104            (w_p0_mciop2a_slot_id),//CPU0-P2A  J40    SLOT_ID
    .i_espi_ram_1105            (w_p0_mciop2c_slot_id),//CPU0-P2C  J41    SLOT_ID
    .i_espi_ram_1106            (w_p0_mciop3a_slot_id),//CPU0-P3A  J42    SLOT_ID
    .i_espi_ram_1107            (w_p0_mciop3c_slot_id),//CPU0-P3C  J43    SLOT_ID
    .i_espi_ram_1108            (w_p0_mciog3a_slot_id),//CPU0-G3A  J45    SLOT_ID
    .i_espi_ram_1109            (w_p0_mciog3c_slot_id),//CPU0-G3C  J44    SLOT_ID
    
    .i_espi_ram_110a            (w_p1_mciop0a_slot_id),//CPU1-P0A  J73    SLOT_ID
    .i_espi_ram_110b            (w_p1_mciop0c_slot_id),//CPU1-P0C  J74    SLOT_ID
    .i_espi_ram_110c            (w_p1_mciop1a_slot_id),//CPU1-P1A  J204    SLOT_ID
    .i_espi_ram_110d            (w_p1_mciop1c_slot_id),//CPU1-P1C  J203    SLOT_ID
    .i_espi_ram_110e            (w_p1_mciop2a_slot_id),//CPU1-P2A  J205    SLOT_ID
    .i_espi_ram_110f            (w_p1_mciop2c_slot_id),//CPU1-P2C  J206    SLOT_ID
    .i_espi_ram_1110            (w_p1_mciop3a_slot_id),//CPU1-P3A  J207    SLOT_ID
    .i_espi_ram_1111            (w_p1_mciop3c_slot_id),//CPU1-P3C  J208    SLOT_ID
    .i_espi_ram_1112            (w_p1_mciog1a_slot_id),//CPU1-G1A  J210    SLOT_ID        
    .i_espi_ram_1113            (w_p1_mciog1c_slot_id)  //CPU1-G1C  J209    SLOT_ID

);

//------------------------------------------------------------------------------------------------//
//BIOS_CPLD_IIC
//------------------------------------------------------------------------------------------------//
wire [7:0]   w_bios_debug_ram_1000;
wire [7:0]   w_bios_debug_ram_1001;
wire [7:0]   w_bios_debug_ram_1002;
wire [7:0]   w_bios_debug_ram_1003;
wire [7:0]   w_bios_debug_ram_1004;
wire [7:0]   w_bios_debug_ram_1005;
wire [7:0]   w_bios_debug_ram_1006;



bios_cpld_i2c_ram #(
.DLY_LEN       (16)   //50MHz,330ns
)bios_cpld_i2c_ram_u0
(
.i_rst_n		(pon_reset_n	),  
.i_clk			(clk_25m		),
.i_1ms_clk		(t1ms_tick		),	          
.i_rst_i2c_n	(1'b1			),		
.i_scl			(i_P0_CPLD_SCL	), 
.io_sda			(io_P0_CPLD_SDA	),

//////////////////////////////////pcie dync alloc start 0x1000-0x1005///////////////////////////
    .i_p0_mciog3a_cb_id0            (w_P0_MCIOG3A_CB_ID0_R),
    .i_p0_mciog3a_cb_id1            (w_P0_MCIOG3A_CB_ID1_R),
    .i_p0_mciog3c_cb_id0            (w_P0_MCIOG3C_CB_ID0_R),
    .i_p0_mciog3c_cb_id1            (w_P0_MCIOG3C_CB_ID1_R),

    .i_p0_mciop0a_cb_id0            (w_P0_MCIOP0A_CB_ID0_R),
    .i_p0_mciop0a_cb_id1            (w_P0_MCIOP0A_CB_ID1_R),
    .i_p0_mciop0c_cb_id0            (w_P0_MCIOP0C_CB_ID0_R),
    .i_p0_mciop0c_cb_id1            (w_P0_MCIOP0C_CB_ID1_R),
    
    .i_p0_mciop1a_cb_id0            (w_P0_MCIOP1A_CB_ID0_R),
    .i_p0_mciop1a_cb_id1            (w_P0_MCIOP1A_CB_ID1_R),
    .i_p0_mciop1c_cb_id0            (w_P0_MCIOP1C_CB_ID0_R),
    .i_p0_mciop1c_cb_id1            (w_P0_MCIOP1C_CB_ID1_R),
    
    .i_p0_mciop2a_cb_id0            (w_P0_MCIOP2A_CB_ID0_R),
    .i_p0_mciop2a_cb_id1            (w_P0_MCIOP2A_CB_ID1_R),
    .i_p0_mciop2c_cb_id0            (w_P0_MCIOP2C_CB_ID0_R),
    .i_p0_mciop2c_cb_id1            (w_P0_MCIOP2C_CB_ID1_R),

    .i_p0_mciop3a_cb_id0            (w_P0_MCIOP3A_CB_ID0_R),
    .i_p0_mciop3a_cb_id1            (w_P0_MCIOP3A_CB_ID1_R),
    .i_p0_mciop3c_cb_id0            (w_P0_MCIOP3C_CB_ID0_R),
    .i_p0_mciop3c_cb_id1            (w_P0_MCIOP3C_CB_ID1_R),

    .i_p1_mciog1a_cb_id0            (w_P1_MCIOG1A_CB_ID0_R),
    .i_p1_mciog1a_cb_id1            (w_P1_MCIOG1A_CB_ID1_R),
    .i_p1_mciog1c_cb_id0            (w_P1_MCIOG1C_CB_ID0_R),
    .i_p1_mciog1c_cb_id1            (w_P1_MCIOG1C_CB_ID1_R),

    .i_p1_mciop0a_cb_id0            (w_P1_MCIOP0A_CB_ID0_R),
    .i_p1_mciop0a_cb_id1            (w_P1_MCIOP0A_CB_ID1_R),
    .i_p1_mciop0c_cb_id0            (w_P1_MCIOP0C_CB_ID0_R),
    .i_p1_mciop0c_cb_id1            (w_P1_MCIOP0C_CB_ID1_R),

    .i_p1_mciop1a_cb_id0            (w_P1_MCIOP1A_CB_ID0_R),
    .i_p1_mciop1a_cb_id1            (w_P1_MCIOP1A_CB_ID1_R),
    .i_p1_mciop1c_cb_id0            (w_P1_MCIOP1C_CB_ID0_R),
    .i_p1_mciop1c_cb_id1            (w_P1_MCIOP1C_CB_ID1_R),

    .i_p1_mciop2a_cb_id0            (w_P1_MCIOP2A_CB_ID0_R),
    .i_p1_mciop2a_cb_id1            (w_P1_MCIOP2A_CB_ID1_R),
    .i_p1_mciop2c_cb_id0            (w_P1_MCIOP2C_CB_ID0_R),
    .i_p1_mciop2c_cb_id1            (w_P1_MCIOP2C_CB_ID1_R),

    .i_p1_mciop3a_cb_id0            (w_P1_MCIOP3A_CB_ID0_R),
    .i_p1_mciop3a_cb_id1            (w_P1_MCIOP3A_CB_ID1_R),
    .i_p1_mciop3c_cb_id0            (w_P1_MCIOP3C_CB_ID0_R),
    .i_p1_mciop3c_cb_id1            (w_P1_MCIOP3C_CB_ID1_R),

//////////////////////////////////0x00C0-0x00D0 for FIX REG/////////////////////////////////////////////////////////////////////////////
    .i_PRODUCT_LINE_C2	        (`PRODUCT_LINE_C2  ),
    .i_PRODUCT_GEN_ID_C3            (`PRODUCT_GEN_ID_C3),
    .i_SERVER_ID_C5                      (w_server_id_c5     ),//2025-3-13  del `SERVER_ID_C5 
    .i_BOARD_ID_C6                        (`BOARD_ID_C6      ),
//////////////////////////////////0x00C0-0x00D0 for FIX REG/////////////////////////////////////////////////////////////////////////////

///////////////////////////////////pcie dync alloc end 0x1000-0x1005/////////////////////////
	//test 0x1006
    .o_espi_debug_ram_1000     (w_bios_debug_ram_1000),
    .o_espi_debug_ram_1001     (w_bios_debug_ram_1001),
    .o_espi_debug_ram_1002     (w_bios_debug_ram_1002),
    .o_espi_debug_ram_1003     (w_bios_debug_ram_1003),
    .o_espi_debug_ram_1004     (w_bios_debug_ram_1004),
    .o_espi_debug_ram_1005     (w_bios_debug_ram_1005),
    .o_test_reg                           (w_bios_debug_ram_1006),    //addr 0x1006

    .i_switch_mode                     (r_switch_mode         ) , // w_ram_1010
    .i_switch2_mode                   (r_switch2_mode       ) , // w_ram_1011

    .i_espi_ram_1050        (w_espi_ram_1050),
    .i_espi_ram_1051        (w_espi_ram_1051),
    .i_espi_ram_1052        (w_espi_ram_1052),
    .i_espi_ram_1053        (w_espi_ram_1053),
    .i_espi_ram_1054        (w_espi_ram_1054),
    .i_espi_ram_1055        (w_espi_ram_1055),
    .i_espi_ram_1056        (w_espi_ram_1056),
    .i_espi_ram_1057        (w_espi_ram_1057),
    .i_espi_ram_1058        (w_espi_ram_1058),

/////////////////2024-3-3 ADD/////////////////////////////////////         
    .i_espi_ram_1100            (w_p0_mciop0a_slot_id),//CPU0-P0A  J185    SLOT_ID
    .i_espi_ram_1101            (w_p0_mciop0c_slot_id),//CPU0-P0C  J48    SLOT_ID
    .i_espi_ram_1102            (w_p0_mciop1a_slot_id),//CPU0-P1A  J75    SLOT_ID
    .i_espi_ram_1103            (w_p0_mciop1c_slot_id),//CPU0-P1C  J76    SLOT_ID
    .i_espi_ram_1104            (w_p0_mciop2a_slot_id),//CPU0-P2A  J40    SLOT_ID
    .i_espi_ram_1105            (w_p0_mciop2c_slot_id),//CPU0-P2C  J41    SLOT_ID
    .i_espi_ram_1106            (w_p0_mciop3a_slot_id),//CPU0-P3A  J42    SLOT_ID
    .i_espi_ram_1107            (w_p0_mciop3c_slot_id),//CPU0-P3C  J43    SLOT_ID
    .i_espi_ram_1108            (w_p0_mciog3a_slot_id),//CPU0-G3A  J45    SLOT_ID
    .i_espi_ram_1109            (w_p0_mciog3c_slot_id),//CPU0-G3C  J44    SLOT_ID
    
    .i_espi_ram_110a            (w_p1_mciop0a_slot_id),//CPU1-P0A  J73    SLOT_ID
    .i_espi_ram_110b            (w_p1_mciop0c_slot_id),//CPU1-P0C  J74    SLOT_ID
    .i_espi_ram_110c            (w_p1_mciop1a_slot_id),//CPU1-P1A  J204    SLOT_ID
    .i_espi_ram_110d            (w_p1_mciop1c_slot_id),//CPU1-P1C  J203    SLOT_ID
    .i_espi_ram_110e            (w_p1_mciop2a_slot_id),//CPU1-P2A  J205    SLOT_ID
    .i_espi_ram_110f            (w_p1_mciop2c_slot_id),//CPU1-P2C  J206    SLOT_ID
    .i_espi_ram_1110            (w_p1_mciop3a_slot_id),//CPU1-P3A  J207    SLOT_ID
    .i_espi_ram_1111            (w_p1_mciop3c_slot_id),//CPU1-P3C  J208    SLOT_ID
    .i_espi_ram_1112            (w_p1_mciog1a_slot_id),//CPU1-G1A  J210    SLOT_ID        
    .i_espi_ram_1113            (w_p1_mciog1c_slot_id)  //CPU1-G1C  J209    SLOT_ID

);

//----------------------------------------------------------------------------------//
//delay
//----------------------------------------------------------------------------------//
edge_delay #(.CNTR_NBITS(1), .DELAY_MODE(1'b0)) edge_delay_rst_srst_bmc_b_n_1ms (   //DELAY_MODE =0 for rise edge
    .clk         (clk_50m),
    .reset       (~pon_reset_n),
    .cnt_size    (1'b1),
    .cnt_step    (t1ms_tick),
    .signal_in   (wBMC_PWR_OK),
    .delay_output(w_pal_bmc_srst_n_r) 
  );

edge_delay #(.CNTR_NBITS(6), .DELAY_MODE(1'b0)) edge_delay_slot_0_on_dly_10ms (   //DELAY_MODE =0 for rise edge
    .clk         (clk_50m),
    .reset       (~pon_reset_n),
    .cnt_size    (6'd10),
    .cnt_step    (t1ms_tick),
    .signal_in   (db_i_p0_slp_s5_n),//2024-4-10 chg w_PWRGD_P12V to w_pch_slp5_n
    .delay_output(w_slot_0_on_dly_10ms)
  );

edge_delay #(.CNTR_NBITS(6), .DELAY_MODE(1'b0)) edge_delay_slot_1_on_dly_10ms (   //DELAY_MODE =0 for rise edge
    .clk         (clk_50m),
    .reset       (~pon_reset_n),
    .cnt_size    (6'd10),
    .cnt_step    (t1ms_tick),
    .signal_in   (w_slot_0_on_dly_10ms),
    .delay_output(w_slot_1_on_dly_10ms)
  );

edge_delay #(.CNTR_NBITS(6), .DELAY_MODE(1'b0)) edge_delay_slot_2_on_dly_10ms (   //DELAY_MODE =0 for rise edge
    .clk         (clk_50m),
    .reset       (~pon_reset_n),
    .cnt_size    (6'd10),
    .cnt_step    (t1ms_tick),
    .signal_in   (w_slot_1_on_dly_10ms),
    .delay_output(w_slot_2_on_dly_10ms)
  );

//--------------------------------------------------------------------------------------------------------------------------------------------------
//RTC clear cmos 
//--------------------------------------------------------------------------------------------------------------------------------------------------
//RTC Sensor SW
clear_cmos clear_cmos_int(
 .i_clk					(clk_50m			),
 .i_rst_n				(~w_st_steady_pwrok & pon_reset_n	),
 .i_clr_cmos_flg		        (w_clr_cmos_flg		),//clear sig from bmc iic ram 0x03A0 bit4
 .i_t64ms_tick			(t1s_tick			),
 .o_clr_cmos_done		(w_clr_cmos_done	),//output sig to clear the cmos
 .o_clr_cmos_done_rst	(w_clr_cmos_done_rst	)

);

 clear_nmi nmi_ctl_int(
 .i_clk					(clk_50m			),
 .i_rst_n				(pon_reset_n		),
 .i_clr_nmi_flg			(w_bmc_nmi_ctl		),	//from bmc iic ram 0x03A0 bit6
 .i_t64ms_tick			(t1s_tick			),
 .o_clr_nmi_done		(w_bmc_nmi_ctl_done	),	//output sig for NMI
 .o_clr_nmi_done_rst	(w_bmc_nmi_ctl_rst	)
);
assign  w_p0_nmi_sync_flood_n = ~w_bmc_nmi_ctl_done; 
assign  w_p1_nmi_sync_flood_n = ~w_bmc_nmi_ctl_done; 

// assign o_EPR_WP_N    	= eeprom_wp;			
// assign bmc_alarm_flag	= |bmc_wdt_rst_evt;
assign w_dimm_alarm_flag	= w_p0_dimm_gl_pwrgd_fail_event | w_p0_dimm_af_pwrgd_fail_event;	//p1_dimm_gl_pwrgd_fail_event|p1_dimm_af_pwrgd_fail_event|

// assign btn_press_flag	= ~(/* db_i_pal_button_rst_n & */ db_i_pwr_btn_cpld_n_r & io_uid_btn_n);	//change to io_uid_btn_n

//--------------------------------------------------------------------------------------------------------------------------------------------------
//CPLD hitless  
//--------------------------------------------------------------------------------------------------------------------------------------------------
// wire hitless_reset_n				;
// wire hitless_en						;
//110bit 20241226
// wire [96:0] user_outputs			;	
// wire [96:0] pre_load_feedback		;	
// wire [96:0] normal_reset_value		;	

// always @(posedge clk_50m or negedge pon_reset_n)    
// begin
	// if (~pon_reset_n)
	// begin
		// power_seq_sm_fb[5:0]	<= power_seq_sm_fb[5:0]	;
		// r_uid_led_fb			<= r_uid_led_fb;				// UID LED hitless
	// end
	// else
	// begin
		// power_seq_sm_fb[5:0]	<= pre_load_feedback[5:0]	;
		// r_uid_led_fb			<= {8{pre_load_feedback[106]}}	;		// UID LED hitless
	// end
// end
//assign power_seq_sm_fb[5:0] = pre_load_feedback[5:0];	// refer 2P V16


//-------------------------------------------------------------------------------------------------
// CPU0 PE0 --- switch board signal PVT_DATA   74lv165
//-------------------------------------------------------------------------------------------------
edge_delay #(.CNTR_NBITS(3), .DELAY_MODE(1'b0)) edge_delay_dc_pwr_on_2s (   //DELAY_MODE =0 for rise edge
    .clk         (clk_50m),
    .reset       (~pon_reset_n),
    .cnt_size    (3'd2),
    .cnt_step    (t1s_tick),
    .signal_in   (db_i_p0_slp_s3_n & db_i_pgd_p5v),
    .delay_output(w_pwr_on_dly2s)
  );
edge_delay #(.CNTR_NBITS(3), .DELAY_MODE(1'b0)) edge_delay_dc_pwr_on_1s5 (   //DELAY_MODE =0 for rise edge
    .clk         (clk_50m),
    .reset       (~pon_reset_n),
    .cnt_size    (3'd3),
    .cnt_step    (t512ms_tick),
    .signal_in   (db_i_p0_slp_s3_n & db_i_pgd_p5v),
    .delay_output(w_pwr_on_dly1s5)
  );
//-------------------------------------------------------------------------------------------------
// CPU0 PE0 --- PVT_DATA   74lv165 //2024-1-16 add for switch debug
//-------------------------------------------------------------------------------------------------
// pvt_gpi #(
  // .TOTAL_BIT_COUNT(8),
  // .DEFAULT_STATE(8'h0),
  // .NUMBER_OF_COUNTER_BITS(3)
// ) pvt_gpi_4u_gpu_sw_inst_u2 (
  // .clk           (clk_50m),                        //in
  // .reset_n       (~w_pwr_on_dly2s & pon_reset_n ),                    //in  //2024-9-4 add & ~w_pwr_on_dly2s
  // .clk_ena       (t1ms_tick),                     //in  //2024-9-3 t16us_tick
  // .serclk_in     (o_P0_MCIOP0A_CLK_R   ),         //in   
  // .par_load_in_n (o_P0_MCIOP0A_LD_R  ),          //in   
  // .sdi           (i_P0_MCIOP0A_DATAIN_R ),  //in   
  // .bit_idx_in    (pvti_sw_u2_count1),                  //in
  // .bit_idx_out   (pvti_sw_u2_count1),                  //out
  // .serclk_out       (o_P0_MCIOP0A_CLK_R ),        //out
  // .par_load_out_n(o_P0_MCIOP0A_LD_R  ),          //out

  // .par_data      ({
                    // w_pal_p12v_drop_sw,w_pg_p5v0_r_sw,w_pg_p1v8_r_sw,w_pg_p1v8_pll_r_sw ,
                    // w_db2000_pwrgd0_sw,w_db2000_pwrgd1_sw,w_mcio_slot13_prsnt_n_1_sw,w_u40_nc7_sw
		
			// })
// );

//-------------------------------------------------------------------------------------------------
// CPU0 PE0 --- ZT board & switch board signal  all in J48 J185
//-------------------------------------------------------------------------------------------------
pvt_gpi #(
  .TOTAL_BIT_COUNT(64),
  .DEFAULT_STATE(64'h0),
  .NUMBER_OF_COUNTER_BITS(6)
) pvt_gpi_4u_gpu_zt_inst (
  .clk                      (clk_50m),                        //in
  .reset_n              (~w_pwr_on_dly2s & pon_reset_n ),                    //in //2024-9-4 add & w_pwr_on_dly2s
  .clk_ena              (t1ms_tick),                     //in  //2024-9-3 t16us_tick
  .serclk_in          (o_P0_MCIOP1A_CLK_R    ),        //in   o_CPU0_MCIO3A_CLK_R     J42 A8
  .par_load_in_n  (o_P0_MCIOP1A_LD_R     ),        //in   o_CPU0_MCIO3A_LD_R      J42 A9
  .sdi                      (i_P0_MCIOP1A_DATAIN_R ),        //in   i_CPU0_MCIO3A_DATAIN_R  J42 B10
  .bit_idx_in        (pvti_zt_count),                  //in
  .bit_idx_out      (pvti_zt_count),                  //out
  .serclk_out        (o_P0_MCIOP1A_CLK_R   ),         //out o_CPU0_MCIO3A_CLK_R   J42 A8
  .par_load_out_n(o_P0_MCIOP1A_LD_R     ),         //out o_CPU0_MCIO3A_LD_R    J42 A9
                   //last bit
  .par_data      ({
                                w_tpm431_alert_n_zt,w_ina3221_pwr_alert_zt,w_pal_3v3_pgd1_r_zt,w_pal_3v3_pgd2_r_zt,
                                w_pal_3v3_pgd3_r_zt,w_pal_3v3_pgd4_r_zt,w_pal_3v3_pgd5_r_zt,w_u3_nc7_zt,
                                
                                w_slot1_prsnt_n_zt,w_slot2_prsnt_n_zt,w_slot3_prsnt_n_zt,w_slot4_prsnt_n_zt,
                                w_slot5_prsnt_n_zt,w_slot6_prsnt_n_zt,w_slot7_prsnt_n_zt,w_slot8_prsnt_n_zt,

                                w_slot9_prsnt_n_zt ,w_slot10_prsnt_n_zt,w_slot11_prsnt_n_zt,w_slot12_prsnt_n_zt,
                                w_slot13_prsnt_n_zt,w_mcio1_prsnt_n_zt ,w_mcio2_prsnt_n_zt ,w_mcio3_prsnt_n_zt ,

                                w_mcio4_prsnt_n_zt ,w_mcio5_prsnt_n_zt ,w_mcio6_prsnt_n_zt ,w_mcio7_prsnt_n_zt ,
                                w_mcio8_prsnt_n_zt ,w_mcio9_prsnt_n_zt ,w_mcio10_prsnt_n_zt,w_mcio11_prsnt_n_zt,

                                w_mcio12_prsnt_n_zt,w_mcio13_prsnt_n_zt,w_pcb_version2_zt,  w_pcb_version1_zt,  
                                w_pcb_version0_zt,  w_pca_version2_zt,  w_pca_version1_zt,  w_pca_version0_zt,  

                                w_board_id0_zt,w_board_id1_zt,w_board_id2_zt,w_board_id3_zt,
                                w_board_id4_zt,w_board_id5_zt,w_board_id6_zt,w_board_id7_zt,

                                w_mcio1_prsnt_n_1_zt ,w_mcio2_prsnt_n_1_zt ,w_mcio3_prsnt_n_1_zt ,w_mcio4_prsnt_n_1_zt ,
                                w_mcio5_prsnt_n_1_zt ,w_mcio7_prsnt_n_1_zt ,w_mcio9_prsnt_n_1_zt ,w_mcio10_prsnt_n_1_zt,

                                w_mcio11_prsnt_n_1_zt,w_mcio12_prsnt_n_1_zt,w_u19_nc2_zt,w_u19_nc3_zt,
                                w_u19_nc4_zt,w_u19_nc5_zt,w_u19_nc6_zt,w_u19_nc7_zt
                                })//first bit
);
//-------------------------------------------------------------------------------------------------
// 2024-9-6 add for cable error
//-------------------------------------------------------------------------------------------------
always@(posedge clk_50m or negedge pon_reset_n) begin //2024-9-6 add 
    if(~pon_reset_n) 
    begin
            r_board_id0_zt     <= w_board_id0_zt     ;
            r_board_id1_zt     <= w_board_id1_zt     ;
            r_board_id2_zt     <= w_board_id2_zt     ;
            r_board_id3_zt     <= w_board_id3_zt     ;
            r_board_id4_zt     <= w_board_id4_zt     ;
            r_board_id5_zt     <= w_board_id5_zt     ;
            r_board_id6_zt     <= w_board_id6_zt     ;
            r_board_id7_zt     <= w_board_id7_zt     ;
            r_pcb_version2_zt  <= w_pcb_version2_zt  ;
            r_pcb_version1_zt  <= w_pcb_version1_zt  ;
            r_pcb_version0_zt  <= w_pcb_version0_zt  ;
            r_pca_version2_zt  <= w_pca_version2_zt  ;
            r_pca_version1_zt  <= w_pca_version1_zt  ;
            r_pca_version0_zt  <= w_pca_version0_zt  ;
            r_mcio9_prsnt_n_zt <= w_mcio9_prsnt_n_zt ;
            r_mcio7_prsnt_n_zt <= w_mcio7_prsnt_n_zt ;
            r_mcio3_prsnt_n_zt <= w_mcio3_prsnt_n_zt ;
            r_mcio1_prsnt_n_zt <= w_mcio1_prsnt_n_zt ;
            r_mcio10_prsnt_n_zt<= w_mcio10_prsnt_n_zt;
            r_mcio8_prsnt_n_zt <= w_mcio8_prsnt_n_zt ;
            r_mcio6_prsnt_n_zt <= w_mcio6_prsnt_n_zt ;
            r_mcio4_prsnt_n_zt <= w_mcio4_prsnt_n_zt ;
	end
	else  begin  
	    if(w_pwr_on_dly1s5) 
            begin
                r_board_id0_zt     <= r_board_id0_zt     ;
                r_board_id1_zt     <= r_board_id1_zt     ;
                r_board_id2_zt     <= r_board_id2_zt     ;
                r_board_id3_zt     <= r_board_id3_zt     ;
                r_board_id4_zt     <= r_board_id4_zt     ;
                r_board_id5_zt     <= r_board_id5_zt     ;
                r_board_id6_zt     <= r_board_id6_zt     ;
                r_board_id7_zt     <= r_board_id7_zt     ;
                r_pcb_version2_zt  <= r_pcb_version2_zt  ;
                r_pcb_version1_zt  <= r_pcb_version1_zt  ;
                r_pcb_version0_zt  <= r_pcb_version0_zt  ;
                r_pca_version2_zt  <= r_pca_version2_zt  ;
                r_pca_version1_zt  <= r_pca_version1_zt  ;
                r_pca_version0_zt  <= r_pca_version0_zt  ;
                r_mcio9_prsnt_n_zt <= r_mcio9_prsnt_n_zt ;
                r_mcio7_prsnt_n_zt <= r_mcio7_prsnt_n_zt ;
                r_mcio3_prsnt_n_zt <= r_mcio3_prsnt_n_zt ;
                r_mcio1_prsnt_n_zt <= r_mcio1_prsnt_n_zt ;
                r_mcio10_prsnt_n_zt<= r_mcio10_prsnt_n_zt;
                r_mcio8_prsnt_n_zt <= r_mcio8_prsnt_n_zt ;
                r_mcio6_prsnt_n_zt <= r_mcio6_prsnt_n_zt ;
                r_mcio4_prsnt_n_zt <= r_mcio4_prsnt_n_zt ;
            end
            else begin
                r_board_id0_zt     <= w_board_id0_zt     ;
                r_board_id1_zt     <= w_board_id1_zt     ;
                r_board_id2_zt     <= w_board_id2_zt     ;
                r_board_id3_zt     <= w_board_id3_zt     ;
                r_board_id4_zt     <= w_board_id4_zt     ;
                r_board_id5_zt     <= w_board_id5_zt     ;
                r_board_id6_zt     <= w_board_id6_zt     ;
                r_board_id7_zt     <= w_board_id7_zt     ;
                r_pcb_version2_zt  <= w_pcb_version2_zt  ;
                r_pcb_version1_zt  <= w_pcb_version1_zt  ;
                r_pcb_version0_zt  <= w_pcb_version0_zt  ;
                r_pca_version2_zt  <= w_pca_version2_zt  ;
                r_pca_version1_zt  <= w_pca_version1_zt  ;
                r_pca_version0_zt  <= w_pca_version0_zt  ;
                r_mcio9_prsnt_n_zt <= w_mcio9_prsnt_n_zt ;
                r_mcio7_prsnt_n_zt <= w_mcio7_prsnt_n_zt ;
                r_mcio3_prsnt_n_zt <= w_mcio3_prsnt_n_zt ;
                r_mcio1_prsnt_n_zt <= w_mcio1_prsnt_n_zt ;
                r_mcio10_prsnt_n_zt<= w_mcio10_prsnt_n_zt;
                r_mcio8_prsnt_n_zt <= w_mcio8_prsnt_n_zt ;
                r_mcio6_prsnt_n_zt <= w_mcio6_prsnt_n_zt ;
                r_mcio4_prsnt_n_zt <= w_mcio4_prsnt_n_zt ;
            end
	end
end

//-------------------------------------------------------------------------------------------------
// ZT board or  switch board  judge
//-------------------------------------------------------------------------------------------------
assign  w_zt_board_id ={r_board_id7_zt,r_board_id6_zt,r_board_id5_zt,r_board_id4_zt,
                        r_board_id3_zt,r_board_id2_zt,r_board_id1_zt,r_board_id0_zt}; //2024-9-6

assign  w_sw_board_id ={w_board_id7_sw,w_board_id6_sw,w_board_id5_sw,w_board_id4_sw,
                        w_board_id3_sw,w_board_id2_sw,w_board_id1_sw,w_board_id0_sw};  

always@(posedge clk_50m or negedge pon_reset_n) begin
    if(~pon_reset_n) begin
		r_zt_board_prsnt_n <= 1'b0;
	end
	else if (w_zt_board_id == 8'h2d) begin  
	    r_zt_board_prsnt_n <= 1'b0;                                  
	end
	else 
	    r_zt_board_prsnt_n <= 1'b1;
end

assign w_zt_board_prsnt_n = r_zt_board_prsnt_n;//2024-9-9 add
//2024-4-30 SW CHG VB REMAPPED
assign  w_tpm431_alert_n_sw    = (r_zt_board_prsnt_n == 1'b1) ? w_tpm431_alert_n_zt    : 1'b1 ;//u3     
assign  w_ina3221_pwr_alert_sw = (r_zt_board_prsnt_n == 1'b1) ? w_ina3221_pwr_alert_zt : 1'b1 ;//u3     
assign  w_pal_3v3_pgd1_r_sw    = (r_zt_board_prsnt_n == 1'b1) ? w_pal_3v3_pgd1_r_zt    : 1'b1 ;//u3     
assign  w_pal_3v3_pgd2_r_sw    = (r_zt_board_prsnt_n == 1'b1) ? w_pal_3v3_pgd2_r_zt    : 1'b1 ;//u3     
assign  w_pal_3v3_pgd3_r_sw    = (r_zt_board_prsnt_n == 1'b1) ? w_pal_3v3_pgd3_r_zt    : 1'b1 ;//u3     
assign  w_pal_3v3_pgd4_r_sw    = (r_zt_board_prsnt_n == 1'b1) ? w_pal_3v3_pgd4_r_zt    : 1'b1 ;//u3     
assign  w_pal_3v3_pgd5_r_sw    = (r_zt_board_prsnt_n == 1'b1) ? w_pal_3v3_pgd5_r_zt    : 1'b1 ;//u3     
assign  w_u3_nc7_sw            = (r_zt_board_prsnt_n == 1'b1) && (w_sw_board_id == 8'h0d) ? w_u3_nc7_zt : 1'b1 ;//u3     

assign  w_mcio_slot11_prsnt_n_1= (r_zt_board_prsnt_n == 1'b1) && (w_sw_board_id == 8'h0c) ? w_u3_nc7_zt : 1'b1 ;//2024-9-24

assign  w_slot1_prsnt_n_sw     = (r_zt_board_prsnt_n == 1'b1) ? w_slot1_prsnt_n_zt : 1'b1     ;//u7     
assign  w_slot2_prsnt_n_sw     = (r_zt_board_prsnt_n == 1'b1) ? w_slot2_prsnt_n_zt : 1'b1     ;//u7     
assign  w_slot3_prsnt_n_sw     = (r_zt_board_prsnt_n == 1'b1) ? w_slot3_prsnt_n_zt : 1'b1     ;//u7     
assign  w_slot4_prsnt_n_sw     = (r_zt_board_prsnt_n == 1'b1) ? w_slot4_prsnt_n_zt : 1'b1     ;//u7     
assign  w_slot5_prsnt_n_sw     = (r_zt_board_prsnt_n == 1'b1) ? w_slot5_prsnt_n_zt : 1'b1     ;//u7     
assign  w_slot6_prsnt_n_sw     = (r_zt_board_prsnt_n == 1'b1) ? w_slot6_prsnt_n_zt : 1'b1     ;//u7     
assign  w_slot7_prsnt_n_sw     = (r_zt_board_prsnt_n == 1'b1) ? w_slot7_prsnt_n_zt : 1'b1     ;//u7     
assign  w_slot8_prsnt_n_sw     = (r_zt_board_prsnt_n == 1'b1) ? w_slot8_prsnt_n_zt : 1'b1     ;//u7     

assign  w_slot9_prsnt_n_sw     = (r_zt_board_prsnt_n == 1'b1) ? w_slot9_prsnt_n_zt  : 1'b1    ;//u8     
assign  w_slot10_prsnt_n_sw    = (r_zt_board_prsnt_n == 1'b1) ? w_slot10_prsnt_n_zt : 1'b1    ;//u8     
assign  w_slot11_prsnt_n_sw    = (r_zt_board_prsnt_n == 1'b1) ? w_slot11_prsnt_n_zt : 1'b1    ;//u8     
assign  w_slot12_prsnt_n_sw    = (r_zt_board_prsnt_n == 1'b1) ? w_slot12_prsnt_n_zt : 1'b1    ;//u8     
assign  w_slot13_prsnt_n_sw    = (r_zt_board_prsnt_n == 1'b1) ? w_slot13_prsnt_n_zt : 1'b1    ;//u8     
assign  w_mcio1_prsnt_n_sw     = (r_zt_board_prsnt_n == 1'b1) && (w_sw_board_id == 8'h0d) ? r_mcio1_prsnt_n_zt : //2024-9-24
                                 (r_zt_board_prsnt_n == 1'b1) && (w_sw_board_id == 8'h0c) ? r_mcio4_prsnt_n_zt : 1'b1    ;//u8    //2024-9-6 
assign  w_mcio2_prsnt_n_sw     = (r_zt_board_prsnt_n == 1'b1) && (w_sw_board_id == 8'h0d) ? w_mcio2_prsnt_n_zt : //2024-9-24
                                 (r_zt_board_prsnt_n == 1'b1) && (w_sw_board_id == 8'h0c) ? w_mcio5_prsnt_n_zt : 1'b1    ;//u8     
assign  w_mcio3_prsnt_n_sw     = (r_zt_board_prsnt_n == 1'b1) && (w_sw_board_id == 8'h0d) ? r_mcio3_prsnt_n_zt : //2024-9-24
                                 (r_zt_board_prsnt_n == 1'b1) && (w_sw_board_id == 8'h0c) ? r_mcio6_prsnt_n_zt : 1'b1    ;//u8    //2024-9-6  

assign  w_mcio_slot9_prsnt_n   = (r_zt_board_prsnt_n == 1'b1) && (w_sw_board_id == 8'h0c) ? r_mcio1_prsnt_n_zt  : 1'b1    ;//2024-9-24
assign  w_mcio_slot9_prsnt_n_1 = (r_zt_board_prsnt_n == 1'b1) && (w_sw_board_id == 8'h0c) ? w_mcio2_prsnt_n_zt  : 1'b1    ;//2024-9-24
assign  w_mcio_slot11_prsnt_n  = (r_zt_board_prsnt_n == 1'b1) && (w_sw_board_id == 8'h0c) ? r_mcio3_prsnt_n_zt  : 1'b1    ;//2024-9-24

assign  w_mcio4_prsnt_n_sw     = (r_zt_board_prsnt_n == 1'b1) && (w_sw_board_id == 8'h0d) ? r_mcio4_prsnt_n_zt  : //2024-9-24
                                 (r_zt_board_prsnt_n == 1'b1) && (w_sw_board_id == 8'h0c) ? r_mcio7_prsnt_n_zt  : 1'b1    ;//u4     
assign  w_mcio5_prsnt_n_sw     = (r_zt_board_prsnt_n == 1'b1) ? w_mcio5_prsnt_n_zt  : 1'b1    ;//u4    
assign  w_mcio6_prsnt_n_sw     = (r_zt_board_prsnt_n == 1'b1) ? r_mcio6_prsnt_n_zt  : 1'b1    ;//u4     
assign  w_mcio7_prsnt_n_sw     = (r_zt_board_prsnt_n == 1'b1) && (w_sw_board_id == 8'h0d) ? r_mcio7_prsnt_n_zt  : //2024-9-24 
                                 (r_zt_board_prsnt_n == 1'b1) && (w_sw_board_id == 8'h0c) ? r_mcio8_prsnt_n_zt  : 1'b1    ;//u4     //2024-9-6 
assign  w_mcio8_prsnt_n_sw     = (r_zt_board_prsnt_n == 1'b1) && (w_sw_board_id == 8'h0d) ? r_mcio8_prsnt_n_zt  : //2024-9-24
                                 (r_zt_board_prsnt_n == 1'b1) && (w_sw_board_id == 8'h0c) ? r_mcio9_prsnt_n_zt  : 1'b1    ;//u4     
assign  w_mcio9_prsnt_n_sw     = (r_zt_board_prsnt_n == 1'b1) && (w_sw_board_id == 8'h0d) ? r_mcio9_prsnt_n_zt  : //2024-9-24
                                 (r_zt_board_prsnt_n == 1'b1) && (w_sw_board_id == 8'h0c) ? r_mcio10_prsnt_n_zt : 1'b1    ;//u4     //2024-9-6
assign  w_mcio10_prsnt_n_sw    = (r_zt_board_prsnt_n == 1'b1) && (w_sw_board_id == 8'h0d) ? r_mcio10_prsnt_n_zt : //2024-9-24
                                 (r_zt_board_prsnt_n == 1'b1) && (w_sw_board_id == 8'h0c) ? w_mcio11_prsnt_n_zt : 1'b1    ;//u4     
assign  w_mcio11_prsnt_n_sw    = (r_zt_board_prsnt_n == 1'b1) ? w_mcio11_prsnt_n_zt : 1'b1    ;//u4     

assign  w_mcio12_prsnt_n_sw    = (r_zt_board_prsnt_n == 1'b1) && (w_sw_board_id == 8'h0d) ? w_mcio12_prsnt_n_zt : 1'b1    ;//u5    
assign  w_mcio_slot13_prsnt_n_1= (r_zt_board_prsnt_n == 1'b1) && (w_sw_board_id == 8'h0c) ? w_mcio12_prsnt_n_zt : 1'b1    ;//2024-9-24

assign  w_mcio13_prsnt_n_sw    = (r_zt_board_prsnt_n == 1'b1) ? w_mcio13_prsnt_n_zt : 1'b1    ;//u5    
assign  w_pcb_version2_sw      = (r_zt_board_prsnt_n == 1'b1) ? r_pcb_version2_zt   : 1'b1    ;//u5   //2024-9-6 
assign  w_pcb_version1_sw      = (r_zt_board_prsnt_n == 1'b1) ? r_pcb_version1_zt   : 1'b1    ;//u5   //2024-9-6 
assign  w_pcb_version0_sw      = (r_zt_board_prsnt_n == 1'b1) ? r_pcb_version0_zt   : 1'b1    ;//u5   //2024-9-6 
assign  w_pca_version2_sw      = (r_zt_board_prsnt_n == 1'b1) ? r_pca_version2_zt   : 1'b1    ;//u5   //2024-9-6 
assign  w_pca_version1_sw      = (r_zt_board_prsnt_n == 1'b1) ? r_pca_version1_zt   : 1'b1    ;//u5   //2024-9-6 
assign  w_pca_version0_sw      = (r_zt_board_prsnt_n == 1'b1) ? r_pca_version0_zt   : 1'b1    ;//u5   //2024-9-6 

assign  w_board_id0_sw         = (r_zt_board_prsnt_n == 1'b1) ? r_board_id0_zt : 1'b1         ;//u6    //2024-9-6
assign  w_board_id1_sw         = (r_zt_board_prsnt_n == 1'b1) ? r_board_id1_zt : 1'b1         ;//u6    //2024-9-6
assign  w_board_id2_sw         = (r_zt_board_prsnt_n == 1'b1) ? r_board_id2_zt : 1'b1         ;//u6    //2024-9-6
assign  w_board_id3_sw         = (r_zt_board_prsnt_n == 1'b1) ? r_board_id3_zt : 1'b1         ;//u6    //2024-9-6
assign  w_board_id4_sw         = (r_zt_board_prsnt_n == 1'b1) ? r_board_id4_zt : 1'b1         ;//u6    //2024-9-6
assign  w_board_id5_sw         = (r_zt_board_prsnt_n == 1'b1) ? r_board_id5_zt : 1'b1         ;//u6    //2024-9-6
assign  w_board_id6_sw         = (r_zt_board_prsnt_n == 1'b1) ? r_board_id6_zt : 1'b1         ;//u6    //2024-9-6
assign  w_board_id7_sw         = (r_zt_board_prsnt_n == 1'b1) ? r_board_id7_zt : 1'b1         ;//u6    //2024-9-6

assign  w_ct_p1v25_sw0_pg_sw   = (r_zt_board_prsnt_n == 1'b1) ? w_mcio1_prsnt_n_1_zt  : 1'b1  ;//u18    
assign  w_ct_p1v25_sw1_pg_sw   = (r_zt_board_prsnt_n == 1'b1) ? w_mcio2_prsnt_n_1_zt  : 1'b1  ;//u18    
assign  w_p0v8_sw0_pwrgd_sw    = (r_zt_board_prsnt_n == 1'b1) ? w_mcio3_prsnt_n_1_zt  : 1'b1  ;//u18    
assign  w_p0v8_sw1_pwrgd_sw    = (r_zt_board_prsnt_n == 1'b1) ? w_mcio4_prsnt_n_1_zt  : 1'b1  ;//u18    
assign  w_slot1_wake_n_sw      = (r_zt_board_prsnt_n == 1'b1) ? w_mcio5_prsnt_n_1_zt  : 1'b1  ;//u18    
assign  w_slot2_wake_n_sw      = (r_zt_board_prsnt_n == 1'b1) ? w_mcio7_prsnt_n_1_zt  : 1'b1  ;//u18    
assign  w_slot3_wake_n_sw      = (r_zt_board_prsnt_n == 1'b1) ? w_mcio9_prsnt_n_1_zt  : 1'b1  ;//u18    
assign  w_slot4_wake_n_sw      = (r_zt_board_prsnt_n == 1'b1) ? w_mcio10_prsnt_n_1_zt : 1'b1  ;//u18    

assign  w_slot5_wake_n_sw      = (r_zt_board_prsnt_n == 1'b1) ? w_mcio11_prsnt_n_1_zt : 1'b1  ;//u19    
assign  w_slot6_wake_n_sw      = (r_zt_board_prsnt_n == 1'b1) ? w_mcio12_prsnt_n_1_zt : 1'b1  ;//u19    
assign  w_slot7_wake_n_sw      = (r_zt_board_prsnt_n == 1'b1) ? w_u19_nc2_zt          : 1'b1  ;//u19    
assign  w_slot8_wake_n_sw      = (r_zt_board_prsnt_n == 1'b1) ? w_u19_nc3_zt          : 1'b1  ;//u19    
assign  w_slot9_wake_n_sw      = (r_zt_board_prsnt_n == 1'b1) ? w_u19_nc4_zt          : 1'b1  ;//u19    
assign  w_slot10_wake_n_sw     = (r_zt_board_prsnt_n == 1'b1) ? w_u19_nc5_zt          : 1'b1  ;//u19    
assign  w_slot11_wake_n_sw     = (r_zt_board_prsnt_n == 1'b1) && (w_sw_board_id == 8'h0d) ? w_u19_nc6_zt : //2024-9-24
                                 (r_zt_board_prsnt_n == 1'b1) && (w_sw_board_id == 8'h0c) ? w_u19_nc4_zt : 1'b1  ;//u19    
assign  w_slot12_wake_n_sw     = (r_zt_board_prsnt_n == 1'b1) && (w_sw_board_id == 8'h0d) ? w_u19_nc7_zt : //2024-9-24
                                 (r_zt_board_prsnt_n == 1'b1) && (w_sw_board_id == 8'h0c) ? w_u19_nc5_zt : 1'b1  ;//u19    

//-------------------------------------------------------------------------------------------------
//switch_mode //2024-9-6 
// ------------------------------------------------------------------------------------------------
//bit0 X16 Cpu0_PE0: J48-A10  i_CPU0_MCIO0C_NVME0_PRSNT_N_R == w_mcio1_prsnt_n_sw
//bit1 X16 Cpu0 PE1: J75-A10  i_MCIO1A4_NVME0_PRSNT_N_R == w_mcio3_prsnt_n_sw
//bit2 X16 Cpu1_PE0: J74-A10  w_cpu1_mcio0c4_nvme0_prsnt_n == w_mcio7_prsnt_n_sw
//bit3 X16 Cpu1 PE1: J204-A10 w_pal_mcio18_nvme0_prsnt_n == w_mcio9_prsnt_n_sw

always@(posedge clk_50m or negedge pon_reset_n) begin
    if(~pon_reset_n) begin
	    r_switch_mode <= 8'hff; //espi reg 0x1010  BMC_IIC_REG 0x008d
	end
	else begin
	    if(r_zt_board_prsnt_n == 1'b0) begin //zt board
		    r_switch_mode <= 8'hff;  
		end
		else if(w_sw_board_id == 8'h0c) begin //104 switch
                    case({w_mcio9_prsnt_n_sw,w_mcio7_prsnt_n_sw,w_mcio3_prsnt_n_sw,w_mcio1_prsnt_n_sw}) 
                        4'b0000: r_switch_mode <= 8'h01;   //8GPU HPC模式
                        4'b0110: r_switch_mode <= 8'h02;   //8GPU 并行模式 或耥HPC模式
                        4'b1110: r_switch_mode <= 8'h03;   //8GPU 串行模式
                        4'b1111: r_switch_mode <= 8'hff;   //未接
                        default: r_switch_mode <= 8'hff;
                    endcase
		end
		else if(w_sw_board_id == 8'h0d) begin //144 switch
                    case({w_mcio9_prsnt_n_sw,w_mcio7_prsnt_n_sw,w_mcio3_prsnt_n_sw,w_mcio1_prsnt_n_sw}) 
                        4'b0000: r_switch_mode <= 8'h01;   //8GPU HPC模式
                        4'b1010: r_switch_mode <= 8'h02;   //8GPU 并行模式
                        4'b1110: r_switch_mode <= 8'h03;   //8GPU 串行模式
                        4'b1111: r_switch_mode <= 8'hff;   //未接
                        default: r_switch_mode <= 8'hff;
                    endcase
		end
	end
end
//-------------------------------------------------------------------------------------------------
//switch_mode //2024-9-6 
// ------------------------------------------------------------------------------------------------

//-------------------------------------------------------------------------------------------------
// CPU0 PE0 --- switch2 board signal PVT_DATA   74lv165
//-------------------------------------------------------------------------------------------------

// wire w_pwr_on_dly2s;
// wire w_pwr_on_dly1s5;  

// edge_delay #(.CNTR_NBITS(3), .DELAY_MODE(1'b0)) edge_delay_dc_pwr_on_2s (   //DELAY_MODE =0 for rise edge
    // .clk         (clk_50m),
    // .reset       (~pon_reset_n),
    // .cnt_size    (3'd2),
    // .cnt_step    (t1s_tick),
    // .signal_in   (db_i_p0_slp_s3_n & db_i_pgd_p5v),
    // .delay_output(w_pwr_on_dly2s)
  // );
// edge_delay #(.CNTR_NBITS(3), .DELAY_MODE(1'b0)) edge_delay_dc_pwr_on_1s5 (   //DELAY_MODE =0 for rise edge
    // .clk         (clk_50m),
    // .reset       (~pon_reset_n),
    // .cnt_size    (3'd3),
    // .cnt_step    (t512ms_tick),
    // .signal_in   (db_i_p0_slp_s3_n & db_i_pgd_p5v),
    // .delay_output(w_pwr_on_dly1s5)
  // );
//-------------------------------------------------------------------------------------------------
// CPU0 PE0 --- PVT_DATA   74lv165 //2024-1-16 add for switch debug
//-------------------------------------------------------------------------------------------------
pvt_gpi #(
  .TOTAL_BIT_COUNT(8),
  .DEFAULT_STATE(8'h0),
  .NUMBER_OF_COUNTER_BITS(3)
) pvt_gpi_4u_gpu_sw2_inst_u2 (
  .clk           (clk_50m),                        //in
  .reset_n       (~w_pwr_on_dly2s & pon_reset_n ),                    //in  //2024-9-4 add & ~w_pwr_on_dly2s
  .clk_ena       (t1ms_tick),                     //in  //2024-9-3 t16us_tick
  .serclk_in     (o_P0_MCIOP0C_CLK_R   ),         //in   
  .par_load_in_n (o_P0_MCIOP0C_LD_R  ),          //in   
  .sdi           (i_P0_MCIOP0C_DATAIN_R ),  //in   
  .bit_idx_in    (pvti_sw2_u2_count1),                  //in
  .bit_idx_out   (pvti_sw2_u2_count1),                  //out
  .serclk_out       (o_P0_MCIOP0C_CLK_R ),        //out
  .par_load_out_n(o_P0_MCIOP0C_LD_R  ),          //out

  .par_data      ({
                    w_pal_p12v_drop_sw2,w_pg_p5v0_r_sw2,w_pg_p1v8_r_sw2,w_pg_p1v8_pll_r_sw2 ,
                    w_db2000_pwrgd0_sw2,w_db2000_pwrgd1_sw2,w_mcio_slot13_prsnt_n_1_sw2,w_u40_nc7_sw2
		
			})
);
//-------------------------------------------------------------------------------------------------
// CPU0 PE0 --- PVT_DATA    //2024-1-16 add for switch2 debug
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
  .so        (o_P0_MCIOP0C_WAKE_N_R)  ,    //2024-2-22 chg J48  B29  o_CPU0_MCIO0_WAKE_N_R  TO J185 B29  o_CPU0_MCIO0A_WAKE_N_R
  .sld_n     (o_P0_MCIOP0A_WAKE_N_R)  ,    //2024-2-22 chg J185 B29  o_CPU0_MCIO0A_WAKE_N_R TO J48  B29  o_CPU0_MCIO0_WAKE_N_R
  .o_sclk    (o_P0_MCIOP0C_RSV_R)        //2024-2-22 chg J48  B30  o_CPU0_MCIO0C_RSV_R    TO J185 B30  o_CPU0_MCIO0A_RSV_R
) ;
// assign o_CPU0_MCIO0C_RSV_R = 1'b1 ; //2024-2-22 CHG TO USE AS EN , ALWAYS SET HIGH

//-------------------------------------------------------------------------------------------------
// CPU0 PE0 --- ZT2 board & switch2 board signal  all in J48 J185
//-------------------------------------------------------------------------------------------------
pvt_gpi #(
  .TOTAL_BIT_COUNT(64),
  .DEFAULT_STATE(64'h0),
  .NUMBER_OF_COUNTER_BITS(6)
) pvt_gpi_4u_gpu_zt2_inst (
  .clk                      (clk_50m),                        //in
  .reset_n              (~w_pwr_on_dly2s & pon_reset_n ),                    //in //2024-9-4 add & w_pwr_on_dly2s
  .clk_ena              (t1ms_tick),                     //in  //2024-9-3 t16us_tick
  .serclk_in          (o_P0_MCIOP0A_CLK_R    ),        //in   o_CPU0_MCIO3A_CLK_R     J42 A8
  .par_load_in_n  (o_P0_MCIOP0A_LD_R     ),        //in   o_CPU0_MCIO3A_LD_R      J42 A9
  .sdi                      (i_P0_MCIOP0A_DATAIN_R ),        //in   i_CPU0_MCIO3A_DATAIN_R  J42 B10
  .bit_idx_in        (pvti_zt2_count),                  //in
  .bit_idx_out      (pvti_zt2_count),                  //out
  .serclk_out        (o_P0_MCIOP0A_CLK_R   ),         //out o_CPU0_MCIO3A_CLK_R   J42 A8
  .par_load_out_n(o_P0_MCIOP0A_LD_R     ),         //out o_CPU0_MCIO3A_LD_R    J42 A9
                   //last bit
  .par_data      ({
                                w_tpm431_alert_n_zt2,w_ina3221_pwr_alert_zt2,w_pal_3v3_pgd1_r_zt2,w_pal_3v3_pgd2_r_zt2,
                                w_pal_3v3_pgd3_r_zt2,w_pal_3v3_pgd4_r_zt2,w_pal_3v3_pgd5_r_zt2,w_u3_nc7_zt2,
                                
                                w_slot1_prsnt_n_zt2,w_slot2_prsnt_n_zt2,w_slot3_prsnt_n_zt2,w_slot4_prsnt_n_zt2,
                                w_slot5_prsnt_n_zt2,w_slot6_prsnt_n_zt2,w_slot7_prsnt_n_zt2,w_slot8_prsnt_n_zt2,

                                w_slot9_prsnt_n_zt2 ,w_slot10_prsnt_n_zt2,w_slot11_prsnt_n_zt2,w_slot12_prsnt_n_zt2,
                                w_slot13_prsnt_n_zt2,w_mcio1_prsnt_n_zt2 ,w_mcio2_prsnt_n_zt2 ,w_mcio3_prsnt_n_zt2 ,

                                w_mcio4_prsnt_n_zt2 ,w_mcio5_prsnt_n_zt2 ,w_mcio6_prsnt_n_zt2 ,w_mcio7_prsnt_n_zt2 ,
                                w_mcio8_prsnt_n_zt2 ,w_mcio9_prsnt_n_zt2 ,w_mcio10_prsnt_n_zt2,w_mcio11_prsnt_n_zt2,

                                w_mcio12_prsnt_n_zt2,w_mcio13_prsnt_n_zt2,w_pcb_version2_zt2,  w_pcb_version1_zt2,  
                                w_pcb_version0_zt2,  w_pca_version2_zt2,  w_pca_version1_zt2,  w_pca_version0_zt2,  

                                w_board_id0_zt2,w_board_id1_zt2,w_board_id2_zt2,w_board_id3_zt2,
                                w_board_id4_zt2,w_board_id5_zt2,w_board_id6_zt2,w_board_id7_zt2,

                                w_mcio1_prsnt_n_1_zt2 ,w_mcio2_prsnt_n_1_zt2 ,w_mcio3_prsnt_n_1_zt2 ,w_mcio4_prsnt_n_1_zt2 ,
                                w_mcio5_prsnt_n_1_zt2 ,w_mcio7_prsnt_n_1_zt2 ,w_mcio9_prsnt_n_1_zt2 ,w_mcio10_prsnt_n_1_zt2,

                                w_mcio11_prsnt_n_1_zt2,w_mcio12_prsnt_n_1_zt2,w_u19_nc2_zt2,w_u19_nc3_zt2,
                                w_u19_nc4_zt2,w_u19_nc5_zt2,w_u19_nc6_zt2,w_u19_nc7_zt2
                                })//first bit
);

//-------------------------------------------------------------------------------------------------
// 2024-9-6 add for cable error
//-------------------------------------------------------------------------------------------------
always@(posedge clk_50m or negedge pon_reset_n) begin //2024-9-6 add 
    if(~pon_reset_n) 
    begin
            r_board_id0_zt2     <= w_board_id0_zt2     ;
            r_board_id1_zt2     <= w_board_id1_zt2     ;
            r_board_id2_zt2     <= w_board_id2_zt2     ;
            r_board_id3_zt2     <= w_board_id3_zt2     ;
            r_board_id4_zt2     <= w_board_id4_zt2     ;
            r_board_id5_zt2     <= w_board_id5_zt2     ;
            r_board_id6_zt2     <= w_board_id6_zt2     ;
            r_board_id7_zt2     <= w_board_id7_zt2     ;
            r_pcb_version2_zt2  <= w_pcb_version2_zt2  ;
            r_pcb_version1_zt2  <= w_pcb_version1_zt2  ;
            r_pcb_version0_zt2  <= w_pcb_version0_zt2  ;
            r_pca_version2_zt2  <= w_pca_version2_zt2  ;
            r_pca_version1_zt2  <= w_pca_version1_zt2  ;
            r_pca_version0_zt2  <= w_pca_version0_zt2  ;
            r_mcio9_prsnt_n_zt2 <= w_mcio9_prsnt_n_zt2 ;
            r_mcio7_prsnt_n_zt2 <= w_mcio7_prsnt_n_zt2 ;
            r_mcio3_prsnt_n_zt2 <= w_mcio3_prsnt_n_zt2 ;
            r_mcio1_prsnt_n_zt2 <= w_mcio1_prsnt_n_zt2 ;
            r_mcio10_prsnt_n_zt2<= w_mcio10_prsnt_n_zt2;
            r_mcio8_prsnt_n_zt2 <= w_mcio8_prsnt_n_zt2 ;
            r_mcio6_prsnt_n_zt2 <= w_mcio6_prsnt_n_zt2 ;
            r_mcio4_prsnt_n_zt2 <= w_mcio4_prsnt_n_zt2 ;
	end
	else  begin  
	    if(w_pwr_on_dly1s5) 
            begin
                r_board_id0_zt2     <= r_board_id0_zt2     ;
                r_board_id1_zt2     <= r_board_id1_zt2     ;
                r_board_id2_zt2     <= r_board_id2_zt2     ;
                r_board_id3_zt2     <= r_board_id3_zt2     ;
                r_board_id4_zt2     <= r_board_id4_zt2     ;
                r_board_id5_zt2     <= r_board_id5_zt2     ;
                r_board_id6_zt2     <= r_board_id6_zt2     ;
                r_board_id7_zt2     <= r_board_id7_zt2     ;
                r_pcb_version2_zt2  <= r_pcb_version2_zt2  ;
                r_pcb_version1_zt2  <= r_pcb_version1_zt2  ;
                r_pcb_version0_zt2  <= r_pcb_version0_zt2  ;
                r_pca_version2_zt2  <= r_pca_version2_zt2  ;
                r_pca_version1_zt2  <= r_pca_version1_zt2  ;
                r_pca_version0_zt2  <= r_pca_version0_zt2  ;
                r_mcio9_prsnt_n_zt2 <= r_mcio9_prsnt_n_zt2 ;
                r_mcio7_prsnt_n_zt2 <= r_mcio7_prsnt_n_zt2 ;
                r_mcio3_prsnt_n_zt2 <= r_mcio3_prsnt_n_zt2 ;
                r_mcio1_prsnt_n_zt2 <= r_mcio1_prsnt_n_zt2 ;
                r_mcio10_prsnt_n_zt2<= r_mcio10_prsnt_n_zt2;
                r_mcio8_prsnt_n_zt2 <= r_mcio8_prsnt_n_zt2 ;
                r_mcio6_prsnt_n_zt2 <= r_mcio6_prsnt_n_zt2 ;
                r_mcio4_prsnt_n_zt2 <= r_mcio4_prsnt_n_zt2 ;
            end
            else begin
                r_board_id0_zt2     <= w_board_id0_zt2     ;
                r_board_id1_zt2     <= w_board_id1_zt2     ;
                r_board_id2_zt2     <= w_board_id2_zt2     ;
                r_board_id3_zt2     <= w_board_id3_zt2     ;
                r_board_id4_zt2     <= w_board_id4_zt2     ;
                r_board_id5_zt2     <= w_board_id5_zt2     ;
                r_board_id6_zt2     <= w_board_id6_zt2     ;
                r_board_id7_zt2     <= w_board_id7_zt2     ;
                r_pcb_version2_zt2  <= w_pcb_version2_zt2  ;
                r_pcb_version1_zt2  <= w_pcb_version1_zt2  ;
                r_pcb_version0_zt2  <= w_pcb_version0_zt2  ;
                r_pca_version2_zt2  <= w_pca_version2_zt2  ;
                r_pca_version1_zt2  <= w_pca_version1_zt2  ;
                r_pca_version0_zt2  <= w_pca_version0_zt2  ;
                r_mcio9_prsnt_n_zt2 <= w_mcio9_prsnt_n_zt2 ;
                r_mcio7_prsnt_n_zt2 <= w_mcio7_prsnt_n_zt2 ;
                r_mcio3_prsnt_n_zt2 <= w_mcio3_prsnt_n_zt2 ;
                r_mcio1_prsnt_n_zt2 <= w_mcio1_prsnt_n_zt2 ;
                r_mcio10_prsnt_n_zt2<= w_mcio10_prsnt_n_zt2;
                r_mcio8_prsnt_n_zt2 <= w_mcio8_prsnt_n_zt2 ;
                r_mcio6_prsnt_n_zt2 <= w_mcio6_prsnt_n_zt2 ;
                r_mcio4_prsnt_n_zt2 <= w_mcio4_prsnt_n_zt2 ;
            end
	end
end

//-------------------------------------------------------------------------------------------------
// ZT board or  switch board  judge
//-------------------------------------------------------------------------------------------------

assign  w_zt2_board_id ={r_board_id7_zt2,r_board_id6_zt2,r_board_id5_zt2,r_board_id4_zt2,
                        r_board_id3_zt2,r_board_id2_zt2,r_board_id1_zt2,r_board_id0_zt2}; //2024-9-6

assign  w_sw2_board_id ={w_board_id7_sw2,w_board_id6_sw2,w_board_id5_sw2,w_board_id4_sw2,
                        w_board_id3_sw2,w_board_id2_sw2,w_board_id1_sw2,w_board_id0_sw2};  

always@(posedge clk_50m or negedge pon_reset_n) begin
    if(~pon_reset_n) begin
		r_zt2_board_prsnt_n <= 1'b0;
	end
	else if (w_zt2_board_id == 8'h2d) begin  
	    r_zt2_board_prsnt_n <= 1'b0;                                  
	end
	else 
	    r_zt2_board_prsnt_n <= 1'b1;
end

assign w_zt2_board_prsnt_n = r_zt2_board_prsnt_n;//2024-9-9 add
//2024-4-30 SW CHG VB REMAPPED
assign  w_tpm431_alert_n_sw2    = (r_zt2_board_prsnt_n == 1'b1) ? w_tpm431_alert_n_zt2    : 1'b1 ;//u3     
assign  w_ina3221_pwr_alert_sw2 = (r_zt2_board_prsnt_n == 1'b1) ? w_ina3221_pwr_alert_zt2 : 1'b1 ;//u3     
assign  w_pal_3v3_pgd1_r_sw2    = (r_zt2_board_prsnt_n == 1'b1) ? w_pal_3v3_pgd1_r_zt2    : 1'b1 ;//u3     
assign  w_pal_3v3_pgd2_r_sw2    = (r_zt2_board_prsnt_n == 1'b1) ? w_pal_3v3_pgd2_r_zt2    : 1'b1 ;//u3     
assign  w_pal_3v3_pgd3_r_sw2    = (r_zt2_board_prsnt_n == 1'b1) ? w_pal_3v3_pgd3_r_zt2    : 1'b1 ;//u3     
assign  w_pal_3v3_pgd4_r_sw2    = (r_zt2_board_prsnt_n == 1'b1) ? w_pal_3v3_pgd4_r_zt2    : 1'b1 ;//u3     
assign  w_pal_3v3_pgd5_r_sw2    = (r_zt2_board_prsnt_n == 1'b1) ? w_pal_3v3_pgd5_r_zt2    : 1'b1 ;//u3     
assign  w_u3_nc7_sw2            = (r_zt2_board_prsnt_n == 1'b1) && (w_sw2_board_id == 8'h0d) ? w_u3_nc7_zt2 : 1'b1 ;//u3     

assign  w_zt2_mcio_slot11_prsnt_n_1= (r_zt2_board_prsnt_n == 1'b1) && (w_sw2_board_id == 8'h0c) ? w_u3_nc7_zt2 : 1'b1 ;//2024-9-24

assign  w_slot1_prsnt_n_sw2     = (r_zt2_board_prsnt_n == 1'b1) ? w_slot1_prsnt_n_zt2 : 1'b1     ;//u7     
assign  w_slot2_prsnt_n_sw2     = (r_zt2_board_prsnt_n == 1'b1) ? w_slot2_prsnt_n_zt2 : 1'b1     ;//u7     
assign  w_slot3_prsnt_n_sw2     = (r_zt2_board_prsnt_n == 1'b1) ? w_slot3_prsnt_n_zt2 : 1'b1     ;//u7     
assign  w_slot4_prsnt_n_sw2     = (r_zt2_board_prsnt_n == 1'b1) ? w_slot4_prsnt_n_zt2 : 1'b1     ;//u7     
assign  w_slot5_prsnt_n_sw2     = (r_zt2_board_prsnt_n == 1'b1) ? w_slot5_prsnt_n_zt2 : 1'b1     ;//u7     
assign  w_slot6_prsnt_n_sw2     = (r_zt2_board_prsnt_n == 1'b1) ? w_slot6_prsnt_n_zt2 : 1'b1     ;//u7     
assign  w_slot7_prsnt_n_sw2     = (r_zt2_board_prsnt_n == 1'b1) ? w_slot7_prsnt_n_zt2 : 1'b1     ;//u7     
assign  w_slot8_prsnt_n_sw2     = (r_zt2_board_prsnt_n == 1'b1) ? w_slot8_prsnt_n_zt2 : 1'b1     ;//u7     

assign  w_slot9_prsnt_n_sw2      = (r_zt2_board_prsnt_n == 1'b1) ? w_slot9_prsnt_n_zt2  : 1'b1    ;//u8     
assign  w_slot10_prsnt_n_sw2    = (r_zt2_board_prsnt_n == 1'b1) ? w_slot10_prsnt_n_zt2 : 1'b1    ;//u8     
assign  w_slot11_prsnt_n_sw2    = (r_zt2_board_prsnt_n == 1'b1) ? w_slot11_prsnt_n_zt2 : 1'b1    ;//u8     
assign  w_slot12_prsnt_n_sw2    = (r_zt2_board_prsnt_n == 1'b1) ? w_slot12_prsnt_n_zt2 : 1'b1    ;//u8     
assign  w_slot13_prsnt_n_sw2    = (r_zt2_board_prsnt_n == 1'b1) ? w_slot13_prsnt_n_zt2 : 1'b1    ;//u8     
assign  w_mcio1_prsnt_n_sw2      = (r_zt2_board_prsnt_n == 1'b1) && (w_sw2_board_id == 8'h0d) ? r_mcio1_prsnt_n_zt2 : //2024-9-24
                                 (r_zt2_board_prsnt_n == 1'b1) && (w_sw2_board_id == 8'h0c) ? r_mcio4_prsnt_n_zt2 : 1'b1    ;//u8    //2024-9-6 
assign  w_mcio2_prsnt_n_sw2     = (r_zt2_board_prsnt_n == 1'b1) && (w_sw2_board_id == 8'h0d) ? w_mcio2_prsnt_n_zt2 : //2024-9-24
                                 (r_zt2_board_prsnt_n == 1'b1) && (w_sw2_board_id == 8'h0c) ? w_mcio5_prsnt_n_zt2 : 1'b1    ;//u8     
assign  w_mcio3_prsnt_n_sw2     = (r_zt2_board_prsnt_n == 1'b1) && (w_sw2_board_id == 8'h0d) ? r_mcio3_prsnt_n_zt2 : //2024-9-24
                                 (r_zt2_board_prsnt_n == 1'b1) && (w_sw2_board_id == 8'h0c) ? r_mcio6_prsnt_n_zt2 : 1'b1    ;//u8    //2024-9-6  

assign  w_zt2_mcio_slot9_prsnt_n     = (r_zt2_board_prsnt_n == 1'b1) && (w_sw2_board_id == 8'h0c) ? r_mcio1_prsnt_n_zt2  : 1'b1    ;//2024-9-24
assign  w_zt2_mcio_slot9_prsnt_n_1 = (r_zt2_board_prsnt_n == 1'b1) && (w_sw2_board_id == 8'h0c) ? w_mcio2_prsnt_n_zt2  : 1'b1    ;//2024-9-24
assign  w_zt2_mcio_slot11_prsnt_n   = (r_zt2_board_prsnt_n == 1'b1) && (w_sw2_board_id == 8'h0c) ? r_mcio3_prsnt_n_zt2  : 1'b1    ;//2024-9-24

assign  w_mcio4_prsnt_n_sw2     = (r_zt2_board_prsnt_n == 1'b1) && (w_sw2_board_id == 8'h0d) ? r_mcio4_prsnt_n_zt2  : //2024-9-24
                                 (r_zt2_board_prsnt_n == 1'b1) && (w_sw2_board_id == 8'h0c) ? r_mcio7_prsnt_n_zt2  : 1'b1    ;//u4     
assign  w_mcio5_prsnt_n_sw2     = (r_zt2_board_prsnt_n == 1'b1) ? w_mcio5_prsnt_n_zt2  : 1'b1    ;//u4    
assign  w_mcio6_prsnt_n_sw2     = (r_zt2_board_prsnt_n == 1'b1) ? r_mcio6_prsnt_n_zt2  : 1'b1    ;//u4     
assign  w_mcio7_prsnt_n_sw2     = (r_zt2_board_prsnt_n == 1'b1) && (w_sw2_board_id == 8'h0d) ? r_mcio7_prsnt_n_zt2  : //2024-9-24 
                                 (r_zt2_board_prsnt_n == 1'b1) && (w_sw2_board_id == 8'h0c) ? r_mcio8_prsnt_n_zt2  : 1'b1    ;//u4     //2024-9-6 
assign  w_mcio8_prsnt_n_sw2     = (r_zt2_board_prsnt_n == 1'b1) && (w_sw2_board_id == 8'h0d) ? r_mcio8_prsnt_n_zt2  : //2024-9-24
                                 (r_zt2_board_prsnt_n == 1'b1) && (w_sw2_board_id == 8'h0c) ? r_mcio9_prsnt_n_zt2  : 1'b1    ;//u4     
assign  w_mcio9_prsnt_n_sw2     = (r_zt2_board_prsnt_n == 1'b1) && (w_sw2_board_id == 8'h0d) ? r_mcio9_prsnt_n_zt2  : //2024-9-24
                                 (r_zt2_board_prsnt_n == 1'b1) && (w_sw2_board_id == 8'h0c) ? r_mcio10_prsnt_n_zt2 : 1'b1    ;//u4     //2024-9-6
assign  w_mcio10_prsnt_n_sw2    = (r_zt2_board_prsnt_n == 1'b1) && (w_sw2_board_id == 8'h0d) ? r_mcio10_prsnt_n_zt2 : //2024-9-24
                                 (r_zt2_board_prsnt_n == 1'b1) && (w_sw2_board_id == 8'h0c) ? w_mcio11_prsnt_n_zt2 : 1'b1    ;//u4     
assign  w_mcio11_prsnt_n_sw2    = (r_zt2_board_prsnt_n == 1'b1) ? w_mcio11_prsnt_n_zt2 : 1'b1    ;//u4     

assign  w_mcio12_prsnt_n_sw2    = (r_zt2_board_prsnt_n == 1'b1) && (w_sw2_board_id == 8'h0d) ? w_mcio12_prsnt_n_zt2 : 1'b1    ;//u5    
assign  w_zt2_mcio_slot13_prsnt_n_1= (r_zt2_board_prsnt_n == 1'b1) && (w_sw2_board_id == 8'h0c) ? w_mcio12_prsnt_n_zt2 : 1'b1    ;//2024-9-24

assign  w_mcio13_prsnt_n_sw2    = (r_zt2_board_prsnt_n == 1'b1) ? w_mcio13_prsnt_n_zt2 : 1'b1    ;//u5    
assign  w_pcb_version2_sw2      = (r_zt2_board_prsnt_n == 1'b1) ? r_pcb_version2_zt2   : 1'b1    ;//u5   //2024-9-6 
assign  w_pcb_version1_sw2      = (r_zt2_board_prsnt_n == 1'b1) ? r_pcb_version1_zt2   : 1'b1    ;//u5   //2024-9-6 
assign  w_pcb_version0_sw2      = (r_zt2_board_prsnt_n == 1'b1) ? r_pcb_version0_zt2   : 1'b1    ;//u5   //2024-9-6 
assign  w_pca_version2_sw2      = (r_zt2_board_prsnt_n == 1'b1) ? r_pca_version2_zt2   : 1'b1    ;//u5   //2024-9-6 
assign  w_pca_version1_sw2      = (r_zt2_board_prsnt_n == 1'b1) ? r_pca_version1_zt2   : 1'b1    ;//u5   //2024-9-6 
assign  w_pca_version0_sw2      = (r_zt2_board_prsnt_n == 1'b1) ? r_pca_version0_zt2   : 1'b1    ;//u5   //2024-9-6 

assign  w_board_id0_sw2         = (r_zt2_board_prsnt_n == 1'b1) ? r_board_id0_zt2 : 1'b1         ;//u6    //2024-9-6
assign  w_board_id1_sw2         = (r_zt2_board_prsnt_n == 1'b1) ? r_board_id1_zt2 : 1'b1         ;//u6    //2024-9-6
assign  w_board_id2_sw2         = (r_zt2_board_prsnt_n == 1'b1) ? r_board_id2_zt2 : 1'b1         ;//u6    //2024-9-6
assign  w_board_id3_sw2         = (r_zt2_board_prsnt_n == 1'b1) ? r_board_id3_zt2 : 1'b1         ;//u6    //2024-9-6
assign  w_board_id4_sw2         = (r_zt2_board_prsnt_n == 1'b1) ? r_board_id4_zt2 : 1'b1         ;//u6    //2024-9-6
assign  w_board_id5_sw2         = (r_zt2_board_prsnt_n == 1'b1) ? r_board_id5_zt2 : 1'b1         ;//u6    //2024-9-6
assign  w_board_id6_sw2         = (r_zt2_board_prsnt_n == 1'b1) ? r_board_id6_zt2 : 1'b1         ;//u6    //2024-9-6
assign  w_board_id7_sw2         = (r_zt2_board_prsnt_n == 1'b1) ? r_board_id7_zt2 : 1'b1         ;//u6    //2024-9-6

assign  w_ct_p1v25_sw0_pg_sw2   = (r_zt2_board_prsnt_n == 1'b1) ? w_mcio1_prsnt_n_1_zt2  : 1'b1  ;//u18    
assign  w_ct_p1v25_sw1_pg_sw2   = (r_zt2_board_prsnt_n == 1'b1) ? w_mcio2_prsnt_n_1_zt2  : 1'b1  ;//u18    
assign  w_p0v8_sw0_pwrgd_sw2     = (r_zt2_board_prsnt_n == 1'b1) ? w_mcio3_prsnt_n_1_zt2  : 1'b1  ;//u18    
assign  w_p0v8_sw1_pwrgd_sw2     = (r_zt2_board_prsnt_n == 1'b1) ? w_mcio4_prsnt_n_1_zt2  : 1'b1  ;//u18    
assign  w_slot1_wake_n_sw2         = (r_zt2_board_prsnt_n == 1'b1) ? w_mcio5_prsnt_n_1_zt2  : 1'b1  ;//u18    
assign  w_slot2_wake_n_sw2         = (r_zt2_board_prsnt_n == 1'b1) ? w_mcio7_prsnt_n_1_zt2  : 1'b1  ;//u18    
assign  w_slot3_wake_n_sw2         = (r_zt2_board_prsnt_n == 1'b1) ? w_mcio9_prsnt_n_1_zt2  : 1'b1  ;//u18    
assign  w_slot4_wake_n_sw2         = (r_zt2_board_prsnt_n == 1'b1) ? w_mcio10_prsnt_n_1_zt2 : 1'b1  ;//u18    

assign  w_slot5_wake_n_sw2       = (r_zt2_board_prsnt_n == 1'b1) ? w_mcio11_prsnt_n_1_zt2 : 1'b1  ;//u19    
assign  w_slot6_wake_n_sw2       = (r_zt2_board_prsnt_n == 1'b1) ? w_mcio12_prsnt_n_1_zt2 : 1'b1  ;//u19    
assign  w_slot7_wake_n_sw2       = (r_zt2_board_prsnt_n == 1'b1) ? w_u19_nc2_zt2          : 1'b1  ;//u19    
assign  w_slot8_wake_n_sw2       = (r_zt2_board_prsnt_n == 1'b1) ? w_u19_nc3_zt2          : 1'b1  ;//u19    
assign  w_slot9_wake_n_sw2       = (r_zt2_board_prsnt_n == 1'b1) ? w_u19_nc4_zt2          : 1'b1  ;//u19    
assign  w_slot10_wake_n_sw2     = (r_zt2_board_prsnt_n == 1'b1) ? w_u19_nc5_zt2          : 1'b1  ;//u19    
assign  w_slot11_wake_n_sw2     = (r_zt2_board_prsnt_n == 1'b1) && (w_sw2_board_id == 8'h0d) ? w_u19_nc6_zt2 : //2024-9-24
                                 (r_zt2_board_prsnt_n == 1'b1) && (w_sw2_board_id == 8'h0c) ? w_u19_nc4_zt2 : 1'b1  ;//u19    
assign  w_slot12_wake_n_sw2     = (r_zt2_board_prsnt_n == 1'b1) && (w_sw2_board_id == 8'h0d) ? w_u19_nc7_zt2 : //2024-9-24
                                 (r_zt2_board_prsnt_n == 1'b1) && (w_sw2_board_id == 8'h0c) ? w_u19_nc5_zt2 : 1'b1  ;//u19    

//-------------------------------------------------------------------------------------------------
//switch_mode //2024-9-6 
// ------------------------------------------------------------------------------------------------
//bit0 X16 Cpu0_PE0: J48-A10  i_CPU0_MCIO0C_NVME0_PRSNT_N_R == w_mcio1_prsnt_n_sw
//bit1 X16 Cpu0 PE1: J75-A10  i_MCIO1A4_NVME0_PRSNT_N_R == w_mcio3_prsnt_n_sw
//bit2 X16 Cpu1_PE0: J74-A10  w_cpu1_mcio0c4_nvme0_prsnt_n == w_mcio7_prsnt_n_sw
//bit3 X16 Cpu1 PE1: J204-A10 w_pal_mcio18_nvme0_prsnt_n == w_mcio9_prsnt_n_sw

always@(posedge clk_50m or negedge pon_reset_n) begin
    if(~pon_reset_n) begin
	    r_switch2_mode <= 8'hff; //espi reg 0x1010  BMC_IIC_REG 0x008d
	end
	else begin
	    if(r_zt2_board_prsnt_n == 1'b0) begin //zt board
		    r_switch2_mode <= 8'hff;  
		end
		else if(w_sw2_board_id == 8'h0c) begin //104 switch
                    case({w_mcio9_prsnt_n_sw2,w_mcio7_prsnt_n_sw2,w_mcio3_prsnt_n_sw2,w_mcio1_prsnt_n_sw2}) 
                        4'b0000: r_switch2_mode <= 8'h01;   //8GPU HPC模式
                        4'b0110: r_switch2_mode <= 8'h02;   //8GPU 并行模式 或耥HPC模式
                        4'b1110: r_switch2_mode <= 8'h03;   //8GPU 串行模式
                        4'b1111: r_switch2_mode <= 8'hff;   //未接
                        default: r_switch2_mode <= 8'hff;
                    endcase
		end
		else if(w_sw2_board_id == 8'h0d) begin //144 switch
                    case({w_mcio9_prsnt_n_sw2,w_mcio7_prsnt_n_sw2,w_mcio3_prsnt_n_sw2,w_mcio1_prsnt_n_sw2}) 
                        4'b0000: r_switch2_mode <= 8'h01;   //8GPU HPC模式
                        4'b1010: r_switch2_mode <= 8'h02;   //8GPU 并行模式
                        4'b1110: r_switch2_mode <= 8'h03;   //8GPU 串行模式
                        4'b1111: r_switch2_mode <= 8'hff;   //未接
                        default: r_switch2_mode <= 8'hff;
                    endcase
		end
	end
end
//-------------------------------------------------------------------------------------------------
//switch_mode //2024-9-6 
// ------------------------------------------------------------------------------------------------
wire    w_sw_board_prsnt_n;
wire    w_sw2_board_prsnt_n;
wire    w_fan_pwr_en;

assign  w_sw_board_prsnt_n  =   (w_sw_board_id==8'h0d)?1'b0:1'b1;
assign  w_sw2_board_prsnt_n  =   (w_sw2_board_id==8'h0d)?1'b0:1'b1;

assign  w_espi_ram_1055[0]  =   w_zt_board_prsnt_n?1'b1:1'b0;
assign  w_espi_ram_1055[1]  =   w_zt2_board_prsnt_n?1'b1:1'b0;
assign  w_espi_ram_1055[2]  =   w_sw_board_prsnt_n?1'b1:1'b0;
assign  w_espi_ram_1055[3]  =   w_sw2_board_prsnt_n?1'b1:1'b0;
assign  w_espi_ram_1055[4]  =   w_ocp1_x8_prsnt_n?1'b1:1'b0;
assign  w_espi_ram_1055[5]  =   w_ocp1_x16_prsnt_n?1'b1:1'b0;
assign  w_espi_ram_1055[7:6]  = 2'b11;
assign  w_espi_ram_1056 =   8'hff;
assign  w_espi_ram_1057 =   8'hff;
assign  w_espi_ram_1058 =   8'hff;

//------------------------------------------------------------------------------------------------//
assign  w_FM_P12V_EN =  db_i_pwrgd_p3v3_stby ? 1'b1 : 1'b0 ;//P12_MAIN pwr up when cpld work  
assign  w_PWRGD_P12V =   (~i_PS1_DCOK_N & i_PS1_PRSNT) || (~i_PS2_DCOK_N & i_PS2_PRSNT) || w_PWRGD_P12V_PS3_PS4 ;
assign  w_ps2_p12v_on_r  = w_FM_P12V_EN & db_i_ps2_prsnt ;
assign  w_ps1_p12v_on_r  = w_FM_P12V_EN & db_i_ps1_prsnt ;

assign  w_pal_ps_off_r = (db_i_ps1_acfail_n&&db_i_ps2_acfail_n&&w_PS3_PS4_ACFAIL)?1'b0:1'b1 ;  
assign  w_pal_dual_en_r = w_PWRGD_P12V  ? 1'b1 : 1'b0 ;
assign  w_clk_gen_en_r_n    =   1'b0;
assign  w_pal_db2000_1_pwrgd_r    = db_i_pgd_p5v ? 1'b1 : 1'b0 ;
assign  w_pal_db2000_2_pwrgd_r    = db_i_pgd_p5v ? 1'b1 : 1'b0 ;
assign  w_clk_db2000_1_1_oe_n    = db_i_pgd_p5v ? 1'b0 : 1'b1 ;
assign  w_clk_db2000_1_2_oe_n    = db_i_pgd_p5v ? 1'b0 : 1'b1 ;
assign  w_fm_pld_db800_3_clks_dev_en_r  =   fm_pld_db800_3_clks_en&&db_i_pgd_p5v;
assign  w_clk_db800_3_1_oe_n_r    = db_i_pgd_p5v ? 1'b0 : 1'b1 ;
assign  w_clk_db800_3_2_oe_n_r    = db_i_pgd_p5v ? 1'b0 : 1'b1 ;
assign  w_cpld_sgpio1_clk_r  =1'bz;
assign  w_cpld_sgpio1_ld_n_r=1'bz;
assign  w_cpld_sgpio1_mosi_r=1'bz;
assign  w_p12v_slot_0_on_r  =   w_p12v_slot_0_on & (w_slot_0_on_dly_10ms ||(~w_SW_2 && db_i_p0_slp_s5_n));
assign  w_p12v_slot_1_on_r  =   w_p12v_slot_1_on & (w_slot_1_on_dly_10ms ||(~w_SW_2 && db_i_p0_slp_s5_n));
assign  w_p12v_slot_2_on_r  =   w_p12v_slot_2_on & (w_slot_2_on_dly_10ms ||(~w_SW_2 && db_i_p0_slp_s5_n));
assign  w_p0_pcie_wake_n    =     w_p0_pcie_wake_n_r;
assign  w_p1_pcie_wake_n    =   w_p1_pcie_wake_n_r;

assign  w_pal_p0_vdd_core_0_soc_rst_l_n	    = (~db_cpu_prsnt_n[0]) & db_i_p0_pwrok ;
assign  w_pal_p1_vdd_core_0_soc_rst_l_n        = (~db_cpu_prsnt_n[1]) & db_i_p1_pwrok ;
assign  w_pal_p0_vdd_core_1_11_sus_rst_l_n  = (~db_cpu_prsnt_n[0]) & db_i_p0_pwrok ;
assign  w_p1_vdd_core_1_11_sus_rst_l_n          = (~db_cpu_prsnt_n[1]) & db_i_p1_pwrok ;
assign  w_pal_p0_vddio_rst_n				    = (~db_cpu_prsnt_n[0]) & db_i_p0_pwrok ;
assign  w_p1_vddio_rst_l_n                                  = (~db_cpu_prsnt_n[1]) & db_i_p1_pwrok ;

assign  w_p5v_vga2_en_n_r   =   db_i_pgd_p5v ? 1'b0 : 1'b1;
assign  w_pal_p5v_en_r  =   w_p5v_en&&w_PWRGD_P12V;
assign  w_pal_bmc_aux_pgd   =   w_clr_cmos_done ? 1'b0 : db_i_pwrgd_p3v3_stby;
assign  w_p1v0_stby_m2_en   =   w_PWRGD_P12V&&db_i_p0_slp_s5_n;

// assign  w_pal_i3c_mux_en_r_n	=  ~w_i3c_mux_en		;
assign  w_bmc_jtag_trst_r_n  = w_jtag_cpld_bmc_ntrst_reg;	
	
assign  w_p0_sys_reset_r_n   = w_pal_sys_reset_od_n_r;		
assign  w_cpu1_pwr_good  =   db_i_p0_pwrgd_out ? 1'b1 : 1'b0;
assign  w_fan_pwr_en = (~w_ocp_prsnt_n || db_i_p0_slp_s5_n) && ~w_FAN_PRSNT_R ? 1'b1 : 1'b0 ;//2024-4-10 add

assign  w_led_control[1] =  w_power_seq_sm[0];
assign  w_led_control[2] =  w_power_seq_sm[1];
assign  w_led_control[3] =  w_power_seq_sm[2];
assign  w_led_control[7] =  w_power_seq_sm[3];
assign  w_led_control[6] =  w_power_seq_sm[4];
assign  w_led_control[5] =  w_power_seq_sm[5];
assign  w_led_control[4] =  wBMC_PWR_OK ? 1'b1 :1'b0;//wBMC_PWR_OK
assign  w_led_control[0] =  db_i_pwrgd_p3v3_stby ? t2p5hz_clk : 1'b0 ;
 

//-----------------------------------------------------------------------------------------------//
//Output SIGNAL
//-----------------------------------------------------------------------------------------------//
assign  o_PS1_P12V_ON_R                                         =   w_ps1_p12v_on_r;//1
assign  o_PS2_P12V_ON_R                                         =   w_ps2_p12v_on_r;//2
assign  o_PAL_PS_OFF_R                                           =   w_pal_ps_off_r;//3
assign  o_PAL_DUAL_EN_R                                         =   w_pal_dual_en_r;//4
assign  o_CLK_GEN_EN_R_N                                       =   w_clk_gen_en_r_n;//5
assign  o_PAL_DB2000_1_PWRGD_R                           =   w_pal_db2000_1_pwrgd_r;//6
assign  o_PAL_DB2000_2_PWRGD_R                           =   w_pal_db2000_2_pwrgd_r;//7
assign  o_CLK_DB2000_1_1_OE_N                             =   w_clk_db2000_1_1_oe_n;//8
assign  o_CLK_DB2000_1_2_OE_N                             =   w_clk_db2000_1_2_oe_n;//9
assign  o_FM_PLD_DB800_3_CLKS_DEV_EN_R           =   w_fm_pld_db800_3_clks_dev_en_r;//10
assign  o_CLK_DB800_3_1_OE_N_R                           =   w_clk_db800_3_1_oe_n_r;//11
assign  o_CLK_DB800_3_2_OE_N_R                           =   w_clk_db800_3_2_oe_n_r;//12 
assign  o_CPLD_SGPIO0_CLK_R                                 =   w_cpld_sgpio0_clk_r  ;//13
assign  o_CPLD_SGPIO0_LD_N_R                               =   w_cpld_sgpio0_ld_n_r;//14
assign  o_CPLD_SGPIO0_MOSI_R                               =   w_cpld_sgpio0_mosi_r;//15
assign  o_CPLD_SGPIO1_CLK_R                                 =   w_cpld_sgpio1_clk_r  ;//16    //rsvd
assign  o_CPLD_SGPIO1_LD_N_R                               =   w_cpld_sgpio1_ld_n_r;//17    //rsvd  
assign  o_CPLD_SGPIO1_MOSI_R                               =   w_cpld_sgpio1_mosi_r;//18    //rsvd
assign  o_SS_PAL_CLK_R                                           =   w_ss_pal_clk_r;//19
assign  o_SS_PAL_LOAD_N_R                                     =   w_ss_pal_load_n_r;//20
assign  o_SS_PAL_DATA_OUT_R                                 =   w_ss_pal_data_out_r;//21
assign  o_PAL_BMC_PERST_N_R                                 =   db_i_p0_pcie_rst_n_0;//22
assign  o_PAL_BMC_INT_N_R                                     =   1'bz;//23
assign  o_PAL_BMC_SRST_N_R                                   =   w_pal_bmc_srst_n_r;//24
assign  o_CPLD_ESPI_D2                                           =   1'bz;//25
assign  o_CPLD_ESPI_D3                                           =   1'bz;//26
assign  o_CPLD_ESPI_ALERT_N                                 =   1'bz;//27
assign  o_P12V_SLOT_0_ON                                       =   w_p12v_slot_0_on_r;//28
assign  o_P12V_SLOT_1_ON                                       =   w_p12v_slot_1_on_r;//29
assign  o_P12V_SLOT_2_ON                                       =   w_p12v_slot_2_on_r;//30
assign  o_FAN_BOARD_RST                                         =   1'b1;//31
assign  o_FAN_PWR_EN                                               =   w_fan_pwr_en;//32
assign  o_FAN_SPGIO_CLK                                         =   1'bz;//33
assign  o_FAN_SPGIO_LD                                           =   1'bz;//34
assign  o_FAN_SPGIO_DATAOUT                                 =   1'bz;//35
assign  o_P0_MCIOP0A_PERST_N_R                           =   db_i_p0_pcie_rst_n_1;//36
assign  o_P0_MCIOP0C_PERST_N_R                           =   db_i_p0_pcie_rst_n_1;//41
assign  o_P0_MCIOP0A_GPU_THROTTLE_N_R             =   w_p0_mciop0a_gpu_throttle_n_r;//37
assign  o_P0_MCIOP0C_GPU_THROTTLE_N_R             =   w_p0_mciop0c_gpu_throttle_n_r;//42
// assign  o_P0_MCIOP0A_CLK_R                                   =   1'bz;//38
// assign  o_P0_MCIOP0A_LD_R                                     =   1'bz;//39
assign  o_P0_MCIOP0A_RSV_R                                   =   1'b1;//40
// assign  o_P0_MCIOP0C_CLK_R                                   =   1'bz;//43
// assign  o_P0_MCIOP0C_LD_R                                     =   1'bz;//44
assign  o_P0_MCIOP0C_RSV_R                                   =   1'bz;//45
// assign  o_P0_MCIOP1A_CLK_R                                   =   1'bz;//46
// assign  o_P0_MCIOP1A_LD_R                                     =   1'bz;//47
assign  o_P0_MCIOP3A_CLK_R                                   =   1'bz;//48
assign  o_P0_MCIOP3A_LD_R                                     =   1'bz;//49
assign  o_SATA1_SCLOCK0_R                                     =   1'bz;//50
assign  o_SATA1_SLOAD0_R                                       =   1'bz;//51
assign  o_PD_SATA1_CONTROLLER0_R                       =   1'bz;//52
assign  o_P0_PWR_BTN_R_N                                       =   w_pal_pwrbtn_n_r;
assign  o_P1_PWR_BTN_R_N                                       =   1'bz;
assign  o_P0_SYS_RESET_R_N                                   =   w_p0_sys_reset_r_n;
assign  o_P1_SYS_RESET_R_N                                   =   w_p0_sys_reset_r_n;
assign  o_P0_PCIE_WAKE_N_R                                   =   w_p0_pcie_wake_n;//34
assign  o_P1_PCIE_WAKE_N_R                                   =   w_p1_pcie_wake_n;//34
assign  o_P0_RSMRST_N                                             =   w_rsmrst_n;
assign  o_P1_RSMRST_N                                             =   w_rsmrst_n;
assign  o_P0_PWR_GOOD                                             =   w_cpu_pwr_good;
assign  o_P1_PWR_GOOD                                             =   w_cpu1_pwr_good;
assign  o_P0_PROCHOT_N                                           =   w_p0_prochot_n;
assign  o_P1_PROCHOT_N                                           =   w_p1_prochot_n;
assign  o_P0_KBRST_N                                               =   w_p0_kbrst_n;
assign  o_P1_KBRST_N                                               =   w_p1_kbrst_n;
assign  o_P0_NMI_SYNC_FLOOD_N                             =   w_p0_nmi_sync_flood_n;
assign  o_P1_NMI_SYNC_FLOOD_N                             =   w_p1_nmi_sync_flood_n;
assign  o_P0_FORCE_SELFREFRESH_R		             = 1'bz;		//STRAP
assign  o_P1_FORCE_SELFREFRESH_R		             = 1'bz;		//STRAP
assign  o_P0_DIMM_GL_PCAMP_R                               =   w_p0_dimm_gl_pcamp_r;//53
assign  o_P0_DIMM_AF_PCAMP_R                               =   w_p0_dimm_af_pcamp_r;//54
assign  o_P1_DIMM_GL_PCAMP_R                               =   w_p1_dimm_gl_pcamp_r;//53
assign  o_P1_DIMM_AF_PCAMP_R                               =   w_p1_dimm_af_pcamp_r;//54
//uart
assign  o_P0_UART_RXD_0				             = 1'bz;//55
// assign  o_P0_UART_RXD_1			                     = w_st_steady_pwrok ? i_UART_CPLD_RX_R: 1'b0;			
// assign  o_UART_CPLD_TX_R			                     = i_P0_UART_TXD_1;
assign  o_UART_CPLD_TX_R			                     =1'bz;
assign  o_P0_UART_RXD_1			                     = w_st_steady_pwrok ? i_CPLD1_CPLD2_RSV1: 1'b0;					
assign  o_CPLD1_CPLD2_RSV2                                   =   i_P0_UART_TXD_1;

assign  o_P0_SPI_CLK_STRAP                                   =   1'bz;
assign  o_P0_SPI_T245_OE_N_R                               =   w_rsmrst_n?1'b0:1'bz;
assign  o_P0_WAFL_STRAP_SEL_R                             =   1'bz;
//HDT
assign o_PAL_P0_PRSENT_HDT	                             =	db_cpu_prsnt_n[0];
assign o_PAL_P1_PRSENT_HDT	                             =	db_cpu_prsnt_n[1];
assign  o_HDT_CPU_PWROK		                             = db_i_p0_pwrok    ;
assign o_HDT_CPU_RESET_N	                                     = i_P0_RESET_N     ;
assign  o_PAL_TPCM_BIOS_DONE_R_N		             = 1'bz;
assign  o_PAL_BMC_POST_DONE_FLAG_R		     = r_bmc_ready;
assign  o_PAL_BIOS_DEBUG_R_N                               =   w_sys_debug_mode;
assign  o_PAL_TPCM_IRQ_R_L			             = 1'bz;
assign  o_PAL_TPCM_BMC_DONE_R_N		             = 1'bz;
assign  o_P0_VDDC_EN_R                                           =   w_grp_b_p0_33_s5_en;//2025-02-09 add ||(~w_SW_4) for pwron
assign  o_P1_VDDC_EN_R                                           =   w_grp_b_p1_33_s5_en;
assign  o_PAL_P0_VDD_18_STBY_EN_R                     =   w_grp_b_p0_18_s5_en;
assign  o_P1_VDD_18_STBY_EN                                 =   w_grp_b_p1_18_s5_en;
assign  o_PAL_P0_VDDIO_EN_R                                 =   w_grp_d_p0_vddio_en ;
assign  o_PAL_P1_VDDIO_EN_R                                 =   w_grp_d_p1_vddio_en;
assign  o_PAL_P0_VDD_11_SUS_EN                           =   w_grp_c_p0_vdd11_en;
assign  o_PAL_P1_VDD_11_SUS_EN                           =   w_grp_c_p1_vdd11_en;
assign  o_PAL_P0_VDD_CORE_1_11_SUS_RST_L_N   =   w_pal_p0_vdd_core_1_11_sus_rst_l_n;
assign  o_PAL_P1_VDD_CORE_1_11_SUS_RST_L_N   =   w_p1_vdd_core_1_11_sus_rst_l_n;
assign  o_PAL_P0_VDDIO_RST_N                               =   w_pal_p0_vddio_rst_n;
assign  o_P1_VDDIO_RST_L_N                                   =   w_p1_vddio_rst_l_n;
assign  o_PAL_P0_VDD_SOC_EN                                 =   w_grp_d_p0_soc_en;
assign  o_PAL_P1_VDD_SOC_EN                                 =   w_grp_d_p1_soc_en;
assign  o_PAL_P0_VDD_CORE_1_EN_R                       =   w_grp_d_p0_vddcore1_en;
assign  o_PAL_P1_VDD_CORE_1_EN_R                       =   w_grp_d_p1_vddcore1_en;
assign  o_PAL_P0_VDD_CORE_0_EN_R                       =   w_grp_d_p0_vddcore0_en;
assign  o_PAL_P1_VDD_CORE_0_EN_R                       =   w_grp_d_p1_vddcore0_en;
assign  o_PAL_P0_VDD_CORE_0_SOC_RST_L_N         =   w_pal_p0_vdd_core_0_soc_rst_l_n;
assign  o_PAL_P1_VDD_CORE_0_SOC_RST_L_N         =   w_pal_p1_vdd_core_0_soc_rst_l_n;
assign  o_P5V_VGA2_EN_N_R                                     =   w_p5v_vga2_en_n_r;
assign  o_PAL_P3V3_STBY_EN_R                               =   1'bz;
assign  o_P3V3_STBY_B_EN_R                                   =   1'bz;
assign  o_PAL_P5V_STBY_EN_R                                 =   w_p5v_stby_en;
assign  o_P1V2_STBY_EN_R                                       =   w_p5v_stby_usb_en;
assign  o_P0_I2C_9617_EN                                       =   db_i_pgd_p0_vdd_18_stby?1'b1:1'b0;
assign  o_PAL_P5V_EN_R                                           =   w_pal_p5v_en_r;
assign  o_SCALED_BAT_TEST_EN_R                           =   w_ctl_scaled_bat_test_en_r;
assign  o_P3V_BAT_SWITCH_EN_R                             =   ~w_pal_bmc_aux_pgd;
assign  o_PAL_BAT_SENSE_R                                     =   w_rtc_senor_sw;
assign  o_PAL_BMC_AUX_PGD                                     =   w_pal_bmc_aux_pgd;
assign  o_P1V0_STBY_M2_EN                                     =   w_p1v0_stby_m2_en;
assign  o_P0_VPP_9545_1_RST_N_R                         =   w_p0_vpp_9545_1_rst_n;
assign  o_P0_VPP_9545_2_RST_N_R                         =   w_p0_vpp_9545_2_rst_n;
assign  o_PAL_P0_I2C5_9548_RST_R                       =   w_bmc_i2c5_9548_rst_n;
assign  o_BMC_I2C9_9548_1_RST_N_R                     =   w_bmc_i2c9_9548_1_rst_n;
assign  o_BMC_I2C9_9548_2_RST_N_R                     =   w_bmc_i2c9_9548_2_rst_n;
assign  o_BMC_I2C9_9548_3_RST_N_R                     =   w_bmc_i2c9_9548_3_rst_n;
assign  o_BMC_I2C9_9548_4_RST_N_R                     =   w_bmc_i2c9_9548_4_rst_n;
assign  o_BIOS_POST_CMPLT_BMC_N_R                     =   db_i_p0_bios_post_stage_r_n;
assign  o_PAL_I3C_MUX_EN_R_N                               =   ~w_i3c_mux_en;
assign  o_I3C_MUX_SEL_R_0                                     =   db_i_p0_spd_host_ctrl_n;
assign  o_I3C_MUX_SEL_R_1                                     =   db_i_p0_spd_host_ctrl_n;
assign  o_I3C_MUX_SEL_R_2                                     =   db_i_p0_spd_host_ctrl_n;
assign  o_I3C_MUX_SEL_R_3                                     =   db_i_p0_spd_host_ctrl_n;
assign  o_I3C_MUX_OE_N_R_0                                   =   1'b0;
assign  o_I3C_MUX_OE_N_R_1                                   =   1'b0;
assign  o_I3C_MUX_OE_N_R_2                                   =   1'b0;
assign  o_I3C_MUX_OE_N_R_3                                   =   1'b0;
assign  o_SHORT_DET_EN_R                                       =   1'b1;
assign  o_PAL_CLEAR_CMOS_R_N                               =   (~w_clr_cmos_flg & w_st_steady_pwrok    );	
assign  o_PAL_CMOS_CLEAR_R                                   =   (w_clr_cmos_done & w_st_off_standby  );
assign  o_BMC_JTAG_MUX_S                                       =   w_bmc_jtag_mux_s;//2025-03-05 chg 1'b0 to 1'b1
assign  o_BMC_JTAG_MUX_OE_N                                 =   1'b0;
assign  o_BMC_JTAG_TRST_R_N                                 =   w_bmc_jtag_trst_r_n;
assign  o_TPM_IO2_RST                                             =   db_i_p0_pcie_rst_n_0;
assign  o_EEPROM_WP_N_R                                         =   w_eeprom_wp ? 1'b0 : 1'b1;
assign  o_PAL_PVCC_HPMOS_SW_R                             =   w_FM_P12V_EN  ;//2025-02-09 add

//--------------------------------------------------------------------------------------------------------------------------------------------------
//I2C RAM  Start
//--------------------------------------------------------------------------------------------------------------------------------------------------
/************************************************************************************************************************************************************************/
// reg [7:0] r_uid_led_fb				;	// UID LED hitless
bmc_cpld_i2c_ram #(
.DLY_LEN       (16)   //50MHz,330ns
)bmc_cpld_i2c_ram_u0
(
.i_rst_n		(pon_reset_n	),  
.i_clk			(clk_25m		),
.i_1ms_clk		(t1ms_tick		),	          
.i_rst_i2c_n	(1'b1			),		
.i_scl			(i_I2C7_PAL_SCL		), 
.io_sda			(io_I2C7_PAL_SDA	),

.i_product_id			(`PRODUCT_ID	),	                        //addr 0x0000	
.i_vender_id			(`VENDER_ID	        ),				//addr 0x0001
.i_board_id				({4'b0000,w_board_id}   ),	        //addr 0x0002	
.i_pcb_version			({5'b0,w_pcb_version}   ),	        //addr 0x0003	
.i_bom_id				({5'b0,w_pca_version}   ),	        //addr 0x0004
.i_cpld_version			(`CPLD_VERSION	),				//addr 0x0005
.o_test_reg				(		),                                 		//addr 0x0006
.i_year					(`Year	),						//addr 0x0007
.i_month				(`Month	),						//addr 0x0008
.i_day					(`Day	),						//addr 0x0009
.i_nc_pin                              ({7'b0,w_nc_pin}),                            //addr 0x000a 
.i_cpld_compa_version	(8'h00	),  					   	//addr 0x000b
.i_cpld_debug_version	(`DEBUG_VERSION	),  				//addr 0x000c

//PSU--0x000D
.i_PS1_PRSNT                              (db_i_ps1_prsnt)                  , //addr 0x000D bit7
.i_PS2_PRSNT                              (db_i_ps2_prsnt)                  , //addr 0x000D bit6
.i_PS3_PRSNT                              (db_i_ps3_prsnt)                  , //addr 0x000D bit5
.i_PS4_PRSNT                              (db_i_ps4_prsnt)                  , //addr 0x000D bit4
.i_PS1_ACFAIL                            (db_i_ps1_acfail_n)            , //addr 0x000D bit3
.i_PS2_ACFAIL                            (db_i_ps2_acfail_n)            , //addr 0x000D bit2
.i_PS1_DCOK                                (db_i_ps1_dcok_n)                , //addr 0x000D bit1
.i_PS2_DCOK                                (db_i_ps2_dcok_n)                , //addr 0x000D bit0
//PSU--0x000E
.i_PS1_ALERT                              (db_i_ps1_smb_alert)                , //addr 0x000E bit7
.i_PS2_ALERT                              (db_i_ps2_smb_alert)                , //addr 0x000E bit6
.i_PS1_P12V_ON                          (w_ps1_p12v_on_r)                      , //addr 0x000E bit5
.i_PS2_P12V_ON                          (w_ps2_p12v_on_r)                      , //addr 0x000E bit4
.i_PS_OFF                                    (w_pal_ps_off_r)                        , //addr 0x000E bit3
.i_DUAL_EN                                  (w_pal_dual_en_r)                      , //addr 0x000E bit2
.i_P12V_DROOP                            (db_i_pgd_p12v_droop)              , //addr 0x000E bit1
.i_P12V_STBY_DROOP                  (db_i_pgd_p12v_stby_droop)    , //addr 0x000E bit0
//P12V --0x000F
.i_P12V_DISCHARGE                    (w_p12v_discharge_r)                , //addr 0x000F bit7

//POL PGD --0x0010
.i_PGD_P5V_MB                                      (db_i_pgd_p5v                 )           , //addr 0x0010 bit7
.i_PGD_P5V_STBY_MB                            (db_i_pg_p5v_stby         )           , //addr 0x0010 bit6
.i_PGD_P3V3_STBY_MB                          (db_i_pwrgd_p3v3_stby )           , //addr 0x0010 bit5
.i_PGD_P3V3_STBY_B_MB                      (db_i_pgd_p3v3_stby_b )           , //addr 0x0010 bit4
.i_PGD_P1V8_PCH_STBY_MB                  (db_i_p1v8_stby_pg       )           , //addr 0x0010 bit3
.i_PGD_P1V2_STBY_MB                          (db_i_pgd_p1v2_stby     )           , //addr 0x0010 bit2
.i_PGD_P1V05_PCH_STBY_MB                (  )          , //addr 0x0010 bit1
.i_PGD_PVNN_PCH_STBY_MB                  (  )          , //addr 0x0010 bit0

//--0x0011
.i_USB_INNER_OVERCUR3                  (w_usb_inner_overcur3  )      , //addr 0x0011 bit7
.i_USB2_LCD_OC_N                            (w_usb2_lcd_oc_n            )      , //addr 0x0011 bit6

//POL PGD --0x0012
.i_PAL_P5V_EN_R_MB                             (w_pal_p5v_en_r          )    , //addr 0x0012 bit7
.i_PAL_P5V_STBY_EN_R_MB                   (w_p5v_stby_en            )    , //addr 0x0012 bit6
.i_P5V_STBY_USB_EN                             (w_p5v_stby_usb_en     )    , //addr 0x0012 bit5
.i_P5V_EN                                             (  w_p5v_en    )    , //addr 0x0012 bit4
.i_ncsi_main_pwr_en                           ( w_ocp_main_en     )    , //addr 0x0012 bit3
.i_ncsi_aux_pwr_en                             (  w_ocp_aux_en    )    , //addr 0x0012 bit2
.i_PAL_PVNN_STBY_EN_R_MB                 (      )    , //addr 0x0012 bit1
.i_PAL_EN_PWM_CTRL_VCC_R_MB           (      )    , //addr 0x0012 bit0
//0x0013
.o_BMC_JTAG_MUX_S                           (w_bmc_jtag_mux_s),     //addr 0x0013 bit7 default 1


//////////////0X0013 -0X001F RESERVED FOR FUTURE USE/////////////////////////////////////////////////////////////////////////
//CPU0 PGD --0x0020
.i_pwrgd_vdd_33_stby0			(db_i_pgd_p0_vddc			),	//addr 0x0020 bit7
.i_pwrgd_vdd_18_stby0			(db_i_pgd_p0_vdd_18_stby	),	//addr 0x0020 bit6
.i_pal_pgd_p0_vdd_core_1		(db_i_pgd_p0_vdd_core_1		),	//addr 0x0020 bit5
.i_pal_pgd_p0_vdd_core_0		(db_i_pgd_p0_vdd_core_0		),	//addr 0x0020 bit4
.i_pal_pgd_p0_vdd_soc_0			(db_i_pgd_p0_vdd_soc_0		),	//addr 0x0020 bit3
.i_pal_pgd_p0_vddio				(db_i_pgd_p0_vddio			),	//addr 0x0020 bit2
.i_pal_pgd_p0_vdd_sus_0			(db_i_pgd_p0_vdd_11_sus		),	//addr 0x0020 bit1
.i_pal_cpu_sys_pwrok                        (w_cpu_sys_pwrok                        ),    //addr 0x0020 bit0
//CPU0 ALERT --0x0021
.i_p0_pwrgd_out_r				(db_i_p0_pwrgd_out			),	//addr 0x0021 bit7
.i_p0_pwrok_r				        (db_i_p0_pwrok				),	//addr 0x0021 bit6
.i_p0_pwr_good_r				(w_cpu_pwr_good				),	//addr 0x0021 bit5
//CPU0 PWR EN --0x0022
.i_p0_vddc_en					(w_grp_b_p0_33_s5_en		),	//addr 0x0022 bit7
.i_p0_vdd_18_stby_en			(w_grp_b_p0_18_s5_en		),	//addr 0x0022 bit6
.i_pal_p0_vdd_11_sus_en			(w_grp_c_p0_vdd11_en		),	//addr 0x0022 bit5
.i_pal_p0_vddio_en_r			(w_grp_d_p0_vddio_en		),	//addr 0x0022 bit4
.i_pal_p0_vdd_soc_en			(w_grp_d_p0_soc_en			),	//addr 0x0022 bit3
.i_pal_p0_vdd_core_0_en_r		(w_grp_d_p0_vddcore0_en		),	//addr 0x0022 bit2
.i_pal_p0_vdd_core_1_en_r		(w_grp_d_p0_vddcore1_en		),	//addr 0x0022 bit1
//CPU0 PGD --0x0023
.i_pwrgd_vdd_18_stby1			(db_i_pgd_p1_vdd_18_stby	),	//addr 0x0023 bit7	 
.i_pwrgd_vdd_33_stby1			(db_i_pgd_p1_vddc		        ),	//addr 0x0023 bit6	 
.i_pal_pgd_p1_vdd_core_1	        (db_i_pgd_p1_vdd_core_1		),	//addr 0x0023 bit5	 
.i_pal_pgd_p1_vdd_core_0	        (db_i_pgd_p1_vdd_core_0		),	//addr 0x0023 bit4	 
.i_pal_pgd_p1_vdd_soc_0		        (db_i_pgd_p1_vdd_soc_0		),	//addr 0x0023 bit3	 
.i_pal_pgd_p1_vddio			        (db_i_pgd_p1_vddio		        ),	//addr 0x0023 bit2	 
.i_pal_pgd_p1_vdd_sus_0		        (db_i_pgd_p1_vdd_11_sus		),	//addr 0x0023 bit1	 
//CPU1 ALERT --0x0024
.i_p1_pwrgd_out_r				(db_i_p1_pwrgd_out		        ),	//addr 0x0024 bit7	
.i_p1_pwrok_r				        (db_i_p1_pwrok		                ),	//addr 0x0024 bit6	
.i_p1_pwr_good_r			        (db_i_p0_pwrgd_out			),	//addr 0x0024 bit5
//CPU0 PWR EN --0x0025
.i_p1_vdd_18_stby_en			(w_grp_b_p1_18_s5_en		),	//addr 0x0025 bit7	
.i_p1_vddc_en					(w_grp_b_p1_33_s5_en		),	//addr 0x0025 bit6	
.i_pal_p1_vdd_11_sus_en			(w_grp_c_p1_vdd11_en		),	//addr 0x0025 bit5	
.i_pal_p1_vddio_en_r			(w_grp_d_p1_vddio_en		),	//addr 0x0025 bit4	
.i_pal_p1_vdd_soc_en			(w_grp_d_p1_soc_en		        ),	//addr 0x0025 bit3	
.i_pal_p1_vdd_core_0_en_r		(w_grp_d_p1_vddcore0_en		),	//addr 0x0025 bit2	
.i_pal_p1_vdd_core_1_en_r		(w_grp_d_p1_vddcore1_en		),	//addr 0x0025 bit1	
//CPU PRSNT --0x0030
.i_PAL_CPU0_PRSNT_N                          (db_cpu_prsnt_n[0] & w_SW_1    ),     //addr 0x0030 bit7
.i_PAL_CPU1_PRSNT_N                          (db_cpu_prsnt_n[1] & w_SW_1    ),     //addr 0x0030 bit6
//CPU ERR --0x0032
.i_P0_SMERR_N                                      (db_i_p0_smerr_n                        ),      //addr 0x0032 bit7
.i_P1_SMERR_N                                      (db_i_p1_smerr_n                        ),      //addr 0x0032 bit6
//CPU THERM --0x0033
.i_PAL_CPU0_MEMHOT_OUT_N                (  )         , //addr 0x0033 bit7 
.i_PAL_CPU0_MEMTRIP_N                      (  )         , //addr 0x0033 bit6 
.i_PAL_CPU0_THERMTRIP_N                  (db_i_p0_pwrgd_out ? wFM_CPU0_THERMTRIP_LVT3_Fault_N :1'b1 )  , //addr 0x0033 bit5 
.i_PAL_CPU0_PROCHOT_N                      (w_p0_prochot_n ),                                                                                      //addr 0x0033 bit4 
.i_PAL_CPU1_MEMHOT_OUT_N                ( )         , //addr 0x0033 bit3 
.i_PAL_CPU1_MEMTRIP_N                      ( )         , //addr 0x0033 bit2
.i_PAL_CPU1_THERMTRIP_N                  (~(db_cpu_prsnt_n[1] & w_SW_1) & db_i_p1_pwrgd_out ? wFM_CPU1_THERMTRIP_LVT3_Fault_N :1'b1)  , //addr 0x0033 bit1
.i_PAL_CPU1_PROCHOT_N                      (w_p1_prochot_n )             , //addr 0x0033 bit0 


//pwr_flt_clr --0x0034
.o_bmc_clr_tmout_n                            (w_bmc_clr_tmout_n)                 , //addr 0x0034 bit7  //default 1
.o_pal_cpu0_forcepr_r                      (w_cpu0_prochot)              , //addr 0x0034 bit6  //default 0
.o_pal_cpu1_forcepr_r                      (w_cpu1_prochot)              , //addr 0x0034 bit5  //default 0
.o_clear_register                              (w_clear_register)                  , //addr 0x0034 bit4  //default 0

// .o_cpu0_prochot						(w_cpu0_prochot					),	//addr 0x02a2 bit2 
// .o_cpu1_prochot						(w_cpu1_prochot			                ),	//addr 0x02a9 bit2 

//pwr_flt_code --0x0035
.i_pwr_flt_code                                  (w_pwr_flt_code)                    , //addr 0x0035       //default 8'h00
//////////////0X0036 -0X004F RESERVED FOR FUTURE USE///////////////////////////////////////////////////////////////////
//btn_press_flag --0x0050
.i_btn_press_flag                              (w_btn_press_flag )                 , //addr 0x0050 bit7
.i_slps5_sts                                        (db_i_p0_slp_s5_n )                 , //addr 0x0050 bit6  
.i_slps3_sts                                        (db_i_p0_slp_s3_n )                 , //addr 0x0050 bit5  
//btn_evt --0x0051
.i_sbtn_pwron_evt                              (w_sbtn_pwron_evt    )               , //addr 0x0051 bit7
.i_lbtn_pwrdown_evt                          (w_lbtn_pwrdown_evt)               , //addr 0x0051 bit6
.i_sbtn_sysrst_evt                            (w_sbtn_sysrst_evt  )               , //addr 0x0051 bit5
//bmc_clr_btn_evt --0x0052
.o_bmc_clr_sbtn_n                              (w_bmc_sbtn_wc          )                , //addr 0x0052 bit7  //default 1
.o_bmc_clr_lbtn_n                              (w_bmc_lbtn_wc          )                , //addr 0x0052 bit6  //default 1
.o_bmc_clr_sbtn_sys_n                      (w_bmc_sbtn_sys_wc  )                , //addr 0x0052 bit5  //default 1
//bmc_btn_ctl --0x0053
.o_pwr_btn_lock                                  (w_bmc_pwrbtn_lock       )  		, //addr 0x0053 bit7  //default 1
.o_bmc_power_soft_ctl                      (w_bmc_sbtn_powerdown )           , //addr 0x0053 bit6  //default 0
.o_bmc_lbtn_pwrdown_ctl                  (w_bmc_lbtn_powerdown )           , //addr 0x0053 bit5  //default 0
.o_bmc_sbtn_pwron_ctl                      (w_bmc_sbtn_poweron     )           , //addr 0x0053 bit4  //default 0
.o_bmc_sbtn_sysrst_ctl                    (w_bmc_sbtn_reset_ctl )           , //addr 0x0053 bit3  //default 0
//bmc_btn_done --0x0054
.i_bmc_power_soft_done                    (w_bmc_sbtn_powerdown_done ) , //addr 0x0054 bit7
.i_bmc_lbtn_pwrdown_done                (w_bmc_lbtn_powerdown_done ) , //addr 0x0054 bit6
.i_bmc_sbtn_pwron_done                    (w_bmc_sbtn_poweron_done     ) , //addr 0x0054 bit5
.i_bmc_sbtn_sysrst_done                  (w_bmc_ctl_sys_rst_done       ) , //addr 0x0054 bit4

//bmc_uid --0x0056
.i_pal_bmcuid_button                        (db_i_pal_bmcuid_button)         , //addr 0x0056 bit7
//0x0065
.i_p1_vr_i2c7_alert_n			(~db_i_p1_vr_i2c7_alert_n),	//addr 0x0065 bit7
.i_p0_vr_i2c7_alert_n			(~db_i_p0_vr_i2c7_alert_n),	//addr 0x0065 bit6		
//0x0066
.i_P0_MCIOP0A_NVME0_PRSNT_N_R      (i_P0_MCIOP0A_NVME0_PRSNT_N_R) ,//addr 0x0066 bit7 
.i_P0_MCIOP0C_NVME0_PRSNT_N_R      (i_P0_MCIOP0C_NVME0_PRSNT_N_R) ,//addr 0x0066 bit6 
.i_P0_MCIOP0A_NVME1_PRSNT_N_R      (i_P0_MCIOP0A_NVME1_PRSNT_N_R) ,//addr 0x0066 bit5 
.i_P0_MCIOP0C_NVME1_PRSNT_N_R      (i_P0_MCIOP0C_NVME1_PRSNT_N_R) ,//addr 0x0066 bit4 

//u72_data4      --0x006a
.i_pal_m2_0_prsnt_n                          (w_PAL_M2_0_PRSNT_N       )         , //addr 0x006a bit7 
.i_pal_m2_1_prsnt_n                          (w_PAL_M2_1_PRSNT_N       )         , //addr 0x006a bit6 
.i_pal_bp1_prsnt_n                            (w_PAL_BP1_PRSNT_N         )         , //addr 0x006a bit5
.i_pal_bp2_prsnt_n                            (w_PAL_BP2_PRSNT_N         )         , //addr 0x006a bit4
.i_pal_bp3_prsnt_n                            (w_PAL_BP3_PRSNT_N         )         , //addr 0x006a bit3
.i_pal_bp4_prsnt_n                            (w_PAL_BP4_PRSNT_N         )         , //addr 0x006a bit2
.i_pal_bp5_prsnt_n                            (w_PAL_BP5_PRSNT_N         )         , //addr 0x006a bit1
.i_pal_bp6_prsnt_n                            (w_PAL_BP6_PRSNT_N         )         , //addr 0x006a bit0
//0x006b                                                                                                           
.i_pal_bp8_prsnt_n                            (w_PAL_BP8_PRSNT_N         )         , //addr 0x006a bit7

//gpu_throttle_n--0x006c
.o_p0_mciop0a_gpu_throttle_n_r    (w_p0_mciop0a_gpu_throttle_n_r )    , //addr 0x006c bit7     //default 0
.o_p0_mciop0c_gpu_throttle_n_r	(w_p0_mciop0c_gpu_throttle_n_r )    , //addr 0x006c bit6     //default 0

//scpld_data --0x0070
.i_p1_pcie_wake_n_r                          (w_p1_pcie_wake_n     )           , //addr 0x0070 bit3
.i_p0_pcie_wake_n_r                          (w_p0_pcie_wake_n     )           , //addr 0x0070 bit2
//0x0073
.o_i3c_mux_en		                        (w_i3c_mux_en	       ),	//addr 0x0073 bit7	//default 0
.o_i3c_remote_cs                                (w_i3c_remote_cs       ),     //addr 0x0073 bit4	//default 0
//EEP WR--0x0074
.o_eeprom_wp	                                (w_eeprom_wp                                ), //addr 0x0074 bit7	//default 0
.o_scaled_bat_test_en_r	                (w_ctl_scaled_bat_test_en_r  ), //addr 0x0074 bit6	//default 0
.o_bmc_nmi_event                                (w_bmc_nmi_event                        ), //addr 0x0074 bit5	//default 0
.o_rtc_senor_sw					(w_rtc_senor_sw				), //addr 0x03A1 bit0    //default 0

//pcycle--0x0076
.o_aux_pcycle                                      (w_pal_p3v3_stby_rst_r )            ,  //addr 0x0076 bit7    //default 0
.o_usb_sw_s                                          (w_usb_sw_s                       )            ,  //addr 0x0076 bit6    //default 0
//gpu_pwr --0x0077
.o_p12v_slot_0_on                              (w_p12v_slot_0_on)                  ,  //addr 0x0077 bit7    //default 1
.o_p12v_slot_1_on                              (w_p12v_slot_1_on)                  ,  //addr 0x0077 bit6    //default 1
.o_p12v_slot_2_on                              (w_p12v_slot_2_on)                  ,  //addr 0x0077 bit5    //default 1

//i2c_mux_rst -- 0x0078
.o_bmc_i2c5_9548_rst_n			(w_bmc_i2c5_9548_rst_n	),	//addr 0x0078 bit7
.o_bmc_i2c9_9548_1_rst_n		(w_bmc_i2c9_9548_1_rst_n),	//addr 0x0078 bit6
.o_bmc_i2c9_9548_2_rst_n		(w_bmc_i2c9_9548_2_rst_n),	//addr 0x0078 bit5
.o_bmc_i2c9_9548_3_rst_n		(w_bmc_i2c9_9548_3_rst_n),	//addr 0x0078 bit4
.o_bmc_i2c9_9548_4_rst_n		(w_bmc_i2c9_9548_4_rst_n),	//addr 0x0078 bit3
.o_p0_vpp_9545_1_rst_n			(w_p0_vpp_9545_1_rst_n	),	//addr 0x0078 bit2
.o_p0_vpp_9545_2_rst_n			(w_p0_vpp_9545_2_rst_n	),	//addr 0x0078 bit1

//0X0089
.i_switch_mode                              (r_switch_mode        )             ,  //addr 0x0089    //default 0xff
//0X008A
.o_164_mr_n                             (w_164_mr_n           )             ,  //addr 0x008a bit7   //default 1 //2025-1-16 del

//0x008b
.i_pch_bios_post_cmplt_n                (db_i_p0_bios_post_stage_r_n )          ,  //addr 0x008b bit7

.o_164_test_data                          (w_164_test_data      )             ,  //addr 0x008c    //default 0xff //2024-5-14 chg 0f to ff
.i_switch2_mode                              (r_switch2_mode        )             ,  //addr 0x008d    //default 0xff

//0x008e
.i_LEAKAGE0_PRSNT_N                            (~w_LEAKAGE0_PRSNT_N          ),    //addr 0x008e   bit7
.i_BREAK_DET_DO_N                                (~w_BREAK_DET_DO_N              ),    //addr 0x008e   bit6
.i_LEAKAGE_DET_DO_N                            (~w_LEAKAGE_DET_DO_N          ),    //addr 0x008e   bit5
.i_LEAKAGE_PRSNT1_N                            (~w_LEAKAGE_PRSNT1_N          ),    //addr 0x008e   bit4
.i_BREAK_DET1_DO_N                              (~w_BREAK_DET1_DO_N            ),    //addr 0x008e   bit3
.i_LEAKAGE_DET1_DO_N                          (~w_LEAKAGE_DET1_DO_N        ),    //addr 0x008e   bit2

//0x008f
.o_leakage_int_mask                          (w_leakage_int_mask)                  ,  //0x008f bit7  //2024-8-13 add //default 1
//0x0090
.i_p0_spd_host_ctrl_n				(db_i_p0_spd_host_ctrl_n		),	//addr 0x0090 bit6
//0x0091
.i_p12v_stby_fault_det			(w_p12v_stby_fault_det				),	//addr 0x0091 bit7
.i_p5v_stby_fault_det			(w_p5v_stby_fault_det				),	//addr 0x0091 bit6
.i_grp_b_p0_33_s5_fault_det		(w_grp_b_p0_33_s5_fault_det			),	//addr 0x0091 bit3
.i_grp_b_p1_33_s5_fault_det		(w_grp_b_p1_33_s5_fault_det		        ),	//addr 0x0091 bit2	
.i_grp_b_p0_18_s5_fault_det		(w_grp_b_p0_18_s5_fault_det			),	//addr 0x0091 bit1
.i_grp_b_p1_18_s5_fault_det		(w_grp_b_p1_18_s5_fault_det		        ),	//addr 0x0091 bit0	
//0x0092
.i_p5v_fault_det				(w_p5v_fault_det					),	//addr 0x0092 bit6
.i_p12v_efuse_fault_det			(				),	//addr 0x0092 bit5
.i_p12v_ssd_efuse_fault_det		(			),	//addr 0x0092 bit4
.i_p12v_p0_dimm_fault_det		(			),	//addr 0x0092 bit3
.i_p12v_p1_dimm_fault_det		(		        ),	//addr 0x0092 bit2	 
.i_grp_c_p0_fault_det			(w_grp_c_p0_fault_det				),	//addr 0x0092 bit1
.i_grp_c_p1_fault_det			(w_grp_c_p1_fault_det		                ),	//addr 0x0092 bit0	 
//0x0093
.i_grp_d_vddio_p0_fault_det		(w_grp_d_vddio_p0_fault_det			),	//addr 0x0093 bit7 
.i_grp_d_vddio_p1_fault_det		(w_grp_d_vddio_p1_fault_det		        ),	//addr 0x0093 bit6 	   
.i_grp_d_soc_p0_fault_det		(w_grp_d_soc_p0_fault_det		        ),	//addr 0x0093 bit5 
.i_grp_d_soc_p1_fault_det		(w_grp_d_soc_p1_fault_det		        ),	//addr 0x0093 bit4	 
.i_grp_d_p0_vddcore0_fault_det	(w_grp_d_p0_vddcore0_fault_det            ),	//addr 0x0093 bit3
.i_grp_d_p1_vddcore0_fault_det	(w_grp_d_p1_vddcore0_fault_det		),	//addr 0x0093 bit2	 
.i_grp_d_p0_vddcore1_fault_det	(w_grp_d_p0_vddcore1_fault_det            ),	//addr 0x0093 bit1
.i_grp_d_p1_vddcore1_fault_det	(w_grp_d_p1_vddcore1_fault_det		),	//addr 0x0093 bit0	 


.i_p1_vdd_core_1_ocp_n		        (~db_i_pal_p1_vdd_core_1_ocp_n	        ),	//addr 0x009D bit7	
.i_p1_vdd_core_0_ocp_n		        (~db_i_p1_vdd_core_0_ocp_n_r	        ),	//addr 0x009D bit6	
.i_p1_vddio_ocp_n			        (~db_i_p1_vddio_ocp_n		                ),	//addr 0x009D bit5	
.i_p1_efuse_fault_n			        (1'b0		),							//addr 0x009D bit4	
.i_p0_vdd_core_1_ocp_n		        (~db_i_pal_p0_vdd_core_1_ocp_n	        ),	//addr 0x009D bit3
.i_p0_vdd_core_0_ocp_n		        (~db_i_p0_vdd_core_0_ocp_n_r		),	//addr 0x009D bit2
.i_p0_vddio_ocp_n			        (~db_i_p0_vddio_ocp_n				),	//addr 0x009D bit1

.i_rtc_sqw                                  (~i_RTC_SQW		                                ),	//addr 0x009E bit7	
.i_rtc_inta_n                            (~i_RTC_INTA_N					),	//addr 0x009E bit6

.i_p1_i3c_apml_alert_n          (~i_P1_I3C_APML_ALERT_N		        ),	//addr 0x009E bit4	
.i_p0_i3c_apml_alert_n          (~i_P0_I3C_APML_ALERT_N			),	//addr 0x009E bit3
.i_clk_gen_en_r_n                    (w_clk_gen_en_r_n				),	//addr 0x009E bit2	
.i_clk_gen_alert_r_n              (~i_CLK_GEN_ALERT_R_N		        ),	//addr 0x009E bit1	

.o_force_allpwron_ctl           ( w_force_allpwron_ctl			),	//addr 0x00A0 bit0	

//////////////////////////////////0x00C0-0x00D0 for FIX REG////////////////////////////////////////////////////////////

.i_PRODUCT_LINE_C2	                        (`PRODUCT_LINE_C2       )    , //addr 0x00C2
.i_PRODUCT_GEN_ID_C3                        (`PRODUCT_GEN_ID_C3   )    , //addr 0x00C3
.i_SERVER_ID_C5                                  (w_server_id_c5            )    , //addr 0x00C5  //2025-3-13`SERVER_ID_C5 
.i_BOARD_ID_C6                                    (`BOARD_ID_C6               )    , //addr 0x00C6

//////////////////////////////////0x00C0-0x00D0 for FIX REG////////////////////////////////////////////////////////////

//0x00D1
.o_fm_pld_db800_3_clks_dev_en	        (fm_pld_db800_3_clks_en		),	//addr 0x00D1 bit6
//0x00F4
.i_cpu1_reset_n					(db_i_p1_reset_n			),	//addr 0x00F4 bit0
.i_cpu0_reset_n					(db_i_p0_reset_n			),	//addr 0x00F4 bit0

//0X0103
.i_p1_vdd_core_0_soc_rst_l_n		(db_i_p1_pwrok		),	//addr 0x0103 bit7	 
.i_p1_vdd_core_1_11_sus_rst_l_n		(db_i_p1_pwrok		),	//addr 0x0103 bit6	 
.i_p1_vddio_rst_l_n					(db_i_p1_pwrok		),	//addr 0x0103 bit5	 
.i_p0_vddio_rst_l_n					(db_i_p0_pwrok		),	//addr 0x0103 bit4
.i_p0_vdd_core_0_soc_rst_l_n		(db_i_p0_pwrok		),	//addr 0x0103 bit3
.i_p0_vdd_core_1_11_sus_rst_l_n		(db_i_p0_pwrok		),	//addr 0x0103 bit2
.i_cpu_sys_reset_r_n				(db_i_pal_ext_rst_n	),	//addr 0x0103 bit1
.i_cpu_rsmrst_r_n					(w_rsmrst_n			),	//addr 0x0103 bit0 

//0x0105
.o_jtag_cpld_bmc_ntrst_r			(w_jtag_cpld_bmc_ntrst_reg		),	//addr 0x0105 bit4
//0x0130
.o_bmc_warm_reset_ctl				(w_bmc_warm_reset_ctl				),	//addr 0x0130 bit5

//0x0200
.i_power_alarm_flag		                (w_power_fault		                                ),	//addr 0x0012 bit0
//0x0201
.i_stb_pwron_tmout_fail			(w_dc_failure_detected				),	//addr 0x0030 bit7
.o_bmc_clr_stby_tmout_n			(w_stb_pwron_tmout_fail_clr			),	//addr 0x0030 bit7      

.i_stb_pwrdown_ukwn_fail		(w_power_fault_detected				),	//addr 0x0030 bit6  
.o_bmc_clr_stby_pwr_drop_n		(w_stb_pwrdown_ukwn_fail_clr		),	//addr 0x0030 bit6

.i_poweron_tmout_fail			(w_dc_failure_detected				),	//addr 0x0030 bit5
.o_bmc_clr_core_tmout_n			(w_poweron_tmout_fail_clr			),	//addr 0x0030 bit5 

.i_powerdown_ukwn_fail			(w_rt_failure_detected | w_stby_failure_detected ),//addr 0x0030 bit4
.i_st_aux_fail_recovery			(w_st_aux_fail_recovery | r_p12v_moc_stby_en_neg	),	//addr 0x0030 bit3 
.i_system_pwr_sts				(w_all_power_pg & db_i_p0_slp_s5_n	),	//addr 0x0030 bit0

//0x0202
.i_power_on_fail_err_code		(r_timeout_code						),	//addr 0x0032 
.o_power_on_fail_err_code_clr	(w_power_on_fail_err_code_clr		),	//addr 0x0032 
//0x0203
.i_power_down_fail_err_code		(r_pwrdrop_code						),	//addr 0x0033 
.o_power_down_fail_err_code_clr	(w_power_down_fail_err_code_clr		),	//addr 0x0033     
//0x0205
.i_power_seq_state_machine		({2'b0,w_power_seq_sm	}			),	//addr 0x0035 
//0x0206
.i_power_seq_fault_latch		({2'b0,w_pwrseq_sm_fault_det	}	),	//addr 0x0036

//0x02A1
.i_cpu0_thermtrip					(w_cpu_thermtrip_fault_det[0]	),	//addr 0x02a1 bit7  
.o_cpu0_thermtrip_clr				(w_cpu0_thermaltrip_clr			),	//addr 0x02a1 bit7  
//0x02A8
.i_cpu1_thermtrip					(w_cpu_thermtrip_fault_det[1]	),	//addr 0x02a8 bit7 
.o_cpu1_thermtrip_clr				(w_cpu1_thermaltrip_clr			),	//addr 0x02a8 bit7 
//0x02c0
.o_sys_debug_mode					(w_sys_debug_mode				),	//addr 0x02C0 bit0 

//0x02e0
.i_p0_coretype2						(i_P0_CORETYPE_2		),	//addr 0x02E0 bit6
.i_p0_coretype1						(i_P0_CORETYPE_1		),	//addr 0x02E0 bit5
.i_p0_coretype0						(i_P0_CORETYPE_0		),	//addr 0x02E0 bit4
.i_p0_sp5r4							(i_P0_SP5R_R_4			),	//addr 0x02E0 bit3
.i_p0_sp5r3							(i_P0_SP5R_R_3			),	//addr 0x02E0 bit2
.i_p0_sp5r2							(i_P0_SP5R_R_2			),	//addr 0x02E0 bit1
.i_p0_sp5r1							(i_P0_SP5R_R_1			),	//addr 0x02E0 bit0
//0x02e8
.i_p1_coretype2						(i_P1_CORETYPE_2		),	//addr 0x02E8 bit6	
.i_p1_coretype1						(i_P1_CORETYPE_1		),	//addr 0x02E8 bit5	
.i_p1_coretype0						(i_P1_CORETYPE_0		),	//addr 0x02E8 bit4	
.i_p1_sp5r4							(i_P1_SP5R_R_4			),	//addr 0x02E8 bit3	
.i_p1_sp5r3							(i_P1_SP5R_R_3			),	//addr 0x02E8 bit2	
.i_p1_sp5r2							(i_P1_SP5R_R_2			),	//addr 0x02E8 bit1	
.i_p1_sp5r1							(i_P1_SP5R_R_1			),	//addr 0x02E8 bit0	

//0x0300
.i_dimm_alarm_flag					(w_dimm_alarm_flag				),	//addr 0x0300 bit0

//0x0312
.i_p1_dimm_gl_pwrgd_fail_event		(w_p1_dimm_gl_pwrgd_fail_event	    ),	//addr 0x0312 bit3	
.o_p1_dimm_gl_pwrgd_fail_event_clr	(w_p1_dimm_gl_pwrgd_fail_event_clr),	//addr 0x0312 bit3	
.i_p1_dimm_af_pwrgd_fail_event		(w_p1_dimm_af_pwrgd_fail_event	    ),	//addr 0x0312 bit2	
.o_p1_dimm_af_pwrgd_fail_event_clr	(w_p1_dimm_af_pwrgd_fail_event_clr),	//addr 0x0312 bit2	
.i_p0_dimm_gl_pwrgd_fail_event		(w_p0_dimm_gl_pwrgd_fail_event	    ),	//addr 0x0312 bit1
.o_p0_dimm_gl_pwrgd_fail_event_clr	(w_p0_dimm_gl_pwrgd_fail_event_clr),	//addr 0x0312 bit1
.i_p0_dimm_af_pwrgd_fail_event		(w_p0_dimm_af_pwrgd_fail_event	    ),	//addr 0x0312 bit0
.o_p0_dimm_af_pwrgd_fail_event_clr	(w_p0_dimm_af_pwrgd_fail_event_clr),	//addr 0x0312 bit0
//0x03a0
//.o_bios_reflash						(bios_reflash					),	//addr 0x03A0 bit7
.o_bmc_nmi_ctl						(w_bmc_nmi_ctl					),	//addr 0x03A0 bit6
.i_bmc_nmi_ctl						(w_bmc_nmi_ctl_rst				),	//addr 0x03A0 bit6
.i_bmc_clr_cmos						(w_clr_cmos_done_rst			),	//addr 0x03A0 bit4
.o_clr_cmos_ctl						(w_clr_cmos_flg					),	//addr 0x03A0 bit4

.o_espi_ram_1050                        (w_espi_ram_1050)                   , //addr 0x1050 //default 0xff
.o_espi_ram_1051                        (w_espi_ram_1051)                   , //addr 0x1051 //default 0xff
.o_espi_ram_1052                        (w_espi_ram_1052)                   , //addr 0x1052 //default 0xff
.o_espi_ram_1053                        (w_espi_ram_1053)                   , //addr 0x1053 //default 0xff
.o_espi_ram_1054                        (w_espi_ram_1054)                   , //addr 0x1050 //default 0xff
.i_espi_ram_1055                        (w_espi_ram_1055)                   , //addr 0x1051 //default 0xff
.i_espi_ram_1056                        (w_espi_ram_1056)                   , //addr 0x1052 //default 0xff
.i_espi_ram_1057                        (w_espi_ram_1057)                   , //addr 0x1053 //default 0xff
.i_espi_ram_1058                        (w_espi_ram_1058)                      //addr 0x1053 //default 0xff


);


/************************************************************************************************************************************************************************/
//--------------------------------------------------------------------------------------------------------------------------------------------------
//I2C RAM  End
//--------------------------------------------------------------------------------------------------------------------------------------------------
/************************************************************************************************************************************************************************/


endmodule



