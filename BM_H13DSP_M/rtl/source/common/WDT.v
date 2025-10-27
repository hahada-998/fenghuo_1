// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
// *                   C O P Y R I G H T     N O T I C E                       *
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
// * Description:     Module Function
// *    UID Control
// * Instances:       Modules included in this file
// *    <1> lowpass_filter
// *    <2> Edge_Detect
// *    <3> NA
// *    <4> NA
// * Modification:    The content been modified
// *    2020-11-26: New Created

`timescale 1ns / 1ps

module WDT#(
parameter WDT_TIMIEOUT = 'd6 ,
parameter RST_VLU      = 1'b0
)
(
input wire i_clk,		//input Clk
input wire i_rst_n,		//Global rst,Active Low
input wire i_wdt_en ,    //WDT timeout detect eabale

input wire i_WDT_cnt_clk, //WDT counter clock
input wire i_WDT_cnt_clr, //WDT counter clear

//Output Signal
output o_WDT_timeout  //active higeh
);
//////////////////////////////////////////////////////////////////////////////////
// Parameters
//////////////////////////////////////////////////////////////////////////////////
//parameter LOW    = 1'b0;
//parameter HIGH   = 1'b1;
//parameter Z      = 1'bz;

//////////////////////////////////////////////////////////////////////////////////
// Internal Signals
//////////////////////////////////////////////////////////////////////////////////
reg [9:0] r_wdt_cnt;
wire w_WDT_cnt_clk_pos;
wire w_WDT_cnt_clr_pos;
reg r_WDT_cnt_clk_dly1,r_WDT_cnt_clk_dly2;
reg r_WDT_cnt_clr_dly1 ,r_WDT_cnt_clr_dly2;
reg r_WDT_timeout;

//////////////////////////////////////////////////////////////////////////////////
// edge detect
//////////////////////////////////////////////////////////////////////////////////
always@(posedge i_clk or negedge i_rst_n)
begin
    if(~i_rst_n)
    begin
        r_WDT_cnt_clk_dly1 <= 1'b1;
		r_WDT_cnt_clk_dly2 <= 1'b1;
        r_WDT_cnt_clr_dly1 <= 1'b1;
		r_WDT_cnt_clr_dly2 <= 1'b1;
	end
    else
    begin
        r_WDT_cnt_clk_dly1 <= i_WDT_cnt_clk;
		r_WDT_cnt_clk_dly2 <= r_WDT_cnt_clk_dly1;
        r_WDT_cnt_clr_dly1 <= i_WDT_cnt_clr ;
		r_WDT_cnt_clr_dly2 <= r_WDT_cnt_clr_dly1;	    
    end
end

assign w_WDT_cnt_clk_pos = r_WDT_cnt_clk_dly1 && (~r_WDT_cnt_clk_dly2);
assign w_WDT_cnt_clr_pos = r_WDT_cnt_clr_dly1 && (~r_WDT_cnt_clr_dly2);

//////////////////////////////////////////////////////////////////////////////////
// timeout detect
//////////////////////////////////////////////////////////////////////////////////


always@(posedge i_clk or negedge i_rst_n)
begin
    if(~i_rst_n)
    begin
        r_WDT_timeout <= RST_VLU;  //RST_VLU
		r_wdt_cnt     <= {10{RST_VLU}};
	end
    else
    begin
        if(w_WDT_cnt_clr_pos)
        begin
            r_wdt_cnt	<= 8'd0;
        end
        else if(r_wdt_cnt>=WDT_TIMIEOUT)
        begin
        	r_wdt_cnt	<= r_wdt_cnt;
        end
        else if( i_wdt_en & w_WDT_cnt_clk_pos)
        begin
        	r_wdt_cnt	<= r_wdt_cnt + 1;
        end
        else
        begin
        	r_wdt_cnt	<= r_wdt_cnt ;
        end
    
        if(r_wdt_cnt>=WDT_TIMIEOUT)
        begin
            r_WDT_timeout	<= 1'b1;
        end
	    else
	    begin
		    r_WDT_timeout	<= 1'b0;
		end
    end
end

assign o_WDT_timeout = r_WDT_timeout ;


endmodule
