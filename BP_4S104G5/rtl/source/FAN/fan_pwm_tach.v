//FAN MAX speed is 17000r/min  17000/60s= 283r/s
//8038 single rotor fan MAX speed is 17000r/min
//8056 dual rotor fan front rotor  MAX speed is 17000r/min tach0 
//8056 dual rotor fan back rotor  MAX speed is 14500r/min tach1  //2023-2-9 add
//2022-12-10 change  fan_tach logic
 



`timescale 1ns / 1ps
module fan_pwm_tach
(
input  i_clk,
input  i_rst_n,
input  i_clk_0_4us,  //2023-6-6 actually chg to t6m25_clk
input  i_clk_1s,
input  [7:0] i_pwm_duty,
input  i_fan_tach0,
input  i_fan_tach1,
output o_pwm_out,
output [7:0] o_fan_tach0_reg,
output [7:0] o_fan_tach1_reg,
output reg  [10:0]o_fan_tach0_cnt,//2023-3-16 add  it is real tach
output reg  [10:0]o_fan_tach1_cnt


);

//FAN logic
localparam FAN_PCT_0   = 8'd00;//  0/256= 0.000%
localparam FAN_PCT_10  = 8'd10;// 25/256= 9.766% a
localparam FAN_PCT_20  = 8'd20;// 51/256=19.922% 14
localparam FAN_PCT_30  = 8'd30;// 76/256=29.688% 1e
localparam FAN_PCT_40  = 8'd40;//102/256=39.844% 28
localparam FAN_PCT_50  = 8'd50;//128/256=50.000% 32
localparam FAN_PCT_60  = 8'd60;//153/256=59.766% 3c 
localparam FAN_PCT_70  = 8'd70;//179/256=69.922% 46
localparam FAN_PCT_80  = 8'd80;//204/256=79.688% 50
localparam FAN_PCT_90  = 8'd90;//230/256=89.844% 5a
localparam FAN_PCT_100 = 8'd100;//255/256=99.219% 64 
 
 
 
///////////////////////////////////////////////////////////////////////////////////
//internal signals
///////////////////////////////////////////////////////////////////////////////////   
wire [7:0] w_cnt_max; 
wire [7:0] w_cnt_pwm;
// wire w_clr_pwm_cnt_n;
reg  r_clr_pwm_cnt;
// wire w_clr_en;  
wire w_clk_0_4us_pos;//2022-12-10 add
wire w_clk_1s_pos;
wire w_clk_1s_neg;
wire [10:0]w_fan_tach0_cnt_pre;	//2023-2-1add
wire [10:0]w_fan_tach1_cnt_pre;	//2023-2-1add
// wire [8:0]w_fan_tach0_cnt;	
// wire [8:0]w_fan_tach1_cnt;	
wire w_fan_tach0_pos;
wire w_fan_tach1_pos;
 
// reg  r_clk_1s;
	

			  
///////////////////////////////////////////////////////////////////////////////////
//
///////////////////////////////////////////////////////////////////////////////////
assign w_cnt_max       = 255;   //100  //255 2023-6-6 chg back to 100
assign o_pwm_out       = ( i_pwm_duty >= 8'd255   ) ? 1'b1 ://8'd100
                         ( w_cnt_pwm < i_pwm_duty ) ? 1'b1 : 1'b0 ; 
//assign w_clk_1s_pos    = i_clk_1s & (~r_clk_1s);
//assign w_clk_1s_neg    = (~i_clk_1s) & r_clk_1s;
			   
////////////////////////////////////////////////////////////////////////////////////				   
//generate PWM 		
 

always@(posedge i_clk or negedge i_rst_n)
begin
    if(~i_rst_n)
        r_clr_pwm_cnt <= 1'b0;
	else 
	begin
	    if(w_cnt_pwm >= w_cnt_max)
		    r_clr_pwm_cnt  <= 1'b1;
		else
		    r_clr_pwm_cnt  <= 1'b0;
	end
end

Edge_Detect Edge_Detect_u0(
.i_clk              (i_clk),           //input Clk
.i_rst_n            (i_rst_n),         //Global rst,Active Low
.i_signal           (i_clk_0_4us),

.o_signal_pos       (w_clk_0_4us_pos),
.o_signal_neg       (),
.o_signal_invert    ()
);

fan_counter #(
.WIDTH          (8 ), 
.MAX_VALUE      (255 )//100
)fan_pwm_cnt_u0(
.i_clk          (i_clk),
.i_rst_n        (i_rst_n),
.i_clk_en       (w_clk_0_4us_pos),
.i_clr_pwm_cnt  (r_clr_pwm_cnt),
.o_cnt_result   (w_cnt_pwm)
);



  
  
//////////////////////////////////////////////////////////////////////////////////
//monitor TACH
 /*
always@(posedge i_clk or negedge i_rst_n) 
begin
    if(~i_rst_n)
	begin 
		r_clk_1s        <= 1'b0;
	end
	else
	begin 
		r_clk_1s        <= i_clk_1s;
	end
end
*/
Edge_Detect Edge_Detect_u1(
.i_clk              (i_clk),           //input Clk
.i_rst_n            (i_rst_n),         //Global rst,Active Low
.i_signal           (i_clk_1s),

.o_signal_pos       (w_clk_1s_pos),
.o_signal_neg       (w_clk_1s_neg),
.o_signal_invert    ()
);
 

Edge_Detect Edge_Detect_u2(
.i_clk              (i_clk),           //input Clk
.i_rst_n            (i_rst_n),         //Global rst,Active Low
.i_signal           (i_fan_tach0),

.o_signal_pos       (w_fan_tach0_pos),
.o_signal_neg       (),
.o_signal_invert    ()
);


fan_counter #(
.WIDTH          (11 ), 
.MAX_VALUE      ('h3FE ) // tach is twice fan speed 2023-2-1 add    //2023-7-12  d800 to h3FE
)fan_pwm_cnt_u1(
.i_clk          (i_clk),
.i_rst_n        (i_rst_n),
.i_clk_en       (w_fan_tach0_pos ),
.i_clr_pwm_cnt  (w_clk_1s_pos),
.o_cnt_result   (w_fan_tach0_cnt_pre)
);

 

Edge_Detect Edge_Detect_u3(
.i_clk              (i_clk),           //input Clk
.i_rst_n            (i_rst_n),         //Global rst,Active Low
.i_signal           (i_fan_tach1),

.o_signal_pos       (w_fan_tach1_pos),
.o_signal_neg       (),
.o_signal_invert    ()
);

fan_counter #(
.WIDTH          (11 ), 
.MAX_VALUE      ('h3FE )     //  //2023-7-12  10'd773 to h3FE
)fan_pwm_cnt_u2(
.i_clk          (i_clk),
.i_rst_n        (i_rst_n),
.i_clk_en       (w_fan_tach1_pos ),
.i_clr_pwm_cnt  (w_clk_1s_pos),
.o_cnt_result   (w_fan_tach1_cnt_pre)
);
 
/////////////////////////////////////////////////////////////////////////////////////////
// the r_fan_tach_cnt data is valid only at posedge of w_clk_1s_pos  2023-2-1 add
// tach is twice fan speed 2023-2-1 add 
/////////////////////////////////////////////////////////////////////////////////////////
 
always@(posedge w_clk_1s_pos or negedge i_rst_n)  
begin
    if ( i_rst_n == 1'b0  )
        o_fan_tach0_cnt <=11'd000      ; //9'd000
    else
        o_fan_tach0_cnt <= w_fan_tach0_cnt_pre ;  //(w_fan_tach0_cnt_pre >> 1 );   
end

always@(posedge w_clk_1s_pos or negedge i_rst_n)
begin
    if ( i_rst_n == 1'b0  )
        o_fan_tach1_cnt <= 11'd000      ;  //9'd000
    else
        o_fan_tach1_cnt <= w_fan_tach1_cnt_pre ; //(w_fan_tach1_cnt_pre >> 1 );
end

assign o_fan_tach0_reg = (o_fan_tach0_cnt >= 11'd760)                                   ? FAN_PCT_100 : //95%-100%  //800
						 ((o_fan_tach0_cnt < 11'd760)  && (o_fan_tach0_cnt >= 11'd680)) ? FAN_PCT_90  : //85%-95%
						 ((o_fan_tach0_cnt < 11'd680)  && (o_fan_tach0_cnt >= 11'd600)) ? FAN_PCT_80  : //75%-85%
						 ((o_fan_tach0_cnt < 11'd600)  && (o_fan_tach0_cnt >= 11'd520)) ? FAN_PCT_70  : //65%-75%
						 ((o_fan_tach0_cnt < 11'd520)  && (o_fan_tach0_cnt >= 11'd440)) ? FAN_PCT_60  : //55%-65%
						 ((o_fan_tach0_cnt < 11'd440)  && (o_fan_tach0_cnt >= 11'd360)) ? FAN_PCT_50  : //45%-55%
						 ((o_fan_tach0_cnt < 11'd360)  && (o_fan_tach0_cnt >= 11'd280)) ? FAN_PCT_40  : //35%-45%
						 ((o_fan_tach0_cnt < 11'd280)  && (o_fan_tach0_cnt >= 11'd200)) ? FAN_PCT_30  : //25%-35%
						 ((o_fan_tach0_cnt < 11'd200)  && (o_fan_tach0_cnt >= 11'd120)) ? FAN_PCT_20  : //15%-25%
						 ((o_fan_tach0_cnt < 11'd120)  && (o_fan_tach0_cnt >= 11'd40 )) ? FAN_PCT_10  : //5%-15%
					     (o_fan_tach0_cnt == 11'd0)                                     ? 8'd0        :8'd0 ;


assign o_fan_tach1_reg = (o_fan_tach1_cnt >= 11'd734)                                   ? FAN_PCT_100 : //95%-100%     //773
                         ((o_fan_tach1_cnt < 11'd734)  && (o_fan_tach1_cnt >= 11'd656)) ? FAN_PCT_90  : //85%-95%   
                         ((o_fan_tach1_cnt < 11'd656)  && (o_fan_tach1_cnt >= 11'd580)) ? FAN_PCT_80  : //75%-85%
                         ((o_fan_tach1_cnt < 11'd580)  && (o_fan_tach1_cnt >= 11'd502)) ? FAN_PCT_70  : //65%-75%
                         ((o_fan_tach1_cnt < 11'd502)  && (o_fan_tach1_cnt >= 11'd424)) ? FAN_PCT_60  : //55%-65%
                         ((o_fan_tach1_cnt < 11'd424)  && (o_fan_tach1_cnt >= 11'd348)) ? FAN_PCT_50  : //45%-55%//2023-3-17 fix the error 96-->108
                         ((o_fan_tach1_cnt < 11'd348)  && (o_fan_tach1_cnt >= 11'd270)) ? FAN_PCT_40  : //35%-45%
                         ((o_fan_tach1_cnt < 11'd270)  && (o_fan_tach1_cnt >= 11'd192)) ? FAN_PCT_30  : //25%-35%
                         ((o_fan_tach1_cnt < 11'd192)  && (o_fan_tach1_cnt >= 11'd116)) ? FAN_PCT_20  : //15%-25%
                         ((o_fan_tach1_cnt < 11'd116)  && (o_fan_tach1_cnt >= 11'd38 )) ? FAN_PCT_10  : //5%-15%
                         (o_fan_tach1_cnt == 11'd0)                                     ? 8'd0        :8'd0 ;





endmodule





