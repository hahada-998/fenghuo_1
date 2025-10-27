//=================================================================================================
// Copyright(c) 2021, CLOUDNINEINFO.CO, Ltd, All right reserved
// Filename   : pwrseq_slave_pch.v
// Project    : CLOUDNINEINFO common code
// Author     : dingxianhua
// Date       : 2017-07-18
// Email      : dingxianhua@cloudnineinfo.com
// Company    : CLOUDNINEINFO.CO., Ltd
// Description: This module handles the power control and monitor of PCH rails. Also handles other
//   signals required for power control.
// Parameter  :
// BOUND_SYS_PWROK: If set, wait for delay of 25ms once in SM_STEADY_OK before asserting
//   pch_sys_pwrok instead of waiting on gmt_sysrst_n. If cleared, wait for de-assertion of
//   gmt_sysrst_n before asserting pch_sys_pwrok. This parameter allows bounding the pch_sys_pwrok
//   assertion to bound PCH's PROCPWRGD to PLTRST# delay.
//   Default: 1'b1
// History    :
//   Date      By          Revision  Change Description
//=================================================================================================

module pwrseq_slave_pch #(
  parameter BOUND_SYS_PWROK = 1'b1) (
  input        reset,                   // reset
  input        clk,                     // clock
  input        t1us,
  input        t2ms,

  // Control, status
  input  [5:0] power_seq_sm,            // pwrseq state
  input        any_pwr_fault_det,       // any power fault detected
  input        fault_clear,             // clear fault flags
  input        gmt_sysrst_n,            // iLO initiated system reset
  input        pgood_rst_mask,          // from adr module
  input        keep_alive_on_fault,     // when asserted, a fault will not mask the corresponding enable signal (default to 1'b0, debug only)
  input        rt_critical_fail_store,  // asserts when during runtime when critical failure detected
  output       pgd_so_far,              // pgd_so_far for PCH rails

  // SLPSUS#/VRD status
  input        pch_slpsus_n,
  input        pgd_p1v8_pch_stby,
  input        pgd_pvnn_pch_stby,
  input        pgd_p1v05_pch_stby,

  // EN, PWROK
  output       p1v8_pch_stby_en,
  output       pvnn_pch_stby_en,
  output       p1v05_pch_stby_en,
  output       pch_dsw_pwrok,
  output       pch_rsmrst_n,
  output reg   pch_pwrok,
  output reg   pch_sys_pwrok,

  // Fault status
  output       any_pch_fault_det,
  output       slpsus_pch_fault_det,
  output       p1v8_pch_fault_det,
  output       pvnn_pch_fault_det,
  output       p1v05_pch_fault_det
);

