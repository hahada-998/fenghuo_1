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
//2017/04/10        fangchunfei     0.1                     file created

/******************************************************************************************/

module p2s_master #(parameter NBIT = 64) (
  input             clk  ,
  input             rst  ,
  input             tick ,
  input  [NBIT-1:0] pi   ,
  output            so   ,
  output            sclk ,
  output            sld_n
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

localparam WCNT = clogb2(NBIT*2);

  reg       [2:0] tick_r ;
  wire            tick_pp;
  reg  [WCNT-1:0] cnt    ;

  always@(posedge clk or posedge rst)
  begin
    if (rst)
      tick_r <= 3'b00;
    else
      tick_r <= {tick_r[1:0], tick};
  end

  assign tick_pp = (tick_r[2:1] == 2'b01) ? 1'b1 : 1'b0;

  always@(posedge clk or posedge rst)
  begin
    if(rst)
      cnt <= {WCNT{1'b0}};
    else if(tick_pp)begin
      if (cnt == NBIT*2-1)
        cnt <= {WCNT{1'b0}};
      else
        cnt <= cnt + 1'b1;
    end
  end

  assign sclk  = cnt[0];
  assign sld_n = ((cnt == {WCNT{1'b0}}) || (cnt == {{(WCNT-1){1'b0}},1'b1}))? 1'b0 : 1'b1;
  assign so = pi[(cnt>>1)];

endmodule
