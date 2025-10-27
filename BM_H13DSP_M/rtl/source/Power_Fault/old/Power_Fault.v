
`timescale 1ns / 1ps

module Power_Fault 
(
input  i_clk,
input  i_rst_n,
input  i_20mSEC,

input  i_delay_int_ign,

input  i_clr_flag,

input  i_FM_SLPS3_N,
input  i_FM_SLPS4_N,
input  i_RST_PLTRST_N,
input  i_PWRGD_P1V05_PCH_STBY,

input  i_p12v_stby_droop           ,
input  i_p3v3_stby_pwr_flt         ,
input  i_p12v_droop                ,
input  i_p12v_pwr_flt              , 
input  i_aux_pwr_flt               ,
input  i_p5v_stby_pwr_flt          ,          
input  i_p1v2_stby_pwr_flt         ,        
input  i_p1v8_stby_pwr_flt         ,         
input  i_cmu_p5v0_stby_pwr_flt	   ,
input  i_cmu_p3v3_stby_pwr_flt	   ,
input  i_cmu_p3v3_stby_rgm_pwr_flt ,
input  i_cmu_p2v5_stby_pwr_flt	   ,
input  i_cmu_p1v8_stby_pwr_flt	   ,
input  i_cmu_p1v2_stby_pwr_flt	   ,
input  i_cmu_p1v0_stby_pwr_flt	   ,
input  i_pch_pwr_flt               ,
input  i_pch_pvnn_pwr_flt          ,
input  i_pch_p1v05_pwr_flt         ,
input  i_p5v_pwr_flt               ,
input  i_cpu0_mem_pwr_flt          ,
input  i_Cpu0PvppHbmFlt            ,
input  i_Cpu0PvccfaEhvFlt          ,
input  i_Cpu0PvccfaFivrFlt         ,
input  i_Cpu0PvccInfaonFlt         ,
input  i_Cpu0PvnnMainFlt           ,
input  i_Cpu0PvccinFlt             ,
input  i_Cpu0PvccdHvFlt            ,
input  i_cpu1_mem_pwr_flt          ,
input  i_Cpu1PvppHbmFlt            ,
input  i_Cpu1PvccfaEhvFlt          ,
input  i_Cpu1PvccfaFivrFlt         ,
input  i_Cpu1PvccInfaonFlt         ,
input  i_Cpu1PvnnMainFlt           ,
input  i_Cpu1PvccinFlt             ,
input  i_Cpu1PvccdHvFlt            ,
input  i_cpu0Mem_ab_pwr_flt        ,
input  i_cpu0Mem_cd_pwr_flt        ,
input  i_cpu0Mem_ef_pwr_flt        ,
input  i_cpu0Mem_gh_pwr_flt        ,
input  i_cpu1Mem_ab_pwr_flt        ,
input  i_cpu1Mem_cd_pwr_flt        ,
input  i_cpu1Mem_ef_pwr_flt        ,
input  i_cpu1Mem_gh_pwr_flt        ,
output [7:0] o_pwr_flt_code              

);
//////////////////////////////////////////////////////////////////////////////////
// Parameters
//////////////////////////////////////////////////////////////////////////////////
localparam LOW     = 1'b0;
localparam HIGH    = 1'b1;
localparam Z       = 1'bz;
localparam T10S    = 500;  //SIM 10 (200ms)
localparam T5S     = 250;  //SIM 5  (100ms)
//////////////////////////////////////////////////////////////////////////////////
// Internal Signals
//////////////////////////////////////////////////////////////////////////////////

wire w_fault_all;
wire w_fault_all_pos;
wire w_delay_err_int;
//Power on delay
wire w_20mSEC_pos;
reg  [8:0]r_cnt_delay_AC;         //Max 500*20ms = 10s;
reg  [7:0]r_cnt_delay_DC;         //Max 250*20ms = 5s;
reg  r_AC_delay;
reg  r_DC_delay;
reg  r_pwr_fail_flag;
reg  [7:0] r_timeout_code;


assign w_delay_err_int = r_AC_delay | r_DC_delay;


assign w_fault_all = i_p12v_stby_droop           |
                     i_p3v3_stby_pwr_flt         |
                     i_p12v_droop                |
                     i_p12v_pwr_flt              |
					 i_aux_pwr_flt               |
                     i_p5v_stby_pwr_flt          |
					 i_p1v2_stby_pwr_flt         |
					 i_p1v8_stby_pwr_flt         |
					 i_cmu_p5v0_stby_pwr_flt	 |
					 i_cmu_p3v3_stby_pwr_flt	 |
					 i_cmu_p3v3_stby_rgm_pwr_flt |
					 i_cmu_p2v5_stby_pwr_flt	 |
					 i_cmu_p1v8_stby_pwr_flt	 |
					 i_cmu_p1v2_stby_pwr_flt	 |
					 i_cmu_p1v0_stby_pwr_flt	 |
					 i_pch_pwr_flt               |
					 i_pch_pvnn_pwr_flt          |
					 i_pch_p1v05_pwr_flt         |
					 i_p5v_pwr_flt               |
					 i_cpu0_mem_pwr_flt          |
					 i_Cpu0PvppHbmFlt            |
					 i_Cpu0PvccfaEhvFlt          |
					 i_Cpu0PvccfaFivrFlt         |
					 i_Cpu0PvccInfaonFlt         |
					 i_Cpu0PvnnMainFlt           |
					 i_Cpu0PvccinFlt             |
					 i_Cpu0PvccdHvFlt            |
					 i_cpu1_mem_pwr_flt          |
					 i_Cpu1PvppHbmFlt            |
					 i_Cpu1PvccfaEhvFlt          |
					 i_Cpu1PvccfaFivrFlt         |
					 i_Cpu1PvccInfaonFlt         |
					 i_Cpu1PvnnMainFlt           |
					 i_Cpu1PvccinFlt             |
					 i_Cpu1PvccdHvFlt            |
					 i_cpu0Mem_ab_pwr_flt        |
					 i_cpu0Mem_cd_pwr_flt        |
					 i_cpu0Mem_ef_pwr_flt        |
					 i_cpu0Mem_gh_pwr_flt        |
					 i_cpu1Mem_ab_pwr_flt        |
					 i_cpu1Mem_cd_pwr_flt        |
					 i_cpu1Mem_ef_pwr_flt        |
					 i_cpu1Mem_gh_pwr_flt       
					 ;

assign o_pwr_flt_code = r_timeout_code;

//////////////////////////////////////////////////////////////////////////////
//Add power on delay error due to the frame has been changed on 20190701
//////////////////////////////////////////////////////////////////////////////
always@(posedge i_clk or negedge i_rst_n)
begin
    if(~i_rst_n)
        r_pwr_fail_flag <= 1'b0;
    else if(w_fault_all_pos)
        r_pwr_fail_flag <= 1'b1;
    else
        r_pwr_fail_flag <= r_pwr_fail_flag;
end

always@(posedge i_clk or negedge i_rst_n)
begin
    if(~i_rst_n)
        r_cnt_delay_AC <= 9'd0;
    else if(r_pwr_fail_flag || i_PWRGD_P1V05_PCH_STBY || i_clr_flag || i_delay_int_ign)
        r_cnt_delay_AC <= 9'd0;
    else if(r_cnt_delay_AC >= T10S)
        r_cnt_delay_AC <= T10S;
    else if(r_cnt_delay_AC < T10S && w_20mSEC_pos && (~i_PWRGD_P1V05_PCH_STBY) && (~r_pwr_fail_flag))
        r_cnt_delay_AC <= r_cnt_delay_AC + 1'b1;
    else
        r_cnt_delay_AC <= r_cnt_delay_AC;
end

always@(posedge i_clk or negedge i_rst_n)
begin
    if(~i_rst_n)
        r_cnt_delay_DC <= 8'd0;
    else if(~i_FM_SLPS3_N | r_pwr_fail_flag | i_RST_PLTRST_N || (i_clr_flag && i_FM_SLPS3_N && (r_cnt_delay_DC < T5S)) || i_delay_int_ign)
        r_cnt_delay_DC <= 8'd0;
    else if(r_cnt_delay_DC >= T5S)  //8'd25 Sim
        r_cnt_delay_DC <= T5S;
    else if(r_cnt_delay_DC < T5S && w_20mSEC_pos && i_FM_SLPS3_N && (~i_RST_PLTRST_N) && (~r_pwr_fail_flag))
        r_cnt_delay_DC <= r_cnt_delay_DC + 1'b1;
    else
        r_cnt_delay_DC <= r_cnt_delay_DC;
end

always@(posedge i_clk or negedge i_rst_n)
begin
    if(~i_rst_n)
        r_AC_delay <= 1'b0;
    else if(i_clr_flag && i_PWRGD_P1V05_PCH_STBY)
        r_AC_delay <= 1'b0;
    else if(~i_PWRGD_P1V05_PCH_STBY && (r_cnt_delay_AC == T10S))
        r_AC_delay <= 1'b1;
    else
        r_AC_delay <= r_AC_delay;
end

always@(posedge i_clk or negedge i_rst_n)
begin
    if(~i_rst_n)
        r_DC_delay <= 1'b0;
    else if(i_clr_flag && (i_RST_PLTRST_N || (~i_FM_SLPS3_N) || (i_FM_SLPS3_N && (r_cnt_delay_DC < T5S))))
        r_DC_delay <= 1'b0;
    else if(~i_RST_PLTRST_N && (r_cnt_delay_DC == T5S))
        r_DC_delay <= 1'b1;
    else
        r_DC_delay <= r_DC_delay;
end


Edge_Detect Edge_Detect_U0(
.i_clk            (i_clk),           //input Clk
.i_rst_n          (i_rst_n),         //Global rst,Active Low
.i_signal         (w_fault_all),

.o_signal_pos     (w_fault_all_pos),
.o_signal_neg     (),
.o_signal_invert  ()
);

Edge_Detect Edge_Detect_U4(
.i_clk            (i_clk),           //input Clk
.i_rst_n          (i_rst_n),         //Global rst,Active Low
.i_signal         (i_20mSEC),

.o_signal_pos     (w_20mSEC_pos),
.o_signal_neg     (),
.o_signal_invert  ()
);



// timeout log  


always@(posedge i_clk or negedge i_rst_n)
begin
    if(~i_rst_n)
	begin
	    r_timeout_code    <= 8'h00;
	end
	else if(i_clr_flag)
	    r_timeout_code    <= 8'h00;
	else if(~i_clr_flag)
	begin
	    if(i_p12v_stby_droop)
		    r_timeout_code    <= 8'h01;
		else if(i_p3v3_stby_pwr_flt)
		    r_timeout_code    <= 8'h02;
		else if(i_p12v_droop)
		    r_timeout_code    <= 8'h03;
		else if(i_p12v_pwr_flt)
		    r_timeout_code    <= 8'h04;
		else if(i_aux_pwr_flt)
		    r_timeout_code    <= 8'h05;
		else if(i_p5v_stby_pwr_flt)
		    r_timeout_code    <= 8'h06;
		else if(i_p1v2_stby_pwr_flt)
		    r_timeout_code    <= 8'h07;
		else if(i_p1v8_stby_pwr_flt)
		    r_timeout_code    <= 8'h08;
		else if(i_cmu_p5v0_stby_pwr_flt)
		    r_timeout_code    <= 8'h09;
		else if(i_cmu_p3v3_stby_pwr_flt)
		    r_timeout_code    <= 8'h0a;
		else if(i_cmu_p3v3_stby_rgm_pwr_flt)
		    r_timeout_code    <= 8'h0b;
		else if(i_cmu_p2v5_stby_pwr_flt)
		    r_timeout_code    <= 8'h0c;
		else if(i_cmu_p1v8_stby_pwr_flt)
		    r_timeout_code    <= 8'h0d;
		else if(i_cmu_p1v2_stby_pwr_flt)
		    r_timeout_code    <= 8'h0e;
		else if(i_cmu_p1v0_stby_pwr_flt)
		    r_timeout_code    <= 8'h0f;
		else if(i_pch_pwr_flt)
		    r_timeout_code    <= 8'h10;
		else if(i_pch_pvnn_pwr_flt)
		    r_timeout_code    <= 8'h11;
		else if(i_pch_p1v05_pwr_flt)
		    r_timeout_code    <= 8'h12;
		else if(~i_FM_SLPS4_N)
		    r_timeout_code    <= 8'h13;
		else if(i_p5v_pwr_flt)
		    r_timeout_code    <= 8'h14;
		else if(i_cpu0_mem_pwr_flt)
		    r_timeout_code    <= 8'h15;
		else if(i_Cpu0PvppHbmFlt)
		    r_timeout_code    <= 8'h16;
		else if(i_Cpu0PvccfaEhvFlt)
		    r_timeout_code    <= 8'h17;
		else if(i_Cpu0PvccfaFivrFlt)
		    r_timeout_code    <= 8'h18;		
		else if(i_Cpu0PvccInfaonFlt)
		    r_timeout_code    <= 8'h19;
		else if(i_Cpu0PvnnMainFlt)
		    r_timeout_code    <= 8'h1a;
		else if(i_Cpu0PvccinFlt)
		    r_timeout_code    <= 8'h1b;
		else if(i_Cpu0PvccdHvFlt)
		    r_timeout_code    <= 8'h1c;	
		else if(i_cpu1_mem_pwr_flt)
		    r_timeout_code    <= 8'h1d;
		else if(i_Cpu1PvppHbmFlt)
		    r_timeout_code    <= 8'h1e;
		else if(i_Cpu1PvccfaEhvFlt)
		    r_timeout_code    <= 8'h1f;
		else if(i_Cpu1PvccfaFivrFlt)
		    r_timeout_code    <= 8'h20;		
		else if(i_Cpu1PvccInfaonFlt)
		    r_timeout_code    <= 8'h21;
		else if(i_Cpu1PvnnMainFlt)
		    r_timeout_code    <= 8'h22;
		else if(i_Cpu1PvccinFlt)
		    r_timeout_code    <= 8'h23;
		else if(i_Cpu1PvccdHvFlt)
		    r_timeout_code    <= 8'h24;		
		else if(i_cpu0Mem_ab_pwr_flt)
		    r_timeout_code    <= 8'h25;
		else if(i_cpu0Mem_cd_pwr_flt)
		    r_timeout_code    <= 8'h26;
		else if(i_cpu0Mem_ef_pwr_flt)
		    r_timeout_code    <= 8'h27;
		else if(i_cpu0Mem_gh_pwr_flt)
		    r_timeout_code    <= 8'h28;		
		else if(i_cpu1Mem_ab_pwr_flt)
		    r_timeout_code    <= 8'h29;
		else if(i_cpu1Mem_cd_pwr_flt)
		    r_timeout_code    <= 8'h2a;
		else if(i_cpu1Mem_ef_pwr_flt)
		    r_timeout_code    <= 8'h2b;
		else if(i_cpu1Mem_gh_pwr_flt)
		    r_timeout_code    <= 8'h2c;			
		else if(~i_RST_PLTRST_N)
		    r_timeout_code    <= 8'h2d;	
        else 
            r_timeout_code    <= 8'h00;			
	end
	else
	begin
	    r_timeout_code  <= 8'h00;
	end
end



endmodule
