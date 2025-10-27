//=================================================================================================--
// Copyright(c) 2021, CLOUDNINEINFO.CO, Ltd, All right reserved
// Filename   : AIS03MB03.v
// Project    : CLOUDNINEINFO common code
// Author     : dingxianhua
// Date       : 2020-09-24
// Email      : dingxianhua@cloudnineinfo.com
// Company    : CLOUDNINEINFO.CO., Ltd
// Description: This module detects faults by monitoring the vrm_pgood signal. vrm_enable must be
//   enabled first before any monitoring is done. In addition, a high on vrm_chklive_en is
//   required to enable monitoring. This is an indication that vrm_pgood must be monitored now.
//   A high on vrm_chklive_dis causes the monitoring to be turned off. These two signals provide
//   a window for checking vrm_pgood as opposed to only checking the the signal at certain point
//   in power sequencer.
// History    :
//   Date      By          Revision  Change Description
//=================================================================================================

module fault_detectB_chklive #(parameter NUMBER_OF_VRM = 1) (
  input                          clk,              // clock
  input                          reset,            // reset
  input      [NUMBER_OF_VRM-1:0] vrm_enable,       // VRM enable signal
  input      [NUMBER_OF_VRM-1:0] vrm_pgood,        // VRM power good signal
  input      [NUMBER_OF_VRM-1:0] vrm_chklive_en,   // enable checking of VRM
  input      [NUMBER_OF_VRM-1:0] vrm_chklive_dis,  // disable checking of VRM
  input                          critical_fail,    // power sequencer in critical fail state
  input                          fault_clear,      // clear fault flags
  input                          lock,             // lock out any fault capture
  output reg                     any_vrm_fault,    // any vrm_fault bit asserted
  output reg [NUMBER_OF_VRM-1:0] vrm_fault         // fault indicator flag, 1 = fault
);

wire                     lock_en;
reg  [NUMBER_OF_VRM-1:0] chklive_en;
wire [NUMBER_OF_VRM-1:0] monitor_en;
wire [NUMBER_OF_VRM-1:0] fault_event;

assign lock_en = any_vrm_fault | lock;

genvar i;
generate
  for (i = 0; i < NUMBER_OF_VRM; i = i + 1)
  begin : _fault_detect_
    // Assert chklive_en on vrm_chklive_en assertion and clear on vrm_chklive_dis.
    // This provides the window of checking.
    always @(posedge clk or posedge reset) begin
      if (reset)
        chklive_en[i] <= 1'b0;
      else if (vrm_chklive_dis[i])
        chklive_en[i] <= 1'b0;
      else if (vrm_chklive_en[i])
        chklive_en[i] <= 1'b1;
    end

    assign monitor_en[i]  = chklive_en[i] | critical_fail;
    assign fault_event[i] = vrm_enable[i] & ~vrm_pgood[i];

    always @(posedge clk or posedge reset) begin
      if (reset)
        vrm_fault[i] <= 1'b0;
      else if (fault_clear)
        vrm_fault[i] <= 1'b0;
      else if (~lock_en && monitor_en[i] && fault_event[i])
        vrm_fault[i] <= 1'b1;
    end
  end
endgenerate

// any_vrm_fault asserts if any fault is detected here. This will be used for
// locking out further faults.
always @(posedge clk or posedge reset) begin
  if (reset)
    any_vrm_fault <= 1'b0;
  else if (fault_clear)
    any_vrm_fault <= 1'b0;
  else
    any_vrm_fault <= |vrm_fault;
end

endmodule

