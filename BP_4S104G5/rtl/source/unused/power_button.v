//=================================================================================================--
// Copyright(c) 2021, CLOUDNINEINFO.CO, Ltd, All right reserved
// Filename   : AIS03MB03.v
// Project    : CLOUDNINEINFO common code
// Author     : dingxianhua
// Date       : 2020-09-24
// Email      : dingxianhua@cloudnineinfo.com
// Company    : CLOUDNINEINFO.CO., Ltd
// Description: This module generates the proper logic for driving the PCH's power button and
//   THERMTRIP input. It takes various stimulus from the system generates the proper response.                                                      *
// History    :
//   Date      By          Revision  Change Description
//=================================================================================================

module power_button #(parameter BL_MODE = 1'b0) ( // Enable BL support
  input       clk,                          // main clock (100MHz)
  input       reset,                        // reset
  input       t1s,                          // 10ns pulse every 1s
  input       gpo_pwr_btn_mask,             // GPO power button mask control

  input       defeat_pwr_btn_dis_n,         // from maintenance switch (active low)

  // External events - these should be debounced already

  input       st_off_standby,//w17260 1209
  input       sys_sw_in_n,                  // system's power button switch
  input       i_p0_slp_s5_n,
  input       gmt_shutdown,                 // GLP SHUTDOWN pin
  input       bmc_shutdown,                 //c00268 rdc:3704704
  input       gmt_wakeup_n,                 // GLP WAKEUP# pin
  input       i_cpu_thermtrip,              // CPU thermtrip event
  input       temp_deadly,                  // system temperature deadly event
  input       interlock_broken,             // interlock broken status
  input 	  i_sbtn_pwron_evt_clr,
  input 	  i_lbtn_pwrdown_evt_clr,
  output 	  o_sbtn_pwron_evt,
  output      o_lbtn_pwrdown_evt,


  input       st_steady_pwrok,              // Power sequencer in SM_STEADY_PWROK state
  input 	  st_halt_power_cycle,
  output reg  o_cpu_pwrbtn,                 // AMD CPU PWR_BTN_L
  output reg  o_cpu_thermtrip               // PCH THERMTRIP# pin
);


//------------------------------------------------------------------------------
// Local sigs
//------------------------------------------------------------------------------
wire       pwr_btn_allow;
reg  [2:0] force_off_count;
reg        force_off;
reg  [1:0] shutdown_events;
wire       shutdown_events_pe;

reg 		force_shutdown;  //if gmt_shutdown asserted, assert force_shutdown 8s to force shutdown the M/B
wire		gmt_shutdown_reg;
wire		gmt_shutdown_reg_delay;

reg  [3:0]  force_down_count;  //if gmt_wakeup_n asserted during force_shutdown, trig power button to power on the M/B 2S after force_shutdown finished
reg			wakeup_check;
reg			wakeup_clear;
reg			wakeup_delay;

wire sbtn_pwron_evt_in;
wire lbtn_pwrdown_evt_in;
reg  reg_sbtn_pwron_evt;
reg  reg_lbtn_pwrdown_evt;

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


//S5 pwr_btn_allow = 1;
//S0 pwr_btn_allow = 0;
//
assign pwr_btn_allow = (~(st_steady_pwrok & gpo_pwr_btn_mask & defeat_pwr_btn_dis_n));//& ~st_halt_power_cycle;


assign sbtn_pwron_evt_in	= ~sys_sw_in_n & pwr_btn_allow & ~force_off;
assign lbtn_pwrdown_evt_in  = force_off	& ~i_p0_slp_s5_n;

assign o_sbtn_pwron_evt = reg_sbtn_pwron_evt;
assign o_lbtn_pwrdown_evt = reg_lbtn_pwrdown_evt;

always @(posedge clk or posedge reset)
begin
  if (reset)
    o_cpu_pwrbtn <= 1'b0;
  else if (interlock_broken)
    o_cpu_pwrbtn <= 1'b0;
  else
    o_cpu_pwrbtn <= (~gmt_wakeup_n & st_off_standby) | force_off |
                  (~force_off & ~sys_sw_in_n & pwr_btn_allow) | force_shutdown | wakeup_delay |bmc_shutdown; //c00268 rdc:3704704
