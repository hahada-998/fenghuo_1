//=================================================================================================--
// Copyright(c) 2021, CLOUDNINEINFO.CO, Ltd, All right reserved
// Filename   : AIS03MB03.v
// Project    : CLOUDNINEINFO common code
// Author     : dingxianhua
// Date       : 2020-09-24
// Email      : dingxianhua@cloudnineinfo.com
// Company    : CLOUDNINEINFO.CO., Ltd
// Description: This module handles FPGA power-on reset. This is basically the source of reset for
//   all the sub-blocks in the top level.
// History    :
//   Date      By          Revision  Change Description
//=================================================================================================

module pon_reset (
  input       clk,                          // main clock (100MHz)
  input       pll_lock,                     // PLL lock signal
  input       pgd_p3v3_stby,                // P3V3_STBY pgood
  input       pgd_aux_gmt,                  // PGD_AUX_GMT signal
  input       done_booting,                 // FPGA done booting image (if not used, set to 1'b1)
  input       done_booting_delayed,         // delayed version of done_booting (if not used, set to 1'b1)
  output      pon_reset_n,                  // master AUX power-on reset (based on pgd_p3v3_stby)
  output reg  pon_reset_db_n,               // pon_reset_n version that is qualified with done_booting_delayed
  output      pgd_aux_system,               // AUX pgood indicator (based on both pgd_p3v3_stby and pgd_aux_gmt)
  output reg  pgd_aux_system_sasd,          // SASD version of pgd_aux_system
  output      cpld_ready                    // FPGA is ready to go (0 means go)
);

wire       master_reset_n;
reg  [2:0] reset1_reg;
reg  [2:0] reset2_reg;
reg        pgd_aux_system_reg;

//------------------------------------------------------------------------------
// Reset output
//------------------------------------------------------------------------------
// Reset everything if pgd_p3v3_stby or pll_lock goes down.
assign master_reset_n = pgd_p3v3_stby & pll_lock;

// Synchronize reset for downstream logic.  Note there's no need to include the
// pgd_p3v3_stby and pll_lock term in resetX_reg terms since they reset to 0
// if any of these signals are low.
always @(posedge clk or negedge master_reset_n)
begin
  if (!master_reset_n)
  begin
    reset1_reg <= 3'b0;
    reset2_reg <= 3'b0;
  end
  else
  begin
    reset1_reg <= {reset1_reg[1:0], 1'b1};
    reset2_reg <= {reset2_reg[1:0], pgd_aux_gmt};
  end
end

assign pon_reset_n    = reset1_reg[2];
assign pgd_aux_system = reset2_reg[2];

// Generate SASD version of pgd_aux_system
always @(posedge clk)
begin
  if (!master_reset_n)
  begin
    pgd_aux_system_reg  <= 1'b0;
    pgd_aux_system_sasd <= 1'b0;
  end
  else
  begin
    pgd_aux_system_reg  <= pgd_aux_system;
    pgd_aux_system_sasd <= pgd_aux_system_reg;
  end
end

// Generate done_booting_delayed qualified version of pon_reset_n
always @(posedge clk or negedge pon_reset_n)
begin
  if (!pon_reset_n)
    pon_reset_db_n <= 1'b0;
  else if (done_booting_delayed)
    pon_reset_db_n <= 1'b1;
end

// Drive cpld_ready low when FPGA is done booting
assign cpld_ready = ~done_booting;

endmodule
