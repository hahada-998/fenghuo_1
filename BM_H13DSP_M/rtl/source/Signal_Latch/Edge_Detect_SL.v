//Company:	Inspur
//Engineer:	LEO Ning
//Design Name: 	SEER
//Module Name:	Edge_Detect
//Project Name: SEER
//Version:	v1.0
//Description:	Module Function
//Modification:	The content been modified
//2018-5-8:Modify1
//2018-5-9:Modify2

`timescale 1ns / 1ps

module Edge_Detect_SL#(
	parameter INIT = 1'b1
)(
input i_Clk,		//input Clk
input i_Rst_n,		//Global rst,Active Low
input i_Signal,

output O_Signal_Edge		//Output Signal

);


reg rSignal_a;
reg rSignal_b;
wire wSignal_Pos;
wire wSignal_Neg;

always@(posedge i_Clk or negedge i_Rst_n)
begin
	if(~i_Rst_n)
		begin
			rSignal_a <= INIT;
			rSignal_b <= INIT;
		end
	else
		begin
			rSignal_a <= i_Signal;
			rSignal_b <= rSignal_a;
		end
end

assign wSignal_Pos = rSignal_a && !rSignal_b;
assign wSignal_Neg = !rSignal_a && rSignal_b;

//assign wSignal_Pos = i_Signal && !rSignal_a;
//assign wSignal_Neg = !i_Signal && rSignal_a;

assign O_Signal_Edge = (INIT) ? wSignal_Pos : wSignal_Neg;

endmodule