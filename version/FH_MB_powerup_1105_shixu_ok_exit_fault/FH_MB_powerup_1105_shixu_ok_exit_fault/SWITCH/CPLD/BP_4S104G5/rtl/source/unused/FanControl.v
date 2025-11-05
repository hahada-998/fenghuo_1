// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
// *                   C O P Y R I G H T     N O T I C E                       *
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
// *                                                                           *
// * Inspur Company Confidential                                               *
// *                                                                           *
// * (c) Copyright 2020 - 2025 Inspur Electronic Information Industry Co.,Ltd. *
// * All rights reserved.                                                      *
// *                                                                           *
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
// * Engineer:       Abel Ge
// * Email:          gezh@inspur.com 
// * Module Name:    WDT
// * Project Name:   **
// * Description:    FanControl module
// * Instances:      Modules included in this file
// *    <1>  WDT
// * V1.1: 20210316-- ADD i_low_speed_pwr_on
// *       2021-4-5-- use TIME_OUT1 for o_wdt_override_pld_sel
// * v1.2: 2021-5-6: remove w_FullSpeed0_2 ;    assign o_wdt_override_pld_sel  = ~w_FullSpeed1        ;	
// * v1.3: 2021-5-14: add   "r_pwr_on_st_dly <= i_pwr_on_st;"

module  FanControl #(
	parameter FANNUMBER	=	8,
	parameter TIME_OUT0	=	'd15 , // Unit: second 
	parameter TIME_OUT1	=	'd15  // Unit: second 
	)
(
    input		i_clk           ,
    input		i_rst_n         ,
    input		i_1uSCE         ,
    input		i_1000mSCE      ,   	
    input		i_heartbeat     ,
    input [7:0] i_max_speed_ctrl,
    input [7:0] i_low_speed_pwr_on,
    input       i_fan_en_when_s5   ,
    input       i_bmc_ctrl_when_s5 ,
    input       i_pwr_on_st        ,
    input [7:0] i_fan_speed_when_s5,
    
    input       i_rst_bmc_n   ,

    output      o_bmc_active0_n        ,  
    output      o_bmc_active0_rst_n    ,  
    output      o_wdt_override_pld_sel ,  
    output      o_bmc_active1_n        ,  
    
    
    
    input	[FANNUMBER-1:0] i_BMC_pwm,	
    output	[FANNUMBER-1:0] o_CPLD_pwm
 
); 
	
// wire wRst;

// assign wRst = ~i_rst_n ;


wire [7:0] w_duty_dat;
 
wire        w_FullSpeed0;
wire        w_FullSpeed0_bmc_rst;
// wire        w_FullSpeed0_2;
wire        w_FullSpeed1;
// reg [7:0]   rvCounter;
 
wire       w_cpld_PWM; 
wire       w_cpld_PWM_when_s5;
wire [7:0] w_duty_dat_when_s5;
reg  [5:0] r_cpld_PWM_Counter;

 
//CPLD PWM Generate=====================================================
always@(posedge i_1uSCE or negedge i_rst_n) begin
    if(~i_rst_n) begin
        r_cpld_PWM_Counter		<= 0;
    end
    else begin
        if(r_cpld_PWM_Counter < 39)
            r_cpld_PWM_Counter	<= r_cpld_PWM_Counter + 1;
        else 
            r_cpld_PWM_Counter	<= 0;
    end
end

