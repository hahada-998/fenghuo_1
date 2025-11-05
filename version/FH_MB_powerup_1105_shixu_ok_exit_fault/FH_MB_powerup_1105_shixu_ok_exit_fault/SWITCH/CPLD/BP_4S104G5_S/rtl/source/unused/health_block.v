//=================================================================================================--
// Copyright(c) 2021, CLOUDNINEINFO.CO, Ltd, All right reserved
// Filename   : AIS03MB03.v
// Project    : CLOUDNINEINFO common code
// Author     : dingxianhua
// Date       : 2020-09-24
// Email      : dingxianhua@cloudnineinfo.com
// Company    : CLOUDNINEINFO.CO., Ltd
// Description: This module is responsible for health related logic, but at this time it is only
//   handling the generation of the green and red blinking Health LEDs as well as the two nets
//   used for health led state feebdack to the XREGs block.  It also sources the cpu_led[*] nets.
//   Note: Assumes fan_caution/critical are handled through iLO health LED GPOs
// History    :
//   Date      By          Revision  Change Description
//=================================================================================================

//`include "wpspo_g5_define.vh"
`include "as03mb03_define.vh"
module health_block (
  input                       clk,                       // core clock, e.g. 100MHz
  input                       t1hz_clk,                  // 50% dc 1Hz clock
  input                       t4hz_clk,                  // 50% dc 4Hz clock
  input                       reset,                     // active-high reset (use a pgd_aux sig)
  input                       pch_sys_pwrok,             // Stand-in for pgood_final
  input                       power_fault,               // An active VRD fault
  input                       fault_blink_code,          // power fault blink code
  input                       gpo_sys_hlth_red,          // ROM indication that Health LED should be lit Red   (active-high)
  input                       gpo_sys_hlth_amb,          // ROM indication that Health LED should be lit Amber (active-high)
  input                       ilo_health_red,            // iLO indication ctrl for Health LED:: 00 = Green  (solid),   01 = Amber (blinking)
  input                       ilo_health_amber,          //                                      10 = Red (blinking),   11 = Red   (blinking)
  input                       interlock_fail,            // Blink Health LED Red when there's an Interlock Failure
  input      [`NUM_CPU-1:0]   cpu_prsnt_n,               // CPU is present (active-low)
  input                       override_cpu_prsnt_sw_n,   // Make it appear that CPUs are all present (active-low)
  input      [`NUM_CPU-1:0]   gpo_cpu_err_led,           // ROM indication that indicated CPU is bad (active-high)
  input                       hsb_fail_n,                // Indicates the BSP was unable to boot (active-low)
  input                       gmt_fail_n,                // iLO FW/HW failure (active-low)
  input                       ps_pgood,                  // Asserted HIGH when at least one PSU is generating 12V DCOK
  input                       ps_on_n,                   // Asserted LOW when pwr_seq enables power to a PSU
  input                       ps_critical,               // From psu sub-module
  input                       ps_caution,                // From psu sub-module
  input                       ilo_reset_in_progress,     //modify by Jerry
  output                      health_led_grn_n,          // Drives Physical Internal HEALTH LED
  output                      health_led_red_n,          // Drives Physical Internal HEALTH LED
  output reg          [1:0]   health_led_fb,             // Feedback to iLO for Int Health LED: 10 = Red, 11 = Amber, 01 = Grn, 00 = Off
  output reg [`NUM_CPU-1:0]   cpu_led                    // CPU Fail LEDs
);

  reg                 health_led_grn;
  reg                 health_led_red;
  reg                 hardware_critical;
  reg                 hardware_caution;
  reg                 fru_critical;
  reg                 fru_caution;
  reg                 ps_crit;
  reg                 ps_caut;
  wire [`NUM_CPU-1:0] pre_cpu_led;
  wire                health_critical;
  wire                health_caution;

// On a power fault, we blink the int health LED 4x the regular 1hz 50% dc
assign health_led_grn_n = (ilo_reset_in_progress==1'b1) ? t4hz_clk : (power_fault ? 1'b1 : ~health_led_grn);
assign health_led_red_n = (ilo_reset_in_progress==1'b1) ? 1'b1 : (power_fault ? fault_blink_code : ~health_led_red);

// CHECKME: Should gpo_cpu_err_led be qualified by cpu_prsnt_n or leave it to SW to know what they're doing.
assign pre_cpu_led      = (~({`NUM_CPU{hsb_fail_n}} | (cpu_prsnt_n & {`NUM_CPU{override_cpu_prsnt_sw_n}})) | gpo_cpu_err_led);

assign health_critical  = fru_critical | ps_crit;
assign health_caution   = fru_caution  | ps_caut;

// Generate CPU LED state based on pre_cpu_led equation (above); latch when sys
//  pwr is lost.
always @(posedge clk or posedge reset) begin
  if (reset)
    cpu_led <= {`NUM_CPU{1'b0}};
  else if (!pch_sys_pwrok)
    cpu_led <= cpu_led;   // Hold state on loss of power
  else begin
    cpu_led[0] <= pre_cpu_led[0] | (cpu_prsnt_n[0] & override_cpu_prsnt_sw_n);
    cpu_led[`NUM_CPU-1:1] <= pre_cpu_led[`NUM_CPU-1:1];
  end
end

// Generate FRU crit and caut registers (crit takes precedence); note that only pre_cpu_led
//  is latched on power loss (CHECKME for correctness)
always @(posedge clk or posedge reset) begin
  if (reset) begin
    hardware_critical <= 1'b0;
    hardware_caution  <= 1'b0;
    fru_critical      <= 1'b0;
    fru_caution       <= 1'b0;
  end
  else begin
    // CHECKME: It seems gpo_cpu_test_ok is depricated (always 1'b1), so I have removed it from the equations
    hardware_critical <=  pch_sys_pwrok ?                ~hsb_fail_n : hardware_critical;
    hardware_caution  <=  pch_sys_pwrok ?  |pre_cpu_led & hsb_fail_n : hardware_caution;
    fru_critical      <=  gpo_sys_hlth_red | ilo_health_red   | hardware_critical | interlock_fail |
                         (cpu_prsnt_n[0] & override_cpu_prsnt_sw_n) | ~gmt_fail_n;   // Blink Health LED Red if the monarch cpu is not present (CHECKME: is this only for AMD as per pg. 55 of Feature Imp Spec v0.3?)
    fru_caution       <= (gpo_sys_hlth_amb | ilo_health_amber | hardware_caution) & ~fru_critical;
  end
end

// Generate ps_crit/caut registers and latch state on loss of ps_on
always @(posedge clk or posedge reset) begin
  if (reset) begin
    ps_crit <= 1'b0;
    ps_caut <= 1'b0;
  end
  else if (ps_on_n) begin
     ps_crit <= ps_crit;
     ps_caut <= ps_caut;
  end
  else begin
     ps_crit <= ps_critical;
     ps_caut <= ps_caution & ~ps_critical;
  end
end

// Drive the key outputs of health_block, internal health LED state based on
//  combined critical and caution inputs
//  (Note, this doesn't have to be in a synchronous always block)
always @(posedge clk or posedge reset) begin
  if (reset) begin
    health_led_grn   <= 1'b0;
    health_led_red   <= 1'b0;
    health_led_fb[1] <= 1'b0;
    health_led_fb[0] <= 1'b0;
  end
  else begin
    case ({health_critical, health_caution})
      2'b00 :   // LED OFF or GRN depending on power state
      begin
         health_led_grn   <= (pch_sys_pwrok | ps_pgood);   // CHECKME: prioritize what constitutes system on?
         health_led_red   <= 1'b0;
         health_led_fb[1] <= power_fault;                                        // 1'b0 when power fault is not active
         health_led_fb[0] <= power_fault ? 1'b0 : (pch_sys_pwrok | ps_pgood);   // Force RED on power fault
      end
      2'b01 :   // LED AMB due to caution condition
      begin
         health_led_grn  <= t1hz_clk;
         health_led_red  <= t1hz_clk;
         health_led_fb[1]<= 1'b1;
         health_led_fb[0]<= power_fault ? 1'b0 : 1'b1;    // Force RED on power fault
      end
      2'b10 :   // LED RED due to critical condition
      begin
         health_led_grn   <= 1'b0;
         health_led_red   <= t1hz_clk;
         health_led_fb[1] <= 1'b1;
         health_led_fb[0] <= 1'b0;
      end
      2'b11 :   // LED RED due to critical condition (crit takes precedence)
      begin
         health_led_grn   <= 1'b0;
         health_led_red   <= t1hz_clk;
         health_led_fb[1] <= 1'b1;
         health_led_fb[0] <= 1'b0;
      end
    endcase
  end
end

endmodule
