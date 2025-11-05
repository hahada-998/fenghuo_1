//=================================================================================================--
// Copyright(c) 2021, CLOUDNINEINFO.CO, Ltd, All right reserved
// Filename   : AIS03MB03.v
// Project    : CLOUDNINEINFO common code
// Author     : dingxianhua
// Date       : 2020-09-24
// Email      : dingxianhua@cloudnineinfo.com
// Company    : CLOUDNINEINFO.CO., Ltd
// Description: This block of code handles synch, latching, and qualification logic associated
//   with error signals from the chipset.
//   Notes: Assumes error signals, such cpu_caterr and msmi_n are wire-OR externally. This module
//   is not capable of "repeating" errors as is required in multi-node/uP-island systems.
// History    :
//   Date      By          Revision  Change Description
//=================================================================================================

module errors_block (
   input                             clk,                       // core clock, e.g. 100MHz
   input                             t40ns_tick,                // core clock wide tick every 40ns
   input                             t30p5us_tick,              // core clock wide tick every 30.5us
   input                             t125ms_tick,               // core clock wide tick every 125ms
   input                             reset,                     // active-high reset (use a synch'd ~plt_rst_n)
   input                             pgd_aux_system,            // A device wide reset
   input                             sys_pgood,                 // Indication that system DC rails are up and good (signal de-asserts on cold reset or power rail fault)
   input                             cpu_caterr,                // From CPUs; indicates system has encountered a catastrophic, fatal error
   input                             cpu0_prsnt_n,              // Low when CPU0 is present in the system (this should always be LOW)
   input                     [2:0]   cpu_err,                   // {CPU ERROR2 (Fatal, act-high), ERROR1 (Non-fatal, act-high, ERROR0 (HW correctable, act-high)}
   input                             disable_caterr_hold,       // 0(default) = Reset system on CATERR hold, 1 = Do not reset; clears caterr_latch
   input                             enable_caterr_pulse,       // 0(default) = Do not reset system on CATERR pls, 1 = Reset system after 1-2s...
   input                             caterr_rst_en_sw_n,        // When SW is ON (0), disable caterr reset propogation
   input                             rearm_pulse_caterr_det,    // 0(default) = Allow SMI generation on cpu_caterr de-assertion; allow system reset
                                                                //               after 1-2 seconds after cpu_caterr de-assertion,
                                                                // 1          = Clear edge detector.  Must set bit back to "0" in order to look for subsequent
                                                                //               cpu_caterr de-assertions (clear only after min dly of 20us after setting);
                                                                //               Also clears 1-2 second timer to not allow a system reset.
   output                            CPU_CAT_ERR_DLY_N,         // Routes to PCH GPIO8_pin-C41 (CHECKME)
   output                            err2_re,                   // 1-clk high pulse on rising-edge of the err2 signal (IOH or CPU); used in G8
   output reg                        caterr_latch,              // Latch of clk synched cpu_caterr signal
   output                            caterr_hold_reset,         // Reset system when cpu_caterr asserts for more than 16 BCLKs
   output                            caterr_dly_1ms,            // Asserted a ~1ms delay after de-assertion edge of cpu_caterr
   output                            caterr_pulse_reset         // Asserted a 1-2s delay after de-assertion edge of cpu_caterr
);

reg                          [1:0]   disable_caterr_hold_r;
reg                          [1:0]   caterr_r;
reg                                  negedge_caterr_detected;
reg                          [1:0]   caterr_edgedet_r;
reg                          [1:0]   rearm_pulse_caterr_det_r;
reg                          [2:0]   cpu_err_r;
wire                                 caterr_negedge_pls;
wire                                 caterr_hold_detected;
wire                                 caterr_delayed_by_1sec;
wire                                 combined_reset;

