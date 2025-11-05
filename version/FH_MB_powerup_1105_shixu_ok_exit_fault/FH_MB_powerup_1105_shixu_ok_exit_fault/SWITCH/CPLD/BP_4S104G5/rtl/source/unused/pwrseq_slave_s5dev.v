
module pwrseq_slave_s5dev #(
  parameter NUM_DEV                 = 1,
  parameter S5DEV_STUCKON_FAULT_CHK = 1'b0) (

  // Clocks and resets
  input                    reset,                   // reset
  input                    clk,                     // clock
  input                    t1us,
  input                    t64ms,

  // pwrseq state, status, misc
  input              [5:0] power_seq_sm,            // pwrseq state
  input                    any_pwr_fault_det,       // any power fault detected
  input                    fault_clear,             // clear fault flags
  input                    keep_alive_on_fault,     // when asserted, a fault will not mask the corresponding enable signal (default to 1'b0, debug only)
  output                   pgd_so_far,              // pgd_so_far for S5 device

  // Xreg control
  input                    xreg_wol_en,             // Xreg byte 0x06.3
  input      [NUM_DEV-1:0] xreg_disable,            // Xreg byte 0x49/0x4A (mapping platform specific)

  // Presence status
  input      [NUM_DEV-1:0] prsnt_n,                 // device presence

  // Power enable
  output     [NUM_DEV-1:0] pal_aux_en,              // enable device's aux power
  output     [NUM_DEV-1:0] pal_main_en,             // enable device's main power

  // Power status
  input      [NUM_DEV-1:0] pgd_pwr_aux,             // device aux pgood
  input      [NUM_DEV-1:0] pgd_pwr_main,            // device main pgood

  // Fault/pwrdis status
  // ... aux
  output                   aux_mod_fault,           // any device aux power fault
  output     [NUM_DEV-1:0] aux_fault_det,           // device aux power fault
  output reg [NUM_DEV-1:0] aux_fault_pwrdis,        // device disabled due to aux power fault
  // ... main
  output                   main_mod_fault,          // any device main power fault
  output     [NUM_DEV-1:0] main_fault_det,          // device main power fault
  output reg [NUM_DEV-1:0] main_fault_pwrdis,       // device disabled due to main power fault

  // Clock enable
  output     [NUM_DEV-1:0] pal_clken,               // device clock enable

  // Power change request - to pwrseq_master
  output                   aux_pwren_request,       // device enable request
  output                   aux_pwrdis_request       // device disable request
);