`include "pwrseq_define.vh"

wire st_wait_powerok      ;
wire st_steady_pwrok      ;
wire st_disable_vmcp      ;
wire st_disable_vccsa     ;
wire st_en_pch_p1v8       ;
wire st_en_pch_pvnn       ;
wire st_en_pch_p1v05      ;
wire st_pch_rsmrst_release;
wire st_critical_fail     ;
reg  reg_p1v8_pch_en  ;
reg  reg_pvnn_pch_en  ;
reg  reg_p1v05_pch_en ;
reg  reg_pch_dsw_pwrok;
reg  reg_pch_rsmrst   ;
wire any_pch_fault_det_dly;
wire slpsus_pch_ok;
wire p1v8_pch_ok  ;
wire pvnn_pch_ok  ;
wire p1v05_pch_ok ;
wire pch_sys_pwrok_en;


//------------------------------------------------------------------------------
// SM states
// - The st_* stuff are just convenience variable that can be used throughout.
//------------------------------------------------------------------------------
assign st_wait_powerok       = (power_seq_sm==SM_WAIT_POWEROK      );
assign st_steady_pwrok       = (power_seq_sm==SM_STEADY_PWROK      );
assign st_disable_vmcp       = (power_seq_sm==SM_DISABLE_VMCP      );
assign st_disable_vccsa      = (power_seq_sm==SM_DISABLE_VCCSA     );

assign st_en_pch_p1v8        = (power_seq_sm==SM_EN_PCH_P1V8       );
assign st_en_pch_pvnn        = (power_seq_sm==SM_EN_PCH_PVNN       );
assign st_en_pch_p1v05       = (power_seq_sm==SM_EN_PCH_P1V05      );
assign st_pch_rsmrst_release = (power_seq_sm==SM_PCH_RSMRST_RELEASE);
assign st_critical_fail      = (power_seq_sm==SM_CRITICAL_FAIL     );


//------------------------------------------------------------------------------
// Enable registers
//------------------------------------------------------------------------------
always @(posedge clk or posedge reset) begin
  if (reset) begin
    reg_p1v8_pch_en   <= 1'b0;
    reg_pvnn_pch_en   <= 1'b0;
    reg_p1v05_pch_en  <= 1'b0;
    reg_pch_dsw_pwrok <= 1'b0;
    reg_pch_rsmrst    <= 1'b1;
  end
  else if (t1us) begin
    case (power_seq_sm)
      SM_RESET_STATE : begin
        reg_p1v8_pch_en   <= 1'b0;
        reg_pvnn_pch_en   <= 1'b0;
        reg_p1v05_pch_en  <= 1'b0;
        reg_pch_dsw_pwrok <= 1'b0;
        reg_pch_rsmrst    <= 1'b1;
      end

      SM_EN_PCH_DSW_PWROK : begin
        reg_pch_dsw_pwrok <= 1'b1;
      end

      SM_EN_PCH_P1V8 : begin
        reg_p1v8_pch_en <= 1'b1;
      end

      SM_EN_PCH_PVNN : begin
        reg_pvnn_pch_en <= 1'b1;
      end

      SM_EN_PCH_P1V05 : begin
        reg_p1v05_pch_en <= 1'b1;
      end

      SM_PCH_RSMRST_RELEASE : begin
        reg_pch_rsmrst <= 1'b0;
      end

      SM_HALT_POWER_CYCLE : begin
      	if (any_pch_fault_det) begin
          reg_p1v8_pch_en   <= 1'b0;
          reg_pvnn_pch_en   <= 1'b0;
          reg_p1v05_pch_en  <= 1'b0;
          reg_pch_dsw_pwrok <= 1'b0;
          reg_pch_rsmrst    <= 1'b1;
        end
      end

//    default : begin
//      reg_p1v8_pch_en   <= reg_p1v8_pch_en;
//      reg_pvnn_pch_en   <= reg_pvnn_pch_en;
//      reg_p1v05_pch_en  <= reg_p1v05_pch_en;
//      reg_pch_dsw_pwrok <= reg_pch_dsw_pwrok;
//      reg_pch_rsmrst    <= reg_pch_rsmrst;
//    end
    endcase
  end
end


//------------------------------------------------------------------------------//
// Enable logic
//------------------------------------------------------------------------------
// For any PCH rail fault, generate a ~1us delay of any_pch_fault_det to mask out
// the en signals above. This is to allow RSMRST_N to drop 1us before any of the
// rails (LBG EDS T23).
edge_delay #(.CNTR_NBITS(1)) any_pch_fault_det_dly_inst (
  .clk          (clk),
  .reset        (reset),
  .cnt_size     (1'd1),
  .cnt_step     (t1us),
  .signal_in    (any_pch_fault_det),
  .delay_output (any_pch_fault_det_dly)
);

// PCH P1V8
assign p1v8_pch_stby_en = reg_p1v8_pch_en & (~any_pch_fault_det_dly | keep_alive_on_fault);
assign p1v8_pch_ok     = ~p1v8_pch_stby_en | pgd_p1v8_pch_stby;

// PCH PVNN
assign pvnn_pch_stby_en = reg_pvnn_pch_en & (~any_pch_fault_det_dly | keep_alive_on_fault);
assign pvnn_pch_ok     = ~pvnn_pch_stby_en | pgd_pvnn_pch_stby;

// PCH 1.05V
assign p1v05_pch_stby_en = reg_p1v05_pch_en & (~any_pch_fault_det_dly | keep_alive_on_fault);
assign p1v05_pch_ok     = ~p1v05_pch_stby_en | pgd_p1v05_pch_stby;

// Generate pgd_so_far status
assign pgd_so_far = slpsus_pch_ok & p1v8_pch_ok & pvnn_pch_ok & p1v05_pch_ok;


//------------------------------------------------------------------------------
// Fault detect
//------------------------------------------------------------------------------
fault_detectB_chklive #(.NUMBER_OF_VRM(4)) stby_fault_detect_inst (
  .clk              (clk),
  .reset            (reset),
  .vrm_enable       ({reg_pch_dsw_pwrok,
                      p1v8_pch_stby_en,
                      pvnn_pch_stby_en,
                      p1v05_pch_stby_en}),
  .vrm_pgood        ({pch_slpsus_n,
                      pgd_p1v8_pch_stby,
                      pgd_pvnn_pch_stby,
                      pgd_p1v05_pch_stby}),
  .vrm_chklive_en   ({st_en_pch_p1v8,
                      st_en_pch_pvnn,
                      st_en_pch_p1v05,
                      st_pch_rsmrst_release}),
  .vrm_chklive_dis  ({4{any_pch_fault_det}}),
  .critical_fail    (st_critical_fail),
  .fault_clear      (fault_clear),
  .lock             (any_pwr_fault_det),
  .any_vrm_fault    (any_pch_fault_det),
  .vrm_fault        ({slpsus_pch_fault_det,
                      p1v8_pch_fault_det,
                      pvnn_pch_fault_det,
                      p1v05_pch_fault_det})
);


//------------------------------------------------------------------------------
// DSW_PWROK logic
// - This is deasserted on any PCH fault (SLPSUS# or PCH rails)
// - SLPSUS# is treated like a VRD PGD since it behaves much the same way where
//   it goes high (de-asserts) when DSW_PWROK asserts.
//------------------------------------------------------------------------------
assign pch_dsw_pwrok = reg_pch_dsw_pwrok & ~any_pch_fault_det;
assign slpsus_pch_ok = ~pch_dsw_pwrok | pch_slpsus_n;


//------------------------------------------------------------------------------
// RSMRST logic
// - Per PCH spec (T11), RSMRST_N is de-asserted at least 10ms after all PCH
//   primary rails is stable (T11).
// - RSMRST_N is asserted if any of the PCH rail has faulted. Per PCH spec (T23),
//   RSMRST_N must be asserted at least 1us before any of the rails goes down.
//   On any sign of PCH rail fault, we drop RSMRST_N first, wait ~1us, and then
//   drop all power rails simultaneously.
//------------------------------------------------------------------------------
assign pch_rsmrst_n = ~(reg_pch_rsmrst | any_pch_fault_det);


//------------------------------------------------------------------------------
// PCH_PWROK logic
// - Asserts on entry to SM_WAIT_POWEROK
// - Keep asserted while system power is on and pgood_rst_mask asserted
// - De-assert on power down or power fault
//------------------------------------------------------------------------------
always @(posedge clk or posedge reset) begin
  if (reset)
    pch_pwrok <= 1'b0;
  else if (pgood_rst_mask && st_steady_pwrok && pch_pwrok)
    pch_pwrok <= 1'b1;
  else if ((t1us && (st_disable_vmcp || st_disable_vccsa)) || rt_critical_fail_store)
    pch_pwrok <= 1'b0;
  else if (t1us && st_wait_powerok)
    pch_pwrok <= 1'b1;
end


//------------------------------------------------------------------------------
// PCH_SYS_PWROK logic
//------------------------------------------------------------------------------
// If BOUND_SYS_PWROK is set, use a delay timer to bound the assertion of
// pch_sys_pwrok within ~22ms after system reached SM_STEADY_OK. Otherwise,
// rely on GMT_SYSRST_N to gate pch_sys_pwrok assertion.
generate if (BOUND_SYS_PWROK) begin : _BOUND_SYS_PWROK_BLOCK_
  // 25ms delay
  edge_delay #(.CNTR_NBITS(4)) bound_sys_pwrok_delay_inst (
    .clk           (clk),
    .reset         (reset),
    .cnt_size      (4'd11),
    .cnt_step      (t2ms),
    .signal_in     (st_steady_pwrok & ~rt_critical_fail_store),
    .delay_output  (pch_sys_pwrok_en)
  );
end
else begin
  assign pch_sys_pwrok_en = gmt_sysrst_n;
end
endgenerate

// Assert pch_sys_pwrok when in SM_STEADY_PWROK and pch_sys_pwrok_en is asserted.
// De-assert on powerdown or power fault. Allow ADR to keep it high if needed but
// only if it's already high.
always @(posedge clk or posedge reset) begin
  if (reset)
    pch_sys_pwrok <= 1'b0;
  else if (pgood_rst_mask && st_steady_pwrok && pch_sys_pwrok)
    pch_sys_pwrok <= 1'b1;
  else if ((t1us && (st_disable_vmcp || st_disable_vccsa)) || rt_critical_fail_store)
    pch_sys_pwrok <= 1'b0;
  else if (t1us && st_steady_pwrok && pch_sys_pwrok_en)
    pch_sys_pwrok <= 1'b1;
end

endmodule
