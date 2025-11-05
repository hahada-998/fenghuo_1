// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
// *                   C O P Y R I G H T     N O T I C E                       *
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
// *                                                                           *
// * Inspur Company Confidential                                               *
// *                                                                           *
// * (c) Copyright 2020 - 2025 Inspur Electronic Information Industry Co.,Ltd. *
// * All rights reserved.                                                      *
// *                                                                           *
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
// * Engineer:        Lambert
// * Email:           chenzhanliang@inspur.com 
// * Module Name:     fan_pwm_cnt.v
// * Project Name:    XXXX
// * Description:     counter follow clk_en 
// *		 
// * Instances:       Modules included in this file
// *    <1>           CNTx_with_Keep.v 
// *    <1>           DFFEV.v 
// * Modification:    The content been modified
// *    2020-11-26: New Created
// * 

module fan_counter #(
parameter        WIDTH        = 4, 
parameter        MAX_VALUE    = 5 
)(
input  i_clk,
input  i_rst_n,
input  i_clk_en,
input  i_clr_pwm_cnt,
output [WIDTH-1:0]o_cnt_result
);

///////////////////////////////////////////////////////////
reg [WIDTH-1:0]r_cnt_result;
assign o_cnt_result = r_cnt_result;

///////////////////////////////////////////////////////////

always@(posedge i_clk or negedge i_rst_n)
begin
    if(~i_rst_n)
	    r_cnt_result  <= 0;
	else 
	begin	
	    if(i_clr_pwm_cnt)
		    r_cnt_result <= 0;
		else if(r_cnt_result >= MAX_VALUE)
		    r_cnt_result <= r_cnt_result;
		else if(i_clk_en)
		    r_cnt_result <= r_cnt_result + 1;
	end
end

 
endmodule 

 