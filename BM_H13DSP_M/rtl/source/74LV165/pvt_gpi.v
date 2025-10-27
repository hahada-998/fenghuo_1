
/* =============================================================================================================
模块功能：
高效的串行转并行数据转换模块，支持灵活的参数配置和控制信号生成。它适用于需要串行数据采集、并行数据输出和时钟控制的场景。
1、外部串行数据采集, 收时钟使能clk_ena和串行加载控制信号serclk_in、parload_in_n控制, 位索引受bit_idx_in控制
2、并行数据输出par_data, 并且输出穿行时钟、位索引、并行加载控制信号
===============================================================================================================*/
module #(
      parameter TOTAL_BIT_COUNT        = 64                 ,// 总位数
      parameter DEFAULT_STATE          = 64'h0              ,// 默认状态
      parameter SEGMENT_MAX            = TOTAL_BIT_COUNT-1  ,// 位段最大值
      parameter SEGMENT_MIN            = 0                  ,// 位段最小值
      parameter NUMBER_OF_COUNTER_BITS = 6                   // 计数器位宽
)(
      input  wire                               clk,              // 主时钟信号（典型为 100MHz）
      input  wire                               reset_n,          // 异步复位信号，低电平有效
      input  wire                               clk_ena,          // 时钟使能信号
      input  wire                               serclk_in,        // 外部设备提供的串行时钟信号
      input  wire                               par_load_in_n,    // 外部设备提供的并行加载信号，低电平有效
      input  wire                               sdi,              // 串行数据输入信号
      input  wire [NUMBER_OF_COUNTER_BITS-1:0]  bit_idx_in,       // 位索引输入信号

      output reg [NUMBER_OF_COUNTER_BITS-1:0]   bit_idx_out,      // 位索引输出信号
      output reg [SEGMENT_MAX:SEGMENT_MIN]      par_data,         // 并行数据输出信号
      output reg                                serclk_out,       // 自由运行的串行时钟输出信号
      output reg                                par_load_out_n    // 并行加载控制信号输出，低电平有效
);

// 门控时钟使能信号
wire gated_clk_ena;
assign gated_clk_ena = clk_ena & ~serclk_in & par_load_in_n;

// 并行数据更新逻辑
always @(posedge clk or negedge reset_n) begin
      if(!reset_n)
            par_data <= DEFAULT_STATE; // 复位时，将并行数据初始化为默认状态
      else if((bit_idx_in >= SEGMENT_MIN) && (bit_idx_in <= SEGMENT_MAX) && gated_clk_ena) 
            par_data[bit_idx_in] <= sdi; // 更新指定索引的并行数据位
      else 
            par_data <= par_data; // 保持并行数据不变
end

// 串行时钟生成逻辑
always @(posedge clk or negedge reset_n)begin
      if(!reset_n)
            serclk_out <= 1'b0; 
      else if(clk_ena)
            serclk_out <= ~serclk_out;
end

// 位索引计数器更新逻辑
always @(posedge clk or negedge reset_n) begin
      if(!reset_n)
            bit_idx_out <= {NUMBER_OF_COUNTER_BITS{1'b0}}; 
      else if(clk_ena && !serclk_out && par_load_in_n) begin
            if(bit_idx_out == TOTAL_BIT_COUNT-1)
                  bit_idx_out <= {NUMBER_OF_COUNTER_BITS{1'b0}}; // 计数器达到最大值时复位
            else 
                  bit_idx_out <= bit_idx_out + {{NUMBER_OF_COUNTER_BITS-1{1'b0}}, 1'b1}; // 计数器递增
      end
end

// 并行加载控制信号生成逻辑
always @(posedge clk or negedge reset_n)begin
      if (!reset_n)
            par_load_out_n <= 1'b0; 
      else if(clk_ena && serclk_out && par_load_in_n)begin
            if (bit_idx_out == {NUMBER_OF_COUNTER_BITS{1'b0}})
                  par_load_out_n <= 1'b0; // 当位索引为 0 时，拉低加载信号
      end
      else if(clk_ena && serclk_out && !par_load_in_n)begin
            par_load_out_n <= 1'b1; // 当加载信号为低时，拉高加载信号
      end 
end
endmodule
