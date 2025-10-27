//=================================================================================================
// Copyright(c)
// Filename   : BP_4S104G5
// Project    : BP_4S104G5
// Author     :
// Date       : 2024-4-9
//Simulator   : Lattice Diamond 3.12
//FPGA        : LCMXO3LF_6900C_5BG400C
// Email      : cloudnineinfo.com
// Company    :
// Description: BP_4S104G5 Top Code
// History    :
// Date      By          Revision  Change Description
//-------------------------------------------------------------------------------------------------
//-- Principle of Naming:
//-- In BP_4S104G5  : one CPLD,this Code for CPLD_U1  J68

//--------------------------------------------------------------------------------------------------

//=================================================================================================

`include "BP_4S104G5_VA_port.v"


//-------------------------------------------------------------------------------------------------
// define parameter
//-------------------------------------------------------------------------------------------------

`define PRODUCT_ID      8'h33
`define VENDER_ID       8'h08

`define Year            8'h25
`define Month           8'h02
`define Day             8'h08
`define CPLD_VERSION    8'h11
`define DEBUG_VERSION   8'h00





localparam FAN_NUM = 15  ;





//-------------------------------------------------------------------------------------------------
//For pll_inst
//-------------------------------------------------------------------------------------------------
wire clk_50m ;
wire clk_25m ;
wire pll_lock;

// wire [7:0] uart_slave_test ;
//-------------------------------------------------------------------------------------------------
//For pon_reset_inst
//-------------------------------------------------------------------------------------------------
wire pon_reset_n                ;
wire pon_reset_db_n             ;
wire pgd_aux_system             ;
wire pgd_aux_system_sasd        ;
// wire pgd_aux_bmc                ;//From CMU
wire done_booting_delayed = 1'b1;//input; define constant 1

//-------------------------------------------------------------------------------------------------
//For timer_gen_inst
//-------------------------------------------------------------------------------------------------
wire t40ns_tick ;
wire t1us_tick  ;
wire t2us_tick  ;
wire t16us_tick ;
wire t32us_tick ;
wire t128us_tick;
wire t512us_tick;
wire t1ms_tick  ;
wire t2ms_tick  ;
wire t32ms_tick ;
wire t64ms_tick ;
wire t128ms_tick;
wire t256ms_tick;
wire t512ms_tick;
wire t1s_tick   ;
wire t0p5hz_clk ;
wire t1hz_clk   ;
wire t2p5hz_clk ;
wire t4hz_clk   ;
wire t16khz_clk ;
wire t6m25_clk  ;
// wire t16m6_clk  ;




wire w_pch_slp5_n   ;
wire w_p12v_pg_db         ;//02
wire w_rst_pltrst_n        ;
//-------------------------------------------------------------------------------------------------
//For NC PIN
//-------------------------------------------------------------------------------------------------
wire w_nc_pin ;

assign w_nc_pin =  i_NIC_SGPIO_SDO_R    |
                   i_RSVD_PARTNER0_R	|
                   i_RSVD_PARTNER1_R	|
                   i_RSVD_PARTNER2_R	|
                   i_RSVD_PARTNER3_R	|
                   // i_3V3IO_RSVD0_FFU_R  |   //2024-5-20 del
                   // i_3V3IO_RSVD1_FFU_R  |   //2024-5-20 del
                   // i_3V3IO_RSVD2_FFU_R  |   //2024-5-20 del
                   // i_3V3IO_RSVD3_FFU_R  |   //2024-5-20 del
                   i_3V3IO_RSVD4_FFU_R  |
                   i_3V3IO_RSVD5_FFU_R  |
                   i_3V3IO_RSVD1_R	    |
                   i_3V3IO_RSVD3_R	    |
                   i_3V3IO_RSVD4_R	    |
                   i_BB_RSVD_1_R        |
                   i_PE0_PERST_R		|		   
                   i_SW0_SLOT1_RST_N_R  |
                   i_SW0_SLOT2_RST_N_R  |
                   i_SW0_SLOT3_RST_N_R  |
                   i_SW0_SLOT4_RST_N_R  |
                   i_SW0_SLOT5_RST_N_R  |
                   i_SW0_SLOT6_RST_N_R  |
                   i_SW1_SLOT1_RST_N_R  |
                   i_SW1_SLOT2_RST_N_R  |
                   i_SW1_SLOT3_RST_N_R  |
                   i_SW1_SLOT4_RST_N_R  |
                   i_SW1_SLOT5_RST_N_R  |
                   i_SW1_SLOT6_RST_N_R  |
                   i_SW2_SLOT1_RST_N_R  |
                   i_SW2_SLOT2_RST_N_R  |
                   i_SW2_SLOT3_RST_N_R  |
                   i_SW2_SLOT4_RST_N_R  |
                   i_SW2_SLOT5_RST_N_R  |
                   i_SW2_SLOT6_RST_N_R  |
                   i_SW3_SLOT1_RST_N_R  |
                   i_SW3_SLOT2_RST_N_R  |
                   i_SW3_SLOT3_RST_N_R  |
                   i_SW3_SLOT4_RST_N_R  |
                   i_SW3_SLOT5_RST_N_R  |
                   i_SW3_SLOT6_RST_N_R

                   ;


assign o_SMB_NIC_RST_N_R = 1'bz;

// assign o_PAL_HSC0_RESTART_R = w_pch_slp5_n & w_p12v_pg_db? 1'b1 : 1'b0 ;  //2024-6-18 chg 1'bz;

assign o_PAL_HSC0_RESTART_R = 1'b0; //2024-12-24 

//-------------------------------------------------------------------------------------------------
// RETIMER_RESET START 2024-7-10 ADD
//-------------------------------------------------------------------------------------------------
wire w_RETIMER1_0P9_PG;
wire w_RETIMER2_0P9_PG;
wire w_RETIMER3_0P9_PG;
wire w_RETIMER4_0P9_PG;
wire w_RETIMER5_0P9_PG;
wire w_RETIMER6_0P9_PG;
wire w_RETIMER7_0P9_PG;
wire w_RETIMER8_0P9_PG;

// assign o_RETIMER1_RESET_N_R = w_pch_slp5_n & w_p12v_pg_db? 1'b1 : 1'b0 ; //w_rst_pltrst_n ; //2024-7-1   
// assign o_RETIMER2_RESET_N_R = w_pch_slp5_n & w_p12v_pg_db? 1'b1 : 1'b0 ; //w_rst_pltrst_n ; //2024-7-1   
// assign o_RETIMER3_RESET_N_R = w_pch_slp5_n & w_p12v_pg_db? 1'b1 : 1'b0 ; //w_rst_pltrst_n ; //2024-7-1   
// assign o_RETIMER4_RESET_N_R = w_pch_slp5_n & w_p12v_pg_db? 1'b1 : 1'b0 ; //w_rst_pltrst_n ; //2024-7-1   
// assign o_RETIMER5_RESET_N_R = w_pch_slp5_n & w_p12v_pg_db? 1'b1 : 1'b0 ; //w_rst_pltrst_n ; //2024-7-1   
// assign o_RETIMER6_RESET_N_R = w_pch_slp5_n & w_p12v_pg_db? 1'b1 : 1'b0 ; //w_rst_pltrst_n ; //2024-7-1   
// assign o_RETIMER7_RESET_N_R = w_pch_slp5_n & w_p12v_pg_db? 1'b1 : 1'b0 ; //w_rst_pltrst_n ; //2024-7-1   
// assign o_RETIMER8_RESET_N_R = w_pch_slp5_n & w_p12v_pg_db? 1'b1 : 1'b0 ; //w_rst_pltrst_n ; //2024-7-1   


// wire w_rst_pltrst_pos ;
// Edge_Detect Edge_Detect_U1(    
    // .i_clk               (clk_50m),        
    // .i_rst_n             (pon_reset_n),       
    // .i_signal            (w_rst_pltrst_n),
    
    // .o_signal_pos        (w_rst_pltrst_pos),
    // .o_signal_neg        (),
    // .o_signal_invert     ()
// );

// reg r_rst_pltrst_pos ;
// always@(posedge clk_50m or negedge pon_reset_n) begin
	// if(~pon_reset_n) begin
		// r_rst_pltrst_pos <=1'b0;
	// end
	// else if(w_rst_pltrst_pos) begin
		// r_rst_pltrst_pos <=1'b1;
	// end
	// else begin
		// r_rst_pltrst_pos <= r_rst_pltrst_pos;
	// end
// end

// assign o_RETIMER1_RESET_N_R = w_pch_slp5_n & r_rst_pltrst_pos ? 1'b1 : 1'b0 ;  //2024-7-10 add for debug   
// assign o_RETIMER2_RESET_N_R = w_pch_slp5_n & r_rst_pltrst_pos ? 1'b1 : 1'b0 ;  //2024-7-10 add for debug   
// assign o_RETIMER3_RESET_N_R = w_pch_slp5_n & r_rst_pltrst_pos ? 1'b1 : 1'b0 ;  //2024-7-10 add for debug   
// assign o_RETIMER4_RESET_N_R = w_pch_slp5_n & r_rst_pltrst_pos ? 1'b1 : 1'b0 ;  //2024-7-10 add for debug   
// assign o_RETIMER5_RESET_N_R = w_pch_slp5_n & r_rst_pltrst_pos ? 1'b1 : 1'b0 ;  //2024-7-10 add for debug   
// assign o_RETIMER6_RESET_N_R = w_pch_slp5_n & r_rst_pltrst_pos ? 1'b1 : 1'b0 ;  //2024-7-10 add for debug   
// assign o_RETIMER7_RESET_N_R = w_pch_slp5_n & r_rst_pltrst_pos ? 1'b1 : 1'b0 ;  //2024-7-10 add for debug   
// assign o_RETIMER8_RESET_N_R = w_pch_slp5_n & r_rst_pltrst_pos ? 1'b1 : 1'b0 ;  //2024-7-10 add for debug  



wire w_retimer1_0p9_pg_dly10ms ; //2024-7-10 add 
edge_delay #(.CNTR_NBITS(3), .DELAY_MODE(1'b0)) edge_delay_retimer1_0p9_pg ( //DELAY_MODE =0 for rise 
  .clk         (clk_50m),
  .reset       (~pgd_aux_system),
  .cnt_size    (3'd5),
  .cnt_step    (t2ms_tick),
  .signal_in   (w_RETIMER1_0P9_PG),     //this signal from 0 to 1
  .delay_output(w_retimer1_0p9_pg_dly10ms)  
  );
  
wire w_retimer2_0p9_pg_dly10ms ; //2024-7-10 add 
edge_delay #(.CNTR_NBITS(3), .DELAY_MODE(1'b0)) edge_delay_retimer2_0p9_pg ( //DELAY_MODE =0 for rise 
  .clk         (clk_50m),
  .reset       (~pgd_aux_system),
  .cnt_size    (3'd5),
  .cnt_step    (t2ms_tick),
  .signal_in   (w_RETIMER2_0P9_PG),     //this signal from 0 to 1
  .delay_output(w_retimer2_0p9_pg_dly10ms)  
  );
  
wire w_retimer3_0p9_pg_dly10ms ; //2024-7-10 add 
edge_delay #(.CNTR_NBITS(3), .DELAY_MODE(1'b0)) edge_delay_retimer3_0p9_pg ( //DELAY_MODE =0 for rise 
  .clk         (clk_50m),
  .reset       (~pgd_aux_system),
  .cnt_size    (3'd5),
  .cnt_step    (t2ms_tick),
  .signal_in   (w_RETIMER3_0P9_PG),     //this signal from 0 to 1
  .delay_output(w_retimer3_0p9_pg_dly10ms)  
  );

wire w_retimer4_0p9_pg_dly10ms ; //2024-7-10 add 
edge_delay #(.CNTR_NBITS(3), .DELAY_MODE(1'b0)) edge_delay_retimer4_0p9_pg ( //DELAY_MODE =0 for rise 
  .clk         (clk_50m),
  .reset       (~pgd_aux_system),
  .cnt_size    (3'd5),
  .cnt_step    (t2ms_tick),
  .signal_in   (w_RETIMER4_0P9_PG),     //this signal from 0 to 1
  .delay_output(w_retimer4_0p9_pg_dly10ms)  
  );

wire w_retimer5_0p9_pg_dly10ms ; //2024-7-10 add 
edge_delay #(.CNTR_NBITS(3), .DELAY_MODE(1'b0)) edge_delay_retimer5_0p9_pg ( //DELAY_MODE =0 for rise 
  .clk         (clk_50m),
  .reset       (~pgd_aux_system),
  .cnt_size    (3'd5),
  .cnt_step    (t2ms_tick),
  .signal_in   (w_RETIMER5_0P9_PG),     //this signal from 0 to 1
  .delay_output(w_retimer5_0p9_pg_dly10ms)  
  );

wire w_retimer6_0p9_pg_dly10ms ; //2024-7-10 add 
edge_delay #(.CNTR_NBITS(3), .DELAY_MODE(1'b0)) edge_delay_retimer6_0p9_pg ( //DELAY_MODE =0 for rise 
  .clk         (clk_50m),
  .reset       (~pgd_aux_system),
  .cnt_size    (3'd5),
  .cnt_step    (t2ms_tick),
  .signal_in   (w_RETIMER6_0P9_PG),     //this signal from 0 to 1
  .delay_output(w_retimer6_0p9_pg_dly10ms)  
  );

wire w_retimer7_0p9_pg_dly10ms ; //2024-7-10 add 
edge_delay #(.CNTR_NBITS(3), .DELAY_MODE(1'b0)) edge_delay_retimer7_0p9_pg ( //DELAY_MODE =0 for rise 
  .clk         (clk_50m),
  .reset       (~pgd_aux_system),
  .cnt_size    (3'd5),
  .cnt_step    (t2ms_tick),
  .signal_in   (w_RETIMER7_0P9_PG),     //this signal from 0 to 1
  .delay_output(w_retimer7_0p9_pg_dly10ms)  
  );

wire w_retimer8_0p9_pg_dly10ms ; //2024-7-10 add 
edge_delay #(.CNTR_NBITS(3), .DELAY_MODE(1'b0)) edge_delay_retimer8_0p9_pg ( //DELAY_MODE =0 for rise 
  .clk         (clk_50m),
  .reset       (~pgd_aux_system),
  .cnt_size    (3'd5),
  .cnt_step    (t2ms_tick),
  .signal_in   (w_RETIMER8_0P9_PG),     //this signal from 0 to 1
  .delay_output(w_retimer8_0p9_pg_dly10ms)  
  );

assign o_RETIMER1_RESET_N_R = w_retimer1_0p9_pg_dly10ms ? 1'b1 : 1'b0 ;  //2024-7-10 add for debug   
assign o_RETIMER2_RESET_N_R = w_retimer2_0p9_pg_dly10ms ? 1'b1 : 1'b0 ;  //2024-7-10 add for debug   
assign o_RETIMER3_RESET_N_R = w_retimer3_0p9_pg_dly10ms ? 1'b1 : 1'b0 ;  //2024-7-10 add for debug   
assign o_RETIMER4_RESET_N_R = w_retimer4_0p9_pg_dly10ms ? 1'b1 : 1'b0 ;  //2024-7-10 add for debug   
assign o_RETIMER5_RESET_N_R = w_retimer5_0p9_pg_dly10ms ? 1'b1 : 1'b0 ;  //2024-7-10 add for debug   
assign o_RETIMER6_RESET_N_R = w_retimer6_0p9_pg_dly10ms ? 1'b1 : 1'b0 ;  //2024-7-10 add for debug   
assign o_RETIMER7_RESET_N_R = w_retimer7_0p9_pg_dly10ms ? 1'b1 : 1'b0 ;  //2024-7-10 add for debug   
assign o_RETIMER8_RESET_N_R = w_retimer8_0p9_pg_dly10ms ? 1'b1 : 1'b0 ;  //2024-7-10 add for debug  










//-------------------------------------------------------------------------------------------------
// RETIMER_RESET END
//-------------------------------------------------------------------------------------------------

assign o_BP_9548_RST_N_R = 1'bz;

assign o_UBB_PEX_STRAP0_R = 1'bz;
assign o_UBB_PEX_STRAP1_R = 1'bz;
assign o_FPGA_EROT_RECOV_N_R = 1'bz;
assign o_FPGA_EROT_RST_N_R	 = 1'bz;
assign o_FPGA_BOOT_EN_R	= 1'bz;    
assign o_HGX_DETECT_N_R	= 1'bz;    
assign o_NVLINK_REFCLK_SELECT_R = 1'bz;

assign o_DS160_TX_READ_EN_N = 1'bz;
assign o_DS160_RX_READ_EN_N = 1'bz;


assign o_I2C_RST0_N_R = 1'bz;
assign o_I2C_RST1_N_R = 1'bz;
assign o_I2C_RST2_N_R = 1'bz;




//-------------------------------------------------------------------------------------------------
// SYS Clock
//-------------------------------------------------------------------------------------------------
pll_i25M_o50M_o25M pll_inst(
  .CLKI  (i_CPLD_CLK), //in
  .RST   (~i_P3V3_STBY_PG ), //in  //.RST   (i_CPLD_RESET_N ),
  .CLKOP (clk_50m        ), //out  50Mhz in fact
  .CLKOS (clk_25m        ), //out; 25MHZ in fact    for  bmc_cpld_i2c_ram only
  .LOCK  (pll_lock       )  //out
);

