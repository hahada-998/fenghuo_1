
//=================================================================================================--
// Copyright(c) 2021, CLOUDNINEINFO.CO, Ltd, All right reserved
// Filename   : AIS03MB03.v
// Project    : CLOUDNINEINFO common code
// Author     : dingxianhua
// Date       : 2020-09-24
// Email      : dingxianhua@cloudnineinfo.com
// Company    : CLOUDNINEINFO.CO., Ltd
//=================================================================================================--

`timescale 1ns / 1ps
 
module Hitless_Top #( 
parameter 	HITLESS_SIG_NUM  = 100
)
(

input  i_clk,
input  i_rst_n,
input  i_hitless_en,
input  [HITLESS_SIG_NUM-1:0] i_signal_in,
inout  [HITLESS_SIG_NUM-1:0] io_signal_out

);

////////////////////////////////////////////////////////////////////////////////// //
//internal signals                                                          
////////////////////////////////////////////////////////////////////////////////// //
reg  r_hitless_release_pre        = 0;
//reg  r_hitless_en                 = 1'b1;
reg  r_hitless_en                 ;
reg  [31:0]r_hitless_release_cnt  = 0;

wire [HITLESS_SIG_NUM-1:0] w_signal_out_b;	
wire [HITLESS_SIG_NUM-1:0] w_Hitless_bb_o,w_Hitless_bb_m;
wire w_hitless_release; 

///////////////////////////////////////////////////////////////////////////////////////
assign w_hitless_release = r_hitless_en?r_hitless_release_pre:1'b1; 
///////////////////////////////////////////////////////////////////////////////////////
always @(posedge i_clk) 
begin
    if(i_rst_n) 
	    r_hitless_en <= r_hitless_en;
	else         
	    r_hitless_en <= i_hitless_en;

    if(r_hitless_release_cnt<32'd10_000_000)  
	    r_hitless_release_pre<=0; //5s
    else  
	    r_hitless_release_pre<=1;
	
	if(r_hitless_release_cnt >= 32'd10_000_000)  
	    r_hitless_release_cnt <= r_hitless_release_cnt;
	else 							     
	    r_hitless_release_cnt <= r_hitless_release_cnt+1;

end

  
generate
    genvar k;
    for (k=0; k<=(HITLESS_SIG_NUM-1); k=k+1)  
    begin
        assign w_Hitless_bb_m[k] =  w_hitless_release ? i_signal_in[k] : w_Hitless_bb_o[k];
        //assign io_signal_out[k]   =  w_signal_out_b[k];
        BB Hitless    ( .I( w_Hitless_bb_m[k]), .T( 1'b0 ), .O( w_Hitless_bb_o[k]), .B( io_signal_out[k] ) );
    end
endgenerate


endmodule