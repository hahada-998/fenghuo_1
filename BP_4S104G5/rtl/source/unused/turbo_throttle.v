//=================================================================================================--
// Copyright(c) 2021, CLOUDNINEINFO.CO, Ltd, All right reserved
// Filename   : AIS03MB03.v
// Project    : CLOUDNINEINFO common code
// Author     : dingxianhua
// Date       : 2020-09-24
// Email      : dingxianhua@cloudnineinfo.com
// Company    : CLOUDNINEINFO.CO., Ltd
// Description: This module handles turbo throttle logic.
// History    :
//   Date      By          Revision  Change Description
//=================================================================================================

module turbo_throttle(
   input clk_100m,
   input t2ms_tick,
   input reset,
   input smb_alert_n,
   input ps_intr_n,
   input smb_alert_throttle_en,
   input ps_intr_throttle_en,
   input throttle_type_select,

   output throttle
);

`define IDLE              2'd0
`define THROTTLE          2'd1
`define STOP_THROTTLE     2'd2
//`define RESTART_THROTTLE  3'd4

// Throttling Code
reg [4:0] thr_count;
reg [1:0] thr_state;
reg psu_throttle;
wire throttle_event;

assign throttle = throttle_type_select ?  psu_throttle : (!smb_alert_n && smb_alert_throttle_en) || (!ps_intr_n && ps_intr_throttle_en);

assign throttle_event = (!smb_alert_n && smb_alert_throttle_en) || (!ps_intr_n && ps_intr_throttle_en);

always @(posedge clk_100m or posedge reset)
begin
   if(reset)
   begin
   psu_throttle <= 1'b0;
   thr_count    <= 5'd0;
   thr_state    <= `IDLE;
   end
   else //if (t2ms_tick)
      begin
      case(thr_state)
            `IDLE:
               begin
               if(throttle_event)
                  begin
                  thr_state <= `THROTTLE;
                  thr_count <= 5'd0;
                  psu_throttle <= 1'b1;
                  end
               end
            `THROTTLE:
               begin
               if(thr_count > 5'd24)
                  begin
                  thr_state <= `STOP_THROTTLE;
                  thr_count <= 5'd0;
                  psu_throttle <= 1'b0;
                  end
               else if (t2ms_tick)
                  begin
                  thr_state <= `THROTTLE;
                  thr_count <= thr_count + 5'd1;
                  psu_throttle <= 1'b1;
                  end
               end
            `STOP_THROTTLE:
               begin
                  if(thr_count > 5'd24)
                  begin
                  thr_state <= `IDLE;
                  thr_count <= 5'd0;
                  psu_throttle <= 1'b0;
                  end
               else if (t2ms_tick)
                  begin
                  thr_state <= `STOP_THROTTLE;
                  thr_count <= thr_count + 5'd1;
                  psu_throttle <= 1'b0;
                  end
               end
            default:
            begin
                  thr_state <= `IDLE;
                  thr_count <= 5'd0;
                  psu_throttle <= 1'b0;
            end
            endcase
      end

end

endmodule

