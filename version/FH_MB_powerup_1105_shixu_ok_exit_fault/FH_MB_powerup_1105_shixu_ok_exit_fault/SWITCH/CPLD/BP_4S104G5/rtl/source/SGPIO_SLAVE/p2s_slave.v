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


module p2s_slave #(parameter NBIT = 64) ( 
  input             clk  ,
  input             rst  ,
  input  [NBIT-1:0] pi   ,	//并行数据输入（NBIT位宽，来自内部逻辑）
  output       reg     so   , //串行数据输出（逐位发送到外部设备）
  input             sld_n,	  //加载控制信号
  input             sclk 	  //串行时钟（同步发送，由外部设备提供）
)/* synthesis syn_preserve=1 */;

function integer clogb2(
  input integer value
);

  integer tmp;
  begin
    tmp = value - 1;
    for (clogb2=0; tmp>0; clogb2=clogb2+1)//log2
      tmp = tmp>>1;

    clogb2 = (clogb2 < 1) ? 1 : clogb2;//set minimum = 1
  end

endfunction

localparam WCNT = clogb2(NBIT);

  reg       [8:0] sclk_r ;	//sclk_r的9拍采样寄存器
  reg       [2:0] sld_n_r;	//sld_n的3拍采样寄存器
//wire            sclk_pp;
  wire            sclk_np;	//下降沿标志
  reg  [WCNT-1:0] cnt    ;	//计数寄存器：记录已发送的位数

  always@(posedge clk or posedge rst)
  begin
    if (rst) begin
      sclk_r  <= 9'b000000000;
      sld_n_r <= 3'b111;	//sld_n默认高电平（未加载）
    end
    else begin
      sclk_r  <= {sclk_r[7:0] , sclk };	//右移操作：保留前8拍的sclk，新拍sclk存入最低位
      sld_n_r <= {sld_n_r[1:0], sld_n};	//右移操作：保留前2拍的sld_n，新拍sld_n存入最低位
    end
  end
//增加拍数的原因：slck_r用9拍：p2s_slave需在sclk的下降沿发送数据（sclk_np），需更多拍的采样能更稳定地检测高频sclk的边沿，避免因外部时钟抖动导致的误触发
//sld_n_r用3拍：sld_n是启动发送的关键信号，多一拍可进一步过滤噪声，确保加载指令的可靠性

//  assign sclk_pp = (sclk_r[2:1]==2'b01) ? 1'b1 : 1'b0;
//  assign sclk_np = (sclk_r[4:3]==2'b10) ? 1'b1 : 1'b0;
    assign sclk_np = (sclk_r[8:7]==2'b10) ? 1'b1 : 1'b0;	//当sclk从1变为0时，sclk_r[8:7] = 2'b10,输出1个时钟周期的高电平
//s2p_slave主要检测上升沿（sclk_pp）用于采样，p2s_slave检测下降沿(slck_np)用于发送，形成接受-发送的边沿配合
always@(posedge clk or posedge rst)
  begin
    if (rst)
      cnt <= {WCNT{1'b0}};
    else if (~sld_n_r[1])	//sld_n低电平（加载有效）：启动发送
	  begin
      cnt <= 1'b1;	//初始化为1
	  so  <= pi[0];	//提前发送第0位数据（启动时立即输出）
	  end
    else if (sclk_np)	//sclk下降沿：发送下一位
	begin
		if(cnt!={NBIT-1})	//未发送完所有位
		begin
        cnt <= cnt + 1'b1;	//计数器+1
	    so  <= pi[cnt];		//发送当前位（pi[cnt])
		end					//已发送完所有位（cnt=NBIT-1)
		else
		so  <= pi[cnt];		//发送最后一位
	 end
  end



/**
  always@(posedge clk or posedge rst)
  begin
    if (rst)
      cnt <= {WCNT{1'b0}};
    else if (~sld_n_r[1])
      begin
      cnt <= {WCNT{1'b0}};
      so <= pi[0];
      end
    else if (sclk_np)
      cnt <= cnt + 1'b1;
         else
      so <= pi[cnt];
  end
**/

/**
  always@(posedge clk or posedge rst)
  begin
    if (rst)
      cnt <= {WCNT{1'b0}};
    else if (~sld_n_r[1])
      cnt <= {WCNT{1'b0}};
    else if (sclk_np)
      cnt <= cnt + 1'b1;
  end

  assign so = pi[cnt];
**/

endmodule
