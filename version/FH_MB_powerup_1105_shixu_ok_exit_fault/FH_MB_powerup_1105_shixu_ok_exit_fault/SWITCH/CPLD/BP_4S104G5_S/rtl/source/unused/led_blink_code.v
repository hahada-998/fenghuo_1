//=================================================================================================--
// Copyright(c) 2021, CLOUDNINEINFO.CO, Ltd, All right reserved
// Filename   : AIS03MB03.v
// Project    : CLOUDNINEINFO common code
// Author     : dingxianhua
// Date       : 2020-09-24
// Email      : dingxianhua@cloudnineinfo.com
// Company    : CLOUDNINEINFO.CO., Ltd
// Description: This module is the LED Blink_code sequence for G9 based the Power fault XREG_rev7
//   it generates a sequence on a output going off for 2 seconds and then blink the red health
//   LED sequentially at 4Hz to represent a particular failure as follows.
//   + System Board          |Class 0     |1 Blink |
//   + Processor             |Class 1     |2 Blinks|
//   + Memory                |Class 2     |3 Blinks|
//   + Memory Board          |Class 3     |3 Blinks|
//   + Riser/Mezz Assembly   |Class 4     |4 Blinks|
//   + A/BLOM Board          |Class 5     |5 Blinks|
//   + A/BROC Board          |Class 6     |6 Blinks|
//   + Optional IO PCIe Slots|Class 7     |7 Blinks|
//   + Power Backplanes      |Class 8     |8 Blinks|
//   + SAS Backplanes        |Class 9     |8 Blinks|
//   + Power Supply Faults   |Class A     |9 Blinks|
//   This macro is to determine the number of clk cycles the LED will be OFF accoding to the
//   OFF_SECS parameter and the blink rate defined in blink_clk at this moment is hardcoded due
//   to a limitation from Quartus to support real datatype in static function in this case
//   f_blink = 2.5Hz -> T_blink = 400ms
//   OFF_SECS = 1, CLK_CYCLES_OFF = 2.5Hz * 1 => 2.5 = 3 CLK CYCLES = 1.2s
// History    :
//   Date      By          Revision  Change Description
//   20170718  QIURONGLIN  1.0       file created
//=================================================================================================

`define CLK_CYCLES_OFF 1

module led_blink_code #(
parameter OFF_SECS = 1, //~secs off before start blinking
parameter MAX_NUMBER_OF_BLINKS = 9,
parameter CLASS_SIZE = 8)
(reset_n,
  sys_clk,
  blink_clk,
  class_0,
  class_1,
  class_2,
  class_3,
  class_4,
  class_5,
  class_6,
  class_7,
  class_8,
  class_9,
  class_A,
  health_led);

input reset_n;
input sys_clk;
input blink_clk;
input [CLASS_SIZE-1:0] class_0;
input [CLASS_SIZE-1:0] class_1;
input [CLASS_SIZE-1:0] class_2;
input [CLASS_SIZE-1:0] class_3;
input [CLASS_SIZE-1:0] class_4;
input [CLASS_SIZE-1:0] class_5;
input [CLASS_SIZE-1:0] class_6;
input [CLASS_SIZE-1:0] class_7;
input [CLASS_SIZE-1:0] class_8;
input [CLASS_SIZE-1:0] class_9;
input [CLASS_SIZE-1:0] class_A;
output health_led;

wire class_0_event;
wire class_1_event;
wire class_2_event;
wire class_3_event;
wire class_4_event;
wire class_5_event;
wire class_6_event;
wire class_7_event;
wire class_8_event;
wire class_9_event;
wire class_A_event;

//State definition
localparam [1:0] INIT = 2'b00;
localparam [1:0] FAULT_DETECT = 2'b01;
localparam [1:0] BLINK_SEQUENCE = 2'b10;
localparam [1:0] LED_OFF = 2'b11;

//Local parameter to get the number of bits for the blink counter
localparam BLINK_COUNTER_SIZE = clog2(MAX_NUMBER_OF_BLINKS + `CLK_CYCLES_OFF);

//internal reg for threshold according to fault class
reg [BLINK_COUNTER_SIZE-1:0] threshold;

//Blink counter for Health LED
reg [BLINK_COUNTER_SIZE-1:0] blink_counter;

//The width of this events reg should be should be a parameter
reg [10:0] events;

reg [1:0] state;
reg [1:0] next_state;

reg clear_n;
reg sm_clear_n;

//OR all bits in a failure class port
//If at least one bit on the failure class is "1" report an event

assign class_0_event = |class_0;
assign class_1_event = |class_1;
assign class_2_event = |class_2;
assign class_3_event = |class_3;
assign class_4_event = |class_4;
assign class_5_event = |class_5;
assign class_6_event = |class_6;
assign class_7_event = |class_7;
assign class_8_event = |class_8;
assign class_9_event = |class_9;
assign class_A_event = |class_A;

