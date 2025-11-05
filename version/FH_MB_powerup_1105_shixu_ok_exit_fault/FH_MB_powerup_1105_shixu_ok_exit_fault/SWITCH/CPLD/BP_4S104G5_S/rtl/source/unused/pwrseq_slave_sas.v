
module pwrseq_slave_sas #(
  parameter NUM_DEV = 1) (

  // Clocks and resets
  input                    reset,               // reset
  input                    clk,                 // clock
  input                    t1us,

  // pwrseq state, status, misc
  input              [5:0] power_seq_sm,        // pwrseq state
  input                    any_pwr_fault_det,   // any power fault detected
  input                    fault_clear,         // clear fault flags
  output                   pgd_so_far,          // pgd_so_far status

  // Xreg control
  input      [NUM_DEV-1:0] xreg_disable,        // Xreg byte 0x49/0x4A (mapping platform specific)
  output reg [NUM_DEV-1:0] dev_enable,          // last state of ~xreg_disable while system is in standby

  // Presence status
  input      [NUM_DEV-1:0] prsnt_n,             // device presence
  input      [NUM_DEV-1:0] intlock_pd,          // critical interlock failure

  // Power enable/status
  output     [NUM_DEV-1:0] pal_en,              // enable device power
  input      [NUM_DEV-1:0] pgd_pwr,             // device power status

  // Fault/pwrdis status
  output                   mod_fault,           // any device aux power fault
  output     [NUM_DEV-1:0] fault_det,           // device aux power fault
  output reg [NUM_DEV-1:0] fault_pwrdis,        // device disabled due to aux power fault
  output reg [NUM_DEV-1:0] intlock_pwrdis,      // disable device due to interlock fault

  // Clock enable
  output     [NUM_DEV-1:0] pal_clken            // device clock enable
);


//------------------------------------------------------------------------------
// Power sequence state definition
//------------------------------------------------------------------------------
`include "pwrseq_define.vh"

//------------------------------------------------------------------------------
// Local sigs
//------------------------------------------------------------------------------
genvar i;
wire st_off_standby;
wire st_critical_fail;
wire st_disable_3v3;

// Enable registers
reg reg_power_en;
reg reg_check_en;
reg reg_clken;

// main logic
wire force_pal_en_low;
wire [NUM_DEV-1:0] power_ok;


//------------------------------------------------------------------------------
// SM states
// - These are just convenience variable for use below
//------------------------------------------------------------------------------
assign st_off_standby     = (power_seq_sm == SM_OFF_STANDBY);
assign st_critical_fail   = (power_seq_sm == SM_CRITICAL_FAIL);
assign st_disable_3v3     = (power_seq_sm == SM_DISABLE_GRP_ATX);


//------------------------------------------------------------------------------
// Enable registers
// - non-BL/BT, reg_power_en is always high
//------------------------------------------------------------------------------
always @(posedge clk or posedge reset) begin
  if (reset) begin
    reg_power_en <= 1'b1;
    reg_check_en <= 1'b0;
    reg_clken    <= 1'b0;
  end
  else if (t1us) begin
    case (power_seq_sm)
      SM_RESET_STATE : begin
        reg_power_en <= 1'b1;
        reg_check_en <= 1'b0;
        reg_clken    <= 1'b0;
      end

      SM_EN_GRP_D : begin
        reg_power_en <= 1'b1;
      end

      SM_EN_GRP_E : begin
        reg_clken    <= 1'b1;
        reg_check_en <= 1'b1;
      end
      
      
      SM_DISABLE_GRP_E : begin
        reg_check_en <= 1'b0;
        reg_clken    <= 1'b0;
      end
      
//    default : begin
//      reg_power_en <= reg_power_en;
//      reg_check_en <= reg_check_en;
//      reg_clken    <= reg_clken;
//    end
    endcase
  end
end


//------------------------------------------------------------------------------
// Generate a 1us pulse to force pal_en low for non-BL/BT
//------------------------------------------------------------------------------
generate begin : _FORCE_PAL_EN_LOW_BLOCK_
  edge_detect sm_ps_en_posedge (
    .reset      (reset),
    .clk        (clk),
    .tick       (t1us),
    .signal_in  (power_seq_sm == SM_PS_ON),
    .detect_pe  (force_pal_en_low),
    .detect_ne  (),
    .detect_any ()
  );
end
endgenerate


//------------------------------------------------------------------------------
// The works
//------------------------------------------------------------------------------
generate for (i = 0; i < NUM_DEV; i = i + 1) begin : _SAS_GENERATE_BLOCK_
  // dev_enable - track xreg_disable while in standby
  always @(posedge clk or posedge reset) begin
    if (reset)
      dev_enable[i] <= 1'b0;
    else if (t1us)
      dev_enable[i] <= (st_off_standby) ? ~xreg_disable[i] : dev_enable[i];
  end

  // power enable
  // - BL/BT - enabled on when PCH_1V5 (BL) or 3V3 (BT)
  // - non-BL/BT
  //   - always enabled unless xreg_disable is set
  //   - driven low for 1us on entry to SM_PS_ON to clear faults in SAS CPLD, if any.
  assign pal_en[i] = ~prsnt_n[i]       &  // present
                      dev_enable[i]    &  // enabled
                      reg_power_en     &  // sequenced enabled
                     ~force_pal_en_low &  // not forced low
                     ~fault_pwrdis[i]  &  // no power fault
                     ~intlock_pwrdis[i];  // no interlock fault

  // power_ok status
  assign power_ok[i] =  prsnt_n[i]  |  // present
                       ~pal_en[i]   |  // power enabled
						pgd_pwr[i]  |  // pgood
                       ~reg_check_en;  // check enabled

  // clock enable
  assign pal_clken[i] = pal_en[i] & reg_clken;

  // fault_pwrdis
  // - asserts when device's power is forced off due to faults
  // - cleared only during aux power cycle
  always @(posedge clk or posedge reset) begin
    if (reset)
      fault_pwrdis[i] <= 1'b0;
    else if (t1us && st_disable_3v3 && fault_det[i])
      fault_pwrdis[i] <= 1'b1;
  end

  // intlock_pwrdis
  // - asserts when device's power is forced off due to interlock failure
  // - cleared only during aux power cycle
  always @(posedge clk or posedge reset) begin
    if (reset)
      intlock_pwrdis[i] <= 1'b0;
    else if (t1us && st_disable_3v3 && intlock_pd[i])
      intlock_pwrdis[i] <= 1'b1;
  end
end  
endgenerate

// fault capture logic
fault_detectB_chklive #(.NUMBER_OF_VRM(NUM_DEV)) sas_fault_detect (
  .clk              (clk),
  .reset            (reset),
  .vrm_enable       (pal_en),
  .vrm_pgood        (power_ok),  
  .vrm_chklive_en   ({NUM_DEV{ reg_check_en}}),
  .vrm_chklive_dis  ({NUM_DEV{~reg_check_en}}),
  .critical_fail    (st_critical_fail),
  .fault_clear      (fault_clear),
  .lock             (any_pwr_fault_det),
  .any_vrm_fault    (mod_fault),
  .vrm_fault        (fault_det)
);

// pgd_so_far
assign pgd_so_far = &power_ok;

endmodule

