// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
// *                   C O P Y R I G H T     N O T I C E                       *
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

// *    2021-02-26: New Created


`timescale 1ns/1ps

module i2c_slave_bmc #(
    parameter                   DLY_LEN = 3 // 延迟长度，24.18MHz 时钟对应 330ns
)(
    // 输入信号
    input   wire                  i_rst_n,       // 全局复位信号，低电平有效
    input   wire                  i_clk,         // 系统时钟信号
    input   wire                  i_1ms_clk,     // 1ms 时钟信号，用于超时逻辑
    input   wire                  i_rst_i2c_n,   // I2C 专用复位信号
    input   wire                  i_scl,         // I2C 时钟信号
    inout   wire                  io_sda,        // I2C 数据线（双向）
    input   wire [6:0]            i_i2c_address, // 从设备地址
    input   wire [7:0]            i_i2c_data_in, // 主设备写入的并行数据

    // 输出信号
    output  wire                  o_i2c_start,    // I2C 起始条件信号
    output  wire                  o_WR,           // 读写信号，高电平表示读操作
    output  wire                  o_data_vld_pos, // 数据有效信号的上升沿
    output  wire [15:0]           o_i2c_command,  // I2C 命令
    output  wire [7:0]            o_i2c_data_out  // 从设备输出的数据
);
      
wire w_start;               		// I2C 起始条件信号
wire w_stop;                		// I2C 停止条件信号
wire [7:0] w_i2c_data_out;  		// 从设备输出的数据
wire w_R_W;                 		// 读写信号，高电平表示读操作
wire w_data_vld;            		// 数据有效信号，高电平表示数据有效
wire w_data_vld_pos;        		// 数据有效信号的上升沿
wire [6:0] w_i2c_addr_out;  		// 输出的 I2C 地址
wire [15:0] w_i2c_command;  		// I2C 命令

reg [7:0] r_i2c_data_in;            // 从设备接收的数据
reg r_data_vld1;                    // 数据有效信号的一级延迟
reg r_data_vld2;                    // 数据有效信号的二级延迟
reg r_addr_hit;                     // 地址匹配信号，高电平表示匹配成功
reg [15:0] r_i2c_command_temp;      // 临时存储的 I2C 命令
reg [15:0] r_i2c_command;           // 最终的 I2C 命令
reg [15:0] r_read_byte_cnt;         // 读字节计数器
reg [15:0] r_write_byte_cnt;        // 写字节计数器

// I2C从设备地址匹配逻辑
always @(posedge i_clk or negedge i_rst_n) begin
    if (~i_rst_n ) 
        r_addr_hit <= 'b0;    
    else if (w_i2c_addr_out == i_i2c_address)        
        r_addr_hit <= 1'b1;
    else
        r_addr_hit <= 1'b0;   
end  

// -------------------------------------------------------------------------------------------------------------
// 实例化 i2c_slave_basic0 模块，作为 I2C 从设备的核心逻辑模块
// -------------------------------------------------------------------------------------------------------------
i2c_slave_basic0 #(
    .TOTAL_STAGES       (3),                // 去毛刺滤波器的采样阶段数
    .DLY_LEN            (DLY_LEN)           // 延迟长度，24.18MHz 时钟对应 330ns
)i2c_slave_basic0_u0(      
    .i_rst_n            (i_rst_n & i_rst_i2c_n), // 全局复位信号，结合 I2C 专用复位信号
    .i_clk              (i_clk),                // 系统时钟信号
    .i_1ms_clk          (i_1ms_clk),            // 1ms 时钟信号，用于超时逻辑
    .i_data_in          (r_i2c_data_in),        // 并行数据输入
    .i_addr_hit         (r_addr_hit),           // 地址匹配信号，高电平表示匹配成功
    .o_I2C_ADDR_OUT     (w_i2c_addr_out),       // 输出的 I2C 地址
    .o_data_out         (w_i2c_data_out),       // 并行数据输出
    .o_R_W              (w_R_W),                // 读写信号，高电平表示读操作
    .o_data_vld         (w_data_vld),           // 数据有效信号，高电平表示数据有效
    .o_start            (w_start),              // I2C 起始条件信号
    .o_stop             (w_stop),               // I2C 停止条件信号

    // I2C 信号
    .i_scl              (i_scl),                // I2C 时钟信号（不使用）
    .io_sda             (io_sda)                // I2C 数据线（双向）
);

// BMC读取从设备寄存器的地址
always@(posedge i_clk or negedge i_rst_n) begin
	if(~i_rst_n)
		r_i2c_data_in	<= 8'h00;
	else if ( w_R_W) begin    
		r_i2c_data_in	<= i_i2c_data_in;
	end 
	else begin
		r_i2c_data_in	<= 8'h00;
	end
end
  
// 读写数据有效信号上升沿检测
always@(posedge i_clk) begin
	r_data_vld1 <= w_data_vld;
	r_data_vld2 <= r_data_vld1;
end
assign w_data_vld_pos = ~r_data_vld2 & r_data_vld1;  

// 读数据字节计数器
always@(posedge i_clk or posedge w_start) begin
	if(w_start) 
		r_read_byte_cnt	<= 16'h0000;
	else if(w_data_vld_pos & w_R_W & r_addr_hit)
		r_read_byte_cnt  <= r_read_byte_cnt + 1;
end

// 写数据字节计数器
always@(posedge i_clk or posedge w_start) begin
	if(w_start) 
		r_write_byte_cnt  <= 16'h0000;
	else if(w_data_vld_pos & ~w_R_W & r_addr_hit)
		r_write_byte_cnt  <= r_write_byte_cnt + 1;
end

// 写命令寄存器, 高8位写地址, 低8位写数据
always@(posedge i_clk or negedge i_rst_n) begin
	if(~i_rst_n) 
		 r_i2c_command_temp		<= 16'hffff; 
	else if(w_data_vld_pos & (r_write_byte_cnt == 0) & (~w_R_W) & r_addr_hit)
		 r_i2c_command_temp[15:8]		<= w_i2c_data_out;
	else if(w_data_vld_pos & (r_write_byte_cnt == 1) & (~w_R_W) & r_addr_hit)
		 r_i2c_command_temp[7:0]		<= w_i2c_data_out;	 
end

assign w_i2c_command = ((r_write_byte_cnt == 2) & (~w_R_W) & r_addr_hit) ? r_i2c_command_temp : w_i2c_command;


// 输出读写命令; 写命令地址不便; 读命令输出当前读地址加读字节计数器
always@(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
	     r_i2c_command  <= 16'hffff;
	 end
	 else begin
	     if(!w_R_W && (r_write_byte_cnt >=2) )
		      r_i2c_command  <= w_i2c_command + r_write_byte_cnt -2;
		  else if(w_R_W && (r_read_byte_cnt >= 0))
		      r_i2c_command  <= w_i2c_command + r_read_byte_cnt;
		  else
		      r_i2c_command  <= 16'hffff;
	 end
end 
 
assign o_i2c_start    = w_start;          // 输出 I2C 起始条件信号
assign o_WR           = w_R_W;            // 输出读写信号
assign o_i2c_data_out = w_i2c_data_out;   // 输出从设备数据
assign o_data_vld_pos = w_data_vld_pos;   // 输出数据有效信号的上升沿
assign o_i2c_command  = r_i2c_command;    // 输出 I2C 命令
endmodule 