assign health_led = ((state == BLINK_SEQUENCE) &&
                     (blink_counter <= threshold + `CLK_CYCLES_OFF)) ?
                      ~blink_clk : 1'b1;

always @(posedge sys_clk or negedge reset_n) begin
  if(!reset_n)
    state <= INIT;
  else begin
    state <= next_state;
  end
end

always @(*) begin
  sm_clear_n = 1'b1;
  case(state)
    INIT: begin
      next_state = FAULT_DETECT;
      sm_clear_n = 1'b0;
    end

    FAULT_DETECT: begin
      next_state = (|events)? LED_OFF: FAULT_DETECT;
    end

    LED_OFF: begin
      next_state = !(blink_counter <= `CLK_CYCLES_OFF)? BLINK_SEQUENCE: LED_OFF;
    end

    BLINK_SEQUENCE: begin
      next_state = !(blink_counter <= threshold + `CLK_CYCLES_OFF)? INIT: BLINK_SEQUENCE;
    end

    default: begin
      next_state = INIT;
    end
  endcase
end

//Registered output
always @(posedge sys_clk or negedge reset_n) begin
  if (!reset_n) begin
    clear_n <= 1'b1;
  end
  else begin
    clear_n <= sm_clear_n;
  end
end

//count number of blinks
always @(posedge blink_clk or negedge clear_n) begin
  if(!clear_n)
    blink_counter <= {BLINK_COUNTER_SIZE{1'b0}};//bring blink counter to zero
  else
    blink_counter <= (state == BLINK_SEQUENCE || state == LED_OFF) ? ((blink_counter <= threshold + `CLK_CYCLES_OFF) ?
                     blink_counter + 1'b1 : blink_counter) : ({BLINK_COUNTER_SIZE{1'b0}});
end


//store all the events in the events reg on FAULT_DETECT state
always @(posedge sys_clk or negedge reset_n) begin
  if(!reset_n)
    events <= 11'd0;
  else
    events <= (state == FAULT_DETECT) ? {class_0_event, class_1_event, class_2_event, class_3_event,
                                         class_4_event, class_5_event, class_6_event, class_7_event,
                                         class_8_event, class_9_event, class_A_event} : 11'd0;
end

//determine the number of blinks according to the fault class
//using the following priority the class 9 > class 8 ... > class 0
always @(posedge sys_clk or negedge reset_n) begin
  if(!reset_n)begin
    threshold <= {BLINK_COUNTER_SIZE{1'b0}};
  end
  else begin
    casez(events)
    11'b???_????_???1: threshold <= (state == FAULT_DETECT) ? 4'd11: threshold;//class A priority 9 Blinks
    11'b???_????_??10: threshold <= (state == FAULT_DETECT) ? 4'd10: threshold;//class 9 priority 8 Blinks
    11'b???_????_?100: threshold <= (state == FAULT_DETECT) ? 4'd9 : threshold;//class 8 priority 8 Blinks
    11'b???_????_1000: threshold <= (state == FAULT_DETECT) ? 4'd8 : threshold;//class 7 priority 7 Blinks
    11'b???_???1_0000: threshold <= (state == FAULT_DETECT) ? 4'd7 : threshold;//class 6 priority 6 Blinks
    11'b???_??10_0000: threshold <= (state == FAULT_DETECT) ? 4'd6 : threshold;//class 5 priority 5 Blinks
    11'b???_?100_0000: threshold <= (state == FAULT_DETECT) ? 4'd5 : threshold;//class 4 priority 4 Blinks
    11'b???_1000_0000: threshold <= (state == FAULT_DETECT) ? 4'd4 : threshold;//class 3 priority 3 Blinks
    11'b??1_0000_0000: threshold <= (state == FAULT_DETECT) ? 4'd3 : threshold;//class 2 priority 3 Blinks
    11'b?10_0000_0000: threshold <= (state == FAULT_DETECT) ? 4'd2 : threshold;//class 1 priority 2 Blinks
    11'b100_0000_0000: threshold <= (state == FAULT_DETECT) ? 4'd1 : threshold;//class 0 priority 1 Blinks
    11'b000_0000_0000: threshold <= (state == FAULT_DETECT) ? 4'd0 : threshold;//No faults
    endcase
  end
end

//Ceiling Log2 Function to get the number of bits
//for a particular bus/reg size;
function integer clog2;
input [31:0] in_value;
reg [31:0] value;
begin
  value = in_value ? in_value : 1;
  for (clog2 = 0; value > 0; clog2 = clog2 + 1)
    value = value >> 1;
end
endfunction

endmodule
