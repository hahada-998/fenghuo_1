//=================================================================================================
// Copyright(c) 2017, New H3C Technologies Co., Ltd, All right reserved
// Filename   : nic_leds.v
// Project    : CLOUDNINEINFO common code
// Author     : dingxianhua
// Date       : 2017-07-18
// Email      : dingxianhua@cloudnineinfo.com
// Company    : CLOUDNINEINFO.CO., Ltd
// Description: This module is used for generating NIC LED outputs for both the front panel and
//   for SID displays. The NUMBER_OF_NICS parameter is used designate the number of NIC to be
//   supported.
// History    :
//   Date      By          Revision  Change Description
//=================================================================================================

module nic_leds #(parameter NUMBER_OF_NICS = 2)
  (
    input  wire                       sys_clk,
    input  wire                       reset_n,
    input  wire                       lom_present_n,
    input  wire                       t62p5ms,
    input  wire [NUMBER_OF_NICS-1:0]  nic_link,
    input  wire [NUMBER_OF_NICS-1:0]  nic_act,
    input  wire                       power_fault,
    input  wire                       fault_blink_code,
    output wire [NUMBER_OF_NICS-1:0]  sid_nic_leds,
    output wire                       fp_nic_led);

wire         lom_present;
wire         all_link;
wire         all_act;

reg  [1:0]   all_act_stretch;

// Individual nic leds: if power is on and lom installed light the led
// if the link is established. Then, blink if there is activity on the link.
assign lom_present = !lom_present_n;
assign sid_nic_leds = {NUMBER_OF_NICS{reset_n}} &     // PCH_SYS_PWROK
                      {NUMBER_OF_NICS{lom_present}} & // lom present
                       nic_link &                     // link connected
                      ~nic_act;                       // led off if activity

// Front panel led: blinky if activity on any of individual links
assign all_link = |nic_link; // active if link on any nic
assign all_act  = |nic_act;  // active if activity on any nic

assign fp_nic_led = (power_fault) ? fault_blink_code :
                                    (reset_n && lom_present && all_link && 
                                    (all_act_stretch[1] || t62p5ms));

always @(posedge sys_clk or negedge reset_n)
  begin
    if (!reset_n)
      begin
        all_act_stretch <= 2'b00;
      end
    else
      begin
        all_act_stretch <= all_act ? 2'b00 : (t62p5ms && ~all_act_stretch[1]) ?
                           all_act_stretch + 2'b01 : all_act_stretch;
      end
  end

endmodule
