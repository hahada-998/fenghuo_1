//=================================================================================================
// Copyright(c) 2021, CLOUDNINEINFO.CO, Ltd, All right reserved
// Filename   : AIS03MB03.v
// Project    : CLOUDNINEINFO common code
// Author     : dingxianhua
// Date       : 2020-09-24
// Email      : dingxianhua@cloudnineinfo.com
// Company    : CLOUDNINEINFO.CO., Ltd
// Description: This module is the power sequencing master. It is responsible for directing the
//   system's power sequencing slaves to enable/disable VRMs. The master is responsible for
//   monitoring each of the power goods coming back from the slaves. These power goods are
//   consolidated to pgd_so_far When a power fault occurs, the master will normally transition to
//   the SM_CRITICAL_FAIL state to allow the slave to capture the source of the fault. The master
//   will then proceed with power-down sequence to protect the system.
//   This module uses a single WDT counter for all timeout logic so it determines the largest
//   counter needed based on the largest timeout parameter given below. This, together with
//   sequence_tick and psu_on_tick, each platform can vary the granularity of the timeout values.
// Parameter  :
//   LIM_RECOV_MAX_RETRY_ATTEMPT: Number of allowed power-on retry attempt following a limited
//     recoverable fault condition. Once the max number of attempt is reached, the system will only
//     be recoverable by cycling aux efuse.
//     Default: 2
//   WDT_NBITS: Number of counter bits to use to support the timeout values below.
//     Default: 8 (max of 255 for any timeout values)
//     For the parameters below, it is assumed that the sequence_tick rate is 2ms while psu_on_tick
//     rate is 32ms. Platform can use a different tick as needed.
//   DSW_PWROK_TIMEOUT_VAL: Time to wait in SM_EN_PCH_DSW_PWROK for SLPSUS# to de-assert after
//     DSWPWROK is asserted. Max spec time is 100ms. Use 150ms for timeout.
//     Default: 75 (sequence_tick=2ms * 75 = 150ms)
//   PCH_WATCHDOG_TIMEOUT_VAL: Wait time for PCH VRM turn on before considering it faulted.
//     Default: 8 (sequence_tick=2ms * 8 = 16ms)
//   PON_WATCHDOG_TIMEOUT_VAL: Wait time for VRM turn on before considering it faulted.
//     Default: 112 (sequence_tick=2ms * 112 = 224ms)
//   PSU_WATCHDOG_TIMEOUT_VAL: 1st stage wait time for PSU turn on. If PSU is good during this
//     time, power sequencer proceed to next stage. Otherwise, wait for 2nd stage.
//     Default: 10 (psu_on_tick=32ms * 10 = 320ms)
//   EFUSE_WATCHDOG_TIMEOUT_VAL: Wait time for efuse turnon before considering it faulted.
//     Default: 137 (sequence_tick=2ms * 137 = 274ms)
//   VCORE_WATCHDOG_TIMEOUT_VAL: Wait time for CPU vcore turn on before considering it faulted.
//     Default: 112 (sequence_tick=2ms * 112 = 224ms)
//   PDN_WATCHDOG_TIMEOUT_VAL: Wait time for VRM turn off during no-fault condition.
//     Default: 2 (sequence_tick=2ms * 2 = 4ms)
//   PDN_WATCHDOG_TIMEOUT_FAULT_VAL: Wait time for VRM turn off during fault condition.
//     Default: 2 (sequence_tick=2ms * 2 = 4ms)
//   DISABLE_INTEL_VCCIN_TIMEOUT_VAL, DISABLE_INTEL_VCCIN_TIMEOUT_FAULT_VAL: Wait time for VRM turn
//     off during SM_DISABLE_INTEL_VCCIN state for both normal and fault condition.
//     This is a state specific timout value.
//     Default: PDN_WATCHDOG_TIMEOUT_VAL
//   DISABLE_3V3_TIMEOUT_VAL, DISABLE_3V3_TIMEOUT_FAULT_VAL: Wait time for VRM turn off during
//     SM_DISABLE_3V3 state for both normal and fault condition.
//     This is a state specific timout value.
//     Default: PDN_WATCHDOG_TIMEOUT_VAL
//   PON_65MS_WATCHDOG_TIMEOUT_VAL: Wait before transitioning to SM_STEADY_PWROK after all VRM has turnd on.
//     Default: 34 (sequence_tick=2ms * 34 = 68ms)
//   DC_ON_WAIT_COMPLETE_NOFLT_VAL: Time to wait in SM_OFF_STANDBY before proceeding to turn on w/o fault.
//     Default: 17 (256ms * 17 = 4.3s)
//   DC_ON_WAIT_COMPLETE_FAULT_VAL: Time to wait in SM_OFF_STANDBY before proceeding to turn on with fault.
//     Default: 2 (256ms * 2 = 512ms)
//   PF_ON_WAIT_COMPLETE_VAL: Time to wait in SM_HALT_POWER_CYCLE before allowing recovery, if
//     allowed. This is also the time used to assert PCH PWRBTN# input to force S0->S5 transition.
//     Default: 33 (256ms * 33 = 8.4s)
//   PO_ON_WAIT_COMPLETE_VAL: Time to assert the PCH PWRBTN# input to force an S5->S0 transition.
//     Default: 1 (256ms * 1 = 256ms)
//   S5_DEVICES_ON_WAIT_COMPLETE_NOFLT_VAL, S5_DEVICES_ON_WAIT_COMPLETE_FAULT_VAL: Time to wait in
//     SM_OFF_STANDBY before proceeding to enable the S5 devices.
//     Default: 0 (256ms * 0 = 0)
// History    :
//   Date      By          Revision  Change Description
//=================================================================================================


