//=================================================================================================--
// Copyright(c) 2021, CLOUDNINEINFO.CO, Ltd, All right reserved
// Filename   : AIS03MB03.v
// Project    : CLOUDNINEINFO common code
// Author     : dingxianhua
// Date       : 2020-09-24
// Email      : dingxianhua@cloudnineinfo.com
// Company    : CLOUDNINEINFO.CO., Ltd
// Description: The minimum BUFFER_WIDTH for implementing this module must be 1. Synchonizes
//   signal_in to the CLK domain and drives as signal_out. Delays signal_in by (BUFFER_WIDTH * 2)
//   CLK cycles, resulting in a (period(CLK) * BUFFER_WIDTH * 2) second delay, and drives as
//   signal_out. Detects the rising and falling edges of signal_in, which are deglitched for
//   (period(CLK) * BUFFER_WIDTH * 2) seconds.
// History    :
//   Date      By          Revision  Change Description
//=================================================================================================

module edge_sync
 #(  // *** the minimum buffer width for this module must be 1 ***
   parameter BUFFER_WIDTH = 1'd1) (
    input  wire          clk,
    input  wire          reset_n,
    input  wire          t30p5us,
    input  wire          signal_in,
    input  wire          edge_clear,
    output reg           signal_out,
    output reg           falling_edge,
    output reg           rising_edge
)/* synthesis syn_preserve=1 */;

// the buffer that the input signal is shifted through
reg  [BUFFER_WIDTH*2-1:0] buffit;

wire    falling_edge_occured;
wire    rising_edge_occured;

// Note: rising_edge != ~falling_edge
// parameter BUFFER_WIDTH = 4;
// reg [BUFFER_WIDTH*2-1:0] buffit === reg [7:0] buffit
//
// _oldest val          _most recent val
// |                    |
// |         T0         |                  T1
// |                    |
// 7  6  5  4  3  2  1  0        7  6  5  4  3  2  1  0
// 0  0  0  0  0  0  0  1   =>   0  0  0  0  1  1  1  1
//                     __  time             ___________
// ____________________|    =>   ___________|


assign falling_edge_occured = (buffit[BUFFER_WIDTH*2-1:0]=={1'b1, {BUFFER_WIDTH*2-1{1'b0}}});
assign rising_edge_occured  = (buffit[BUFFER_WIDTH*2-1:0]=={1'b0, {BUFFER_WIDTH*2-1{1'b1}}});

always @(posedge clk or negedge reset_n)
  begin
    if (!reset_n)
      begin // reset output signal and buffer
        buffit[BUFFER_WIDTH*2-1:0] <= {BUFFER_WIDTH*2{1'b0}};
        signal_out   <= 1'b0;
        rising_edge  <= 1'b0;
        falling_edge <= 1'b0;
      end
    else
      begin // shift input signal through the buffer
        if (t30p5us)
          begin
            buffit[0] <= signal_in;
            buffit[BUFFER_WIDTH*2-1:1] <= buffit[BUFFER_WIDTH*2-2:0];
            signal_out <= buffit[BUFFER_WIDTH*2-1];
            rising_edge <= (rising_edge || rising_edge_occured) &&
                           !edge_clear;
            falling_edge <= (falling_edge || falling_edge_occured) &&
                            !edge_clear;
          end
       end
  end

endmodule