assign w_duty_dat = (i_max_speed_ctrl==8'd60) ?8'd23:
                    (i_max_speed_ctrl==8'd65) ?8'd25:
                    (i_max_speed_ctrl==8'd70) ?8'd27:
                    (i_max_speed_ctrl==8'd75) ?8'd29:
                    (i_max_speed_ctrl==8'd80) ?8'd31:
                    (i_max_speed_ctrl==8'd85) ?8'd33:
                    (i_max_speed_ctrl==8'd90) ?8'd35:
                    (i_max_speed_ctrl==8'd95) ?8'd37:
                    (i_max_speed_ctrl==8'd100)?8'd39:
                    8'd31;

assign w_cpld_PWM = (r_cpld_PWM_Counter <= w_duty_dat)?1'b1:1'b0;

wire [7:0] w_duty_dat_first_on;
wire w_cpld_PWM_first_on;

assign w_duty_dat_first_on= (i_low_speed_pwr_on==8'd10) ?8'd3:
                            (i_low_speed_pwr_on==8'd15) ?8'd5:
                            (i_low_speed_pwr_on==8'd20) ?8'd7:
                            (i_low_speed_pwr_on==8'd25) ?8'd9:
                            (i_low_speed_pwr_on==8'd30) ?8'd11:
                            (i_low_speed_pwr_on==8'd35) ?8'd13:
                            (i_low_speed_pwr_on==8'd40) ?8'd15:
                            (i_low_speed_pwr_on==8'd45) ?8'd17:
                            (i_low_speed_pwr_on==8'd50) ?8'd19:
                            (i_low_speed_pwr_on==8'd55) ?8'd21:
                            (i_low_speed_pwr_on==8'd60) ?8'd23:
                            8'd11;
                              
                             
assign w_cpld_PWM_first_on = (r_cpld_PWM_Counter <= w_duty_dat_first_on)?1'b1:1'b0;


assign w_duty_dat_when_s5 = (i_fan_speed_when_s5==8'd10) ?8'd3:
                            (i_fan_speed_when_s5==8'd15) ?8'd5:
                            (i_fan_speed_when_s5==8'd20) ?8'd7:
                            (i_fan_speed_when_s5==8'd25) ?8'd9:
                            (i_fan_speed_when_s5==8'd30) ?8'd11:
                            (i_fan_speed_when_s5==8'd35) ?8'd13:
                            (i_fan_speed_when_s5==8'd40) ?8'd15:
                            (i_fan_speed_when_s5==8'd45) ?8'd17:
                            (i_fan_speed_when_s5==8'd50) ?8'd19:
                            (i_fan_speed_when_s5==8'd55) ?8'd21:
                            (i_fan_speed_when_s5==8'd60) ?8'd23:
                            8'd11;
assign w_cpld_PWM_when_s5 = (r_cpld_PWM_Counter <= w_duty_dat_when_s5)?1'b1:1'b0;


//CPLD PWM Generate=====================================================


WDT#(.WDT_TIMIEOUT (TIME_OUT0), .RST_VLU(1'b0) ) m_WDT0
(
.i_clk         (i_clk), 
.i_rst_n       (i_rst_n), 
.i_wdt_en      (1'b1), 
.i_WDT_cnt_clk (i_1000mSCE  ), 
.i_WDT_cnt_clr (i_heartbeat ), 
.o_WDT_timeout (w_FullSpeed0)  
);

WDT#(.WDT_TIMIEOUT (TIME_OUT0), .RST_VLU(1'b0) ) m_WDT1
(
.i_clk         (i_clk), 
.i_rst_n       (i_rst_n & i_rst_bmc_n), 
.i_wdt_en      (1'b1), 
.i_WDT_cnt_clk (i_1000mSCE  ), 
.i_WDT_cnt_clr (i_heartbeat ), 
.o_WDT_timeout (w_FullSpeed0_bmc_rst)  
);

// WDT#(.WDT_TIMIEOUT (TIME_OUT1), .RST_VLU(1'b1) ) m_WDT2
// (
// .i_clk         (i_clk), 
// .i_rst_n       (i_rst_n), 
// .i_wdt_en      (1'b1), 
// .i_WDT_cnt_clk (i_1000mSCE  ), 
// .i_WDT_cnt_clr (i_heartbeat ), 
// .o_WDT_timeout (w_FullSpeed0_2)  
// );


WDT#(.WDT_TIMIEOUT (TIME_OUT1), .RST_VLU(1'b1) ) m_WDT3
(
.i_clk         (i_clk), 
.i_rst_n       (i_rst_n), 
.i_wdt_en      (1'b1), 
.i_WDT_cnt_clk (i_1000mSCE  ), 
.i_WDT_cnt_clr (i_heartbeat ), 
.o_WDT_timeout (w_FullSpeed1)  
);


//low_speed_pwr_on=======================================
reg r_low_speed_pwr_on_vld;
reg r_pwr_on_st_dly;
wire w_pwr_on_st_pos;
assign w_pwr_on_st_pos = i_pwr_on_st&&(~r_pwr_on_st_dly);

always@(posedge i_clk or negedge i_rst_n)
begin
    if(~i_rst_n)
    begin
        r_low_speed_pwr_on_vld <= 1'b0;
        r_pwr_on_st_dly   <= 1'b0;
	end
    else
    begin
        r_pwr_on_st_dly <= i_pwr_on_st;
    
        if(w_pwr_on_st_pos && (~w_FullSpeed0) && (w_FullSpeed1) )
            r_low_speed_pwr_on_vld <= 1'b1;
        else if(  (i_pwr_on_st && w_FullSpeed0 && w_FullSpeed1    )
                ||(i_pwr_on_st &&                ( ~w_FullSpeed1) )
                ||(~i_pwr_on_st                                   )
                )
            r_low_speed_pwr_on_vld <= 1'b0;
        else 
            r_low_speed_pwr_on_vld <= r_low_speed_pwr_on_vld;
    end
end


assign o_CPLD_pwm = 
( (~i_pwr_on_st)&(~i_fan_en_when_s5)                                       ) ? i_BMC_pwm                        :
( (~i_pwr_on_st)&( i_fan_en_when_s5)&(~i_bmc_ctrl_when_s5)                 ) ? {(FANNUMBER){w_cpld_PWM_when_s5}}:
( (~i_pwr_on_st)&( i_fan_en_when_s5)&( i_bmc_ctrl_when_s5)&( w_FullSpeed1) ) ? {(FANNUMBER){w_cpld_PWM_when_s5}}:
( (~i_pwr_on_st)&( i_fan_en_when_s5)&( i_bmc_ctrl_when_s5)&(~w_FullSpeed1) ) ? i_BMC_pwm                        :
r_low_speed_pwr_on_vld                                                       ? {(FANNUMBER){w_cpld_PWM_first_on}}        :
( ( i_pwr_on_st)&                                          ( w_FullSpeed1) ) ? {(FANNUMBER){w_cpld_PWM}}        :
( ( i_pwr_on_st)&                                          (~w_FullSpeed1) ) ? i_BMC_pwm                        :

                                                                               {(FANNUMBER){w_cpld_PWM}} ;

												   
// assign o_WDT_timeout0         = w_FullSpeed0 ;	
// assign o_WDT_timeout0_bmc_rst = w_FullSpeed0_bmc_rst ;			
// assign o_WDT_timeout0_n       = ~w_FullSpeed0_2 ;				   
// assign o_WDT_timeout1         = w_FullSpeed1 ;												   


assign o_bmc_active0_n         = w_FullSpeed0         ;	
assign o_bmc_active0_rst_n     = w_FullSpeed0_bmc_rst ;			
// assign o_wdt_override_pld_sel  = ~w_FullSpeed0_2      ;		
assign o_wdt_override_pld_sel  = ~w_FullSpeed1        ;				   
assign o_bmc_active1_n         = w_FullSpeed1         ;												   
								   
												   
endmodule
