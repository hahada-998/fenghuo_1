//=================================================================================================--
// Copyright(c) 2021, CLOUDNINEINFO.CO, Ltd, All right reserved
// Filename   : AIS03MB03.v
// Project    : CLOUDNINEINFO common code
// Author     : dingxianhua
// Date       : 2020-09-24
// Email      : dingxianhua@cloudnineinfo.com
// Company    : CLOUDNINEINFO.CO., Ltd
// Description: This module provides the control interface for the UID button. The UID button
//   function is overloaded to provide UID LED control as well as a method for generating soft and
//   hard resets to iLO.
//   UID presses of less than SOFT_RESET_LIMIT will simply invert the state of the UID LED.
//   UID presses of at least SOFT_RESET_LIMIT but less than HARD_RESET_LIMIT will result in iLO
//   being soft reset. iLO soft reset will encounter a reset pulse duration of SOFT_RESET_DURATION
//   on iLO's ilo_rstreq_n pin.
//   UID presses of HARD_RESET_LIMIT or longer will result in iLO being hard reset. iLO soft reset
//   will encounter a reset pulse duration of HARD_RESET_DURATION on iLO's ilo_rstreq_n pin.
//   Notes:
//   (1) Getting clarification from Binh Nguyen on need for UID_BUTTON_MASK
//   (2) Some timer ticks are not in phase (assertions do not occur within the same clock cycle).
//       This was noticed on t1us and t250ms during module debug.
// History    :
//   Date      By          Revision  Change Description
//=================================================================================================

module uid_top_level (
   reset_n,
   clk,
   t500ms,
   t250ms,
   t62p5ms,
   t1us,
   uid_button_in_n,
   userGPOtoggle,
   gpo_uid_blink,
   uid_state_latch,
   gmt_uid_mux,
   ilo_hw_reset_enable,
   force_leds_on,
   uid_on_level,

   uid_out,
   uid_gpi_in_n,
   uid_blink_status_n,
   uid_state,
   ilo_hard_reset,
   ilo_rstreq_n
);

input         reset_n;                  // Reset (connect to aux power good in top level)
input         clk;                      // 100 MHz clock
input         t1us;                     // 1us timer tick (10ns wide)
input         t62p5ms;                  // 62.5ms timer tick (10ns wide)
input         t250ms;                   // 250ms timer tick (10ns wide)
input         t500ms;                   // 500ms timer tick (10ns wide)
input         uid_button_in_n;          // UID button press signal (virtual or physical)
input         userGPOtoggle;            // iLO GPO scan chain UID toggle
input         gpo_uid_blink;            // iLO GPO blink control
input         uid_state_latch;          // iLO UID hold state (UID_STATE_LATCH)
input [1:0]   gmt_uid_mux;              // iLO UID mux control
input         ilo_hw_reset_enable;      // iLO disable UID-based reset feature (from Xregister)
input         force_leds_on;            // Force all LEDs on for Manufacturing test (0: normal, 1: force on)
input         uid_on_level;             // UID LED on physical level (1=active high, 0=active low)
output reg    uid_out;                  // UID LED output
output        uid_gpi_in_n;             // iLO GPI scan chain input for UID LED status
output        uid_blink_status_n;       // Blink status of UID LED to iLO Xregister
output        uid_state;                // Indicator of UID state to iLO Xregister
output reg    ilo_hard_reset;           // Indicates a hard reset is pending to iLO Xregister W1C
output reg    ilo_rstreq_n;             // iLO reset pin control signal (1=run,0=reset)

//------------------------------------------------------------------------------
// Local Parameters
//------------------------------------------------------------------------------
parameter
   WDT_TIMER_LIMIT           = 6'd20,   // Watchdog timer used in various phases of the UID press/hold control loop (250ms*20 = 5 seconds)
   HARD_RESET_LIMIT          = 6'd32,   // UID press+hold threshold for initiating soft iLO reset (250ms*32 = 8 seconds)//w17260 1010
   HARD_RESET_DURATION       = 4'd12;   // Assertion length of iLO's REQRST_N when hard reset is initiated (250ms*12 = 3 seconds); Set NO GREATER THAN 'd15

// State machine definitions
parameter
   SM_UID_PRESS_RST          = 1'b0,
   SM_UID_PRESS              = 1'b1;

// State machine definitions
parameter
   SM_UID_SERVICE_RST        = 3'h0,
   SM_PRE_HARD_RESET_SERVICE = 3'h1,
   SM_HARD_RESET_SERVICE     = 3'h2,
   SM_BOGUS_5                = 3'h3,
   SM_BOGUS_6                = 3'h4,
   SM_BOGUS_7                = 3'h5;

//------------------------------------------------------------------------------
// Local Variables
//------------------------------------------------------------------------------
reg        uid_press_sm;              // UID press state machine registers
reg  [2:0] uid_service_sm;            // UID service state machine registers
reg  [5:0] uid_button_cnt;            // Counts the duration that UID button is pressed (250ms increments)
reg  [5:0] wdt_counter;               // Watchdog timer / second counter
reg  [3:0] ilo_reset_assert_counter;  // Counter for 250ms increments for soft/hard reset
reg        wdt_to_5s;                 // Watchdog timer flag -- trips at 5 seconds