end



always  @(posedge clk or posedge reset)
begin 
if (reset)
    reg_sbtn_pwron_evt <= 1'b0;
  else if (sbtn_pwron_evt_in)
    reg_sbtn_pwron_evt <= 1'b1;
  else if (~i_sbtn_pwron_evt_clr)
    reg_sbtn_pwron_evt <= 1'b0;
end


always  @(posedge clk or posedge reset)
begin 
if (reset)
    reg_lbtn_pwrdown_evt <= 1'b0;
  else if (lbtn_pwrdown_evt_in)
    reg_lbtn_pwrdown_evt <= 1'b1;
  else if (~i_lbtn_pwrdown_evt_clr)
    reg_lbtn_pwrdown_evt <= 1'b0;
end


assign gmt_shutdown_reg = gmt_shutdown & st_steady_pwrok;
always @(posedge clk or posedge reset)
begin
  if (reset)
    force_shutdown <= 1'b0;
  else
    force_shutdown <= gmt_shutdown_reg_delay;
end


  edge_delay #(.CNTR_NBITS(3), .DELAY_MODE(1'b1)) edge_delay_inst1(
    .clk         (clk),
    .reset       (reset),
    .cnt_size    (3'b0), //计数1s延时
    .cnt_step    (t1s),
    .signal_in   (gmt_shutdown_reg),
    .delay_output(gmt_shutdown_reg_delay)
  );


  always @(posedge clk or posedge reset)
  begin
    if (reset) begin
      wakeup_check <= 1'b0;
	  end
    else if (wakeup_clear) begin
      wakeup_check <= 1'b0;
	  end
    else if (gmt_shutdown_reg_delay && !gmt_wakeup_n) begin
      wakeup_check <= 1'b1;
	  end
    else begin
      wakeup_check <= wakeup_check;
	  end
  end
  
  
  always @(posedge clk or posedge reset)
  begin
    if (reset) begin
      force_down_count <= 4'hF;
	  end
	else if (gmt_shutdown_reg) begin
	  force_down_count<= 4'h0;
	  end
	else if (t1s) begin
	  force_down_count <= (force_down_count >= 4'hF) ? 4'hF : (force_down_count + 1'b1);
	end
  end	  
  
 
  always @(posedge clk or posedge reset)
  begin
    if (reset) begin
      wakeup_delay <= 1'b0;
	  end
	else if (force_down_count == 4'hA) begin   
	  wakeup_delay <= wakeup_check ? 1'b1 : 1'b0;    ///数到10，看wakeup_check是否是1
	  end
	else begin
	  wakeup_delay <= 1'b0;
	end
  end
  
always @(posedge clk or posedge reset)
begin
  if (reset)
    wakeup_clear <= 1'b0;
  else
    wakeup_clear <= (force_down_count == 4'hF);
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
    force_off_count <= 3'b000;
    force_off       <= 1'b0;
  end
  else if (sys_sw_in_n)
  begin
    force_off_count <= 3'b00;
    force_off       <= 1'b0;
  end
  else if (t1s && (force_off_count == 3'b000))//1s
  begin
    force_off       <= 1'b1;
  end
  else if (t1s && !sys_sw_in_n && gpo_pwr_btn_mask)
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
/*    shutdown_events <= {shutdown_events[0], (i_cpu_thermtrip |
                                             pch_thermtrip |
                                             temp_deadly  |
                                             gmt_shutdown |
                                             force_off)}; */
	shutdown_events <= {shutdown_events[0], (i_cpu_thermtrip |
                                            // pch_thermtrip |
                                             temp_deadly)};
end

assign shutdown_events_pe = (shutdown_events == 2'b01);


always @(posedge clk or posedge reset)
begin
  if (reset)
    o_cpu_thermtrip <= 1'b0;
  else if (st_off_standby)
    o_cpu_thermtrip <= 1'b0;
  else if (shutdown_events_pe && st_steady_pwrok)
    o_cpu_thermtrip <= 1'b1;
end

endmodule

