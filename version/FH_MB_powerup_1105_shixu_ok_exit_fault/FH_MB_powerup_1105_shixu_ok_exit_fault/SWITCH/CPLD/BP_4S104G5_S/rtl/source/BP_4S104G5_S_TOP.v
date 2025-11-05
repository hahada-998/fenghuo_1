//=================================================================================================
// Copyright(c) 
// Filename   : BP_4S104G5_S_TOP
// Project    : BP_4S104G5_S
// Author     : 
// Date       : 2024-08-28
//Simulator   : Lattice Diamond 3.12
//FPGA        : LCMXO2_4000HC_4BG256C
// Email      : cloudnineinfo.com
// Company    : 
// Description: BP_4S104G5_S Top Code
// History    :
// Date      By          Revision  Change Description
//------------------------------------------------------------------------------
//-- Principle of Naming:
//-- In BP_4S104G5_S  : ONE CPLD,this Code for Master CPLD_U1
//-- CPLD     BOARD NAME            PCB CODE        BOARD ID     TAG NO    JTAG CON

//-- CPLD     BP_4S104G5_S      
`timescale 1ns/1ps
`include "../include/BP_4S104G5_VA_S_port.v"
// `include "BP_4S104G5_VA_S_port.v"

//------------------------------------------------------------------------------
// define parameter
//------------------------------------------------------------------------------
`define PRODUCT_ID      8'h33
`define VENDER_ID       8'h08

