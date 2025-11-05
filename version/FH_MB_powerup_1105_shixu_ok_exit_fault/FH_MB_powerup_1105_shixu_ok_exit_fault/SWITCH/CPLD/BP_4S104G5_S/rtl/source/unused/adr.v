//=================================================================================================--
// Copyright(c) 2021, CLOUDNINEINFO.CO, Ltd, All right reserved
// Filename   : AIS03MB03.v
// Project    : CLOUDNINEINFO common code
// Author     : dingxianhua
// Date       : 2020-09-24
// Email      : dingxianhua@cloudnineinfo.com
// Company    : CLOUDNINEINFO.CO., Ltd
// Description:This module creates project top source. 
// History    :
// Date      By          Revision  Change Description
//20210918   lizhonglei   ver1.0    file creat
//=================================================================================================

module adr(
  input       pgd_aux_gmt_async,        // in:  module main reset
  input       pch_pltrst_n,             // in:  synchronized version of PCH's PLTRST# signal
  input       pgood,                    // in:  system pgood state (use PGD_GMT - already synchronized in system_reset)
  input       clk,                      // in:  main 100MHz clock
  input       t1us,              // in:  10ns tick every 1us
  input       t16us,             // in:  10ns tick every 15.2us
  input       orange_enable,            // in:  GPO Peavey enable bit      (from GPO0 byte5[0])
  input       adr_trigger_manual,       // in:  GPO ADR manual trigger     (from GPO0 byte3[7])
  input       auto_adr_pfault_enable,   // in:  GPO ADR power fault enable (from GPO0 byte3[6])
  input       save_assert_manual,       // in:  GPO ADR assert save        (from GPO0 byte3[5])
  input       st_steady_pwrok,          // in:  power sequencer in SM_STEADY_PWROK (from pwrseq_master module)
  input       pch_slp4_n,               // in:  synchronized version of PCH's SLP4# signal
  input       rt_critical_fail_store,   // in:  runtime critical fail detected (from pwrseq_master module)
  input       adr_complete,             // in:  synchronized version of PCH's ADR_COMPLETE signal
  output reg  pgood_rst_mask,           // out: mask out system shutdown (to pwrseq_master/slave and system_reset modules)
  output reg  adr_trigger,              // out: to PCH's ADR_TRIGGER
  output      sync_adr_complete,        // out: ADR complete       (to GPI byte3[7])
  output      adr_event,                // out: ADR event detected (to gpi byte3[6])
  output reg  reset_io,                 // out: PCI reset (to system_reset module)
  output reg  save                      // out: to megacell
);

localparam [2:0] IDLE        = 3'b000,
                 ADR_ARMED   = 3'b001,
                 ADR_TRIGGER = 3'b011,
                 SAVE        = 3'b111,
                 DONE        = 3'b110;

reg [2:0] adr_st, n_adr_st;
reg [5:0] adr_tout_cntr, n_adr_tout_cntr;
reg [3:0] save_assert_cntr, n_save_assert_cntr;
reg [3:0] reset_tout_cntr, n_reset_tout_cntr;
reg       orange_enable_r1;
reg       orange_enable_detect;
reg       orange_enable_clr, n_orange_enable_clr;
reg       n_pgood_rst_mask;
reg       n_adr_trigger;
reg       n_reset_io;
reg       n_save;
wire      save_event;
reg       save_event_dly;
reg [1:0] delay_cnt;

// Map adr_complete to sync_adr_complete. No need to synchronize here since
// we're expecting a synchronized adr_complete signal to be passed to this module.
assign sync_adr_complete = adr_complete;

// ADR events include Power Fault, AC Loss. This signal
// includes 12V Droop and other power faults.
assign adr_event = rt_critical_fail_store;

// Save events are SLP_S4# assertion, PLTRST# assertion. This can occur
// because of graceful reset and shutdowns perform a reset-warn over DMI
// to the CPUs.
assign save_event = !pch_slp4_n || !pch_pltrst_n;

