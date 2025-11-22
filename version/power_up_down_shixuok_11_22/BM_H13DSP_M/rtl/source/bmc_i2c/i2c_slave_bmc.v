// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
// *                   C O P Y R I G H T     N O T I C E                       *
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

// *    2021-02-26: New Created


`timescale 1ns/1ps

module i2c_slave_bmc #(
parameter DLY_LEN  = 3   //24.18MHz,330ns
)(
input    wire i_rst_n, 
input    wire i_clk,
input    wire i_1ms_clk,

input	 wire i_rst_i2c_n,

input    wire i_scl,
inout    wire io_sda,
input    wire [6:0] i_i2c_address,
output   wire o_i2c_start,
output   wire o_WR,
output   wire o_data_vld_pos,
output   wire [15:0] o_i2c_command,
input    wire [7:0]  i_i2c_data_in,
output   wire [7:0]  o_i2c_data_out

); 
      

//////////////////////////////////////////////////////////////
wire w_start;
wire w_stop;
wire [7:0] w_i2c_data_out;
wire w_R_W; 
wire w_data_vld;
wire w_data_vld_pos;  
wire [6:0] w_i2c_addr_out;    
wire [15:0] w_i2c_command;
//////////////////////////////////////////////////////////////
reg [7:0] r_i2c_data_in;
reg	r_data_vld1;
reg	r_data_vld2;
reg r_addr_hit;
reg [15:0] r_i2c_command_temp; 
reg [15:0] r_i2c_command;  
reg [15:0] r_read_byte_cnt;
reg [15:0] r_write_byte_cnt;
/////////////////////////////////////////////////////////////
assign o_i2c_start    = w_start;  
assign o_WR           = w_R_W;
assign o_i2c_data_out = w_i2c_data_out;
assign o_data_vld_pos = w_data_vld_pos;
assign o_i2c_command  = r_i2c_command;

//-------------------addr hit------------------------------//
// 当主机发送的地址与本从机地址一致时，r_addr_hit 置 1（从机准备响应）
always @(posedge i_clk or negedge i_rst_n) begin
    if (~i_rst_n ) 
        r_addr_hit <= 'b0;    
    else if (w_i2c_addr_out == i_i2c_address)        
        r_addr_hit <= 1'b1;
    else
        r_addr_hit <= 1'b0;   
end  
 

//----------------i2c slave instant---------------------//

i2c_slave_basic0 #(
.TOTAL_STAGES       (3),
.DLY_LEN            (DLY_LEN)            //24.18MHz,330ns
)i2c_slave_basic0_u0(      
// generic ports
.i_rst_n            (i_rst_n & i_rst_i2c_n), 		
.i_clk              (i_clk),                    // System Reset
.i_1ms_clk          (i_1ms_clk),
// 输入：从机要返回的数据（读操作）
.i_data_in          (r_i2c_data_in),          // 连接到内部暂存的返回数据
// 输入：地址匹配标志（只有匹配时才响应）
.i_addr_hit         (r_addr_hit),  

// 输出：解析结果
.o_I2C_ADDR_OUT     (w_i2c_addr_out),         // 主机发送的地址（供地址匹配检测）
.o_data_out         (w_i2c_data_out),         // 主机写入的数据（供上层处理）
.o_R_W              (w_R_W),                  // 读写标志（1=读，0=写）
.o_data_vld         (w_data_vld),             // 主机数据有效（高电平表示数据可用）
.o_start            (w_start),                 // 检测到的起始信号
.o_stop             (w_stop),                  // 检测到的停止信号
// I2C 物理线
.i_scl              (i_scl),                   // 连接外部 SCL 线
.io_sda             (io_sda)                   // 连接外部 SDA 线（双向）
);
  
 
//------------------------valid data detect-----------------//

always@(posedge i_clk) begin
  r_data_vld1 <= w_data_vld;
  r_data_vld2 <= r_data_vld1;
end
// 上升沿检测：当 r_data_vld1 为 1 且 r_data_vld2 为 0 时，表示数据刚有效
assign w_data_vld_pos    = ~r_data_vld2 & r_data_vld1;  

//---------------------read byte counter--------------------//
// 读字节计数器：跟踪主机连续读取的字节数
always@(posedge i_clk or posedge w_start) begin
	if(w_start) 
		r_read_byte_cnt	<= 16'h0000;
	else if(w_data_vld_pos & w_R_W & r_addr_hit)// 读操作（w_R_W=1）、地址匹配、数据有效上升沿：计数器+1
		r_read_byte_cnt  <= r_read_byte_cnt + 1;
end

 
//------------------- -write byte counter--------------------//
// 写字节计数器：跟踪主机连续写入的字节数
always@(posedge i_clk or posedge w_start) begin
	if(w_start) 
		 r_write_byte_cnt	<= 16'h0000;
	else if(w_data_vld_pos & ~w_R_W & r_addr_hit)// 写操作（w_R_W=0）、地址匹配、数据有效上升沿：计数器+1
		 r_write_byte_cnt  <= r_write_byte_cnt + 1;
end


//-----------------------command id-------------------------//

// 暂存 16 位寄存器地址（前两个写入字节）
always@(posedge i_clk or negedge i_rst_n) begin
	if(~i_rst_n) 
		 r_i2c_command_temp		<= 16'hffff; 
	else if(w_data_vld_pos & (r_write_byte_cnt == 0) & (~w_R_W) & r_addr_hit)// 写操作第 1 个字节：存为地址高 8 位
		 r_i2c_command_temp[15:8]		<= w_i2c_data_out;
	else if(w_data_vld_pos & (r_write_byte_cnt == 1) & (~w_R_W) & r_addr_hit)// 写操作第 2 个字节：存为地址低 8 位（组合成 16 位地址）
		 r_i2c_command_temp[7:0]		<= w_i2c_data_out;	 
end
// 生成 16 位命令地址（支持连续写时地址递增）
assign w_i2c_command = ((r_write_byte_cnt == 2) & (~w_R_W) & r_addr_hit) ? r_i2c_command_temp : w_i2c_command;


// 最终输出的命令地址（支持连续读写时自动递增）
always@(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
	     r_i2c_command  <= 16'hffff;
	 end
	 else begin
	     if(!w_R_W && (r_write_byte_cnt >=2) )// 写操作：从第 3 个字节开始，地址=起始地址+偏移（r_write_byte_cnt-2）
		      r_i2c_command  <= w_i2c_command + r_write_byte_cnt -2;
		  else if(w_R_W && (r_read_byte_cnt >= 0))// 读操作：从第 1 个字节开始，地址=起始地址+偏移（r_read_byte_cnt）
		      r_i2c_command  <= w_i2c_command + r_read_byte_cnt;
		  else
		      r_i2c_command  <= 16'hffff;
	 end
end 
 
  
 
//-------------------------------------------------------------------------



 


 
 
 
 

//-----------------------BMC READ---------------------------------------//
// 读操作时，将上层模块的寄存器数据（i_i2c_data_in）返回给主机
always@(posedge i_clk or negedge i_rst_n) begin
	if(~i_rst_n)
		 r_i2c_data_in	<= 8'h00;
	else if ( w_R_W) begin    // 读操作（w_R_W=1）时
		 r_i2c_data_in	<= i_i2c_data_in;// 传递上层寄存器数据
	end 
	else begin
		 r_i2c_data_in	<= 8'h00;// 写操作时无需返回数据
	end
end
 
 
 

endmodule 