//=================================================================================================--
// Copyright(c) 2021, CLOUDNINEINFO.CO, Ltd, All right reserved
// Filename   : AIS03MB03.v
// Project    : CLOUDNINEINFO common code
// Author     : dingxianhua
// Date       : 2020-09-24
// Email      : dingxianhua@cloudnineinfo.com
// Company    : CLOUDNINEINFO.CO., Ltd
// Description:
// History    :
//   Date      By          Revision  Change Description
//=================================================================================================//

module system_reset #(
  parameter PEAVEY_SUPPORT           = 1'b1, // Enable peavey support
  parameter MAX_HSB_EVENTS_PER_RESET = 4,    // max number of BOOTNEXT_N assertion per reset
  parameter MAX_HSB_RST_ATTEMPT      = 1,    // max number of resets due to HSB before asserting hsb_fail_n
  parameter NUM_CPU                  = 2,    // number of CPUs
  parameter NUM_IO                   = 1) (  // number of IO reset to drive out

  // Clocks and resets
  input       clk,                          // main clock (100MHz)
  input       reset,                        // reset
  input       t1us,                         // 10ns pulse every 1us

  // Power sequencer status
  input       st_steady_pwrok,              // power sequencer in power OK status
  input       reached_sm_pre_wait_powerok,  // power sequencer in pre_wait_powerok state
  input       rt_critical_fail_store,       // power sequencer detected power fault

  // Reset stimulus - these nets should have been debounced and synchronized
  input       glp_bootnext_n,               // GLP BOOTNEXT_N signal
  input       glp_sysrst_n,                 // GLP SYSRST_N signal
  input       sysrst_button_n,              // External reset button
  input       pch_cpupwrok,                 // PCH CPUPWROK signal
  input       pch_pltrst_n,                 // PCH PLTRST signal
//  input       xdp_cpu_syspwrok,             // XDP HOOK[7] - controls PCH SYS_RESET#
//  input       caterr_detect,                // Comes from CATERR/MSMI handler. Asserts when hold or pulse is detected.
//  input       rst_pcie_pch_n,               // BIOS initiated PCIE reset (PCIe hosted in PCH)
//  input       rst_pcie_cpu_n,               // BIOS initiated PCIE reset (PCIe hosted in CPU)

  // Peavey support (only in affect with PEAVEY_SUPPORT)
//  input       pgood_rst_mask,               // Masks CPU reset when asserted
//  input       reset_pci_io,                 // Forces PCI IO reset when asserted
  output reg  pch_pltrst_n_qual,            // Qualified pch_pltrst_n for ADR module

  // HSB
  input       hsb_en,                       // Enable HSB
  output reg  hsb_fail_n,                   // Max number of resets due to HSB has been reached

  // Forcepr mask
  output reg  forcepr_mask,                 // Mask assertion of FORCEPR output

  // Reset output
  output reg               pal_sys_reset,   // System reset request (non-hiZ output)
  output                   pal_sys_reset_n, // System reset request (drives PCH's SYSRST input, hi-Z)
  output reg               pgd_gmt          // GLP PGOOD driver
//  output reg               rst_gmt_n,       // GLP PCIe reset
//  output reg               gmt_lreset_n,    // GLP LPC reset
//  output reg  [NUM_IO-1:0] rst_io_n,        // IO reset driver

  // CPU nets
//  input      [NUM_CPU-1:0] cpu_prsnt_n      // CPU presence
//  output reg [NUM_CPU-1:0] pgd_cpu,         // CPU PGD output
//  output reg [NUM_CPU-1:0] rst_cpu_n        // CPU reset output
);


//------------------------------------------------------------------------------
// Parameter
//------------------------------------------------------------------------------
// Derive number of bits needed for counter
// - This may generate one more than required number of FFs
function integer clogb2 (input [31:0] value);
reg [31:0] tmp;
begin      
  tmp = (value == 1) ? 1 : (value - 1);
  for (clogb2 = 0; tmp > 0; clogb2 = clogb2 + 1)        
    tmp = tmp >> 1;
end    
endfunction

// Number of counter bits
localparam num_hsb_event_bits = clogb2(MAX_HSB_EVENTS_PER_RESET);
localparam num_hsb_event_msb  = num_hsb_event_bits - 1;
localparam num_hsb_rst_bits   = clogb2(MAX_HSB_RST_ATTEMPT);
localparam num_hsb_rst_msb    = num_hsb_rst_bits - 1;