assign CPU_CAT_ERR_DLY_N  = 1'bz;
assign caterr_pulse_reset = caterr_delayed_by_1sec &  enable_caterr_pulse      & caterr_rst_en_sw_n;
assign caterr_hold_reset  = caterr_hold_detected   & ~disable_caterr_hold_r[1] & caterr_rst_en_sw_n;
assign caterr_negedge_pls = (caterr_edgedet_r == 2'b10);
assign combined_reset     = reset | ~pgd_aux_system;
assign err2_re            = ~cpu_err_r[2] & cpu_err_r[1];

// Error2 Synch and Neg-edge detect for G8
always @(posedge clk or posedge reset) begin
   if (reset)
      cpu_err_r[2:0] <= 3'b000;
   else
      cpu_err_r[2:0] <= {cpu_err_r[1:0], cpu_err[2]};
end

// Caterr Hold detection:
//  Detect a cpu_caterr when asserted for more than 16 bclk (~484ns)
always @(posedge clk or posedge reset) begin
   if (reset)
      disable_caterr_hold_r[1:0] <= 2'b00;
   else
      disable_caterr_hold_r[1:0] <= {disable_caterr_hold_r[0], disable_caterr_hold};
end

always @(posedge clk or posedge reset) begin
   if (reset)
      caterr_r[1:0] <= 2'b00;
   else
      caterr_r[1:0] <= {caterr_r[0], (cpu_caterr & ~cpu0_prsnt_n)};
end

signal_timer_wclken #(.CNT_SIZE (4)) signal_timer_wclken_caterr_inst (
   .clk             (clk),
   .clk_en          (t40ns_tick),
   .reset           (reset),
   .sig_start_tmr   (caterr_r[1]),
   .timer_expired   (caterr_hold_detected)
);

// CATERR# latch - cleared by rearm_pulse_caterr_det
always @(posedge clk or negedge sys_pgood) begin
   if (!sys_pgood)
         caterr_latch <= 1'b0;
   else
      if (rearm_pulse_caterr_det_r[1])
         caterr_latch <= 1'b0;
      else
         caterr_latch <= caterr_r[1] | caterr_latch;
end

//------------------------------------------------------------------------------
// Caterr Pulse detection:
//  Detect falling-edge of cpu_caterr, and then send a pulse to the GPI chain
//  to generate an SMI after 1mS.  After 1-2 seconds, if not cleared by a GPO,
//  send a pulse to reset system.
//  Note that cpu_caterr is treated as an active high signal so the falling
//  edge must be detected. In PFIS, it's detecting the positive edge since CATERR#
//  is an active low signal.
always @(posedge clk or negedge pgd_aux_system) begin
   if (!pgd_aux_system)
      rearm_pulse_caterr_det_r[1:0] <= 2'b00;
   else
      rearm_pulse_caterr_det_r[1:0] <= {rearm_pulse_caterr_det_r[0], rearm_pulse_caterr_det};
end

always @(posedge clk or posedge combined_reset) begin
   if (combined_reset) begin
      caterr_edgedet_r[1:0]   <= 2'b00;
      negedge_caterr_detected <= 1'b0;
   end
   else begin
      caterr_edgedet_r[1:0]   <= {caterr_edgedet_r[0], (cpu_caterr & ~cpu0_prsnt_n)};
      negedge_caterr_detected <= (negedge_caterr_detected | caterr_negedge_pls) & ~rearm_pulse_caterr_det_r[1];
   end
end

delay_timer #(.CNT_SIZE (6)) delay_timer_1ms_caterr (
   .clk            (clk),
   .reset          (reset),
   .signal_in      (negedge_caterr_detected),
   .cnt_step       (t30p5us_tick),
   .cnt_size       (6'h21),
   .delay_output   (caterr_dly_1ms)
);

delay_timer #(.CNT_SIZE (4)) delay_timer_1s_caterr (
   .clk            (clk),
   .reset          (reset),
   .signal_in      (negedge_caterr_detected & ~rearm_pulse_caterr_det_r[1]),
   .cnt_step       (t125ms_tick),
   .cnt_size       (4'b1001),
   .delay_output   (caterr_delayed_by_1sec)
);

endmodule

