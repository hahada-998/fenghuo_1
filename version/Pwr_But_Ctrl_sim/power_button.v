//=================================================================================================
// Copyright(c) 2017, New H3C Technologies Co., Ltd, All right reserved
// Filename   : power_button.v
// Project    : H3C common code
// Author     : QIURONGLIN
// Date       : 2017-07-18
// Email      : qiu.ronglin@h3c.com
// Company    : New H3C Technologies Co., Ltd
// Description: This module generates the proper logic for driving the PCH's power button and
//   THERMTRIP input. It takes various stimulus from the system generates the proper response.                                                      *
// History    :
//   Date      By          Revision  Change Description
//   20170718  QIURONGLIN  1.0       file created
//=================================================================================================

module power_button #(parameter BL_MODE = 1'b0) ( // Enable BL support
  input       clk,                          // main clock (100MHz)
  input       reset,                        // reset
  input       t1s,                          // 10ns pulse every 1s
  input       gpo_pwr_btn_mask,             // GPO power button mask control
  input       xreg_pwr_btn_passthru,        // Xreg power button passthru
  input       xreg_vir_pwr_btn,             // Xreg virtual power button
  input       defeat_pwr_btn_dis_n,         // from maintenance switch (active low)
  input       turn_on_override,             // asserts to 1 when SW1&3 are set to ON
  input       sys_sw_in_n,                  // system's power button switch
  input       gmt_shutdown,                 // GLP SHUTDOWN pin
  input       gmt_wakeup_n,                 // GLP WAKEUP# pin
  input       cpu_thermtrip,                // CPU thermtrip event
//YHY  input       pch_thermtrip,                // PCH thermtrip event
 input       temp_deadly,                  // system temperature deadly event
  input       interlock_broken,             // interlock broken status
//YHY  input       pch_slp4_n,                   // PCH system sleep state
  input       st_steady_pwrok  ,             // Power sequencer in SM_STEADY_PWROK state
  input       st_off_standby , 
  output reg  pch_pwrbtn,                   // PCH PWRBTN# pin
  output reg  pch_thrmtrip                  // PCH THERMTRIP# pin
);


wire       pwr_btn_allow;
reg  [1:0] force_off_count;
reg        force_off;
reg  [1:0] shutdown_events;
wire       shutdown_events_pe;

//------------------------------------------------------------------------------
// power button logic
// - The following are power button events that drives PCH PWRBTN# pin:
//   - GLP WAKEUP#
//   - Physical power button press
//   - Xreg VIR_PWR_BTN (0x0C, bit[2]) - BL-only
//
// Power button is allowed on the following:
//   - In S0 and (gpo_pwr_btn_mask = 0 or defeat_pwr_btn_dis_n = 0). This has
//     priority so if gpo_pwr_btn_mask is 1 (in S0 and defeat_pwr_btn_dis_n = 1),
//     the button is masked out.
//   - BL_MODE and xreg_pwr_btn_passthru = 1
//   - BL_MODE and turn_on_override = 1
//------------------------------------------------------------------------------
   assign pwr_btn_allow = ~(st_steady_pwrok & gpo_pwr_btn_mask & defeat_pwr_btn_dis_n);//defeat_pwr_btn_dis_nĬ��0������pwr_btn_allow��Զ����1
  
   always @(posedge clk or posedge reset)
   begin
     if (reset)
       pch_pwrbtn <= 1'b0;
     else if (interlock_broken)
       pch_pwrbtn <= 1'b0;
     else
       pch_pwrbtn <= ~gmt_wakeup_n |
                     (~force_off & ~sys_sw_in_n & pwr_btn_allow);//defeat_pwr_btn_dis_nĬ��0������pwr_btn_allow��Զ����1
   end


//------------------------------------------------------------------------------
// force_off logic (emergency power down)
// - Asserts when gpo_pwr_btn_mask is set and power button is held at least 4s.
// - This is one of the shutdown events
//------------------------------------------------------------------------------
always @(posedge clk or posedge reset)
begin
  if (reset)
  begin
    force_off_count <= 2'b00;
    force_off       <= 1'b0;
  end
  else if (sys_sw_in_n)
  begin
    force_off_count <= 2'b00;
    force_off       <= 1'b0;
  end
  else if (t1s && (force_off_count == 2'b11))
  begin
    force_off       <= 1'b1;
  end
//YHY  else if (t1s && !sys_sw_in_n && gpo_pwr_btn_mask)
    else if (t1s && !sys_sw_in_n )

  begin
    force_off_count <= force_off_count + 1'b1;
  end
end

//------------------------------------------------------------------------------
// PCH THERMTRIP# driver
// - The following events causes an immediate shutdown by asserting THERMTRIP#:
//   - CPU thermtrip
//   - PCH thermtrip
//   - system temp deadly event
//   - GMT SHUTDOWN
//   - force_off assertion (emergency power down when power button is masked)
//------------------------------------------------------------------------------
// Detect posedge on shutdown_events
always @(posedge clk or posedge reset)
begin
  if (reset)
    shutdown_events <= 2'b00;
  else
//YHY    shutdown_events <= {shutdown_events[0], (cpu_thermtrip |
//YHY                                             pch_thermtrip |
//YHY                                             temp_deadly  |
//YHY                                             gmt_shutdown |
//YHY                                             force_off)};
    shutdown_events <= {shutdown_events[0], (gmt_shutdown |   
                                             force_off)};                                             
end

assign shutdown_events_pe = (shutdown_events == 2'b01);

   // Assert PCH_THRMTRIP# on shutdown_events_pe and keep asserting until
   // pch_slp4_n asserts.
   always @(posedge clk or posedge reset)
   begin
     if (reset)
       pch_thrmtrip <= 1'b0;
//YHY     else if (!pch_slp4_n)
      else if (st_off_standby)
       pch_thrmtrip <= 1'b0;
     else if (shutdown_events_pe && st_steady_pwrok)
       pch_thrmtrip <= 1'b1;
   end

endmodule