//------------------------------------------------------------------------------
// Local sigs
//------------------------------------------------------------------------------
reg                        bootnext_n_reg;
wire                       bootnext_n_ne;
wire                       bootnext_count_max;
reg  [num_hsb_event_msb:0] bootnext_count;
reg                        hsb_reset;
wire                       hsb_rst_count_max;
reg    [num_hsb_rst_msb:0] hsb_rst_count;
/*reg                        caterr_detect_reg;
wire                       caterr_detect_pe;
reg                        caterr_sysrst;*/
reg                        pch_pltrst_n_reg;
wire                       pch_pltrst_n_pe;
wire                       pch_pltrst_n_ne;
reg                  [3:0] delay_sr;


//------------------------------------------------------------------------------
// HSB (Hot Spare Boot) logic
// - boot_next_count is incremented for every negedge of glp_bootnext_n
// - if bootnext_count is equal to MAX_HSB_EVENTS_PER_RESET, force a sys reset
// - if hsb_rst_count is equal to MAX_HSB_RST_ATTEMPT, assert hsb_fail_n
// - hsb_en = 0 will disable HSB logic
//------------------------------------------------------------------------------
// Detect negedge of glp_bootnext_n;
always @(posedge clk or posedge reset)
begin
  if (reset)
    bootnext_n_reg <= 1'b0;
  else
    bootnext_n_reg <= glp_bootnext_n;
end

assign bootnext_n_ne = ~glp_bootnext_n & bootnext_n_reg;

// Count the number of bootnext_n negedge assertion detected. If it reaches
// MAX_HSB_EVENTS_PER_RESET, force a system reset.
assign bootnext_count_max = (bootnext_count == (MAX_HSB_EVENTS_PER_RESET - 1));