// Delaying to account for internal Wellsburg triggers that will
// generate an ADR, and ADR_COMPLETE will assert. This is too avoid
// a possible race condition.
always @(posedge clk or negedge pgd_aux_gmt_async)
begin
  if (!pgd_aux_gmt_async)
  begin
    delay_cnt      <= 2'b00;
    save_event_dly <= 1'b0;
  end
  else if (!save_event)
  begin
    delay_cnt      <= 2'b00;
    save_event_dly <= 1'b0;
  end
  else if (t1us)
  begin
    delay_cnt      <= (delay_cnt == 2'b10) ? delay_cnt : delay_cnt + 1'b1;
    save_event_dly <= (delay_cnt == 2'b10);
  end
end

always @(posedge clk or negedge pgd_aux_gmt_async)
begin
  if (!pgd_aux_gmt_async)
  begin
    adr_st[2:0]           <= IDLE;
    adr_tout_cntr[5:0]    <= 6'b110110;
    save_assert_cntr[3:0] <= 4'b1010;
    reset_tout_cntr[3:0]  <= 4'b1010;
    orange_enable_r1      <= 1'b0;
    orange_enable_detect  <= 1'b0;
    pgood_rst_mask        <= 1'b0;
    adr_trigger           <= 1'b0;
    save                  <= 1'b0;
    reset_io              <= 1'b0;
    orange_enable_clr     <= 1'b0;
  end
  else
  begin
    adr_st[2:0]           <= n_adr_st[2:0];
    adr_tout_cntr[5:0]    <= n_adr_tout_cntr[5:0];
    save_assert_cntr[3:0] <= n_save_assert_cntr[3:0];
    reset_tout_cntr[3:0]  <= n_reset_tout_cntr[3:0];
    orange_enable_r1      <= orange_enable;
    // This signal detects the low to high edge of the "orange_enable" gpo.
    // This signal is cleared once "SAVE" is asserted. To re-arm, the gpo
    // must be cleared and set again for warm resets. Cold boot will clear
    // the gpo. So ROM must clear the bit before setting it in post.
    orange_enable_detect  <= orange_enable_clr                  ? 1'b0 :
                             orange_enable && !orange_enable_r1 ? 1'b1 :
                             orange_enable_detect;
    pgood_rst_mask        <= n_pgood_rst_mask;
    adr_trigger           <= n_adr_trigger;
    save                  <= n_save;
    reset_io              <= n_reset_io;
    orange_enable_clr     <= n_orange_enable_clr;
  end
end

always @(*)
begin
  // Hold current state if no transitions occur.
  n_adr_st[2:0]           = adr_st[2:0];
  n_pgood_rst_mask        = pgood_rst_mask;
  n_adr_trigger           = adr_trigger;
  n_adr_tout_cntr[5:0]    = adr_tout_cntr[5:0];
  n_save                  = save;
  n_save_assert_cntr[3:0] = save_assert_cntr[3:0];
  n_reset_io              = reset_io;
  n_orange_enable_clr     = 1'b0;
  n_reset_tout_cntr[3:0]  = reset_tout_cntr[3:0];

  case (adr_st)
    IDLE : begin
      n_adr_tout_cntr[5:0]    = 6'b110110;
      n_save_assert_cntr[3:0] = 4'b1010;
      n_reset_tout_cntr[3:0]  = 4'b1010;
      if (!pch_pltrst_n)
        begin
          n_adr_trigger = 1'b0;
          n_reset_io = 1'b0;
        end
      // Arm ADR if orange is enabled and we are in a steady power state out of reset.
      if (orange_enable_detect && st_steady_pwrok && pch_pltrst_n && pgood)
      begin
        n_adr_st[2:0]    = ADR_ARMED;
        n_pgood_rst_mask = 1'b1;
      end
    end

    ADR_ARMED : begin
      // Generate "ADR_TRIGGER" for AC loss and power faults
      if ((adr_event && auto_adr_pfault_enable) || adr_trigger_manual)
      begin
        n_adr_st[2:0] = ADR_TRIGGER;
        n_adr_trigger = 1'b1;
        if (!adr_trigger_manual)
        begin
          n_reset_io = 1'b1;
        end
      end
      // Generate "SAVE" for internal ADR and graceful resets/power downs
      else if (adr_complete || save_event_dly || save_assert_manual)
      begin
        n_adr_st[2:0] = SAVE;
        n_save        = 1'b1;
      end
    end

    ADR_TRIGGER : begin
      // Timeout after ~800us (max ADR Time via SB) if no "ADR_COMPLETE" detected
      if (t16us && (|adr_tout_cntr[5:0]))
      begin
        n_adr_tout_cntr[5:0] = adr_tout_cntr[5:0] - 6'b000001;
      end

      // Assert "SAVE"
      if (adr_complete || !(|adr_tout_cntr[5:0]))
      begin
        n_adr_st[2:0] = SAVE;
        n_save        = 1'b1;
      end
    end

    SAVE : begin
      // Assert "save" for ~10us. NVDIM spec is ~7us min.
      if (t1us && (|save_assert_cntr[3:0]))
      begin
        n_save_assert_cntr[3:0] = save_assert_cntr[3:0] - 4'b0001;
      end

      if (!(|save_assert_cntr[3:0]))
      begin
        n_adr_st[2:0]       = DONE;
        // Allow SAVE to remain asserted for power fault case
        if (!reset_io)
          begin
            n_save          = 1'b0;
          end
        n_orange_enable_clr = 1'b1;
        n_pgood_rst_mask    = 1'b0;
      end
    end

    DONE : begin
      // Wait for PLTRST# assertion. Timeout after ~150us.
      // This will prevent potential reset de-assertions.
      if (t16us && (|reset_tout_cntr[3:0]))
      begin
        n_reset_tout_cntr[3:0] = reset_tout_cntr[3:0] - 4'b0001;
      end

      if (!pch_pltrst_n || !(|reset_tout_cntr[3:0]) || save_assert_manual)
      begin
        n_adr_st[2:0] = IDLE;
      end
    end

    default : begin
      n_adr_st[2:0] = IDLE;
    end
  endcase
end

endmodule