//------------------------------------------------------------------------------
// Power sequence state definition//
//------------------------------------------------------------------------------
`include "pwrseq_define.vh"


//------------------------------------------------------------------------------
// Local sigs
//------------------------------------------------------------------------------
genvar i;
wire st_off_standby;
wire st_enable_s5_devices;
wire st_critical_fail;
wire st_disable_3v3;
wire st_disable_5v;
wire st_disable_s5_devices;
wire st_aux_fail_recovery;
reg [5:0] power_seq_sm_last;

// Enable registers
reg reg_stuckon_chk_dis;
reg reg_main_power_en;
reg reg_main_chk_en;
reg reg_clken;

// Main logic
wire [NUM_DEV-1:0] prsnt_n_pe;
reg  [NUM_DEV-1:0] reg_aux_power_en;
reg  [NUM_DEV-1:0] aux_pwren_request_reg;
reg  [NUM_DEV-1:0] aux_pwrdis_request_reg;
wire [NUM_DEV-1:0] clr_pwrdis;
reg  [NUM_DEV-1:0] dev_enable;
wire [NUM_DEV-1:0] aux_power_ok;
wire [NUM_DEV-1:0] main_power_ok;

// Stuckon fault check workaround
wire [NUM_DEV-1:0] stuckon_chk_en;
wire [NUM_DEV-1:0] stuckon_chk_mask;
wire aux_check_en;


//------------------------------------------------------------------------------
// SM states
// - These are just convenience variable for use below
//------------------------------------------------------------------------------
assign st_off_standby        = (power_seq_sm == SM_OFF_STANDBY);
assign st_enable_s5_devices  = (power_seq_sm == SM_ENABLE_S5_DEVICES);
assign st_critical_fail      = (power_seq_sm == SM_CRITICAL_FAIL);
assign st_disable_5v         = (power_seq_sm == SM_DISABLE_GRP_ATX);
assign st_disable_3v3		= (power_seq_sm == SM_DISABLE_GRP_ATX);
assign st_disable_s5_devices = (power_seq_sm == SM_DISABLE_S5_DEVICES);
assign st_aux_fail_recovery  = (power_seq_sm == SM_AUX_FAIL_RECOVERY);

// Lagging copy of power_seq_sm for checking last state
always @(posedge clk or posedge reset) begin
  if (reset)
    power_seq_sm_last <= 6'b0;
  else if (t1us)
    power_seq_sm_last <= power_seq_sm;
end


//------------------------------------------------------------------------------
// Enable registers
//------------------------------------------------------------------------------
always @(posedge clk or posedge reset) begin
  if (reset) begin
    reg_stuckon_chk_dis <= 1'b1;
    reg_main_power_en   <= 1'b0;
    reg_main_chk_en     <= 1'b0;
    reg_clken           <= 1'b0;
  end
  else if (t1us) begin
    case (power_seq_sm)
      SM_RESET_STATE : begin
        reg_stuckon_chk_dis <= 1'b1;
        reg_main_power_en   <= 1'b0;
        reg_main_chk_en     <= 1'b0;
        reg_clken           <= 1'b0;
      end

      SM_OFF_STANDBY : begin
        reg_stuckon_chk_dis <= 1'b0;
      end

      SM_EN_GRP_D : begin
        reg_main_power_en <= 1'b1;
      end

      SM_EN_GRP_E : begin
        reg_clken <= 1'b1;
      end

      SM_WAIT_POWEROK : begin
        reg_main_chk_en <= 1'b1;
      end
      
      SM_DISABLE_GRP_E: begin
        reg_clken <= 1'b0;
        reg_main_chk_en <= 1'b0;
      end
      
      SM_DISABLE_GRP_D : begin
        reg_main_power_en <= 1'b0;
      end

      SM_DISABLE_GRP_ATX : begin
        reg_main_power_en <= 1'b0;
      end
      
//    default : begin
//      reg_stuckon_chk_dis <= reg_stuckon_chk_dis;
//      reg_main_power_en   <= reg_main_power_en;
//      reg_main_chk_en     <= reg_main_chk_en;
//      reg_clken           <= reg_clken;
//    end
    endcase
  end
end


//------------------------------------------------------------------------------
// Present de-assertion detect (non-BT only)
// - detects device removal case
//------------------------------------------------------------------------------
generate begin : _PRSNT_POSEDGE_DETECT_BLOCK_
  // posedge detector for prsnt_n - removal case
  edge_detect #(.SIGCNT(NUM_DEV), .DEF_INIT({NUM_DEV{1'b1}})) prsnt_n_pe_detect (
    .reset       (reset),
    .clk         (clk),
    .tick        (t1us),
    .signal_in   (prsnt_n),
    .detect_pe   (prsnt_n_pe),
    .detect_ne   (),
    .detect_any  ()
  );
end
endgenerate
  

//------------------------------------------------------------------------------
// Stuckon fault check
//------------------------------------------------------------------------------
generate if (S5DEV_STUCKON_FAULT_CHK) begin : _S5DEV_STUCKON_FAULT_CHK_BLOCK_
  reg  aux_power_cycle;
  wire st_off_standby_dly;

  // Some LOM devices take too long to deassert PGD with respect to EN causing
  // false stuck-on fault check. To avoid this false fault, delay st_off_standby
  // that goes to vrm_enable port of fault_detect_aux below by ~120ms. This
  // should give time for ALOM's PGD to catch up with their EN state.
  edge_delay #(
    .CNTR_NBITS    (2),
    .DEF_OUTPUT    (1'b0),
    .DELAY_MODE    (1'b0)  // Delay rising edge
  ) st_off_standby_delayed_inst (
    .clk           (clk),
    .reset         (reset),
    .cnt_size      (2'd2),
    .cnt_step      (t64ms),
    .signal_in     (st_off_standby),
    .delay_output  (st_off_standby_dly)
  );

  // After an aux power cycle, if there is a stuckon fault (PGD already up before
  // EN is enabled), we'll miss this detection in SM_OFF_STANDBY due to the delay
  // above. This fault is never seen since the pwrseq will go to S5_ENABLE_DEVICE
  // state following a brief visit in STANDBY. The logic below creates a 1us wide
  // pulse in SM_OFF_STANDBY after an aux power cycle. The edges are used to
  // enable window in chklive below to check for stuckon.
  always @(posedge clk or posedge reset) begin
    if (reset)
      aux_power_cycle <= 1'b1;
    else if (t1us && st_off_standby)
      aux_power_cycle <= 1'b0;
  end

  // JLL: Use edge_Detect to detect negedge of reg_stuckon_chk_dis to give us
  //      1us pulse to check for stuckon check after aux power cycle.

  // Enable stuckon check in standby after a power cycle or when device is
  // disabled after enough delay in standby. stuckon_chk_mask is used in
  // aux_power_ok to mask out stuckon fault check until we reach SM_OFF_STANDBY.
  // Without this, the wrong fault bit is asserted early in the power sequence.
  for (i = 0; i < NUM_DEV; i = i + 1) begin : _STUCKON_CHK_EN_BLOCK_
    assign stuckon_chk_en[i] = (aux_power_cycle & st_off_standby)         |
                               (~reg_aux_power_en[i] & st_off_standby_dly);

    assign stuckon_chk_mask[i] = reg_stuckon_chk_dis & ~stuckon_chk_en[i];
  end
end
else begin
  assign stuckon_chk_en   = {NUM_DEV{1'b0}};
  assign stuckon_chk_mask = {NUM_DEV{1'b1}};
end
endgenerate

//------------------------------------------------------------------------------
// Enable and pwrdis logic
//------------------------------------------------------------------------------
generate for (i = 0; i < NUM_DEV; i = i + 1) begin : _S5DEV_GENERATE_BLOCK_
  // Aux power state tracker. This tracks individual device so their power state
  // can be independent of each other.
  always @(posedge clk or posedge reset) begin
    if (reset)
      reg_aux_power_en[i] <= 1'b0;
    else if (t1us && st_disable_s5_devices && (aux_pwrdis_request_reg[i]))
      reg_aux_power_en[i] <= 1'b0;
    else if (t1us && st_off_standby && aux_pwren_request_reg[i])
      reg_aux_power_en[i] <= 1'b1;
  end

  // Enable request logic
  always @(posedge clk or posedge reset) begin
    if (reset)
      aux_pwren_request_reg[i] <= 1'b0;
    else if (t1us)
      aux_pwren_request_reg[i] <=
          (~prsnt_n[i]                 &  // present
           ~aux_fault_pwrdis[i]        &  // not forced off
           ~reg_aux_power_en[i]        &  // currently turned off
            dev_enable[i]);               // not disabled
  end

  // Disable request logic
  always @(posedge clk or posedge reset) begin
    if (reset)
      aux_pwrdis_request_reg[i] <= 1'b0;
    else if (t1us)
      aux_pwrdis_request_reg[i] <=
          (prsnt_n_pe[i] | (~prsnt_n[i]         &       // present
                            reg_aux_power_en[i] &       // currently turned on
                           ~dev_enable[i]));            // disabled, BL: WOL disabled
  end

  // dev_enable - track xreg_disable while in standby
  always @(posedge clk or posedge reset) begin
    if (reset)
      dev_enable[i] <= 1'b0;
    else if (t1us)
      dev_enable[i] <= (st_off_standby) ? 1'b1 : dev_enable[i];
  end
    
  // clr_pwrdis
  // - non-BL/BT can clear the pwrdis flag by setting the xreg disable bit or
  //   device removal.
  assign clr_pwrdis[i] = xreg_disable[i] | prsnt_n[i];
  
  // aux_fault_pwrdis
  // - asserts when device's aux power is forced off due to faults
  always @(posedge clk or posedge reset) begin
    if (reset)
      aux_fault_pwrdis[i] <= 1'b0;
    else if (t1us && st_disable_s5_devices && (aux_fault_det[i] || main_fault_det[i]))
      aux_fault_pwrdis[i] <= 1'b1;
    else if (t1us && clr_pwrdis[i])
      aux_fault_pwrdis[i] <= 1'b0;
  end

  // main_fault_pwrdis
  // - asserts when device's main power is forced off due to faults
  // - for non-BL/BT, can be cleared by setting xreg disable bit or removing device.
  // - CHECKME: Why wait until SM_DISABLE_3V3 to assert?
  always @(posedge clk or posedge reset) begin
    if (reset)
      main_fault_pwrdis[i] <= 1'b0;
    else if (t1us && st_disable_3v3 && main_fault_det[i])
      main_fault_pwrdis[i] <= 1'b1;
    else if (t1us && clr_pwrdis[i])
      main_fault_pwrdis[i] <= 1'b0;
  end
     
  // Device aux power enable asserts on the following:
  assign pal_aux_en[i] = ~prsnt_n[i]                                          &  // present
                         reg_aux_power_en[i]                                  &  // aux power enabled
                         (~aux_fault_det[i] | keep_alive_on_fault)            &  // no aux fault
                         (~main_fault_det[i] | keep_alive_on_fault)           &  // ALOM/BLOM only has single EN, turn off on either fault
                         ~aux_fault_pwrdis[i]                                 &  // not forced off due to aux fault
                         ~main_fault_pwrdis[i];                                // not forced off due to main fault

  // Device main power enable asserts on the following:
  assign pal_main_en[i] = pal_aux_en[i]                             &  // aux power enabled
                          reg_main_power_en                         &  // main power enabled
                          (~main_fault_det[i] | keep_alive_on_fault);  // no main fault
    
  // Device's clock enable
  assign pal_clken[i] = pal_main_en[i] & reg_clken;

  // For non-BT, since ALOM/BLOM only has a single PGD for both aux and main,
  // force aux_power_ok high when starting to track main power. This prevents
  // both aux and main fault flag from asserting during a fault.
  assign aux_power_ok[i] = (~pal_aux_en[i] | pgd_pwr_aux[i] | reg_main_chk_en) &
                           (stuckon_chk_mask[i] | pal_aux_en[i] | ~pgd_pwr_aux[i]);

  assign main_power_ok[i] = ~pal_main_en[i] | ~reg_main_chk_en | pgd_pwr_main[i];
end  
endgenerate
  
// OR of request from each device. pwrseq_master only requires single bit.
assign aux_pwren_request  = |aux_pwren_request_reg;
assign aux_pwrdis_request = |aux_pwrdis_request_reg;


//------------------------------------------------------------------------------
// Fault capture
//------------------------------------------------------------------------------
// For non-BL/BT, if device faults while in SM_ENABLE_S5_DEVICES, we transition
// to SM_DISABLE_S5_DEVICES. Allow fault to be captured in this condition.
assign aux_check_en = st_disable_s5_devices                      &
                      (power_seq_sm_last == SM_ENABLE_S5_DEVICES);
  
// Aux LOM power fault latch logic. Note the critical_fail check is done on
// SM_DISABLE_S5_DEVICES to capture fault when LOM failed to turn on during
// SM_ENABLE_S5_DEVICES state. Also removed delayed version of pal_aux_en
// to drive vrm_enable below as the delay to wait for LOM power stable is
// part of SM_ENABLE_S5_DEVICES state.
fault_detectB_chklive #(.NUMBER_OF_VRM(NUM_DEV)) s5dev_fault_detect_aux (
  .clk              (clk),
  .reset            (reset),
  .vrm_enable       (pal_aux_en | stuckon_chk_en),
  .vrm_pgood        (aux_power_ok),
  .vrm_chklive_en   ({NUM_DEV{st_off_standby}} & reg_aux_power_en),
  .vrm_chklive_dis  (~reg_aux_power_en),
  .critical_fail    (st_critical_fail | aux_check_en | (|stuckon_chk_en)),
  .fault_clear      (st_aux_fail_recovery),
  .lock             (any_pwr_fault_det),
  .any_vrm_fault    (aux_mod_fault),
  .vrm_fault        (aux_fault_det)
);

// Main device power fault latch logic
fault_detectB_chklive #(.NUMBER_OF_VRM(NUM_DEV)) s5dev_fault_detect_main (
  .clk              (clk),
  .reset            (reset),
  .vrm_enable       (pal_main_en),
  .vrm_pgood        (main_power_ok),
  .vrm_chklive_en   ({NUM_DEV{reg_main_chk_en}}),
  .vrm_chklive_dis  ({NUM_DEV{~reg_main_chk_en}}),
  .critical_fail    (st_critical_fail),
  .fault_clear      (fault_clear),
  .lock             (any_pwr_fault_det),
  .any_vrm_fault    (main_mod_fault),
  .vrm_fault        (main_fault_det)
);

// Generate pgd_so_far status
assign pgd_so_far = (&aux_power_ok) & (&main_power_ok);

endmodule


