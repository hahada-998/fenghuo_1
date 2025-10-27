//=================================================================================================--
// Copyright(c) 2021, CLOUDNINEINFO.CO, Ltd, All right reserved
// Filename   : AIS03MB03.v
// Project    : CLOUDNINEINFO common code
// Author     : dingxianhua
// Date       : 2020-09-24
// Email      : dingxianhua@cloudnineinfo.com
// Company    : CLOUDNINEINFO.CO., Ltd
// Description:
// History    :
//   Date      By          Revision  Change Description
//=================================================================================================

module stby_power_reset(
  input       clk                 ,
  input       reset_n             ,
  input       tick_ena            ,
  input       tick_dis            ,
  input       p3v3_stby_pgd       ,
  input       p2v5_stby_bmc_pgd   ,
  input       p1v2_stby_bmc_pgd   ,
  input       p1v1_stby_bmc_pgd   ,
  input       p1v0_stby_bmc_pgd   ,
  input       rst_en              ,
  input       p3v3_stby_rst_en    ,
  input       p2v5_stby_bmc_rst_en,
  input       p1v2_stby_bmc_rst_en,
  input       p1v1_stby_bmc_rst_en,
  input       p1v0_stby_bmc_rst_en,
  output reg  p3v3_stby_rst       ,
  output reg  p2v5_stby_bmc_rst   ,
  output reg  p1v2_stby_bmc_rst   ,
  output reg  p1v1_stby_bmc_rst   ,
  output reg  p1v0_stby_bmc_rst
);

  parameter FSM_IDLE              = 4'h0;
  parameter FSM_P3V3_STBY_ENA     = 4'h1;
  parameter FSM_P2V5_STBY_BMC_ENA = 4'h2;
  parameter FSM_P1V2_STBY_BMC_ENA = 4'h3;
  parameter FSM_P1V1_STBY_BMC_ENA = 4'h4;
  parameter FSM_P1V0_STBY_BMC_ENA = 4'h5;
  parameter FSM_FAULT             = 4'h6;
  parameter FSM_STEADY            = 4'h7;
  parameter FSM_P1V0_STBY_BMC_DIS = 4'h8;
  parameter FSM_P1V1_STBY_BMC_DIS = 4'h9;
  parameter FSM_P1V2_STBY_BMC_DIS = 4'hA;
  parameter FSM_P2V5_STBY_BMC_DIS = 4'hB;
  parameter FSM_P3V3_STBY_DIS     = 4'hC;
  parameter FSM_DIS_DONE          = 4'hD;
//parameter                       = 4'hE;
//parameter                       = 4'hF;

  reg  [3:0] fsm;
  wire       any_stby_rst_en;
  reg        p3v3_stby_rst_en_latch;
  always@(posedge clk or negedge reset_n)//p3v3_stby_rst
  begin
    if (!reset_n)
      p3v3_stby_rst <= 1'b0;
    else
      p3v3_stby_rst <= p3v3_stby_rst_en_latch;
  end


  assign any_stby_rst_en = p3v3_stby_rst_en     |
                           p2v5_stby_bmc_rst_en |
                           p1v2_stby_bmc_rst_en |
                           p1v1_stby_bmc_rst_en |
                           p1v0_stby_bmc_rst_en;

  always@(posedge clk or negedge reset_n)//
  begin
    if (reset_n==1'b0)
      p3v3_stby_rst_en_latch <= 1'b0;
    else if (p3v3_stby_rst_en)
      p3v3_stby_rst_en_latch <= 1'b1;
  end
  
  always@(posedge clk or negedge reset_n)//fsm[]
  begin
    if (reset_n==1'b0)
      fsm[3:0] <= FSM_IDLE;
    else if (rst_en & p3v3_stby_pgd) begin
      case(fsm[3:0])
      	  FSM_IDLE             : fsm <= FSM_P3V3_STBY_ENA;
          FSM_P3V3_STBY_ENA    : if (tick_ena)                     fsm <= FSM_P2V5_STBY_BMC_ENA;
          FSM_P2V5_STBY_BMC_ENA: if (tick_ena & p2v5_stby_bmc_pgd) fsm <= FSM_P1V2_STBY_BMC_ENA; else fsm <= FSM_FAULT;
          FSM_P1V2_STBY_BMC_ENA: if (tick_ena & p1v2_stby_bmc_pgd) fsm <= FSM_P1V1_STBY_BMC_ENA; else fsm <= FSM_FAULT;
          FSM_P1V1_STBY_BMC_ENA: if (tick_ena & p1v1_stby_bmc_pgd) fsm <= FSM_P1V0_STBY_BMC_ENA; else fsm <= FSM_FAULT;
          FSM_P1V0_STBY_BMC_ENA: if (tick_ena & p1v0_stby_bmc_pgd) fsm <= FSM_STEADY           ; else fsm <= FSM_FAULT;
          FSM_FAULT            :                                   fsm <= FSM_P2V5_STBY_BMC_ENA;
          FSM_STEADY           : if (any_stby_rst_en) fsm <= FSM_P1V0_STBY_BMC_DIS;
          FSM_P1V0_STBY_BMC_DIS: if (tick_dis) fsm <= FSM_P1V1_STBY_BMC_DIS;
          FSM_P1V1_STBY_BMC_DIS: if (tick_dis) fsm <= FSM_P1V2_STBY_BMC_DIS;
          FSM_P1V2_STBY_BMC_DIS: if (tick_dis) fsm <= FSM_P2V5_STBY_BMC_DIS;
          FSM_P2V5_STBY_BMC_DIS: if (tick_dis) begin
                                  if (p3v3_stby_rst_en_latch)
                                    fsm <= FSM_P3V3_STBY_DIS;
                                  else
                                    fsm <= FSM_DIS_DONE;
                                end
          FSM_P3V3_STBY_DIS    : fsm <= FSM_IDLE;
          FSM_DIS_DONE         : fsm <= FSM_IDLE;
          default              : fsm <= FSM_IDLE;
      endcase
    end
    else
      fsm[3:0] <= FSM_IDLE;
  end



  always@(posedge clk or negedge reset_n)//rst
  begin
    if (reset_n==1'b0) begin
      p2v5_stby_bmc_rst = 1'b0;
      p1v2_stby_bmc_rst = 1'b0;
      p1v1_stby_bmc_rst = 1'b0;
      p1v0_stby_bmc_rst = 1'b0;
    end
    else if (fsm[3:0]==FSM_IDLE) begin
      p2v5_stby_bmc_rst = 1'b0;
      p1v2_stby_bmc_rst = 1'b0;
      p1v1_stby_bmc_rst = 1'b0;
      p1v0_stby_bmc_rst = 1'b0;
    end
    else if (fsm[3:0]==FSM_P1V0_STBY_BMC_DIS)
      p1v0_stby_bmc_rst = 1'b1;
    else if (fsm[3:0]==FSM_P1V1_STBY_BMC_DIS)
      p1v1_stby_bmc_rst = 1'b1;
    else if (fsm[3:0]==FSM_P1V2_STBY_BMC_DIS)
      p1v2_stby_bmc_rst = 1'b1;
    else if (fsm[3:0]==FSM_P2V5_STBY_BMC_DIS)
      p2v5_stby_bmc_rst = 1'b1;
  end

endmodule
