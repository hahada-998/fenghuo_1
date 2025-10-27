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
//=================================================================================================

module fan_pwm
  #(parameter TOTAL_BITS    =  8,
    parameter POL           =  1'b1)
(
    input                           pwm_clk,        // pwm input clk, 6MHz typical
    input                           reset_n,        // auxpwrgood
    input                           enable,         // enable signal
    input [(TOTAL_BITS-1):0]        duty_cycle,     // fan duty cycle
    output                          fan_pwm_out     // fan pwm out
);

reg                     fan_pwm_d;
reg                     fan_pwm_q;
reg  [(TOTAL_BITS-1):0] fan_pwm_cnt_d;  //PWM counter
reg  [(TOTAL_BITS-1):0] fan_pwm_cnt_q;

assign fan_pwm_out = fan_pwm_q;

//==============================================================================
// pwm counter logic
//==============================================================================
always @ (posedge pwm_clk or negedge reset_n)
  begin
    if (!reset_n)
    begin
		  fan_pwm_q        <= ~POL;
        fan_pwm_cnt_q    <= {TOTAL_BITS{1'b0}};
    end
    else
      begin
        fan_pwm_q <= fan_pwm_d;
		  if(enable == 1'b1)
		  begin
		    fan_pwm_cnt_q <= fan_pwm_cnt_d;
		  end
		  else
		  begin
		  fan_pwm_cnt_q <= fan_pwm_cnt_q;
		  end
		end
	end

always @*
begin
     fan_pwm_cnt_d = fan_pwm_cnt_q + 1'b1;
	  fan_pwm_d     = (fan_pwm_cnt_q < duty_cycle) ? ~POL : POL;
end

endmodule
