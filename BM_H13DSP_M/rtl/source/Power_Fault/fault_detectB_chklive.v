//=================================================================================================--
// Copyright(c) 2021, CLOUDNINEINFO.CO, Ltd, All right reserved
// Filename   : AIS03MB03.v
// Project    : CLOUDNINEINFO common code
// Author     : liuqi
// Date       : 2020-09-24
// Email      : liuqic@cloudnineinfo.com
// Company    : CLOUDNINEINFO.CO., Ltd
// Description: This module detects faults by monitoring the vrm_pgood signal. vrm_enable must be
//   enabled first before any monitoring is done. In addition, a high on vrm_chklive_en is
//   required to enable monitoring. This is an indication that vrm_pgood must be monitored now.
//   A high on vrm_chklive_dis causes the monitoring to be turned off. These two signals provide
//   a window for checking vrm_pgood as opposed to only checking the the signal at certain point
//   in power sequencer.
// History    :
//   Date      By          Revision  Change Description
//=================================================================================================
/* 
模块功能：
1. 监控 VRM 状态：通过 vrm_pgood 信号监控 VRM 的电源状态。
2. 故障检测：在监控窗口内检测 VRM 是否发生故障。
3. 故障标志：记录每个 VRM 的故障状态，并汇总所有 VRM 的故障标志。
4. 故障清除与锁定：支持清除故障标志，并提供锁定机制防止重复记录故障。
*/

module fault_detectB_chklive #(parameter NUMBER_OF_VRM = 1) (
    input                          clk,              // 时钟信号
    input                          reset,            // 复位信号，高电平有效
    input      [NUMBER_OF_VRM-1:0] vrm_enable,       // VRM 启用信号
    input      [NUMBER_OF_VRM-1:0] vrm_pgood,        // VRM 电源良好信号
    input      [NUMBER_OF_VRM-1:0] vrm_chklive_en,   // 启用 VRM 检测信号
    input      [NUMBER_OF_VRM-1:0] vrm_chklive_dis,  // 禁用 VRM 检测信号
    input                          critical_fail,    // 电源管理器的关键故障状态信号
    input                          fault_clear,      // 清除故障标志信号
    input                          lock,             // 锁定故障捕获信号
    output reg                     any_vrm_fault,    // 任意 VRM 故障标志信号
    output reg [NUMBER_OF_VRM-1:0] vrm_fault         // 每个 VRM 的故障标志信号
);

wire                     lock_en;                  // 锁定使能信号
reg  [NUMBER_OF_VRM-1:0] chklive_en;               // 检测使能信号
wire [NUMBER_OF_VRM-1:0] monitor_en;               // 监控使能信号
wire [NUMBER_OF_VRM-1:0] fault_event;              // 故障事件信号

// 锁定使能信号，当任意 VRM 故障或锁定信号有效时，锁定故障捕获
assign lock_en = any_vrm_fault | lock;

genvar i;
generate
  for (i = 0; i < NUMBER_OF_VRM; i = i + 1)
  begin : _fault_detect_
    // 检测窗口控制逻辑
    // 当 vrm_chklive_en 置高时，开启检测窗口
    // 当 vrm_chklive_dis 置高时，关闭检测窗口
    always @(posedge clk or posedge reset) begin
      if (reset)
        chklive_en[i] <= 1'b0;                     // 复位时关闭检测窗口
      else if (vrm_chklive_dis[i])
        chklive_en[i] <= 1'b0;                     // 禁用检测时关闭检测窗口
      else if (vrm_chklive_en[i])
        chklive_en[i] <= 1'b1;                     // 启用检测时开启检测窗口
    end

    // 监控使能信号，当检测窗口开启或关键故障信号有效时，启用监控
    assign monitor_en[i]  = chklive_en[i] | critical_fail;

    // 故障事件信号，当 VRM 启用且电源良好信号无效时，触发故障事件
    assign fault_event[i] = vrm_enable[i] & ~vrm_pgood[i];

    // 故障标志逻辑
    always @(posedge clk or posedge reset) begin
      if (reset)
        vrm_fault[i] <= 1'b0;                      // 复位时清除故障标志
      else if (fault_clear)
        vrm_fault[i] <= 1'b0;                      // 清除故障标志信号有效时清除故障标志
      else if (~lock_en && monitor_en[i] && fault_event[i])
        vrm_fault[i] <= 1'b1;                      // 未锁定且监控启用且发生故障事件时，设置故障标志
    end
  end
endgenerate

// 任意 VRM 故障标志逻辑
// 如果任意 VRM 的故障标志有效，则置高 any_vrm_fault
always @(posedge clk or posedge reset) begin
  if (reset)
    any_vrm_fault <= 1'b0;                         // 复位时清除故障标志
  else if (fault_clear)
    any_vrm_fault <= 1'b0;                         // 清除故障标志信号有效时清除故障标志
  else
    any_vrm_fault <= |vrm_fault;                   // 如果任意 VRM 的故障标志有效，则置高
end

endmodule

