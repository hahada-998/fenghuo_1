`timescale 1ns / 1ps

module Signal_Latch#(  
parameter EDGE        = 1'b1,         // 1'b1: rising edge; 1'b0: falling edge
parameter INIT        = 1'b1,         // initial or default value of i_Signal
parameter LATCH       = 1'b0,         // abnormal value of i_Signal
parameter POWER_JUDGE = 1'b1          // 1'b1: use i_PWRGD_OK; 1'b0: unuse i_PWRGD_OK
)(

input 			i_Clk,
input 			i_Rst_n,

input 			i_Clr_Flag,
input 			i_PWRGD_OK,            //To judge if the DC on or DC off;
input 			i_Signal,
output 			o_Signal_Latch,
output 			o_Fault
);

////////////////////////////////////////////////////////////////////////////////// //
// VariableS Declaration                                                           //
////////////////////////////////////////////////////////////////////////////////// //

wire 		wSignal_Edge;

reg 		rSignal_Latch;
reg 		rAlert;
////////////////////////////////////////////////////////////////////////////////// //
////////////////////////////////////////////////////////////////////////////////// //

////////////////////////////////////////////////////////////////////////////////// //
// Continuous assignments                                                          //
////////////////////////////////////////////////////////////////////////////////// //

assign o_Signal_Latch = rSignal_Latch;
assign o_Fault        = rAlert;

////////////////////////////////////////////////////////////////////////////////// //
////////////////////////////////////////////////////////////////////////////////// //

Edge_Detect_SL #(
    .INIT(EDGE)
)Edge_Detect_0(
    .i_Clk					(i_Clk),		                      //input Clk
    .i_Rst_n				(i_Rst_n),		                   //Global rst,Active Low
    .i_Signal				(i_Signal),
	
    .O_Signal_Edge		(wSignal_Edge)		          //Output Signal
);

always@(posedge i_Clk or negedge i_Rst_n) begin
    if(~i_Rst_n)
        rAlert <= 1'b0;
    else if(wSignal_Edge && (i_PWRGD_OK || (~POWER_JUDGE)))        //DC on, but has falling edge
        rAlert <= 1'b1;
    else
        rAlert <= 1'b0;
end



always@(posedge i_Clk or negedge i_Rst_n) begin
    if(~i_Rst_n)
        rSignal_Latch <= INIT;
    else if(i_Clr_Flag && (i_Signal == INIT))
        rSignal_Latch <= INIT;
    else if(wSignal_Edge && (i_PWRGD_OK || (~POWER_JUDGE)))        //DC on, but has falling edge
        rSignal_Latch <= LATCH;
    else
        rSignal_Latch <= rSignal_Latch;
end

endmodule