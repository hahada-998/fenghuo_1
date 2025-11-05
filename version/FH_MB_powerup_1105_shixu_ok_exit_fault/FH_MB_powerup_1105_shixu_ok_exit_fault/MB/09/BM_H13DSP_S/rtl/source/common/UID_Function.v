// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
// *                   C O P Y R I G H T     N O T I C E                       *
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
// * All rights reserved.                                                      *
// *                                                                           *
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
// * Engineer:        dingxianhua
// * Email:           dingxianhua@cloudnineinfo.com 
// * Module Name:     UID_Function
// * Project Name:    AIS03MB03.v
// * Description:     Module Function
// *    UID Control
// * Instances:       Modules included in this file
// *    <1> lowpass_filter
// *    <2> Edge_DetectA
// *    <3> NA
// *    <4> NA
// * Modification:    The content been modified
// *    2020-8-26: New Created
// *    2020-12-17: Modify the netname according to the Coding rule
// *    2021-04-11: Modify the 'parameter' to 'localparam'
// *    2021-05-08: Limited the blinking frequency to 1Hz, 2Hz, 4Hz
// *    2021-05-13: Add o_UID_BTN_short_pos and change clear signals follow ALI requirement

`timescale 1ns / 1ps

module UID_Function#(
parameter LONG_PRESS = 'd6
)
(
input  i_clk,		           //input Clk
input  i_1mSEC,
input  i_20mSEC,
input  i_rst_n,		           //Global rst,Active Low
//input  i_clr_flag,           //Modified on 20210513
input  i_clr_flag_short,       //Use the same signal on common design
input  i_clr_flag_long,        //Use the same signal on common design
input  i_UID_BMC_BTN_N,
input  i_UID_BTN_RP_CPLD_N,
input  i_UID_BTN_FP_CPLD_N,

//Output Signal
output o_BMC_UID_CPLD_N,
output o_BMC_EXTRST_CPLD_OUT_N,
output o_UID_BTN_short_pos,    //Added on 20210513

output o_uid_button_long,
output o_uid_button_short,

input  i_uid_valid,
input  [7:0]i_uid_status,
output [7:0]o_uid_act_st
);
//////////////////////////////////////////////////////////////////////////////////
// Parameters
//////////////////////////////////////////////////////////////////////////////////
localparam LOW    = 1'b0;
localparam HIGH   = 1'b1;
localparam Z      = 1'bz;

localparam CNT_1S = 31;//50; //20ms clk
localparam CNT_6S = (LONG_PRESS * CNT_1S) - 1;
localparam CNT_9S = ((LONG_PRESS + 3) * CNT_1S) - 1;

localparam UID_OFF     = 8'h00;
localparam UID_ON      = 8'hFF;
localparam UID_BLK_NHZ = 8'h01;
//////////////////////////////////////////////////////////////////////////////////
// Internal Signals
//////////////////////////////////////////////////////////////////////////////////
wire w_UID_BTN_RP_CPLD_N;
wire w_UID_BTN_FP_CPLD_N;

wire w_UID_BTN_ALL;
wire w_UID_BTN_ALL_pos;
wire w_UID_BMC_BTN_N_neg;

reg  r0_UID_BTN_ALL_dly;
reg  r1_UID_BTN_ALL_dly;

reg  r_BMC_EXTRST_CPLD_OUT_N;
reg  [7:0]r_cnt_100ms;

reg  [1:0]r_uid_button;
reg  r_uid_long_flag;
wire w_uid_long_flag_pos;

reg  r_pulse_nHz;
reg  [8:0]r_cnt_pulse;
reg  [9:0]r_cnt_pulse_set;
reg  [7:0]r_uid_status;

reg  [7:0]r_flag_uid;
reg  [7:0]r_uid_act_st;
reg  r_BMC_UID_CPLD_N;

reg  [8:0]r_cnt_time;
//////////////////////////////////////////////////////////////////////////////////
// Continuous assignments
//////////////////////////////////////////////////////////////////////////////////
//assign w_uid_status_div         = r_uid_status << 1;    Modified on 20210510
assign w_UID_BTN_ALL            = w_UID_BTN_RP_CPLD_N & w_UID_BTN_FP_CPLD_N;
assign o_uid_button_long        = r_uid_button[1];
assign o_uid_button_short       = r_uid_button[0];
assign o_uid_act_st             = r_uid_act_st;
assign o_BMC_UID_CPLD_N         = r_BMC_UID_CPLD_N;
assign o_BMC_EXTRST_CPLD_OUT_N  = r_BMC_EXTRST_CPLD_OUT_N;
assign o_UID_BTN_short_pos      = (r_cnt_time < CNT_6S) && w_UID_BTN_ALL_pos;
//////////////////////////////////////////////////////////////////////////////////
// Secuencial Logic
//////////////////////////////////////////////////////////////////////////////////

//Pulse nHz(n >= 1)
always@(posedge i_clk or negedge i_rst_n)
begin
    if(~i_rst_n)
        r_uid_status <= 8'h01;
    //else if(i_uid_valid && i_uid_status != 8'h00 && i_uid_status != 8'hFF)    //Modified on 20210508
    else if(i_uid_valid && (i_uid_status == 8'h01 || i_uid_status == 8'h02 || i_uid_status == 8'h04))
        r_uid_status <= i_uid_status;
    else
        r_uid_status <= r_uid_status;
end

always@(posedge i_clk or negedge i_rst_n)
begin
    if(~i_rst_n)
        r_cnt_pulse <= 9'd0;
    else if(r_cnt_pulse == (r_cnt_pulse_set-1) && i_1mSEC)
        r_cnt_pulse <= 9'd0;
    else if(i_1mSEC)
        r_cnt_pulse <= r_cnt_pulse + 1'b1;
    else
        r_cnt_pulse <= r_cnt_pulse;
end

//always@(posedge i_clk or negedge i_rst_n)
//begin
//    if(~i_rst_n)
//        r_cnt_pulse_set <= 10'h3E8;    //10'd1000;
//    else
//        r_cnt_pulse_set <= 10'h3E8/w_uid_status_div;
//end

//Modified on 20210510
always@(posedge i_clk or negedge i_rst_n)
begin
    if(~i_rst_n)
        r_cnt_pulse_set <= 10'd1000;
    else if(r_uid_status == 8'h01)
        r_cnt_pulse_set <= 10'd500;
    else if(r_uid_status == 8'h02)
        r_cnt_pulse_set <= 10'd250;
    else if(r_uid_status == 8'h04)
        r_cnt_pulse_set <= 10'd125;
    else
        r_cnt_pulse_set <= r_cnt_pulse_set;
end

always@(posedge i_clk or negedge i_rst_n)
begin
    if(~i_rst_n)
        r_pulse_nHz <= 1'b0;
    else if(r_cnt_pulse == (r_cnt_pulse_set-1) && i_1mSEC)
        r_pulse_nHz <= ~r_pulse_nHz;
    else
        r_pulse_nHz <= r_pulse_nHz;
end
//////////////////////////////////////////////////////////////////////////////////
//UID LED control//
always@(posedge i_clk or negedge i_rst_n)
begin
    if(~i_rst_n)
    begin
        r_uid_act_st     <= UID_OFF;
        r_flag_uid       <= UID_OFF;
        r_BMC_UID_CPLD_N <= 1'b1;
    end
    else
    case(r_flag_uid)
    UID_OFF:
    begin
        if((r_cnt_time < CNT_6S && w_UID_BTN_ALL_pos) || w_UID_BMC_BTN_N_neg || (i_uid_valid && i_uid_status == 8'hFF))
        begin
            r_uid_act_st     <= UID_ON;
            r_flag_uid       <= UID_ON;
            r_BMC_UID_CPLD_N <= 1'b0;
        end
        //else if(i_uid_valid && i_uid_status != 8'h00)    //Modified on 20210508
        else if(i_uid_valid && (i_uid_status == 8'h01 || i_uid_status == 8'h02 || i_uid_status == 8'h04))
        begin
            r_uid_act_st     <= r_uid_status;
            r_flag_uid       <= UID_BLK_NHZ;
            r_BMC_UID_CPLD_N <= r_pulse_nHz;
        end
        else
        begin
            r_uid_act_st     <= UID_OFF;
            r_flag_uid       <= UID_OFF;
            r_BMC_UID_CPLD_N <= 1'b1;
        end
    end
    UID_ON:
    begin
        if((r_cnt_time < CNT_6S && w_UID_BTN_ALL_pos) || w_UID_BMC_BTN_N_neg || (i_uid_valid && i_uid_status == 8'h00))
        begin
            r_uid_act_st     <= UID_OFF;
            r_flag_uid       <= UID_OFF;
            r_BMC_UID_CPLD_N <= 1'b1;
        end
        else
        begin
            r_uid_act_st     <= UID_ON;
            r_flag_uid       <= UID_ON;
            r_BMC_UID_CPLD_N <= 1'b0;
        end
    end
    UID_BLK_NHZ:
    begin
        if(i_uid_valid && i_uid_status == 8'h00)
        begin
            r_uid_act_st     <= UID_OFF;
            r_flag_uid       <= UID_OFF;
            r_BMC_UID_CPLD_N <= 1'b1;
        end
        else if((r_cnt_time < CNT_6S && w_UID_BTN_ALL_pos) || w_UID_BMC_BTN_N_neg || (i_uid_valid && i_uid_status == 8'hFF))
        begin
            r_uid_act_st     <= UID_ON;
            r_flag_uid       <= UID_ON;
            r_BMC_UID_CPLD_N <= 1'b0;
        end
        else
        begin
            r_uid_act_st     <= r_uid_status;
            r_flag_uid       <= UID_BLK_NHZ;
            r_BMC_UID_CPLD_N <= r_pulse_nHz;
        end
    end
    endcase
end
//////////////////////////////////////////////////////////////////////////////////
//Reset BMC//
always@(posedge i_clk or negedge i_rst_n)
begin
    if(~i_rst_n)
        r_cnt_100ms <= 8'd0;
    else if(r_BMC_EXTRST_CPLD_OUT_N)
        r_cnt_100ms <= 8'd0;
    else if(r_cnt_100ms == 8'd100)		//100ms
        r_cnt_100ms <= 8'd101;
    else if((r_cnt_time == CNT_9S || !r_BMC_EXTRST_CPLD_OUT_N) && i_1mSEC)
        r_cnt_100ms <= r_cnt_100ms + 1'b1;
end

always@(posedge i_clk or negedge i_rst_n)
begin
    if(~i_rst_n)
        r_BMC_EXTRST_CPLD_OUT_N <= 1'b1;
    else if(r_cnt_100ms == 8'd100)
        r_BMC_EXTRST_CPLD_OUT_N <= 1'b1;
    else if(r_cnt_time == CNT_9S)
        r_BMC_EXTRST_CPLD_OUT_N <= 1'b0;
    else
        r_BMC_EXTRST_CPLD_OUT_N <= r_BMC_EXTRST_CPLD_OUT_N;
end
//////////////////////////////////////////////////////////////////////////////////
//UID Status//
always@(posedge i_clk or negedge i_rst_n)
begin
    if(~i_rst_n)
    begin
        r0_UID_BTN_ALL_dly <= 1'b1;
        r1_UID_BTN_ALL_dly <= 1'b1;
    end
    else
    begin
        r0_UID_BTN_ALL_dly <= w_UID_BTN_ALL;
        r1_UID_BTN_ALL_dly <= r0_UID_BTN_ALL_dly;
    end
end

always@(posedge i_clk or negedge i_rst_n)
begin
    if(~i_rst_n)
        r_cnt_time <= 9'd0;
    else if(r1_UID_BTN_ALL_dly && (r_cnt_time < CNT_6S))
        r_cnt_time <= 9'd0;
    else if(r1_UID_BTN_ALL_dly && (r_cnt_time > CNT_9S) && r_BMC_EXTRST_CPLD_OUT_N)
        r_cnt_time	<= 9'd0;
    else if(r_cnt_time >= CNT_9S)
        r_cnt_time <= 9'h1_FF;
    else if(i_20mSEC)
        r_cnt_time <= r_cnt_time + 1'b1;
    else
        r_cnt_time <= r_cnt_time;
end

always@(posedge i_clk or negedge i_rst_n)
begin
    if(~i_rst_n)
        r_uid_long_flag <= 1'b0;
    else if(r_cnt_time > CNT_6S)
        r_uid_long_flag <= 1'b1;
    else
        r_uid_long_flag <= 1'b0;
end

always@(posedge i_clk or negedge i_rst_n)
begin
    if(~i_rst_n)
        r_uid_button[0] <= 1'b0;
    //else if(i_clr_flag)    //Modified on 20210513
    else if(i_clr_flag_short)
        r_uid_button[0] <= 1'b0;
    else if(r_cnt_time < CNT_6S && w_UID_BTN_ALL_pos)
        r_uid_button[0] <= 1'b1;
    else
        r_uid_button[0] <= r_uid_button[0];
end

always@(posedge i_clk or negedge i_rst_n)
begin
    if(~i_rst_n)
        r_uid_button[1] <= 1'b0;
    //else if(i_clr_flag)    //Modified on 20210513
    else if(i_clr_flag_long)
        r_uid_button[1] <= 1'b0;
    else if(w_uid_long_flag_pos)
        r_uid_button[1] <= 1'b1;
    else
        r_uid_button[1] <= r_uid_button[1];
end
//////////////////////////////////////////////////////////////////////////////////
// Submodule                                                                      
//////////////////////////////////////////////////////////////////////////////////
//Filter of UID button
lowpass_filter#(
.TOTAL_STAGES         ('d3),
.INIT_VALUE           (1'b1)
)lowpass_filter_U0
(
.i_clk                (i_clk),
.i_rst_n              (i_rst_n),
.i_filter_en          (i_20mSEC),
.i_data_in            (i_UID_BTN_RP_CPLD_N),

.o_data_out           (w_UID_BTN_RP_CPLD_N)
);


lowpass_filter#(
.TOTAL_STAGES         ('d3),
.INIT_VALUE           (1'b1)
)lowpass_filter_U1
(
.i_clk                (i_clk),
.i_rst_n              (i_rst_n),
.i_filter_en          (i_20mSEC),
.i_data_in            (i_UID_BTN_FP_CPLD_N),

.o_data_out           (w_UID_BTN_FP_CPLD_N)
);

//////////////////////////////////////////////////////////////////////////////////
//edge detect of UID button and BMC GPIO//
Edge_Detect Edge_Detect_U0
(
.i_clk                (i_clk),                  //input Clk
.i_rst_n              (i_rst_n),                //Global rst,Active Low
.i_signal             (w_UID_BTN_ALL),

.o_signal_pos         (w_UID_BTN_ALL_pos),    //Output Signal
.o_signal_neg         (),
.o_signal_invert      ()
);

Edge_Detect Edge_Detect_U1
(
.i_clk                (i_clk),                  //input Clk
.i_rst_n              (i_rst_n),                //Global rst,Active Low
.i_signal             (i_UID_BMC_BTN_N),

.o_signal_pos         (),    //Output Signal
.o_signal_neg         (w_UID_BMC_BTN_N_neg),    //Output Signal
.o_signal_invert      ()
);

Edge_Detect Edge_Detect_U2
(
.i_clk                (i_clk),                  //input Clk
.i_rst_n              (i_rst_n),                //Global rst,Active Low
.i_signal             (r_uid_long_flag),

.o_signal_pos         (w_uid_long_flag_pos),    //Output Signal
.o_signal_neg         (),
.o_signal_invert      ()
);
//////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////

endmodule
