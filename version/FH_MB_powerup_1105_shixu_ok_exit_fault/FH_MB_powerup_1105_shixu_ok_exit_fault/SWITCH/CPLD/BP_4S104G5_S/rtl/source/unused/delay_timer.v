//=================================================================================================--
// Copyright(c) 2021, CLOUDNINEINFO.CO, Ltd, All right reserved
// Filename   : AIS03MB03.v
// Project    : CLOUDNINEINFO common code
// Author     : dingxianhua
// Date       : 2020-09-24
// Email      : dingxianhua@cloudnineinfo.com
// Company    : CLOUDNINEINFO.CO., Ltd
// Description: This module creates a delayed version of signal_in by (cnt_size*cnt_step). It is
//   asserted while signal_in = 1. When signal_in de-asserts low or reset asserts, delay_output
//   will de-assert LOW asynchronously.
//   Notes:
//    This module assumes the input signal has been synchronized to clk and de-glitched.
//    Example for cnt_size = 1:
//     signal_in:      _______________________|--------------------------------------------------
//     cnt_step:       __|-|________|-|________|-|________|-|________|-|________|-|________|-|___
//                     __________________________ _______________________________________________
//     timer_cntr:                    0          I       1
//                     --------------------------^-----------------------------------------------
//     delay_output:   _____________________________________|------------------------------------
// History    :
//   Date      By          Revision  Change Description
//=================================================================================================

module delay_timer #(parameter CNT_SIZE = 8) (
   input                  clk,           // fast core clock
   input                  reset,         // Asynch reset
   input                  signal_in,     // Input signal to be delayed
   input                  cnt_step,      // Use a clk wide tick for delay
   input [CNT_SIZE-1:0]   cnt_size,      //
   output reg             delay_output   // delay signal_in by (cnt_size*cnt_step)
);

`define ZERO_COUNT {CNT_SIZE{1'b0}}

reg [CNT_SIZE-1:0]        delay_cnt;
wire                      combined_reset = reset | !signal_in;

always@(posedge clk or posedge combined_reset) begin
   if (combined_reset) begin
      delay_cnt       <= `ZERO_COUNT;
      delay_output    <= 1'b0;
   end
   else begin
      if ( (delay_cnt != cnt_size) && cnt_step ) begin
         delay_cnt    <= delay_cnt + {{CNT_SIZE-1{1'b0}}, 1'b1};
         delay_output <= delay_output;
      end
      else if (delay_cnt == cnt_size) begin
         delay_cnt    <= delay_cnt;
         delay_output <= 1'b1;
      end
   end
end

endmodule
