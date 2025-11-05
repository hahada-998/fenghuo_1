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
//2017/03/07        fangchunfei     0.1                     file created

/******************************************************************************************/
  `define FSM_I2C_IDLE         7'h1
  `define FSM_I2C_DEV_ADDR     7'h2
  `define FSM_I2C_DEV_ADDR_ACK 7'h4
  `define FSM_I2C_REG_ADDR     7'h8
  `define FSM_I2C_REG_ADDR_ACK 7'h10
  `define FSM_I2C_DATA         7'h20
  `define FSM_I2C_DATA_ACK     7'h40

  `define I2C_OP_RD 1'b1
  `define I2C_OP_WR 1'b0

module i2c_slave #(parameter DEV_ADDR = 8'h60) (
  input            clk         ,
  input            rst         ,
  input            sdai        ,
  output reg       sdao        ,
  output reg       sdao_en     ,
  input            scl         ,
  output     [7:0] i2c_addr    ,
  input      [7:0] i2c_rdata   ,
  output     [7:0] i2c_wdata   ,
  output reg       i2c_wdata_en
);

  reg  [2:0] sdai_r       ;
  reg  [2:0] scl_r        ;
  wire       scl_pp       ; // cycle positive pulse clock enalbe
  wire       scl_np       ; // cycle negative pulse clock enalbe

  wire       start_con    ;
  wire       stop_con     ; // START / stop condition pulse

  reg  [3:0] bit_cnt      ; // down counter
  wire       byte_done    ;
  reg        reg_op       ; // read operation (=1 ) or write operation (=0 )
  reg  [7:0] reg_sdai     ;
  reg  [7:0] reg_addr     ;
  reg  [7:0] reg_rdata    ;
  reg        reg_rdata_en ;
  wire       dev_addr_ok  ;
  reg        reg_rdata_ack;

  reg  [6:0] state        ;
  reg  [6:0] next_state   ;

  assign i2c_addr  = reg_addr;
  assign i2c_wdata = reg_sdai;

// I2C data receive
  always@(posedge clk or posedge rst)
  begin
    if (rst)
      reg_sdai <= 8'b0;
    else if(scl_pp)
      reg_sdai <= {reg_sdai[6:0], sdai_r[1]};
  end

  assign dev_addr_ok = (reg_sdai[7:1]==DEV_ADDR[7:1]);

  always@(posedge clk or posedge rst)
  begin
    if (rst)
      reg_addr <= 8'b0;
    else if(scl_np && (next_state==`FSM_I2C_REG_ADDR_ACK))
      reg_addr <= reg_sdai;
    else if(scl_np && (state==`FSM_I2C_DATA_ACK) && (next_state==`FSM_I2C_DATA))
      reg_addr <= reg_addr + 1'b1;
  end

  always@(posedge clk or posedge rst)
  begin
    if (rst)
      reg_rdata_en <= 1'b0;
    else if (scl_np && (state!=`FSM_I2C_DATA) && (next_state==`FSM_I2C_DATA))
      reg_rdata_en <= 1'b1;
    else
      reg_rdata_en <= 1'b0;
  end

  always@(posedge clk or posedge rst)
  begin
    if (rst)
      i2c_wdata_en <= 1'b0;
    else if (scl_np && (next_state==`FSM_I2C_DATA_ACK) && (reg_op==`I2C_OP_WR))
      i2c_wdata_en <= 1'b1;
    else
      i2c_wdata_en <= 1'b0;
  end

  always@(posedge clk or posedge rst)
  begin
    if (rst)
      reg_rdata <= 8'b0;
    else if (reg_rdata_en)
      reg_rdata <= i2c_rdata;
    else if (scl_np && (state==`FSM_I2C_DATA) && (reg_op==`I2C_OP_RD))
      reg_rdata <= {reg_rdata[6:0], 1'b0};
  end

//Start and stop condition
  always@(posedge clk or posedge rst)
  begin
    if (rst)
      scl_r <= 3'b111;
    else
      scl_r <= {scl_r[1:0], scl};
  end

  always@(posedge clk or posedge rst)
  begin
    if (rst)
      sdai_r <= 3'b111;
    else
      sdai_r <= {sdai_r[1:0], sdai};
  end

  assign start_con = (( sdai_r[2]) & (~sdai_r[1])) & scl_r[1];
  assign stop_con  = ((~sdai_r[2]) & ( sdai_r[1])) & scl_r[1];

  assign scl_pp = (~scl_r[2]) & ( scl_r[1]);
  assign scl_np = ( scl_r[2]) & (~scl_r[1]);

// Byte count
  always@(posedge clk or posedge rst)
  begin
    if (rst)
      bit_cnt <= 4'd8;
    else if (start_con)
      bit_cnt <= 4'd8;
    else if (scl_pp) begin
      if (byte_done)
        bit_cnt <= 4'd8;
      else
        bit_cnt <= bit_cnt - 1'b1;
    end
  end

  assign byte_done = (bit_cnt==4'd0);


// I2C slave state machine
  always@(posedge clk or posedge rst)
  begin
    if (rst)
      state <= `FSM_I2C_IDLE;
    else if (stop_con)
      state <= `FSM_I2C_IDLE;
    else if (start_con)
      state <= `FSM_I2C_DEV_ADDR;
    else if (scl_np)
      state <= next_state;
  end

  always@(*)
  begin
    case(state)
      `FSM_I2C_IDLE:
         if (start_con)
           next_state = `FSM_I2C_DEV_ADDR;
         else
           next_state = `FSM_I2C_IDLE;
      `FSM_I2C_DEV_ADDR:
         if (byte_done) begin
           if (dev_addr_ok)
             next_state = `FSM_I2C_DEV_ADDR_ACK;
           else
             next_state = `FSM_I2C_IDLE;
          end
          else
            next_state = `FSM_I2C_DEV_ADDR;
      `FSM_I2C_DEV_ADDR_ACK:
         if (reg_op==`I2C_OP_RD)
           next_state = `FSM_I2C_DATA;
         else
           next_state = `FSM_I2C_REG_ADDR;
      `FSM_I2C_REG_ADDR:
         if (byte_done)
           next_state = `FSM_I2C_REG_ADDR_ACK;
         else
           next_state = `FSM_I2C_REG_ADDR;
      `FSM_I2C_REG_ADDR_ACK:
         next_state = `FSM_I2C_DATA;
      `FSM_I2C_DATA:
         if (byte_done)
           next_state = `FSM_I2C_DATA_ACK;
         else
           next_state = `FSM_I2C_DATA;
      `FSM_I2C_DATA_ACK:
         if ((reg_op==`I2C_OP_RD) && reg_rdata_ack) //如果读ACK无效的话则结束操作；否则连续读或写，地址加1
           next_state = `FSM_I2C_IDLE;
         else
           next_state = `FSM_I2C_DATA;
      default:
        next_state = `FSM_I2C_IDLE;
    endcase
  end

// state machine output codec
  always@(posedge clk or posedge rst)
  begin
    if (rst)
      reg_op <= `I2C_OP_RD;
    else if (state==`FSM_I2C_IDLE)
      reg_op <= `I2C_OP_RD;
    else if (state==`FSM_I2C_DEV_ADDR && byte_done && dev_addr_ok)
      reg_op <= reg_sdai[0];
  end

  always@(posedge clk or posedge rst)
  begin
    if (rst)
      reg_rdata_ack <= 1'b0;
    else if (state==`FSM_I2C_IDLE)
      reg_rdata_ack <= 1'b0;
    else if (state==`FSM_I2C_DATA_ACK && (reg_op==`I2C_OP_RD) && scl_pp)
      reg_rdata_ack <= sdai_r[1];
  end

  always@(*)
  begin
    case(state)
      `FSM_I2C_IDLE: begin
        sdao_en = 1'b0;
        sdao = 1'b0;
      end
      `FSM_I2C_DEV_ADDR: begin
        sdao_en = 1'b0;
        sdao = 1'b0;
      end
      `FSM_I2C_DEV_ADDR_ACK: begin
        sdao_en = 1'b1;
        sdao = 1'b0;
      end
      `FSM_I2C_REG_ADDR: begin
        sdao_en = 1'b0;
        sdao = 1'b0;
      end
      `FSM_I2C_REG_ADDR_ACK: begin
        sdao_en = 1'b1;
        sdao = 1'b0;
      end
      `FSM_I2C_DATA: begin
         if (reg_op==`I2C_OP_RD) begin // read operation
           if (next_state==`FSM_I2C_DATA_ACK && ~scl_r[1]) //release as quickly as scl down
             sdao_en = 1'b0;
           else
             sdao_en = 1'b1;
           sdao = reg_rdata[7];
         end
         else begin // write
           sdao_en = 1'b0;
           sdao = 1'b0;
         end
      end
      `FSM_I2C_DATA_ACK: begin
        if (reg_op==`I2C_OP_RD) begin//read
          sdao_en = 1'b0;
          sdao = 1'b0;
        end
        else begin//write
          sdao_en = 1'b1;
          sdao = 1'b0;
        end
      end
      default: begin
        sdao_en = 1'b0;
        sdao = 1'b0;
      end
    endcase
  end

endmodule

//i2c_slave #(.DEV_ADDR(8'h60)) inst_i2c_slave(
//  .clk         (clk         ),
//  .rst         (rst         ),
//  .sdai        (sdai        ),
//  .sdao        (sdao        ),
//  .sdao_en     (sdao_en     ),
//  .scl         (scl         ),
//  .i2c_addr    (i2c_addr    ),
//  .i2c_rdata   (i2c_rdata   ),
//  .i2c_wdata   (i2c_wdata   ),
//  .i2c_wdata_en(i2c_wdata_en)
//);

