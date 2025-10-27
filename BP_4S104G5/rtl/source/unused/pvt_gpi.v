//=================================================================================================--
// Copyright(c) 2021, CLOUDNINEINFO.CO, Ltd, All right reserved
// Filename   : AIS03MB03.v
// Project    : CLOUDNINEINFO common code
// Author     : dingxianhua
// Date       : 2020-09-24
// Email      : dingxianhua@cloudnineinfo.com
// Company    : CLOUDNINEINFO.CO., Ltd
// Description: This module implements a serial to parallel conversion routine, which provides for
//   a flexible private chain width and speed through the use of defined input ports and
//   parameters.
//   Set parameters TOTAL_BI_COUNT, NUMBER_OF_COUNTER_BITS in recognition of each other to obtain
//     the desired width.
//   SEGMENT_MIN/MAX may be used to truncate out portions of the chain below/above a desired range.
//   DEFAULT_STATE specifies the reset state of the registered par_data output to help prevent
//     Power-on, reset-release glitches.
// History    :
//   Date      By          Revision  Change Description
//=================================================================================================

module pvt_gpi   #(parameter TOTAL_BIT_COUNT        = 64,
                             DEFAULT_STATE          = 64'h0,
                             SEGMENT_MAX            = TOTAL_BIT_COUNT-1,
                             SEGMENT_MIN            = 0,
                             NUMBER_OF_COUNTER_BITS = 6) (
   input clk,              // fast clock (100MHZ clock domain typical)
   input reset_n,           // CPLD synchronized reset
   input clk_ena,          // Timer Tick in clk domain
   input serclk_in,        // Serial clock in from external device
   input par_load_in_n,    // Serial load in from external device
   input sdi,              // Serial data in from external device
   input      [NUMBER_OF_COUNTER_BITS-1:0] bit_idx_in,    // Bit counter (index) input
   output reg [NUMBER_OF_COUNTER_BITS-1:0] bit_idx_out,   // Bit counter (index) output
   output reg    [SEGMENT_MAX:SEGMENT_MIN] par_data,      // Parallel data output
   output reg                              serclk_out,    // Serial output clock, free running
   output reg                              par_load_out_n // Parallel load_n for external gpio chains
);

wire   gated_clk_ena;
assign gated_clk_ena = clk_ena & ~serclk_in & par_load_in_n;

always @(posedge clk or negedge reset_n) begin
   if (!reset_n)
      par_data    <= DEFAULT_STATE;
   else
      if ((bit_idx_in >= SEGMENT_MIN) && (bit_idx_in <= SEGMENT_MAX) && gated_clk_ena)
         par_data[bit_idx_in] <= sdi;
      else
         par_data <= par_data;
end

always @(posedge clk or negedge reset_n) begin
   if (!reset_n) begin
      serclk_out           <= 1'b0;
      par_load_out_n       <= 1'b0;
      bit_idx_out          <= {NUMBER_OF_COUNTER_BITS{1'b0}};
   end
   else begin
      if (clk_ena)
         serclk_out        <= ~serclk_out;

      if (clk_ena && !serclk_out && par_load_in_n) begin
         if (bit_idx_out == TOTAL_BIT_COUNT-1)
            bit_idx_out    <= {NUMBER_OF_COUNTER_BITS{1'b0}};
         else
            bit_idx_out    <= bit_idx_out + {{NUMBER_OF_COUNTER_BITS-1{1'b0}}, 1'b1};
      end

      if (clk_ena && serclk_out && par_load_in_n) begin
         if (bit_idx_out == {NUMBER_OF_COUNTER_BITS{1'b0}})
            par_load_out_n <= 1'b0;
      end
      else if (clk_ena && serclk_out && !par_load_in_n) begin
         par_load_out_n    <= 1'b1;
      end
   end
end

endmodule
