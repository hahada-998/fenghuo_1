module HITLESS#(
  parameter  CNTR_NBITS = 5) (
input i_clk,
input i_reset_n,
input i_hitless_en,

input  [CNTR_NBITS-1:0] i_user_outputs 			,
//output [CNTR_NBITS-1:0] o_latched_user_outputs,
//input  [CNTR_NBITS-1:0] i_user_outputs_fb		,
output [CNTR_NBITS-1:0] o_pre_load_feedback		,
input  [CNTR_NBITS-1:0] i_normal_reset_value	,
inout  [CNTR_NBITS-1:0] io_user_outputs_top	    ,	
output o_mux_sel  //20220915 d00412
//input i_hold_outputs,
//output o_normal_operation

);


// wires (assigns)
//wire mux_sel;  //20220915 d00412
wire [CNTR_NBITS-1:0] i_user_outputs_fb;
wire [CNTR_NBITS-1:0] o_latched_user_outputs;

reg  r_hitless_release_pre;
reg  [31:0]r_hitless_release_cnt;
//-------------------------------------//
//-- assign (non-process) operations --//
//-------------------------------------//



// Add Multiplexer Select logic 
assign o_mux_sel = r_hitless_release_pre | (~i_hitless_en);//Normal Operation or Hitless_enable/disable signal	
// Add Multiplexer Latch 
assign o_latched_user_outputs = o_mux_sel ? i_user_outputs : i_user_outputs_fb;// Inversed for ON--1 & OFF--0; Output MUX to select user Logic or HOLD the IO state

assign o_pre_load_feedback = i_hitless_en ? i_user_outputs_fb : i_normal_reset_value;


always @(posedge i_clk or negedge i_reset_n) 
begin
    if(~i_reset_n) 
        r_hitless_release_cnt <= 32'd0;
	else if(r_hitless_release_cnt >= 32'd5_000_000)  
	    r_hitless_release_cnt <= r_hitless_release_cnt;
	else 							     
	    r_hitless_release_cnt <= r_hitless_release_cnt + 1'b1;
end

always @(posedge i_clk or negedge i_reset_n) 
begin
    if(~i_reset_n) 
	    r_hitless_release_pre <= 1'b0;
    else if(r_hitless_release_cnt == 4'd5 && ~i_hitless_en)
	    r_hitless_release_pre <= 1'b1;
    else if(r_hitless_release_cnt == 4'd5 && i_hitless_en)
	    r_hitless_release_pre <= 1'b0;
    else if(r_hitless_release_cnt >= 32'd5_000_000)   //100ms
	    r_hitless_release_pre <= 1'b1;
    else  
	    r_hitless_release_pre <= r_hitless_release_pre;
end

//-------------------------------------//
//-- Message Control Module Instance --//
//-------------------------------------//

/*
MESSAGE_CONTROL msg_ctrl_inst(

	.reset_n	      (i_reset_n			),
	.clk		      (i_clk				),
	.sw		  		  (i_hold_outputs		),
	.normal_operation (o_normal_operation	)
);
*/

generate
    genvar k;
    for (k=0; k<=(CNTR_NBITS-1); k=k+1)  
    begin
        BB bidir_inst( .I(o_latched_user_outputs[k]), .T( 1'b0 ), .O( i_user_outputs_fb[k]), .B( io_user_outputs_top[k]) );
    end
endgenerate

endmodule 