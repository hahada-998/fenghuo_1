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
  input  [NBIT-1:0] pi   ,
  output       reg     so   ,
  input             sld_n,
  input             sclk
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

  reg       [8:0] sclk_r ;
  reg       [2:0] sld_n_r;
//wire            sclk_pp;
  wire            sclk_np;
  reg  [WCNT-1:0] cnt    ;

  always@(posedge clk or posedge rst)
  begin
    if (rst) begin
      sclk_r  <= 9'b000000000;
      sld_n_r <= 3'b111;
    end
    else begin
      sclk_r  <= {sclk_r[7:0] , sclk };
      sld_n_r <= {sld_n_r[1:0], sld_n};
    end
  end

//  assign sclk_pp = (sclk_r[2:1]==2'b01) ? 1'b1 : 1'b0;
//  assign sclk_np = (sclk_r[4:3]==2'b10) ? 1'b1 : 1'b0;
    assign sclk_np = (sclk_r[8:7]==2'b10) ? 1'b1 : 1'b0;
always@(posedge clk or posedge rst)
  begin
    if (rst)
      cnt <= {WCNT{1'b0}};
    else if (~sld_n_r[1])
	  begin
      cnt <= 1'b1;
	  so  <= pi[0];
	  end
    else if (sclk_np)
	begin
		if(cnt!={NBIT-1})
		begin
        cnt <= cnt + 1'b1;
	    so  <= pi[cnt];
		end
		else
		so  <= pi[cnt];
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
