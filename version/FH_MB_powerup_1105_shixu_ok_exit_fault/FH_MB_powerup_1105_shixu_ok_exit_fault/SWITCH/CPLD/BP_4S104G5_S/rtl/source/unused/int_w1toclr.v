//=================================================================================================--
// Copyright(c) 2021, CLOUDNINEINFO.CO, Ltd, All right reserved
// Filename   : AIS03MB03.v
// Project    : CLOUDNINEINFO common code
// Author     : dingxianhua
// Date       : 2020-09-24
// Email      : dingxianhua@cloudnineinfo.com
// Company    : CLOUDNINEINFO.CO., Ltd
// Description: This module implements a parameterized interrupt flag that generates interrupts
//   based on digital signal events.  Detected signal events can be controlled with the MODE
//   parameter to be:
//   (1) rising edge sensitive,
//   (2) falling edge sensitive, or
//   (3) sensitive to both edges.
//   The selected edge(s) of "signal" causes the "int_latch" output to be asserted. The output
//   remains high until a '1' is written to the proper location (that location is specified by
//   "address"). The "event_counter" is advanced by one on the selected edge of "signal".
//   The "reset_event" is a pulse that will only go high when the correct address is written. If
//   the designated dataline is true when expwrite deasserts, event_counter will decrement.
//   Every design has limitations.  It is important to state the design assumptions to set
//   expectations for behavior and to prevent module from being misused.
//   Assumptions:
//     The signal that generates the interrupt event has good signal integrity and has been
//     verified to have monotonic edges. No more than 3 interrupt events will be queued before the
//     processor clears them.
//     The address, expcs_n and expwrite_n are synchronous with the incoming "clk". The dataline
//     and expwrite_n signal must meet setup to the the RISING edge of "clk".
//     Address and expcs_n must meet setup to the same "clk" edge and are multicycle paths in most
//     applications.
//     expwrite_n must be asserted FOR ONLY ONE "clk"cycle for each expansion bus write.
// History    :
//   Date      By          Revision  Change Description
//   20170718  QIURONGLIN  1.0       file created
//   20200224  WANGMENGLONG 1.1       add mask bit
//=================================================================================================

module  int_w1toclr   #( parameter [1:0] MODE = 2'b00,
                         parameter NO_QUEUING = 0,
                         parameter NUMBER_OF_MAD_ADDRESS_LINES = 8) (
                         input pgoodaux,
                         input pon_reset_sasd,
                         input clk,
                         input expcs_n,
                         input expwrite_n,
                         input mad27,
                         input [8+NUMBER_OF_MAD_ADDRESS_LINES-1:8] address,
                         input [8+NUMBER_OF_MAD_ADDRESS_LINES-1:8] ilo_lvad,
                         input dataline,
                         input signal,
						 input mask,
                         output  int_latch,
                         output reg reset_event
                        );

reg [1:0]  event_count;
reg [2:0]  reg_signal;
wire       pos_pulse_signal;
wire       neg_pulse_signal;
wire       count_up;
wire       count_down;
wire       dual_edge_detect;
wire       edge_detect;

assign    pos_pulse_signal = reg_signal[1] & ~reg_signal[2];
assign    neg_pulse_signal = ~reg_signal[1] & reg_signal[2];
assign    dual_edge_detect = pos_pulse_signal | neg_pulse_signal;

assign edge_detect = ((MODE == 2'b01) & pos_pulse_signal) |
                     ((MODE == 2'b10) & neg_pulse_signal) |
                     ((MODE == 2'b11) & dual_edge_detect);

// These signals are only 1 clock period wide (10ns pulses)
// interrupt set and interrupt clear pulses that occur simultaneously
// cancel each other out!
// Note: this code is not really necessary because it is redundant
// with the conditions imposed by the counter logic case statement.
assign count_up           = edge_detect & (~reset_event);
assign count_down         = reset_event & (~edge_detect);

// Note: reset_event is registered to improve timing
always @(posedge clk or negedge pgoodaux)
 if(!pgoodaux)
 	 begin
     reset_event <= 1'b0;
   end
 else if (pon_reset_sasd)
    reset_event <= 1'b0;
 else
 	 begin
     reset_event <= (mad27 & ~expcs_n & ~expwrite_n &
                     dataline & (ilo_lvad == address));
   end

// Interrupt events are typically not synchronized to any clock domain so
// we synchronized to 100MHz clock before doing edge detection.
// We do not asynch reset these flops so that we can observe the
// initial state of the signal just before reset deasserts.
// This prevents a false interrupt trigger by assuming the wrong
// signal polarity at startup.
always @(posedge clk) begin
    reg_signal <= {reg_signal[1:0], signal};
    end

// This block implements and up/down johnson counter.
// We increment the count on interrupt events and decrement the
// counter when the cleared by the appropriate x-bit write.
always @(posedge clk or negedge pgoodaux)
    begin
    if (!pgoodaux)
        event_count <= 2'b00;
    else if (pon_reset_sasd)
        event_count <= 2'b00;
    else
        if (NO_QUEUING == 1)
          case ({count_down, count_up})
          2'b01: event_count[0] <= 1'b1;
          2'b10: event_count[0] <= 1'b0;
          default:
              event_count <= event_count;
          endcase
        else
          // "case" logic prevents overflow if 3 events already pending
          // In these cases, interrupts will be lost
          case ({count_down, count_up, event_count})
          4'b0100: event_count <= {event_count[0],~event_count[1]};
          4'b0101: event_count <= {event_count[0],~event_count[1]};
          4'b0111: event_count <= {event_count[0],~event_count[1]};
          4'b1010: event_count <= {~event_count[0],event_count[1]};
          4'b1011: event_count <= {~event_count[0],event_count[1]};
          4'b1001: event_count <= {~event_count[0],event_count[1]};
          default:
              event_count <= event_count;
          endcase
    end

// when the counter is non-zero, there is an interrupt pending
assign int_latch = (|event_count)&(!mask);

endmodule