`define Year            8'h25
`define Month           8'h04
`define Day             8'h09
`define CPLD_VERSION    8'h10
`define DEBUG_VERSION   8'h00

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
  .CLKI     (i_CPLD2_CLK         ), //in
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
  .clk             (clk_50m     ),
  .reset           (~pon_reset_n),
  .t40ns           (t40ns_tick  ),
  .t80ns           (),
  .t160ns          (),
  .t1us            (t1us_tick   ),
  .t2us            (t2us_tick   ),
  .t16us           (t16us_tick  ),
  .t32us           (t32us_tick  ),
  .t128us          (t128us_tick ),
  .t512us          (t512us_tick ),
  .t1ms            (t1ms_tick   ),
  .t2ms            (t2ms_tick   ),
  .t16ms           (),
  .t32ms           (t32ms_tick  ),
  .t64ms           (t64ms_tick  ),
  .t128ms          (t128ms_tick ),
  .t256ms          (t256ms_tick ),
  .t512ms          (t512ms_tick ),
  .t1s             (t1s_tick    ),
  .clk_1hz         (t1hz_clk    ),
  .clk_0p5hz       (t0p5hz_clk	),
  .clk_2p5hz       (t2p5hz_clk  ),
  .clk_4hz         (t4hz_clk    ),
  .clk_16khz       (t16khz_clk  ),
  .clk_6m25        (t6m25_clk   )

);
//-------------------------------------------------------------------------------------------------
//Clock generation and CE
//-------------------------------------------------------------------------------------------------
//% Clock divider three - Generates the following synchronous clock enables: 10uS, 50uS, 500uS, 1mS, 20mS and 250mS
ClkDivTree mClkDivTree
(
    .iClk           ( clk_50m            ),
    .iRst           ( ~pon_reset_n       ),
    .o1uSCE         ( w1uSCE             ),
    .o10uSCE        ( w10uSCE            ),
    .o50uSCE        ( w50uSCE            ),
    .o500uSCE       ( w500uSCE           ),
    .o1mSCE         ( w1mSCE             ),
    .o250mSCE       ( w250mSCE           ),
    .o10mSCE        ( w10mSCE            ),
    .o20mSCE        ( w20mSCE            ),
    .o1SCE          ( w1SCE              )
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
.i2c1_scl	(io_I2C1_CPLD2_UPDATE_SCL	),
.i2c1_sda	(io_I2C1_CPLD2_UPDATE_SDA	)
); 
/************************************************************************************************************************************************************************/
//--------------------------------------------------------------------------------------------------------------------------------------------------
//I2C Update End
//--------------------------------------------------------------------------------------------------------------------------------------------------
/************************************************************************************************************************************************************************/
wire  w_npu1_4_gpu_throttle_r_n;
wire  w_npu5_8_gpu_throttle_r_n;
wire  w_nic1_4_gpu_throttle_r_n;
wire  w_nic5_8_gpu_throttle_r_n;
wire  w_mcio01_11_gpu_throttle_r_n;
wire  w_mcio02_12_gpu_throttle_r_n;
wire  w_mcio21_31_gpu_throttle_r_n;
wire  w_mcio22_32_gpu_throttle_r_n;

wire  w_MCIO01A_CB_ID0_R;
wire  w_MCIO01A_CB_ID1_R;
wire  w_MCIO01C_CB_ID0_R;
wire  w_MCIO01C_CB_ID1_R;
wire  w_MCIO02A_CB_ID0_R;
wire  w_MCIO02A_CB_ID1_R;
wire  w_MCIO02C_CB_ID0_R;
wire  w_MCIO02C_CB_ID1_R;
wire  w_MCIO11A_CB_ID0_R;
wire  w_MCIO11A_CB_ID1_R;
wire  w_MCIO11C_CB_ID0_R;
wire  w_MCIO11C_CB_ID1_R;
wire  w_MCIO12A_CB_ID0_R;
wire  w_MCIO12A_CB_ID1_R;
wire  w_MCIO12C_CB_ID0_R;
wire  w_MCIO12C_CB_ID1_R;
wire  w_MCIO21A_CB_ID0_R;
wire  w_MCIO21A_CB_ID1_R;
wire  w_MCIO21C_CB_ID0_R;
wire  w_MCIO21C_CB_ID1_R;
wire  w_MCIO22A_CB_ID0_R;
wire  w_MCIO22A_CB_ID1_R;
wire  w_MCIO22C_CB_ID0_R;
wire  w_MCIO22C_CB_ID1_R;
wire  w_MCIO31A_CB_ID0_R;
wire  w_MCIO31A_CB_ID1_R;
wire  w_MCIO31C_CB_ID0_R;
wire  w_MCIO31C_CB_ID1_R;
wire  w_MCIO32A_CB_ID0_R;
wire  w_MCIO32A_CB_ID1_R;
wire  w_MCIO32C_CB_ID0_R;
wire  w_MCIO32C_CB_ID1_R;

wire  w_nvme1_cb_id0_r;
wire  w_nvme1_cb_id1_r;
wire  w_nvme2_cb_id0_r;
wire  w_nvme2_cb_id1_r;
wire  w_nvme3_cb_id0_r;
wire  w_nvme3_cb_id1_r;
wire  w_nvme4_cb_id0_r;
wire  w_nvme4_cb_id1_r;

wire  w_npu1a_cb_id1_r;
wire  w_npu1c_cb_id1_r;
wire  w_npu2a_cb_id1_r;
wire  w_npu2c_cb_id1_r;
wire  w_npu3a_cb_id1_r;
wire  w_npu3c_cb_id1_r;
wire  w_npu4a_cb_id1_r;
wire  w_npu4c_cb_id1_r;
wire  w_npu5a_cb_id1_r;
wire  w_npu5c_cb_id1_r;
wire  w_npu6a_cb_id1_r;
wire  w_npu6c_cb_id1_r;
wire  w_npu7a_cb_id1_r;
wire  w_npu7c_cb_id1_r;
wire  w_npu8a_cb_id1_r;
wire  w_npu8c_cb_id1_r;

wire  w_nic1a_cb_id0_r;
wire  w_nic1a_cb_id1_r;
wire  w_nic1c_cb_id0_r;
wire  w_nic1c_cb_id1_r;
wire  w_nic2a_cb_id0_r;
wire  w_nic2a_cb_id1_r;
wire  w_nic2c_cb_id0_r;
wire  w_nic2c_cb_id1_r;
wire  w_nic3a_cb_id0_r;
wire  w_nic3a_cb_id1_r;
wire  w_nic3c_cb_id0_r;
wire  w_nic3c_cb_id1_r;
wire  w_nic4a_cb_id0_r;
wire  w_nic4a_cb_id1_r;
wire  w_nic4c_cb_id0_r;
wire  w_nic4c_cb_id1_r;
wire  w_nic5a_cb_id0_r;
wire  w_nic5a_cb_id1_r;
wire  w_nic5c_cb_id0_r;
wire  w_nic5c_cb_id1_r;
wire  w_nic6a_cb_id0_r;
wire  w_nic6a_cb_id1_r;
wire  w_nic6c_cb_id0_r;
wire  w_nic6c_cb_id1_r;
wire  w_nic7a_cb_id0_r;
wire  w_nic7a_cb_id1_r;
wire  w_nic7c_cb_id0_r;
wire  w_nic7c_cb_id1_r;
wire  w_nic8a_cb_id0_r;
wire  w_nic8a_cb_id1_r;
wire  w_nic8c_cb_id0_r;
wire  w_nic8c_cb_id1_r;



//-------------------------------------------------------------------------------------------------
//  ID  Assign
// ------------------------------------------------------------------------------------------------
assign  w_MCIO01A_CB_ID0_R = i_MCIO01A_CB_ID0_R ;
assign  w_MCIO01A_CB_ID1_R = i_MCIO01A_CB_ID1_R ;
assign  w_MCIO01C_CB_ID0_R = i_MCIO01C_CB_ID0_R ;
assign  w_MCIO01C_CB_ID1_R = i_MCIO01C_CB_ID1_R ;
assign  w_MCIO02A_CB_ID0_R = i_MCIO02A_CB_ID0_R ;
assign  w_MCIO02A_CB_ID1_R = i_MCIO02A_CB_ID1_R ;
assign  w_MCIO02C_CB_ID0_R = i_MCIO02C_CB_ID0_R ;
assign  w_MCIO02C_CB_ID1_R = i_MCIO02C_CB_ID1_R ;
assign  w_MCIO11A_CB_ID0_R = i_MCIO11A_CB_ID0_R ;
assign  w_MCIO11A_CB_ID1_R = i_MCIO11A_CB_ID1_R ;
assign  w_MCIO11C_CB_ID0_R = i_MCIO11C_CB_ID0_R ;
assign  w_MCIO11C_CB_ID1_R = i_MCIO11C_CB_ID1_R ;
assign  w_MCIO12A_CB_ID0_R = i_MCIO12A_CB_ID0_R ;
assign  w_MCIO12A_CB_ID1_R = i_MCIO12A_CB_ID1_R ;
assign  w_MCIO12C_CB_ID0_R = i_MCIO12C_CB_ID0_R ;
assign  w_MCIO12C_CB_ID1_R = i_MCIO12C_CB_ID1_R ;
assign  w_MCIO21A_CB_ID0_R = i_MCIO21A_CB_ID0_R ;
assign  w_MCIO21A_CB_ID1_R = i_MCIO21A_CB_ID1_R ;
assign  w_MCIO21C_CB_ID0_R = i_MCIO21C_CB_ID0_R ;
assign  w_MCIO21C_CB_ID1_R = i_MCIO21C_CB_ID1_R ;
assign  w_MCIO22A_CB_ID0_R = i_MCIO22A_CB_ID0_R ;
assign  w_MCIO22A_CB_ID1_R = i_MCIO22A_CB_ID1_R ;
assign  w_MCIO22C_CB_ID0_R = i_MCIO22C_CB_ID0_R ;
assign  w_MCIO22C_CB_ID1_R = i_MCIO22C_CB_ID1_R ;
assign  w_MCIO31A_CB_ID0_R = i_MCIO31A_CB_ID0_R ;
assign  w_MCIO31A_CB_ID1_R = i_MCIO31A_CB_ID1_R ;
assign  w_MCIO31C_CB_ID0_R = i_MCIO31C_CB_ID0_R ;
assign  w_MCIO31C_CB_ID1_R = i_MCIO31C_CB_ID1_R ;
assign  w_MCIO32A_CB_ID0_R = i_MCIO32A_CB_ID0_R ;
assign  w_MCIO32A_CB_ID1_R = i_MCIO32A_CB_ID1_R ;
assign  w_MCIO32C_CB_ID0_R = i_MCIO32C_CB_ID0_R ;
assign  w_MCIO32C_CB_ID1_R = i_MCIO32C_CB_ID1_R ;

assign  w_nvme1_cb_id0_r  = i_NVME1_CB_ID0_R ;
assign  w_nvme1_cb_id1_r  = i_NVME1_CB_ID1_R ;
assign  w_nvme2_cb_id0_r  = i_NVME2_CB_ID0_R ;
assign  w_nvme2_cb_id1_r  = i_NVME2_CB_ID1_R ;
assign  w_nvme3_cb_id0_r  = i_NVME3_CB_ID0_R ;
assign  w_nvme3_cb_id1_r  = i_NVME3_CB_ID1_R ;
assign  w_nvme4_cb_id0_r  = i_NVME4_CB_ID0_R ;
assign  w_nvme4_cb_id1_r  = i_NVME4_CB_ID1_R ;

assign  w_npu1a_cb_id1_r  = i_NPU1A_CB_ID1_R ;
assign  w_npu1c_cb_id1_r  = i_NPU1C_CB_ID1_R ;
assign  w_npu2a_cb_id1_r  = i_NPU2A_CB_ID1_R ;
assign  w_npu2c_cb_id1_r  = i_NPU2C_CB_ID1_R ;
assign  w_npu3a_cb_id1_r  = i_NPU3A_CB_ID1_R ;
assign  w_npu3c_cb_id1_r  = i_NPU3C_CB_ID1_R ;
assign  w_npu4a_cb_id1_r  = i_NPU4A_CB_ID1_R ;
assign  w_npu4c_cb_id1_r  = i_NPU4C_CB_ID1_R ;
assign  w_npu5a_cb_id1_r  = i_NPU5A_CB_ID1_R ;
assign  w_npu5c_cb_id1_r  = i_NPU5C_CB_ID1_R ;
assign  w_npu6a_cb_id1_r  = i_NPU6A_CB_ID1_R ;
assign  w_npu6c_cb_id1_r  = i_NPU6C_CB_ID1_R ;
assign  w_npu7a_cb_id1_r  = i_NPU7A_CB_ID1_R ;
assign  w_npu7c_cb_id1_r  = i_NPU7C_CB_ID1_R ;
assign  w_npu8a_cb_id1_r  = i_NPU8A_CB_ID1_R ;
assign  w_npu8c_cb_id1_r  = i_NPU8C_CB_ID1_R ;

assign  w_nic1a_cb_id0_r  = i_NIC1A_CB_ID0_R ;
assign  w_nic1a_cb_id1_r  = i_NIC1A_CB_ID1_R ;
assign  w_nic1c_cb_id0_r  = i_NIC1C_CB_ID0_R ;
assign  w_nic1c_cb_id1_r  = i_NIC1C_CB_ID1_R ;
assign  w_nic2a_cb_id0_r  = i_NIC2A_CB_ID0_R ;
assign  w_nic2a_cb_id1_r  = i_NIC2A_CB_ID1_R ;
assign  w_nic2c_cb_id0_r  = i_NIC2C_CB_ID0_R ;
assign  w_nic2c_cb_id1_r  = i_NIC2C_CB_ID1_R ;
assign  w_nic3a_cb_id0_r  = i_NIC3A_CB_ID0_R ;
assign  w_nic3a_cb_id1_r  = i_NIC3A_CB_ID1_R ;
assign  w_nic3c_cb_id0_r  = i_NIC3C_CB_ID0_R ;
assign  w_nic3c_cb_id1_r  = i_NIC3C_CB_ID1_R ;
assign  w_nic4a_cb_id0_r  = i_NIC4A_CB_ID0_R ;
assign  w_nic4a_cb_id1_r  = i_NIC4A_CB_ID1_R ;
assign  w_nic4c_cb_id0_r  = i_NIC4C_CB_ID0_R ;
assign  w_nic4c_cb_id1_r  = i_NIC4C_CB_ID1_R ;
assign  w_nic5a_cb_id0_r  = i_NIC5A_CB_ID0_R ;
assign  w_nic5a_cb_id1_r  = i_NIC5A_CB_ID1_R ;
assign  w_nic5c_cb_id0_r  = i_NIC5C_CB_ID0_R ;
assign  w_nic5c_cb_id1_r  = i_NIC5C_CB_ID1_R ;
assign  w_nic6a_cb_id0_r  = i_NIC6A_CB_ID0_R ;
assign  w_nic6a_cb_id1_r  = i_NIC6A_CB_ID1_R ;
assign  w_nic6c_cb_id0_r  = i_NIC6C_CB_ID0_R ;
assign  w_nic6c_cb_id1_r  = i_NIC6C_CB_ID1_R ;
assign  w_nic7a_cb_id0_r  = i_NIC7A_CB_ID0_R ;
assign  w_nic7a_cb_id1_r  = i_NIC7A_CB_ID1_R ;
assign  w_nic7c_cb_id0_r  = i_NIC7C_CB_ID0_R ;
assign  w_nic7c_cb_id1_r  = i_NIC7C_CB_ID1_R ;
assign  w_nic8a_cb_id0_r  = i_NIC8A_CB_ID0_R ;
assign  w_nic8a_cb_id1_r  = i_NIC8A_CB_ID1_R ;
assign  w_nic8c_cb_id0_r  = i_NIC8C_CB_ID0_R ;
assign  w_nic8c_cb_id1_r  = i_NIC8C_CB_ID1_R ;

//------------------------------------------------------------------------------
// Version ID
//------------------------------------------------------------------------------
wire w_board_id0;
wire w_board_id1;
wire w_board_id2;
wire w_board_id3;
wire w_board_id4;

wire w_pca_id0;
wire w_pca_id1;
wire w_pca_id2;

wire w_pcb_id0;
wire w_pcb_id1;
wire w_pcb_id2;

assign w_board_id0 = i_BOARD_ID0;
assign w_board_id1 = i_BOARD_ID1;
assign w_board_id2 = i_BOARD_ID2;
assign w_board_id3 = i_BOARD_ID3;
assign w_board_id4 = i_BOARD_ID4;

assign w_pca_id0   = i_PCA_ID0;
assign w_pca_id1   = i_PCA_ID1;
assign w_pca_id2   = i_PCA_ID2;

assign w_pcb_id0   = i_PCB_ID0;
assign w_pcb_id1   = i_PCB_ID1;
assign w_pcb_id2   = i_PCB_ID2;


// //------------------------------------------------------------------------------
// // Debounce / edge detect modules (instances as in BM_H13DSP_S_TOP.v style)
// //   - assume db_filter and edge_detect/edge_delay modules exist in project
// //------------------------------------------------------------------------------
// wire db_i_p12v_stby_pg;
// db_filter #(.DEB_CNT(12)) db_p12v_stby (
//     .clk(clk_50m),
//     .rst_n(pon_reset_n),
//     .i_sig(i_PAL_P12V_STBY_PG),
//     .o_sig(db_i_p12v_stby_pg)
// );

// wire db_i_p12v_pg;
// db_filter #(.DEB_CNT(12)) db_p12v_pg (
//     .clk(clk_50m),
//     .rst_n(pon_reset_n),
//     .i_sig(i_PAL_P12V_PG),
//     .o_sig(db_i_p12v_pg)
// );

// // UID button (if present on board, map to internal)
// wire uid_button_short_evt;
// wire uid_button_long_evt;
// db_filter #(.DEB_CNT(8)) db_uid (
//     .clk(clk_50m),
//     .rst_n(pon_reset_n),
//     .i_sig(i_P0V8_SW1_ALERT_N),    // example mapping; adapt if real pin exists
//     .o_sig(db_i_uid_sw_in_n)
// );
wire w_PWRGD_P12V;
wire w_pch_slp5_n;
wire w_mcio_pcie_wake_n_r;
//------------------------------------------------------------------------------
// SGPIO serial-parallel blocks (master<->slave exchange)
//------------------------------------------------------------------------------
// 60-bit vectors chosen to match typical mapping in BM files; adapt width as needed
wire [59:0] mcpld_to_scpld_s2p_data; // serial->parallel from master CPLD
wire [59:0] scpld_to_mcpld_p2s_data; // parallel->serial to master CPLD
reg [51:0] mcpld_to_scpld_data_filter;
reg mb_sgpio_fail;

wire [59:0] s2p_from_master; // serial->parallel from master CPLD
wire [59:0] p2s_to_master;   // parallel->serial to master CPLD

//scpld ---> mcpld
assign  scpld_to_mcpld_p2s_data[59]      = 1'b1                                ;
assign  scpld_to_mcpld_p2s_data[58]      = 1'b0                                ;
assign  scpld_to_mcpld_p2s_data[57]      = 1'b1                                ;
assign  scpld_to_mcpld_p2s_data[56]      = 1'b0                                ;
assign  scpld_to_mcpld_p2s_data[55:20]   = 'b0                                 ;
assign  scpld_to_mcpld_p2s_data[19]        = i_P0V8_SW1_ALERT_N        ;
assign  scpld_to_mcpld_p2s_data[18]        = i_P0V8_SW1_FAULT_N        ;
assign  scpld_to_mcpld_p2s_data[17]        = 1'b0        ;

assign  scpld_to_mcpld_p2s_data[16]        = 1'b0        ;
assign  scpld_to_mcpld_p2s_data[15]        = 1'b0        ;
assign  scpld_to_mcpld_p2s_data[14]        = 1'b0        ;
assign  scpld_to_mcpld_p2s_data[13]        = 1'b0        ;
assign  scpld_to_mcpld_p2s_data[12]        = 1'b0        ;
assign  scpld_to_mcpld_p2s_data[11]        = 1'b0        ;
assign  scpld_to_mcpld_p2s_data[10]        = 1'b0        ;
assign  scpld_to_mcpld_p2s_data[9]         = 1'b0        ;
assign  scpld_to_mcpld_p2s_data[8]         = 1'b0        ;
assign  scpld_to_mcpld_p2s_data[7]         = 1'b0        ;
assign  scpld_to_mcpld_p2s_data[6]         = 1'b0        ;
assign  scpld_to_mcpld_p2s_data[5]         = 1'b0        ;
assign  scpld_to_mcpld_p2s_data[4]         = 1'b0        ;


assign  scpld_to_mcpld_p2s_data[3]          = 1'b0                                ;
assign  scpld_to_mcpld_p2s_data[2]          = 1'b1                                ;
assign  scpld_to_mcpld_p2s_data[1]          = 1'b0                                ;
assign  scpld_to_mcpld_p2s_data[0]          = 1'b1                                ;



always@(posedge clk_50m or negedge pon_reset_n)
	begin
		if(~pon_reset_n)  // 复位状态（低电平有效）
			begin
				mcpld_to_scpld_data_filter <= {52{1'b0}};  // 初始化过滤后的数据为192位全0
				mb_sgpio_fail <= 1'b0;  // 初始化通信故障标志为0（无故障）
			end
		// 数据校验：检查帧头和帧尾是否匹配（自定义协议：帧头0101，帧尾1010）
		else if((mcpld_to_scpld_s2p_data[3:0] == 4'b0101) && (mcpld_to_scpld_s2p_data[59:56] == 4'b1010))
			begin
				// 校验通过：提取有效数据（去掉4位帧头和4位帧尾，保留中间位）
				mcpld_to_scpld_data_filter <= mcpld_to_scpld_s2p_data[55:4];
				mb_sgpio_fail <= 1'b0;  // 清除故障标志（通信正常）
			end
		else  // 校验失败（帧头/帧尾不匹配）
			begin
				mcpld_to_scpld_data_filter <= mcpld_to_scpld_data_filter;  // 保持上一次有效数据
				mb_sgpio_fail <= 1'b1;  // 置位故障标志（通信异常）
			end
end


// simple SGPIO converters (replace with actual s2p/p2s modules)
s2p_slave #(.NBIT(60)) s2p_inst (
    .clk(clk_50m),
    .rst(pon_reset_n),
    .si(i_SCPLD_SGPIO_DATA_IN),
    .sclk(i_SCPLD_SGPIO_CLK),
    .sld_n(i_SCPLD_SGPIO_LD),
    .po(mcpld_to_scpld_s2p_data)
);

p2s_slave #(.NBIT(60)) p2s_inst (
    .clk(clk_50m),
    .rst(pon_reset_n),
    .pi(scpld_to_mcpld_p2s_data),
    .so(o_SCPLD_SGPIO_DATA_OUT),
    .sclk(i_SCPLD_SGPIO_CLK),
    .sld_n(i_SCPLD_SGPIO_LD)
);
//-----------------------------------------------------------------------------------------------//
//M_CPLD <---> S_CPLD SGPIO END
//-----------------------------------------------------------------------------------------------//


//MCIO
wire [15:0] w_mb_to_bp_mcio01a_data;
wire [15:0] w_mb_to_bp_mcio01c_data;
wire [15:0] w_mb_to_bp_mcio02a_data;
wire [15:0] w_mb_to_bp_mcio02c_data;
wire [15:0] w_mb_to_bp_mcio11a_data;
wire [15:0] w_mb_to_bp_mcio11c_data;
wire [15:0] w_mb_to_bp_mcio12a_data;
wire [15:0] w_mb_to_bp_mcio12c_data;
wire [15:0] w_mb_to_bp_mcio21a_data;
wire [15:0] w_mb_to_bp_mcio21c_data;
wire [15:0] w_mb_to_bp_mcio22a_data;
wire [15:0] w_mb_to_bp_mcio22c_data;
wire [15:0] w_mb_to_bp_mcio31a_data;
wire [15:0] w_mb_to_bp_mcio31c_data;
wire [15:0] w_mb_to_bp_mcio32a_data;
wire [15:0] w_mb_to_bp_mcio32c_data;

wire [15:0]  w_bp_to_mb_mcio01a_data;
wire [15:0]  w_bp_to_mb_mcio01c_data;
wire [15:0]  w_bp_to_mb_mcio02a_data;
wire [15:0]  w_bp_to_mb_mcio02c_data;
wire [15:0]  w_bp_to_mb_mcio11a_data;
wire [15:0]  w_bp_to_mb_mcio11c_data;
wire [15:0]  w_bp_to_mb_mcio12a_data;
wire [15:0]  w_bp_to_mb_mcio12c_data;
wire [15:0]  w_bp_to_mb_mcio21a_data;
wire [15:0]  w_bp_to_mb_mcio21c_data;
wire [15:0]  w_bp_to_mb_mcio22a_data;
wire [15:0]  w_bp_to_mb_mcio22c_data;
wire [15:0]  w_bp_to_mb_mcio31a_data;
wire [15:0]  w_bp_to_mb_mcio31c_data;
wire [15:0]  w_bp_to_mb_mcio32a_data;
wire [15:0]  w_bp_to_mb_mcio32c_data;



wire w_mcio01a_pwr_en;
wire w_mcio01c_pwr_en;
wire w_mcio02a_pwr_en;
wire w_mcio02c_pwr_en;
wire w_mcio11a_pwr_en;
wire w_mcio11c_pwr_en;
wire w_mcio12a_pwr_en;
wire w_mcio12c_pwr_en;
wire w_mcio21a_pwr_en;
wire w_mcio21c_pwr_en;
wire w_mcio22a_pwr_en;
wire w_mcio22c_pwr_en;
wire w_mcio31a_pwr_en;
wire w_mcio31c_pwr_en;
wire w_mcio32a_pwr_en;
wire w_mcio32c_pwr_en;

// ------------------------------
// MCIO控制数据的固定字段定义（用于填充16位控制数据的高15位，最低位为电源使能信号）
// ------------------------------
wire    [5:0]   w_mcio_rsvd_bit15_10;       // 16位数据的[15:10]位：预留（固定为0）
wire    [1:0]   w_mcio_rsvd_bit9_8;         // 16位数据的[9:8]位：预留（固定为11）
wire    [2:0]   w_mcio_rsvd_bit7_5;         // 16位数据的[7:5]位：预留（固定为100）
wire    [3:0]   w_mcio_vpp_addr_bit4_1;     // 16位数据的[4:1]位：VPP地址（固定为0000，未启用）

assign  w_mcio_rsvd_bit15_10       =    6'b0;
assign  w_mcio_rsvd_bit9_8         =    2'b11;
assign  w_mcio_rsvd_bit7_5         =    3'b100;
assign  w_mcio_vpp_addr_bit4_1     =    4'b0000;


assign w_mb_to_bp_mcio01a_data = {w_mcio_rsvd_bit15_10, w_mcio_rsvd_bit9_8, w_mcio_rsvd_bit7_5, w_mcio_vpp_addr_bit4_1, w_mcio01a_pwr_en};
assign w_mb_to_bp_mcio01c_data = {w_mcio_rsvd_bit15_10, w_mcio_rsvd_bit9_8, w_mcio_rsvd_bit7_5, w_mcio_vpp_addr_bit4_1, w_mcio01c_pwr_en};
assign w_mb_to_bp_mcio02a_data = {w_mcio_rsvd_bit15_10, w_mcio_rsvd_bit9_8, w_mcio_rsvd_bit7_5, w_mcio_vpp_addr_bit4_1, w_mcio02a_pwr_en};
assign w_mb_to_bp_mcio02c_data = {w_mcio_rsvd_bit15_10, w_mcio_rsvd_bit9_8, w_mcio_rsvd_bit7_5, w_mcio_vpp_addr_bit4_1, w_mcio02c_pwr_en};
assign w_mb_to_bp_mcio11a_data = {w_mcio_rsvd_bit15_10, w_mcio_rsvd_bit9_8, w_mcio_rsvd_bit7_5, w_mcio_vpp_addr_bit4_1, w_mcio11a_pwr_en};
assign w_mb_to_bp_mcio11c_data = {w_mcio_rsvd_bit15_10, w_mcio_rsvd_bit9_8, w_mcio_rsvd_bit7_5, w_mcio_vpp_addr_bit4_1, w_mcio11c_pwr_en};
assign w_mb_to_bp_mcio12a_data = {w_mcio_rsvd_bit15_10, w_mcio_rsvd_bit9_8, w_mcio_rsvd_bit7_5, w_mcio_vpp_addr_bit4_1, w_mcio12a_pwr_en};
assign w_mb_to_bp_mcio12c_data = {w_mcio_rsvd_bit15_10, w_mcio_rsvd_bit9_8, w_mcio_rsvd_bit7_5, w_mcio_vpp_addr_bit4_1, w_mcio12c_pwr_en};
assign w_mb_to_bp_mcio21a_data = {w_mcio_rsvd_bit15_10, w_mcio_rsvd_bit9_8, w_mcio_rsvd_bit7_5, w_mcio_vpp_addr_bit4_1, w_mcio21a_pwr_en};
assign w_mb_to_bp_mcio21c_data = {w_mcio_rsvd_bit15_10, w_mcio_rsvd_bit9_8, w_mcio_rsvd_bit7_5, w_mcio_vpp_addr_bit4_1, w_mcio21c_pwr_en};
assign w_mb_to_bp_mcio22a_data = {w_mcio_rsvd_bit15_10, w_mcio_rsvd_bit9_8, w_mcio_rsvd_bit7_5, w_mcio_vpp_addr_bit4_1, w_mcio22a_pwr_en};
assign w_mb_to_bp_mcio22c_data = {w_mcio_rsvd_bit15_10, w_mcio_rsvd_bit9_8, w_mcio_rsvd_bit7_5, w_mcio_vpp_addr_bit4_1, w_mcio22c_pwr_en};
assign w_mb_to_bp_mcio31a_data = {w_mcio_rsvd_bit15_10, w_mcio_rsvd_bit9_8, w_mcio_rsvd_bit7_5, w_mcio_vpp_addr_bit4_1, w_mcio31a_pwr_en};
assign w_mb_to_bp_mcio31c_data = {w_mcio_rsvd_bit15_10, w_mcio_rsvd_bit9_8, w_mcio_rsvd_bit7_5, w_mcio_vpp_addr_bit4_1, w_mcio31c_pwr_en};
assign w_mb_to_bp_mcio32a_data = {w_mcio_rsvd_bit15_10, w_mcio_rsvd_bit9_8, w_mcio_rsvd_bit7_5, w_mcio_vpp_addr_bit4_1, w_mcio32a_pwr_en};
assign w_mb_to_bp_mcio32c_data = {w_mcio_rsvd_bit15_10, w_mcio_rsvd_bit9_8, w_mcio_rsvd_bit7_5, w_mcio_vpp_addr_bit4_1, w_mcio32c_pwr_en};

assign w_mcio01a_pwr_en = (w_PWRGD_P12V && w_pch_slp5_n) ? 1'b1 : 1'b0  ; 
assign w_mcio01c_pwr_en = (w_PWRGD_P12V && w_pch_slp5_n) ? 1'b1 : 1'b0  ;
assign w_mcio02a_pwr_en = (w_PWRGD_P12V && w_pch_slp5_n) ? 1'b1 : 1'b0  ;
assign w_mcio02c_pwr_en = (w_PWRGD_P12V && w_pch_slp5_n) ? 1'b1 : 1'b0  ;
assign w_mcio11a_pwr_en = (w_PWRGD_P12V && w_pch_slp5_n) ? 1'b1 : 1'b0  ;
assign w_mcio11c_pwr_en = (w_PWRGD_P12V && w_pch_slp5_n) ? 1'b1 : 1'b0  ;
assign w_mcio12a_pwr_en = (w_PWRGD_P12V && w_pch_slp5_n) ? 1'b1 : 1'b0  ;
assign w_mcio12c_pwr_en = (w_PWRGD_P12V && w_pch_slp5_n) ? 1'b1 : 1'b0  ;
assign w_mcio21a_pwr_en = (w_PWRGD_P12V && w_pch_slp5_n) ? 1'b1 : 1'b0  ;
assign w_mcio21c_pwr_en = (w_PWRGD_P12V && w_pch_slp5_n) ? 1'b1 : 1'b0  ;
assign w_mcio22a_pwr_en = (w_PWRGD_P12V && w_pch_slp5_n) ? 1'b1 : 1'b0  ;
assign w_mcio22c_pwr_en = (w_PWRGD_P12V && w_pch_slp5_n) ? 1'b1 : 1'b0  ;
assign w_mcio31a_pwr_en = (w_PWRGD_P12V && w_pch_slp5_n) ? 1'b1 : 1'b0  ;
assign w_mcio31c_pwr_en = (w_PWRGD_P12V && w_pch_slp5_n) ? 1'b1 : 1'b0  ;
assign w_mcio32a_pwr_en = (w_PWRGD_P12V && w_pch_slp5_n) ? 1'b1 : 1'b0  ;
assign w_mcio32c_pwr_en = (w_PWRGD_P12V && w_pch_slp5_n) ? 1'b1 : 1'b0  ;


//--------------------------------------------------------------------------------------------------------------------------------------------------
//  --> J46    MCIO01A
// -------------------------------------------------------------------------------------------------------------------------------------------------
UART_MASTER #(.NBIT_IN(16), .NBIT_OUT(16), .BPS_COUNT_NUM(48), .START_COUNT_NUM(24)) uart_master_u0 (
	.clk                        (clk_50m            )  ,             //input
	.rst                        (~pon_reset_n  )  ,             //input
	.tick                      (t16us_tick      )  ,             //input
	.send_enable        (1'b1                  )  ,             //input
         .t128ms_tick       (t128ms_tick    )  ,             //input
	.par_data_in        (w_mb_to_bp_mcio01a_data)  , //input 
	.par_data_out       (w_bp_to_mb_mcio01a_data)  , //output
	.ser_data              (io_MCIO01A_PWR_EN_R      )  , //inout
         .riser_en_out     (w_mcio01a_pwr_en    )  , //output
	.mcio_cable_id0  (w_MCIO01A_CB_ID0_R        )  , //input
	.mcio_cable_id1  (w_MCIO01A_CB_ID1_R        )  , //input

	.error_flag          (  )                          //output
);
//--------------------------------------------------------------------------------------------------------------------------------------------------
// --> J53    MCIO01C
// -------------------------------------------------------------------------------------------------------------------------------------------------
UART_MASTER #(.NBIT_IN(16), .NBIT_OUT(16), .BPS_COUNT_NUM(48), .START_COUNT_NUM(24)) uart_master_u1 (
	.clk                        (clk_50m            )  ,             //input
	.rst                        (~pon_reset_n  )  ,             //input
	.tick                      (t16us_tick      )  ,             //input
	.send_enable        (1'b1                  )  ,             //input
         .t128ms_tick       (t128ms_tick    )  ,             //input
	.par_data_in        (w_mb_to_bp_mcio01c_data)  , //input 
	.par_data_out       (w_bp_to_mb_mcio01c_data)  , //output
	.ser_data              (io_MCIO01C_PWR_EN_R      )  , //inout
         .riser_en_out     (w_mcio01c_pwr_en    )  , //output
	.mcio_cable_id0  (w_MCIO01C_CB_ID0_R        )  , //input
	.mcio_cable_id1  (w_MCIO01C_CB_ID1_R        )  , //input

	.error_flag          (  )                          //output
);
//--------------------------------------------------------------------------------------------------------------------------------------------------
//   --> J38    MCIO02A
// -------------------------------------------------------------------------------------------------------------------------------------------------
UART_MASTER #(.NBIT_IN(16), .NBIT_OUT(16), .BPS_COUNT_NUM(48), .START_COUNT_NUM(24)) uart_master_u2 (
	.clk                        (clk_50m            )  ,             //input
	.rst                        (~pon_reset_n  )  ,             //input
	.tick                      (t16us_tick      )  ,             //input
	.send_enable        (1'b1                  )  ,             //input
         .t128ms_tick       (t128ms_tick    )  ,             //input
	.par_data_in        (w_mb_to_bp_mcio02a_data)  , //input 
	.par_data_out       (w_bp_to_mb_mcio02a_data)  , //output
	.ser_data              (io_MCIO02A_PWR_EN_R      )  , //inout
         .riser_en_out     (w_mcio02a_pwr_en    )  , //output
	.mcio_cable_id0  (w_MCIO02A_CB_ID0_R        )  , //input
	.mcio_cable_id1  (w_MCIO02A_CB_ID1_R        )  , //input

	.error_flag          (  )                          //output
);
//--------------------------------------------------------------------------------------------------------------------------------------------------
//   --> J39    MCIO02C
// -------------------------------------------------------------------------------------------------------------------------------------------------
UART_MASTER #(.NBIT_IN(16), .NBIT_OUT(16), .BPS_COUNT_NUM(48), .START_COUNT_NUM(24)) uart_master_u3 (
	.clk                        (clk_50m            )  ,             //input
	.rst                        (~pon_reset_n  )  ,             //input
	.tick                      (t16us_tick      )  ,             //input
	.send_enable        (1'b1                  )  ,             //input
         .t128ms_tick       (t128ms_tick    )  ,             //input
	.par_data_in        (w_mb_to_bp_mcio02c_data)  , //input 
	.par_data_out       (w_bp_to_mb_mcio02c_data)  , //output
	.ser_data              (io_MCIO02C_PWR_EN_R      )  , //inout
         .riser_en_out     (w_mcio02c_pwr_en    )  , //output
	.mcio_cable_id0  (w_MCIO02C_CB_ID0_R        )  , //input
	.mcio_cable_id1  (w_MCIO02C_CB_ID1_R        )  , //input

	.error_flag          (  )                          //output
);
//--------------------------------------------------------------------------------------------------------------------------------------------------
//   --> J44    MCIO11A
// -------------------------------------------------------------------------------------------------------------------------------------------------
UART_MASTER #(.NBIT_IN(16), .NBIT_OUT(16), .BPS_COUNT_NUM(48), .START_COUNT_NUM(24)) uart_master_u4 (
	.clk                        (clk_50m            )  ,             //input
	.rst                        (~pon_reset_n  )  ,             //input
	.tick                      (t16us_tick      )  ,             //input
	.send_enable        (1'b1                  )  ,             //input
         .t128ms_tick       (t128ms_tick    )  ,             //input
	.par_data_in        (w_mb_to_bp_mcio11a_data)  , //input 
	.par_data_out       (w_bp_to_mb_mcio11a_data)  , //output
	.ser_data              (io_MCIO11A_PWR_EN_R      )  , //inout
         .riser_en_out     (w_mcio11a_pwr_en    )  , //output
	.mcio_cable_id0  (w_MCIO11A_CB_ID0_R        )  , //input
	.mcio_cable_id1  (w_MCIO11A_CB_ID1_R        )  , //input

	.error_flag          (  )                          //output
);
//--------------------------------------------------------------------------------------------------------------------------------------------------
//   --> J45    MCIO11C
// -------------------------------------------------------------------------------------------------------------------------------------------------
UART_MASTER #(.NBIT_IN(16), .NBIT_OUT(16), .BPS_COUNT_NUM(48), .START_COUNT_NUM(24)) uart_master_u5 (
	.clk                        (clk_50m            )  ,             //input
	.rst                        (~pon_reset_n  )  ,             //input
	.tick                      (t16us_tick      )  ,             //input
	.send_enable        (1'b1                  )  ,             //input
         .t128ms_tick       (t128ms_tick    )  ,             //input
	.par_data_in        (w_mb_to_bp_mcio11c_data)  , //input 
	.par_data_out       (w_bp_to_mb_mcio11c_data)  , //output
	.ser_data              (io_MCIO11C_PWR_EN_R      )  , //inout
         .riser_en_out     (w_mcio11c_pwr_en    )  , //output
	.mcio_cable_id0  (w_MCIO11C_CB_ID0_R        )  , //input
	.mcio_cable_id1  (w_MCIO11C_CB_ID1_R        )  , //input

	.error_flag          (  )                          //output
);

//--------------------------------------------------------------------------------------------------------------------------------------------------
//   --> J47    MCIO12A
// -------------------------------------------------------------------------------------------------------------------------------------------------
UART_MASTER #(.NBIT_IN(16), .NBIT_OUT(16), .BPS_COUNT_NUM(48), .START_COUNT_NUM(24)) uart_master_u6 (
	.clk                        (clk_50m            )  ,             //input
	.rst                        (~pon_reset_n  )  ,             //input
	.tick                      (t16us_tick      )  ,             //input
	.send_enable        (1'b1                  )  ,             //input
         .t128ms_tick       (t128ms_tick    )  ,             //input
	.par_data_in        (w_mb_to_bp_mcio12a_data)  , //input 
	.par_data_out       (w_bp_to_mb_mcio12a_data)  , //output
	.ser_data              (io_MCIO12A_PWR_EN_R      )  , //inout
         .riser_en_out     (w_mcio12a_pwr_en    )  , //output
	.mcio_cable_id0  (w_MCIO12A_CB_ID0_R        )  , //input
	.mcio_cable_id1  (w_MCIO12A_CB_ID1_R        )  , //input

	.error_flag          (  )                          //output
);
//--------------------------------------------------------------------------------------------------------------------------------------------------
//   --> J48    MCIO12C
// -------------------------------------------------------------------------------------------------------------------------------------------------
UART_MASTER #(.NBIT_IN(16), .NBIT_OUT(16), .BPS_COUNT_NUM(48), .START_COUNT_NUM(24)) uart_master_u7 (
	.clk                        (clk_50m            )  ,             //input
	.rst                        (~pon_reset_n  )  ,             //input
	.tick                      (t16us_tick      )  ,             //input
	.send_enable        (1'b1                  )  ,             //input
         .t128ms_tick       (t128ms_tick    )  ,             //input
	.par_data_in        (w_mb_to_bp_mcio12c_data)  , //input 
	.par_data_out       (w_bp_to_mb_mcio12c_data)  , //output
	.ser_data              (io_MCIO12C_PWR_EN_R      )  , //inout
         .riser_en_out     (w_mcio12c_pwr_en    )  , //output
	.mcio_cable_id0  (w_MCIO12C_CB_ID0_R        )  , //input
	.mcio_cable_id1  (w_MCIO12C_CB_ID1_R        )  , //input

	.error_flag          (  )                          //output
);
//--------------------------------------------------------------------------------------------------------------------------------------------------
//   --> J40    MCIO21A
// -------------------------------------------------------------------------------------------------------------------------------------------------
UART_MASTER #(.NBIT_IN(16), .NBIT_OUT(16), .BPS_COUNT_NUM(48), .START_COUNT_NUM(24)) uart_master_u8 (
	.clk                        (clk_50m            )  ,             //input
	.rst                        (~pon_reset_n  )  ,             //input
	.tick                      (t16us_tick      )  ,             //input
	.send_enable        (1'b1                  )  ,             //input
         .t128ms_tick       (t128ms_tick    )  ,             //input
	.par_data_in        (w_mb_to_bp_mcio21a_data)  , //input 
	.par_data_out       (w_bp_to_mb_mcio21a_data)  , //output
	.ser_data              (io_MCIO21A_PWR_EN_R      )  , //inout
         .riser_en_out     (w_mcio21a_pwr_en    )  , //output
	.mcio_cable_id0  (w_MCIO21A_CB_ID0_R        )  , //input
	.mcio_cable_id1  (w_MCIO21A_CB_ID1_R        )  , //input

	.error_flag          (  )                          //output
);
//--------------------------------------------------------------------------------------------------------------------------------------------------
//   --> J41    MCIO21C
// -------------------------------------------------------------------------------------------------------------------------------------------------
UART_MASTER #(.NBIT_IN(16), .NBIT_OUT(16), .BPS_COUNT_NUM(48), .START_COUNT_NUM(24)) uart_master_u9 (
	.clk                        (clk_50m            )  ,             //input
	.rst                        (~pon_reset_n  )  ,             //input
	.tick                      (t16us_tick      )  ,             //input
	.send_enable        (1'b1                  )  ,             //input
         .t128ms_tick       (t128ms_tick    )  ,             //input
	.par_data_in        (w_mb_to_bp_mcio21c_data)  , //input 
	.par_data_out       (w_bp_to_mb_mcio21c_data)  , //output
	.ser_data              (io_MCIO21C_PWR_EN_R      )  , //inout
         .riser_en_out     (w_mcio21c_pwr_en    )  , //output
	.mcio_cable_id0  (w_MCIO21C_CB_ID0_R        )  , //input
	.mcio_cable_id1  (w_MCIO21C_CB_ID1_R        )  , //input

	.error_flag          (  )                          //output
);

//--------------------------------------------------------------------------------------------------------------------------------------------------
//   --> J42    MCIO22A
// -------------------------------------------------------------------------------------------------------------------------------------------------
UART_MASTER #(.NBIT_IN(16), .NBIT_OUT(16), .BPS_COUNT_NUM(48), .START_COUNT_NUM(24)) uart_master_u10 (
	.clk                        (clk_50m            )  ,             //input
	.rst                        (~pon_reset_n  )  ,             //input
	.tick                      (t16us_tick      )  ,             //input
	.send_enable        (1'b1                  )  ,             //input
         .t128ms_tick       (t128ms_tick    )  ,             //input
	.par_data_in        (w_mb_to_bp_mcio22a_data)  , //input 
	.par_data_out       (w_bp_to_mb_mcio22a_data)  , //output
	.ser_data              (io_MCIO22A_PWR_EN_R      )  , //inout
         .riser_en_out     (w_mcio22a_pwr_en    )  , //output
	.mcio_cable_id0  (w_MCIO22A_CB_ID0_R        )  , //input
	.mcio_cable_id1  (w_MCIO22A_CB_ID1_R        )  , //input

	.error_flag          (  )                          //output
);
//--------------------------------------------------------------------------------------------------------------------------------------------------
//   --> J43    MCIO22C
// -------------------------------------------------------------------------------------------------------------------------------------------------
UART_MASTER #(.NBIT_IN(16), .NBIT_OUT(16), .BPS_COUNT_NUM(48), .START_COUNT_NUM(24)) uart_master_u11 (
	.clk                        (clk_50m            )  ,             //input
	.rst                        (~pon_reset_n  )  ,             //input
	.tick                      (t16us_tick      )  ,             //input
	.send_enable        (1'b1                  )  ,             //input
         .t128ms_tick       (t128ms_tick    )  ,             //input
	.par_data_in        (w_mb_to_bp_mcio22c_data)  , //input 
	.par_data_out       (w_bp_to_mb_mcio22c_data)  , //output
	.ser_data              (io_MCIO22C_PWR_EN_R      )  , //inout
         .riser_en_out     (w_mcio22c_pwr_en    )  , //output
	.mcio_cable_id0  (w_MCIO22C_CB_ID0_R        )  , //input
	.mcio_cable_id1  (w_MCIO22C_CB_ID1_R        )  , //input

	.error_flag          (  )                          //output
);
//--------------------------------------------------------------------------------------------------------------------------------------------------
//   --> J49    MCIO31A
// -------------------------------------------------------------------------------------------------------------------------------------------------
UART_MASTER #(.NBIT_IN(16), .NBIT_OUT(16), .BPS_COUNT_NUM(48), .START_COUNT_NUM(24)) uart_master_u12 (
	.clk                        (clk_50m            )  ,             //input
	.rst                        (~pon_reset_n  )  ,             //input
	.tick                      (t16us_tick      )  ,             //input
	.send_enable        (1'b1                  )  ,             //input
         .t128ms_tick       (t128ms_tick    )  ,             //input
	.par_data_in        (w_mb_to_bp_mcio31a_data)  , //input 
	.par_data_out       (w_bp_to_mb_mcio31a_data)  , //output
	.ser_data              (io_MCIO31A_PWR_EN_R      )  , //inout
         .riser_en_out     (w_mcio31a_pwr_en    )  , //output
	.mcio_cable_id0  (w_MCIO31A_CB_ID0_R        )  , //input
	.mcio_cable_id1  (w_MCIO31A_CB_ID1_R        )  , //input

	.error_flag          (  )                          //output
);
//--------------------------------------------------------------------------------------------------------------------------------------------------
//  --> J50    MCIO31C
// -------------------------------------------------------------------------------------------------------------------------------------------------
UART_MASTER #(.NBIT_IN(16), .NBIT_OUT(16), .BPS_COUNT_NUM(48), .START_COUNT_NUM(24)) uart_master_u13 (
	.clk                        (clk_50m            )  ,             //input
	.rst                        (~pon_reset_n  )  ,             //input
	.tick                      (t16us_tick      )  ,             //input
	.send_enable        (1'b1                  )  ,             //input
         .t128ms_tick       (t128ms_tick    )  ,             //input
	.par_data_in        (w_mb_to_bp_mcio31c_data)  , //input 
	.par_data_out       (w_bp_to_mb_mcio31c_data)  , //output
	.ser_data              (io_MCIO31C_PWR_EN_R      )  , //inout
         .riser_en_out     (w_mcio31c_pwr_en    )  , //output
	.mcio_cable_id0  (w_MCIO31C_CB_ID0_R        )  , //input
	.mcio_cable_id1  (w_MCIO31C_CB_ID1_R        )  , //input

	.error_flag          (  )                          //output
);

//--------------------------------------------------------------------------------------------------------------------------------------------------
//  --> J51    MCIO32A
// -------------------------------------------------------------------------------------------------------------------------------------------------
UART_MASTER #(.NBIT_IN(16), .NBIT_OUT(16), .BPS_COUNT_NUM(48), .START_COUNT_NUM(24)) uart_master_u14 (
	.clk                        (clk_50m            )  ,             //input
	.rst                        (~pon_reset_n  )  ,             //input
	.tick                      (t16us_tick      )  ,             //input
	.send_enable        (1'b1                  )  ,             //input
         .t128ms_tick       (t128ms_tick    )  ,             //input
	.par_data_in        (w_mb_to_bp_mcio32a_data)  , //input 
	.par_data_out       (w_bp_to_mb_mcio32a_data)  , //output
	.ser_data              (io_MCIO32A_PWR_EN_R      )  , //inout
         .riser_en_out     (w_mcio32a_pwr_en    )  , //output
	.mcio_cable_id0  (w_MCIO32A_CB_ID0_R        )  , //input
	.mcio_cable_id1  (w_MCIO32A_CB_ID1_R        )  , //input

	.error_flag          (  )                          //output
);
//--------------------------------------------------------------------------------------------------------------------------------------------------
//   --> J52    MCIO32C
// -------------------------------------------------------------------------------------------------------------------------------------------------
UART_MASTER #(.NBIT_IN(16), .NBIT_OUT(16), .BPS_COUNT_NUM(48), .START_COUNT_NUM(24)) uart_master_u15 (
	.clk                        (clk_50m            )  ,             //input
	.rst                        (~pon_reset_n  )  ,             //input
	.tick                      (t16us_tick      )  ,             //input
	.send_enable        (1'b1                  )  ,             //input
         .t128ms_tick       (t128ms_tick    )  ,             //input
	.par_data_in        (w_mb_to_bp_mcio32c_data)  , //input 
	.par_data_out       (w_bp_to_mb_mcio32c_data)  , //output
	.ser_data              (io_MCIO32C_PWR_EN_R      )  , //inout
         .riser_en_out     (w_mcio32c_pwr_en    )  , //output
	.mcio_cable_id0  (w_MCIO32C_CB_ID0_R        )  , //input
	.mcio_cable_id1  (w_MCIO32C_CB_ID1_R        )  , //input

	.error_flag          (  )                          //output
);


//---------------------------------------------------------------------------------------------
assign w_mcio_pcie_wake_n_r = i_MCIO01A_PE_WAKE_R_N & i_MCIO01C_PE_WAKE_R_N &
                              i_MCIO02A_PE_WAKE_R_N & i_MCIO02C_PE_WAKE_R_N &
                              i_MCIO11A_PE_WAKE_R_N & i_MCIO11C_PE_WAKE_R_N &
                              i_MCIO12A_PE_WAKE_R_N & i_MCIO12C_PE_WAKE_R_N &
                              i_MCIO21A_PE_WAKE_R_N & i_MCIO21C_PE_WAKE_R_N &
                              i_MCIO22A_PE_WAKE_R_N & i_MCIO22C_PE_WAKE_R_N &
                              i_MCIO31A_PE_WAKE_R_N & i_MCIO31C_PE_WAKE_R_N &
                              i_MCIO32A_PE_WAKE_R_N & i_MCIO32C_PE_WAKE_R_N ;




//-------------------------------------------------------------------------------------------------
// NC_PIN
//-------------------------------------------------------------------------------------------------
wire w_nc_pin;
assign w_nc_pin =         i_CPLD2_HDR_R &
                          i_CPLD2_JTAGEN_N &
                          i_CPLD2_INIT_N &
                          i_CPLD2_DONE  &
                          i_CPLD2_PULLUP_SN
                          ;



//-------------------------------------------------------------------------------------------------
// Output SIGNAL
//-------------------------------------------------------------------------------------------------
assign  o_CPLD2_LED2_N	= 1'bz;            
assign  o_CPLD2_LED3_N  = 1'bz;            

assign  o_CPLD_RSV1_R   = 1'bz;           
assign  o_CPLD_RSV2_R   = 1'bz;           
assign  o_CPLD_RSV3_R   = 1'bz;           
assign  o_CPLD_RSV4_R   = 1'bz;           
assign  o_CPLD_RSV5_R   = 1'bz;           
assign  o_CPLD_RSV6_R   = 1'bz;       


assign  o_MCIO01_11_GPU_THROTTLE_R_N = w_mcio01_11_gpu_throttle_r_n;
assign  o_MCIO02_12_GPU_THROTTLE_R_N = w_mcio02_12_gpu_throttle_r_n;
assign  o_MCIO21_31_GPU_THROTTLE_R_N = w_mcio21_31_gpu_throttle_r_n;
assign  o_MCIO22_32_GPU_THROTTLE_R_N = w_mcio22_32_gpu_throttle_r_n;
assign  o_NPU1_4_GPU_THROTTLE_R_N   = w_npu1_4_gpu_throttle_r_n;
assign  o_NPU5_8_GPU_THROTTLE_R_N   = w_npu5_8_gpu_throttle_r_n;
assign  o_NIC1_4_GPU_THROTTLE_R_N   = w_nic1_4_gpu_throttle_r_n;
assign  o_NIC5_8_GPU_THROTTLE_R_N   = w_nic5_8_gpu_throttle_r_n;
//------------------------------------------------------------------------------
// I2C RAM  Start
//------------------------------------------------------------------------------

bmc_cpld_i2c_ram #(
    .DLY_LEN (16)
) bmc_cpld_i2c_ram_u0 (
    .i_rst_n                (pon_reset_n),
    .i_clk                  (clk_25m),            // use 25MHz derived clock if available
    .i_1ms_clk              (t1ms_tick),
    .i_rst_i2c_n            (1'b1),
    .i_scl                  (i_I2C1_CPLD2_REG_SCL),
    .io_sda                 (io_I2C1_CPLD2_REG_SDA),

    // identification
    .i_product_id           (`PRODUCT_ID),        // addr 0x0000
    .i_vender_id            (`VENDER_ID),         // addr 0x0001
    .i_board_id             ({3'b0, w_board_id4, w_board_id3, w_board_id2, w_board_id1, w_board_id0}), // addr 0x0002 pack to 8b
    .i_pcb_version          ({5'b0, w_pcb_id2, w_pcb_id1, w_pcb_id0}), // addr 0x0003
    .i_bom_id               ({5'b0, w_pca_id2, w_pca_id1, w_pca_id0}), // addr 0x0004
    .i_cpld_version         (`CPLD_VERSION),      // addr 0x0005
    .o_test_reg             (),                   // addr 0x0006
    .i_year                 (`Year),              // addr 0x0007
    .i_month                (`Month),             // addr 0x0008
    .i_day                  (`Day),               // addr 0x0009
    .i_nc_pin               ({7'b0, w_nc_pin}),   // addr 0x000a
    .i_cpld_compa_version   (8'h00),              // addr 0x000b
    .i_cpld_debug_version   (`DEBUG_VERSION),     // addr 0x000c

    .i_nic_board_id		       (8'b0)      , //addr 0x0010
    .i_nic_pcb_version	     (8'b0)      , //addr 0x0011

    //sw
    .i_P0V8_SW1_ALERT_N          (i_P0V8_SW1_ALERT_N),   // addr 0x0012 bit7
    .i_P0V8_SW1_FAULT_N          (i_P0V8_SW1_FAULT_N),   // addr 0x0012 bit3
   
    .o_uid_led_ctl          (w_uid_led_ctl),          // addr 0x0013

    // NVMe PRSNT signals  --0x14
    .i_MCIO01A_NVME0_PRSNT_R_N       (i_MCIO01A_NVME0_PRSNT_R_N),//addr 0x0014 bit7
    .i_MCIO01C_NVME0_PRSNT_R_N       (i_MCIO01C_NVME0_PRSNT_R_N),//addr 0x0014 bit6
    .i_MCIO02A_NVME0_PRSNT_R_N       (i_MCIO02A_NVME0_PRSNT_R_N),//addr 0x0014 bit5
    .i_MCIO02C_NVME0_PRSNT_R_N       (i_MCIO02C_NVME0_PRSNT_R_N),//addr 0x0014 bit4
    .i_MCIO11A_NVME0_PRSNT_R_N       (i_MCIO11A_NVME0_PRSNT_R_N),//addr 0x0014 bit3
    .i_MCIO11C_NVME0_PRSNT_R_N       (i_MCIO11C_NVME0_PRSNT_R_N),//addr 0x0014 bit2
    .i_MCIO12A_NVME0_PRSNT_R_N       (i_MCIO12A_NVME0_PRSNT_R_N),//addr 0x0014 bit1
    .i_MCIO12C_NVME0_PRSNT_R_N       (i_MCIO12C_NVME0_PRSNT_R_N),//addr 0x0014 bit0
    //--0x0015
    .i_MCIO21A_NVME0_PRSNT_R_N       (i_MCIO21A_NVME0_PRSNT_R_N),//addr 0x0015 bit7
    .i_MCIO21C_NVME0_PRSNT_R_N       (i_MCIO21C_NVME0_PRSNT_R_N),//addr 0x0015 bit6
    .i_MCIO22A_NVME0_PRSNT_R_N       (i_MCIO22A_NVME0_PRSNT_R_N),//addr 0x0015 bit5
    .i_MCIO22C_NVME0_PRSNT_R_N       (i_MCIO22C_NVME0_PRSNT_R_N),//addr 0x0015 bit4
    .i_MCIO31A_NVME0_PRSNT_R_N       (i_MCIO31A_NVME0_PRSNT_R_N),//addr 0x0015 bit3
    .i_MCIO31C_NVME0_PRSNT_R_N       (i_MCIO31C_NVME0_PRSNT_R_N),//addr 0x0015 bit2
    .i_MCIO32A_NVME0_PRSNT_R_N       (i_MCIO32A_NVME0_PRSNT_R_N),//addr 0x0015 bit1
    .i_MCIO32C_NVME0_PRSNT_R_N       (i_MCIO32C_NVME0_PRSNT_R_N),//addr 0x0015 bit0
    //--0x0016
    .i_MCIO01A_NVME1_PRSNT_R_N       (i_MCIO01A_NVME1_PRSNT_R_N),//addr 0x0016 bit7
    .i_MCIO01C_NVME1_PRSNT_R_N       (i_MCIO01C_NVME1_PRSNT_R_N),//addr 0x0016 bit6
    .i_MCIO02A_NVME1_PRSNT_R_N       (i_MCIO02A_NVME1_PRSNT_R_N),//addr 0x0016 bit5
    .i_MCIO02C_NVME1_PRSNT_R_N       (i_MCIO02C_NVME1_PRSNT_R_N),//addr 0x0016 bit4
    .i_MCIO11A_NVME1_PRSNT_R_N       (i_MCIO11A_NVME1_PRSNT_R_N),//addr 0x0016 bit3
    .i_MCIO11C_NVME1_PRSNT_R_N       (i_MCIO11C_NVME1_PRSNT_R_N),//addr 0x0016 bit2
    .i_MCIO12A_NVME1_PRSNT_R_N       (i_MCIO12A_NVME1_PRSNT_R_N),//addr 0x0016 bit1
    .i_MCIO12C_NVME1_PRSNT_R_N       (i_MCIO12C_NVME1_PRSNT_R_N),//addr 0x0016 bit0
    //--0x0017
    .i_MCIO21A_NVME1_PRSNT_R_N       (i_MCIO21A_NVME1_PRSNT_R_N),//addr 0x0017 bit7
    .i_MCIO21C_NVME1_PRSNT_R_N       (i_MCIO21C_NVME1_PRSNT_R_N),//addr 0x0017 bit6
    .i_MCIO22A_NVME1_PRSNT_R_N       (i_MCIO22A_NVME1_PRSNT_R_N),//addr 0x0017 bit5
    .i_MCIO22C_NVME1_PRSNT_R_N       (i_MCIO22C_NVME1_PRSNT_R_N),//addr 0x0017 bit4
    .i_MCIO31A_NVME1_PRSNT_R_N       (i_MCIO31A_NVME1_PRSNT_R_N),//addr 0x0017 bit3
    .i_MCIO31C_NVME1_PRSNT_R_N       (i_MCIO31C_NVME1_PRSNT_R_N),//addr 0x0017 bit2
    .i_MCIO32A_NVME1_PRSNT_R_N       (i_MCIO32A_NVME1_PRSNT_R_N),//addr 0x0017 bit1
    .i_MCIO32C_NVME1_PRSNT_R_N       (i_MCIO32C_NVME1_PRSNT_R_N),//addr 0x0017 bit0

    //--0x0018
    .i_NVME3_PRSNT0_R_N               (i_NVME3_PRSNT0_R_N),//addr 0x0018 bit7
    .i_NVME3_PRSNT1_R_N               (i_NVME3_PRSNT1_R_N),//addr 0x0018 bit6
    .i_NVME4_PRSNT0_R_N               (i_NVME4_PRSNT0_R_N),//addr 0x0018 bit5
    .i_NVME4_PRSNT1_R_N               (i_NVME4_PRSNT1_R_N),//addr 0x0018 bit4

    //gpu_throttle -- 0x0019
    .o_mcio01_11_gpu_throttle_r_n       (w_mcio01_11_gpu_throttle_r_n),    //addr 0x0019   bit7   default 1
    .o_mcio02_12_gpu_throttle_r_n       (w_mcio02_12_gpu_throttle_r_n),    //addr 0x0019   bit6   default 1
    .o_mcio21_31_gpu_throttle_r_n       (w_mcio21_31_gpu_throttle_r_n),    //addr 0x0019   bit5   default 1
    .o_mcio22_32_gpu_throttle_r_n       (w_mcio22_32_gpu_throttle_r_n),    //addr 0x0019   bit4   default 1
    //--0x001a
    .o_npu1_4_gpu_throttle_r_n           (w_npu1_4_gpu_throttle_r_n),       //addr 0x001a   bit7   default 1
    .o_npu5_8_gpu_throttle_r_n           (w_npu5_8_gpu_throttle_r_n),       //addr 0x001a   bit6   default 1
    //--0x001b
    .o_nic1_4_gpu_throttle_r_n          (w_nic1_4_gpu_throttle_r_n),     //addr 0x001b   bit7   default 1
    .o_nic5_8_gpu_throttle_r_n          (w_nic5_8_gpu_throttle_r_n),     //addr 0x001b   bit6   default 1

    //MCIO pcie wake--0x0020
    .i_MCIO01A_PE_WAKE_R_N              (i_MCIO01A_PE_WAKE_R_N), //addr 0x0020 bit7
    .i_MCIO01C_PE_WAKE_R_N              (i_MCIO01C_PE_WAKE_R_N), //addr 0x0020 bit6
    .i_MCIO02A_PE_WAKE_R_N              (i_MCIO02A_PE_WAKE_R_N), //addr 0x0020 bit5
    .i_MCIO02C_PE_WAKE_R_N              (i_MCIO02C_PE_WAKE_R_N), //addr 0x0020 bit4
    .i_MCIO11A_PE_WAKE_R_N              (i_MCIO11A_PE_WAKE_R_N), //addr 0x0020 bit3
    .i_MCIO11C_PE_WAKE_R_N              (i_MCIO11C_PE_WAKE_R_N), //addr 0x0020 bit2
    .i_MCIO12A_PE_WAKE_R_N              (i_MCIO12A_PE_WAKE_R_N), //addr 0x0020 bit1
    .i_MCIO12C_PE_WAKE_R_N              (i_MCIO12C_PE_WAKE_R_N), //addr 0x0020 bit0
    //--0x0021
    .i_MCIO21A_PE_WAKE_R_N              (i_MCIO21A_PE_WAKE_R_N), //addr 0x0021 bit7
    .i_MCIO21C_PE_WAKE_R_N              (i_MCIO21C_PE_WAKE_R_N), //addr 0x0021 bit6
    .i_MCIO22A_PE_WAKE_R_N              (i_MCIO22A_PE_WAKE_R_N), //addr 0x0021 bit5
    .i_MCIO22C_PE_WAKE_R_N              (i_MCIO22C_PE_WAKE_R_N), //addr 0x0021 bit4
    .i_MCIO31A_PE_WAKE_R_N              (i_MCIO31A_PE_WAKE_R_N), //addr 0x0021 bit3
    .i_MCIO31C_PE_WAKE_R_N              (i_MCIO31C_PE_WAKE_R_N), //addr 0x0021 bit2
    .i_MCIO32A_PE_WAKE_R_N              (i_MCIO32A_PE_WAKE_R_N), //addr 0x0021 bit1
    .i_MCIO32C_PE_WAKE_R_N              (i_MCIO32C_PE_WAKE_R_N)  //addr 0x0021 bit0

);



endmodule