//=================================================================================================--
// Copyright(c) 2021, CLOUDNINEINFO.CO, Ltd, All right reserved
// Filename   : AIS03MB03.v
// Project    : CLOUDNINEINFO common code
// Author     : dingxianhua
// Date       : 2020-09-24
// Email      : dingxianhua@cloudnineinfo.com
// Company    : CLOUDNINEINFO.CO., Ltd
// Description: This module handles the PSU logic. This includes control, status and brownout
//   management.
// History    :
//   Date      By          Revision  Change Description
//=================================================================================================

module psu #(
  parameter NUM_PSU           = 2,    // number of PSU supported
  parameter BROWNOUT_WARN_VAL = 5) (  // (1ms * 5 = 5ms) time for detecting brownout warning
  input                    clk,               // main clock (100MHz)
  input                    reset,             // reset
  input                    t1us,              // 10ns pulse every 1us
  input                    t1ms,              // 10ns pulse every 1ms
  input                    t1s,               // 10ns pulse every 1s
  input      [NUM_PSU-1:0] xreg_ps_enable,    // Xreg ps_enable bits
  input      [NUM_PSU-1:0] xreg_ps_mismatch,  // Xreg ps_mismatch indicator
  input                    gpo_cpld_rst,      // GPO byte3[4]
  input              [5:0] power_seq_sm,      // power sequencer current state
  input                    power_supply_on,   // power supply enable
  input                    bad_fuse_det,      // bad fuse detect (overcurrent trip)
  input                    lom_prsnt_n,       // LOM presence
  input                    lom_fan_on_aux,    // LOM fan enabled - forces PSU to output 12V
  input      [NUM_PSU-1:0] ps_prsnt_n,        // PSU presence
  input      [NUM_PSU-1:0] ps_acok,           // PSU ACOK
  input      [NUM_PSU-1:0] ps_dcok,           // PSU DCOK
  input                    pgd_p12v_droop,    // PSU 12V good status
  output reg [NUM_PSU-1:0] ps_on_n,           // PSU PSx_ON_P12V_N driver
  output                   ps_cyc_pwr_n,      // PSU power cycle
  output reg               ps_acok_link,      // PSU acok_link
  output reg [NUM_PSU-1:0] ps_fail,           // PSU fail indicator
  output                   ps_caution,        // Any of the PSU failed (at least one good)
  output                   ps_critical,       // All active PSU have failed
  output reg               brownout_warning,  // Brownout warning indicator
  output reg               brownout_fault     // Brownout fault indicator
);

