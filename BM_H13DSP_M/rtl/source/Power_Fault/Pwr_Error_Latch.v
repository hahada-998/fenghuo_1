// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
// *                   C O P Y R I G H T     N O T I C E                       *
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
// * Description:     Module Function
// *    When error happens, Latch the signal and export error of a clock,
// *    When error doesn't happen, pass through the original signal.
// * Instances:       Modules included in this file
// *    <1> Edge_Detect
// *    <2> NA
// *    <3> NA
// *    <4> NA
// * Modification:    The content been modified
// *    2020-11-24: New Created
// *    2021-04-11: Modify the 'parameter' to 'localparam'
// *    2021-06-30: When there is a power drop of one signal, the other fault signals will be latched to normal instead of the act status of PG.

`timescale 1ns / 1ps

module Pwr_Error_Latch#(  
parameter EDGE          = 1'b1,   //1'b1: posedge edge, 1'b0: negedge edge
parameter EN_JUDGE      = 1'b1,   //1'b1: enable signal is needed for fall edge or rising edge; 1'b0: fall edge or rising edge will trigger error directly
parameter EDGE_LATCH_EN = 1'b1,   //1'b1: enable edge , 1'b0:diable edge
parameter EXT_LATCH_EN  = 1'b1    //1'b1: enable external latch, 1'b0: disable external latch
)(

input  i_clk,
input  i_rst_n,

input  i_clr_flag,          //clear instruction after BMC reading data
input  i_PWR_EN,            //To judge if there is power en;
input  i_latch_flag,        //external trigger to latch the current value
input  i_signal,            //
output o_signal_latch,      //latch signal when wrong i_signal or external trigger
output o_fault_n            //
);

//////////////////////////////////////////////////////////////////////////////////
// Parameters
//////////////////////////////////////////////////////////////////////////////////
localparam LOW  = 1'b0;
localparam HIGH = 1'b1;
localparam Z    = 1'bz;
//////////////////////////////////////////////////////////////////////////////////
// Internal Signals
//////////////////////////////////////////////////////////////////////////////////
wire w_signal_edge;
wire w_signal_pos;
wire w_signal_neg;

reg  r_signal_latch;
reg  r_latch_flag;
reg  r_fault;
////////////////////////////////////////////////////////////////////////////////// //
////////////////////////////////////////////////////////////////////////////////// //

////////////////////////////////////////////////////////////////////////////////// //
// Continuous assignments                                                          //
////////////////////////////////////////////////////////////////////////////////// //
assign w_signal_edge  = EDGE ? w_signal_pos : w_signal_neg;
assign o_signal_latch = r_signal_latch;
assign o_fault_n      = r_fault;
//////////////////////////////////////////////////////////////////////////////////
// Secuencial Logic
//////////////////////////////////////////////////////////////////////////////////
always@(posedge i_clk or negedge i_rst_n)
begin
    if(~i_rst_n)
        r_fault <= 1'b1;
    else if(i_clr_flag)
        r_fault <= 1'b1;
    else if(r_latch_flag)
        r_fault <= r_fault;
    else if(w_signal_edge && EDGE_LATCH_EN && (i_PWR_EN || (~EN_JUDGE)))        //En but falling edge
        r_fault <= 1'b0;
    else
        r_fault <= r_fault;
end

always@(posedge i_clk or negedge i_rst_n)
begin
    if(~i_rst_n)
        r_latch_flag <= 1'b0;
    else if(i_clr_flag)
        r_latch_flag <= 1'b0;
    else if((w_signal_edge && EDGE_LATCH_EN && (i_PWR_EN || (~EN_JUDGE))) || (i_latch_flag && EXT_LATCH_EN))        //En but falling edge or external latch signal
        r_latch_flag <= 1'b1;
    else
        r_latch_flag <= r_latch_flag;
end

always@(posedge i_clk or negedge i_rst_n)
begin
    if(~i_rst_n)
        r_signal_latch <= i_signal;
    else if(i_clr_flag)
        r_signal_latch <= i_signal;
    else if(r_latch_flag)
        r_signal_latch <= r_signal_latch;
    else if(w_signal_edge && EDGE_LATCH_EN && (i_PWR_EN || (~EN_JUDGE)))    //En but falling edge 
        r_signal_latch <= i_signal;
    else if(i_latch_flag && EXT_LATCH_EN)                                   //external latch signal
        r_signal_latch <= ~EDGE;
	 else
        r_signal_latch <= i_signal;
end
//////////////////////////////////////////////////////////////////////////////////
// Submodule                                                                      
//////////////////////////////////////////////////////////////////////////////////
Edge_Detect Edge_Detect_u(
.i_clk            (i_clk),           //input Clk
.i_rst_n          (i_rst_n),         //Global rst,Active Low
.i_signal         (i_signal),

.o_signal_pos     (w_signal_pos),
.o_signal_neg     (w_signal_neg),
.o_signal_invert  ()
);

endmodule