reg        uid_button_mask;           // Mask UID button **** MAY NOT BE NEEDED ****
//reg        ilo_soft_reset_queued;     // iLO soft reset has been queued for servicing
reg        ilo_hard_reset_queued;     // iLO hard reset has been queued for servicing

wire       temp_uid_out;              // UID output control from UID module

//------------------------------------------------------------------------------
// Processes
//------------------------------------------------------------------------------
// *****************************************************************************
// * MONITOR UID BUTTON PRESS DURATION                                         *
// *                                                                           *
// * Detect when the UID button is pressed and released. When pressed, count   *
// * how long the UID button is pressed, up to a maximum of 9 seconds. A       *
// * separate state machine will monitor the count output of this state        *
// * machine.                                                                  *
// *****************************************************************************
always @(posedge clk or negedge reset_n) begin
   if (!reset_n) begin
      uid_press_sm               <= SM_UID_PRESS_RST;   // Reset state
      uid_button_cnt             <= 6'd0;               // Zero counter
   end
   else begin
      case (uid_press_sm)
         SM_UID_PRESS_RST: begin         // Wait for UID button press while UID button unmasked and iLO reset mask is disabled
            if (!uid_button_in_n && !uid_button_mask && ilo_hw_reset_enable)
               uid_press_sm      <= SM_UID_PRESS;
         end
         SM_UID_PRESS: begin
            if (uid_button_in_n) begin   // Check if UID button is released
                uid_press_sm     <= SM_UID_PRESS_RST;
                uid_button_cnt   <= 6'd0;
            end
            else begin                   // UID still pressed, increment counter every 250ms
               if (t250ms && (uid_button_cnt != HARD_RESET_LIMIT))   // Check if held for hard reset
                  uid_button_cnt <= uid_button_cnt + 6'd1;
               else
                  uid_button_cnt <= uid_button_cnt;
            end
         end
         default: begin                  // Any other state, clear counter and go to reset state
            uid_press_sm         <= SM_UID_PRESS_RST;
            uid_button_cnt       <= 6'd0;
         end
      endcase
   end // if (!reset_n) else
end // always block

always @(posedge clk or negedge reset_n) begin
   if (!reset_n) begin
      wdt_counter            <= 6'd0;
      wdt_to_5s              <= 1'b0;
   end
   else begin
      if ((uid_service_sm == SM_PRE_HARD_RESET_SERVICE) ||    // Check to reset watchdog counters/flags
          (uid_service_sm == SM_UID_SERVICE_RST)) begin
         wdt_counter         <= 6'd0;
         wdt_to_5s           <= 1'b0;
      end
      else if (t250ms) begin                                 // Otherwise, check the following every 250ms
         if (wdt_counter == WDT_TIMER_LIMIT)                 // WDT expired, keep current count
            wdt_counter      <= wdt_counter;
         else
            wdt_counter[5:0] <= wdt_counter[5:0] + 6'd1;     // Else increment counter
         if (wdt_counter == WDT_TIMER_LIMIT)                 // Check for WDT expiration
            wdt_to_5s        <= 1'b1;
      end // else if (t250ms)
   end // if (!reset_n) else
end // always block

