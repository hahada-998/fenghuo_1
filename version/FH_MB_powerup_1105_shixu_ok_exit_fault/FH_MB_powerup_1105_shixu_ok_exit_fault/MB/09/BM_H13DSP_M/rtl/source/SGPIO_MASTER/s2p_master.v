//=================================================================================================--
// Copyright(c) 2021, CLOUDNINEINFO.CO, Ltd, All right reserved
// Filename   : AIS03MB03.v
// Project    : CLOUDNINEINFO common code
// Author     : liuqi
// Date       : 2020-09-24
// Email      : liuqic@cloudnineinfo.com
// Company    : CLOUDNINEINFO.CO., Ltd
//
//--------------------------------------------------------------------------------------
//Description :
//
//Modification History:
//Date              By              Revision                Change Description

/******************************************************************************************/

module s2p_master #(parameter NBIT = 64) ( //参数1：并行数据位宽（默认64位，实例化时可修改）
  input                 clk  ,
  input                 rst  ,
  input                 tick ,
  input                 si   ,	//串行数据输入（逐位传输）
  output reg [NBIT-1:0] po   ,	//并行数据输出（NBIT位宽）
  output       reg         sld_n,
  output       reg         sclk
) /* synthesis syn_preserve=1 */;

//定义函数clogb2：计算“大于等于value的最小2的幂次对应的位数”即log2向上取整
function integer clogb2(
  input integer value
);

  integer tmp;//临时变量，，存储value-1（用于避免value=0的情况）
  begin
    tmp = value - 1;
    for (clogb2=0; tmp>0; clogb2=clogb2+1)//log2 循环计算：通过右移逐步缩小tmp，直到tmp=0，记录右移次数（即位数)
      tmp = tmp>>1;//右移1位，等价于tmp=tmp/2

    clogb2 = (clogb2 < 1) ? 1 : clogb2;//set minimum = 1 确保最小位数为1（避免value=1时返回0位）
  end

endfunction

localparam WCNT = clogb2(NBIT*2); //定义本地参数WCNT：计数器位宽（由clogb2函数计算，不可修改）

  reg      [2:0] tick_r   ;
  wire           tick_pp  ;
  
  reg            sclk_r   ;
  wire           sclk_pp  ;
  reg            sclk_pp_r;
  
  reg      [1:0] si_r     ;
  reg [NBIT-1:0] po_r     ;	//并行数据寄存器：逐位存储串行数据
  reg [WCNT-1:0] cnt;

  always@(posedge clk or posedge rst)
  begin
    if (rst)
      tick_r <= 3'b00;
    else
      tick_r <= {tick_r[1:0],tick};
  end

   
  assign tick_pp = (tick_r[2:1] == 2'b01) ? 1'b1 : 1'b0;

  always@(posedge clk or posedge rst)
  begin
    if (rst) begin
      si_r   <= 2'b00;
      sclk_r <= 1'b0;
    end
    else begin
      si_r   <= {si_r[0], si};
      sclk_r <= sclk;
    end
  end

  assign sclk_pp = ({sclk_r, sclk}==2'b01) ? 1'b1 : 1'b0;

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
        cnt <= {WCNT{1'b0}};
      else if (tick_pp)begin
        if (cnt==NBIT*2-1)
          cnt <= {WCNT{1'b0}};
        else
          cnt <= cnt + 1'b1;
      end
	  else 
	   begin
	   sclk  <= cnt[0];
       sld_n <= ((cnt == {WCNT{1'b0}}) || (cnt == {{(WCNT-1){1'b0}},1'b1}))? 1'b0 : 1'b1;
	   end
  end

/**
  assign sclk  = cnt[0];
  assign sld_n = ((cnt == {WCNT{1'b0}}) || (cnt == {{(WCNT-1){1'b0}},1'b1}))? 1'b0 : 1'b1;
**/
//移位寄存器：存储串行数据
  always@(posedge clk or posedge rst)
  begin
    if (rst)
      po_r <= {NBIT{1'b0}};
    else if (sclk_pp)	//sclk上升沿：将串行数据存入po_r的当前位
      po_r[(cnt>>1)] <= si_r[1];	//si_r[1]是同步后的串行数据，cnt是当前存储的位地址
  end
//并行输出：锁存最终数据
  always@(posedge clk or posedge rst)
  begin
    if(rst)
      po <= {NBIT{1'b0}};
    else if (sclk_pp_r && (cnt==NBIT*2-1))//接受所有位ie，锁存输出
      po <= po_r;//将po_r中存储的并行数据赋值给po，对外输出
  end

endmodule
