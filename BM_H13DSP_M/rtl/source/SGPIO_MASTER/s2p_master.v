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

module s2p_master #(parameter NBIT = 64) (
  input                 clk  ,
  input                 rst  ,
  input                 tick ,
  input                 si   ,
  output reg [NBIT-1:0] po   ,
  output       reg         sld_n,
  output       reg         sclk
) /* synthesis syn_preserve=1 */;

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

  reg      [2:0] tick_r   ;
  wire           tick_pp  ;
  
  reg            sclk_r   ;
  wire           sclk_pp  ;
  reg            sclk_pp_r;
  
  reg      [1:0] si_r     ;
  reg [NBIT-1:0] po_r     ;
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
  always@(posedge clk or posedge rst)
  begin
    if (rst)
      po_r <= {NBIT{1'b0}};
    else if (sclk_pp)
      po_r[(cnt>>1)] <= si_r[1];
  end

  always@(posedge clk or posedge rst)
  begin
    if(rst)
      po <= {NBIT{1'b0}};
    else if (sclk_pp_r && (cnt==NBIT*2-1))
      po <= po_r;
  end

endmodule
