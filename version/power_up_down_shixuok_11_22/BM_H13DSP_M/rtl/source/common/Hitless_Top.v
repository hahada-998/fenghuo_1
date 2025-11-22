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
// * Engineer:        Lambert
// * Email:           chenzhanliang@inspur.com 
// * Module Name:     Hitless_Top.v
// * Project Name:    fuzhou
// * Description:     hitless function for altera MAX10
// *		 
// * Instances:       Modules included in this file
// *    <1>           sp_test.v 
// *    <2>           Edge_Detect.v
// *    <3>           bidir_io_hitless_pp
// *    <4>           bidir_io_hitless_od
// * Modification:    The content been modified
// *    2020-11-26: New Created
// *    2021-05-08：  
// *    1. change input clock to 50MHz;
// *    2. delete the default value of r_hitless_en;
// *    3. change r_hitless_release_cnt to 250_000_000 for 50MHz clock;
// *    2021-07-06：
// *    1. add  o_signal_out for inout signals;
// *    2. change w_hitless_release logic for first AC on issue;

//Hitless_Top是无中断切换（无感升级）核心模块，专为 Altera MAX10 CPLD 设计，用于在系统状态切换
//（如固件更新、配置变更）时，确保关键控制信号（如电源使能、芯片复位）无毛刺、无中断，避免设备重启或功能
//异常。该模块是 “无感升级”（Hitless Upgrade）的关键组件，直接支撑系统在升级过程中保持业务连续性。

