//=================================================================================================--
// Copyright(c) 2021, CLOUDNINEINFO.CO, Ltd, All right reserved
// Filename   : AIS03MB03.v
// Project    : CLOUDNINEINFO common code
// Author     : dingxianhua
// Date       : 2020-09-24
// Email      : dingxianhua@cloudnineinfo.com
// Company    : CLOUDNINEINFO.CO., Ltd
// Description: This module Module create a full powercapping function for hp server and include
//   the following three functions:
//   (1) prochot
//   (2) memory throttle
//   (3) power capping LED
//   FIXME: It looks like either BL_MODE or PSU_CTRL (ML/DL) will be defined. This seems odd and
//     could be improved for better readability/linting
//   one of BL_MODE or PSU_CTRL should be defined in the following include depending on what
//   platform type is. see below about restrictions on NUMBER_OF_CPUS/NUMBER_OF_CHANNEL.
// History    :
//   Date      By          Revision  Change Description
//=================================================================================================

//`include "wpspo_g5_define.vh"
`include "as03mb03_define.vh"
module pwrcap
 #(
`ifdef PSU_CTRL
    parameter NUMBER_OF_PSU     = 'd2, // default for two CPU system
`endif
    parameter NUMBER_OF_CHANNEL = 'd4, // default for two CPU system
    parameter NUMBER_OF_CPUS    = 'd2  // default for two CPU system
  )
  (
    //==========================================================================
    // prochot module port list
    //==========================================================================
    input  wire                         sys_clk,// Clock used to clock shift_register_delay
    // power good p3v3 standby used as active low flop reset
    input  wire                         reset_n, // connect to p3v3_stby_pgd
    input  wire                         t30p5us,// 32KHz tick used to generate different duty cycle for VR_HOT and SW_STPCLK
    input  wire                         power_fault,// power fault indicator and blink code
    input  wire                         fault_blink_code,
    input  wire                         pm_stpclk,// stp clk from power management microchip,1= asserted
    input  wire                         sw_stpclk,// GMT GPO to put system in lower P-state, 1=asserted
    input  wire [NUMBER_OF_CPUS-1:0]    vr_hot_n ,// Asserts when VRM is hot to put system in lower P-state, 0=asserted
    input  wire                         forcepr_mask,// Mask bit for PROCHOT# assertion
    input  wire                         adr_trigger,
    output reg  [NUMBER_OF_CPUS-1:0]    prochot_outen,// to turn on open collector driver to assert PROCHOT#, 1=turn on driver

    input  wire                         ddr_pwrcap_enable,// DDR power capping enable signal from GPO
    input  wire                         ddr_pwrcap_sw_therm,// BIOS control power capping for memory from GPO
    // GPO bit from second chain to force assertion of MEM forcepr
    // does not require ddr_pwrcap_enable to be asserted
    // tie to 1'b0 at top level if 2nd GPO chain is not available
    input  wire [NUMBER_OF_CHANNEL-1:0] ddr_pwrcap_throttle,
    input  wire [NUMBER_OF_CHANNEL-1:0] dimm_alert,// Channel alert signal from memory, qualified with P3v3_PGD active high
    output wire [NUMBER_OF_CHANNEL-1:0] ddr_pwrcap_assert_ch,// Memory throttle signal to CPU for each channel

    //==========================================================================
    // power capping LED port list
    //==========================================================================
    input  wire vdd3_pgood   ,// 3.3v main power present signal
    input  wire onehz_clk    ,// timer tick drive LED blinking
    input  wire pwrcap_en    ,// power capping enable signal from xregister
    input  wire pwrcap_denied,// power capping LED disable from xregister
    input  wire pwrcap_wait  ,// power capping wait from xregister
    input  wire pwrseq_wait  ,// wait from power seq master for blink
    output wire pwrcap_grn   ,// power capping green LED out
    output wire pwrcap_amb   ,// power capping amber LED out
    output wire pwrbtn_grn   ,// power button green LED out
    output wire pwrbtn_amb   ,// power button amber LED out

    //==========================================================================
    // E-brake funciton port list
    //==========================================================================
    input  wire                     ebrake_en,// ebrake enable from gpo
`ifdef PSU_CTRL
    input  wire [NUMBER_OF_PSU-1:0] ps_ac_ok,// PSU AC OK