//-------------------------------------------------------------------------------------------------
// SYS RST
//-------------------------------------------------------------------------------------------------
pon_reset pon_reset_inst(
  .clk                  (clk_50m),              //in
  .pll_lock             (pll_lock),             //in
  .pgd_p3v3_stby        (i_P3V3_STBY_PG ),      //in
  .pgd_aux_gmt          (1'b1),                 //in, all BMC power ok
  .done_booting         (1'b1),                 //in
  .done_booting_delayed (done_booting_delayed), //in;  delayed version of done_booting (if not used, set to 1'b1)
  .pon_reset_n          (pon_reset_n),          //out; master AUX power-on reset (based on pgd_p3v3_stby)
  .pon_reset_db_n       (pon_reset_db_n),       //out; when done_booting_delayed not usd;  pon_reset_db_n = pon_reset_n.
  .pgd_aux_system       (pgd_aux_system),       //out; 
  .pgd_aux_system_sasd  (pgd_aux_system_sasd),  //out; SASD version of pgd_aux_system; pgd_aux_system_sasd = pgd_aux_system
  .cpld_ready           ()
);

//-------------------------------------------------------------------------------------------------
// Generate Timer Ticks (1-clk wide pulse) And Slow 50% Duty Cycle Clock
//-------------------------------------------------------------------------------------------------
timer_gen timer_gen_inst(
  .clk      (clk_50m),
  .reset    (~pon_reset_n),
  .t40ns    (t40ns_tick ),
  .t80ns    (),
  .t160ns   (),
  .t1us     (t1us_tick  ),
  .t2us     (t2us_tick  ),
  .t16us    (t16us_tick ),
  .t32us    (t32us_tick ),
  .t128us   (t128us_tick),
  .t512us   (t512us_tick),
  .t1ms     (t1ms_tick  ),
  .t2ms     (t2ms_tick  ),
  .t16ms    (),
  .t32ms    (t32ms_tick ),
  .t64ms    (t64ms_tick ),
  .t128ms   (t128ms_tick),
  .t256ms   (t256ms_tick),
  .t512ms   (t512ms_tick),
  .t1s      (t1s_tick   ),
  .clk_0p5hz(t0p5hz_clk	),
  .clk_1hz  (t1hz_clk   ),
  .clk_2p5hz(t2p5hz_clk ),
  .clk_4hz  (t4hz_clk   ),
  .clk_16khz(t16khz_clk ),
  .clk_6m25 (t6m25_clk  )
);





//-------------------------------------------------------------------------------------------------
// Pwrgood Debounce
//-------------------------------------------------------------------------------------------------

wire w_p3v3_stby_pg_db    ;//01
// wire w_p12v_pg_db         ;//02
wire w_p0v8_sw0_pwrgd_db  ;//03
wire w_p0v8_sw1_pwrgd_db  ;//04
wire w_p0v8_sw2_pwrgd_db  ;//05
wire w_p0v8_sw3_pwrgd_db  ;//06
wire w_ct_p1v25_sw0_pg_db ;//07
wire w_ct_p1v25_sw1_pg_db ;//08
wire w_ct_p1v25_sw2_pg_db ;//09
wire w_ct_p1v25_sw3_pg_db ;//10
wire w_pg_p5v0_r_db       ;//11
wire w_pg_p1v8_r_db       ;//12
wire w_pg_p1v8_pll_r_db   ;//13

//Active High
//If The Un-Debounced Signal Starts Low Initially Such As PGD, Use PGM_DEBOUNCE_N.
//For Signal That Starts High Like Power Buttons,Use PGM_DEBOUNCE.

PGM_DEBOUNCE_N #(.SIGCNT(13),.NBITS(2'b11),.ENABLE(1'b1))
db_power_pg(
  .clk         (clk_50m),
  .rst_n       (pon_reset_n),
  .timer_tick  (t1us_tick),  
  .din         ({
				i_P3V3_STBY_PG               ,//01
				i_P12V_PG                    ,//02
				i_P0V8_SW0_PWRGD             ,//03
				i_P0V8_SW1_PWRGD             ,//04
				i_P0V8_SW2_PWRGD             ,//05
				i_P0V8_SW3_PWRGD             ,//06
				i_CT_P1V25_SW0_PG            ,//07
				i_CT_P1V25_SW1_PG            ,//08
				i_CT_P1V25_SW2_PG            ,//09
				i_CT_P1V25_SW3_PG            ,//10
				i_PG_P5V0_R                  ,//11
				i_PG_P1V8_R                  ,//12
				i_PG_P1V8_PLL_R               //13

				}),
  .dout        ({
				w_p3v3_stby_pg_db              ,//01
				w_p12v_pg_db                   ,//02
				w_p0v8_sw0_pwrgd_db            ,//03
				w_p0v8_sw1_pwrgd_db            ,//04
				w_p0v8_sw2_pwrgd_db            ,//05
				w_p0v8_sw3_pwrgd_db            ,//06
				w_ct_p1v25_sw0_pg_db           ,//07
				w_ct_p1v25_sw1_pg_db           ,//08
				w_ct_p1v25_sw2_pg_db           ,//09
				w_ct_p1v25_sw3_pg_db           ,//10
				w_pg_p5v0_r_db                 ,//11
				w_pg_p1v8_r_db                 ,//12
				w_pg_p1v8_pll_r_db              //13

				})
);

wire w_psu0_pwrok_n_db;//01
wire w_psu1_pwrok_n_db;//02
wire w_psu2_pwrok_n_db;//03
wire w_psu3_pwrok_n_db;//04
wire w_psu4_pwrok_n_db;//05
wire w_psu5_pwrok_n_db;//06


PGM_DEBOUNCE #(.SIGCNT(6), .NBITS (2'b11), .ENABLE(1'b1)) db_inst_psu0_pwrok_n(
  .clk(clk_50m),
  .timer_tick(t512us_tick),
  .rst(~pon_reset_n),
  .din({
  	    i_PSU0_PWROK_N, //01
		i_PSU1_PWROK_N, //02
		i_PSU2_PWROK_N, //03
		i_PSU3_PWROK_N, //04
		i_PSU4_PWROK_N, //05
		i_PSU5_PWROK_N  //06
	  }),
  .dout({
	    w_psu0_pwrok_n_db, //01
		w_psu1_pwrok_n_db, //02
		w_psu2_pwrok_n_db, //03
		w_psu3_pwrok_n_db, //04
		w_psu4_pwrok_n_db, //05
		w_psu5_pwrok_n_db  //06

       })
);


// edge_delay #(.CNTR_NBITS(4), .DELAY_MODE(1'b0)) edge_delay_inst_n ( //DELAY_MODE =0 for rise 
  // .clk         (clk_50m),
  // .reset       (~pgd_aux_system),
  // .cnt_size    (4'd10),
  // .cnt_step    (t1ms_tick),
  // .signal_in   (db_i_pal_bmc_srst_n_r),     //this signal from mb  from 0 to 1
  // .delay_output(w_pal_bmc_srst_n_dly10ms)  //from mb to bmc delay 10ms
  // );






//-------------------------------------------------------------------------------------------------
//From MB SGPIO
//-------------------------------------------------------------------------------------------------


// wire w_t4hz_clk_from_mb    ; //2024-7-1 add 
wire w_cpld_pch_rsmrst_n_r ;
wire w_bmc_active0_n       ;
wire w_pgd_p5v             ;


//-------------------------------------------------------------------------------------------------
//To MB SGPIO
//-------------------------------------------------------------------------------------------------
reg r_sw0_spi_cs_sel_r ;
reg r_sw1_spi_cs_sel_r ;
reg r_sw2_spi_cs_sel_r ;
reg r_sw3_spi_cs_sel_r ;



//-------------------------------------------------------------------------------------------------
// SGPIO data
//-------------------------------------------------------------------------------------------------
wire [59:0] mcpld_to_swcpld_s2p_data;
wire [59:0] swcpld_to_mcpld_p2s_data;

reg [51:0] mcpld_to_swcpld_data_filter;
reg mb_sgpio_fail;



//swcpld ---> mcpld
assign swcpld_to_mcpld_p2s_data[59]      = 1'b1                                ;
assign swcpld_to_mcpld_p2s_data[58]      = 1'b0                                ;
assign swcpld_to_mcpld_p2s_data[57]      = 1'b1                                ;
assign swcpld_to_mcpld_p2s_data[56]      = 1'b0                                ;
assign swcpld_to_mcpld_p2s_data[55:16]   = 'b0                                 ;




assign swcpld_to_mcpld_p2s_data[15]     = r_sw3_spi_cs_sel_r                  ; //2024-11-21 add 
assign swcpld_to_mcpld_p2s_data[14]     = r_sw2_spi_cs_sel_r                  ; //2024-11-21 add 
assign swcpld_to_mcpld_p2s_data[13]     = r_sw1_spi_cs_sel_r                  ; //2024-11-21 add 
assign swcpld_to_mcpld_p2s_data[12]     = r_sw0_spi_cs_sel_r                  ; //2024-11-21 add 
assign swcpld_to_mcpld_p2s_data[11]     = o_SW3_SPI_CS_SEL_R                  ; //2024-9-10 add
assign swcpld_to_mcpld_p2s_data[10]     = o_SW2_SPI_CS_SEL_R                  ; //2024-9-10 add
assign swcpld_to_mcpld_p2s_data[9]      = o_SW1_SPI_CS_SEL_R                  ; //2024-9-10 add
assign swcpld_to_mcpld_p2s_data[8]      = o_SW0_SPI_CS_SEL_R                  ; //2024-9-10 add


// assign swcpld_to_mcpld_p2s_data[8]       = t4hz_clk                            ;  //2024-7-1 add 
assign swcpld_to_mcpld_p2s_data[7]       = i_3V3IO_RSVD0_FFU_R                 ;  //2024-5-20
assign swcpld_to_mcpld_p2s_data[6]       = i_3V3IO_RSVD1_FFU_R                 ;  //2024-5-20
assign swcpld_to_mcpld_p2s_data[5]       = i_3V3IO_RSVD2_FFU_R                 ;  //2024-5-20
assign swcpld_to_mcpld_p2s_data[4]       = i_3V3IO_RSVD3_FFU_R                 ;  //2024-5-20
assign swcpld_to_mcpld_p2s_data[3]       = 1'b0                                ;
assign swcpld_to_mcpld_p2s_data[2]       = 1'b1                                ;
assign swcpld_to_mcpld_p2s_data[1]       = 1'b0                                ;
assign swcpld_to_mcpld_p2s_data[0]       = 1'b1                                ;


//mcpld ---> swcpld

// assign w_t4hz_clk_from_mb                = mcpld_to_swcpld_data_filter[5]       ; //2024-7-1 add 
assign w_cpld_pch_rsmrst_n_r             = mcpld_to_swcpld_data_filter[4]       ;
assign w_bmc_active0_n                   = mcpld_to_swcpld_data_filter[3]       ;
assign w_pgd_p5v                         = mcpld_to_swcpld_data_filter[2]       ;
assign w_rst_pltrst_n                    = mcpld_to_swcpld_data_filter[1]       ;
assign w_pch_slp5_n                      = mcpld_to_swcpld_data_filter[0]       ;


//-------------------------------------------------------------------------------------------------
// SW_CPLD_U1 SGPIO Moudule       SW_CPLD_U1 is slave
//-------------------------------------------------------------------------------------------------

always@(posedge clk_50m or negedge pon_reset_n)
	begin
		if(~pon_reset_n)
			begin
				mcpld_to_swcpld_data_filter <= {52{1'b0}};
				mb_sgpio_fail <=1'b0;
			end
		else if
			((mcpld_to_swcpld_s2p_data[3:0] == 4'b0101)&& (mcpld_to_swcpld_s2p_data[59:56] == 4'b1010))
			begin
				mcpld_to_swcpld_data_filter <= mcpld_to_swcpld_s2p_data[55:4];
				mb_sgpio_fail <=1'b0;
			end
		else
			begin
				mcpld_to_swcpld_data_filter <= mcpld_to_swcpld_data_filter;
				mb_sgpio_fail <=1'b1;
			end

end


//M CPLD ---> SW CPLD
s2p_slave #(.NBIT(60)) inst_mb_to_slv_s2p(
	.clk   (clk_50m                 ),
	.rst   (~pon_reset_n            ),
	.si    (i_MB_SGPIO_DATA_OUT	    ),//SGPIO_MOSI Serial Signal input
	.po    (mcpld_to_swcpld_s2p_data),//Parallel Signal output
	.sld_n (i_MB_SGPIO_LD	        ),//SGPIO_LOAD
	.sclk  (i_MB_SGPIO_CLK		    ) //SGPIO_CLK
);

// SW CPLD ---> M CPLD
p2s_slave #(.NBIT(60)) inst_slv_to_mb_p2s(
	.clk   (clk_50m				    ),
	.rst   (~pon_reset_n			),
	.pi    (swcpld_to_mcpld_p2s_data),//Parallel Signal input
	.so    (o_MB_SGPIO_DATA_IN		),//SGPIO_MISO Serial Signal output
	.sld_n (i_MB_SGPIO_LD   	    ),//SGPIO_LOAD
	.sclk  (i_MB_SGPIO_CLK	        ) //SGPIO_CLK
);

//-------------------------------------------------------------------------------------------------
// SGPIO WDT 2024-7-1 add
// ------------------------------------------------------------------------------------------------
// wire w_sgpio_active0_n;

// WDT#(.WDT_TIMIEOUT (2'd2), .RST_VLU(1'b0) ) SGPIO_WDT  
// (
// .i_clk         (clk_50m), 
// .i_rst_n       (pon_reset_n), 
// .i_wdt_en      (1'b1), 
// .i_WDT_cnt_clk (t2p5hz_clk  ), 
// .i_WDT_cnt_clr (w_t4hz_clk_from_mb ), 
// .o_WDT_timeout (w_sgpio_active0_n)  // defaulte 0; SGPIO die: 1; SGPIO active: 0 ; 
// );


// assign w_led_control[4] = w_sgpio_active0_n ? 1'b1 : 1'b0 ; //SGPIO die light the led 

assign o_debug_led2 = mb_sgpio_fail ? 1'b0 : 1'b1 ; //2024-7-1 add SGPIO die light the led

//-------------------------------------------------------------------------------------------------
// pvt SW_165_0
//-------------------------------------------------------------------------------------------------

wire [5:0]pvti_ss_count;

//U95
wire w_PAL_FAN14_PRSNT_N;
wire w_PAL_FAN5_PRSNT_N ;
wire w_TEMP_ALERT_1_R   ;
wire w_PAL_FAN10_PRSNT_N;
wire w_PAL_FAN4_PRSNT_N ;
wire w_PAL_FAN9_PRSNT_N ;
wire w_PAL_FAN15_PRSNT_N;
wire w_SW0_CLKREQ_N_R   ;
//U96
wire w_PAL_FAN13_PRSNT_N;
wire w_PAL_FAN1_PRSNT_N ;
wire w_PAL_FAN6_PRSNT_N ;
wire w_PAL_FAN11_PRSNT_N;
wire w_PAL_FAN12_PRSNT_N;
wire w_PAL_FAN7_PRSNT_N ;
wire w_PAL_FAN2_PRSNT_N ;
wire w_TEMP_ALERT_0_R   ;
//U101
wire w_TEMP_ALERT_2_R  ;
wire w_PAL_FAN3_PRSNT_N;
wire w_PAL_FAN8_PRSNT_N;
wire w_NICBOX_PRSNT_N_R;
wire w_SW2_CLKREQ_N_R  ;
wire w_PSU2_PRSNT_R    ;
wire w_PSU1_PRSNT_R    ;
wire w_PSU0_PRSNT_R    ;
//U97
wire w_TEMP_ALERT_3_R;
wire w_HSC0_PG       ;
wire w_HSC0_FAULT    ;
wire w_HSC0_GPIO1_R  ;
wire w_HSC0_GPIO2_R  ;
wire w_PSU3_PRSNT_R  ;
wire w_PSU4_PRSNT_R  ;
wire w_PSU5_PRSNT_R  ;
//U98
wire w_P0V8_SW2_FAULT_N;
wire w_P0V8_SW2_ALERT_N;
wire w_P0V8_SW2_VRHOT_N;
wire w_SW3_CLKREQ_N_R  ;
wire w_MCIO21A_CFG_N_R ;
wire w_MCIO21C_CFG_N_R ;
wire w_MCIO22A_CFG_N_R ;
wire w_MCIO22C_CFG_N_R ;
//U102
wire w_MCIO01C_CFG_N_R ;
wire w_MCIO01A_CFG_N_R ;
wire w_P0V8_SW0_ALERT_N;
wire w_P0V8_SW0_VRHOT_N;
wire w_P0V8_SW0_FAULT_N;
wire w_MCIO02A_CFG_N_R ;
wire w_MCIO02C_CFG_N_R ;
wire w_BPTB_PRSNT_N_R  ;
//U103
wire w_MCIO31C_CFG_N_R ;
wire w_MCIO32A_CFG_N_R ;
wire w_MCIO32C_CFG_N_R ;
wire w_MCIO31A_CFG_N_R ;
wire w_MBP_PRSNT_N_R   ;
wire w_P0V8_SW3_VRHOT_N;
wire w_P0V8_SW3_FAULT_N;
wire w_P0V8_SW3_ALERT_N;



pvt_gpi #(
  .TOTAL_BIT_COUNT(56),
  .DEFAULT_STATE(56'h0),
  .NUMBER_OF_COUNTER_BITS(6)
) pvt_SW_inst (
  .clk           (clk_50m),            //in
  .reset_n       (pon_reset_n),        //in
  .clk_ena       (t16us_tick),         //in
  .serclk_in     (o_74LV165_CLK_R),    //in
  .par_load_in_n (o_74LV165_LD_R),     //in
  .sdi           (i_74LV165_DATA_IN_R),//in
  .bit_idx_in    (pvti_ss_count),      //in
  .bit_idx_out   (pvti_ss_count),      //out
  .serclk_out    (o_74LV165_CLK_R ),   //out
  .par_load_out_n(o_74LV165_LD_R),     //out

  .par_data ({
            w_PAL_FAN14_PRSNT_N,w_PAL_FAN5_PRSNT_N,w_TEMP_ALERT_1_R,w_PAL_FAN10_PRSNT_N,
            w_PAL_FAN4_PRSNT_N,w_PAL_FAN9_PRSNT_N,w_PAL_FAN15_PRSNT_N,w_SW0_CLKREQ_N_R,
            //U95
            w_PAL_FAN13_PRSNT_N,w_PAL_FAN1_PRSNT_N,w_PAL_FAN6_PRSNT_N,w_PAL_FAN11_PRSNT_N,
            w_PAL_FAN12_PRSNT_N,w_PAL_FAN7_PRSNT_N,w_PAL_FAN2_PRSNT_N,w_TEMP_ALERT_0_R,
			//U96
			w_TEMP_ALERT_2_R,w_PAL_FAN3_PRSNT_N,w_PAL_FAN8_PRSNT_N,w_NICBOX_PRSNT_N_R,
			w_SW2_CLKREQ_N_R,w_PSU2_PRSNT_R,w_PSU1_PRSNT_R,w_PSU0_PRSNT_R,
			//U101
			w_TEMP_ALERT_3_R,w_HSC0_PG,w_HSC0_FAULT,w_HSC0_GPIO1_R,
			w_HSC0_GPIO2_R,w_PSU3_PRSNT_R,w_PSU4_PRSNT_R,w_PSU5_PRSNT_R,
			//U97
			w_P0V8_SW2_FAULT_N,w_P0V8_SW2_ALERT_N,w_P0V8_SW2_VRHOT_N,w_SW3_CLKREQ_N_R,
			w_MCIO21A_CFG_N_R,w_MCIO21C_CFG_N_R,w_MCIO22A_CFG_N_R,w_MCIO22C_CFG_N_R,
			//U98
			w_MCIO01C_CFG_N_R,w_MCIO01A_CFG_N_R,w_P0V8_SW0_ALERT_N,w_P0V8_SW0_VRHOT_N,
			w_P0V8_SW0_FAULT_N,w_MCIO02A_CFG_N_R,w_MCIO02C_CFG_N_R,w_BPTB_PRSNT_N_R,
			//U102
			w_MCIO31C_CFG_N_R,w_MCIO32A_CFG_N_R,w_MCIO32C_CFG_N_R,w_MCIO31A_CFG_N_R,
			w_MBP_PRSNT_N_R,w_P0V8_SW3_VRHOT_N,w_P0V8_SW3_FAULT_N,w_P0V8_SW3_ALERT_N
			//U103
            })
);


//-------------------------------------------------------------------------------------------------
// pvt SW_165_1
//-------------------------------------------------------------------------------------------------

wire [3:0]pvti_ss_count1;


//U104
wire w_BOARD_ID4;
wire w_BOARD_ID3;
wire w_BOARD_ID2;
wire w_BOARD_ID1;
wire w_BOARD_ID0;
wire w_PCB_ID2  ;
wire w_PCB_ID1  ;
wire w_PCB_ID0  ;
//U105
wire w_MCIO11A_CFG_N_R ;
wire w_P0V8_SW1_FAULT_N;
wire w_P0V8_SW1_ALERT_N;
wire w_P0V8_SW1_VRHOT_N;
wire w_SW1_CLKREQ_N_R  ;
wire w_MCIO11C_CFG_N_R ;
wire w_MCIO12A_CFG_N_R ;
wire w_MCIO12C_CFG_N_R ;


pvt_gpi #(
  .TOTAL_BIT_COUNT(16),
  .DEFAULT_STATE(16'h0),
  .NUMBER_OF_COUNTER_BITS(4)
) pvt1_SW_inst (
  .clk           (clk_50m),               //in
  .reset_n       (pon_reset_n),           //in
  .clk_ena       (t16us_tick),            //in
  .serclk_in     (o_74LV165_1_CLK_R),     //in
  .par_load_in_n (o_74LV165_1_LD_R),      //in
  .sdi           (i_74LV165_1_DATA_IN_R), //in
  .bit_idx_in    (pvti_ss_count1),        //in
  .bit_idx_out   (pvti_ss_count1),        //out
  .serclk_out    (o_74LV165_1_CLK_R ),    //out
  .par_load_out_n(o_74LV165_1_LD_R),      //out

  .par_data ({
            w_BOARD_ID4,w_BOARD_ID3,w_BOARD_ID2,w_BOARD_ID1,
		    w_BOARD_ID0,w_PCB_ID2,w_PCB_ID1,w_PCB_ID0,
			//U104
			w_MCIO11A_CFG_N_R,w_P0V8_SW1_FAULT_N,w_P0V8_SW1_ALERT_N,w_P0V8_SW1_VRHOT_N,
			w_SW1_CLKREQ_N_R,w_MCIO11C_CFG_N_R,w_MCIO12A_CFG_N_R,w_MCIO12C_CFG_N_R
			//U105

            })
);


//-------------------------------------------------------------------------------------------------
// pvt NIC_165
//-------------------------------------------------------------------------------------------------

wire [5:0]pvti_nic_ss_count;

//U42
// wire w_RETIMER1_0P9_PG;
// wire w_RETIMER2_0P9_PG;
// wire w_RETIMER3_0P9_PG;
// wire w_RETIMER4_0P9_PG;
// wire w_RETIMER5_0P9_PG;
// wire w_RETIMER6_0P9_PG;
// wire w_RETIMER7_0P9_PG;
// wire w_RETIMER8_0P9_PG;
//U43
wire w_SLOT1_WAKE_N;
wire w_SLOT2_WAKE_N;
wire w_SLOT3_WAKE_N;
wire w_SLOT4_WAKE_N;
wire w_SLOT5_WAKE_N;
wire w_SLOT6_WAKE_N;
wire w_SLOT7_WAKE_N;
wire w_SLOT8_WAKE_N;
//U44
wire w_NIC_SLOT1_PRSNT_N;
wire w_NIC_SLOT2_PRSNT_N;
wire w_NIC_SLOT3_PRSNT_N;
wire w_NIC_SLOT4_PRSNT_N;
wire w_NIC_SLOT5_PRSNT_N;
wire w_NIC_SLOT6_PRSNT_N;
wire w_NIC_SLOT7_PRSNT_N;
wire w_NIC_SLOT8_PRSNT_N;
//U45
wire w_NIC_PCB_VER_ID0;
wire w_NIC_PCB_VER_ID1;
wire w_NIC_PCB_VER_ID2;
wire w_NIC_BOARD_ID0  ;
wire w_NIC_BOARD_ID1  ;
wire w_NIC_BOARD_ID2  ;
wire w_NIC_BOARD_ID3  ;
wire w_NIC_BOARD_ID4  ;
//U52
wire w_RETIMER1_1P8_PG;
wire w_RETIMER2_1P8_PG;
wire w_U52_C_NC_PIN   ;
wire w_U52_D_NC_PIN   ;
wire w_U52_E_NC_PIN   ;
wire w_U52_F_NC_PIN   ;
wire w_U52_G_NC_PIN   ;
wire w_U52_H_NC_PIN   ;


pvt_gpi #(
  .TOTAL_BIT_COUNT(40),
  .DEFAULT_STATE(40'h0),
  .NUMBER_OF_COUNTER_BITS(6)
) pvt_nic_inst (
  .clk           (clk_50m),            //in
  .reset_n       (pon_reset_n),        //in
  .clk_ena       (t16us_tick),         //in
  .serclk_in     (o_NIC_SGPIO_CLK_R),  //in
  .par_load_in_n (o_NIC_SGPIO_SLOAD_R),//in
  .sdi           (i_NIC_SGPIO_SDI_R  ),//in
  .bit_idx_in    (pvti_nic_ss_count),  //in
  .bit_idx_out   (pvti_nic_ss_count),  //out
  .serclk_out    (o_NIC_SGPIO_CLK_R ), //out
  .par_load_out_n(o_NIC_SGPIO_SLOAD_R),//out

  .par_data ({
            w_RETIMER8_0P9_PG,w_RETIMER7_0P9_PG,w_RETIMER6_0P9_PG,w_RETIMER5_0P9_PG,
			w_RETIMER4_0P9_PG,w_RETIMER3_0P9_PG,w_RETIMER2_0P9_PG,w_RETIMER1_0P9_PG,
			//2025-1-23 chg 1-8 to 8-1
			//U42
			w_SLOT8_WAKE_N,w_SLOT7_WAKE_N,w_SLOT6_WAKE_N,w_SLOT5_WAKE_N,
			w_SLOT4_WAKE_N,w_SLOT3_WAKE_N,w_SLOT2_WAKE_N,w_SLOT1_WAKE_N,
			//2025-1-23 chg 1-8 to 8-1
			//U43
			w_NIC_SLOT8_PRSNT_N,w_NIC_SLOT7_PRSNT_N,w_NIC_SLOT6_PRSNT_N,w_NIC_SLOT5_PRSNT_N,
			w_NIC_SLOT4_PRSNT_N,w_NIC_SLOT3_PRSNT_N,w_NIC_SLOT2_PRSNT_N,w_NIC_SLOT1_PRSNT_N,
			//2025-1-23 chg 1-8 to 8-1
			//U44
			w_NIC_PCB_VER_ID0,w_NIC_PCB_VER_ID1,w_NIC_PCB_VER_ID2,w_NIC_BOARD_ID0,
			w_NIC_BOARD_ID1,w_NIC_BOARD_ID2,w_NIC_BOARD_ID3,w_NIC_BOARD_ID4,
			//U45
			w_RETIMER2_1P8_PG,w_RETIMER1_1P8_PG,w_U52_C_NC_PIN,w_U52_D_NC_PIN, //cdms202501100001
			w_U52_E_NC_PIN,w_U52_F_NC_PIN,w_U52_G_NC_PIN,w_U52_H_NC_PIN
			//U52
			//2025-1-10   chg w_RETIMER1_1P8_PG,w_RETIMER2_1P8_PG, to w_RETIMER2_1P8_PG ,w_RETIMER1_1P8_PG //cdms202501100001
			
			
            })
);



/**************************************************************************************************/
//-------------------------------------------------------------------------------------------------
//PWR SEQ Start
//-------------------------------------------------------------------------------------------------
/**************************************************************************************************/

wire w_psu0_ctl ;
wire w_psu1_ctl ;
wire w_psu2_ctl ;
wire w_psu3_ctl ;
wire w_psu4_ctl ;
wire w_psu5_ctl ;



assign o_P5V0_EN = w_p3v3_stby_pg_db ? 1'b1 : 1'b0 ;

/////////////////////////////////////////////////////////////////////////////////////////////////////2024-7-25 modify

// wire w_p12v_pg_db_dly10ms ;
// edge_delay #(.CNTR_NBITS(3), .DELAY_MODE(1'b0)) edge_delay_p12v_pg_10ms ( //DELAY_MODE =0 for rise 
  // .clk         (clk_50m),
  // .reset       (~pgd_aux_system),
  // .cnt_size    (3'd5),
  // .cnt_step    (t2ms_tick),
  // .signal_in   (w_p12v_pg_db  ),     //this signal from 0 to 1
  // .delay_output(w_p12v_pg_db_dly10ms)  
  // );

// assign o_P1V8_EN     = w_p12v_pg_db_dly10ms ? 1'b1 : 1'b0 ; //2024-7-25  
// assign o_P1V8_PLL_EN = w_p12v_pg_db_dly10ms ? 1'b1 : 1'b0 ; //2024-7-25 


// wire w_p1v8_pg_db_dly10ms ;
// edge_delay #(.CNTR_NBITS(3), .DELAY_MODE(1'b0)) edge_delay_p1v8_pg_10ms ( //DELAY_MODE =0 for rise 
  // .clk         (clk_50m),
  // .reset       (~pgd_aux_system),
  // .cnt_size    (3'd5),
  // .cnt_step    (t2ms_tick),
  // .signal_in   (w_pg_p1v8_pll_r_db & w_pg_p1v8_r_db  ),     //this signal from 0 to 1
  // .delay_output(w_p1v8_pg_db_dly10ms)  
  // );

// assign o_CT_P1V25_SW_EN = w_p1v8_pg_db_dly10ms ? 1'b1 : 1'b0 ;

// wire w_p1v25_pg_db_dly10ms ;
// edge_delay #(.CNTR_NBITS(3), .DELAY_MODE(1'b0)) edge_delay_p1v25_pg_10ms ( //DELAY_MODE =0 for rise 
  // .clk         (clk_50m),
  // .reset       (~pgd_aux_system),
  // .cnt_size    (3'd5),
  // .cnt_step    (t2ms_tick),
  // .signal_in   (w_ct_p1v25_sw0_pg_db & 
                // w_ct_p1v25_sw1_pg_db & 
				// w_ct_p1v25_sw2_pg_db & 
				// w_ct_p1v25_sw3_pg_db ),     //this signal from 0 to 1
  // .delay_output(w_p1v25_pg_db_dly10ms)  
  // );

// assign o_P0V8_SW_EN = w_p1v25_pg_db_dly10ms ? 1'b1 : 1'b0 ;

///////////////////////////////////////////////////////////////////////////////////////////////////2024-8-17 


assign o_P0V8_SW_EN = w_p12v_pg_db ? 1'b1 : 1'b0 ; //w_p12v_pg_db ? 1'b1 : 1'b0 ; 2024-7-24

wire w_p0v8_sw_pg_dly10ms ; //2024-8-19 chg 50ms to 10ms 
edge_delay #(.CNTR_NBITS(3), .DELAY_MODE(1'b0)) edge_delay_p0v8_pg_50ms ( //DELAY_MODE =0 for rise 
  .clk         (clk_50m),
  .reset       (~pgd_aux_system),
  .cnt_size    (3'd5),
  .cnt_step    (t2ms_tick),
  .signal_in   (w_p0v8_sw0_pwrgd_db & 
                w_p0v8_sw1_pwrgd_db &
				w_p0v8_sw2_pwrgd_db &
				w_p0v8_sw3_pwrgd_db  ),     //this signal from 0 to 1
  .delay_output(w_p0v8_sw_pg_dly10ms)  
  );

assign o_CT_P1V25_SW_EN = w_p0v8_sw_pg_dly10ms ? 1'b1 : 1'b0 ;


wire w_p1v25_sw_pg_dly10ms ; //2024-8-19 chg 50ms to 10ms
edge_delay #(.CNTR_NBITS(3), .DELAY_MODE(1'b0)) edge_delay_p1v25_pg_50ms ( //DELAY_MODE =0 for rise 
  .clk         (clk_50m),
  .reset       (~pgd_aux_system),
  .cnt_size    (3'd5),
  .cnt_step    (t2ms_tick),
  .signal_in   (w_ct_p1v25_sw0_pg_db & 
                w_ct_p1v25_sw1_pg_db & 
				w_ct_p1v25_sw2_pg_db & 
				w_ct_p1v25_sw3_pg_db  ),     //this signal from 0 to 1
  .delay_output(w_p1v25_sw_pg_dly10ms)  
  );

assign o_P1V8_PLL_EN = w_p1v25_sw_pg_dly10ms ? 1'b1 : 1'b0 ;
assign o_P1V8_EN = w_p1v25_sw_pg_dly10ms ? 1'b1 : 1'b0 ;
///////////////////////////////////////////////////////////////////////////////////////////////////


assign o_P5V_VGA_EN = 1'b1 ;
assign o_P5V_RIGHTEAR_USB_EN = 1'b1 ;
assign o_P5V_STBY_USB_EN = 1'b1 ;



wire w_p0v8_sw_pg_dly100ms ; //2024-7-2 add 
edge_delay #(.CNTR_NBITS(6), .DELAY_MODE(1'b0)) edge_delay_p0v8_pg ( //DELAY_MODE =0 for rise 
  .clk         (clk_50m),
  .reset       (~pgd_aux_system),
  .cnt_size    (6'd50),
  .cnt_step    (t2ms_tick),
  .signal_in   (w_p0v8_sw0_pwrgd_db |
                w_p0v8_sw1_pwrgd_db |
                w_p0v8_sw2_pwrgd_db |
                w_p0v8_sw3_pwrgd_db  ),     //this signal from 0 to 1
  .delay_output(w_p0v8_sw_pg_dly100ms)  
  );

assign o_PAL_DB2000_PWRGD	= w_p0v8_sw_pg_dly100ms ? 1'b1 : 1'b0 ;//2024-7-2 add for debug //2024-7-10 add back

// assign o_PAL_DB2000_PWRGD	= 1'b1 ;//2024-5-15  
assign o_PAL_DB2000_1_PWRGD = w_pch_slp5_n & w_p12v_pg_db? 1'b1 : 1'b0 ; //2024-6-18 chg 1'b1 


assign o_PSU0_PSON_R = (w_p3v3_stby_pg_db & w_PSU0_PRSNT_R ? 1'b1 : 1'b0) & w_psu0_ctl ; //2024-5-20 add psu_ctl
assign o_PSU1_PSON_R = (w_p3v3_stby_pg_db & w_PSU1_PRSNT_R ? 1'b1 : 1'b0) & w_psu1_ctl ; //2024-5-20 add psu_ctl
assign o_PSU2_PSON_R = (w_p3v3_stby_pg_db & w_PSU2_PRSNT_R ? 1'b1 : 1'b0) & w_psu2_ctl ; //2024-5-20 add psu_ctl
assign o_PSU3_PSON_R = (w_p3v3_stby_pg_db & w_PSU3_PRSNT_R ? 1'b1 : 1'b0) & w_psu3_ctl ; //2024-5-20 add psu_ctl
assign o_PSU4_PSON_R = (w_p3v3_stby_pg_db & w_PSU4_PRSNT_R ? 1'b1 : 1'b0) & w_psu4_ctl ; //2024-5-20 add psu_ctl
assign o_PSU5_PSON_R = (w_p3v3_stby_pg_db & w_PSU5_PRSNT_R ? 1'b1 : 1'b0) & w_psu5_ctl ; //2024-5-20 add psu_ctl


assign o_PAL_HSC0_EN_R = ~w_psu0_pwrok_n_db & w_PSU0_PRSNT_R || //2024-5-14
                         ~w_psu1_pwrok_n_db & w_PSU1_PRSNT_R ||
                         ~w_psu2_pwrok_n_db & w_PSU2_PRSNT_R ||
                         ~w_psu3_pwrok_n_db & w_PSU3_PRSNT_R ||
                         ~w_psu4_pwrok_n_db & w_PSU4_PRSNT_R ||
                         ~w_psu5_pwrok_n_db & w_PSU5_PRSNT_R ? 1'b1 : 1'b0 ;
 
 
assign o_PAL_RAA_EN_N = (w_pch_slp5_n || i_ict_tp100 ) ? 1'b0 : 1'b1 ;//2024-6-22 del for debug //2024-6-26 add back
//2024-12-4 add || i_ict_tp100

//2024-6-26 del
// wire w_ps_pg_dly500ms ; //2024-6-22 add  
// edge_delay #(.CNTR_NBITS(4), .DELAY_MODE(1'b0)) edge_delay_ps_pg_dly500ms ( //DELAY_MODE =0 for rise 
  // .clk         (clk_50m),
  // .reset       (~pgd_aux_system),
  // .cnt_size    (4'd2),
  // .cnt_step    (t256ms_tick),
  // .signal_in   (~w_psu0_pwrok_n_db & w_PSU0_PRSNT_R || 
                // ~w_psu1_pwrok_n_db & w_PSU1_PRSNT_R ||
                // ~w_psu2_pwrok_n_db & w_PSU2_PRSNT_R ||
                // ~w_psu3_pwrok_n_db & w_PSU3_PRSNT_R ||
                // ~w_psu4_pwrok_n_db & w_PSU4_PRSNT_R ||
                // ~w_psu5_pwrok_n_db & w_PSU5_PRSNT_R ),     //this signal from 0 to 1
  // .delay_output(w_ps_pg_dly500ms)  
  // );

// assign o_PAL_RAA_EN_N = w_ps_pg_dly500ms ? 1'b0 : 1'b1 ;//2024-6-22 add //2024-6-26 del


 
//-------------------------------------------------------------------------------------------------
//NIC PWR SEQ
//-------------------------------------------------------------------------------------------------

wire w_retimer1_1p8_pg_dly5ms ;
wire w_retimer2_1p8_pg_dly5ms ;


wire w_slot1_thorttle_r; //bmc reg ctl
wire w_slot2_thorttle_r; //bmc reg ctl
wire w_slot3_thorttln_r; //bmc reg ctl
wire w_slot4_thorttle_r; //bmc reg ctl
wire w_slot5_thorttle_r; //bmc reg ctl
wire w_slot6_thorttle_r; //bmc reg ctl
wire w_slot7_thorttle_r; //bmc reg ctl
wire w_slot8_thorttle_r; //bmc reg ctl


edge_delay #(.CNTR_NBITS(4), .DELAY_MODE(1'b0)) edge_delay_retimer1_1p8_pg ( //DELAY_MODE =0 for rise 
  .clk         (clk_50m),
  .reset       (~pgd_aux_system),
  .cnt_size    (4'd5),
  .cnt_step    (t1ms_tick),
  .signal_in   (w_RETIMER1_1P8_PG),     //this signal from 0 to 1
  .delay_output(w_retimer1_1p8_pg_dly5ms)  
  );
  
edge_delay #(.CNTR_NBITS(4), .DELAY_MODE(1'b0)) edge_delay_retimer2_1p8_pg ( //DELAY_MODE =0 for rise 
  .clk         (clk_50m),
  .reset       (~pgd_aux_system),
  .cnt_size    (4'd5),
  .cnt_step    (t1ms_tick),
  .signal_in   (w_RETIMER2_1P8_PG),     //this signal from 0 to 1
  .delay_output(w_retimer2_1p8_pg_dly5ms)  
  );

assign o_PAL_RETIMER1_0P9_EN_R = w_retimer1_1p8_pg_dly5ms ? 1'b1 : 1'b0 ;
assign o_PAL_RETIMER3_0P9_EN_R = w_retimer1_1p8_pg_dly5ms ? 1'b1 : 1'b0 ;
assign o_PAL_RETIMER5_0P9_EN_R = w_retimer1_1p8_pg_dly5ms ? 1'b1 : 1'b0 ;
assign o_PAL_RETIMER7_0P9_EN_R = w_retimer1_1p8_pg_dly5ms ? 1'b1 : 1'b0 ;

assign o_PAL_RETIMER2_0P9_EN_R = w_retimer2_1p8_pg_dly5ms ? 1'b1 : 1'b0 ;
assign o_PAL_RETIMER4_0P9_EN_R = w_retimer2_1p8_pg_dly5ms ? 1'b1 : 1'b0 ;
assign o_PAL_RETIMER6_0P9_EN_R = w_retimer2_1p8_pg_dly5ms ? 1'b1 : 1'b0 ;
assign o_PAL_RETIMER8_0P9_EN_R = w_retimer2_1p8_pg_dly5ms ? 1'b1 : 1'b0 ;



assign o_NICSLOT_3P3V_EN_R = w_RETIMER1_0P9_PG & ~w_NIC_SLOT1_PRSNT_N ||
                             w_RETIMER2_0P9_PG & ~w_NIC_SLOT2_PRSNT_N ||
                             w_RETIMER3_0P9_PG & ~w_NIC_SLOT3_PRSNT_N ||
                             w_RETIMER4_0P9_PG & ~w_NIC_SLOT4_PRSNT_N ||
                             w_RETIMER5_0P9_PG & ~w_NIC_SLOT5_PRSNT_N ||
                             w_RETIMER6_0P9_PG & ~w_NIC_SLOT6_PRSNT_N ||
                             w_RETIMER7_0P9_PG & ~w_NIC_SLOT7_PRSNT_N ||
                             w_RETIMER8_0P9_PG & ~w_NIC_SLOT8_PRSNT_N ? 1'b1 : 1'b0 ;


// assign o_RETIMER_1P8V_EN_R =  w_pch_slp5_n & w_p12v_pg_db? 1'b1 : 1'b0 ;//w_pch_slp5_n //2024-6-4 chg to follow i_P12V_PG  

assign o_RETIMER_1P8V_EN_R =  w_pch_slp5_n & w_pg_p1v8_r_db? 1'b1 : 1'b0 ;//2024-6-26 chg to follow i_PG_P1V8_R  
//2024-7-10 add back

assign o_SLOT1_THORTTLE_R = w_slot1_thorttle_r;
assign o_SLOT2_THORTTLE_R = w_slot2_thorttle_r;
assign o_SLOT3_THORTTLN_R = w_slot3_thorttln_r;
assign o_SLOT4_THORTTLE_R = w_slot4_thorttle_r;
assign o_SLOT5_THORTTLE_R = w_slot5_thorttle_r;
assign o_SLOT6_THORTTLE_R = w_slot6_thorttle_r;
assign o_SLOT7_THORTTLE_R = w_slot7_thorttle_r;
assign o_SLOT8_THORTTLE_R = w_slot8_thorttle_r;

//-------------------------------------------------------------------------------------------------
//BP SIGNAL CONTROL 
//-------------------------------------------------------------------------------------------------

wire w_bptb_eep_wp_r  ; //bmc reg ctl
wire w_bp_eeprom_wp_r ; //bmc reg ctl

assign o_BP1_PWR_EN_R = ~i_BP1_PRSNT_N_R & w_pch_slp5_n ? 1'b1 : 1'b0 ;   
assign o_BP2_PWR_EN_R = ~i_BP2_PRSNT_N_R & w_pch_slp5_n ? 1'b1 : 1'b0 ;   

assign o_BPTB_EEP_WP_R  = w_bptb_eep_wp_r  ;
assign o_BP_EEPROM_WP_R = w_bp_eeprom_wp_r ; //2024-5-23 chg back 


//-------------------------------------------------------------------------------------------------
//UBB SIGNAL CONTROL 
//-------------------------------------------------------------------------------------------------
wire w_pwr_brake_n_r ; //bmc reg ctl
wire w_wp_hw_ctrl_n ; //bmc reg ctl

assign o_GPU_BASE_POWER_EN_R = i_GPU_BASE_FPGA_READY_R &
                               w_pch_slp5_n         &  //2024-5-16 chg o_PAL_HSC0_EN_R to w_pch_slp5_n
							   ~i_BASE_PRSNT_N_R ? 1'b1 : 1'b0 ;

// assign o_UBB_FPGA_PEX_RST_N_R = 1'b1 ;
assign o_GPU_BASE_STBY_EN_R = 1'b1 ;

assign o_PWR_BRAKE_N_R = w_pwr_brake_n_r ;
assign o_WP_HW_CTRL_N = w_wp_hw_ctrl_n ;



// wire w_fpga_ready_dly1ms;

// edge_delay #(.CNTR_NBITS(4), .DELAY_MODE(1'b0)) edge_delay_fpga_ready ( //DELAY_MODE =0 for rise 
  // .clk         (clk_50m),
  // .reset       (~pgd_aux_system),
  // .cnt_size    (4'd1),
  // .cnt_step    (t1ms_tick),
  // .signal_in   (i_GPU_BASE_FPGA_READY_R),     //this signal from 0 to 1
  // .delay_output(w_fpga_ready_dly1ms)  
  // );

wire w_cpld_pch_rsmrst_n_dly1ms ;

edge_delay #(.CNTR_NBITS(4), .DELAY_MODE(1'b0)) edge_delay_pch_rsmrst_n ( //DELAY_MODE =0 for rise 
  .clk         (clk_50m),
  .reset       (~pgd_aux_system),
  .cnt_size    (4'd1),
  .cnt_step    (t1ms_tick),
  .signal_in   (w_cpld_pch_rsmrst_n_r),     //this signal from 0 to 1
  .delay_output(w_cpld_pch_rsmrst_n_dly1ms)  
  );


assign o_UBB_FPGA_PEX_RST_N_R = w_cpld_pch_rsmrst_n_dly1ms ? 1'b1 : 1'b0 ; //2024-5-16 w_fpga_ready_dly1ms


wire w_gpu_base_pwr_gd_dly2ms;
edge_delay #(.CNTR_NBITS(4), .DELAY_MODE(1'b0)) edge_delay_gpu_base_pwr_gd ( //DELAY_MODE =0 for rise 
  .clk         (clk_50m),
  .reset       (~pgd_aux_system),
  .cnt_size    (4'd2),
  .cnt_step    (t1ms_tick),
  .signal_in   (i_GPU_BASE_PWR_GD_R),     //this signal from 0 to 1
  .delay_output(w_gpu_base_pwr_gd_dly2ms)  
  );


assign o_UBB_PEX_RST0_N_R = i_GPU_BASE_PWR_GD_R & w_rst_pltrst_n ? 1'b1 : 1'b0 ;  //2024-5-18
assign o_UBB_PEX_RST1_N_R = i_GPU_BASE_PWR_GD_R & w_rst_pltrst_n ? 1'b1 : 1'b0 ;  //2024-5-18
assign o_UBB_PEX_RST2_N_R = i_GPU_BASE_PWR_GD_R & w_rst_pltrst_n ? 1'b1 : 1'b0 ;  //2024-5-18




//-------------------------------------------------------------------------------------------------
//REDRIVER SIGNAL CONTROL 
//-------------------------------------------------------------------------------------------------

assign o_PAL_SAS_PWDN_R = 1'b0 ;
assign o_DS160_TX_PWDN1 = 1'b0 ;
assign o_DS160_TX_PWDN2 = 1'b0 ;
assign o_DS160_RX_PWDN1 = 1'b0 ;
assign o_DS160_RX_PWDN2 = 1'b0 ;

//-------------------------------------------------------------------------------------------------
//USB SIGNAL CONTROL 
//-------------------------------------------------------------------------------------------------

wire w_pal_usbmux_sel ; //bmc reg ctl

assign o_PAL_USBMUX_OE_N = 1'b0 ;
assign o_PAL_USBMUX_SEL = w_pal_usbmux_sel ;


//-------------------------------------------------------------------------------------------------
//RST SIGNAL CONTROL 
//-------------------------------------------------------------------------------------------------

wire [7:0] w_bmc_ctrl_nic_rst ;


assign o_SW0_PEX_PERST_N_R = w_rst_pltrst_n ;  //2024-6-22 del for debug //2024-6-26 add back
assign o_SW1_PEX_PERST_N_R = w_rst_pltrst_n ;  //2024-6-22 del for debug //2024-6-26 add back
assign o_SW2_PEX_PERST_N_R = w_rst_pltrst_n ;  //2024-6-22 del for debug //2024-6-26 add back
assign o_SW3_PEX_PERST_N_R = w_rst_pltrst_n ;  //2024-6-22 del for debug //2024-6-26 add back

//2024-6-26 del
// wire w_p0v8_pg_dly250ms ; //2024-6-22 add 
// edge_delay #(.CNTR_NBITS(4), .DELAY_MODE(1'b0)) edge_delay_p0v8_pg ( //DELAY_MODE =0 for rise 
  // .clk         (clk_50m),
  // .reset       (~pgd_aux_system),
  // .cnt_size    (4'd2),
  // .cnt_step    (t128ms_tick),
  // .signal_in   (w_p0v8_sw0_pwrgd_db &
                // w_p0v8_sw1_pwrgd_db &
                // w_p0v8_sw2_pwrgd_db &
                // w_p0v8_sw3_pwrgd_db  ),     //this signal from 0 to 1
  // .delay_output(w_p0v8_pg_dly250ms)  
  // );

// assign o_SW0_PEX_PERST_N_R = w_p0v8_pg_dly250ms ? 1'b1 : 1'b0 ;  //2024-6-22 add  //2024-6-26 del
// assign o_SW1_PEX_PERST_N_R = w_p0v8_pg_dly250ms ? 1'b1 : 1'b0 ;  //2024-6-22 add  //2024-6-26 del
// assign o_SW2_PEX_PERST_N_R = w_p0v8_pg_dly250ms ? 1'b1 : 1'b0 ;  //2024-6-22 add  //2024-6-26 del
// assign o_SW3_PEX_PERST_N_R = w_p0v8_pg_dly250ms ? 1'b1 : 1'b0 ;  //2024-6-22 add  //2024-6-26 del



assign o_SW0_NVME1_RST_R  = w_rst_pltrst_n ;
assign o_SW1_NVME1_RST_R  = w_rst_pltrst_n ;
assign o_SW2_NVME1_RST_R  = w_rst_pltrst_n ;
assign o_SW3_NVME1_RST_R  = w_rst_pltrst_n ;
// assign o_UBB_PEX_RST0_N_R = w_rst_pltrst_n ;
// assign o_UBB_PEX_RST1_N_R = w_rst_pltrst_n ;
// assign o_UBB_PEX_RST2_N_R = w_rst_pltrst_n ;

assign o_NIC1_PERST_N_R = w_rst_pltrst_n & w_bmc_ctrl_nic_rst[0] ; //2024-10-10 add & w_bmc_ctl_nic_rst
assign o_NIC2_PERST_N_R = w_rst_pltrst_n & w_bmc_ctrl_nic_rst[1] ; //2024-10-10 add 
assign o_NIC3_PERST_N_R = w_rst_pltrst_n & w_bmc_ctrl_nic_rst[2] ; //2024-10-10 add 
assign o_NIC4_PERST_N_R = w_rst_pltrst_n & w_bmc_ctrl_nic_rst[3] ; //2024-10-10 add 
assign o_NIC5_PERST_N_R = w_rst_pltrst_n & w_bmc_ctrl_nic_rst[4] ; //2024-10-10 add 
assign o_NIC6_PERST_N_R = w_rst_pltrst_n & w_bmc_ctrl_nic_rst[5] ; //2024-10-10 add 
assign o_NIC7_PERST_N_R = w_rst_pltrst_n & w_bmc_ctrl_nic_rst[6] ; //2024-10-10 add 
assign o_NIC8_PERST_N_R = w_rst_pltrst_n & w_bmc_ctrl_nic_rst[7] ; //2024-10-10 add 

//-------------------------------------------------------------------------------------------------
//BREATH LED //2024-5-16 add
//-------------------------------------------------------------------------------------------------

wire w_debug_led1 ;
breath_led debug_led1(
    .sys_clk     (clk_50m),  //时钟信号50Mhz
    .sys_rst_n   (pon_reset_n),  //复位信号
	.sys_pwr_ok  (w_p3v3_stby_pg_db), 

    .led         (o_debug_led1)     //LED
);

assign o_debug_led1 = w_debug_led1;



/**************************************************************************************************/
//-------------------------------------------------------------------------------------------------
//PWR SEQ End
//-------------------------------------------------------------------------------------------------
/**************************************************************************************************/


//-------------------------------------------------------------------------------------------------
//SW_CS_SEL
//-------------------------------------------------------------------------------------------------

// reg r_sw0_spi_cs_sel_r ;
// reg r_sw1_spi_cs_sel_r ;
// reg r_sw2_spi_cs_sel_r ;
// reg r_sw3_spi_cs_sel_r ;

reg r_sw0_spi_cs_sel_err_flag ;
reg r_sw1_spi_cs_sel_err_flag ;
reg r_sw2_spi_cs_sel_err_flag ;
reg r_sw3_spi_cs_sel_err_flag ;


//SW0
always@(posedge clk_50m or negedge pon_reset_n) begin
	if(~pon_reset_n) begin
		r_sw0_spi_cs_sel_r <= 1'b0;
		r_sw0_spi_cs_sel_err_flag <=1'b0;
	end
	else if((w_MCIO01A_CFG_N_R == 1'b0) & (w_MCIO01C_CFG_N_R == 1'b0) &&   
	        (w_MCIO02A_CFG_N_R == 1'b1) & (w_MCIO02C_CFG_N_R == 1'b1) )begin
		r_sw0_spi_cs_sel_r <= 1'b0;
		r_sw0_spi_cs_sel_err_flag <=1'b0;
	end
	else if((w_MCIO01A_CFG_N_R == 1'b0) & (w_MCIO01C_CFG_N_R == 1'b0) &&   
	        (w_MCIO02A_CFG_N_R == 1'b0) & (w_MCIO02C_CFG_N_R == 1'b0) )begin
		r_sw0_spi_cs_sel_r <= 1'b1;
		r_sw0_spi_cs_sel_err_flag <=1'b0;
	end
	else begin
		r_sw0_spi_cs_sel_r <= 1'b0;
		r_sw0_spi_cs_sel_err_flag <=1'b1;
	end
end

//SW1
always@(posedge clk_50m or negedge pon_reset_n) begin
	if(~pon_reset_n) begin
		r_sw1_spi_cs_sel_r <= 1'b0;
		r_sw1_spi_cs_sel_err_flag <=1'b0;
	end
	else if((w_MCIO11A_CFG_N_R == 1'b0) & (w_MCIO11C_CFG_N_R == 1'b0) &&   
	        (w_MCIO12A_CFG_N_R == 1'b1) & (w_MCIO12C_CFG_N_R == 1'b1) )begin
		r_sw1_spi_cs_sel_r <= 1'b0;
		r_sw1_spi_cs_sel_err_flag <=1'b0;
	end
	else if((w_MCIO11A_CFG_N_R == 1'b0) & (w_MCIO11C_CFG_N_R == 1'b0) &&   
	        (w_MCIO12A_CFG_N_R == 1'b0) & (w_MCIO12C_CFG_N_R == 1'b0) )begin
		r_sw1_spi_cs_sel_r <= 1'b1;
		r_sw1_spi_cs_sel_err_flag <=1'b0;
	end
	else begin
		r_sw1_spi_cs_sel_r <= 1'b0;
		r_sw1_spi_cs_sel_err_flag <=1'b1;
	end
end

//SW2
always@(posedge clk_50m or negedge pon_reset_n) begin
	if(~pon_reset_n) begin
		r_sw2_spi_cs_sel_r <= 1'b0;
		r_sw2_spi_cs_sel_err_flag <=1'b0;
	end
	else if((w_MCIO21A_CFG_N_R == 1'b0) & (w_MCIO21C_CFG_N_R == 1'b0) &&   
	        (w_MCIO22A_CFG_N_R == 1'b1) & (w_MCIO22C_CFG_N_R == 1'b1) )begin
		r_sw2_spi_cs_sel_r <= 1'b0;
		r_sw2_spi_cs_sel_err_flag <=1'b0;
	end
	else if((w_MCIO21A_CFG_N_R == 1'b0) & (w_MCIO21C_CFG_N_R == 1'b0) &&   
	        (w_MCIO22A_CFG_N_R == 1'b0) & (w_MCIO22C_CFG_N_R == 1'b0) )begin
		r_sw2_spi_cs_sel_r <= 1'b1;
		r_sw2_spi_cs_sel_err_flag <=1'b0;
	end
	else begin
		r_sw2_spi_cs_sel_r <= 1'b0;
		r_sw2_spi_cs_sel_err_flag <=1'b1;
	end
end

//SW3
always@(posedge clk_50m or negedge pon_reset_n) begin
	if(~pon_reset_n) begin
		r_sw3_spi_cs_sel_r <= 1'b0;
		r_sw3_spi_cs_sel_err_flag <=1'b0;
	end
	else if((w_MCIO31A_CFG_N_R == 1'b0) & (w_MCIO31C_CFG_N_R == 1'b0) &&   
	        (w_MCIO32A_CFG_N_R == 1'b1) & (w_MCIO32C_CFG_N_R == 1'b1) )begin
		r_sw3_spi_cs_sel_r <= 1'b0;
		r_sw3_spi_cs_sel_err_flag <=1'b0;
	end
	else if((w_MCIO31A_CFG_N_R == 1'b0) & (w_MCIO31C_CFG_N_R == 1'b0) &&   
	        (w_MCIO32A_CFG_N_R == 1'b0) & (w_MCIO32C_CFG_N_R == 1'b0) )begin
		r_sw3_spi_cs_sel_r <= 1'b1;
		r_sw3_spi_cs_sel_err_flag <=1'b0;
	end
	else begin
		r_sw3_spi_cs_sel_r <= 1'b0;
		r_sw3_spi_cs_sel_err_flag <=1'b1;
	end
end


// assign o_SW0_SPI_CS_SEL_R = r_sw0_spi_cs_sel_r ;
// assign o_SW1_SPI_CS_SEL_R = r_sw1_spi_cs_sel_r ;
// assign o_SW2_SPI_CS_SEL_R = r_sw2_spi_cs_sel_r ;
// assign o_SW3_SPI_CS_SEL_R = r_sw3_spi_cs_sel_r ;

wire [3:0] w_bmc_ctrl_sw_mode;
wire [3:0] w_bmc_ctrl_sw_mode_mask;//2024-9-12


assign o_SW0_SPI_CS_SEL_R = w_bmc_ctrl_sw_mode_mask[0] ? r_sw0_spi_cs_sel_r : w_bmc_ctrl_sw_mode[0]; //2024-9-9 add for debug 
assign o_SW1_SPI_CS_SEL_R = w_bmc_ctrl_sw_mode_mask[1] ? r_sw1_spi_cs_sel_r : w_bmc_ctrl_sw_mode[1]; //2024-9-9 add for debug 
assign o_SW2_SPI_CS_SEL_R = w_bmc_ctrl_sw_mode_mask[2] ? r_sw2_spi_cs_sel_r : w_bmc_ctrl_sw_mode[2]; //2024-9-9 add for debug 
assign o_SW3_SPI_CS_SEL_R = w_bmc_ctrl_sw_mode_mask[3] ? r_sw3_spi_cs_sel_r : w_bmc_ctrl_sw_mode[3]; //2024-9-9 add for debug 



/**************************************************************************************************/
//-------------------------------------------------------------------------------------------------
//FAN  Start
//-------------------------------------------------------------------------------------------------
/**************************************************************************************************/

//-------------------------------------------------------------------------------------------------
// for fan_type
//------------------------------------------------------------------------------------------------- 

wire [7:0] w_fan_type [FAN_NUM-1:0]  ;

//-------------------------------------------------------------------------------------------------
// for fan_pwm_tach
//------------------------------------------------------------------------------------------------- 

wire [FAN_NUM*2-1:0]  w_FAN_TACH_db        ;//26-33
wire [FAN_NUM-1:0]    w_fan_prsnt_n; //2024-4-20 add 
wire [FAN_NUM-1:0]    w_fan_pwm_out;
wire [7:0] w_fan_tach_reg [FAN_NUM*2-1:0] ;//bit width  fan num  2D array
wire [7:0] w_pwm_D_fan[FAN_NUM-1:0]    ; //  [7:0] w_pwm_D_fan[FAN_NUM-1:0] 
wire [7:0] w_BMC_pwe_D_fan[FAN_NUM-1:0] ;
wire [7:0] w_FAN_default_pwm;
wire [7:0] w_FAN_max_pwm;
wire [7:0] w_FAN_half_pwm;


reg [7:0]  r_pwm_D_fan_pre_limit[FAN_NUM-1:0] ; // 
reg [10:0] r_pwm_D_fan_limit[FAN_NUM-1:0]     ; // 
reg [7:0]  r_pwm_D_fan_limit_use[FAN_NUM-1:0] ; // 


assign w_FAN_default_pwm = 8'd102 ;//8'd102 ;//2024-4-20 chg to 60%  2024-5-21  8'd153   2024-5-31 8'd51 to 8'd102
assign w_FAN_max_pwm = 8'd204  ; //2023-8-30 add  80%
assign w_FAN_half_pwm = 8'd127  ;

wire [10:0] w_fan_tach_real [FAN_NUM*2-1:0] ;//bit width  fan num  2D array  //2023-7-12 chg to 10:0
wire [7:0]  w_fan_tach_real_h [FAN_NUM*2-1:0] ;//bit width  fan num  2D array
wire [2:0]  w_fan_tach_real_l [FAN_NUM*2-1:0] ;//bit width  fan num  2D array


PGM_DEBOUNCE #(.SIGCNT(30), .NBITS(2'b10), .ENABLE(1'b1)) db_fan_tach_p ( 
  .clk(clk_50m),
  .rst(~pon_reset_n),
  .timer_tick(t1us_tick),//t128us_tick 2023-6-29 chg to 1'b1  //2023-7-22 chg to t1us_tick
  .din({
        i_PAL_FAN1_TACH1 ,//
        i_PAL_FAN1_TACH2 ,//
        i_PAL_FAN2_TACH1 ,//
        i_PAL_FAN2_TACH2 ,//
        i_PAL_FAN3_TACH1 ,//
        i_PAL_FAN3_TACH2 ,//
        i_PAL_FAN4_TACH1 ,//
        i_PAL_FAN4_TACH2 ,//
        i_PAL_FAN5_TACH1 ,//
        i_PAL_FAN5_TACH2 ,//
        i_PAL_FAN6_TACH1 ,//
        i_PAL_FAN6_TACH2 ,//
        i_PAL_FAN7_TACH1 ,//
        i_PAL_FAN7_TACH2 ,//
        i_PAL_FAN8_TACH1 ,//
        i_PAL_FAN8_TACH2 ,//
        i_PAL_FAN9_TACH1 ,//
        i_PAL_FAN9_TACH2 ,//
        i_PAL_FAN10_TACH1,//
        i_PAL_FAN10_TACH2,//
        i_PAL_FAN11_TACH1,//
        i_PAL_FAN11_TACH2,//
        i_PAL_FAN12_TACH1,//
        i_PAL_FAN12_TACH2,//
        i_PAL_FAN13_TACH1,//
        i_PAL_FAN13_TACH2,//
        i_PAL_FAN14_TACH1,//
        i_PAL_FAN14_TACH2,//
        i_PAL_FAN15_TACH1,//
        i_PAL_FAN15_TACH2 //
  }),
  .dout({
        w_FAN_TACH_db[0]  ,
		w_FAN_TACH_db[1]  ,
		w_FAN_TACH_db[2]  ,
		w_FAN_TACH_db[3]  ,
		w_FAN_TACH_db[4]  ,
		w_FAN_TACH_db[5]  ,
		w_FAN_TACH_db[6]  ,
		w_FAN_TACH_db[7]  ,
		w_FAN_TACH_db[8]  ,
		w_FAN_TACH_db[9]  ,
		w_FAN_TACH_db[10] ,
		w_FAN_TACH_db[11] ,
		w_FAN_TACH_db[12] ,
		w_FAN_TACH_db[13] ,
        w_FAN_TACH_db[14] ,
        w_FAN_TACH_db[15] ,
        w_FAN_TACH_db[16] ,
        w_FAN_TACH_db[17] ,
		w_FAN_TACH_db[18] ,
        w_FAN_TACH_db[19] ,
        w_FAN_TACH_db[20] ,
        w_FAN_TACH_db[21] ,
		w_FAN_TACH_db[22] ,
        w_FAN_TACH_db[23] ,
        w_FAN_TACH_db[24] ,
        w_FAN_TACH_db[25] ,
		w_FAN_TACH_db[26] ,
        w_FAN_TACH_db[27] ,
        w_FAN_TACH_db[28] ,
        w_FAN_TACH_db[29]
  })
);