`include "pwrseq_define.vh"

// Derive number of bits needed for counter
// - This may generate one more than required number of FFs
function integer clogb2 (input [31:0] value);
reg [31:0] tmp;
begin
  tmp = (value == 1) ? 1 : (value - 1);
  for (clogb2 = 0; tmp > 0; clogb2 = clogb2 + 1)
    tmp = tmp >> 1;
end
endfunction

localparam num_warn_bits = clogb2(BROWNOUT_WARN_VAL);
localparam num_warn_msb  = num_warn_bits - 1;
localparam num_psu_bits  = clogb2(NUM_PSU + 1);
localparam num_psu_msb   = num_psu_bits - 1;

wire                  st_off_standby     ;
wire                  st_ps_on           ;
wire                  st_steady_pwrok    ;
wire                  st_critical_fail   ;
wire                  st_halt_power_cycle;
wire    [NUM_PSU-1:0] ps_acok_valid;
reg     [NUM_PSU-1:0] in_service;
wire                  brownout_event;
reg  [num_warn_msb:0] warn_count;
reg     [NUM_PSU-1:0] cur_ps_enable;
wire                  psu_count_full;
reg   [num_psu_msb:0] psu_count;
reg             [1:0] prsnt_count;
reg                   multi_psu_reg;
wire                  multi_psu;
wire                  ps_acok_link_raw;
reg             [2:0] delay_count;

  assign st_off_standby      = (power_seq_sm==SM_OFF_STANDBY     );
  assign st_ps_on            = (power_seq_sm==SM_PS_ON           );
  assign st_steady_pwrok     = (power_seq_sm==SM_STEADY_PWROK    );
  assign st_critical_fail    = (power_seq_sm==SM_CRITICAL_FAIL   );
  assign st_halt_power_cycle = (power_seq_sm==SM_HALT_POWER_CYCLE);

  assign ps_acok_valid       =  ps_acok & ~ps_prsnt_n;

//------------------------------------------------------------------------------
// PS enable control
// - The physical pin driving the PSU should not react right away based on
//   xreg_ps_enable during power down.
// - When powerdown is started, the logic below will keep the current state
//   of the PSU pins seen while power sequencer is in SM_STEADY_PWROK. This
//   keeps the PSU turned on until the power-down is complete.
//------------------------------------------------------------------------------
// cur_ps_enable will only reflect xreg_ps_enable during standby or while system
// is up. On the start of powerdown sequence, the current state is kept until
// system is back in standby state.
always @(posedge clk or posedge reset)
begin
  if (reset)
    cur_ps_enable <= {NUM_PSU{1'b0}};
  else if (t1us && (st_off_standby || st_steady_pwrok))
    cur_ps_enable <= xreg_ps_enable;
end

// Force all PSU on if lom_fan_on_aux is asserted. Otherwise, depend on state
// of power_supply_on for enablement. Also, only enable PSU bit that are present.
// Per Gen9 power supply team, ps_on_n should not be disabled during brownout
// condition. We'll use brownout_fault to keep this enabled.
always @(posedge clk or posedge reset)
begin
  if (reset)
    ps_on_n <= {NUM_PSU{1'b1}};
  else if (t1us)
  begin
    if (lom_fan_on_aux && !lom_prsnt_n)
      ps_on_n <= ps_prsnt_n;
    else if (power_supply_on || brownout_fault)
      ps_on_n <= ~cur_ps_enable | ps_prsnt_n;
    else
      ps_on_n <= {NUM_PSU{1'b1}};
  end
end


//------------------------------------------------------------------------------
// Brownout logic
//------------------------------------------------------------------------------
// PS-in-service
// - A PSU can be installed but not plugged in. This results in ps_acok being
//   low. This PSU is considered out-of-service and should not be taken as a
//   brownout event.
// - A PSU is considered in-service if during the time the PSU is turned on,
//   ps_acok is set. It remains in service for as long it's enabled.
always @(posedge clk or posedge reset)
begin
  if (reset)
    in_service <= {NUM_PSU{1'b0}};
  else if (t1ms && !power_supply_on)
    in_service <= {NUM_PSU{1'b0}};
  else if (t1ms && power_supply_on)
    in_service <= cur_ps_enable & (ps_acok_valid | in_service);
end

// Brownout event is when acok went out for any of the in-service PSU.
assign brownout_event = |(~ps_acok_valid & in_service);

// If brownout event last for BROWNOUT_WARN_VAL*1ms, assert brownout warning
// flag. Clear counter when brownout event goes away or on next power-on attempt.
always @(posedge clk or posedge reset)
begin
  if (reset)
  begin
    warn_count       <= {num_warn_bits{1'b0}};
    brownout_warning <= 1'b0;
  end
  else if ((t1ms && !brownout_event) || st_ps_on)
  begin
    warn_count       <= {num_warn_bits{1'b0}};
    brownout_warning <= 1'b0;
  end
  else if (t1ms && (warn_count == BROWNOUT_WARN_VAL))
  begin
    warn_count       <= warn_count;
    brownout_warning <= 1'b1;
  end
  else if (t1ms)
    warn_count       <= warn_count + 1'b1;
end

// Brownout fault is when pgd_p12v_droop goes out while we have a brownout event.
// Note that the power sequencer will detect de-assertion of pgd_p12v_droop and
// will initiate a power-down. Cleared on next power-on attempt.
always @(posedge clk or posedge reset)
begin
  if (reset)
    brownout_fault <= 1'b0;
  else if (st_ps_on)
    brownout_fault <= 1'b0;
  else if (brownout_warning && !pgd_p12v_droop)
    brownout_fault <= 1'b1;
end


//------------------------------------------------------------------------------
// ps_fail logic
// - PSU is considered fail when it's turned on but DCOK went low.
// - It's not a failure when DCOK went down due to over current condition
//   (bad_fuse_det).
//------------------------------------------------------------------------------
always @(posedge clk or posedge reset)
begin
  if (reset)
    ps_fail <= {NUM_PSU{1'b0}};
  else if (t1us && st_ps_on)
    ps_fail <= {NUM_PSU{1'b0}};
  else if (t1us && !bad_fuse_det && (st_steady_pwrok || st_critical_fail))
    ps_fail <= (~ps_dcok & ~ps_prsnt_n) | xreg_ps_mismatch;
end


//------------------------------------------------------------------------------
// ps_caution
// - Asserts when any of the PSU is in failed condition
//------------------------------------------------------------------------------
assign ps_caution = |ps_fail;


//------------------------------------------------------------------------------
// ps_critical
// - Asserts when all of the PSU are in failed condition.
// - A non-installed PSU is considered 'fail' in the logic below so it's
//   basically controlled by the installed PSU. If all bits are high, then there
//   are no working PSU.
//------------------------------------------------------------------------------
assign ps_critical = &(ps_fail | ps_prsnt_n);


//------------------------------------------------------------------------------
// ps_cyc_pwr_n
// - Allow cpld_reset (GPO byte3[4] to toggle this when in standby or in halt
//   power cycle state.
//------------------------------------------------------------------------------
assign ps_cyc_pwr_n = ~(gpo_cpld_rst & (st_off_standby | st_halt_power_cycle));


//------------------------------------------------------------------------------
// ps_acok_link
// - Low when there's only one power supply present. Otherwise, each PSU's
//   ACOK and DCOK contributes to overall status.
// - Each PSU contribution is high when its ACOK is high and DCOK transitions high.
//   It goes low when either of its ACOK or DCOK goes low.
// - ps_prsnt_n going high will force that PSU's contribution high.
// - Low-to-high transition is delayed for at least 5s (max: 10s).
// - High-to-low transition has no delay.
//------------------------------------------------------------------------------

// Detect 'reverse' one-hot encoding on ps_prsnt_n (only 1 bit is low). Sequential
// logic will be used so a delay of NUM_PSU clock cycle is needed for status refresh.
//   1. Initialize multi_ps[1:0] to 2'b00
//   2. Scan ps_prsnt_n vector from 0 to NUM_PSU-1.
//   3. If ps_prsnt_n[i] is 0, left shift a 1 to multi_ps[1:0].
//   4. Keep scanning until NUM_PSU-1. If multi_ps[1:0] = 2'b11, at least two PSU
//      is installed.
//   5. Keep current status until the next full scan.
//
// To preserve logic, if NUM_PSU is <= 2, use simple logic gate. The logic below is
// made complicated by the use of parameterized NUM_PSU.
genvar i;
generate if (NUM_PSU <= 2) begin : _NUM_PSU_2_OR_SMALLER_ // multi_psu logic generation
    // If it's 2, use NOR gate. If it's 1 or 0, force low.
    assign multi_psu = (NUM_PSU == 2) ? ~|ps_prsnt_n : 1'b0;
  end
  else begin
    always @(posedge clk or posedge reset) begin
      if (reset) begin
        psu_count     <= {num_psu_bits{1'b0}};
        prsnt_count   <= 2'b00;
        multi_psu_reg <= 1'b0;
      end
      else begin
        // Counter
        psu_count <= (psu_count_full) ? {num_psu_bits{1'b0}} : psu_count + 1'b1;

        // Left shift a 1 to prsnt_count for every 0 bit in ps_prsnt_n. Note that
        // psu_count_full will exceed the array bound of ps_prsnt_n but we're
        // not checking for it anymore.
        if (psu_count_full)
          prsnt_count <= 2'b00;
        else if (!ps_prsnt_n[psu_count])
          prsnt_count <= {prsnt_count[0], 1'b1};

        // Update multi_psu_reg on full count
        if (psu_count_full)
          multi_psu_reg <= &prsnt_count;
      end
    end

    assign psu_count_full = (psu_count == NUM_PSU);
    assign multi_psu      = multi_psu_reg;
  end
endgenerate

assign ps_acok_link_raw = multi_psu & (&(ps_acok & ps_dcok));

// Delay low-to-high transition for ~6s. High-to-low is immediate
always @(posedge clk or posedge reset)
begin
  if (reset)
  begin
    ps_acok_link <= 1'b0;
    delay_count  <= 3'b000;
  end
  else if (!ps_acok_link_raw)
  begin
    ps_acok_link <= 1'b0;
    delay_count  <= 3'b000;
  end
  else if (&delay_count)
    ps_acok_link <= 1'b1;
  else if (t1s)
    delay_count  <= delay_count + 1'b1;
end

endmodule