// *****************************************************************************
// * MONITOR UID PRESS COUNT TO DETERMINE IF ILO NEEDS TO BE RESET             *
// *****************************************************************************
always @(posedge clk or negedge reset_n) begin
   if (!reset_n) begin
      uid_service_sm              <= SM_UID_SERVICE_RST;
      uid_button_mask             <= 1'b0;
      ilo_hard_reset              <= 1'b0;
   end
   else begin
      if (t1us) begin
         case (uid_service_sm)
            SM_UID_SERVICE_RST:                            // Reset/default state
            begin
               uid_button_mask    <= 1'b0;                 // Clear mask for UID button
               ilo_hard_reset     <= 1'b0;                 // Clear hard reset
               if (uid_button_cnt == HARD_RESET_LIMIT)     // Counter has reached soft reset limit
               begin
                  uid_service_sm  <= SM_PRE_HARD_RESET_SERVICE;
                  ilo_hard_reset  <= 1'b1;                 // Set hard reset flag
               end
               else
               begin
                  uid_service_sm  <= SM_UID_SERVICE_RST;
                  ilo_hard_reset  <= 1'b0;                  // Clear soft reset
               end
            end
            SM_PRE_HARD_RESET_SERVICE:                     // Hard reset (pre) handler
            begin
               uid_service_sm     <= SM_HARD_RESET_SERVICE;
               ilo_hard_reset     <= 1'b1;                 // Set hard reset flag
               uid_button_mask    <= 1'b1;                 // Set mask for UID button
            end
            SM_HARD_RESET_SERVICE:                         // Hard reset handler
            begin
               ilo_hard_reset     <= 1'b1;                 // Set hard reset flag
               uid_button_mask    <= 1'b1;                 // Set mask for UID button
               if (wdt_to_5s && (uid_button_cnt == 6'd0))  // Wait for UID button release
               begin
                  uid_service_sm  <= SM_UID_SERVICE_RST;
               end
            end
            SM_BOGUS_5:                                    // Spare CPLD state
            begin
               ilo_hard_reset     <= 1'b0;                 // clear hard reset
               uid_button_mask    <= 1'b0;
               uid_service_sm     <= SM_UID_SERVICE_RST;   // goto reset state
            end
            SM_BOGUS_6:                                    // Spare CPLD state
            begin
               ilo_hard_reset     <= 1'b0;                 // clear hard reset
               uid_button_mask    <= 1'b0;
               uid_service_sm     <= SM_UID_SERVICE_RST;   // goto reset state
            end
            SM_BOGUS_7:                                    // Spare CPLD state
            begin
               ilo_hard_reset     <= 1'b0;                 // clear hard reset
               uid_button_mask    <= 1'b0;
               uid_service_sm     <= SM_UID_SERVICE_RST;   // goto reset state
            end
         endcase
      end // if (t1us)
      else begin                                           // No conditional match
         ilo_hard_reset           <= ilo_hard_reset;
         uid_service_sm           <= uid_service_sm;
         uid_button_mask          <= uid_button_mask;
      end
   end // else begin [ of if (!reset_n) ]
end

// *****************************************************************************
// * iLO RESET PULSE GENERATOR                                                 *
// *                                                                           *
// * Generate a SOFT_RESET_DURATION length pulse when a soft reset has been    *
// * requested; else, generate a HARD_RESET_DURATION length pulse when a hard  *
// * reset has been requested.                                                 *
// *                                                                           *
// * When a reset request is made, the ilo_reset_assert_counter starts.        *
// * The iLO RSTREQ_N signal is asserted when the counter is non-zero          *
// *                                                                           *
// * NOTE: Ensure that the timer tick for the soft/hard reset queues is the    *
// *       same timer tick that is used in the other control flows for set /   *
// *       reset of the queued requests.                                       *
// *****************************************************************************
always @(posedge clk or negedge reset_n) begin
   if (!reset_n) begin
      ilo_rstreq_n             <= 1'b1;      // Remove reset
      ilo_reset_assert_counter <= 4'b0;      // Number of 250ms ticks iLO reset is asserted
      ilo_hard_reset_queued    <= 1'b0;      // Queue flag for pending iLO hard reset
   end
   else begin

      ilo_hard_reset_queued    <= (t1us && (uid_service_sm == SM_PRE_HARD_RESET_SERVICE)) ? 1'b1 :
                                  (ilo_hard_reset_queued && !(ilo_reset_assert_counter == HARD_RESET_DURATION));
      ilo_rstreq_n             <= (ilo_reset_assert_counter == 4'd0);
		ilo_reset_assert_counter <= t250ms ? ((ilo_hard_reset_queued) ?
                                           ilo_reset_assert_counter + 4'd1 : 4'd0) : ilo_reset_assert_counter;
      /*ilo_reset_assert_counter <= t250ms ? ((ilo_soft_reset_queued || ilo_hard_reset_queued) ?
                                           ilo_reset_assert_counter + 4'd1 : 4'd0) : ilo_reset_assert_counter;*/
   end
end

// *****************************************************************************
// * UID LED Control                                                           *
// *                                                                           *
// * On soft reset, override UID LED with a 4Hz blink pattern. On hard reset,  *
// * override UID LED with an 8Hz blink pattern.                               *
// *****************************************************************************
always @(posedge clk or negedge reset_n) begin
   if (!reset_n)
      uid_out    <= 1'b0;
   else begin
      if (ilo_hard_reset )
         uid_out <= t62p5ms ? !uid_out : uid_out;   // Blink UID @ 4 Hz if hard reset
      else
         uid_out <= temp_uid_out;
   end
end

//------------------------------------------------------------------------------
// Instantiate uid sub-module
//------------------------------------------------------------------------------
uid uid_inst (
   // Inputs
   .sys_clk            (clk),                  // CPLD 100MHz common clock
   .reset_n            (reset_n),              // Module reset (vauxpgood)
   .t500ms             (t500ms),               // 500ms timer tick (10ns wide)
   .gpo_uid_blink      (gpo_uid_blink),        // From GPO chain
   .gmt_uid_blink      (uid_state_latch),      // From XREGs
   .gmt_uid_mux        (gmt_uid_mux),          // MUX LED control
   .user_gpo_toggle    (userGPOtoggle),        // iLO GPO register 0-1-0 toggle
   .force_leds_on      (force_leds_on),        // GPO to enable LED force for MFG'ing test
   .uid_on_level       (uid_on_level),         // UID physical on value (1=active hi, 0=active low)

   // Outputs
   .uid_gpi_in_n       (uid_gpi_in_n),         // From GPO chain
   .uid_blink_status_n (uid_blink_status_n),   // To GPI chain
   .uid_led_out        (temp_uid_out),         // Drives uid leds,
   .uid_xbit_state     (uid_state)             // High true assert when uid_on_level = 1
);

endmodule
