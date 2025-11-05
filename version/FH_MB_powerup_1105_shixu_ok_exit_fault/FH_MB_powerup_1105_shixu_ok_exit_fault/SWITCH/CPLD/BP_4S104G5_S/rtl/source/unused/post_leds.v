//=================================================================================================--
// Copyright(c) 2021, CLOUDNINEINFO.CO, Ltd, All right reserved
// Filename   : AIS03MB03.v
// Project    : CLOUDNINEINFO common code
// Author     : dingxianhua
// Date       : 2020-09-24
// Email      : dingxianhua@cloudnineinfo.com
// Company    : CLOUDNINEINFO.CO., Ltd
// Description: This module implement the following LED function This is mux function which
//   controlled by mux_led and pgood signal.
//     pgood mux_led[1]/(SW8) led_n
//     0     0                FPGA version
//     0     1                ILO LEDs
//     1     0                ILO LEDs
//     1     1                PORT85/ROM debug
// History    :
//   Date      By          Revision  Change Description
//   20170718  QIURONGLIN  1.0       file created
//=================================================================================================

module post_leds
 #(parameter MULTI_PALS = 'd2,
   parameter PAL_VER_BITS =  (MULTI_PALS == 1) ? 16 : MULTI_PALS*24
  ) (
    input  wire                    sys_clk,
    input  wire                    reset_n,
    input  wire                    sys_pgood,
    input  wire                    onehz_clk,
    input  wire                    mux_led,
    input  wire                    mux_pwrseq,
    input  wire [5:0]              power_seq_sm,
    input  wire [PAL_VER_BITS-1:0] pal_ver_led,
    input  wire [7:0]              gpo_leds,
    input  wire [7:0]              gmt_leds,
    output reg  [7:0]              led_n,
	input  wire					   sw7
  );

reg       mux_led_t1;
reg       mux_led_t2;
reg [7:0] pal_version_led_n;

reg [2:0] state  /* synthesis syn_encoding="grey" */;

localparam [2:0] IDLE         = 3'b000;
localparam [2:0] PRI_PAL_VER1 = 3'b001;
localparam [2:0] PRI_PAL_VER2 = 3'b011;
localparam [2:0] TURN_AROUND  = 3'b111;
localparam [2:0] SEC_PAL_VER1 = 3'b110;
localparam [2:0] SEC_PAL_VER2 = 3'b100;

always @(posedge sys_clk or negedge reset_n)
begin
  if (!reset_n)
  begin
    state <= IDLE;
    pal_version_led_n <= 8'hff;
  end
  else if (onehz_clk)
  begin
    case(state)
      IDLE: begin
        state <= PRI_PAL_VER1;
        pal_version_led_n <= pal_ver_led[7:0];
      end
      PRI_PAL_VER1: begin
        state <= PRI_PAL_VER2;
        pal_version_led_n <= pal_ver_led[15:8];
      end
      PRI_PAL_VER2: begin
        state <= TURN_AROUND;
        pal_version_led_n <= pal_ver_led[23:16];
      end
      TURN_AROUND: begin
        state <= SEC_PAL_VER1;
        pal_version_led_n <= pal_ver_led[31:24];
      end
      SEC_PAL_VER1: begin
        state <= SEC_PAL_VER2;
        pal_version_led_n <= pal_ver_led[39:32];
      end
      SEC_PAL_VER2: begin
        state <= IDLE;
        pal_version_led_n <= pal_ver_led[47:40];
      end
      default: begin
        state <= IDLE;
        pal_version_led_n <= 8'hff;
      end
    endcase
  end
end

// FIXME this is probably not necessary anymore, I think mux_led comes
// from a clocked scan chain instead of straight from a mechanical switch
always @(posedge sys_clk or negedge reset_n)
begin
  if (!reset_n) // If aux power not good, set defaults
  begin
    mux_led_t1 <= 1'b0;
    mux_led_t2 <= 1'b0;
  end
  else
  begin
    mux_led_t1 <= mux_led;
    mux_led_t2 <= mux_led_t1;
  end
end

// FIXME the DLish code seems to blink these at t15p2us, ML/BL does not
always @(posedge sys_clk or negedge reset_n)
  begin
    if (!reset_n)
      led_n <= 8'hff;
    else if(sw7)
	  led_n <= 8'h7F;
	else if (mux_pwrseq)
      led_n <= ~{2'b00, power_seq_sm};
    else
      case({sys_pgood, mux_led_t2})
        2'b11  : led_n <= ~gpo_leds;
        2'b10  : led_n <= ~gmt_leds;
        2'b01  : led_n <= ~gmt_leds;
        2'b00  : led_n <= ~pal_version_led_n;
        default: led_n <= ~gmt_leds;
      endcase
  end

endmodule
