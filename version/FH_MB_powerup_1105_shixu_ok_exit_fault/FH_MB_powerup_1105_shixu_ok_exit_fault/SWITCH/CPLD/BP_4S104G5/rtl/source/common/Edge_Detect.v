
`timescale 1ns / 1ps

module Edge_Detect(
input  wire  i_clk,           //input Clk
input  wire  i_rst_n,         //Global rst,Active Low
input  wire  i_signal,

output wire  o_signal_pos,
output wire  o_signal_neg,
output wire  o_signal_invert
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
reg  r_signal_a;
reg  r_signal_b;
reg  r_signal_c;
reg  r_signal_d;
wire w_signal_pos;
wire w_signal_neg;

//////////////////////////////////////////////////////////////////////////////////
// Continuous assignments
//////////////////////////////////////////////////////////////////////////////////
assign w_signal_pos    = r_signal_a && (~r_signal_b);
assign w_signal_neg    = (~r_signal_c) && r_signal_d;
assign o_signal_pos    = w_signal_pos;
assign o_signal_neg    = w_signal_neg;
assign o_signal_invert = w_signal_pos ^ w_signal_neg;
//////////////////////////////////////////////////////////////////////////////////
// Secuencial Logic
//////////////////////////////////////////////////////////////////////////////////
always@(posedge i_clk or negedge i_rst_n)
begin
    if(~i_rst_n)
    begin
        r_signal_a <= 1'b1;
        r_signal_b <= 1'b1;
    end
    else
    begin
        r_signal_a <= i_signal;
        r_signal_b <= r_signal_a;
    end
end

always@(posedge i_clk or negedge i_rst_n)
begin
    if(~i_rst_n)
    begin
        r_signal_c <= 1'b0;
        r_signal_d <= 1'b0;
    end
    else
    begin
        r_signal_c <= i_signal;
        r_signal_d <= r_signal_c;
    end
end
//////////////////////////////////////////////////////////////////////////////////
// Submodule                                                                      
//////////////////////////////////////////////////////////////////////////////////

endmodule
