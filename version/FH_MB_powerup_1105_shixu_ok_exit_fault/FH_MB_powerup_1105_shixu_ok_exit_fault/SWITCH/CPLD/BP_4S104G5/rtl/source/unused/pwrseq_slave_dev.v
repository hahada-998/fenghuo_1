//=================================================================================================
// Copyright(c) 2021, CLOUDNINEINFO.CO, Ltd, All right reserved
// Filename   : pwrseq_slave_dev.v
// Project    : CLOUDNINEINFO common code
// Author     : dingxianhua
// Date       : 2017-07-18
// Email      : dingxianhua@cloudnineinfo.com
// Company    : CLOUDNINEINFO.CO., Ltd
// Description: This is a generic module that control and monitors device handles and reports power
//   faults.
// Parameter  :
//   NUM_DEV: Number of devices to support.
//   Default: 1
// History    :
//   Date      By          Revision  Change Description
//=================================================================================================

module pwrseq_slave_dev #(parameter NUM_DEV = 1) (
  input                    reset,               // reset
  input                    clk,                 // clock
  input                    t1us,

  // control/status
  input                    gate_en,             // pal_en additional qualifier
  input                    keep_alive_on_fault, // when asserted, a fault will not mask the corresponding enable signal (default to 1'b0, debug only)
  input                    chklive_en,          // enable fault detection
  input                    chklive_dis,         // disable fault detection
  input                    pwrdis_en,           // enable assertion of pwrdis output on fault
  input                    sm_critical_fail,    // pwrseq in SM_CRITICAL_FAIL
  input                    fault_clear,         // clear fault flags
  input                    any_pwr_fault_det,   // any power fault detected
  output                   pgd_so_far,          // pgd_so_far status

  // Presence status
  input      [NUM_DEV-1:0] prsnt_n,             // device presence

  // Power enable/status
  output     [NUM_DEV-1:0] pal_en,              // enable device power
  input      [NUM_DEV-1:0] pgd_pwr,             // device power status

  // Fault/pwrdis status
  output                   mod_fault,           // any device aux power fault
  output     [NUM_DEV-1:0] fault_det,           // device aux power fault
  output reg [NUM_DEV-1:0] fault_pwrdis         // device disabled due to aux power fault
);

genvar i;
wire [NUM_DEV-1:0] power_ok;

generate for (i = 0; i < NUM_DEV; i = i + 1) begin : _DEV_GENERATE_BLOCK_
  // pal_en is a function of presence, gate_en, pwrdis and fault status
  assign pal_en[i] = ~prsnt_n[i]                          &
                      gate_en                             &
                     ~fault_pwrdis[i]                     &
                     (~fault_det[i] | keep_alive_on_fault);

  // power_ok
  assign power_ok[i] =  prsnt_n[i] |  // present
                       ~pal_en[i]  |  // power enabled
                        pgd_pwr[i];   // pgood

  // pwrdis
  always @(posedge clk or posedge reset) begin
    if (reset)
      fault_pwrdis[i] <= 1'b0;
    else if (t1us && pwrdis_en && fault_det[i])
      fault_pwrdis[i] <= 1'b1;
  end
end
endgenerate

// fault capture module
fault_detectB_chklive #(.NUMBER_OF_VRM(NUM_DEV)) dev_fault_detect (
  .clk              (clk),
  .reset            (reset),
  .vrm_enable       (pal_en),
  .vrm_pgood        (pgd_pwr),
  .vrm_chklive_en   ({NUM_DEV{chklive_en}}),
  .vrm_chklive_dis  ({NUM_DEV{chklive_dis}}),
  .critical_fail    (sm_critical_fail),
  .fault_clear      (fault_clear),
  .lock             (any_pwr_fault_det),
  .any_vrm_fault    (mod_fault),
  .vrm_fault        (fault_det)
);

// pgd_so_far
assign pgd_so_far = &power_ok;

endmodule
