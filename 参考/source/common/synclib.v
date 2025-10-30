//=================================================================================================--
// Copyright(c) 2021, CLOUDNINEINFO.CO, Ltd, All right reserved
// Filename   : AIS03MB03.v
// Project    : CLOUDNINEINFO common code
// Author     : liuqi
// Date       : 2020-09-24
// Email      : liuqic@cloudnineinfo.com
// Company    : CLOUDNINEINFO.CO., Ltd
// Description: Library of synchronizing cells to fix common metastability issues
//   SYNCLIB CELL'S INTERFACE
//            Module Name        Clock      Reset             Input(s)   Output(s)
//     module SYNC_RESET_N_AASD (input clk, input aaad_rst_n,            output reg aasd_rst_n);
//     module SYNC_RESET_AASD   (input clk, input aaad_rst,              output reg aasd_rst);
//     module SYNC_RESET_SASD   (input clk, input aaad_rst,              output reg sasd_rst);
//     module STABLE            (input clk, input aaad_sig,              output reg sasd_sig);
//     module SYNC_DATA_N       (input clk, input rst_n,      input din, output reg dout);
//     module SYNC_DATA         (input clk, input rst,        input din, output reg dout);
//     module BREAK_COMBI_N     (input clk, input rst_n,      input din, output reg dout);
//     module BREAK_COMBI       (input clk, input rst,        input din, output reg dout);
//     module ISOLATE_COMBI     (input clk,                   input din, output reg dout);
//     module PGM_DEBOUNCE_N #(parameter SIGCNT=1, NBITS=2, NDELAY=(2**2), ENABLE=1'b1)
//                              (input clk, input rst_n, input [SIGCNT-1:0]din,
//                               input timer_tick, output [SIGCNT-1:0]dout);
//     module PGM_DEBOUNCE #(parameter SIGCNT=1, NBITS=2, NDELAY=(2**2), ENABLE=1'b1)
//                              (input clk, input rst, input [SIGCNT-1:0]din,
//                               input timer_tick, output [SIGCNT-1:0]dout);
//            NOTE: In addition to rst input signal polarity, PGM_DEBOUNCE_N output signal starts low
//                  while PGM_DEBOUNCE starts high. If the un-debounced signal starts low initially
//                  such as PGD, use PGM_DEBOUNCE_N. For signal that starts high like power buttons,
//                  use PGM_DEBOUNCE. Both version will eventually follow their un-debounced signal
//                  after the specified filter width but using an incorrect module may result in
//                  un-intended signal assertion on reset release which can cause unexpected behavior
//                  in downstream logic.
//     module PGM_DEBOUNCE_GPO_N #(parameter SIGCNT=5, NBITS=3, DEFAULT_OUT=5'b00000)
//               (clk, rst_n, din, ndelay0, ndelay1, ndelay2, ndelay3, select_delay, timer_tick, disable_db, dout);
// History    :
//   Date      By          Revision  Change Description
//=================================================================================================

// *****************************************************************************
// * R E S E T    S Y N C H R O N I Z E R S
// *****************************************************************************

// ---------------------------------------------------------------------------
// SYNC_RESET_N_AASD - AASD Reset Synchronizer / aaad --> aasd / Active-Low Reset
//   NOTE: Waive RTL violation on ff_s1 to have constant driver
// ---------------------------------------------------------------------------

module SYNC_RESET_N_AASD (input clk, input aaad_rst_n, output reg aasd_rst_n);
reg ff_s1;  // lint_checking FFCSTD off

always @(posedge clk or negedge aaad_rst_n) begin
  if (! aaad_rst_n) begin
    ff_s1     <= 1'b0;
    aasd_rst_n <= 1'b0;
  end
  else begin
    ff_s1     <= 1'b1;
    aasd_rst_n <= ff_s1;
  end
end
endmodule

// ---------------------------------------------------------------------------
// SYNC_RESET_AASD - AASD Reset Synchronizer / aaad --> aasd / Active-High Reset
//              NOTE: Waive RTL violation on ff_s1 to have constant driver
// ---------------------------------------------------------------------------

module SYNC_RESET_AASD (input clk, input aaad_rst, output reg aasd_rst);
reg ff_s1;  // lint_checking FFCSTD off

always @(posedge clk or posedge aaad_rst) begin
  if (aaad_rst) begin
    ff_s1     <= 1'b1;
    aasd_rst <= 1'b1;
  end
  else begin
    ff_s1     <= 1'b0;
    aasd_rst <= ff_s1;
  end
end
endmodule

