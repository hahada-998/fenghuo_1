/* =============================================================================================================
模块功能
sn74hc595 模块是一个基于 74HC595 芯片的移位寄存器控制模块。74HC595 是一个 8 位串行输入、并行输出的移位寄存器，常用于扩展 GPIO 或驱动 LED。

该模块的主要功能是：

移位时钟生成：生成移位寄存器的时钟信号（o_shift_clk），用于控制数据的移位。
存储时钟生成：生成存储寄存器的时钟信号（o_storage_clk），用于将移位寄存器的数据锁存到输出寄存器。
串行数据输出：根据输入数据（iv_data），通过串行方式将数据移位输出到 74HC595。
===============================================================================================================*/

module sn74hc595(
  input i_clk					, // 输入时钟信号
  input i_rst					, // 输入复位信号，高电平有效
  input i_t1us			    	, // 1us 时钟信号，用于控制移位时钟频率
  
  input [47:0] iv_data			, // 48 位输入数据，用于串行移位输出
  
  output reg o_shift_clk		, // 输出移位时钟信号
  output reg o_storage_clk		, // 输出存储时钟信号
  output reg o_seiral_data 	      // 输出串行数据
);

reg [5:0] data_out_cnt;      // 数据输出计数器，用于控制移位和存储时钟

////////////////////////////////////////////////////////////////////////////////
//                   register shift clock output logic                        //
//                   生成移位寄存器的时钟信号                                 //
////////////////////////////////////////////////////////////////////////////////
always @(posedge i_clk or posedge i_rst)
begin
    if (i_rst) begin
        o_shift_clk <= 1'b0; // 复位时，移位时钟信号置低
    end else begin
        // 移位时钟频率为 500KHz
        o_shift_clk <= (i_t1us ? (~o_shift_clk) : o_shift_clk);  
    end
end

////////////////////////////////////////////////////////////////////////////////
//                             counter logic                                  //
//                             数据输出计数器                                 //
////////////////////////////////////////////////////////////////////////////////
always @(negedge o_shift_clk or posedge i_rst)
begin
    if (i_rst) begin
        data_out_cnt <= 6'b000000; // 复位时，计数器清零
    end else if (data_out_cnt < 49) begin
        data_out_cnt <= data_out_cnt + 1'b1; // 每个移位时钟下降沿，计数器加 1
    end else begin
        data_out_cnt <= 6'b000000; // 当计数器达到 49 时，清零
    end
end

////////////////////////////////////////////////////////////////////////////////
//                   register storage clock output logic                      //
//                   生成存储寄存器的时钟信号                                 //
////////////////////////////////////////////////////////////////////////////////
always @(negedge o_shift_clk or posedge i_rst)
begin
    if (i_rst) begin
        o_storage_clk <= 1'b0; // 复位时，存储时钟信号置低
        o_seiral_data <= 1'b1; // 复位时，串行数据输出置高
    end else if (data_out_cnt < 48) begin
        // 当计数器小于 48 时，输出移位数据
        o_storage_clk <= 1'b0;  
        o_seiral_data <= iv_data[47 - data_out_cnt]; // 从高位到低位依次输出数据
    end else begin
        // 当计数器达到 48 时，存储时钟信号置高，锁存数据
        o_storage_clk <= 1'b1;
        o_seiral_data <= o_seiral_data; // 保持当前串行数据输出
    end
end

////////////////////////////////////////////////////////////////////////////////
//                        seiral data output logic                            //
////////////////////////////////////////////////////////////////////////////////


//always @(negedge o_shift_clk or posedge i_rst)
//begin
//    if(i_rst)
//		o_seiral_data <= 1'b1;
//	else
//	begin
//	    //shift seiral data out at negedge of o_shift_clk
//	    if(data_out_cnt<8)
//	        o_seiral_data <= iv_data[7-data_out_cnt];
//	    else
//	        o_seiral_data <= o_seiral_data;
//	end
//end

endmodule