PGM_DEBOUNCE #(.SIGCNT(15), .NBITS(2'b10), .ENABLE(1'b1)) db_inst_fan_prsnt (
  .clk(clk_50m),
  .rst(~pon_reset_n),
  .timer_tick(t2ms_tick),
  .din({
	     w_PAL_FAN1_PRSNT_N    , //01
	     w_PAL_FAN2_PRSNT_N    , //02
         w_PAL_FAN3_PRSNT_N    , //03
		 w_PAL_FAN4_PRSNT_N    , //04
	     w_PAL_FAN5_PRSNT_N    , //05
         w_PAL_FAN6_PRSNT_N    , //06
		 w_PAL_FAN7_PRSNT_N    , //07
	     w_PAL_FAN8_PRSNT_N    , //08
         w_PAL_FAN9_PRSNT_N    , //09
		 w_PAL_FAN10_PRSNT_N   , //10
	     w_PAL_FAN11_PRSNT_N   , //11
         w_PAL_FAN12_PRSNT_N   , //12
		 w_PAL_FAN13_PRSNT_N   , //13
	     w_PAL_FAN14_PRSNT_N   , //14
         w_PAL_FAN15_PRSNT_N     //15

  }),
  .dout({
		 w_fan_prsnt_n[0]   , //01
		 w_fan_prsnt_n[1]   , //02
		 w_fan_prsnt_n[2]   , //03
		 w_fan_prsnt_n[3]   , //04
		 w_fan_prsnt_n[4]   , //05
		 w_fan_prsnt_n[5]   , //06
		 w_fan_prsnt_n[6]   , //07
		 w_fan_prsnt_n[7]   , //08
		 w_fan_prsnt_n[8]   , //09
		 w_fan_prsnt_n[9]   , //10
		 w_fan_prsnt_n[10]  , //11
		 w_fan_prsnt_n[11]  , //12
		 w_fan_prsnt_n[12]  , //13
		 w_fan_prsnt_n[13]  , //14
		 w_fan_prsnt_n[14]    //15

  })
);

