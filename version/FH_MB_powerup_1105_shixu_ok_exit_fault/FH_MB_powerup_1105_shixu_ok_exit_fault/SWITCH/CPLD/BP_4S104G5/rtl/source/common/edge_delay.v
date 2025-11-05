//=================================================================================================--
// Copyright(c) 2021, CLOUDNINEINFO.CO, Ltd, All right reserved
// Filename   : AIS03MB03.v
// Project    : CLOUDNINEINFO common code
// Author     : dingxianhua
// Date       : 2020-09-24
// Email      : dingxianhua@cloudnineinfo.com
// Company    : CLOUDNINEINFO.CO., Ltd
// Description: This module generates a delayed version of the input signal. The edge where the
//   delay should start is selectable through a parameter. The default output is also
//   configurable by parameter to allow for specific power on default.
// Parameter  :
//   CNTR_NBITS: Number of counter bits to support cnt_size.
//    Default: 5
//   DEF_OUTPUT: Specify the starting value for the output signal.
//    Default: 1'b0
//   DELAY_MODE : Specify which edge to delay, 0 for rising, 1 for falling.
//    Default: 1'b0
// History    :
//   Date      By          Revision  Change Description
//=================================================================================================

module edge_delay #(
  parameter  CNTR_NBITS = 5,
  parameter  DEF_OUTPUT = 1'b0,
  parameter  DELAY_MODE = 1'b0) (

  // Clocks and resets
  input      clk,                       // input clock
  input      reset,                     // reset

  // Delay control
  input      [CNTR_NBITS-1:0] cnt_size,   // delay count
  input      cnt_step,                  // time increment (normally ticks)

  // Signals
  input      signal_in,                 // input signal
  output reg delay_output               // signal_in delayed by cnt_size*cnt_step
);

reg [CNTR_NBITS-1:0] timer_cnt;

//------------------------------------------------------------------------------
// Delay logic
// - delay_output is the delayed version of signal_in by cnt_size*cnt_step.
// - the edge delayed is based on DELAY_MODE
// - only a single edge can be delayed. both edges cannot be delayed with in
//   the same instance of this module.
// - edge not specified by DELAY_MODE has no delay and reflected to delay_output
//   immediately
//------------------------------------------------------------------------------
always @(posedge clk or posedge reset) begin
  if (reset) begin
    timer_cnt    <= {CNTR_NBITS{1'b0}};
    delay_output <= DEF_OUTPUT;
  end
  else if (signal_in == DELAY_MODE) begin
    timer_cnt    <= {CNTR_NBITS{1'b0}};
    delay_output <= DELAY_MODE;
  end
  else if (cnt_step) begin
    timer_cnt    <= (timer_cnt != cnt_size) ? (timer_cnt + 1'b1) : timer_cnt;
    delay_output <= (timer_cnt == cnt_size) ? ~DELAY_MODE        : delay_output;
  end
end

endmodule

