//=================================================================================================--
// Copyright(c) 2021, CLOUDNINEINFO.CO, Ltd, All right reserved
// Filename   : AIS03MB03.v
// Project    : CLOUDNINEINFO common code
// Author     : liuqi
// Date       : 2022-09-24
// Email      : liuqic@cloudnineinfo.com
// Company    : CLOUDNINEINFO.CO., Ltd
// Description: Generate 1-clk wide pulse on signal edges. A pe, ne and any output are available
//   for the desired edge. Separate output is provided to allow single instance of this module to
//   provide the different edge detection instead of having different instances for different
//   edge detection. Multiple signals can be passed to this module by setting SIGCNT properly.
//   Each signal is handled independently. Any unused output will be optimized away by synthesis.
//   'tick' can be used to lenghten detect_* output until next assertion. It's useful where
//   detect_* is used where register is by the same tick signal. For 1-clk pulse wide, keep tick
//   at 1'b1.
// Parameter  :
//   SIGCNT: Number of signals to handle independently.
//    Default: 1
//   DEF_INIT: Default initializer for internal reg. Set this to 1'b1 for active low signal to
//    avoid errant output on pe and any output on reset release.
//    Default: {SIGCNT{1'b0}}
// History    :
//   Date      By          Revision  Change Description
//=================================================================================================

module edge_detect #(
  parameter SIGCNT   = 1,
  parameter DEF_INIT = {SIGCNT{1'b0}}) (
  input               reset,
  input               clk,
  input               tick,
  input  [SIGCNT-1:0] signal_in,
  output [SIGCNT-1:0] detect_pe,
  output [SIGCNT-1:0] detect_ne,
  output [SIGCNT-1:0] detect_any
);

reg  [SIGCNT-1:0] signal_in_reg;

always @(posedge clk or posedge reset) begin
  if (reset)
    signal_in_reg <= DEF_INIT;
  else if (tick)
    signal_in_reg <= signal_in;
end

assign detect_pe  =  signal_in & ~signal_in_reg;
assign detect_ne  = ~signal_in &  signal_in_reg;
assign detect_any =  detect_pe | detect_ne;

endmodule