//---------------------------------------------------------------------------------------------------
//FAN SPEED CONTROL  6056 fan max speed is 24000rad/min  FRONT= 24000rad/min  rear = 23200rad/min
//---------------------------------------------------------------------------------------------------
generate 
    genvar k;
    for(k=0;k<FAN_NUM;k=k+1) 
    begin
	
    //judge BMC die or not 
	always @(posedge clk_25m or negedge pon_reset_n) begin
        if( !pon_reset_n) begin
            r_pwm_D_fan_pre_limit[k] <= 8'd0 ;
        end
        else begin
            if(w_BMC_pwe_D_fan[k] == 8'b0) begin  
       		    r_pwm_D_fan_pre_limit[k] <=  w_FAN_default_pwm ;//40%
       		end
			else if(w_bmc_active0_n) begin //2024-5-21 debug
			    r_pwm_D_fan_pre_limit[k] <=  8'd255 ;   //w_FAN_half_pwm ; //50% 2024-5-31 add
			end
       		else 
       		    r_pwm_D_fan_pre_limit[k] <=  w_BMC_pwe_D_fan[k] ;
        end
    end						
	
	//fan max pwm set pre
    always @(posedge clk_25m or negedge pon_reset_n)
       begin
           if( !pon_reset_n)
           begin
                r_pwm_D_fan_limit[k] <= 11'd0 ;
           end
           else begin
                r_pwm_D_fan_limit[k] <= r_pwm_D_fan_pre_limit[k] << 3 ;  //w_FAN_max_pwm -->80%
           end
       end

    //fan max pwm set
	 always @(posedge clk_25m or negedge pon_reset_n)
       begin
           if( !pon_reset_n)
           begin
                r_pwm_D_fan_limit_use[k] <= 8'd0 ;
           end
           else begin
		        // if((r_pwm_D_fan_pre_limit[k] >= w_FAN_max_pwm) && (w_fan_type[k] == 8'd56))begin //2024-4-20 del for 100% pwm
			        // r_pwm_D_fan_limit_use[k] <= r_pwm_D_fan_limit[k] / 10 ; //w_FAN_max_pwm -->80%
			    // end
                // else 
				    r_pwm_D_fan_limit_use[k] <= r_pwm_D_fan_pre_limit[k] ;
           end
       end
	
	
//fan tach ==================================================    
        fan_pwm_tach fan_pwm_tach_m
        (
        .i_clk      ( clk_50m   ),
        .i_rst_n    ( pon_reset_n     ),
        .i_clk_0_4us( t6m25_clk ), //w_0_4us_clk  //2023-6-6 chg to t6m25_clk
        .i_clk_1s   ( t1hz_clk),
        .i_pwm_duty (r_pwm_D_fan_limit_use[k]), //2023-9-20  chg w_pwm_D_fan[k] to r_pwm_D_fan_limit_use
        .i_fan_tach0 (w_FAN_TACH_db[2*k]  ),
        .i_fan_tach1 (w_FAN_TACH_db[2*k+1]),
        .o_pwm_out       (w_fan_pwm_out[k]),
        .o_fan_tach0_reg (w_fan_tach_reg[2*k]  ),
        .o_fan_tach1_reg (w_fan_tach_reg[2*k+1]),
	    .o_fan_tach0_cnt (w_fan_tach_real[2*k]  ),
        .o_fan_tach1_cnt (w_fan_tach_real[2*k+1])
        );       
    end
endgenerate 

generate 
    genvar i;
    for(i=0;i<(FAN_NUM << 1);i=i+1) //FAN_NUM * 2
    begin
     	assign w_fan_tach_real_h[i][7:0] = w_fan_tach_real[i][10:3]; //2023-3-16 add 
        assign w_fan_tach_real_l[i][2:0] = w_fan_tach_real[i][2:0]  ; 
    end
endgenerate 

//fan pwm ==================================================

assign o_PAL_FAN1_PWM   = w_fan_pwm_out[0] ;
assign o_PAL_FAN2_PWM	= w_fan_pwm_out[1] ;
assign o_PAL_FAN3_PWM	= w_fan_pwm_out[2] ;
assign o_PAL_FAN4_PWM	= w_fan_pwm_out[3] ;
assign o_PAL_FAN5_PWM	= w_fan_pwm_out[4] ;
assign o_PAL_FAN6_PWM	= w_fan_pwm_out[5] ;
assign o_PAL_FAN7_PWM	= w_fan_pwm_out[6] ;
assign o_PAL_FAN8_PWM	= w_fan_pwm_out[7] ;
assign o_PAL_FAN9_PWM	= w_fan_pwm_out[8] ;
assign o_PAL_FAN10_PWM	= w_fan_pwm_out[9] ;
assign o_PAL_FAN11_PWM	= w_fan_pwm_out[10] ;
assign o_PAL_FAN12_PWM	= w_fan_pwm_out[11] ;
assign o_PAL_FAN13_PWM	= w_fan_pwm_out[12] ;
assign o_PAL_FAN14_PWM	= w_fan_pwm_out[13] ;
assign o_PAL_FAN15_PWM	= w_fan_pwm_out[14] ;


//-------------------------------------------------------------------------------------------------
// fan type  detect        2023-8-23 add   8038 single rotor fan    8056 dual rotor fan
//-------------------------------------------------------------------------------------------------

assign w_fan_type[0] = ((w_fan_tach_reg[0] != 0) && (w_fan_tach_reg[1] != 0)) ? 8'd56 : 
                   ((w_fan_tach_reg[0] != 0) && (w_fan_tach_reg[1] == 0)) ? 8'd38 : 8'd00; 
				   //single rotor fan    w_fan_tach_reg[2*k+1] == 0

assign w_fan_type[1] = ((w_fan_tach_reg[2] != 0) && (w_fan_tach_reg[3] != 0)) ? 8'd56 : 
                   ((w_fan_tach_reg[2] != 0) && (w_fan_tach_reg[3] == 0)) ? 8'd38 : 8'd00;
				   
assign w_fan_type[2] = ((w_fan_tach_reg[4] != 0) && (w_fan_tach_reg[5] != 0)) ? 8'd56 : 
                   ((w_fan_tach_reg[4] != 0) && (w_fan_tach_reg[5] == 0)) ? 8'd38 : 8'd00;

assign w_fan_type[3] = ((w_fan_tach_reg[6] != 0) && (w_fan_tach_reg[7] != 0)) ? 8'd56 : 
                   ((w_fan_tach_reg[6] != 0) && (w_fan_tach_reg[7] == 0)) ? 8'd38 : 8'd00;				   
				   
assign w_fan_type[4] = ((w_fan_tach_reg[8] != 0) && (w_fan_tach_reg[9] != 0)) ? 8'd56 : 
                   ((w_fan_tach_reg[8] != 0) && (w_fan_tach_reg[9] == 0)) ? 8'd38 : 8'd00;

assign w_fan_type[5] = ((w_fan_tach_reg[10] != 0) && (w_fan_tach_reg[11] != 0)) ? 8'd56 : 
                   ((w_fan_tach_reg[10] != 0) && (w_fan_tach_reg[11] == 0)) ? 8'd38 : 8'd00;		
				   
assign w_fan_type[6] = ((w_fan_tach_reg[12] != 0) && (w_fan_tach_reg[13] != 0)) ? 8'd56 : 
                   ((w_fan_tach_reg[12] != 0) && (w_fan_tach_reg[13] == 0)) ? 8'd38 : 8'd00;						   
				   
assign w_fan_type[7] = ((w_fan_tach_reg[14] != 0) && (w_fan_tach_reg[15] != 0)) ? 8'd56 : 
                   ((w_fan_tach_reg[14] != 0) && (w_fan_tach_reg[15] == 0)) ? 8'd38 : 8'd00;		

assign w_fan_type[8] = ((w_fan_tach_reg[16] != 0) && (w_fan_tach_reg[17] != 0)) ? 8'd56 : 
                   ((w_fan_tach_reg[16] != 0) && (w_fan_tach_reg[17] == 0)) ? 8'd38 : 8'd00;		

assign w_fan_type[9] = ((w_fan_tach_reg[18] != 0) && (w_fan_tach_reg[19] != 0)) ? 8'd56 : 
                   ((w_fan_tach_reg[18] != 0) && (w_fan_tach_reg[19] == 0)) ? 8'd38 : 8'd00;		

assign w_fan_type[10] = ((w_fan_tach_reg[20] != 0) && (w_fan_tach_reg[21] != 0)) ? 8'd56 : 
                   ((w_fan_tach_reg[20] != 0) && (w_fan_tach_reg[21] == 0)) ? 8'd38 : 8'd00;		

assign w_fan_type[11] = ((w_fan_tach_reg[22] != 0) && (w_fan_tach_reg[23] != 0)) ? 8'd56 : 
                   ((w_fan_tach_reg[22] != 0) && (w_fan_tach_reg[23] == 0)) ? 8'd38 : 8'd00;

assign w_fan_type[12] = ((w_fan_tach_reg[24] != 0) && (w_fan_tach_reg[25] != 0)) ? 8'd56 : 
                   ((w_fan_tach_reg[24] != 0) && (w_fan_tach_reg[25] == 0)) ? 8'd38 : 8'd00;

assign w_fan_type[13] = ((w_fan_tach_reg[26] != 0) && (w_fan_tach_reg[27] != 0)) ? 8'd56 : 
                   ((w_fan_tach_reg[26] != 0) && (w_fan_tach_reg[27] == 0)) ? 8'd38 : 8'd00;

assign w_fan_type[14] = ((w_fan_tach_reg[28] != 0) && (w_fan_tach_reg[29] != 0)) ? 8'd56 : 
                   ((w_fan_tach_reg[28] != 0) && (w_fan_tach_reg[29] == 0)) ? 8'd38 : 8'd00;


//-------------------------------------------------------------------------------------------------
//FAN  LED
//-------------------------------------------------------------------------------------------------
wire [FAN_NUM-1:0] w_pal_fan_led_g ;
wire [FAN_NUM-1:0] w_pal_fan_led_r ;


assign o_PAL_FAN1_LED_G  = w_pal_fan_led_g[0]  ;
assign o_PAL_FAN2_LED_G  = w_pal_fan_led_g[1]  ;
assign o_PAL_FAN3_LED_G  = w_pal_fan_led_g[2]  ;
assign o_PAL_FAN4_LED_G  = w_pal_fan_led_g[3]  ;
assign o_PAL_FAN5_LED_G  = w_pal_fan_led_g[4]  ;
assign o_PAL_FAN6_LED_G  = w_pal_fan_led_g[5]  ;
assign o_PAL_FAN7_LED_G  = w_pal_fan_led_g[6]  ;
assign o_PAL_FAN8_LED_G  = w_pal_fan_led_g[7]  ;
assign o_PAL_FAN9_LED_G  = w_pal_fan_led_g[8]  ;
assign o_PAL_FAN10_LED_G = w_pal_fan_led_g[9]  ;
assign o_PAL_FAN11_LED_G = w_pal_fan_led_g[10] ;
assign o_PAL_FAN12_LED_G = w_pal_fan_led_g[11] ;
assign o_PAL_FAN13_LED_G = w_pal_fan_led_g[12] ;
assign o_PAL_FAN14_LED_G = w_pal_fan_led_g[13] ;
assign o_PAL_FAN15_LED_G = w_pal_fan_led_g[14] ;

assign o_PAL_FAN1_LED_R  = w_pal_fan_led_r[0]  ;
assign o_PAL_FAN2_LED_R  = w_pal_fan_led_r[1]  ;
assign o_PAL_FAN3_LED_R  = w_pal_fan_led_r[2]  ;
assign o_PAL_FAN4_LED_R  = w_pal_fan_led_r[3]  ;
assign o_PAL_FAN5_LED_R  = w_pal_fan_led_r[4]  ;
assign o_PAL_FAN6_LED_R  = w_pal_fan_led_r[5]  ;
assign o_PAL_FAN7_LED_R  = w_pal_fan_led_r[6]  ;
assign o_PAL_FAN8_LED_R  = w_pal_fan_led_r[7]  ;
assign o_PAL_FAN9_LED_R  = w_pal_fan_led_r[8]  ;
assign o_PAL_FAN10_LED_R = w_pal_fan_led_r[9]  ;
assign o_PAL_FAN11_LED_R = w_pal_fan_led_r[10] ;
assign o_PAL_FAN12_LED_R = w_pal_fan_led_r[11] ;
assign o_PAL_FAN13_LED_R = w_pal_fan_led_r[12] ;
assign o_PAL_FAN14_LED_R = w_pal_fan_led_r[13] ;
assign o_PAL_FAN15_LED_R = w_pal_fan_led_r[14] ;



/**************************************************************************************************/
//-------------------------------------------------------------------------------------------------
//FAN  End
//-------------------------------------------------------------------------------------------------
/**************************************************************************************************/


/**************************************************************************************************/
//-------------------------------------------------------------------------------------------------
//I2C Update Start
//-------------------------------------------------------------------------------------------------
/**************************************************************************************************/
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
.i2c1_irqo	(						),
.i2c1_scl	(io_I2C9_CPLD_UPDATE_SCL),
.i2c1_sda	(io_I2C9_CPLD_UPDATE_SDA)

);
/**************************************************************************************************/
//-------------------------------------------------------------------------------------------------
//I2C Update End
//-------------------------------------------------------------------------------------------------
/**************************************************************************************************/

