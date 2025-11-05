//=================================================================================================--
// Copyright(c) 2021, CLOUDNINEINFO.CO, Ltd, All right reserved
// Filename   : AIS03MB03.v
// Project    : CLOUDNINEINFO common code
// Author     : liuqi
// Date       : 2020-09-24
// Email      : liuqic@cloudnineinfo.com
// Company    : CLOUDNINEINFO.CO., Ltd
// Description: This module handles FPGA power-on reset. This is basically the source of reset for
//   all the sub-blocks in the top level.
// History    :
//   Date      By          Revision  Change Description
//=================================================================================================
//pon_reset 模块主要实现系统上电复位（Power-On Reset）及相关信号同步、生成逻辑，确保在电源稳定
//（pgd_p3v3_stby）、锁相环（PLL）锁定（pll_lock）、FPGA 启动完成（done_booting）等条件满足时，
//正确时序释放复位信号，使系统各模块（如 CPLD、辅助系统）有序退出复位，进入正常工作状态。
module pon_reset (
  input       clk,                          // main clock (100MHz)	主时钟（100MHz），用于同步所有操作
  input       pll_lock,                     // PLL lock signal  PLL 锁定信号（高电平表示 PLL 时钟稳定）
  input       pgd_p3v3_stby,                // P3V3_STBY pgood 3.3V 备用电源良好信号（高电平表示电源稳定）
  input       pgd_aux_gmt,                  // PGD_AUX_GMT signal  辅助 GMT（电源/模块）良好信号
  input       done_booting,                 // FPGA done booting image (if not used, set to 1'b1) FPGA 完成启动的信号（高电平有效）
  input       done_booting_delayed,         // delayed version of done_booting (if not used, set to 1'b1)done_booting 的延迟版本信号
  output      pon_reset_n,                  // master AUX power-on reset (based on pgd_p3v3_stby)  主上电复位信号（低电平有效）
  output reg  pon_reset_db_n,               // pon_reset_n version that is qualified with done_booting_delayed 经 done_booting_delayed 合格的延迟复位信号
  output      pgd_aux_system,               // AUX pgood indicator (based on both pgd_p3v3_stby and pgd_aux_gmt) 辅助系统良好指示（基于 pgd_p3v3_stby 和 pgd_aux_gmt）
  output reg  pgd_aux_system_sasd,          // SASD version of pgd_aux_system  pgd_aux_system 的 SASD（同步/延迟）版本
  output      cpld_ready                    // FPGA is ready to go (0 means go) PLD 就绪信号（低电平表示 FPGA 已启动，CPLD 可工作）
);

wire       master_reset_n;		// 主复位条件信号（由电源和 PLL 锁定共同决定）
reg  [2:0] reset1_reg;			// 用于同步复位的第一级寄存器（3位，实现移位同步
reg  [2:0] reset2_reg;			// 用于同步复位的第二级寄存器（3位，实现移位同步）
reg        pgd_aux_system_reg;	// 辅助系统信号的中间寄存器（用于生成 sasd 版本）

//------------------------------------------------------------------------------
// Reset output	主复位条件生成
//------------------------------------------------------------------------------
// Reset everything if pgd_p3v3_stby or pll_lock goes down.
    // 当 3.3V 电源或 PLL 锁定任一失效时，master_reset_n 为低（触发复位）
    // 语法：assign <线网> = <逻辑表达式>，用于组合逻辑赋值
assign master_reset_n = pgd_p3v3_stby & pll_lock;

// Synchronize reset for downstream logic.  Note there's no need to include the
// pgd_p3v3_stby and pll_lock term in resetX_reg terms since they reset to 0
// if any of these signals are low.
//复位信号同步（两级寄存器）
    // 敏感列表：clk 上升沿 或 master_reset_n 下降沿（复位触发时立即同步）
    // 语法：always @(posedge <时钟> or negedge <异步复位>)，实现同步/异步复位逻辑
always @(posedge clk or negedge master_reset_n)
begin
  if (!master_reset_n)
  begin
    reset1_reg <= 3'b0;
    reset2_reg <= 3'b0;
  end
  else
  begin	// 时钟上升沿同步：寄存器左移，最低位补 1 或 pgd_aux_gmt
    reset1_reg <= {reset1_reg[1:0], 1'b1};			// 复位1_reg 左移，最低位补 1（实现复位释放的同步延迟）
    reset2_reg <= {reset2_reg[1:0], pgd_aux_gmt};	// 复位2_reg 左移，最低位补 pgd_aux_gmt（加入辅助电源条件
  end
end

    // --------------------- 输出复位信号赋值 ---------------------
    // 主复位信号：取 reset1_reg 的最高位（经过两级同步后的复位释放信号）
    // 辅助系统信号：取 reset2_reg 的最高位（经过两级同步+辅助电源条件的信号）
assign pon_reset_n    = reset1_reg[2];
assign pgd_aux_system = reset2_reg[2];

// Generate SASD version of pgd_aux_system 生成 SASD 版本的辅助系统信号
always @(posedge clk)
begin
  if (!master_reset_n)
  begin
    pgd_aux_system_reg  <= 1'b0;
    pgd_aux_system_sasd <= 1'b0;
  end
  else
  begin
    pgd_aux_system_reg  <= pgd_aux_system;			// 同步 pgd_aux_system
    pgd_aux_system_sasd <= pgd_aux_system_reg;		// 再延迟一拍，生成 sasd 版本
  end
end

// Generate done_booting_delayed qualified version of pon_reset_n 生成延迟的上电复位信号
always @(posedge clk or negedge pon_reset_n)
begin
  if (!pon_reset_n)	// 主复位有效时，置低延迟复位信号
    pon_reset_db_n <= 1'b0;
  else if (done_booting_delayed)	// FPGA 启动完成（延迟版）后，释放延迟复位
    pon_reset_db_n <= 1'b1;
	 // 注：若 done_booting_delayed 为低，pon_reset_db_n 保持原状态（隐含锁存）
end

// Drive cpld_ready low when FPGA is done booting
    // --------------------- 生成 CPLD 就绪信号 ---------------------
    // FPGA 启动完成（done_booting 高）时，cpld_ready 为低（表示 CPLD 可工作）
assign cpld_ready = ~done_booting;

endmodule
