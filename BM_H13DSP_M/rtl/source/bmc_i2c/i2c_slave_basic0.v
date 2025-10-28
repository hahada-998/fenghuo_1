/* =============================================================================================================
模块功能
是一个 I2C 从设备模块，主要实现 I2C 协议的基本功能，包括：

I2C 通信协议支持：
识别起始条件（START）和停止条件（STOP）
处理主设备发送的从设备地址
支持读写操作

数据传输：
接收主设备发送的数据
根据主设备的读请求发送数据

超时复位：
如果通信超时（例如 35ms 内无有效操作），模块会自动复位
===============================================================================================================*/
`timescale 1ns/1ps
module i2c_slave_basic0 #(
    parameter TOTAL_STAGES = 3, // 去毛刺滤波器的采样阶段数
    parameter DLY_LEN = 8       // 延迟长度，24.18MHz 时钟对应 330ns
)(
    // 通用端口
    input  wire             i_clk,                // 系统时钟信号
    input  wire             i_rst_n,              // 全局复位信号，低电平有效
    input  wire             i_1ms_clk,            // 1ms 时钟信号，用于超时计数
    input  wire [7:0]       i_data_in,            // 并行数据输入，用于写操作
    input  wire             i_addr_hit,           // 地址匹配信号，高电平表示匹配成功
    output reg [6:0]        o_I2C_ADDR_OUT,       // 匹配的 I2C 地址输出
    output reg [7:0]        o_data_out,           // 并行数据输出，用于读操作
    output wire             o_R_W,                // 读写信号，高电平表示读操作
    output reg              o_data_vld,           // 数据有效信号，高电平表示数据有效
    output wire             o_start,              // I2C 起始条件信号
    output wire             o_stop,               // I2C 停止条件信号

    // I2C 信号
    input wire i_scl,              // I2C 时钟信号
    inout wire io_sda              // I2C 数据线（双向）
);

//////////////////////////////////////////////////////////////////////////////////
// VariableS Declaration
//////////////////////////////////////////////////////////////////////////////////
wire w_scl_in;   // 去毛刺后的 SCL 信号
wire w_sda_in;   // 去毛刺后的 SDA 信号
reg  r_sda_en;   // SDA 输出使能信号

reg  r_sda_data; // SDA 输出数据
reg  r_I2C_RW;   // I2C 读写信号，高电平表示读操作，低电平表示写操作
reg  r_start;    // I2C 起始条件信号
reg  r_stop;     // I2C 停止条件信号

wire w_rst;      // 复位信号
wire w_scl;      // 原始 SCL 信号
wire w_sda;      // 原始 SDA 信号

// SCL 去毛刺滤波器相关信号
reg  r_glitchlessSignal_scl_d;               // SCL 去毛刺滤波器的组合逻辑信号
reg  r_glitchlessSignal_scl_q;               // SCL 去毛刺滤波器的寄存器信号
reg  [TOTAL_STAGES-1:0] r_sampledData_scl_d; // SCL 采样数据（组合逻辑）
reg  [TOTAL_STAGES-1:0] r_sampledData_scl_q; // SCL 采样数据（寄存器）

// SDA 去毛刺滤波器相关信号
reg  r_glitchlessSignal_sda_d;               // SDA 去毛刺滤波器的组合逻辑信号
reg  r_glitchlessSignal_sda_q;               // SDA 去毛刺滤波器的寄存器信号
reg  [TOTAL_STAGES-1:0] r_sampledData_sda_d; // SDA 采样数据（组合逻辑）
reg  [TOTAL_STAGES-1:0] r_sampledData_sda_q; // SDA 采样数据（寄存器）

reg  r_sda_0; // 延迟一级的 SDA 信号
reg  r_sda_1; // 延迟两级的 SDA 信号
wire w_sda_pos; // SDA 上升沿检测信号
wire w_sda_neg; // SDA 下降沿检测信号
reg  r_scl_0; // 延迟一级的 SCL 信号
reg  r_scl_1; // 延迟两级的 SCL 信号
wire w_scl_pos; // SCL 上升沿检测信号
wire w_scl_neg; // SCL 下降沿检测信号

reg  [6:0] r_I2c_address; // 接收的 I2C 地址
reg  [4:0] r_I2C_state;   // I2C 状态机状态

reg  [DLY_LEN-1:0] r_r1_sda_dly; // 用于延迟处理的 SDA 信号
wire w_r1_sda_dly;               // 延迟后的 SDA 信号

/////////////////////////////////
// data_in lock  2019-8-22 14:49
/////////////////////////////////
reg  r_data_in_lock;  // 数据输入锁存信号
reg  [7:0] r_data_in; // 锁存的输入数据

//===============================
// timeout reset function   i_1ms_clk
//===============================
reg  [7:0] r_timeout_cnt; // 超时计数器
reg  r_1ms_clk_0;         // 延迟一级的 1ms 时钟信号
reg  r_1ms_clk_1;         // 延迟两级的 1ms 时钟信号
wire w_1ms_clk_pos;       // 1ms 时钟的上升沿检测信号
reg  r_timeout_rst_n;     // 超时复位信号

// 采样复位信号; 原始 SCL 信号; 原始 SDA 信号
assign w_rst     = ~(i_rst_n & r_timeout_rst_n); 
assign w_scl     = i_scl                       ; 
assign w_sda     = io_sda                      ; 

// 移位寄存器采样信号, 使其稳定输出
always @(posedge i_clk or posedge w_rst)
begin
    if(w_rst)                                                    
    begin
        r_glitchlessSignal_scl_q <=      0;                           
        r_sampledData_scl_q      <=      {TOTAL_STAGES{w_scl}};    
    end
    else
    begin
        r_glitchlessSignal_scl_q <=      r_glitchlessSignal_scl_d;
        r_sampledData_scl_q     <=      r_sampledData_scl_d;
    end
end

always @*
begin
    r_sampledData_scl_d         =    {r_sampledData_scl_q[(TOTAL_STAGES-2):0],w_scl};
    r_glitchlessSignal_scl_d     =    r_glitchlessSignal_scl_q;
    if(~|r_sampledData_scl_q)
    begin
        r_glitchlessSignal_scl_d =   0;
    end
    if(&r_sampledData_scl_q)
    begin
        r_glitchlessSignal_scl_d =   1;
    end
end

always @(posedge i_clk or posedge w_rst)
begin
    if(w_rst)                                                    
    begin
        r_glitchlessSignal_sda_q  <= 0;                           
        r_sampledData_sda_q      <= {TOTAL_STAGES{w_sda}};    
    end
    else
    begin
        r_glitchlessSignal_sda_q  <= r_glitchlessSignal_sda_d;
        r_sampledData_sda_q      <= r_sampledData_sda_d;
    end
end

always @*
begin
    r_sampledData_sda_d         =    {r_sampledData_sda_q[(TOTAL_STAGES-2):0],w_sda};
    r_glitchlessSignal_sda_d     =    r_glitchlessSignal_sda_q;
    if(~|r_sampledData_sda_q)
    begin
        r_glitchlessSignal_sda_d =   0;
    end
    if(&r_sampledData_sda_q)
    begin
        r_glitchlessSignal_sda_d =   1;
    end
end

// 采样稳定信号 SCL 和 SDA
assign w_scl_in  = r_glitchlessSignal_scl_q;    
assign w_sda_in  = r_glitchlessSignal_sda_q; 

// 采样稳定信号 SCL 和 SDA打拍
always @ (posedge i_clk or posedge w_rst)	           		
begin
    if (w_rst)
    begin
        r_scl_0 <= 1'b0;
        r_scl_1 <= 1'b0;
    end
    else
    begin
        r_scl_0 <= w_scl_in;
        r_scl_1 <= r_scl_0;
    end
end

always @ (posedge i_clk or posedge w_rst)	            			
begin
    if (w_rst)
    begin
        r_sda_0 <= 1'b0;
        r_sda_1 <= 1'b0;
    end
    else
    begin
        r_sda_0 <= w_sda_in;
        r_sda_1 <= r_sda_0;
    end
end

// 采样稳定信号 SCL 和 SDA 边沿检测
assign w_scl_pos = ~r_scl_0 & w_scl_in;
assign w_scl_neg = r_scl_0 & ~w_scl_in;
assign w_sda_pos = !r_sda_0 & w_sda_in;   
assign w_sda_neg = r_sda_0 & !w_sda_in;

// START 和 STOP 条件检测; 
// START: SDA 由高到低且 SCL 为高; STOP: SDA 由低到高且 SCL 为高
always @ (posedge i_clk or posedge w_rst)	               			
begin
    if (w_rst)
    begin
        r_start     <= 1'b0;
        r_stop      <= 1'b0;
    end
    else
    begin
        r_start     <= 1'b0;
        r_stop      <= 1'b0;
        if (w_scl_in & w_sda_pos)
		begin
            r_stop  <= 1'b1;
            r_start <= 1'b0;
        end

        if (w_scl_in & w_sda_neg)
        begin
            r_stop  <= 1'b0;
            r_start <= 1'b1;
        end
    end
end

assign o_start   = r_start;
assign o_stop    = r_stop;

// SDA数据延迟打拍, 延时8拍用ACK判断是否继续读数据
always @ (posedge i_clk or posedge w_rst)	              
begin
    if (w_rst)
        r_r1_sda_dly <= {DLY_LEN{1'b1}};
    else 
        r_r1_sda_dly <= {r_r1_sda_dly[DLY_LEN-2:0],r_sda_1};
end
assign w_r1_sda_dly = r_r1_sda_dly[DLY_LEN-1];

/* -------------------------------------------------------------------------------------------------------------
 I2C从设备模块的核心逻辑, 主要状态如下：
5'h00       ：空闲状态
5'h13       ：起始条件检测
5'h01~5'h08 ：接收从设备地址
5'h09       ：地址匹配后发送 ACK 或 NACK
5'h0A~5'h12 ：数据传输（读或写）
---------------------------------------------------------------------------------------------------------------*/
// 状态机控制 r_I2C_state
always @(posedge i_clk or posedge w_rst)
begin
    if (w_rst)
        r_I2C_state <= 5'b00; // 复位到空闲状态
    else if (r_start)
        r_I2C_state <= 5'h13; // 检测到起始条件
    else if (r_stop)
        r_I2C_state <= 5'h00; // 检测到停止条件
    else
        case (r_I2C_state)
            5'h00: if (r_start  ) r_I2C_state <= 5'h13;
            5'h13: if (w_scl_neg) r_I2C_state <= 5'h01;
            5'h01: if (w_scl_neg) r_I2C_state <= 5'h02;
            5'h02: if (w_scl_neg) r_I2C_state <= 5'h03;
            5'h03: if (w_scl_neg) r_I2C_state <= 5'h04;
            5'h04: if (w_scl_neg) r_I2C_state <= 5'h05;
            5'h05: if (w_scl_neg) r_I2C_state <= 5'h06;
            5'h06: if (w_scl_neg) r_I2C_state <= 5'h07;
            5'h07: if (w_scl_neg) r_I2C_state <= 5'h08;
            5'h08: if (w_scl_neg) r_I2C_state <= 5'h09;
            5'h09: if (w_scl_neg) r_I2C_state <= (i_addr_hit ? 5'h0A : 5'h00); // 地址匹配成功进入数据传输状态，否则返回空闲状态
            5'h0A: if (w_scl_neg) r_I2C_state <= 5'h0B;
            5'h0B: if (w_scl_neg) r_I2C_state <= 5'h0C;
            5'h0C: if (w_scl_neg) r_I2C_state <= 5'h0D;
            5'h0D: if (w_scl_neg) r_I2C_state <= 5'h0E;
            5'h0E: if (w_scl_neg) r_I2C_state <= 5'h0F;
            5'h0F: if (w_scl_neg) r_I2C_state <= 5'h10;
            5'h10: if (w_scl_neg) r_I2C_state <= 5'h11;
            5'h11: if (w_scl_neg) r_I2C_state <= 5'h12;
            5'h12: if (w_scl_neg) r_I2C_state <= (r_I2C_RW && w_r1_sda_dly ? 5'h12 : 5'h0A); // 读操作且主机发送 ACK 则继续读，否则返回数据接收状态
            default: r_I2C_state <= 5'h00;
        endcase
end

// 读写信号 r_I2C_RW
always @(posedge i_clk or posedge w_rst)
begin
    if (w_rst)
        r_I2C_RW <= 1'b0; // 复位时默认为写操作
    else if (r_I2C_state == 5'h08 && w_scl_neg)
        r_I2C_RW <= w_r1_sda_dly; // 接收读写信号
end

// 控制 SDA 输出使能信号 r_sda_en
always @(posedge i_clk or posedge w_rst)
begin
    if (w_rst)
        r_sda_en <= 1'b0; // 复位时禁用 SDA 输出
    else
        case (r_I2C_state)
            5'h09: r_sda_en <= i_addr_hit; // 地址匹配时使能 ACK
            5'h0A: r_sda_en <= r_I2C_RW  ; // 读操作时使能 SDA 输出
            5'h12: r_sda_en <= ~r_I2C_RW ; // 写操作时发送 ACK
            default: r_sda_en <= 1'b0;     // 其他状态禁用 SDA 输出
        endcase
end

// 锁存输入数据 r_data_in
always @ (posedge i_clk or posedge w_rst)	               			
begin
    if (w_rst)
        r_data_in <= 8'hff;
    else if (r_data_in_lock)
        r_data_in <= r_data_in;			
    else 
        r_data_in <= i_data_in;
end

// 控制 SDA 输出数据 r_sda_data
always @(posedge i_clk or posedge w_rst)
begin
    if (w_rst)
        r_sda_data <= 1'b0; // 复位时清空 SDA 数据
    else
        case (r_I2C_state)
            5'h09: r_sda_data <= ~i_addr_hit ; // 地址匹配时发送 ACK，否则发送 NACK
            5'h0A: r_sda_data <= r_data_in[7]; // 读操作发送最高位数据
            5'h0B: r_sda_data <= r_data_in[6];
            5'h0C: r_sda_data <= r_data_in[5];
            5'h0D: r_sda_data <= r_data_in[4];
            5'h0E: r_sda_data <= r_data_in[3];
            5'h0F: r_sda_data <= r_data_in[2];
            5'h10: r_sda_data <= r_data_in[1];
            5'h11: r_sda_data <= r_data_in[0]; // 读操作发送最低位数据
            5'h12: r_sda_data <= 1'b0        ; // 写操作发送 ACK
            default: r_sda_data <= 1'b0;
        endcase
end

// 写数据完成输出有效信号 o_data_vld
always @(posedge i_clk or posedge w_rst)
begin
    if (w_rst)
        o_data_vld <= 1'b0; // 复位时数据无效
    else if (r_I2C_state == 5'h12 && w_scl_neg)
        o_data_vld <= 1'b1; // 数据接收完成时置高
    else if (w_scl_pos)
        o_data_vld <= 1'b0; // 数据有效信号清零
end

// 数据输出 o_data_out
always @(posedge i_clk or posedge w_rst)
begin
    if (w_rst)
        o_data_out <= 8'b0; // 复位时清空数据输出
    else if (r_I2C_state >= 5'h0A && r_I2C_state <= 5'h11 && w_scl_neg)
        o_data_out[11 - r_I2C_state] <= w_r1_sda_dly; // 接收数据位
end

// 数据输入锁存信号 r_data_in_lock
always @(posedge i_clk or posedge w_rst)
begin
    if (w_rst)
        r_data_in_lock <= 1'b0; // 复位时解锁数据输入
    else if (r_I2C_state == 5'h0A)
        r_data_in_lock <= 1'b1; // 锁存数据输入
    else if (r_I2C_state == 5'h12)
        r_data_in_lock <= 1'b0; // 解锁数据输入
end


// 控制 I2C 数据线 SDA 的输出
assign io_sda = r_sda_en ? r_sda_data : 1'bz; // 当 r_sda_en 为高时，输出 r_sda_data，否则保持高阻态
assign o_R_W = r_I2C_RW; // 输出当前的读写信号，高电平表示读操作，低电平表示写操作

// 检测 1ms 时钟的上升沿
assign w_1ms_clk_pos = (~r_1ms_clk_0) & r_1ms_clk_1; // 通过延迟一级和两级的时钟信号检测上升沿

// 输出匹配的 I2C 地址
always @ (posedge i_clk or posedge w_rst)
begin
    if (w_rst)
        o_I2C_ADDR_OUT <= 7'h0; // 复位时清空地址输出
    else if (r_I2C_state == 5'h00)
        o_I2C_ADDR_OUT <= 7'h0; // 空闲状态时清空地址输出
    else if (r_I2C_state == 5'h08)
        o_I2C_ADDR_OUT <= r_I2c_address; // 地址接收完成后输出匹配的 I2C 地址
end

// I2C_slave 超时复位使用, 35ms超时
always@(posedge i_clk or negedge i_rst_n)
begin
    if(~i_rst_n)
    begin
        r_1ms_clk_0 <= 1'b1;
        // r_1ms_clk_0 <= 1'b1;
        r_1ms_clk_1 <= 1'b1;    //2021-5-14 12:04
    end
    else
    begin
        r_1ms_clk_0 <= i_1ms_clk;
        // r_1ms_clk_0 <= r_1ms_clk_0;
        r_1ms_clk_1 <= r_1ms_clk_0;   //2021-5-14 12:04
    end
end

always@(posedge i_clk or negedge i_rst_n) //r_sda_1
begin
    if(~i_rst_n)
        r_timeout_cnt <= 8'd0;
    else if(r_timeout_cnt >= 8'd35 || r_sda_1)
        r_timeout_cnt <= 8'd0;
    else if(w_1ms_clk_pos && (~r_sda_1))
        r_timeout_cnt <= r_timeout_cnt + 1'b1;
    else
        r_timeout_cnt <= r_timeout_cnt;
end

always@(posedge i_clk or negedge i_rst_n)
begin
    if(~i_rst_n)
        r_timeout_rst_n <= 1'b1;
    else if(r_timeout_cnt == 8'd35)
        r_timeout_rst_n <= 1'b0;
    else
        r_timeout_rst_n <= 1'b1;
end

endmodule
