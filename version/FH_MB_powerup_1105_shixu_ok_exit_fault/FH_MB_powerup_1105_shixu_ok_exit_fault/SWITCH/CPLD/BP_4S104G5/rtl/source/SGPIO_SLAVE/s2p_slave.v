//=================================================================================================--
// Copyright(c) 2021, CLOUDNINEINFO.CO, Ltd, All right reserved
// Filename   : AIS03MB03.v
// Project    : CLOUDNINEINFO common code
// Author     : dingxianhua
// Date       : 2020-09-24
// Email      : dingxianhua@cloudnineinfo.com
// Company    : CLOUDNINEINFO.CO., Ltd
//
//--------------------------------------------------------------------------------------
//Description :
//
//Modification History:
//Date              By              Revision                Change Description

/******************************************************************************************/

module s2p_slave #(parameter NBIT = 64,    //参数1：并行数据位宽（默认64位，实例化时可修改）
	                         DEFAULT_STATE = 64'h0) ( //参数2：并行输出默认值（复位输出）
  input                 clk  ,
  input                 rst  ,
  input                 si   ,  //串行数据输入（逐位传输）
  output reg [NBIT-1:0] po   ,  //并行数据输出（NBIT位宽）
  input                 sld_n,  //加载控制信号（低有效，控制设备传输启停）
  input                 sclk    //串行时钟（同步串行数据，由主设备提供）
)/* synthesis syn_preserve=1 */;

//定义函数clogb2：计算“大于等于value的最小2的幂次对应的位数”即log2向上取整
function integer clogb2(
  input integer value
);

  integer tmp;	//临时变量，，存储value-1（用于避免value=0的情况）
  begin
    tmp = value - 1;
    for (clogb2=0; tmp>0; clogb2=clogb2+1)//log2 循环计算：通过右移逐步缩小tmp，直到tmp=0，记录右移次数（即位数)
      tmp = tmp>>1;	//右移1位，等价于tmp=tmp/2

    clogb2 = (clogb2 < 1) ? 1 : clogb2;//set minimum = 1 确保最小位数为1（避免value=1时返回0位）
  end

endfunction

localparam WCNT = clogb2(NBIT);	//定义本地参数WCNT：计数器位宽（由clogb2函数计算，不可修改）

  reg      [2:0] sclk_r   ;	//sclk的3拍采样寄存器（用于检测边沿）
  reg      [1:0] sld_n_r  ;	//sld_n的2拍采样寄存器（同步+去抖）
  reg      [1:0] si_r     ; //si的2拍采样寄存器（同步串行数据）
  wire           sclk_pp  ;	//sclk上升沿标志
  reg            sclk_pp_r;	//sclk上升沿标志的1拍延迟
  wire           sclk_np  ;	//sclk下降沿标志
  reg [WCNT-1:0] cnt      ;	//计数寄存器：记录已接受的串行数据位数
  reg [NBIT-1:0] po_r     ;	//并行数据寄存器：逐位存储串行数据
//时序逻辑：每拍将输入信号打入采样寄存器（右移+新值）
  always@(posedge clk or posedge rst)
  begin
    if (rst) begin
      sclk_r  <= 3'b000;
      sld_n_r <= 2'b11;	//sld_n默认高电平（未加载）
      si_r    <= 2'b00;
    end
    else begin
      sclk_r  <= {sclk_r[1:0], sclk};	//右移操作：保留前两拍的sclk，新拍sclk存入最低位（sclk_r[0])
      sld_n_r <= {sld_n_r[0], sld_n};	//右移操作：保留前1拍的sld_n,新拍sld_n存入最低位
      si_r    <= {si_r[0], si};			//右移操作：保留前1拍的si，新拍si存入最低位
    end
  end

  assign sclk_pp = (sclk_r[2:1]==2'b01) ? 1'b1 : 1'b0;//检测sclk上升沿：前1拍为0，当前拍为1（sclk_r[2]是前2拍，sclk_r[1]是前1拍）
  assign sclk_np = (sclk_r[2:1]==2'b10) ? 1'b1 : 1'b0;//检测sclk下降沿：前1拍为1，当前拍为0

  always@(posedge clk or posedge rst)	//sclk_pp的1拍延迟：确保与数据采样时序对齐
  begin
    if (rst)
      sclk_pp_r <= 1'b0;
    else
      sclk_pp_r <= sclk_pp;
  end

  always@(posedge clk or posedge rst)
  begin
      if (rst)
        cnt <= {WCNT{1'b0}};
      else if (!sld_n_r[1])	//sld_n低电平（加载信号有效）：重置计数器
        cnt <= {WCNT{1'b0}};
      else if (sclk_np)		//sclk下降沿：计数器+1（每接收1位数据，计数+1）
        cnt <= cnt + 1'b1;
  end
//移位寄存器：存储串行数据
  always@(posedge clk or posedge rst)
  begin
    if (rst)
      po_r <= {NBIT{1'b0}};
    else if (sclk_pp)	//sclk上升沿：将串行数据存入po_r的当前位
      po_r[cnt] <= si_r[1];	//si_r[1]是同步后的串行数据，cnt是当前存储的位地址
  end
//并行输出：锁存最终数据
  always@(posedge clk or posedge rst)
  begin
    if (rst)
      po <= DEFAULT_STATE;
    else if (sclk_pp_r && (cnt==NBIT-1)) //接受所有位ie，锁存输出
      po <= po_r;	//将po_r中存储的并行数据赋值给po，对外输出
  end

endmodule