`endif // PSU_CTRL
    output wire                     ebrake_state// e-brake
  );

// When asserted will assert PROCHOT# to the uP unless mask_prochot
// is asserted, 1=assert prochot
wire [NUMBER_OF_CPUS-1:0] assert_prochot;

// See generate logic below for explanation
wire [NUMBER_OF_CHANNEL-1:0] dimm_alert_n;
wire [NUMBER_OF_CHANNEL-1:0] swiz_vr_hot_n;

wire       ddr_pwrcap_event_cpu;

//==============================================================================
// mask powercap when cpu reset
//==============================================================================
// If Power Capping controller is asserting pm_stpclk and BIOS is not masking,
// assert PROCHOT# to uP. Else if VR_HOT or SW_STPCLK is asserted, output
// the duty cycle output to modulate the PROCHOT# input to uP.
// Else do not assert PROCHOT# to uP.
assign assert_prochot = (~vr_hot_n |
                         {NUMBER_OF_CPUS{pm_stpclk}} |
                         {NUMBER_OF_CPUS{sw_stpclk}} |
                         {NUMBER_OF_CPUS{ebrake_state}});

// If forcepr_mask is asserted, deassert prochot_outen,
// else assert prochot_outen if vr_hot_n, sw_stpclk or pm_stpclk is asserted
always @(posedge sys_clk or negedge reset_n)
  begin
    if (!reset_n)
      begin
        prochot_outen <= {NUMBER_OF_CPUS{1'b0}};
      end
    else if (forcepr_mask || adr_trigger)
      begin
        prochot_outen <= {NUMBER_OF_CPUS{1'b0}};
      end
    else
      begin
        prochot_outen <= assert_prochot;
      end
  end

//==============================================================================
// Continuous assignment ----- memory throttle function
//
// NOTE: this logic relies on a specific mapping of CPU to dimm_alert bits
//       so that the bit-wise logic between dimm_alert_n and vr_hot_n works.
//       For the default parameters (CPU=2, CHANNEL=4) it should look like:
// {cpu1_ch23_alert_n, cpu0_ch23_alert_n, cpu1_ch01_alert_n, cpu0_ch01_alert_n}&
// {cpu1_vr_hot_n,     cpu0_vr_hot_n,     cpu1_vr_hot_n,     cpu0_vr_hot_n}
//       and then ddr_pwrcap_assert_ch =
// {cpu1_ch23_forcepr, cpu0_ch23_forcepr, cpu1_ch01_forcepr, cpu0_ch01_forcepr}
//==============================================================================
// the conditioned dimm_alert inputs coming from the thermal logic module are
// output active high so they can be sent to a register readable by ilo
assign dimm_alert_n = ~dimm_alert;

// This generate statement maps vr_hot_n vectors to the width of dimm_alert_n
// given the mapping rules stated above. WARNING: it only works if
// NUMBER_OF_CHANNEL is evenly divisible by NUMBER_OF_CPUS and
// NUMBER_OF_CHANNEL is greater than or equal to NUMBER_OF_CPUS.
// This shouldn't be much of a problem as most modern processors have more
// than one memory controller in powers of 2.
generate
  genvar k;

  for (k=NUMBER_OF_CHANNEL-1; k>=0; k=k-NUMBER_OF_CPUS)
    begin: swiz_hot
      assign swiz_vr_hot_n[k:k+1-NUMBER_OF_CPUS] = vr_hot_n;
    end
endgenerate

assign ddr_pwrcap_event_cpu = ddr_pwrcap_enable &&
                              (ddr_pwrcap_sw_therm ||
                               pm_stpclk ||
                               ebrake_state);

assign ddr_pwrcap_assert_ch = (ddr_pwrcap_throttle                        |
                               (~(dimm_alert_n & swiz_vr_hot_n))          |
                               {NUMBER_OF_CHANNEL{ddr_pwrcap_event_cpu}}) &
                               {NUMBER_OF_CHANNEL{~adr_trigger}};

pwrcap_pwrbtn_led  pwrcap_pwrbtn_led_inst
  (
    .sys_clk                ( sys_clk ),
    .reset_n                ( reset_n ),
    .vdd3_pgood             ( vdd3_pgood ),
    .onehz_clk              ( onehz_clk ),
    .pwrcap_en              ( pwrcap_en ),
    .pwrcap_denied          ( pwrcap_denied ),
    .pwrcap_wait            ( pwrcap_wait ),
    .pwrseq_wait            ( pwrseq_wait ),
    .power_fault            ( power_fault ),
    .fault_blink_code       ( fault_blink_code ),
    .pwrcap_grn             ( pwrcap_grn ),
    .pwrcap_amb             ( pwrcap_amb ),
    .pwrbtn_grn             ( pwrbtn_grn ),
    .pwrbtn_amb             ( pwrbtn_amb )
  );


`ifdef PSU_CTRL
// exit ebrake state if ps acok recovery
wire [NUMBER_OF_PSU-1 : 0] ps_acok_recovery;

// go into ebrake state when ps acok loss
wire [NUMBER_OF_PSU-1 : 0] ps_acok_loss;

genvar i;
generate
  for(i=0;i<NUMBER_OF_PSU;i=i+1)
    begin: inst
      edge_sync #(.BUFFER_WIDTH(1'd1)) ps_ebrake_dct
        (
          .clk          ( sys_clk ),
          .t30p5us      ( 1'b1 ),
          .reset_n      ( reset_n ),
          .signal_in    ( ps_ac_ok[i] ),
          .edge_clear   ( ps_acok_recovery[i] ),
          .signal_out   ( ), // nc
          .falling_edge ( ps_acok_loss[i] ),
          .rising_edge  ( ps_acok_recovery[i] )
        );
    end
endgenerate

// ebrake state assertion when one or more ps acok loss and no recovery
assign ebrake_state = ebrake_en & (|ps_acok_loss);
`endif

endmodule
