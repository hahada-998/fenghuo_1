//=================================================================================================--
// Copyright(c) 2021, CLOUDNINEINFO.CO, Ltd, All right reserved
// Filename   : AIS03MB03.v
// Project    : CLOUDNINEINFO common code
// Author     : dingxianhua
// Date       : 2020-09-24
// Email      : dingxianhua@cloudnineinfo.com
// Company    : CLOUDNINEINFO.CO., Ltd
// Description: This module Module comtrol the power capping and power LED status.
//   |vdd3_psnt_  |pwrcap_en  |pwr***_wait  |pwrcap_denied |pwrcap_LED   |pwrbtn_LED
//   |0           |X          |X            |X             |off          |Amber
//   |0           |X          |1            |0             |solid Green  |Green blink
//   |0           |X          |0            |1             |Amber blink  |Amber
//   |1           |1          |0            |0             |solid green  |solid green
//   |1           |0          |0            |0             |off          |solid green
// History    :
//   Date      By          Revision  Change Description
//=================================================================================================

//`include "wpspo_g5_define.vh"
`include "as03mb03_define.vh"
module pwrcap_pwrbtn_led (
    input  wire          sys_clk,
    input  wire          reset_n, // p3v3_stby_pgd
    input  wire          vdd3_pgood,
    input  wire          onehz_clk,
    input  wire          pwrcap_en,
    input  wire          pwrcap_denied,
    input  wire          pwrcap_wait,
    input  wire          pwrseq_wait,

`ifdef BL_MODE
    input  wire          ilo_btnrdy,
    input  wire          wait_40s_on_bench_exp,
`endif
    input  wire          power_fault,
    input  wire          fault_blink_code,
    output reg           pwrcap_grn,
    output reg           pwrcap_amb,
    output reg           pwrbtn_grn,
    output reg           pwrbtn_amb
  );

//==============================================================================
// Main Logic ---- power button LED control
//==============================================================================
// If system is in WAIT state, blink green LED at one hz, else track
// the 3.3V plane. If you are in WAIT state, turn off AMBER LED so GREEN LED
// can blink. Otherwise, follow state of the inversion of the 3.3V plane.
//==============================================================================
always @(posedge sys_clk or negedge reset_n)
  begin
    if (!reset_n)
      begin
        pwrbtn_grn <= 1'b0;
        pwrbtn_amb <= 1'b0;
      end
    else if (power_fault)
      begin
        pwrbtn_grn <= 1'b0;
        pwrbtn_amb <= fault_blink_code;
      end
`ifdef BL_MODE
    else if (ilo_btnrdy)
      begin
        pwrbtn_grn <= (pwrcap_wait || pwrseq_wait) ? onehz_clk : vdd3_pgood;
        pwrbtn_amb <= (pwrcap_wait || pwrseq_wait) ? 1'b0 : (!vdd3_pgood) &&
                      (onehz_clk || wait_40s_on_bench_exp);
      end
    else
      begin
        pwrbtn_grn <= 1'b0;
        pwrbtn_amb <= onehz_clk;
      end
  end
`else // not BL_MODE
    else
      begin
        pwrbtn_grn <= (pwrcap_wait || pwrseq_wait) ? onehz_clk : vdd3_pgood;
        pwrbtn_amb <= (pwrcap_wait || pwrseq_wait) ? 1'b0 : !vdd3_pgood;
      end
  end
`endif

//==============================================================================
// Main Logic ---- power capping LED control
//==============================================================================
always @(posedge sys_clk or negedge reset_n)
  begin
    if (!reset_n)
      begin
        pwrcap_grn <= 1'b0;
      end
    else
      begin
        pwrcap_grn <= pwrcap_en && (pwrcap_wait || pwrseq_wait || vdd3_pgood);
      end
  end

always @(posedge sys_clk or negedge reset_n)
  begin
    if (!reset_n)
      begin
        pwrcap_amb <= 1'b0;
      end
    else
      begin
        pwrcap_amb <= onehz_clk && pwrcap_denied;
      end
  end

endmodule
