/* =============================================================================================================
模块功能：
检测输入数据变化。
生成移位操作所需的时钟信号。
将 8 位并行输入数据按位移位输出到串行信号 so。
提供复位信号控制
===============================================================================================================*/

module s2p_164 (   //#(parameter NBIT = 8)
  input                 i_clk  		, // 主时钟信号。
  input                 i_rst  		, // 复位信号，高电平有效。
  input                 tick   		, // 移位操作的触发信号。
  input                 CLK_1ms		, // 1ms 时钟信号，用于检测数据变化。
  input                 i_mr_n 		, // 复位控制信号，低电平有效。
  input  [7:0]          pi   		, // 8位并行输入数据。
  output  reg           so   		, // 串行输出信号
  output                sld_n		, // 复位信号输出，直接连接到 i_mr_n
  output  reg           o_sclk        // 移位寄存器的时钟信号输出
) /* synthesis syn_preserve=1 */;


reg [3:0] data_out_cnt;

reg [7:0] r_old_data;

reg r_data_chg_flag;

reg sclk;

// 1ms检测一次信号变化
/* 复位信号有效，记录当前数据 pi
   pi 未变化，清除数据变化标志。
   pi 发生变化，更新记录的旧数据，并设置数据变化标志。
*/
always @(posedge CLK_1ms or posedge i_rst) begin
    if(i_rst)
        r_old_data <= pi;
    else if(r_old_data == pi)
        r_old_data <= r_old_data;
    else 
        r_old_data <= pi;
end

always @(posedge CLK_1ms or posedge i_rst) begin
    if(i_rst)
        r_data_chg_flag <= 1'b1;
    else if(r_old_data == pi)
        r_data_chg_flag <= 1'b0;
    else
        r_data_chg_flag <= 1'b1;
end

// 串行时钟计数器, 用于记录当前移位的位数, 当数据变化时清零；用于生成串行时钟; 
always @(posedge sclk or posedge i_rst)
begin
    if(i_rst)
		data_out_cnt <= 4'd0;
	else if(r_data_chg_flag == 1'b1)
	    data_out_cnt <= 4'd0;
	else if(data_out_cnt < 8)
	    data_out_cnt  <= data_out_cnt + 1'b1;  
	else
	    data_out_cnt  <= 4'd8;
end

// 串行时钟生成
// sclk：在 tick 信号的上升沿翻转，频率为 tick 的一半。当数据未变化且移位完成时，sclk 保持低电平。
always @(posedge tick or posedge i_rst)
begin
    if(i_rst)
        sclk <= 1'b0;
    else if((r_data_chg_flag == 1'b0) && (data_out_cnt == 4'd8))
        sclk <= 1'b0;
    else 
        sclk <= ~sclk;  
end

// o_sclk：在 tick 信号的下降沿翻转，频率与 sclk 相同，但相位相反。
always @(negedge tick or posedge i_rst)
begin
    if(i_rst)
        o_sclk <= 1'b1;
    else 
        o_sclk <= ~sclk;  
end

// 根据计数器的值，将 pi 的每一位按顺序移位输出
always @(posedge sclk or posedge i_rst)
begin
    if(i_rst)
        so <= 1'b1;
    else if(data_out_cnt < 8)
        so <= pi[7-data_out_cnt];
    else
        so <= so;
end

// 复位信号直接连接到 i_mr_n
assign sld_n = i_mr_n ;  //2024-2-20 add for 74AHC164  MR  PIN9  default 1 ,set 0 to reset

endmodule
