/* =============================================================================================================
模块功能
s2p_master 是一个 串行转并行（Serial-to-Parallel）转换器，用于将串行输入信号转换为并行输出信号。模块的主要功能包括：

接收串行数据输入（si），并通过时钟信号（sclk）采样数据。
将采样的串行数据存储到内部寄存器中，最终输出为并行数据（po）。
提供一个加载信号（sld_n），指示并行数据是否有效。
===============================================================================================================*/
module s2p_master #(parameter NBIT = 64) (
  input                 clk,       // 时钟信号
  input                 rst,       // 复位信号，高电平有效
  input                 tick,      // 数据采样触发信号
  input                 si,        // 串行数据输入
  output reg [NBIT-1:0] po,        // 并行数据输出
  output reg            sld_n,     // 数据加载信号，低电平有效
  output reg            sclk       // 串行时钟信号
);

// 并行信号位宽
function integer clogb2(
  input integer value
);
  integer tmp;
  begin
    tmp = value - 1;
    for (clogb2=0; tmp>0; clogb2=clogb2+1)
      tmp = tmp>>1;

    clogb2 = (clogb2 < 1) ? 1 : clogb2;
  end
endfunction

localparam WCNT = clogb2(NBIT*2);

reg      [2:0] tick_r;          // 用于检测 `tick` 信号的上升沿
wire           tick_pp;         // `tick` 信号的上升沿检测信号
reg            sclk_r;          // 用于检测 `sclk` 信号的上升沿
wire           sclk_pp;         // `sclk` 信号的上升沿检测信号
reg            sclk_pp_r;       // `sclk_pp` 的寄存器延迟
reg      [1:0] si_r;            // 串行数据输入的寄存器，用于同步和延迟
reg [NBIT-1:0] po_r;            // 并行数据的中间寄存器
reg [WCNT-1:0] cnt;             // 计数器，用于控制数据采样和时钟生成

// tick信号的上升沿检测
always@(posedge clk or posedge rst)
begin
  if (rst)
    tick_r <= 3'b00;
  else
    tick_r <= {tick_r[1:0], tick};
end

assign tick_pp = (tick_r[2:1] == 2'b01) ? 1'b1 : 1'b0;

// 串行数据输入打拍
always@(posedge clk or posedge rst)
begin
  if (rst) 
    si_r   <= 2'b00;
  else 
    si_r   <= {si_r[0], si};
end

// 计数器逻辑：更新计数器值
always @(posedge clk or posedge rst) begin
    if (rst)
        cnt <= {WCNT{1'b0}}; // 复位时将计数器清零
    else if (tick_pp) begin
        if (cnt == NBIT * 2 - 1)
            cnt <= {WCNT{1'b0}}; // 计数器达到最大值时清零
        else
            cnt <= cnt + 1'b1; // 否则计数器加 1
    end
end

// 串行时钟信号生成逻辑
always @(posedge clk or posedge rst) begin
    if (rst)
        sclk <= 1'b0; // 复位时将串行时钟信号清零
    else
        sclk <= cnt[0]; // 根据计数器的最低位生成串行时钟信号
end

// 串行时钟sclk信号上升沿检测
always@(posedge clk or posedge rst)
begin
  if (rst) 
    sclk_r <= 1'b0;
  else 
    sclk_r <= sclk;
end

assign sclk_pp = ({sclk_r, sclk} == 2'b01) ? 1'b1 : 1'b0;

// 串行数据采样
always@(posedge clk or posedge rst)
begin
  if (rst)
    po_r <= {NBIT{1'b0}};
  else if (sclk_pp)
    po_r[(cnt >> 1)] <= si_r[1];
end

// 数据加载信号生成逻辑
always @(posedge clk or posedge rst) begin
    if (rst)
        sld_n <= 1'b1; // 复位时将加载信号置为高电平（无效）
    else
        sld_n <= ((cnt == {WCNT{1'b0}}) || (cnt == {{(WCNT-1){1'b0}}, 1'b1})) ? 1'b0 : 1'b1; // 在计数器为 0 或 1 时，加载信号为低电平（有效），否则为高电平
end

// 并行数据输出
always@(posedge clk or posedge rst)
begin
  if (rst)
    sclk_pp_r <= 1'b0;
  else
    sclk_pp_r <= sclk_pp;
end

always@(posedge clk or posedge rst)
begin
  if (rst)
    po <= {NBIT{1'b0}};
  else if (sclk_pp_r && (cnt == NBIT*2-1))
    po <= po_r;
end
endmodule
