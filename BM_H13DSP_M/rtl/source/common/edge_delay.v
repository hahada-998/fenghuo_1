//=================================================================================================--
// Copyright(c) 2021, CLOUDNINEINFO.CO, Ltd, All right reserved
// Filename   : AIS03MB03.v
// Project    : CLOUDNINEINFO common code
// Author     : liuqi
// Date       : 2020-09-24
// Email      : liuqic@cloudnineinfo.com
// Company    : CLOUDNINEINFO.CO., Ltd
// Description: This module generates a delayed version of the input signal. The edge where the
//   delay should start is selectable through a parameter. The default output is also
//   configurable by parameter to allow for specific power on default.
// Parameter  :
//   CNTR_NBITS: Number of counter bits to support cnt_size.
//    Default: 5
//   DEF_OUTPUT: Specify the starting value for the output signal.
//    Default: 1'b0
//   DELAY_MODE : Specify which edge to delay, 0 for rising, 1 for falling.
//    Default: 1'b0
// History    :
//   Date      By          Revision  Change Description
//=================================================================================================
module edge_delay #(
    parameter integer CNTR_NBITS = 5,
    parameter         DEF_OUTPUT = 1'b0,
    parameter         DELAY_MODE = 1'b0
)(
    // 时钟/复位
    input  wire                      clk,        // 时钟
    input  wire                      reset,      // 异步复位（高有效）

    // 延迟控制
    input  wire [CNTR_NBITS-1:0]     cnt_size,   // 延迟计数阈值（以 cnt_step 为步进）
    input  wire                      cnt_step,   // 计数步脉冲（例如 1us tick）

    // 信号
    input  wire                      signal_in,  // 被延迟的输入信号
    output reg                       delay_output// OUTPUT: 延迟后的输出（与 signal_in 相同宽度的单比特）
);
// 计数器寄存
reg [CNTR_NBITS-1:0] timer_cnt;

// timer_cnt 计数器逻辑（独立同步块）
always @(posedge clk or posedge reset)begin
    if(reset)
        timer_cnt <= {CNTR_NBITS{1'b0}};
    else if(signal_in == DELAY_MODE)
        // 输入回到DELAY_MODE（被延迟方向的电平），取消计时并清零计数器
        timer_cnt <= {CNTR_NBITS{1'b0}};
    else if(cnt_step)
        // 累计延时计数，直到达到 cnt_size
        if(timer_cnt < cnt_size)
            timer_cnt <= timer_cnt + 1'b1;
end

// delay_output 输出寄存（独立同步块，基于 timer_cnt 与 signal_in 的状态更新）
always @(posedge clk or posedge reset) begin
    if(reset)
        delay_output <= DEF_OUTPUT;
    else if(signal_in == DELAY_MODE)
        // 输入回到 DELAY_MODE 时，输出立即反映该电平（无延迟方向）
        delay_output <= DELAY_MODE;
    else if (timer_cnt == cnt_size)
        // 当计数器达到阈值时，把输出切换到非 DELAY_MODE（延迟完成）
        delay_output <= ~DELAY_MODE;
end

endmodule