`timescale 1ns / 1ps
 
module Hitless_Top #( 
    parameter 	HITLESS_SIG_NUM  = 100  // 无中断切换的信号数量（默认100路，可根据需求调整）
)
(
    // 时钟与复位
    input  i_clk,                      // 模块工作时钟（50MHz，2021-05-08版本调整，确保时序稳定）
    input  i_rst_n,                    // 异步复位（低电平有效）

    // 无中断切换控制
    input  i_hitless_en,               // 无中断使能信号（高电平=启用切换功能；低电平=强制释放）
    output o_release	,               // 切换释放信号（高电平=允许从预加载状态切换到正常状态）切换完成的标志，通知上层模块 “已完成无中断切换，可进入正常状态”

    // 信号输入与输出（核心切换通道）
    input  [HITLESS_SIG_NUM-1:0] i_signal_in,  // 正常状态输入信号（来自系统逻辑，如电源控制、复位信号）
    output [HITLESS_SIG_NUM-1:0] o_signal_out, // 预加载状态输出信号（反馈到系统，保持初始状态）
    inout  [HITLESS_SIG_NUM-1:0] io_signal_out // 双向输出信号（连接外部硬件，如芯片使能引脚、复位引脚）
);

////////////////////////////////////////////////////////////////////////////////// //
//internal signals                                                          
////////////////////////////////////////////////////////////////////////////////// //
reg  r_hitless_release_pre;       // 释放前导寄存器（用于生成稳定的释放信号）
reg  r_hitless_en;                // 无中断使能锁存寄存器（同步i_hitless_en，避免毛刺）
reg  [31:0]r_hitless_release_cnt; // 释放计数器（用于延时，确保切换时机稳定）
reg	[HITLESS_SIG_NUM-1:0] r_signal_out; // 预加载状态寄存器（存储初始状态值）

// 双向缓冲信号（解决IO双向传输的电平冲突）
wire [HITLESS_SIG_NUM-1:0] w_Hitless_bb_m;	// 双向缓冲输入信号（待输出到硬件）
wire [HITLESS_SIG_NUM-1:0] w_Hitless_bb_o;	// 双向缓冲输出信号（从硬件反馈的信号）
wire w_hitless_release;             // 无中断释放信号（内部逻辑，控制切换时机）

///////////////////////////////////////////////////////////////////////////////////////
// 无中断释放信号：高电平表示“允许切换到正常状态”
// 触发条件：1. 释放前导信号有效（r_hitless_release_pre=1）；2. 无中断功能禁用（i_hitless_en=0）
assign w_hitless_release	= r_hitless_release_pre | (~i_hitless_en);

// 预加载状态输出：使能有效时输出缓冲反馈信号，否则输出预加载寄存器值
assign o_signal_out			= r_hitless_en ? w_Hitless_bb_o		: r_signal_out;

// 释放标志输出：对外指示切换完成
assign o_release			= w_hitless_release	;

// 双向缓冲输入：释放后使用正常状态信号，否则保持当前缓冲输出（锁存初始状态）
assign w_Hitless_bb_m		= w_hitless_release ? i_signal_in	: w_Hitless_bb_o	;
///////////////////////////////////////////////////////////////////////////////////////
// 释放计数器：用于延时，确保系统上电稳定后再切换（避免上电初期信号波动导致误切换）
always @(posedge i_clk or negedge i_rst_n) 
begin
    if(~i_rst_n) 
        r_hitless_release_cnt <= 32'd0;  // 复位时计数器清零
    else if(r_hitless_release_cnt >= 32'd20_000_000)  // 计数到20,000,000（50MHz时钟下为400ms）
        r_hitless_release_cnt <= r_hitless_release_cnt;  // 达到阈值后保持，不再计数
    else 							     
        r_hitless_release_cnt <= r_hitless_release_cnt + 1'b1;  // 未达阈值时累加
end

// 释放前导信号：控制切换的时机，确保切换过程无毛刺
always @(posedge i_clk or negedge i_rst_n) 
begin
    if(~i_rst_n) 
        r_hitless_release_pre <= 1'b0;  // 复位时不释放（预加载状态）
    // 条件1：计数器=5且无中断禁用（i_hitless_en=0）→ 立即释放（强制切换到正常状态）
    else if(r_hitless_release_cnt == 4'd5 && ~i_hitless_en)
        r_hitless_release_pre <= 1'b1;
    // 条件2：计数器=5且无中断使能（i_hitless_en=1）→ 不释放（保持预加载状态）
    else if(r_hitless_release_cnt == 4'd5 && i_hitless_en)
        r_hitless_release_pre <= 1'b0;
    // 条件3：计数器达到阈值（400ms）→ 自动释放（系统稳定后切换）
    else if(r_hitless_release_cnt >= 32'd20_000_000)
        r_hitless_release_pre <= 1'b1;
    else  // 其他情况保持当前状态
        r_hitless_release_pre <= r_hitless_release_pre;
end

// 生成HITLESS_SIG_NUM个双向缓冲器（BB：Bidirectional Buffer），每路对应一个信号
generate
    genvar k;
    for (k=0; k<=(HITLESS_SIG_NUM-1); k=k+1)  
    begin
        // 双向缓冲原语：实现信号的双向传输与隔离，避免切换时的电平冲突
        BB bidir_inst ( 
            .I( w_Hitless_bb_m[k]),  // 输入：待输出到硬件的信号（预加载或正常状态）
            .T( 1'b0 ),              // 三态控制：0=驱动输出（始终驱动，无高阻态）
            .O( w_Hitless_bb_o[k]),  // 输出：从硬件反馈的信号（用于预加载状态自循环）
            .B( io_signal_out[k] )   // 双向端口：连接外部硬件引脚（如电源使能、复位）
        );
    end
endgenerate

endmodule


//1. Hitless_Top 模块的关键作用
//Hitless_Top是无感升级的信号保护核心，通过以下机制支撑无感升级：
//预加载保护：升级开始前，模块将关键信号（如电源使能）锁存在稳定的初始值（预加载状态），避免升级过程中因配置变更导致信号波动；
//无毛刺切换：升级完成后，模块通过 “延时计数器” 和 “双向缓冲”，将信号平滑切换到新配置的正常状态，整个过程无毛刺、无中断；
//状态反馈：o_signal_out提供预加载状态的实时反馈，确保上层模块（如电源状态机）能同步感知切换进度，避免状态不一致；
//灵活控制：通过i_hitless_en可动态启用 / 禁用保护功能，适应 “升级时保护、正常运行时放开” 的场景需求。
//2. 典型无感升级流程中的模块行为
//升级准备：系统发送i_hitless_en=1（启用保护），模块进入预加载状态，io_signal_out锁定当前稳定值；
//固件更新：CPLD 通过 I2C 更新固件，此时io_signal_out保持不变，硬件正常运行；
//切换释放：更新完成后，计数器等待 400ms（确保新固件稳定），w_hitless_release=1，io_signal_out平滑切换到新配置的信号；
//升级完成：o_release=1通知系统切换完成，i_hitless_en=0（禁用保护），模块进入正常运行状态。