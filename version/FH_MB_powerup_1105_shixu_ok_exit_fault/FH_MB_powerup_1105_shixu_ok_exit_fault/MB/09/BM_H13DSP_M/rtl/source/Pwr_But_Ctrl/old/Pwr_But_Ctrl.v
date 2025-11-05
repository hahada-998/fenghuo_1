// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
// *                   C O P Y R I G H T     N O T I C E                       *
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
// * Engineer:    liuqi
// * Email:       liuqic@cooudnineinfo.com
// * Module Name:     Pwr_But_Ctrl
// * Project Name:    **
// * Description:     Module Function
// *    Power button control
// * Instances:       Modules included in this file
// *    <1> lowpass_filter
// *    <2> NA
// *    <3> NA
// *    <4> NA
// * Modification:    The content been modified
// *    2021-1-27 : New Created
// *    2021-3-16 : change net name follow tri-river
// *    2021-3-25 : change Annotation for i_BMC_active0_n
// *    2021-4-22 : line 232 ,change to o_PWRBTN_state from o_PWRBTN_State
// *    2021-5-6  : assign o_PWRBTN_state = {r_power_state,r_Pwrbtn_long,r_Pwrbtn_short};  // 
// *    2021_09_20: add r_power_state_ff
// *    2021-12-01: tririvers v2 change w_Pwrbtn_control logic;
// *    2022_05_01: add i_power_ctl_en,i_TX_prj
// *
`timescale 1ns / 1ps 

module Pwr_But_Ctrl #(
parameter PWRBTN_LONG = 4
)(
input  i_clk   ,		//input Clk
input  i_rst_n ,		//Global rst,Active Low
input  i_20mSEC,

input  i_power_ctl_en,              // 1'b1 is enable the power control function;  1'b1 for TX.
input  i_TX_prj,                    // 1'b1 Tencent's project, 1'b0 Universal project
input  i_PWRBTN_OUT_disable,

input  i_disable_button,			// 1'b1 is disable, 1'b0 is enable;  1'b1 for General items.
input  i_BMC_active0_n,             // 1'b1: BMC die,  1'b0: BMC active, default low when AC in;  if no function of BMC controled power on, this signal shuold 1'b1.
input  i_FP_PWR_BTN_MUX_N,			//Power Button
       
input  i_FM_BMC_PWRBTN_OUT_CPLD_N,	//Power on/off signal from BMC
input  i_DBP_POWER_BTN_N         ,	//Power on/off signal from DBP 

     
input  i_state_s0,
input  i_state_s5,

input  i_bmc_clear_data    ,        //high pulse for BMC clear latch data
input  i_BMC_active1_n       ,        // 1'b1: BMC die,  1'b0: BMC active, default high when AC in
output o_pwrbtn_short      ,
output o_pwrbtn_long       ,
output [3:0] o_PWRBTN_state,

output o_FM_BMC_PWRBTN_OUT_B_N		//Power on/off signal to PCH

);

wire w_PWR_BTN_Filter;
wire w_BMC_PWR_BTN_Filter;
wire w_DBP_POWER_filter;

wire w_PWR_BTN_GD;
wire w_BMC_PWR_BTN_GD;
wire w_DBP_POWER_GD;
wire w_PWR_BTN_OUT;

//wire w_Pwrbtn_control;
reg  r_Pwrbtn_control;

reg r_pwr_btn_dly1, r_pwr_btn_dly2;
wire w_pwr_btn_neg, w_pwr_btn_pos;

reg [1:0] r_power_state;
reg [1:0] r_power_state_ff;

lowpass_filter #
(
    .TOTAL_STAGES           ( 3 ),
    .INIT_VALUE             (1'b1)
)PwrBtn_Filter
(
    .i_clk             ( i_clk ),
    .i_rst_n           ( i_rst_n ),
    .i_filter_en       ( i_20mSEC ),
    .i_data_in         ( i_FP_PWR_BTN_MUX_N ),
    .o_data_out        ( w_PWR_BTN_Filter )
);

lowpass_filter #
(
    .TOTAL_STAGES           ( 3 ),
    .INIT_VALUE             (1'b1)
)BMC_PwrBtn_Filter
(
    .i_clk             ( i_clk ),
    .i_rst_n           ( i_rst_n ),
    .i_filter_en       ( 1'b1 ),
    .i_data_in         ( i_FM_BMC_PWRBTN_OUT_CPLD_N ),
    .o_data_out        ( w_BMC_PWR_BTN_Filter )
);

lowpass_filter #
(
    .TOTAL_STAGES           ( 3 ),
    .INIT_VALUE             (1'b1)
)DBP_BTN_Filter
(
    .i_clk             ( i_clk ),
    .i_rst_n           ( i_rst_n ),
    .i_filter_en       ( 1'b1 ), 
    .i_data_in         ( i_DBP_POWER_BTN_N ),
    .o_data_out        ( w_DBP_POWER_filter )
);

assign w_PWR_BTN_GD     = w_PWR_BTN_Filter;
assign w_BMC_PWR_BTN_GD = w_BMC_PWR_BTN_Filter;
assign w_DBP_POWER_GD   = w_DBP_POWER_filter;
assign w_PWR_BTN_OUT    = w_PWR_BTN_GD & w_BMC_PWR_BTN_GD & w_DBP_POWER_GD;


//assign w_Pwrbtn_control = (i_state_s0 &  (~i_disable_button )) || (i_state_s5 &  i_BMC_active0_n);
//assign w_Pwrbtn_control = (i_state_s0 ) || (i_state_s5 &  (~i_disable_button));

wire w_FM_BMC_PWRBTN_OUT_B_N_pre;
assign w_FM_BMC_PWRBTN_OUT_B_N_pre =  (r_Pwrbtn_control ? w_PWR_BTN_GD :1'b1)
                                     & w_BMC_PWR_BTN_GD 
							         & w_DBP_POWER_GD ;

assign o_FM_BMC_PWRBTN_OUT_B_N = (~i_PWRBTN_OUT_disable)?w_FM_BMC_PWRBTN_OUT_B_N_pre:1'b1;
//=long/short press====================================================================================================
reg r_Pwrbtn_short = 1'b0;
reg r_Pwrbtn_long  = 1'b0;

reg [7:0] r_cnt_pwr_btn;

reg [7:0] r_cnt_100ms;
reg r_clk_100ms;
always@(posedge i_clk or negedge i_rst_n) 
begin
    if(!i_rst_n) 
    begin
        r_cnt_100ms <= 8'd0;
	    r_clk_100ms <= 1'b0;
    end
	else 
	begin
        if(r_cnt_100ms==8'd5)
            r_cnt_100ms <= 8'd0;
		else if(i_20mSEC)
			r_cnt_100ms <= r_cnt_100ms+8'd1;
		else
			r_cnt_100ms <= r_cnt_100ms;
		
		if(r_cnt_100ms==8'd5)
			r_clk_100ms <= 1'b1;
		else
			r_clk_100ms <= 1'b0;
	end
end


always@(posedge i_clk or negedge i_rst_n) 
begin
	if(!i_rst_n) 
	begin
		r_pwr_btn_dly1  <= 1'b1;
		r_pwr_btn_dly2  <= 1'b1;

	end
	else 
    begin
        r_pwr_btn_dly1 <= w_PWR_BTN_Filter;
        r_pwr_btn_dly2 <= r_pwr_btn_dly1 ;
    end
end

assign w_pwr_btn_pos = r_pwr_btn_dly1 && (!r_pwr_btn_dly2) ;
assign w_pwr_btn_neg = (!r_pwr_btn_dly1) && (r_pwr_btn_dly2) ;



always@(posedge i_clk or negedge i_rst_n) 
begin
	if(!i_rst_n) 
	begin
		r_cnt_pwr_btn  <= 8'h00;
		r_Pwrbtn_short <= 1'b0;
		r_Pwrbtn_long  <= 1'b0;
	end
	else begin
		if(w_pwr_btn_neg) 					          r_cnt_pwr_btn	<= 8'h00;
		else if ( r_cnt_pwr_btn == (PWRBTN_LONG*10 +1))  r_cnt_pwr_btn	<= r_cnt_pwr_btn ;
		else if ( (~w_PWR_BTN_Filter) & r_clk_100ms   )    r_cnt_pwr_btn	<= r_cnt_pwr_btn + 1'b1 ;
        else                                          r_cnt_pwr_btn	<= r_cnt_pwr_btn ;
		
		if(w_pwr_btn_pos & (~i_BMC_active1_n  ) ) 
		begin
			if(r_cnt_pwr_btn<=(PWRBTN_LONG*10) )   r_Pwrbtn_short  <=1'b1;
			if(r_cnt_pwr_btn==(PWRBTN_LONG*10 +1)) r_Pwrbtn_long   <=1'b1;
		end
	    else if(i_bmc_clear_data)
		begin
		    r_Pwrbtn_short <= 1'b0;
		    r_Pwrbtn_long  <= 1'b0;			
		end
		else         
		begin
		    r_Pwrbtn_short <= r_Pwrbtn_short;
		    r_Pwrbtn_long  <= r_Pwrbtn_long ;		
		end
	end
end

assign o_pwrbtn_short = r_Pwrbtn_short ;
assign o_pwrbtn_long  = r_Pwrbtn_long  ;
//========================================================== 

//power state===============================================
always@(posedge i_clk or negedge i_rst_n) begin
	if(~i_rst_n) begin
		 r_power_state		<= 2'b11;
	 end
	 else begin
		 if(w_pwr_btn_neg && i_state_s0 && (~i_BMC_active1_n ))
			  r_power_state	<= 2'b01;
		  else if(w_pwr_btn_neg && ~i_state_s0 && (~i_BMC_active1_n ))
			  r_power_state	<= 2'b00;
		  else if(i_bmc_clear_data && (r_Pwrbtn_long || r_Pwrbtn_short)) 
			  r_power_state	<= 2'b11;
	 end
end

always@(posedge i_clk or negedge i_rst_n) begin
	if(~i_rst_n) begin
		 r_power_state_ff		<= 2'b11;
	 end
	 else begin
		 if(w_pwr_btn_pos & (~i_BMC_active1_n  ) )
			  r_power_state_ff	<= r_power_state;
		  else if(i_bmc_clear_data && (r_Pwrbtn_long || r_Pwrbtn_short))
			  r_power_state_ff	<= 2'b11;
		  else
			  r_power_state_ff	<= r_power_state_ff;
	 end
end
// assign o_PWRBTN_state = {r_power_state,r_Pwrbtn_short,r_Pwrbtn_long};
assign o_PWRBTN_state = {r_power_state_ff,r_Pwrbtn_long,r_Pwrbtn_short};  // 
//==========================================================
always@(posedge i_clk or negedge i_rst_n) 
begin
	if(!i_rst_n) 
        r_Pwrbtn_control <= 1'b0;
    else if(~i_power_ctl_en)
        r_Pwrbtn_control <= 1'b1;
	else if(i_TX_prj)
        r_Pwrbtn_control <= (i_state_s0 ) || (i_state_s5 &  (~i_disable_button));
	else
        r_Pwrbtn_control <= ~i_disable_button;
end


endmodule
