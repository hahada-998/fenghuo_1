//=================================================================================================--
// Copyright(c) 2021, CLOUDNINEINFO.CO, Ltd, All right reserved
// Filename   : AIS03MB03.v
// Project    : CLOUDNINEINFO common code
// Author     : dingxianhua
// Date       : 2020-09-24
// Email      : dingxianhua@cloudnineinfo.com
// Company    : CLOUDNINEINFO.CO., Ltd
// Description:
// History    :
//   Date      By          Revision  Change Description
//=================================================================================================

module signal_timer_wclken #(parameter CNT_SIZE = 4) (
   input                  clk,                  // fast core clock
   input                  clk_en,               // clk period wide tic to use or set to "1" for clk
   input                  reset,                // Asynch reset
   input                  sig_start_tmr,        // Start timer counter when "1"
   output reg             timer_expired         // Asserted once timer expires, de-asserted on with sig_start_tmr falling edge
);

`define ZERO_COUNT {CNT_SIZE{1'b0}}

reg      [CNT_SIZE-1:0] counter;

always @(posedge clk or posedge reset) begin
   if(reset) begin
      timer_expired <= 1'b0;
      counter       <= `ZERO_COUNT;
   end
   else if (!sig_start_tmr) begin
      timer_expired <= 1'b0;
      counter       <= `ZERO_COUNT;
   end
   else if (clk_en) begin
      timer_expired <= (&counter) | timer_expired;
      counter       <=   counter + {{CNT_SIZE-1{1'b0}}, 1'b1};
   end
end

endmodule