// ---------------------------------------------------------------------------
// SYNC_RESET_SASD - SASD Reset Synchronizer / aaad --> sasd
//              NOTE: Waive RTL violation on ff_s1 and sasd_rst having no reset control
// ---------------------------------------------------------------------------

module SYNC_RESET_SASD (input clk, input aaad_rst, output reg sasd_rst);
reg ff_s1;  // lint_checking FFWNSR RSTDAT off
  always @(posedge clk) begin
    ff_s1     <= aaad_rst;
    sasd_rst     <= ff_s1;
  end
endmodule

// *****************************************************************************
// * D A T A    S Y N C H R O N I Z E R S
// *****************************************************************************

// ---------------------------------------------------------------------------
// SYNC_DATA_N - Data Synchronizer / 2FFs / Active-Low Reset
// ---------------------------------------------------------------------------

module SYNC_DATA_N #(parameter SIGCNT = 1) (
  input                   clk,
  input                   rst_n,
  input      [SIGCNT-1:0] din,
  output reg [SIGCNT-1:0] dout
);
reg [SIGCNT-1:0] ff_s1;

always @(posedge clk or negedge rst_n) begin
  if (! rst_n) begin
    dout     <= {SIGCNT{1'b0}};
    ff_s1    <= {SIGCNT{1'b0}};
  end
  else begin
    ff_s1     <= din;
    dout     <= ff_s1;
  end
end
endmodule

// ---------------------------------------------------------------------------
// SYNC_DATA - Data Synchronizer / 2FFs / Active-High Reset
// ---------------------------------------------------------------------------

module SYNC_DATA #(parameter SIGCNT = 1) (
  input                   clk,
  input                   rst,
  input      [SIGCNT-1:0] din,
  output reg [SIGCNT-1:0] dout
);
reg [SIGCNT-1:0] ff_s1;

always @(posedge clk or posedge rst) begin
  if (rst) begin
    dout     <= {SIGCNT{1'b1}};
    ff_s1    <= {SIGCNT{1'b1}};
  end
  else begin
    ff_s1     <= din;
    dout     <= ff_s1;
  end
end
endmodule

// ------------------------------------------------------------------------------------------
//  STABLE - Circuit to filter both assert-type and de-assert type glitches of a given signal
//           Note: Waive RTL violations of - missing reset, on flops - sasd_sig, ff_s1, ff_s2
// ------------------------------------------------------------------------------------------

module STABLE (input clk, input aaad_sig, output reg sasd_sig);
reg ff_s1, ff_s2;  // lint_checking FFWASR FFWNSR MRSTDT off

always @ (posedge clk ) begin   // Synchronize incoming signal
    ff_s1 <= aaad_sig;
    ff_s2 <= ff_s1;
end

always @ (posedge clk) begin    // Circuit to filter both signal assert and de-assert glitches
  if(aaad_sig && ff_s1 && ff_s2)
    sasd_sig <= 1;
  else if(!aaad_sig && !ff_s1 && !ff_s2)
    sasd_sig <= 0;
  else
    sasd_sig <= sasd_sig;
end

endmodule

// *****************************************************************************
// * BREAK COMBINATIONAL LOOPS
// *****************************************************************************

// ---------------------------------------------------------------------------
// BREAK_COMBI_N - Break a combinational loop using 1FF / Active-Low Reset Version
// ---------------------------------------------------------------------------

module BREAK_COMBI_N (input clk, input rst_n, input din, output reg dout);

always @(posedge clk or negedge rst_n) begin
  if (! rst_n) begin
    dout     <= 1'b0;
  end
  else begin
    dout     <= din;
  end
end
endmodule

// ---------------------------------------------------------------------------
// BREAK_COMBI - Break a combinational loop using 1FF / Active-High Reset Version
// ---------------------------------------------------------------------------

module BREAK_COMBI (input clk, input rst, input din, output reg dout);

always @(posedge clk or posedge rst) begin
  if (rst) begin
    dout     <= 1'b1;
  end
  else begin
    dout     <= din;
  end
end

endmodule


// ---------------------------------------------------------------------------
// ISOLATE_COMBI - Isolate combinational logic on reset
//                 Note: Waive RTL violations on flops ff_s1 and dout, with no reset
// ---------------------------------------------------------------------------

module ISOLATE_COMBI (input clk, input din, output reg dout);
reg ff_s1;  // lint_checking FFWNSR off
  always @(posedge clk) begin
    ff_s1     <= din;
    dout     <= ff_s1;
  end
endmodule

// *****************************************************************************
// * Module Name:  PGM_DEBOUNCE_N                                                *
// * Description:  Programmable Debounce Module                                *
// *****************************************************************************
// Parameterization
//    Debounce mechanism is programmed with the use of the following parameters - 
//             Default
//  Parameter  Value    Description
//  -----------------------------------------------------------------------------------
//  SIGCNT   5  (Scalar-equivalent) Number of input signals to be debounced
//  NBITS    3
//  NDELAY    2**NBITS Filter width in number of clock cycles.  Note that two
//        additional clock periods will be added to this filter-width
//        due to the reset-synchronizer preceding the delay counter.
//  ENABLE    1  Enable or disable glitch filtering
//  -----------------------------------------------------------------------------------
//
//    Usage Recommendations:
//
//  1. For reset-root signals within the same clock-domain or across clock-domains,
//     use the standard reset-synchronizer as per the HP document on - Metastability Fix
//     Structures. This will insure synchronous-de-assert on reset signals with optimal use
//     of two registers.
//
//  2. For push-button or slide buttons, or hotplug signals, use this programmable debounce
//     scheme with NBITS and or NDELAY paremeter values specified, to match with the desired
//     (worst-case) filter-width in terms of number of input clock periods.
//
//      When say, a minimum of N cycles of filtering is needed, then set NDELAY to (N-2) and
//  NBITS derived as a "minimal value of NBITS" where, 2**NBITS >= NDELAY
//
//  Example Usage:
//
//      - Push-button/Slide-button/Hotplug Signals
//    PGM_DEBOUNCE_N #(.SIGCNT(3),.NBITS(2),.NDELAY(),.ENABLE()) db1 (.clk(clk), .rst_n(rst_n),
//      .din({UID_SW_IN_R_N,SYS_SW_IN_R_N}), .timer_tick(timer_tick), .dout({UID_SW_IN_R_N_db,SYS_SW_IN_R_N_db}));
//
//      - Minimum filter width of say, 12 clock periods -
//    `define  NBITS   4
//    `define  NDELAY  10    // Filter Width = 10+2 = 12 clock cycles
//    PGM_DEBOUNCE_N #(.SIGCNT(),.NBITS(`NBITS),.NDELAY(`NDELAY),.ENABLE()) db1 (clk, rst_n, din, timer_tick, dout);
//
//  -----------------------------------------------------------------------------------

module PGM_DEBOUNCE_N #(parameter SIGCNT=3'b101, NBITS=2'b11, NDELAY=(2**NBITS), ENABLE=1'b1) (clk, rst_n, din, timer_tick, dout);
input  clk, rst_n, timer_tick;
input  [SIGCNT-1:0] din;
output [SIGCNT-1:0] dout;

reg    [(NBITS?NBITS-1:0):0] cnt[SIGCNT-1:0];   // lint_checking MEMSIZ off
reg    [SIGCNT-1:0] nxt_s1, nxt, out_i;
wire   equal[SIGCNT-1:0];

assign dout = ENABLE ? out_i : din;

generate
  genvar i;
  for (i=0; i < SIGCNT; i=i+1)
  begin: mInst
      assign equal[i] = (&{din[i],nxt_s1[i],nxt[i]}) || (!(|{din[i],nxt_s1[i],nxt[i]}));
    always @(posedge clk or negedge rst_n) begin
      if (! rst_n) begin
        nxt_s1[i] <= 1'b0;
        nxt[i] <= 1'b0;
        out_i[i] <= 1'b0;
        cnt[i] <= {(NBITS?NBITS:1){1'b0}};
      end
      else begin
        nxt_s1[i] <= din[i];
        nxt[i] <= nxt_s1[i];
        if (! equal[i])
          cnt[i] <= {(NBITS?NBITS:1){1'b0}};
        else if (cnt[i] == (NDELAY-1'b1))
          out_i[i] <= timer_tick ? nxt[i] : out_i[i];
        else
          cnt[i] <= timer_tick ? cnt[i] + 1'b1 : cnt[i];
      end
    end
  end
endgenerate
endmodule

// *****************************************************************************
// * Module Name:  PGM_DEBOUNCE                                                *
// * Description:  Programmable Debounce Module                                *
// *****************************************************************************
//
// Parameterization
//
//    Debounce mechanism is programmed with the use of the following parameters -
//
//             Default
//   Parameter  Value    Description
//   -----------------------------------------------------------------------------------
//   SIGCNT          5    (Scalar-equivalent) Number of input signals to be debounced
//   NBITS           3
//   NDELAY          2**NBITS Filter width in number of clock cycles.  Note that two
//                   additional clock periods will be added to this filter-width
//                   due to the reset-synchronizer preceding the delay counter.
//   ENABLE          1    Enable or disable glitch filtering
//   -----------------------------------------------------------------------------------
//
//    Usage Recommendations:
//
//   1. For reset-root signals within the same clock-domain or across clock-domains,
//      use the standard reset-synchronizer as per the HP document on - Metastability Fix
//      Structures. This will insure synchronous-de-assert on reset signals with optimal use
//      of two registers.
//
//   2. For push-button or slide buttons, or hotplug signals, use this programmable debounce
//      scheme with NBITS and or NDELAY parameter values specified, to match with the desired
//      (worst-case) filter-width in terms of number of input clock periods.
//
//      When say, a minimum of N cycles of filtering is needed, then set NDELAY to (N-2) and
//   NBITS derived as a "minimal value of NBITS" where, 2**NBITS >= NDELAY
//
//   Example Usage:
//
//       - Push-button/Slide-button/Hotplug Signals
//         PGM_DEBOUNCE #(.SIGCNT(3),.NBITS(2),.NDELAY(),.ENABLE()) db1 (.clk(clk), .rst(rst),
//              .din({UID_SW_IN_R_N,SYS_SW_IN_R_N}), .timer_tick(timer_tick), .dout({UID_SW_IN_R_N_db,SYS_SW_IN_R_N_db}));
//
//       - Minimum filter width of say, 12 clock periods -
//         `define    NBITS   4
//         `define    NDELAY  10      // Filter Width = 10+2 = 12 clock cycles
//         PGM_DEBOUNCE #(.SIGCNT(),.NBITS(`NBITS),.NDELAY(`NDELAY),.ENABLE()) db1 (clk, rst, din, timer_tick, dout);
//
//   -----------------------------------------------------------------------------------

module PGM_DEBOUNCE #(parameter SIGCNT=3'b101, NBITS=2'b11, NDELAY=(2**NBITS), ENABLE=1'b1) (clk, rst, din, timer_tick, dout);
input  clk, rst, timer_tick;
input  [SIGCNT-1:0] din;
output [SIGCNT-1:0] dout;

reg    [(NBITS?NBITS-1:0):0] cnt[SIGCNT-1:0];
reg    [SIGCNT-1:0] nxt_s1, nxt, out_i;
wire   equal[SIGCNT-1:0];

assign dout = ENABLE ? out_i : din;

generate
  genvar i;
  for (i=0; i < SIGCNT; i=i+1)
  begin: mInst
      assign equal[i] = (&{din[i],nxt_s1[i],nxt[i]}) || (!(|{din[i],nxt_s1[i],nxt[i]}));
    always @(posedge clk or posedge rst) begin
      if (rst) begin
        nxt_s1[i] <= 1'b1;
        nxt[i] <= 1'b1;
        out_i[i] <= 1'b1;
        cnt[i] <= {(NBITS?NBITS:1){1'b0}};
      end
      else begin
        nxt_s1[i] <= din[i];
        nxt[i] <= nxt_s1[i];
        if (! equal[i])
          cnt[i] <= {(NBITS?NBITS:1){1'b0}};
        else if (cnt[i] == (NDELAY-1'b1))
          out_i[i] <= timer_tick ? nxt[i] : out_i[i];
        else
          cnt[i] <= timer_tick ? cnt[i] + 1'b1 : cnt[i];
      end
    end
  end
endgenerate
endmodule

// *****************************************************************************
// * Module Name:  PGM_DEBOUNCE_GPO_N                                          *
// * Description:  Programmable Debounce Module                                *
// *        Active-Low-Reset version                                    *
// *        If using Active-High reset, invert it in port-connection    *
// *****************************************************************************
//
// Parameterization
//
//    Debounce mechanism is programmed with the use of the following parameters -
//
//             Default
//   Parameter  Value    Description
//   -----------------------------------------------------------------------------------
//   SIGCNT          5    (Scalar-equivalent) Number of input signals to be debounced
//   NBITS           3
//   DEFAULT_OUT     5'b00000 Default value at output on reset
//   -----------------------------------------------------------------------------------
//
//   Port    Description
//   -----------------------------------------------------------------------------------
//   clk  Input clock used as basis for glitch filter width in # of clock-cycles
//   rst_n  Reset signal (Active-low by default).  When using Active-High reset at
//        port level, it needs be inverted first.
//   din  One or more input signals that need debouncing
//   ndelay0  Delay value option 0 (default).
//   ndelay1  Delay value option 1
//   ndelay2  Delay value option 2
//   ndelay3  Delay value option 3
//   select_delay  Delay value selector.  Used to select ndelay#
//   timer_tick   Additional gating control if needed (Default: 1'b1)
//   disable_db  Disable debouncing.  Default: 1'b0.  If set to 1, debouncing is disabled.
//   dout  Debounced signals
//   -----------------------------------------------------------------------------------
//
//    Usage Recommendations:
//
//   1. For reset-root signals within the same clock-domain or across clock-domains,
//      use the standard reset-synchronizer as per the HP document on - Metastability Fix
//      Structures. This will insure synchronous-de-assert on reset signals with optimal use
//      of two registers.
//
//   2. For push-button or slide buttons, or hotplug signals, use this programmable debounce
//      scheme with the desired (worst-case) filter-width in terms of number of input clock
//      periods.  Specify the NBITS parameter value to represent equivalent delay that is
//      less than 2**NBITS
//
//      When say, a minimum of N cycles of filtering is needed, then set ndelay port to N and
//      derive NBITS derived as a "minimal value of NBITS" where, 2**NBITS >= ndelay
//
//      Note that .5 to 1.5 clock-cycles of additional delay will be added to the specified N
//      value due to the signal synchronizer of the debounce cell.
//
//   Example Usage:
//
//       - Push-button / Slide-button / Hotplug Signals
//
//         PGM_DEBOUNCE_GPO_N #(.SIGCNT(2'b11), .NBITS(2), .DEFAULT_OUT(2'b00))
//           db_i1 (.clk(clk), .rst_n(rst_n), .din({UID_SW_IN_R_N,SYS_SW_IN_R_N}),
//           .ndelay0(4'h8), .ndelay1(4'hA), .ndelay2(4'h3), .ndelay3(4'hf), .select_delay({~debug_sw2,~debug_sw1}),
//           .timer_tick(1'b1), .disable_db(1'b0), .dout({UID_SW_IN_R_N_db,SYS_SW_IN_R_N_db}));
//
//   -----------------------------------------------------------------------------------
//
module PGM_DEBOUNCE_GPO_N #(parameter SIGCNT=5, NBITS=3, DEFAULT_OUT=5'b00000)
               (clk, rst_n, din, ndelay0, ndelay1, ndelay2, ndelay3, select_delay, timer_tick, disable_db, dout);

input  clk, rst_n, timer_tick;
input  [1:0] select_delay;
input  [(NBITS?NBITS-1:0):0]  ndelay0, ndelay1, ndelay2, ndelay3;
input  [SIGCNT-1:0] din;
input  disable_db;
output [SIGCNT-1:0] dout;

localparam NDELAY_DEFAULT = (2**NBITS)-1;

reg    [(NBITS?NBITS-1:0):0]  ndelay;
reg    [(NBITS?NBITS-1:0):0] cnt[SIGCNT-1:0];
reg    [SIGCNT-1:0] nxt_s1, nxt, out_i;
wire   equal[SIGCNT-1:0];

assign dout = disable_db ? din : out_i ;

always @(posedge clk or negedge rst_n) begin
  if(!rst_n)  begin
    ndelay <= ! (|ndelay0) ? NDELAY_DEFAULT : ndelay0;
  end
  else  begin
    case(select_delay)
      2'b00: ndelay <= ndelay0;
      2'b01: ndelay <= ndelay1;
      2'b10: ndelay <= ndelay2;
      2'b11: ndelay <= ndelay3;
   endcase
  end
end

generate
  genvar i;
  for (i=0; i < SIGCNT; i=i+1)
  begin: mInst
    assign equal[i] = (&{din[i],nxt_s1[i],nxt[i]}) || (!(|{din[i],nxt_s1[i],nxt[i]}));
    always @(posedge clk or negedge rst_n) begin
      if (!rst_n) begin
        nxt_s1[i] <= DEFAULT_OUT[i];
        nxt[i] <= DEFAULT_OUT[i];
        out_i[i] <= DEFAULT_OUT[i];
        cnt[i] <= {(NBITS?NBITS:1){1'b0}};
      end
      else begin
        nxt_s1[i] <= din[i];
        nxt[i] <= nxt_s1[i];
        if (! equal[i])
          cnt[i] <= {(NBITS?NBITS:1){1'b0}};
        else if (cnt[i] >= (ndelay-1'b1))
          out_i[i] <= timer_tick ? nxt[i] : out_i[i];
        else
          cnt[i] <= timer_tick ? cnt[i] + 1'b1 : cnt[i];
      end
    end
  end
endgenerate
endmodule