module pwrseq_master #(
  parameter LIM_RECOV_MAX_RETRY_ATTEMPT                     = 2,
  parameter WDT_NBITS                                                         = 10,
  parameter GRP_A_PWROK_TIMEOUT_VAL                             = 75,
  parameter GRP_B_PWROK_TIMEOUT_VAL                             = 256,
  parameter PON_WATCHDOG_TIMEOUT_VAL                           = 256,
  parameter PSU_WATCHDOG_TIMEOUT_VAL                           = 10,
  parameter EFUSE_WATCHDOG_TIMEOUT_VAL                       = 137,
  parameter VCORE_WATCHDOG_TIMEOUT_VAL                       = PON_WATCHDOG_TIMEOUT_VAL,
  parameter PDN_WATCHDOG_TIMEOUT_VAL                           = 2,
  parameter PDN_WATCHDOG_TIMEOUT_FAULT_VAL               = PDN_WATCHDOG_TIMEOUT_VAL,
  parameter DISABLE_INTEL_VCCIN_TIMEOUT_VAL             = PDN_WATCHDOG_TIMEOUT_VAL,
  parameter DISABLE_INTEL_VCCIN_TIMEOUT_FAULT_VAL = PDN_WATCHDOG_TIMEOUT_VAL,
  parameter DISABLE_3V3_TIMEOUT_VAL                             = PDN_WATCHDOG_TIMEOUT_VAL,
  parameter DISABLE_3V3_TIMEOUT_FAULT_VAL                 = PDN_WATCHDOG_TIMEOUT_VAL,
  parameter PON_65MS_WATCHDOG_TIMEOUT_VAL                 = 34,
  parameter DC_ON_WAIT_COMPLETE_NOFLT_VAL                 = 17,
  parameter DC_ON_WAIT_COMPLETE_FAULT_VAL                 = 2,
  parameter PF_ON_WAIT_COMPLETE_VAL                             = 33,
  parameter PO_ON_WAIT_COMPLETE_VAL                             = 1,
  parameter S5_DEVICES_ON_WAIT_COMPLETE_NOFLT_VAL = 4,
  parameter S5_DEVICES_ON_WAIT_COMPLETE_FAULT_VAL = 0,
  parameter RSMRST_REALSE_TIMEOUT_VAL			        = 75,
  parameter DISPG_WATCHDOG_TIMEOUT_VAL			= 6 ) (
// Clocks and resets
  input     wire    clk     ,                   // clock
  input     wire    reset ,                   // reset
  input     wire    cmu_fault_clear_rst,     
// Ticks
  input     wire    t1us                   ,    // 10ns pulse every 1us
  input     wire    t512us               ,    // 10ns pulse every 512us
  input     wire    t256ms               ,    // 10ns pulse every 256ms
  input     wire    t512ms               ,    // 10ns pulse every 500ms
  input     wire    t1s_tick           ,    // 10ns pulse every 1s
  input     wire    sequence_tick ,    // tick used for wdt timeout during power-up/down states
  input     wire    psu_on_tick     ,    // tick used for wdt timeout during PS on state
// Physical power button and south bridge status/control
  input     wire    sys_sw_in_n                          ,    // system's power button switch
  input     wire    pch_slp4_n                            ,    // SB (south bridge) system sleep state
  input     wire    p0_pwrbtn_n                          ,    // SB power button input (same signal driven to SB PWRBTN)
  input     wire    [1:0]   pch_thermtrip_n     ,    // SB bound thermtrip signal (same signal driven to SB THERMTRIP)
  output   reg      force_pwrbtn_n                    ,    // forces SB to switch to S5 after power shutdown due to fault
  input     wire    [1:0]   cpu_thermtrip_fault_det  ,  
  input     wire    [5:0]   power_seq_sm_fb     ,     
  input     wire    mux_sel                                  ,                 

  // Misc.
  input     wire    xr_ps_en                        ,// system allowed to power on (Xreg's ps_enable)
  input     wire    pwron_override_n        ,// power-on override
  input     wire    interlock_broken        ,// interlock broken indicator
  input     wire    allow_recovery            ,// allow power button press to recover from HALT_POWER_CYCLE
  input     wire    aux_video_holdoff      ,// allow AUX video to hold turning on of system
  input     wire    pgood_rst_mask            ,// from ADR module to mask shutdown events
  //input            bmc_ready_out_n           ,
  input     wire    bmc_clr_stby_tmout_n ,

//  input            cpu_mcp_en,              // any CPU is MCP enabled which enables P1V0_CPU and PVMCP_CPU rails
  input     wire    keep_alive_on_fault,     // prevent transition to critical fail on power up
//  input            no_vppen,                // set to 1'b1 if platform does not have an explicity EN for VPP rails
//  input            hold_pch_rsmrst,         // set to 1'b1 to stall power sequencer in state before RSMRST# is released
  output   reg      pgd_raw,                 // de-asserts on SM_STEADY_OK on fault condition
// S5 powered device control
  input     wire    s5dev_pwren_request,     // S5 powered device enable request
  input     wire    s5dev_pwrdis_request,    // S5 powered device disable request
// Slave sequencer interface
  input     wire    pgd_so_far                        ,   // current overall power status
  input     wire    any_pwr_fault_det          ,   // any type of power fault
  input     wire    any_lim_recov_fault      ,   // any limited recovery fault
  input     wire    any_non_recov_fault      ,   // any non-recoverable fault
  output   reg      dc_on_wait_complete      ,   // 4s flag - used by slave for stuck on check
  output   reg      rt_critical_fail_store,   // asserts when during runtime when critical failure detected
  output   reg      fault_clear                      ,   // clear fault flags
  output   reg      cmu_fault_clear              ,   // for cmu 
  output   reg      [5:0]   power_seq_sm       ,   // copy of the state variable  
// Status
  output   reg      fault_power                       ,   // power fault is active
  output   reg      stby_failure_detected   ,   // standby failure detected (goes to Xreg byte07[4]
  output   reg      po_failure_detected       ,   // poweron failure detected (goes to Xreg byte07[2])
  output   reg      rt_failure_detected       ,   // runtime failure detected (goes to Xreg byte07[5])
  output   reg      cpld_latch_sys_off         ,   // system in non-recovery state (goes to Xreg byte08[6])
  output   reg      turn_on_wait                     ,   // system waiting to turn on
  output   reg      po_failure_detected_set
);
//------------------------------------------------------------------------------
// State definition
//------------------------------------------------------------------------------
`include "pwrseq_define.vh"

//------------------------------------------------------------------------------
// Parameters
//------------------------------------------------------------------------------
// Derive number of bits needed for counter
// - This may generate one more than required number of FFs
function integer clogb2 (input [31:0] value);
    reg [31:0] tmp;
    begin
          tmp = (value <= 2) ? 2 : (value - 1);
          for (clogb2 = 0; tmp > 0; clogb2 = clogb2 + 1)
            tmp = tmp >> 1;
    end
endfunction
// Limited recovery retry counter
localparam LIM_RECOV_RETRY_NBITS = clogb2(LIM_RECOV_MAX_RETRY_ATTEMPT);

//------------------------------------------------------------------------------
// Local sigs
//------------------------------------------------------------------------------
// FSM
reg  [5:0] state;
reg  [5:0] state_ns;

wire st_off_standby;
wire st_ps_on;
wire st_steady_pwrok;
wire st_critical_fail;
wire st_halt_power_cycle;
wire st_disable_main_efuse;

// Watchdog logic
reg  [WDT_NBITS-1:0] wdt_counter;
wire wdt_tick;
reg  [5:0] power_seq_sm_last;
wire wdt_counter_clr;
reg  grp_a_pwrok_timeout;
reg  grp_b_pwrok_timeout;
reg  pon_watchdog_timeout;
reg  psu_watchdog_timeout;
reg  efuse_watchdog_timeout;
//reg  vcore_watchdog_timeout;
reg  pdn_watchdog_timeout;
reg  dispg_watchdog_timeout;
//reg  disable_intel_vccin_timeout;
reg  disable_3v3_timeout;
reg  pon_65ms_watchdog_timeout;
reg  pf_on_wait_complete;
reg  po_on_wait_complete;
reg  s5_devices_on_wait_complete;
reg  rsmrst_release_timeout;
reg  rsmrst_release_fail_en;

// Button logic
wire p0_pwrbtn_n_ne;
wire sys_sw_in_n_ne;
// wire sys_sw_in_n_delay;
reg  assert_power_button;
reg  assert_physical_button;
reg  assert_button_clr;
reg  rt_normal_pwr_down_flag;

// Fault flags
reg  stby_failure_detected_clr;
reg  stby_failure_detected_set;
reg  po_failure_detected_clr;
//reg  po_failure_detected_set;
reg  rt_failure_detected_clr;
reg  rt_failure_detected_set;

// Limited recovery logic
reg  ready_for_recov;
reg  ready_for_recov_clr;
reg  ready_for_recov_set;
reg  [LIM_RECOV_RETRY_NBITS-1:0] lim_recov_retry_count;
reg  lim_recov_retry_incr;
reg  lim_recov_retry_clr;
wire lim_recov_retry_max;

// Misc
reg  off_state;
reg  turn_system_on;
// wire pch_thermtrip_n_delay;
wire pch_slp4_n_delay;
reg  fault_clear_ns;

// State transition
reg  grp_a_state_trans_en;
reg  grp_a_critical_fail_en;
reg  grp_b_state_trans_en;
reg  grp_b_critical_fail_en;
reg  pwrup_state_trans_en;
reg  pwron_critical_fail_en;
reg  psu_critical_fail_en;
reg  efuse_critical_fail_en;
//reg  vcore_critical_fail_en;
reg  wait_steady_pwrok_fail_en;
wire rt_critical_fail_check;
wire rt_normal_pwr_down		;
wire rt_thermtrip_pwr_down	;
reg  rsmrst_release_trans_en;

//------------------------------------------------------------------------------
// SM states
//------------------------------------------------------------------------------
// SM states
assign  st_off_standby                = (power_seq_sm == SM_OFF_STANDBY              );
assign  st_ps_on                            = (power_seq_sm == SM_PS_ON                          );
assign  st_steady_pwrok              = (power_seq_sm == SM_STEADY_PWROK            );
assign  st_critical_fail            = (power_seq_sm == SM_CRITICAL_FAIL          );
assign  st_halt_power_cycle      = (power_seq_sm == SM_HALT_POWER_CYCLE    );
assign  st_disable_main_efuse  = (power_seq_sm == SM_DISABLE_MAIN_EFUSE);


//------------------------------------------------------------------------------
// Watchdog logic
//------------------------------------------------------------------------------
// Tick rate depends on which state we're in.
assign wdt_tick = (off_state) ? t256ms            :
                                 (st_ps_on  ) ? psu_on_tick  :
                                  sequence_tick;

// Clear counter - generates a 1us pulse on entry to new state
always @(posedge clk or posedge reset) begin
  if (reset)
    power_seq_sm_last <= power_seq_sm_fb;//SM_RESET_STATE; 
  else if (t1us)
    power_seq_sm_last <= power_seq_sm;
end

assign wdt_counter_clr = (power_seq_sm_last != power_seq_sm);

// Counter
always @(posedge clk or posedge reset) begin
  if (reset)
    wdt_counter <= {WDT_NBITS{1'b0}};
  else if (wdt_counter_clr)
    wdt_counter <= {WDT_NBITS{1'b0}};
  else if (wdt_tick)
    wdt_counter <= wdt_counter + 1'b1;
end

// Timeout flags
// - Used for waiting on power-up/down sequence states
always @(posedge clk or posedge reset) begin
  if (reset) begin
        grp_a_pwrok_timeout               <= 1'b0;
        grp_b_pwrok_timeout               <= 1'b0;
        pon_watchdog_timeout             <= 1'b0;
        psu_watchdog_timeout             <= 1'b0;
        efuse_watchdog_timeout         <= 1'b0;
    //    vcore_watchdog_timeout      <= 1'b0;
        pon_65ms_watchdog_timeout   <= 1'b0;
        pdn_watchdog_timeout             <= 1'b0;
    //    disable_intel_vccin_timeout <= 1'b0;
        disable_3v3_timeout               <= 1'b0;
        rsmrst_release_timeout         <= 1'b0;
        dispg_watchdog_timeout         <= 1'b0;
  end
  else if (wdt_counter_clr) begin
        grp_a_pwrok_timeout               <= 1'b0;
        grp_b_pwrok_timeout               <= 1'b0;
        pon_watchdog_timeout             <= 1'b0;
        psu_watchdog_timeout             <= 1'b0;
        efuse_watchdog_timeout         <= 1'b0;
    //    vcore_watchdog_timeout      <= 1'b0;
        pon_65ms_watchdog_timeout   <= 1'b0;
        pdn_watchdog_timeout             <= 1'b0;
    //    disable_intel_vccin_timeout <= 1'b0;
        disable_3v3_timeout               <= 1'b0;
        rsmrst_release_timeout         <= 1'b0;
        dispg_watchdog_timeout         <= 1'b0;
  end
  else if (wdt_tick) begin
    if (wdt_counter == GRP_A_PWROK_TIMEOUT_VAL)
      grp_a_pwrok_timeout <= 1'b1;

    if (wdt_counter == GRP_B_PWROK_TIMEOUT_VAL)
      grp_b_pwrok_timeout <= 1'b1;

    if (wdt_counter == PON_WATCHDOG_TIMEOUT_VAL)
      pon_watchdog_timeout <= 1'b1;

    if (wdt_counter == PSU_WATCHDOG_TIMEOUT_VAL)
      psu_watchdog_timeout <= 1'b1;

    if (wdt_counter == EFUSE_WATCHDOG_TIMEOUT_VAL)
      efuse_watchdog_timeout <= 1'b1;

//    if (wdt_counter == VCORE_WATCHDOG_TIMEOUT_VAL)
//      vcore_watchdog_timeout <= 1'b1;

    if (wdt_counter == PON_65MS_WATCHDOG_TIMEOUT_VAL)
      pon_65ms_watchdog_timeout <= 1'b1;
	  
    if ( wdt_counter == RSMRST_REALSE_TIMEOUT_VAL)
      rsmrst_release_timeout <= 1'b1;

    if (((wdt_counter == PDN_WATCHDOG_TIMEOUT_VAL)       && !fault_power) ||
        ((wdt_counter == PDN_WATCHDOG_TIMEOUT_FAULT_VAL) &&  fault_power))
      pdn_watchdog_timeout <= 1'b1;
    if (wdt_counter == DISPG_WATCHDOG_TIMEOUT_VAL) 
      dispg_watchdog_timeout <= 1'b1;

//    if (((wdt_counter == DISABLE_INTEL_VCCIN_TIMEOUT_VAL)       && !fault_power) ||
//        ((wdt_counter == DISABLE_INTEL_VCCIN_TIMEOUT_FAULT_VAL) &&  fault_power))
//      disable_intel_vccin_timeout <= 1'b1;

    if (((wdt_counter == DISABLE_3V3_TIMEOUT_VAL)       && !fault_power) ||
        ((wdt_counter == DISABLE_3V3_TIMEOUT_FAULT_VAL) &&  fault_power))
      disable_3v3_timeout <= 1'b1;
  end
end

// Complete flags
// - Used for holding off actions form occurring until enough time has passed
always @(posedge clk or posedge reset) begin
  if (reset) begin
    dc_on_wait_complete                 <= 1'b0;
    po_on_wait_complete                 <= 1'b0;
    s5_devices_on_wait_complete <= 1'b0;
  end
  else if (t1us) begin
    if (!off_state || interlock_broken) begin
      dc_on_wait_complete                 <= 1'b0;
      po_on_wait_complete                 <= 1'b0;
      s5_devices_on_wait_complete <= 1'b0;
    end
    else begin
      if (((wdt_counter == DC_ON_WAIT_COMPLETE_NOFLT_VAL) && !fault_power) ||
          ((wdt_counter == DC_ON_WAIT_COMPLETE_FAULT_VAL) &&  fault_power))
        dc_on_wait_complete <= 1'b1;

      if (wdt_counter == PO_ON_WAIT_COMPLETE_VAL)
        po_on_wait_complete <= 1'b1;

      if (((wdt_counter == S5_DEVICES_ON_WAIT_COMPLETE_NOFLT_VAL) && !fault_power) ||
          ((wdt_counter == S5_DEVICES_ON_WAIT_COMPLETE_FAULT_VAL) &&  fault_power))
        s5_devices_on_wait_complete <= 1'b1;
    end
  end
end

// pf_on_wait_complete is separated from above since it needs to also assert
// during interlock_broken case.
always @(posedge clk or posedge reset) begin
  if (reset)
    pf_on_wait_complete <= 1'b0;
  else if (t1us && !off_state)
    pf_on_wait_complete <= 1'b0;
  else if (t1us && (wdt_counter == PF_ON_WAIT_COMPLETE_VAL))
    pf_on_wait_complete <= 1'b1;
end

//------------------------------------------------------------------------------
// turn_system_on
// - Asserts when system is requested to turn on and have satisfied all
//   required conditions for turn on.
//------------------------------------------------------------------------------
always @(posedge clk or posedge reset) begin
  if (reset)
    turn_system_on <= 1'b0;
  else if (t1us)
    turn_system_on <= (xr_ps_en | ~pwron_override_n | turn_system_on)   &  //default 1 allowed to turn on
                                      pch_slp4_n                                        &  // SB in S0 state
                                      ~interlock_broken                          &  //default 1 nothing is broken
                                      ~aux_video_holdoff;                          //default 1
end

//------------------------------------------------------------------------------
// assert_power_button, phys_power_button
// - Asserts when power button is pressed while in 'off' states unless the
//   assertion is due to force_pwrbtn_n. Mask out in this case. We don't want
//   that asserted due to pwrseq forcing power button assertion.
// - Remains asserted until we hit SM_CRITICAL_FAIL or the start of power-on.
// - phys_power_button only asserts on sys_sw_in_n assertion alone.
//------------------------------------------------------------------------------
// edge_detect #(.SIGCNT(2), .DEF_INIT(2'b11)) edge_detect_button_ne_inst (
  // .reset       (reset),
  // .clk         (clk),
  // .tick        (1'b1),
  // .signal_in   ({p0_pwrbtn_n,    sys_sw_in_n}),
  // .detect_pe   (),
  // .detect_ne   ({p0_pwrbtn_n_ne, sys_sw_in_n_ne}),
  // .detect_any  ()
// );
Edge_Detect Edge_Detect_U1(    
    .i_clk               (clk),        
    .i_rst_n             (reset),       
    .i_signal            (p0_pwrbtn_n),
    
    .o_signal_pos        (),
    .o_signal_neg        (p0_pwrbtn_n_ne),
    .o_signal_invert     ()
);
Edge_Detect Edge_Detect_U2(    
    .i_clk               (clk),        
    .i_rst_n             (reset),       
    .i_signal            (sys_sw_in_n),
    
    .o_signal_pos        (),
    .o_signal_neg        (sys_sw_in_n_ne),
    .o_signal_invert     ()
);

always @(posedge clk or posedge reset) begin
  if (reset)
    assert_power_button <= 1'b0;
  else if (assert_button_clr || ~force_pwrbtn_n)
    assert_power_button <= 1'b0;
  else if (p0_pwrbtn_n_ne && off_state)
    assert_power_button <= 1'b1;
end

always @(posedge clk or posedge reset) begin
  if (reset)
    assert_physical_button <= 1'b0;
  else if (assert_button_clr)
    assert_physical_button <= 1'b0;
  else if (sys_sw_in_n_ne && st_halt_power_cycle)
    assert_physical_button <= 1'b1;
end

//------------------------------------------------------------------------------
// force_pwrbtn_n
// - Asserts low when power sequencer needs to toggle SB power button input.
// - Note the differet behavior between BL and non-BL platform
//------------------------------------------------------------------------------
always @(posedge clk or posedge reset) begin
  if (reset)
    force_pwrbtn_n <= 1'b1;
  else if (t1us) begin
    // Forces SB power button assertion when any of the following:
    // 1. (Any)   Power fault and waiting for pf_on_wait_complete. Asserts for 8s.
    // 2. (BL/BT) Software request to turn E-fuse back on.
    //            CHECKME: Is this a request to turn-on? Shouldn't this be
    //            po_on_wait_complete as using pf_on_wait_complete will assert the
    //            signal for 8s.
    // 3. (BL)    Power fault and waiting for pf_on_wait_complete. Asserts for 8s.
    // 4. (Any)   Power fault and SB in S5 and power button is asserted. This is a
    //            request to turn on. po_on_wait_complete is masked in BL/BT.
    // 5. (BL/BT) This is a hold term. Keep asserted for 250ms and while SB is in S5.
    // 6. (BL)    In SM_MISS_TURNON state and either pf_on_wait_complete is not
    //            done or SB is still in S0 state. This term is forcing SB to S5.
    // 7. (BL)    In SM_MISS_TURNON and now allowed to turn on (xr_ps_en asserts)
    //            causing f_btn_sr to start shifting. Asserts for 250ms as f_btn_sr
    //            is shifted only every 250ms.
    force_pwrbtn_n <=~((st_halt_power_cycle   &  fault_power& ~pf_on_wait_complete)|  // /
                                         (st_off_standby & fault_power & (po_on_wait_complete) & assert_power_button  & ~pch_slp4_n));                        // /
  end
end

//------------------------------------------------------------------------------
// turn_on_wait
// - Asserts when system has been triggered to turn on and keep asserted until
//   SM_STEADY_PWROK or SM_CRITICAL_FAIL is reached.
//------------------------------------------------------------------------------
always @(posedge clk or posedge reset) begin
  if (reset)
    turn_on_wait <= 1'b0;
  else if (t1us)
    turn_on_wait <= (st_off_standby & turn_system_on) |
                                  (assert_power_button)             |
                                  (turn_on_wait & ~(st_steady_pwrok | st_critical_fail));
end

//------------------------------------------------------------------------------
// cpld_latch_sys_off
// - Asserts when in SM_HALT_POWER_CYCLE and we've reached the max number of
//   retry attempt. Aux power cycle is required.
//------------------------------------------------------------------------------
always @(posedge clk or posedge reset) begin
  if (reset)
    cpld_latch_sys_off <= 1'b0;
  else
    cpld_latch_sys_off <= st_halt_power_cycle & lim_recov_retry_max;
end

//------------------------------------------------------------------------------
// stby, poweron and runtime fault flags
//------------------------------------------------------------------------------
always @(posedge clk or posedge reset) begin
  if (reset)
    stby_failure_detected <= 1'b0;
  else if (t1us && stby_failure_detected_clr)
    stby_failure_detected <= 1'b0;
  else if (t1us && stby_failure_detected_set)
    stby_failure_detected <= 1'b1;
end

always @(posedge clk or posedge reset) begin
  if (reset)
    po_failure_detected <= 1'b0;
  else if (t1us && po_failure_detected_clr)
    po_failure_detected <= 1'b0;
  else if (t1us && po_failure_detected_set)
    po_failure_detected <= 1'b1;
end

always @(posedge clk or posedge reset) begin
  if (reset)
    rt_failure_detected <= 1'b0;
  else if (t1us && rt_failure_detected_clr)
    rt_failure_detected <= 1'b0;
  else if (t1us && rt_failure_detected_set)
    rt_failure_detected <= 1'b1;
end

always @(posedge clk or posedge reset) begin
  if (reset)
    fault_power <= 1'b0;
  else if (t1us)
    fault_power <= stby_failure_detected | po_failure_detected | rt_failure_detected;
end

//------------------------------------------------------------------------------
// Limited-recovery logic
//------------------------------------------------------------------------------
always @(posedge clk or posedge reset) begin
  if (reset)
    ready_for_recov <= 1'b0;
  else if (t1us && ready_for_recov_clr)
    ready_for_recov <= 1'b0;
  else if (t1us && ready_for_recov_set)
    ready_for_recov <= 1'b1;
end

always @(posedge clk or posedge reset) begin
  if (reset)
    lim_recov_retry_count <= {LIM_RECOV_RETRY_NBITS{1'b0}};
  else if (t1us && lim_recov_retry_clr)
    lim_recov_retry_count <= {LIM_RECOV_RETRY_NBITS{1'b0}};
  else if (t1us && lim_recov_retry_incr)
    lim_recov_retry_count <= lim_recov_retry_count + 1'b1;
end

assign lim_recov_retry_max = (lim_recov_retry_count == LIM_RECOV_MAX_RETRY_ATTEMPT);

//------------------------------------------------------------------------------
// Generate a 1ms delayed version of pch_thermtrip_n when in SM_STEADY_PWROK.
// This is used to trigger a power-down.
//------------------------------------------------------------------------------
/*
edge_delay #(
  .CNTR_NBITS    (2)
) sb_thermtrip_delay_inst (
  .clk           (clk),
  .reset         (reset),
  .cnt_size      (2'b11),
  .cnt_step      (t512us),
  .signal_in     (~pch_thermtrip_n & st_steady_pwrok),
  .delay_output  (pch_thermtrip_n_delay)
);
*/

edge_delay #(
  .CNTR_NBITS    (2)
) sb_pch_slp4_delay_inst (
  .clk           (clk),
  .reset         (reset),
  .cnt_size      (2'b10),
  .cnt_step      (t512us),
  .signal_in     (~pch_slp4_n & st_steady_pwrok),
  .delay_output  (pch_slp4_n_delay)
);

//------------------------------------------------------------------------------
// fault_clear
// - Clears any outstanding faults on AUX_FAIL_RECOVERY state or during the
//   start of power on sequence.
// - Registered fault_clear to ease out timing since that drives all fault_detectB
//   instances in this module. The extra clock is here is acceptable since SM
//   changes state only every 1us.
//------------------------------------------------------------------------------
always @(posedge clk or posedge reset) begin
  if (reset)
    fault_clear <= 1'b0;
  else
    fault_clear <= fault_clear_ns;
end

always @(posedge cmu_fault_clear_rst or posedge fault_clear_ns) begin
  if (cmu_fault_clear_rst)
    cmu_fault_clear <= 1'b0;
  else
    cmu_fault_clear <= 1'b1;
end

//------------------------------------------------------------------------------
// state transition logic
// - These signals are used by SM to steer state transition. The logic are
//   too big to put in the SM block so an intermediate variable is used.
//------------------------------------------------------------------------------
// Asserts when SM is ready to move to the next VRD enablement
always @(posedge clk or posedge reset) begin
  if (reset) begin
    grp_a_state_trans_en  <= 1'b0;
    grp_b_state_trans_en  <= 1'b0;
    pwrup_state_trans_en  <= 1'b0;
	rsmrst_release_trans_en  <= 1'b0;
  end
  else begin
    grp_a_state_trans_en    <= grp_a_pwrok_timeout    & pgd_so_far;
    grp_b_state_trans_en    <= grp_b_pwrok_timeout    & pgd_so_far;
    pwrup_state_trans_en    <= pon_watchdog_timeout   & pgd_so_far;
	rsmrst_release_trans_en <= rsmrst_release_timeout & pgd_so_far ;
  end
end

// Registered to ease timing
always @(posedge clk or posedge reset) begin
  if (reset) begin
        grp_a_critical_fail_en       <= 1'b0;
        grp_b_critical_fail_en       <= 1'b0;
        pwron_critical_fail_en       <= 1'b0;
        psu_critical_fail_en           <= 1'b0;
        efuse_critical_fail_en       <= 1'b0;
    //    vcore_critical_fail_en    <= 1'b0;
        wait_steady_pwrok_fail_en <= 1'b0;
        rsmrst_release_fail_en	   <= 1'b0;
  end
  else if (keep_alive_on_fault) begin
        grp_a_critical_fail_en       <= 1'b0;
        grp_b_critical_fail_en       <= 1'b0;
        pwron_critical_fail_en       <= 1'b0;
        psu_critical_fail_en           <= 1'b0;
        efuse_critical_fail_en       <= 1'b0;
    //    vcore_critical_fail_en    <= 1'b0;
        wait_steady_pwrok_fail_en <= 1'b0;
        rsmrst_release_fail_en	   <= 1'b0;
  end
  else begin
        grp_a_critical_fail_en       <= (grp_a_pwrok_timeout              & ~pgd_so_far) | any_pwr_fault_det;
        grp_b_critical_fail_en       <= (grp_b_pwrok_timeout              & ~pgd_so_far) | any_pwr_fault_det;
        pwron_critical_fail_en       <= (pon_watchdog_timeout            & ~pgd_so_far) | any_pwr_fault_det;
        psu_critical_fail_en           <= (psu_watchdog_timeout            & ~pgd_so_far) | any_pwr_fault_det;
        efuse_critical_fail_en       <= (efuse_watchdog_timeout        & ~pgd_so_far) | any_pwr_fault_det;
    //  vcore_critical_fail_en    <= (vcore_watchdog_timeout     & ~pgd_so_far) | any_pwr_fault_det;
        wait_steady_pwrok_fail_en <= (pon_65ms_watchdog_timeout  & ~pgd_so_far) | any_pwr_fault_det;
        rsmrst_release_fail_en	   <= (rsmrst_release_timeout	      & ~pgd_so_far) | any_pwr_fault_det;
  end
end

// On fault during runtime, assert flag for the duration of SM_STEADY_OK until
// FSM transitions to SM_CRITICAL_FAIL. Flag deasserts on entry to SM_CRITICAL_FAIL.
assign rt_critical_fail_check = (any_pwr_fault_det & ~keep_alive_on_fault) | interlock_broken;

always @(posedge clk or posedge reset) begin
  if (reset)
    rt_critical_fail_store <= 1'b0;
  else
    rt_critical_fail_store <= ( st_steady_pwrok  & rt_critical_fail_check) |
                                                      (~st_critical_fail & rt_critical_fail_store);
end

// Shutdown events
//assign rt_normal_pwr_down    = ~pgood_rst_mask &(~turn_system_on | ( pch_thermtrip_n_delay & pch_slp4_n));
assign rt_normal_pwr_down    = ~pgood_rst_mask &  pch_slp4_n_delay	 ;
assign rt_thermtrip_pwr_down = ~pgood_rst_mask &  pch_thermtrip_n & st_steady_pwrok	 ;
//assign rt_thermtrip_pwr_down = ~pgood_rst_mask &(~turn_system_on | (pch_thermtrip_n & pch_slp4_n_delay)); 


//addr t_thermtrip_pwr_down
//assign rt_normal_pwr_down = ~pgood_rst_mask &( ~pch_slp4_n | ~turn_system_on); 

// pgd_raw asserts on SM_STEADY_PWROK while pgd_so_far is high and
// rt_critical_fail_check is low. If any of these two terms switches states,
// pgd_raw will immediately de-asserts.
always @(posedge clk or posedge reset) begin
  if (reset)
    pgd_raw <= 1'b0;
  else if (t1us)
    pgd_raw <= pgd_so_far & st_steady_pwrok & ~rt_critical_fail_check;
  else
    pgd_raw <= pgd_so_far & pgd_raw & ~rt_critical_fail_check;
end

//------------------------------------------------------------------------------
// Synchronous portion of FSM
//------------------------------------------------------------------------------
always @(posedge clk or posedge reset) begin
  if (reset)
    state <= SM_RESET_STATE;//power_seq_sm_fb;//SM_RESET_STATE; 
  else if (t1us)
    state <= state_ns;
end

// 'power_seq_sm' is an alias for state
//assign power_seq_sm = state;
always @(posedge clk or posedge reset) begin 
  if (reset)
    power_seq_sm <= power_seq_sm;
  else 
     begin
	      power_seq_sm <=state; 
	 end   
end

//------------------------------------------------------------------------------
// Combinatorial portion of FSM
//------------------------------------------------------------------------------
always @(*) begin
      state_ns                                   = state;
      assert_button_clr                 = 1'b0;
      stby_failure_detected_clr = 1'b0;
      stby_failure_detected_set = 1'b0;
      po_failure_detected_clr     = 1'b0;
      po_failure_detected_set     = 1'b0;
      rt_failure_detected_clr     = 1'b0;
      rt_failure_detected_set     = 1'b0;
      ready_for_recov_clr             = 1'b0;
      ready_for_recov_set             = 1'b0;
      lim_recov_retry_clr             = 1'b0;
      lim_recov_retry_incr           = 1'b0;
      off_state                                 = 1'b0;
      fault_clear_ns                       = 1'b0;
      rt_normal_pwr_down_flag     = 1'b0;
  case (state)
    SM_RESET_STATE : begin       //00
          if (power_seq_sm_fb==SM_OFF_STANDBY && (mux_sel == 1'b0))//08   
               state_ns = SM_OFF_STANDBY;
          else if(power_seq_sm_fb==SM_STEADY_PWROK && (mux_sel == 1'b0))//20  
               state_ns = SM_STEADY_PWROK;
          else begin 
               state_ns = SM_EN_GRP_A;
               stby_failure_detected_clr = 1'b1;
               po_failure_detected_clr   = 1'b1;
               rt_failure_detected_clr   = 1'b1;
          end
    end

    SM_EN_GRP_A : begin          //01
          if (grp_a_critical_fail_en) begin
            state_ns = SM_CRITICAL_FAIL;
            po_failure_detected_set = 1'b1;
          end
          else if (grp_a_state_trans_en) begin
            state_ns = SM_RSMRST_DISABLE;
          end		  
    end
	
    SM_RSMRST_DISABLE : begin       //0X02
          if (pwron_critical_fail_en) begin
            state_ns = SM_CRITICAL_FAIL;
            po_failure_detected_set = 1'b1;
          end
          else if (pwrup_state_trans_en) begin
            state_ns = SM_EN_GRP_B_33_S5;
          end 
    end

    SM_EN_GRP_B_33_S5 : begin   //0X03
          if (grp_b_critical_fail_en) begin
            state_ns = SM_CRITICAL_FAIL;
            po_failure_detected_set = 1'b1;
          end	
          else if (grp_b_state_trans_en) begin
            state_ns = SM_EN_GRP_B_18_S5;
          end
    end
	
    SM_EN_GRP_B_18_S5 : begin   //0X04
          if (grp_b_critical_fail_en) begin
            state_ns = SM_CRITICAL_FAIL;
            po_failure_detected_set = 1'b1;
          end	
          else if (grp_b_state_trans_en) begin
            state_ns = SM_EN_P5V_STBY;
          end
    end
	
    SM_EN_P5V_STBY : begin          //0X05
          if (grp_b_critical_fail_en) begin
            state_ns = SM_CRITICAL_FAIL;
            po_failure_detected_set = 1'b1;
          end
          else if (grp_b_state_trans_en) begin
            state_ns = SM_EN_RSMRST_RELEASE;
          end
    end
	
    SM_EN_RSMRST_RELEASE : begin   //0X06
          if (rsmrst_release_fail_en) begin
            state_ns = SM_CRITICAL_FAIL;
            po_failure_detected_set = 1'b1;
          end	
          else if (rsmrst_release_trans_en) begin
            state_ns = SM_OFF_STANDBY;
          end
    end	
	
    SM_OFF_STANDBY : begin         //0X08
          if (any_pwr_fault_det & ~keep_alive_on_fault) begin  
            // Fault detected. Using new STBY flag for standby failure.
            state_ns = SM_CRITICAL_FAIL;
            stby_failure_detected_set = 1'b1;
          end
          else if (s5dev_pwrdis_request) begin
            // S5 device disable request or request to shutdown e-fuse (BL only)
            state_ns = SM_DISABLE_S5_DEVICES;
          end
          else if (s5dev_pwren_request && s5_devices_on_wait_complete) begin
            // S5 device enable request
            state_ns = SM_ENABLE_S5_DEVICES;
          end
          else if (turn_system_on && dc_on_wait_complete ) begin
            //add bmc_ready_out_n
            // Let's power on. Note that if miss_turn_on_window is asserted, there's
            // no need to wait for dc_on_wait_complete since we just went through
            // SM_MISS_TURNON which is long enough wait time for the next power up.
            state_ns = SM_PS_ON;
            // Clear assert_*_button flags and set fault_clear
            assert_button_clr = 1'b1;
            fault_clear_ns = 1'b1;
          end
          // This is an offstate
          off_state = 1'b1;
    end
	
    SM_ENABLE_S5_DEVICES : begin   //0X07
          if (pwron_critical_fail_en) begin
            // - Fault detected while trying to turn on S5 device.
            // - Non-BL/BT, go to Disable S5 device.
            state_ns = SM_DISABLE_S5_DEVICES;
            po_failure_detected_set = 1'b1;
          end
          else if (pwrup_state_trans_en) begin
            state_ns = SM_OFF_STANDBY;
          end
    end

    SM_PS_ON : begin                 //09
          if (psu_critical_fail_en) begin
            state_ns = SM_CRITICAL_FAIL;
            po_failure_detected_set = 1'b1;
          end
          else if (psu_watchdog_timeout && pgd_so_far) begin
            state_ns = SM_EN_TELEM;
          end
    end

    SM_EN_TELEM : begin              //10
          // - Enable telemetry rails (P3V3_PWM_CTRL and PVCC_HPMOS).
          // - BL, skipped since telemetry rails are enabled during ??
         // if (pwron_critical_fail_en) begin
          //  state_ns = SM_CRITICAL_FAIL;
          //  po_failure_detected_set = 1'b1;
         // end
          //else if (pwrup_state_trans_en) begin
            state_ns = SM_EN_MAIN_EFUSE;
         // end
    end

    SM_EN_MAIN_EFUSE : begin         //11
          // - BL, called after SM_EN_P3V3_VCC state. Go to enabling PCH rails next.
          // - Non-BL, part of power-on sequence.
          if (efuse_critical_fail_en) begin
            state_ns = SM_CRITICAL_FAIL;
            po_failure_detected_set = 1'b1;
          end
          else if (efuse_watchdog_timeout && pgd_so_far) begin
            state_ns = SM_EN_GRP_ATX;
          end
    end

    SM_EN_GRP_ATX : begin            //12
          if (pwron_critical_fail_en) begin
            state_ns = SM_CRITICAL_FAIL;
            po_failure_detected_set = 1'b1;
          end
          else if (pwrup_state_trans_en) begin
            state_ns = SM_EN_GRP_C;
          end
    end

    SM_EN_GRP_C : begin              //13
          if (pwron_critical_fail_en) begin
            state_ns = SM_CRITICAL_FAIL;
            po_failure_detected_set = 1'b1;
          end
          else if (pwrup_state_trans_en) begin
            state_ns = SM_EN_GRP_D_VDDIO;
          end
    end
	
    SM_EN_GRP_D_VDDIO : begin              //14
          if (pwron_critical_fail_en) begin
          // Skipped if no_vppen is set
            state_ns = SM_CRITICAL_FAIL;
            po_failure_detected_set = 1'b1;
          end
          else if (pwrup_state_trans_en) begin
            state_ns = SM_EN_GRP_D_SOC;
          end
    end

    SM_EN_GRP_D_SOC : begin             //15
          if (pwron_critical_fail_en) begin
            state_ns = SM_CRITICAL_FAIL;
            po_failure_detected_set = 1'b1;
          end
          else if (pwrup_state_trans_en) begin
            state_ns = SM_EN_GRP_D_VDDCORE0;
          end
    end
	
    SM_EN_GRP_D_VDDCORE0 : begin          //16
          if (pwron_critical_fail_en) begin
            state_ns = SM_CRITICAL_FAIL;
            po_failure_detected_set = 1'b1;
          end
          else if (pwrup_state_trans_en) begin
            state_ns = SM_EN_GRP_D_VDDCORE1;
          end
    end	

    SM_EN_GRP_D_VDDCORE1 : begin          //17
          if (pwron_critical_fail_en) begin
            state_ns = SM_CRITICAL_FAIL;
            po_failure_detected_set = 1'b1;
          end
          else if (pwrup_state_trans_en) begin
            state_ns = SM_EN_PGOOD_RELEASE;
          end
    end		

    SM_EN_PGOOD_RELEASE : begin     //18
          if (pwron_critical_fail_en) begin
            state_ns = SM_CRITICAL_FAIL;
            po_failure_detected_set = 1'b1;
          end
          else if (pwrup_state_trans_en) begin
            state_ns = SM_WAIT_POWEROK;
          end
    end

    SM_WAIT_POWEROK : begin         //6'h19
          if (wait_steady_pwrok_fail_en) begin
            state_ns = SM_CRITICAL_FAIL;
            po_failure_detected_set = 1'b1;
          end
          else if (pwrup_state_trans_en && pgd_so_far) begin
            state_ns = SM_STEADY_PWROK;
          end
    end

    SM_STEADY_PWROK : begin         //6'h20
          if (rt_critical_fail_store && !pgood_rst_mask ) begin
            state_ns = SM_CRITICAL_FAIL;
            rt_failure_detected_set = 1'b1;
          end
	  else if (rt_thermtrip_pwr_down) begin         
            state_ns = SM_CRITICAL_FAIL;           
    //		rt_failure_detected_set = 1'b1;
          end
          else if (rt_normal_pwr_down   ) begin
             state_ns = SM_DISABLE_PWRGD;
          end
          // Clear retry counter on clean powerup
          lim_recov_retry_clr = 1'b1;
    end

    SM_CRITICAL_FAIL : begin        //34
          state_ns = SM_DISABLE_PWRGD;
          assert_button_clr = 1'b1;
    end
	
    SM_DISABLE_PWRGD: begin       //21
          if (dispg_watchdog_timeout) begin
            state_ns = SM_DISABLE_GRP_D_VDDCORE1;
          end
    end	

    SM_DISABLE_GRP_D_VDDCORE1 : begin  //22
          if (pdn_watchdog_timeout) begin
            state_ns = SM_DISABLE_GRP_D_VDDCORE0;
          end
    end

    SM_DISABLE_GRP_D_VDDCORE0 : begin  //23
          if (pdn_watchdog_timeout) begin
            state_ns = SM_DISABLE_GRP_D_SOC;
          end
    end

    SM_DISABLE_GRP_D_SOC : begin        //24
          if (pdn_watchdog_timeout) begin
            state_ns = SM_DISABLE_GRP_D_VDDIO;
          end
    end

    SM_DISABLE_GRP_D_VDDIO : begin        //25
          if (pdn_watchdog_timeout) begin
            state_ns = SM_DISABLE_GRP_C;
          end
    end

    SM_DISABLE_GRP_C : begin        //26
          if (pdn_watchdog_timeout) begin
            state_ns = SM_DISABLE_GRP_ATX;
          end
    end

   SM_DISABLE_GRP_ATX : begin       //27
          if (pdn_watchdog_timeout) begin
            state_ns = SM_DISABLE_MAIN_EFUSE;
          end
    end

    SM_DISABLE_MAIN_EFUSE : begin   //28
          // - BL, last one to turn off due to power fault or was forced off.
          // - Non-BL, part of pwrdn flow so go to turning off of telemetry rails.
          if (pdn_watchdog_timeout) begin
            state_ns = SM_DISABLE_TELEM;
          end
          off_state = 1'b0;
    end

    SM_DISABLE_TELEM : begin        //29
          // - BT, last pwrdn stage. Go to DISABLE_S5_DEVICES if there's any power fault.
          // - Non-BT, not last group yet.
          if (pdn_watchdog_timeout) begin
            state_ns = SM_DISABLE_PS_ON;
          end
    end

    SM_DISABLE_PS_ON : begin        //30
      // - BL/BT, not used
      // - Non-BL/BT, disable PSU. This is the last stage. Proceed to disable S5
      //   devices if there are any power fault
          if (pdn_watchdog_timeout)
            state_ns = ((any_pwr_fault_det & ~keep_alive_on_fault ) || (cpu_thermtrip_fault_det )) ? SM_DISABLE_S5_DEVICES : SM_OFF_STANDBY; 
    end
      //changed '(!pch_thermtrip_n)' to '(cpu_thermtrip_fault_det)' 
    SM_DISABLE_S5_DEVICES : begin    //31
          // - If no fault, go back to SM_OFF_STANDBY. Otherwise,
          // - BL, proceed to disable main efuse if e-fuse is forced off or we have
          //   limited/non-recoverable fault.
          // - For anything else, go to SM_HALT_POWER_CYCLE
          if (pdn_watchdog_timeout) begin
                if (any_pwr_fault_det  )
                  state_ns = SM_HALT_POWER_CYCLE;
                else if(|cpu_thermtrip_fault_det) //changed '(!pch_thermtrip_n)' to '(cpu_thermtrip_fault_det)'  
                  state_ns = SM_RESET_STATE;             
                else
                  state_ns = SM_OFF_STANDBY;
          end
    end

    SM_HALT_POWER_CYCLE : begin      //6'h32
      // - We have a power fault waiting for user interaction. Recovery is based
      //   on what the user does. We'll force PCH to transition to S5 here in
      //   this state before before honoring any recovery.
      // - For non-BT, the following are the recovery mechanism.
      //   - Virtual or physical button recovery on any of the following:
      //     - allow_recovery = 1 (any fault is recoverable)
      //     - recoverable fault
      //   - Physical button only recovery on any of the following:
      //     - allow_recovery = 0 AND any_lim_recov_fault
      //   - For either recovery mechanism, a max of LIM_RECOV_RETRY_ATTEMP
      //     recovery attemp is allowed. Counter is incremented for every visit
      //     to this state and cleared on successful power-on. No further
      //     recovery possible if max count is reached.
      // - For BT, getting to this state means a recovery was forced from
      //   SM_SYSTEM_LOCKOUT state. A virtual or physical button press will exit
      //   this state.
      //   - No recovery possible with any_non_recov_fault set.
          if (ready_for_recov && !any_non_recov_fault) begin
              if (!lim_recov_retry_max)
                   if ((assert_power_button && (allow_recovery || ~any_lim_recov_fault)) ||
                       (assert_physical_button && !allow_recovery && any_lim_recov_fault)||bmc_clr_stby_tmout_n) 	
                      begin
                        state_ns = SM_AUX_FAIL_RECOVERY;
                        lim_recov_retry_incr = 1'b1;
                      end
          end
          // Set a flag that indicates we're ready for recovery. This flag is
          // to allow system recovery when user first do a virtual power button
          // (no recovery yet) followed by physical button press (recovery expected).
          // In this case, the virtual power button press will cause PCH to switch to
          // S0 which de-asserts pch_slp4_n. Without this latched flag, subsequent
          // physical power button press won't recover since pch_slp4_n is not
          // asserted anymore.
          //ready_for_recov_set = pf_on_wait_complete & ~pch_slp4_n;
          ready_for_recov_set = pf_on_wait_complete ;	  
          // This is an offstate
          off_state = 1'b1;
    end

    SM_AUX_FAIL_RECOVERY : begin      //33
      // Clear faults
          stby_failure_detected_clr = 1'b1;
          po_failure_detected_clr     = 1'b1;
          rt_failure_detected_clr     = 1'b1;
          ready_for_recov_clr             = 1'b1;
          fault_clear_ns                       = 1'b1;
          off_state                                 = 1'b1;        
          if(~cmu_fault_clear)begin       
            state_ns = SM_RSMRST_DISABLE;
          end
    end

    default : begin
      state_ns = SM_RESET_STATE;//power_seq_sm_fb;//SM_RESET_STATE; 
    end
  endcase
end
	
endmodule
