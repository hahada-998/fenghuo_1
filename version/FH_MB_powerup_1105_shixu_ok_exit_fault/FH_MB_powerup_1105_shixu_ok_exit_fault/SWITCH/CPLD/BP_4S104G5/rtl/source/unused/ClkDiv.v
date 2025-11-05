
// * 
// * 
// * 
// *  
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//         ClkDiv
//////////////////////////////////////////////////////////////////////////////////

module ClkDiv # //%Parameterizable Synchronus Clock Divider<br>
(
                //% Counter bits<br>
    parameter   MAX_DIV_BITS = 4, 
                //% Maximun count value<br>
    parameter   MAX_DIV_CNT = 15  
)
(
            //% Clock Input<br>    
    input   i_clk,
            //% Asynchronous Reset Input<br>
    input   i_rst_n,
            //% Clock Enable from a previous stage<br>
    input   iCE,
            //% Output Divided Clock Signal<br>
    output  oDivClk
);
//////////////////////////////////////////////////////////////////////////////////
// Includes
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////
// Defines
//////////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////////
// Internal Signals
//////////////////////////////////////////////////////////////////////////////////
                                //% Internal Counter register input equation<br>
reg    [(MAX_DIV_BITS - 1):0]   rvDivCnt_d;
                                //% Internal Counter register Output<br>
reg    [(MAX_DIV_BITS - 1):0]   rvDivCnt_q;
                                //% Divided Clock register input equation<br>
reg                             rDivClk_d;
                                //% Divided Clock register output<br>
reg                             rDivClk_q;
//////////////////////////////////////////////////////////////////////////////////
// Continous assigment
//////////////////////////////////////////////////////////////////////////////////
assign    oDivClk    =    rDivClk_q;
//////////////////////////////////////////////////////////////////////////////////
// Sequential Section
//////////////////////////////////////////////////////////////////////////////////
//% Sequential Section<br>
always @(posedge i_clk or negedge i_rst_n)
begin
    if(~i_rst_n)                                    //Reset?
    begin
        rvDivCnt_q  <=  {MAX_DIV_BITS{1'b0}};   // Yes, then set Count Reset to all 
        rDivClk_q   <=  1'b0;                   //0's and Divided Clock 0
    end
    else
    begin
        if(iCE)                                 //No, Clock Enable?
        begin
            rvDivCnt_q  <=  rvDivCnt_d;         // Yes, then update Count register
        end
        else
        begin
            rvDivCnt_q  <=  rvDivCnt_q;         // No, then keep the same value
        end
        rDivClk_q   <=  rDivClk_d;              //Update Divided Clock Signal 
                                                //Register
    end
end
//////////////////////////////////////////////////////////////////////////////////
// Combinational Section
//////////////////////////////////////////////////////////////////////////////////
//% Combinational Section<br>
always @*
begin
    //Clock divider will be set to 1 when rvDivCnt_q reaches the MAX_DIV_CNT
    rDivClk_d   =   (iCE) ? (rvDivCnt_q == MAX_DIV_CNT) : 1'b0; 
    //rvDivCnt will be incremented while it is below the MAX_DIV_CNT, otherwise
    //it is set to 0
    rvDivCnt_d  =   {MAX_DIV_BITS{1'b0}};   
    if(rvDivCnt_q != MAX_DIV_CNT)   
    begin
        rvDivCnt_d  =   rvDivCnt_q + 1'b1;
    end
end

//////////////////////////////////////////////////////////////////////////////////
//Instances
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////
endmodule