always @(posedge clk or posedge reset)
begin
  if (reset)
  begin
    bootnext_count <= {num_hsb_event_bits{1'b0}};
    hsb_reset      <= 1'b0;
  end
  else
  begin
    if (~hsb_en || ~st_steady_pwrok || ~pch_pltrst_n)
    begin
      // HSB disabled, power not up or PCH's PLTRST is asserted  - clear everything
      bootnext_count <= {num_hsb_event_bits{1'b0}};
      hsb_reset      <= 1'b0;
    end
    else if (bootnext_n_ne && bootnext_count_max)
    begin
      // Reaches max number of bootnext_n assertion - force a reset
      bootnext_count <= {num_hsb_event_bits{1'b0}};
      hsb_reset      <= 1'b1;
    end    
    else if (bootnext_n_ne)
    begin
      bootnext_count <= bootnext_count + 1'b1;
      hsb_reset      <= 1'b0;
    end
  end  
end

// Count the number of HSB forced reset. If it reaches MAX_HSB_RST_ATTEMPT,
// assert hsb_fail_n. Clear counter when power is down.
assign hsb_rst_count_max = (hsb_rst_count == (MAX_HSB_RST_ATTEMPT - 1));

always @(posedge clk or posedge reset)
begin
  if (reset)
  begin
    hsb_rst_count <= {num_hsb_rst_bits{1'b0}};
    hsb_fail_n    <= 1'b1;
  end
  else if (~hsb_en || ~st_steady_pwrok)
  begin
    hsb_rst_count <= {num_hsb_rst_bits{1'b0}};
    hsb_fail_n    <= 1'b1;
  end
  else if (bootnext_n_ne && bootnext_count_max)
  begin
    hsb_rst_count <= (hsb_rst_count_max) ? hsb_rst_count : hsb_rst_count + 1'b1;
    hsb_fail_n    <= ~hsb_rst_count_max;
  end
end


//------------------------------------------------------------------------------
// Detect posedge on caterr_detect. Set caterr_sysrst when posedge is seen and
// keep set until pltrst_n asserts.
//------------------------------------------------------------------------------
/*always @(posedge clk or posedge reset)
begin
  if (reset)
    caterr_detect_reg <= 1'b0;
  else
    caterr_detect_reg <= caterr_detect;
end

assign caterr_detect_pe = caterr_detect & ~caterr_detect_reg;

always @(posedge clk or posedge reset)
begin
  if (reset)
    caterr_sysrst <= 1'b0;
  else if (~pch_pltrst_n || ~st_steady_pwrok)
    caterr_sysrst <= 1'b0;
  else if (caterr_detect_pe)
    caterr_sysrst <= 1'b1;
end*/

  
//------------------------------------------------------------------------------
// PCH system reset
// - Asserts when:
//   - GMT_SYSRST_N asserts
//   - External reset button is pushed
//   - HSB max events reached
//   - XDP_CPU_SYSPWROK asserts
//   - CATERR/MSMI pulse or hold
// - Note that PFIS indicates not to issue reset on AER_ERR2 assertion
//------------------------------------------------------------------------------
always @(posedge clk or posedge reset)
begin
  if (reset)
    pal_sys_reset <= 1'b0;
  else if (st_steady_pwrok)
    pal_sys_reset <= ~glp_sysrst_n | ~sysrst_button_n   /*| hsb_reset  caterr_sysrst*/;
  else
    pal_sys_reset <= 1'b0;
end

assign pal_sys_reset_n = (pal_sys_reset) ? 1'b0 : 1'bz;

//------------------------------------------------------------------------------
// Reset delay and forcepr_mask
// - To prevent the CPU from going to FRB mode, need to ensure that PROCHOT_N
//   is never asserted 1us before and after RESET_N is asserted to CPU.
// - On PLTRST# posedge, reset is released immediately to CPU/IO.
//   forcepr_mask is delayed ~3us before de-asserting.
// - On PLTRST# negedge, reset is delayed ~3us before assertion to CPU/IO.
//   forcepr_mask is immediately asserted. On power fault or pch_cpupwrok
//   de-assertion, immediately assert reset. The pch_cpupwrok is for forced
//   shutdown condition where it de-asserts about 60ns after PLTRST# assertion.
// - Using 3us to account for turnaround time from FORCEPR to CPUx_HOT
// - On power fault while in st_steady_pwrok, immediately assert reset and
//   forcepr_mask.
//------------------------------------------------------------------------------
// Detect edges of pch_pltrst_n
always @(posedge clk or posedge reset)
begin
  if (reset)
    pch_pltrst_n_reg <= 1'b0;
  else
    pch_pltrst_n_reg <= pch_pltrst_n;
end

assign pch_pltrst_n_pe =  pch_pltrst_n & ~pch_pltrst_n_reg;
assign pch_pltrst_n_ne = ~pch_pltrst_n &  pch_pltrst_n_reg;

// Shift delay_sr on any edge of pch_pltrst_n
always @(posedge clk or posedge reset)
begin
  if (reset)
    delay_sr <= 4'b0000;
  else if (pch_pltrst_n_pe || pch_pltrst_n_ne)
    delay_sr <= 4'b01;
  else if (t1us)
    delay_sr <= {delay_sr[2:0], 1'b0};
end

// Reset qualifier
always @(posedge clk or posedge reset)
begin
  if (reset)
    pch_pltrst_n_qual <= 1'b0;
  else if (pch_pltrst_n_pe)
    pch_pltrst_n_qual <= 1'b1;
  else if (rt_critical_fail_store || (!pch_pltrst_n && (!pch_cpupwrok || (t1us && delay_sr[3]))))
    pch_pltrst_n_qual <= 1'b0;
end

// Forcepr mask
always @(posedge clk or posedge reset)
begin
  if (reset)
    forcepr_mask <= 1'b1;
  else if (pch_pltrst_n_ne || rt_critical_fail_store)
    forcepr_mask <= 1'b1;
  else if (t1us && pch_pltrst_n && delay_sr[3])
    forcepr_mask <= 1'b0;
end


//------------------------------------------------------------------------------
// PGD and reset drivers
// - Registered output
// - Must connect directly to top level ports and not used anywhere else to
//   utilize the IOB register
//------------------------------------------------------------------------------
always @(posedge clk or posedge reset)
begin
  if (reset)
  begin
    pgd_gmt      <= 1'b0;
//    rst_gmt_n    <= 1'b0;
//    gmt_lreset_n <= 1'b0;
//    rst_io_n     <= {NUM_IO{1'b0}};
  end
  else
  begin
    pgd_gmt      <= reached_sm_pre_wait_powerok;
//   rst_gmt_n    <= pch_pltrst_n_qual & rst_pcie_pch_n & (~PEAVEY_SUPPORT | ~reset_pci_io);
//   gmt_lreset_n <= pch_pltrst_n_qual & rst_pcie_pch_n & (~PEAVEY_SUPPORT | ~reset_pci_io);
//   rst_io_n     <= {NUM_IO{pch_pltrst_n_qual & rst_pcie_cpu_n & (~PEAVEY_SUPPORT | ~reset_pci_io)}};
  end
end


//------------------------------------------------------------------------------
// CPU PGD and reset drivers
// - Registered output
// - Must connect directly to top level ports and not used anywhere else to
//   utilize the IOB register
//------------------------------------------------------------------------------
/*always @(posedge clk or posedge reset)
begin
  if (reset)
  begin
    pgd_cpu   <= {NUM_CPU{1'b0}};
    rst_cpu_n <= {NUM_CPU{1'b0}};
  end
  else
  begin
    pgd_cpu   <= (~cpu_prsnt_n                           &
                  {NUM_CPU{pch_cpupwrok}}                &
                  {NUM_CPU{reached_sm_pre_wait_powerok}});

    rst_cpu_n <= (~cpu_prsnt_n & {NUM_CPU{pch_pltrst_n_qual | (PEAVEY_SUPPORT & pgood_rst_mask)}});
  end
end*/
  
endmodule
