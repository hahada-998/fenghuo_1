//=================================================================================================--
// Copyright(c) 2021, CLOUDNINEINFO.CO, Ltd, All right reserved
// Filename   : AIS03MB03.v
// Project    : CLOUDNINEINFO common code
// Author     : dingxianhua
// Date       : 2020-09-24
// Email      : dingxianhua@cloudnineinfo.com
// Company    : CLOUDNINEINFO.CO., Ltd
// Description: This logic is used for UID LED logic control on G9 common code systems
// History    :
//   Date      By          Revision  Change Description
//=================================================================================================

module uid (
   // System clock, 100MHz typical
   input  wire         sys_clk,

   // Used to reset UID FF so that the UID LED is off when you plug in system
   input  wire         reset_n,   // vauxpgood

   // Time base of 1hz blink period
   input  wire         t500ms,

   // Makes UID LED blink at 1Hz.
   input  wire         gpo_uid_blink,

   // Signal from GROMIT PAL to signal when it will blink the UID_LED
   input  wire         gmt_uid_blink,

   // UID mux select signal from xregister
   input  wire [1:0]   gmt_uid_mux,

   // User_gpo_toggle generation
   input  wire         user_gpo_toggle,  // Toggle UID LED from GPO chain

   // Force all LEDs on for Manufacturing test (0: normal, 1: force on)
   input  wire         force_leds_on,

   // UID LED on level, strap that defines uid_led_out "on" state
   input  wire         uid_on_level,

   // Output that shows the current state of the UID_LED when not blinking
   // and latched state of UID_LED prior to blinking
   output reg          uid_gpi_in_n,

   // Output to let software know when UID is blinking. Also latches current
   // state of UID before blinking. 0=blinking
   output wire         uid_blink_status_n,

   // UID LED output to drive LED, 1 = "on"
   output reg          uid_led_out,

   // UID LED state out to feedback to x-bit, 1 = "on"
   output reg          uid_xbit_state
);

reg          uid_ff;          // UID toggle flip flop
reg          blink_sync;      // Synchronize blinking to eliminate "runt" blinks
reg  [2:0]   user_gpo_sync;   // Metastability synchronizer and posedge detect logic

wire         pe_uid;          // posedge detect logic

assign pe_uid          = (user_gpo_sync[2:1] == 2'b01);

// UID FF and posedge event detect
always @(posedge sys_clk or negedge reset_n) begin
   if (!reset_n) begin
      uid_ff         <= ~uid_on_level;   // inital state off (not on)
      user_gpo_sync  <=  3'b000;
      uid_xbit_state <= ~uid_on_level;
   end
   else begin
      uid_ff         <=  pe_uid ? !uid_ff : uid_ff;
      user_gpo_sync  <= {user_gpo_sync[1:0], user_gpo_toggle};
      uid_xbit_state <= (t500ms && gpo_uid_blink)      ? !uid_led_out :
                        ((gpo_uid_blink && blink_sync) ?  uid_led_out :
                                                          uid_ff);
   end
end

always @(posedge sys_clk or negedge reset_n) begin
   if (!reset_n)
      blink_sync <= 1'b0;
   else
      blink_sync <= gpo_uid_blink & (t500ms | blink_sync);
end

always @* begin
   casez ({force_leds_on, gmt_uid_mux})
      3'b1??:  uid_led_out =  uid_on_level;
      3'b000:  uid_led_out =  uid_xbit_state;
      3'b001:  uid_led_out =  uid_xbit_state;
      3'b010:  uid_led_out = ~uid_on_level;   // 1'b0 off
      3'b011:  uid_led_out =  uid_on_level;   // 1'b1 on
      default: uid_led_out = ~uid_on_level;   // 1'b1 off
   endcase
end

// Has someone enabled blinking?
assign uid_blink_status_n = ~(gmt_uid_blink | gpo_uid_blink);

// GPI state latch so that uid_led_out can be restored to "previous state"
//  when hardware controlled blinking is stopped
// Note: This signal is always interpreted as low true assert and must
//        be low when latched state of the LED is "on"
always @(posedge sys_clk or negedge reset_n) begin
   if (!reset_n)
      uid_gpi_in_n <= 1'b1;   // defaults to "off"
   else begin
      uid_gpi_in_n <= (!uid_blink_status_n || blink_sync) ?
                        uid_gpi_in_n :               // holding term
                       (uid_on_level ^ uid_led_out); // flow through term
   end
end

endmodule