/**************************************************************************************************/
//-------------------------------------------------------------------------------------------------
// I2C RAM  Start
//-------------------------------------------------------------------------------------------------
/**************************************************************************************************/
wire [7:0] w_pcb_ver;
wire [7:0] w_board_id ;

wire [7:0] w_nic_pcb_ver;
wire [7:0] w_nic_board_id  ;

assign w_pcb_ver  = {5'b0,w_PCB_ID2,w_PCB_ID1,w_PCB_ID0};
assign w_board_id = {3'b00,w_BOARD_ID4,w_BOARD_ID3,w_BOARD_ID2,w_BOARD_ID1,w_BOARD_ID0};


assign w_nic_pcb_ver  = {5'b0,w_NIC_PCB_VER_ID2,w_NIC_PCB_VER_ID1,w_NIC_PCB_VER_ID0};
assign w_nic_board_id = {3'b00,w_NIC_BOARD_ID4,w_NIC_BOARD_ID3,w_NIC_BOARD_ID2,w_NIC_BOARD_ID1,w_NIC_BOARD_ID0};


bmc_cpld_i2c_ram #(
.DLY_LEN       (16)   //50MHz,330ns
)bmc_cpld_i2c_ram
(
.i_rst_n        (pon_reset_n            ) ,
.i_clk          (clk_25m	            ) ,
.i_1ms_clk      (t1ms_tick              ) ,	          //t1ms_tick
.i_rst_i2c_n    (1'b1                   ) ,
.i_scl          (i_I2C_CPLD_SCL         ) ,
.io_sda         (io_I2C_CPLD_SDA        ) ,

.i_product_id	                        (`PRODUCT_ID)          			    , //addr 0x0000
.i_vender_id	                        (`VENDER_ID)          			    , //addr 0x0001
.i_board_id		                        (w_board_id)          	            , //addr 0x0002
.i_pcb_version	                        (w_pcb_ver)                         , //addr 0x0003
.i_bom_id		                        (8'h00)      	                    , //addr 0x0004
.i_cpld_version	                        (`CPLD_VERSION)          		    , //addr 0x0005
.o_test_reg		                        (	  )                             , //addr 0x0006
.i_year			                        (`Year)                             , //addr 0x0007
.i_month		                        (`Month)                            , //addr 0x0008
.i_day			                        (`Day)                              , //addr 0x0009
.i_ncpin                                (w_nc_pin      )                    , //addr 0x000a bit0
.i_cpld_compa_version	                (8'h04)                             , //addr 0x000b //2025-2-8 add for 4port firmware
.i_cpld_debug_version	                (`DEBUG_VERSION)                    , //addr 0x000c


.i_nic_board_id		                    (w_nic_board_id)          	        , //addr 0x0010
.i_nic_pcb_version	                    (w_nic_pcb_ver)                     , //addr 0x0011

//I2C
.i_I2C1_ALERT_N_R	                    (i_I2C1_ALERT_N_R	 )              , //addr 0x0012  bit7
.i_I2C2_ALERT_N_R	                    (i_I2C2_ALERT_N_R	 )              , //addr 0x0012  bit6
.i_I2C9_9548_CH4_ALERT                  (i_I2C9_9548_CH4_ALERT)             , //addr 0x0012  bit5

//pol
.i_PAL_RAA_CFP_R                        (i_PAL_RAA_CFP_R    )               , //addr 0x0013  bit7
.i_p0v8_sw0_pwrgd_db                    (w_p0v8_sw0_pwrgd_db)               , //addr 0x0013  bit6
.i_p0v8_sw1_pwrgd_db                    (w_p0v8_sw1_pwrgd_db)               , //addr 0x0013  bit5
.i_p0v8_sw2_pwrgd_db                    (w_p0v8_sw2_pwrgd_db)               , //addr 0x0013  bit4
.i_p0v8_sw3_pwrgd_db                    (w_p0v8_sw3_pwrgd_db)               , //addr 0x0013  bit3
.i_PG_P5V0_R                            (i_PG_P5V0_R        )               , //addr 0x0013  bit2
.i_PG_P1V8_R	                        (w_pg_p1v8_r_db      )              , //addr 0x0013  bit1  //2024-6-29 add
.i_PG_P1V8_PLL_R                        (w_pg_p1v8_pll_r_db  )              , //addr 0x0013  bit0  //2024-6-29 add

.i_P5V_VGA_OC                           (i_P5V_VGA_OC         )             , //addr 0x0014  bit7
.i_P5V_RIGHTEAR_USB_OC                  (i_P5V_RIGHTEAR_USB_OC)             , //addr 0x0014  bit6
.i_P5V_STBY_USB_OC                      (i_P5V_STBY_USB_OC    )             , //addr 0x0014  bit5

.i_SMB_PSU0_ALERT_R                     (i_SMB_PSU0_ALERT_R)                , //addr 0x0015  bit7
.i_SMB_PSU1_ALERT_R                     (i_SMB_PSU1_ALERT_R)                , //addr 0x0015  bit6
.i_SMB_PSU2_ALERT_R                     (i_SMB_PSU2_ALERT_R)                , //addr 0x0015  bit5
.i_SMB_PSU3_ALERT_R                     (i_SMB_PSU3_ALERT_R)                , //addr 0x0015  bit4
.i_SMB_PSU4_ALERT_R                     (i_SMB_PSU4_ALERT_R)                , //addr 0x0015  bit3
.i_SMB_PSU5_ALERT_R                     (i_SMB_PSU5_ALERT_R)                , //addr 0x0015  bit2

//NIC
.i_NIC_3P3V_A_PG_R                      (i_NIC_3P3V_A_PG_R)                 , //addr 0x0016  bit7
.i_NIC_3P3V_B_PG_R                      (i_NIC_3P3V_B_PG_R)                 , //addr 0x0016  bit6

.i_RETIMER1_INT_N_R                     (i_RETIMER1_INT_N_R)                , //addr 0x0017  bit7
.i_RETIMER2_INT_N_R                     (i_RETIMER2_INT_N_R)                , //addr 0x0017  bit6
.i_RETIMER3_INT_N_R                     (i_RETIMER3_INT_N_R)                , //addr 0x0017  bit5
.i_RETIMER4_INT_N_R                     (i_RETIMER4_INT_N_R)                , //addr 0x0017  bit4
.i_RETIMER5_INT_N_R                     (i_RETIMER5_INT_N_R)                , //addr 0x0017  bit3
.i_RETIMER6_INT_N_R                     (i_RETIMER6_INT_N_R)                , //addr 0x0017  bit2
.i_RETIMER7_INT_N_R                     (i_RETIMER7_INT_N_R)                , //addr 0x0017  bit1
.i_RETIMER8_INT_N_R                     (i_RETIMER8_INT_N_R)                , //addr 0x0017  bit0

//BP
.i_BP1_PWR_PG_R                         (i_BP1_PWR_PG_R  )                  , //addr 0x0018  bit7
.i_BP2_PWR_PG_R                         (i_BP2_PWR_PG_R  )                  , //addr 0x0018  bit6
.i_BPTB_RE_DONE_R                       (i_BPTB_RE_DONE_R)                  , //addr 0x0018  bit5

//UBB
.i_GPU_BASE_PWR_GD_R	                (i_GPU_BASE_PWR_GD_R     )          , //addr 0x0019  bit7
.i_THERM_OVERT_N_R	                    (i_THERM_OVERT_N_R	     )          , //addr 0x0019  bit6
.i_FPGA_EROT_FATALERR_N_R               (i_FPGA_EROT_FATALERR_N_R)          , //addr 0x0019  bit5
.i_FPGA_OVERT_N_R                       (i_FPGA_OVERT_N_R        )          , //addr 0x0019  bit4
.i_GPU_BASE_HMC_READY_R                 (i_GPU_BASE_HMC_READY_R  )          , //addr 0x0019  bit3
.i_HMC_PRSNT_N_R                        (i_HMC_PRSNT_N_R         )          , //addr 0x0019  bit2
.i_BASE_PRSNT_N_R                       (i_BASE_PRSNT_N_R        )          , //addr 0x0019  bit1 //2024-5-29 ADD 

//REDRIVER
.i_PAL_SAS_ALL_DONE_N                   (i_PAL_SAS_ALL_DONE_N )             , //addr 0x001a  bit7
.i_DS160_TX_ALL_DONE_N                  (i_DS160_TX_ALL_DONE_N)             , //addr 0x001a  bit6
.i_DS160_RX_ALL_DONE_N                  (i_DS160_RX_ALL_DONE_N)             , //addr 0x001a  bit5

//BP
.o_bptb_eep_wp_r                        (w_bptb_eep_wp_r )                  , //addr 0x001b  bit7 //default 0
.o_bp_eeprom_wp_r                       (w_bp_eeprom_wp_r)                  , //addr 0x001b  bit6 //default 0

//NIC
.o_slot1_thorttle_r                     (w_slot1_thorttle_r)                , //addr 0x001c  bit7 //default 0
.o_slot2_thorttle_r                     (w_slot2_thorttle_r)                , //addr 0x001c  bit6 //default 0
.o_slot3_thorttln_r                     (w_slot3_thorttln_r)                , //addr 0x001c  bit5 //default 0
.o_slot4_thorttle_r                     (w_slot4_thorttle_r)                , //addr 0x001c  bit4 //default 0
.o_slot5_thorttle_r                     (w_slot5_thorttle_r)                , //addr 0x001c  bit3 //default 0
.o_slot6_thorttle_r                     (w_slot6_thorttle_r)                , //addr 0x001c  bit2 //default 0
.o_slot7_thorttle_r                     (w_slot7_thorttle_r)                , //addr 0x001c  bit1 //default 0
.o_slot8_thorttle_r                     (w_slot8_thorttle_r)                , //addr 0x001c  bit0 //default 0

//USB
.o_pal_usbmux_sel                       (w_pal_usbmux_sel)                  , //addr 0x001d  bit7 //default 0

//UBB
.o_pwr_brake_n_r                        (w_pwr_brake_n_r)                   , //addr 0x001e  bit7 //default 1
.o_wp_hw_ctrl_n                         (w_wp_hw_ctrl_n )                   , //addr 0x001e  bit6 //default 1

.i_sw0_spi_cs_sel_err_flag              (r_sw0_spi_cs_sel_err_flag)         , //addr 0x001f  bit7 
.i_sw1_spi_cs_sel_err_flag              (r_sw1_spi_cs_sel_err_flag)         , //addr 0x001f  bit6 
.i_sw2_spi_cs_sel_err_flag              (r_sw2_spi_cs_sel_err_flag)         , //addr 0x001f  bit5 
.i_sw3_spi_cs_sel_err_flag              (r_sw3_spi_cs_sel_err_flag)         , //addr 0x001f  bit4 

//165_data
.i_TEMP_ALERT_0_R                       (w_TEMP_ALERT_0_R)                  , //addr 0x0020  bit7 
.i_TEMP_ALERT_1_R                       (w_TEMP_ALERT_1_R)                  , //addr 0x0020  bit6 
.i_TEMP_ALERT_2_R                       (w_TEMP_ALERT_2_R)                  , //addr 0x0020  bit5 
.i_TEMP_ALERT_3_R                       (w_TEMP_ALERT_3_R)                  , //addr 0x0020  bit4 

.i_SW0_CLKREQ_N_R                       (w_SW0_CLKREQ_N_R  )                , //addr 0x0021  bit7 
.i_SW1_CLKREQ_N_R                       (w_SW1_CLKREQ_N_R  )                , //addr 0x0021  bit6 
.i_SW2_CLKREQ_N_R                       (w_SW2_CLKREQ_N_R  )                , //addr 0x0021  bit5 
.i_SW3_CLKREQ_N_R                       (w_SW3_CLKREQ_N_R  )                , //addr 0x0021  bit4 
.i_P0V8_SW0_ALERT_N                     (w_P0V8_SW0_ALERT_N)                , //addr 0x0021  bit3 
.i_P0V8_SW1_ALERT_N                     (w_P0V8_SW1_ALERT_N)                , //addr 0x0021  bit2 
.i_P0V8_SW2_ALERT_N                     (w_P0V8_SW2_ALERT_N)                , //addr 0x0021  bit1 
.i_P0V8_SW3_ALERT_N                     (w_P0V8_SW3_ALERT_N)                , //addr 0x0021  bit0 

.i_P0V8_SW0_VRHOT_N                     (w_P0V8_SW0_VRHOT_N)                , //addr 0x0022  bit7 
.i_P0V8_SW1_VRHOT_N                     (w_P0V8_SW1_VRHOT_N)                , //addr 0x0022  bit6 
.i_P0V8_SW2_VRHOT_N                     (w_P0V8_SW2_VRHOT_N)                , //addr 0x0022  bit5 
.i_P0V8_SW3_VRHOT_N                     (w_P0V8_SW3_VRHOT_N)                , //addr 0x0022  bit4 
.i_P0V8_SW0_FAULT_N                     (w_P0V8_SW0_FAULT_N)                , //addr 0x0022  bit3 
.i_P0V8_SW1_FAULT_N                     (w_P0V8_SW1_FAULT_N)                , //addr 0x0022  bit2 
.i_P0V8_SW2_FAULT_N                     (w_P0V8_SW2_FAULT_N)                , //addr 0x0022  bit1 
.i_P0V8_SW3_FAULT_N                     (w_P0V8_SW3_FAULT_N)                , //addr 0x0022  bit0 

.i_SLOT1_WAKE_N                         (w_SLOT1_WAKE_N)                    , //addr 0x0023  bit7 
.i_SLOT2_WAKE_N                         (w_SLOT2_WAKE_N)                    , //addr 0x0023  bit6 
.i_SLOT3_WAKE_N                         (w_SLOT3_WAKE_N)                    , //addr 0x0023  bit5 
.i_SLOT4_WAKE_N                         (w_SLOT4_WAKE_N)                    , //addr 0x0023  bit4 
.i_SLOT5_WAKE_N                         (w_SLOT5_WAKE_N)                    , //addr 0x0023  bit3 
.i_SLOT6_WAKE_N                         (w_SLOT6_WAKE_N)                    , //addr 0x0023  bit2 
.i_SLOT7_WAKE_N                         (w_SLOT7_WAKE_N)                    , //addr 0x0023  bit1 
.i_SLOT8_WAKE_N                         (w_SLOT8_WAKE_N)                    , //addr 0x0023  bit0 

.i_psu0_pwrok_n                         (w_psu0_pwrok_n_db)                 , //addr 0x0024 bit7  //2024-5-20 add
.i_psu1_pwrok_n                         (w_psu1_pwrok_n_db)                 , //addr 0x0024 bit6  //2024-5-20 add
.i_psu2_pwrok_n                         (w_psu2_pwrok_n_db)                 , //addr 0x0024 bit5  //2024-5-20 add
.i_psu3_pwrok_n                         (w_psu3_pwrok_n_db)                 , //addr 0x0024 bit4  //2024-5-20 add
.i_psu4_pwrok_n                         (w_psu4_pwrok_n_db)                 , //addr 0x0024 bit3  //2024-5-20 add
.i_psu5_pwrok_n                         (w_psu5_pwrok_n_db)                 , //addr 0x0024 bit2  //2024-5-20 add

.i_PSU0_PRSNT_R                         (w_PSU0_PRSNT_R   )                 , //addr 0x0025 bit7  //2024-5-20 add
.i_PSU1_PRSNT_R                         (w_PSU1_PRSNT_R   )                 , //addr 0x0025 bit6  //2024-5-20 add
.i_PSU2_PRSNT_R                         (w_PSU2_PRSNT_R   )                 , //addr 0x0025 bit5  //2024-5-20 add
.i_PSU3_PRSNT_R                         (w_PSU3_PRSNT_R   )                 , //addr 0x0025 bit4  //2024-5-20 add
.i_PSU4_PRSNT_R                         (w_PSU4_PRSNT_R   )                 , //addr 0x0025 bit3  //2024-5-20 add
.i_PSU5_PRSNT_R                         (w_PSU5_PRSNT_R   )                 , //addr 0x0025 bit2  //2024-5-20 add

.o_psu0_ctl                             (w_psu0_ctl       )                 , //addr 0x0026 bit7  //default 1
.o_psu1_ctl                             (w_psu1_ctl       )                 , //addr 0x0026 bit6  //default 1
.o_psu2_ctl                             (w_psu2_ctl       )                 , //addr 0x0026 bit5  //default 1
.o_psu3_ctl                             (w_psu3_ctl       )                 , //addr 0x0026 bit4  //default 1
.o_psu4_ctl                             (w_psu4_ctl       )                 , //addr 0x0026 bit3  //default 1
.o_psu5_ctl                             (w_psu5_ctl       )                 , //addr 0x0026 bit2  //default 1

.i_HSC0_PG                              (w_HSC0_PG           )              , //addr 0x0027  bit7  //2024-6-29 add
.i_P12V_PG                              (w_p12v_pg_db        )              , //addr 0x0027  bit6  //2024-6-29 add
.i_RETIMER1_1P8_PG                      (w_RETIMER1_1P8_PG   )              , //addr 0x0027  bit5  //2024-6-29 add
.i_RETIMER2_1P8_PG                      (w_RETIMER2_1P8_PG   )              , //addr 0x0027  bit4  //2024-6-29 add
.i_CT_P1V25_SW0_PG                      (w_ct_p1v25_sw0_pg_db)              , //addr 0x0027  bit3  //2024-6-29 add
.i_CT_P1V25_SW1_PG                      (w_ct_p1v25_sw1_pg_db)              , //addr 0x0027  bit2  //2024-6-29 add
.i_CT_P1V25_SW2_PG                      (w_ct_p1v25_sw2_pg_db)              , //addr 0x0027  bit1  //2024-6-29 add
.i_CT_P1V25_SW3_PG                      (w_ct_p1v25_sw3_pg_db)              , //addr 0x0027  bit0  //2024-6-29 add

.i_RETIMER1_0P9_PG                      (w_RETIMER1_0P9_PG   )              , //addr 0x0028  bit7  //2024-6-29 add
.i_RETIMER2_0P9_PG                      (w_RETIMER2_0P9_PG   )              , //addr 0x0028  bit6  //2024-6-29 add
.i_RETIMER3_0P9_PG                      (w_RETIMER3_0P9_PG   )              , //addr 0x0028  bit5  //2024-6-29 add
.i_RETIMER4_0P9_PG                      (w_RETIMER4_0P9_PG   )              , //addr 0x0028  bit4  //2024-6-29 add
.i_RETIMER5_0P9_PG                      (w_RETIMER5_0P9_PG   )              , //addr 0x0028  bit3  //2024-6-29 add
.i_RETIMER6_0P9_PG                      (w_RETIMER6_0P9_PG   )              , //addr 0x0028  bit2  //2024-6-29 add
.i_RETIMER7_0P9_PG                      (w_RETIMER7_0P9_PG   )              , //addr 0x0028  bit1  //2024-6-29 add
.i_RETIMER8_0P9_PG                      (w_RETIMER8_0P9_PG   )              , //addr 0x0028  bit0  //2024-6-29 add


.i_3V3IO_RSVD0_FFU_R                    (i_3V3IO_RSVD0_FFU_R)               , //addr 0x0029  bit7  //2024-8-16 add
.i_3V3IO_RSVD1_FFU_R                    (i_3V3IO_RSVD1_FFU_R)               , //addr 0x0029  bit6  //2024-8-16 add
.i_3V3IO_RSVD2_FFU_R                    (i_3V3IO_RSVD2_FFU_R)               , //addr 0x0029  bit5  //2024-8-16 add
.i_3V3IO_RSVD3_FFU_R                    (i_3V3IO_RSVD3_FFU_R)               , //addr 0x0029  bit4  //2024-8-16 add

.o_bmc_ctrl_sw_mode                     (w_bmc_ctrl_sw_mode)                , //addr 0x0033 bit3-0  //2024-9-9 add  //default 0000
.o_bmc_ctrl_sw_mode_mask                (w_bmc_ctrl_sw_mode_mask)           , //addr 0x0034 bit3-0  //2024-9-11 add //default 0000

.o_bmc_ctrl_nic_rst                     (w_bmc_ctrl_nic_rst)                , //addr 0x0035 bit7-0  //2024-10-10 add //default ff

//fan_prsnt--0x0101
.i_fan0_present_n                       (w_fan_prsnt_n[0])                  , //addr 0x0101 bit7 
.i_fan1_present_n                       (w_fan_prsnt_n[1])                  , //addr 0x0101 bit6  
.i_fan2_present_n                       (w_fan_prsnt_n[2])                  , //addr 0x0101 bit5  
.i_fan3_present_n                       (w_fan_prsnt_n[3])                  , //addr 0x0101 bit4  
.i_fan4_present_n                       (w_fan_prsnt_n[4])                  , //addr 0x0101 bit3 
.i_fan5_present_n                       (w_fan_prsnt_n[5])                  , //addr 0x0101 bit2  
.i_fan6_present_n                       (w_fan_prsnt_n[6])                  , //addr 0x0101 bit1  
.i_fan7_present_n                       (w_fan_prsnt_n[7])                  , //addr 0x0101 bit0  

.i_fan8_present_n                       (w_fan_prsnt_n[8])                  , //addr 0x0102 bit7
.i_fan9_present_n                       (w_fan_prsnt_n[9])                  , //addr 0x0102 bit6
.i_fan10_present_n                      (w_fan_prsnt_n[10])                 , //addr 0x0102 bit5 
.i_fan11_present_n                      (w_fan_prsnt_n[11])                 , //addr 0x0102 bit4 
.i_fan12_present_n                      (w_fan_prsnt_n[12])                 , //addr 0x0102 bit3 
.i_fan13_present_n                      (w_fan_prsnt_n[13])                 , //addr 0x0102 bit2 
.i_fan14_present_n                      (w_fan_prsnt_n[14])                 , //addr 0x0102 bit1
.i_fan15_present_n                      (1'b1)                              , //addr 0x0102 bit0

//FAN tach --0x0103~0x0122
.i_fan1_tach0_reg                       (w_fan_tach_reg[0][7:0] )           , //addr 0x0103
.i_fan1_tach1_reg                       (w_fan_tach_reg[1][7:0] )           , //addr 0x0104
.i_fan2_tach0_reg                       (w_fan_tach_reg[2][7:0] )           , //addr 0x0105
.i_fan2_tach1_reg                       (w_fan_tach_reg[3][7:0] )           , //addr 0x0106
.i_fan3_tach0_reg                       (w_fan_tach_reg[4][7:0] )           , //addr 0x0107
.i_fan3_tach1_reg                       (w_fan_tach_reg[5][7:0] )           , //addr 0x0108
.i_fan4_tach0_reg                       (w_fan_tach_reg[6][7:0] )           , //addr 0x0109
.i_fan4_tach1_reg                       (w_fan_tach_reg[7][7:0] )           , //addr 0x010a
.i_fan5_tach0_reg                       (w_fan_tach_reg[8][7:0] )           , //addr 0x010b
.i_fan5_tach1_reg                       (w_fan_tach_reg[9][7:0] )           , //addr 0x010c
.i_fan6_tach0_reg                       (w_fan_tach_reg[10][7:0])           , //addr 0x010d
.i_fan6_tach1_reg                       (w_fan_tach_reg[11][7:0])           , //addr 0x010e
.i_fan7_tach0_reg                       (w_fan_tach_reg[12][7:0])           , //addr 0x010f
.i_fan7_tach1_reg                       (w_fan_tach_reg[13][7:0])           , //addr 0x0110
.i_fan8_tach0_reg                       (w_fan_tach_reg[14][7:0])           , //addr 0x0111
.i_fan8_tach1_reg                       (w_fan_tach_reg[15][7:0])           , //addr 0x0112
.i_fan9_tach0_reg                       (w_fan_tach_reg[16][7:0])           , //addr 0x0113
.i_fan9_tach1_reg                       (w_fan_tach_reg[17][7:0])           , //addr 0x0114
.i_fan10_tach0_reg                      (w_fan_tach_reg[18][7:0])           , //addr 0x0115
.i_fan10_tach1_reg                      (w_fan_tach_reg[19][7:0])           , //addr 0x0116
.i_fan11_tach0_reg                      (w_fan_tach_reg[20][7:0])           , //addr 0x0117
.i_fan11_tach1_reg                      (w_fan_tach_reg[21][7:0])           , //addr 0x0118
.i_fan12_tach0_reg                      (w_fan_tach_reg[22][7:0])           , //addr 0x0119
.i_fan12_tach1_reg                      (w_fan_tach_reg[23][7:0])           , //addr 0x011a
.i_fan13_tach0_reg                      (w_fan_tach_reg[24][7:0])           , //addr 0x011b
.i_fan13_tach1_reg                      (w_fan_tach_reg[25][7:0])           , //addr 0x011c
.i_fan14_tach0_reg                      (w_fan_tach_reg[26][7:0])           , //addr 0x011d
.i_fan14_tach1_reg                      (w_fan_tach_reg[27][7:0])           , //addr 0x011e
.i_fan15_tach0_reg                      (w_fan_tach_reg[28][7:0])           , //addr 0x011f
.i_fan15_tach1_reg                      (w_fan_tach_reg[29][7:0])           , //addr 0x0120
.i_fan16_tach0_reg                      (8'hff)                             , //addr 0x0121
.i_fan16_tach1_reg                      (8'hff)                             , //addr 0x0122

//FAN PWM--0x0123~0x0132
.o_pwm_bmc_fan1                         (w_BMC_pwe_D_fan[0][7:0])           , //addr 0x0123 
.o_pwm_bmc_fan2                         (w_BMC_pwe_D_fan[1][7:0])           , //addr 0x0124 
.o_pwm_bmc_fan3                         (w_BMC_pwe_D_fan[2][7:0])           , //addr 0x0125 
.o_pwm_bmc_fan4                         (w_BMC_pwe_D_fan[3][7:0])           , //addr 0x0126 
.o_pwm_bmc_fan5                         (w_BMC_pwe_D_fan[4][7:0])           , //addr 0x0127 
.o_pwm_bmc_fan6                         (w_BMC_pwe_D_fan[5][7:0])           , //addr 0x0128 
.o_pwm_bmc_fan7                         (w_BMC_pwe_D_fan[6][7:0])           , //addr 0x0129 
.o_pwm_bmc_fan8                         (w_BMC_pwe_D_fan[7][7:0])           , //addr 0x012a 
.o_pwm_bmc_fan9                         (w_BMC_pwe_D_fan[8][7:0])           , //addr 0x012b 
.o_pwm_bmc_fan10                        (w_BMC_pwe_D_fan[9][7:0])           , //addr 0x012c
.o_pwm_bmc_fan11                        (w_BMC_pwe_D_fan[10][7:0])          , //addr 0x012d 
.o_pwm_bmc_fan12                        (w_BMC_pwe_D_fan[11][7:0])          , //addr 0x012e 
.o_pwm_bmc_fan13                        (w_BMC_pwe_D_fan[12][7:0])          , //addr 0x012f 
.o_pwm_bmc_fan14                        (w_BMC_pwe_D_fan[13][7:0])          , //addr 0x0130 
.o_pwm_bmc_fan15                        (w_BMC_pwe_D_fan[14][7:0])          , //addr 0x0131 
.o_pwm_bmc_fan16                        (                )                  , //addr 0x0132 

//FAN real tach --0x0133~0x013a
.i_fan1_tach0_real_h                    (w_fan_tach_real_h[0][7:0])         , //addr 0x0133
.i_fan1_tach0_real_l                    (w_fan_tach_real_l[0][2:0]     )    , //addr 0x0134
.i_fan1_tach1_real_h                    (w_fan_tach_real_h[1][7:0])         , //addr 0x0135
.i_fan1_tach1_real_l                    (w_fan_tach_real_l[1][2:0]     )    , //addr 0x0136
.i_fan2_tach0_real_h                    (w_fan_tach_real_h[2][7:0])         , //addr 0x0137
.i_fan2_tach0_real_l                    (w_fan_tach_real_l[2][2:0]     )    , //addr 0x0138
.i_fan2_tach1_real_h                    (w_fan_tach_real_h[3][7:0])         , //addr 0x0139
.i_fan2_tach1_real_l                    (w_fan_tach_real_l[3][2:0]     )    , //addr 0x013a

//FAN real tach --0x013b~0x0142
.i_fan3_tach0_real_h                    (w_fan_tach_real_h[4][7:0])         , //addr 0x013b
.i_fan3_tach0_real_l                    (w_fan_tach_real_l[4][2:0]     )    , //addr 0x013c
.i_fan3_tach1_real_h                    (w_fan_tach_real_h[5][7:0])         , //addr 0x013d
.i_fan3_tach1_real_l                    (w_fan_tach_real_l[5][2:0]     )    , //addr 0x013e
.i_fan4_tach0_real_h                    (w_fan_tach_real_h[6][7:0])         , //addr 0x013f
.i_fan4_tach0_real_l                    (w_fan_tach_real_l[6][2:0]     )    , //addr 0x0140
.i_fan4_tach1_real_h                    (w_fan_tach_real_h[7][7:0])         , //addr 0x0141
.i_fan4_tach1_real_l                    (w_fan_tach_real_l[7][2:0]     )    , //addr 0x0142

//FAN real tach --0x0143~0x014a
.i_fan5_tach0_real_h                    (w_fan_tach_real_h[8][7:0] )        , //addr 0x0143  
.i_fan5_tach0_real_l                    (w_fan_tach_real_l[8][2:0]      )   , //addr 0x0144
.i_fan5_tach1_real_h                    (w_fan_tach_real_h[9][7:0] )        , //addr 0x0145 
.i_fan5_tach1_real_l                    (w_fan_tach_real_l[9][2:0]      )   , //addr 0x0146 
.i_fan6_tach0_real_h                    (w_fan_tach_real_h[10][7:0])        , //addr 0x0147
.i_fan6_tach0_real_l                    (w_fan_tach_real_l[10][2:0]     )   , //addr 0x0148
.i_fan6_tach1_real_h                    (w_fan_tach_real_h[11][7:0])        , //addr 0x0149 
.i_fan6_tach1_real_l                    (w_fan_tach_real_l[11][2:0]     )   , //addr 0x014a 

//FAN real tach --0x014b~0x0152
.i_fan7_tach0_real_h                    (w_fan_tach_real_h[12][7:0])        , //addr 0x014b  
.i_fan7_tach0_real_l                    (w_fan_tach_real_l[12][2:0]     )   , //addr 0x014c
.i_fan7_tach1_real_h                    (w_fan_tach_real_h[13][7:0])        , //addr 0x014d 
.i_fan7_tach1_real_l                    (w_fan_tach_real_l[13][2:0]     )   , //addr 0x014e 
.i_fan8_tach0_real_h                    (w_fan_tach_real_h[14][7:0])        , //addr 0x014f
.i_fan8_tach0_real_l                    (w_fan_tach_real_l[14][2:0]     )   , //addr 0x0150
.i_fan8_tach1_real_h                    (w_fan_tach_real_h[15][7:0])        , //addr 0x0151 
.i_fan8_tach1_real_l                    (w_fan_tach_real_l[15][2:0]     )   , //addr 0x0152 

//FAN real tach --0x0153~0x015a
.i_fan9_tach0_real_h                    (w_fan_tach_real_h[16][7:0])        , //addr 0x0153  
.i_fan9_tach0_real_l                    (w_fan_tach_real_l[16][2:0]     )   , //addr 0x0154
.i_fan9_tach1_real_h                    (w_fan_tach_real_h[17][7:0])        , //addr 0x0155 
.i_fan9_tach1_real_l                    (w_fan_tach_real_l[17][2:0]     )   , //addr 0x0156 
.i_fan10_tach0_real_h                   (w_fan_tach_real_h[18][7:0])        , //addr 0x0157
.i_fan10_tach0_real_l                   (w_fan_tach_real_l[18][2:0]     )   , //addr 0x0158
.i_fan10_tach1_real_h                   (w_fan_tach_real_h[19][7:0])        , //addr 0x0159 
.i_fan10_tach1_real_l                   (w_fan_tach_real_l[19][2:0]     )   , //addr 0x015a 

//FAN real tach --0x015b~0x0162
.i_fan11_tach0_real_h                   (w_fan_tach_real_h[20][7:0])        , //addr 0x015b  
.i_fan11_tach0_real_l                   (w_fan_tach_real_l[20][2:0]     )   , //addr 0x015c
.i_fan11_tach1_real_h                   (w_fan_tach_real_h[21][7:0])        , //addr 0x015d 
.i_fan11_tach1_real_l                   (w_fan_tach_real_l[21][2:0]     )   , //addr 0x015e 
.i_fan12_tach0_real_h                   (w_fan_tach_real_h[22][7:0])        , //addr 0x015f
.i_fan12_tach0_real_l                   (w_fan_tach_real_l[22][2:0]     )   , //addr 0x0160
.i_fan12_tach1_real_h                   (w_fan_tach_real_h[23][7:0])        , //addr 0x0161 
.i_fan12_tach1_real_l                   (w_fan_tach_real_l[23][2:0]     )   , //addr 0x0162 

//FAN real tach --0x0163~0x016a
.i_fan13_tach0_real_h                   (w_fan_tach_real_h[24][7:0])        , //addr 0x0163  
.i_fan13_tach0_real_l                   (w_fan_tach_real_l[24][2:0]     )   , //addr 0x0164
.i_fan13_tach1_real_h                   (w_fan_tach_real_h[25][7:0])        , //addr 0x0165 
.i_fan13_tach1_real_l                   (w_fan_tach_real_l[25][2:0]     )   , //addr 0x0166 
.i_fan14_tach0_real_h                   (w_fan_tach_real_h[26][7:0])        , //addr 0x0167
.i_fan14_tach0_real_l                   (w_fan_tach_real_l[26][2:0]     )   , //addr 0x0168
.i_fan14_tach1_real_h                   (w_fan_tach_real_h[27][7:0])        , //addr 0x0169 
.i_fan14_tach1_real_l                   (w_fan_tach_real_l[27][2:0]     )   , //addr 0x016a 

//FAN real tach --0x016b~0x0172
.i_fan15_tach0_real_h                   (w_fan_tach_real_h[28][7:0])        , //addr 0x016b  
.i_fan15_tach0_real_l                   (w_fan_tach_real_l[28][2:0]     )   , //addr 0x016c
.i_fan15_tach1_real_h                   (w_fan_tach_real_h[29][7:0])        , //addr 0x016d 
.i_fan15_tach1_real_l                   (w_fan_tach_real_l[29][2:0]     )   , //addr 0x016e 
.i_fan16_tach0_real_h                   (8'h00)                             , //addr 0x016f
.i_fan16_tach0_real_l                   (3'b000    )                        , //addr 0x0170
.i_fan16_tach1_real_h                   (8'h00)                             , //addr 0x0171 
.i_fan16_tach1_real_l                   (3'b000    )                        , //addr 0x0172 

//FAN TYPE--0x0173~0x0182
.i_fan1_type                            (w_fan_type[0]  )                   , //addr 0x0173
.i_fan2_type                            (w_fan_type[1]  )                   , //addr 0x0174
.i_fan3_type                            (w_fan_type[2]  )                   , //addr 0x0175
.i_fan4_type                            (w_fan_type[3]  )                   , //addr 0x0176
.i_fan5_type                            (w_fan_type[4]  )                   , //addr 0x0177
.i_fan6_type                            (w_fan_type[5]  )                   , //addr 0x0178
.i_fan7_type                            (w_fan_type[6]  )                   , //addr 0x0179
.i_fan8_type                            (w_fan_type[7]  )                   , //addr 0x017a
.i_fan9_type                            (w_fan_type[8]  )                   , //addr 0x017b
.i_fan10_type                           (w_fan_type[9]  )                   , //addr 0x017c
.i_fan11_type                           (w_fan_type[10]  )                  , //addr 0x017d
.i_fan12_type                           (w_fan_type[11]  )                  , //addr 0x017e
.i_fan13_type                           (w_fan_type[12]  )                  , //addr 0x017f
.i_fan14_type                           (w_fan_type[13]  )                  , //addr 0x0180
.i_fan15_type                           (w_fan_type[14]  )                  , //addr 0x0181
.i_fan16_type                           (8'hff  )                           , //addr 0x0182

//FAN LED--0x0183~0x0186
.o_fan1_led_g                           (w_pal_fan_led_g[0] )               , //addr 0x0183 bit7 //default 0
.o_fan2_led_g                           (w_pal_fan_led_g[1] )               , //addr 0x0183 bit6 //default 0
.o_fan3_led_g                           (w_pal_fan_led_g[2] )               , //addr 0x0183 bit5 //default 0
.o_fan4_led_g                           (w_pal_fan_led_g[3] )               , //addr 0x0183 bit4 //default 0
.o_fan5_led_g                           (w_pal_fan_led_g[4] )               , //addr 0x0183 bit3 //default 0
.o_fan6_led_g                           (w_pal_fan_led_g[5] )               , //addr 0x0183 bit2 //default 0
.o_fan7_led_g                           (w_pal_fan_led_g[6] )               , //addr 0x0183 bit1 //default 0
.o_fan8_led_g                           (w_pal_fan_led_g[7] )               , //addr 0x0183 bit0 //default 0

.o_fan9_led_g                           (w_pal_fan_led_g[8] )               , //addr 0x0184 bit7 //default 0
.o_fan10_led_g                          (w_pal_fan_led_g[9] )               , //addr 0x0184 bit6 //default 0
.o_fan11_led_g                          (w_pal_fan_led_g[10])               , //addr 0x0184 bit5 //default 0
.o_fan12_led_g                          (w_pal_fan_led_g[11])               , //addr 0x0184 bit4 //default 0
.o_fan13_led_g                          (w_pal_fan_led_g[12])               , //addr 0x0184 bit3 //default 0
.o_fan14_led_g                          (w_pal_fan_led_g[13])               , //addr 0x0184 bit2 //default 0
.o_fan15_led_g                          (w_pal_fan_led_g[14])               , //addr 0x0184 bit1 //default 0
.o_fan16_led_g                          (                   )               , //addr 0x0184 bit0 //default 0

.o_fan1_led_r                           (w_pal_fan_led_r[0] )               , //addr 0x0185 bit7 //default 1
.o_fan2_led_r                           (w_pal_fan_led_r[1] )               , //addr 0x0185 bit6 //default 1
.o_fan3_led_r                           (w_pal_fan_led_r[2] )               , //addr 0x0185 bit5 //default 1
.o_fan4_led_r                           (w_pal_fan_led_r[3] )               , //addr 0x0185 bit4 //default 1
.o_fan5_led_r                           (w_pal_fan_led_r[4] )               , //addr 0x0185 bit3 //default 1
.o_fan6_led_r                           (w_pal_fan_led_r[5] )               , //addr 0x0185 bit2 //default 1
.o_fan7_led_r                           (w_pal_fan_led_r[6] )               , //addr 0x0185 bit1 //default 1
.o_fan8_led_r                           (w_pal_fan_led_r[7] )               , //addr 0x0185 bit0 //default 1

.o_fan9_led_r                           (w_pal_fan_led_r[8] )               , //addr 0x0186 bit7 //default 1
.o_fan10_led_r                          (w_pal_fan_led_r[9] )               , //addr 0x0186 bit6 //default 1
.o_fan11_led_r                          (w_pal_fan_led_r[10])               , //addr 0x0186 bit5 //default 1
.o_fan12_led_r                          (w_pal_fan_led_r[11])               , //addr 0x0186 bit4 //default 1
.o_fan13_led_r                          (w_pal_fan_led_r[12])               , //addr 0x0186 bit3 //default 1
.o_fan14_led_r                          (w_pal_fan_led_r[13])               , //addr 0x0186 bit2 //default 1
.o_fan15_led_r                          (w_pal_fan_led_r[14])               , //addr 0x0186 bit1 //default 1
.o_fan16_led_r                          (                   )                 //addr 0x0186 bit0 //default 1


);

/**************************************************************************************************/
//-------------------------------------------------------------------------------------------------
// I2C RAM  Stop
//-------------------------------------------------------------------------------------------------
/**************************************************************************************************/










endmodule