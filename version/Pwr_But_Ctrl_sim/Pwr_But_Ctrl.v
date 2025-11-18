
`timescale 1ns / 1ps

module Pwr_But_Ctrl #(parameter PWRBTN_LONG = 4 )
(
input  wire       i_clk   ,		//input Clk
input  wire       i_rst_n ,		//Global rst,Active Low
input  wire       i_20mSEC,
		          
input  wire       i_PWRBTN_OUT_disable,
		          
input  wire       i_disable_button,			// 1'b1 is disable, 1'b0 is enable;  1'b1 for General items.
input  wire       i_BMC_active0_n,             // 1'b1: BMC die,  1'b0: BMC active, default low when AC in;  if no function of BMC controled power on, this signal shuold 1'b1.
input  wire       i_FP_PWR_BTN_MUX_N,			//Power Button
		          
input  wire       i_FM_BMC_PWRBTN_OUT_CPLD_N,	//Power on/off signal from BMC
input  wire       i_DBP_POWER_BTN_N         ,	//Power on/off signal from DBP 
		          
		          
input  wire       i_state_s0,
input  wire       i_state_s5,
		          
input  wire       i_bmc_clear_data    ,        //high pulse for BMC clear latch data
input  wire       i_BMC_active1_n     ,        // 1'b1: BMC die,  1'b0: BMC active, default high when AC in
output wire       o_pwrbtn_short      ,
output wire       o_pwrbtn_long       ,
output wire [3:0] o_PWRBTN_state      ,
output wire [1:0] o_pwr_btn_state     ,
output wire       o_pwr_btn_dly       ,

output wire       o_FM_BMC_PWRBTN_OUT_B_N		//Power on/off signal to PCH

);

wire w_PWR_BTN_Filter;
wire w_BMC_PWR_BTN_Filter;
wire w_DBP_POWER_filter;

wire w_PWR_BTN_GD;
wire w_BMC_PWR_BTN_GD;
wire w_DBP_POWER_GD;
wire w_PWR_BTN_OUT;

wire w_Pwrbtn_control;  


reg r_pwr_btn_dly1, r_pwr_btn_dly2;
wire w_pwr_btn_neg, w_pwr_btn_pos;

reg [1:0] r_power_state;

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

assign w_Pwrbtn_control = (i_state_s0 &  (~i_disable_button )) || (i_state_s5 &  i_BMC_active0_n);

wire w_FM_BMC_PWRBTN_OUT_B_N_pre;
assign w_FM_BMC_PWRBTN_OUT_B_N_pre =  (w_Pwrbtn_control?w_PWR_BTN_GD :1'b1)
                                     & w_BMC_PWR_BTN_GD 
							         & w_DBP_POWER_GD ;

                                
assign o_FM_BMC_PWRBTN_OUT_B_N = (~i_PWRBTN_OUT_disable)?w_FM_BMC_PWRBTN_OUT_B_N_pre:1'b1;  //2023-11-20 add back
                                
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
		else if(i_bmc_clear_data) 
			r_power_state	<= 2'b11;
	 end
end
// assign o_PWRBTN_state = {r_power_state,r_Pwrbtn_short,r_Pwrbtn_long};
assign o_PWRBTN_state = {r_power_state,r_Pwrbtn_long,r_Pwrbtn_short};  // 
//==========================================================


///////////////////////////////////////2023-6-1 add //////////////////////////////////////////////////////////////////////////////////////////////////
reg [12:0] r_ac_init_cnt ; //20ms*4550 = 91s   max 4550  //2023-6-5 chg 40s to 90s

reg [1:0] r_pwr_btn_state;

reg r_pwr_btn;
reg r_pwr_btn_dly;

//timer cnt 
always@(posedge i_clk or negedge i_rst_n) begin
	if(~i_rst_n) begin
		r_ac_init_cnt		<= 13'd0;
	end
	else begin
		if(r_ac_init_cnt >= 13'd4550)   //20ms * 4550 = 91s
		    r_ac_init_cnt	<= r_ac_init_cnt;
		else if(i_20mSEC )
		    r_ac_init_cnt	<= r_ac_init_cnt + 1;
		else 
		    r_ac_init_cnt	<= r_ac_init_cnt;
	end
end

//pwr_on stage
always@(posedge i_clk or negedge i_rst_n) begin
	if(~i_rst_n) begin
		r_pwr_btn_state		<= 2'd0;
	end
	else begin
		if(r_ac_init_cnt < 13'd500)   //< 10s
		    r_pwr_btn_state	<= 2'd0;
		else if(r_ac_init_cnt < 13'd4500 && r_ac_init_cnt >= 13'd500 ) // 10s-90s
		    r_pwr_btn_state	<= 2'd1;
		else if(r_ac_init_cnt < 13'd4550 && r_ac_init_cnt >= 13'd4500 ) // 90s-91s
		    r_pwr_btn_state	<= 2'd2;
		else if(r_ac_init_cnt >= 13'd4550 ) // > 91s
		    r_pwr_btn_state	<= 2'd3;
	end
end

//pwr_btn 
always@(posedge i_clk or negedge i_rst_n) begin
	if(~i_rst_n) begin
		r_pwr_btn		    <= 1'b1;
		r_pwr_btn_dly		<= 1'b1;
	end
	else begin
		if(r_pwr_btn_state ==  2'd0)   // < 10s
		    r_pwr_btn		<= 1'b1;
		else if(r_pwr_btn_state ==  2'd1 && ~i_FP_PWR_BTN_MUX_N ) begin // 10s-90s
		    r_pwr_btn		<= 1'b1;
			r_pwr_btn_dly	<= 1'b0;
		end
		else if(r_pwr_btn_state ==  2'd2 || r_pwr_btn_state ==  2'd3 ) // > 90s
		    r_pwr_btn		<= i_FP_PWR_BTN_MUX_N;
	end
end


// assign o_FM_BMC_PWRBTN_OUT_B_N = r_pwr_btn && ((r_pwr_btn_state ==  2'd2) ? r_pwr_btn_dly : 1'b1); 
assign o_pwr_btn_state =  r_pwr_btn_state ;
assign o_pwr_btn_dly   =  r_pwr_btn_dly   ;



endmodule
