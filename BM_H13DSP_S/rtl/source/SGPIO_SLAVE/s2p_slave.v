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

module s2p_slave #(parameter NBIT = 64, 
	                         DEFAULT_STATE = 64'h0) (
  input  wire               clk  ,
  input  wire               rst  ,
  input  wire               si   ,
  output reg [NBIT-1:0]    po   ,
  input  wire               sld_n,
  input  wire               sclk
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

  reg      [2:0] sclk_r   ;
  reg      [1:0] sld_n_r  ;
  reg      [1:0] si_r     ;
  wire           sclk_pp  ;
  reg            sclk_pp_r;
  wire           sclk_np  ;
  reg [WCNT-1:0] cnt      ;
  reg [NBIT-1:0] po_r     ;

  always@(posedge clk or posedge rst)
  begin
    if (rst) begin
      sclk_r  <= 3'b000;
      sld_n_r <= 2'b11;
      si_r    <= 2'b00;
    end
    else begin
      sclk_r  <= {sclk_r[1:0], sclk};
      sld_n_r <= {sld_n_r[0], sld_n};
      si_r    <= {si_r[0], si};
    end
  end

  assign sclk_pp = (sclk_r[2:1]==2'b01) ? 1'b1 : 1'b0;
  assign sclk_np = (sclk_r[2:1]==2'b10) ? 1'b1 : 1'b0;

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
      else if (!sld_n_r[1])
        cnt <= {WCNT{1'b0}};
      else if (sclk_np)
        cnt <= cnt + 1'b1;
  end

  always@(posedge clk or posedge rst)
  begin
    if (rst)
      po_r <= {NBIT{1'b0}};
    else if (sclk_pp)
      po_r[cnt] <= si_r[1];
  end

  always@(posedge clk or posedge rst)
  begin
    if (rst)
      po <= DEFAULT_STATE;
    else if (sclk_pp_r && (cnt==NBIT-1))
      po <= po_r;
  end

endmodule
