//=================================================================================================--
// Copyright(c) 2021, CLOUDNINEINFO.CO, Ltd, All right reserved
// Filename   : AIS03MB03.v
// Project    : CLOUDNINEINFO common code
// Author     : dingxianhua
// Date       : 2020-09-24
// Email      : dingxianhua@cloudnineinfo.com
// Company    : CLOUDNINEINFO.CO., Ltd
// Description: This module debounces the pme_source input and creates a 1-clock pulse that is used
//   to trigger an interrupt in the xregs block.
// History    :
//   Date      By          Revision  Change Description
//   20170718  QIURONGLIN  1.0       file created
//=================================================================================================

module pme_filter(
   input     clk,
   input     t1hz_tick,
   input     pgoodaux,
   input     pme_source_or_all,   // Combine all pme event sources on this input
   input     pme_mask_n,          // When LOW, mask event pulse
   output    db_pme_source_all,   // The debounced copy of pme_source_or_all
   output    pme_event_pls        // 1-clock pulse to XREG block
);

reg          pme_delayed_reg1_n;
reg          pme_delayed_reg2_n;
reg  [1:0]   all_pme_delayed;

always @(posedge clk or negedge pgoodaux) begin
   if (!pgoodaux) begin
      all_pme_delayed       <= 2'b00;
      pme_delayed_reg1_n    <= 1'b1;
      pme_delayed_reg2_n    <= 1'b1;
   end
   else begin
      if (t1hz_tick) begin
         all_pme_delayed    <= {all_pme_delayed[0], pme_source_or_all};
      end

      pme_delayed_reg1_n <= ~(&all_pme_delayed);
      pme_delayed_reg2_n <= pme_delayed_reg1_n;
   end
end

assign pme_event_pls     = ~pme_delayed_reg1_n & pme_delayed_reg2_n & pme_mask_n;
assign db_pme_source_all = ~pme_delayed_reg1_n;

endmodule
