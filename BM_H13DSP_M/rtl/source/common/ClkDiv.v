/* =============================================================================================================
模块功能：参数化的同步时钟分频器模块，用于生成一个单周期的时钟脉冲信号，当内部计数器达到最大计数值时输出脉冲

1. 输入时钟分频：将输入时钟信号 iClk 分频，生成一个低频的输出时钟信号 oDivClk。
2. 时钟使能控制：通过输入信号 iCE 控制分频器是否工作。
3. 异步复位：通过输入信号 iRst 对模块进行异步复位。

       +-----------------+
-----> |> iClk   oDivClk |----->
-----> |  iRst      .    |
-----> |  iCE       .    |
       +-----------------+
             ClkDiv
===============================================================================================================*/
`timescale 1ns / 1ps
module ClkDiv #
(
    parameter MAX_DIV_BITS = 4,  // 计数器位宽
    parameter MAX_DIV_CNT  = 15   // 最大计数值
)(
    input   wire           iClk            , // 输入时钟信号
    input   wire           iRst            , // 异步复位信号
    input   wire           iCE             , // 时钟使能信号
    output  wire           oDivClk           // 输出分频时钟信号
);
reg  [(MAX_DIV_BITS - 1):0]              rvDivCnt_d              ; // 计数器的组合逻辑值
reg  [(MAX_DIV_BITS - 1):0]              rvDivCnt_q              ; // 计数器的寄存器值
reg                                      rDivClk_d               ; // 输出时钟的组合逻辑值
reg                                      rDivClk_q               ; // 输出时钟的寄存器值

// 计数器控制生成分频时钟脉冲
always @(*)begin
    rvDivCnt_d = (rvDivCnt_q != MAX_DIV_CNT) ? (rvDivCnt_q + 1'b1) : {MAX_DIV_BITS{1'b0}};
end

always @(posedge iClk or posedge iRst)begin
    if(iRst)                                    
        rvDivCnt_q  <=  {MAX_DIV_BITS{1'b0}} ; // 复位计数器
    else if(iCE)
        rvDivCnt_q  <=  rvDivCnt_d           ; // 更新计数器
end


// 当计数器达到最大值时，输出一个分频时钟信号脉冲
always @(*)begin 
    rDivClk_d = (iCE) ? (rvDivCnt_q == MAX_DIV_CNT) : 1'b0;
end 

always @(posedge iClk or posedge iRst)begin
    if(iRst)                                    
        rDivClk_q   <=  1'b0        ; // 复位输出时钟
    else
        rDivClk_q   <=  rDivClk_d   ; // 更新输出时钟 
end

// 分频时钟信号输出
assign oDivClk = rDivClk_q  ;
endmodule
