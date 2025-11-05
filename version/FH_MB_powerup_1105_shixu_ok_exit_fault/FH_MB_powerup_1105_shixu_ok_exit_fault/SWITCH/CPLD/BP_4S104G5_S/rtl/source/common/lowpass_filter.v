// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
// *                   C O P Y R I G H T     N O T I C E                       *
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
// * All rights reserved.                                                      *
// *                                                                           *
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
// * Engineer:        dingxianhua
// * Email:           dingxianhua@cloudnineinfo.com
// * Module Name:     lowpass_filter
// * Project Name:    NF5280M6
// * Description:     Module Function
// *    to filter the signals
// * Instances:       Modules included in this file
// *    <1> NA
// * Modification:    The content been modified
// *    2020-8-25: New Created
// *    2021-3-30: Add 'STAGES' to filter one more 'i_filter_en' stage
// *    2021-04-11: Modify the 'parameter' to 'localparam'


`timescale 1ns/1ns

module lowpass_filter#(
parameter TOTAL_STAGES = 5,
parameter INIT_VALUE   = 1
)
(
input  i_clk,
input  i_rst_n,
input  i_filter_en,
input  i_data_in,

output o_data_out
);

//////////////////////////////////////////////////////////////////////////////////
// Parameters
//////////////////////////////////////////////////////////////////////////////////
localparam LOW    = 1'b0;
localparam HIGH   = 1'b1;
localparam Z      = 1'bz;
localparam STAGES = TOTAL_STAGES + 1'b1;
//////////////////////////////////////////////////////////////////////////////////
// Internal Signals
//////////////////////////////////////////////////////////////////////////////////
reg  [STAGES-1:0] r_data;
reg  r_data_out;

//////////////////////////////////////////////////////////////////////////////////
// Continuous assignments
//////////////////////////////////////////////////////////////////////////////////
assign o_data_out = r_data_out;

//////////////////////////////////////////////////////////////////////////////////
// Secuencial Logic
//////////////////////////////////////////////////////////////////////////////////
always@(posedge i_clk or negedge i_rst_n)
begin
    if(~i_rst_n) 
        r_data    <= {STAGES{INIT_VALUE}};
    else if (i_filter_en)
        r_data    <= {r_data[STAGES-2:0],i_data_in};
    else
        r_data    <= r_data;
end

always@(posedge i_clk or negedge i_rst_n)
begin
	if(~i_rst_n)
        r_data_out    <= INIT_VALUE;
    else
    begin
        if(&r_data) 
            r_data_out	<= 1'b1;
        else if (~(|r_data))
            r_data_out	<= 1'b0;
        else
            r_data_out	<= r_data_out;
    end		
end
//////////////////////////////////////////////////////////////////////////////////
// Submodule                                                                      
//////////////////////////////////////////////////////////////////////////////////

endmodule 