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

`include "tpm_define.v"

module tpm(
  input             spi_mosi         ,
  output reg        spi_miso         ,
  output reg        spi_miso_en      ,
  input             spi_cs_n         ,
  input             spi_clk          ,

  output reg  [7:0] spi_cmd          ,
  output reg [23:0] spi_addr         ,
  output reg [31:0] spi_wdata        ,
  output reg [31:0] spi_rdata        ,
  output reg  [7:0] spi_state        ,

  output reg  [7:0] buf_spi_cmd      ,
  output reg [23:0] buf_spi_addr     ,
  output reg [31:0] buf_spi_wdata    ,
  output reg [31:0] buf_spi_rdata    ,
  output reg  [7:0] buf_state        ,

  output reg  [3:0] buf_lpc_start    ,
  output reg  [1:0] buf_lpc_ct       ,
  output reg        buf_lpc_dir      ,
  output reg [15:0] buf_lpc_addr     ,
  output reg  [7:0] buf_lpc_wdata    ,
  output reg  [7:0] buf_lpc_rdata    ,

  output reg  [3:0] lpc_start        ,
  output reg  [1:0] lpc_ct           ,
  output reg        lpc_dir          ,
  output reg [15:0] lpc_addr         ,
  output reg  [7:0] lpc_wdata        ,
  output reg  [7:0] lpc_rdata        ,
  output reg  [7:0] lpc_state        ,

  input       [3:0] lpc_adi          ,
  output reg  [3:0] lpc_ado          ,
  output reg        lpc_ado_en       ,
  output reg        lpc_frame_n      ,
  input             lpc_clk          ,
  input             lpc_rst_n        ,

  input             clk              ,
  input             rst_n
);

//SPI interface
  reg   [2:0] spi_clk_dly           ;
  wire        spi_clk_pp0           ;
  wire        spi_clk_np0           ;
  wire        spi_clk_pp1           ;
//wire        spi_clk_np1           ;

  reg   [7:0] spi_mosi_state        ;
  reg   [7:0] spi_mosi_data         ;

  reg   [7:0] spi_miso_state        ;
  reg   [7:0] spi_miso_data         ;

//SPI side
  reg   [7:0] spi_state_dly         ;

  reg         spi_wdata_done        ;
  reg         spi_wait              ;

  wire        spi_buf_done          ;
  reg   [1:0] spi_buf_done_dly      ;
  wire        spi_buf_done_pp       ;

  wire        spi_cmd_dir           ;
  wire        spi_cmd_rsvd          ;
  wire  [5:0] spi_cmd_size          ;

//BUFFER
  wire        buf_spi_cmd_dir       ;
  wire        buf_spi_cmd_rsvd      ;
  wire  [5:0] buf_spi_cmd_size      ;

  wire        buf_spi_wdata_done_pp ;

  wire        buf_spi_wait          ;
  reg   [1:0] buf_spi_wait_dly      ;
  wire        buf_spi_wait_pp       ;

  reg         buf_lpc_tx            ;
  reg         buf_lpc_rx            ;
  reg         buf_done              ;

  wire        buf_lpc_done          ;
  reg   [1:0] buf_lpc_done_dly      ;
  wire        buf_lpc_done_pp       ;

  reg   [5:0] buf_cnt;

//LPC
  wire        lpc_en                ;
  reg   [2:0] lpc_en_dly            ;
  wire        lpc_en_pp             ;

  reg         lpc_done              ;

  reg   [3:0] lpc_sync_cnt          ;
  wire        lpc_sync_timeout      ;

//SPI interface transmit
  always@(posedge clk or negedge rst_n)
  begin
  	if (!rst_n)
  	  spi_clk_dly[2:0] <= 3'b0;
  	else
  	  spi_clk_dly[2:0] <= {spi_clk_dly[1:0], spi_clk};
  end

  assign spi_clk_pp0 = (spi_clk_dly[1:0]==2'b01);
  assign spi_clk_np0 = (spi_clk_dly[1:0]==2'b10);

  assign spi_clk_pp1 = (spi_clk_dly[2:1]==2'b01);
//assign spi_clk_np1 = (spi_clk_dly[2:1]==2'b10);

  always@(posedge clk or negedge rst_n)
  begin
  	if (!rst_n)
  	  spi_mosi_state <= `FSM_SPI_MOSI_BIT7;
  	else if (spi_cs_n==1'b1)
  	  spi_mosi_state <= `FSM_SPI_MOSI_BIT7;
  	else if (spi_clk_pp0)
  		case(spi_mosi_state)
  			`FSM_SPI_MOSI_BIT7: spi_mosi_state <= `FSM_SPI_MOSI_BIT6;
  			`FSM_SPI_MOSI_BIT6: spi_mosi_state <= `FSM_SPI_MOSI_BIT5;
  			`FSM_SPI_MOSI_BIT5: spi_mosi_state <= `FSM_SPI_MOSI_BIT4;
  			`FSM_SPI_MOSI_BIT4: spi_mosi_state <= `FSM_SPI_MOSI_BIT3;
  			`FSM_SPI_MOSI_BIT3: spi_mosi_state <= `FSM_SPI_MOSI_BIT2;
  			`FSM_SPI_MOSI_BIT2: spi_mosi_state <= `FSM_SPI_MOSI_BIT1;
  			`FSM_SPI_MOSI_BIT1: spi_mosi_state <= `FSM_SPI_MOSI_BIT0;
  			`FSM_SPI_MOSI_BIT0: spi_mosi_state <= `FSM_SPI_MOSI_BIT7;
//			default           : spi_mosi_state <= `FSM_SPI_MOSI_BIT7;
  		endcase
  end

  always@(posedge clk or negedge rst_n)
  begin
  	if (!rst_n)
  	  spi_mosi_data[7:0] <= 8'h00;
  	else if (spi_cs_n==1'b1)
  	  spi_mosi_data[7:0] <= 8'h00;
  	else if (spi_clk_pp0)
  		case(spi_mosi_state)
  			`FSM_SPI_MOSI_BIT7: spi_mosi_data[7]   <= spi_mosi;
  			`FSM_SPI_MOSI_BIT6: spi_mosi_data[6]   <= spi_mosi;
  			`FSM_SPI_MOSI_BIT5: spi_mosi_data[5]   <= spi_mosi;
  			`FSM_SPI_MOSI_BIT4: spi_mosi_data[4]   <= spi_mosi;
  			`FSM_SPI_MOSI_BIT3: spi_mosi_data[3]   <= spi_mosi;
  			`FSM_SPI_MOSI_BIT2: spi_mosi_data[2]   <= spi_mosi;
  			`FSM_SPI_MOSI_BIT1: spi_mosi_data[1]   <= spi_mosi;
  			`FSM_SPI_MOSI_BIT0: spi_mosi_data[0]   <= spi_mosi;
//			default           : spi_mosi_data[7:0] <= 8'b0    ;
  		endcase
  end

//SPI interface receive
  always@(posedge clk or negedge rst_n)
  begin
  	if (!rst_n)
  	  spi_miso_state <= `FSM_SPI_MISO_BIT7;
  	else if (spi_cs_n==1'b1)
  	  spi_miso_state <= `FSM_SPI_MISO_BIT7;
  	else if (spi_clk_np0)
  		case(spi_miso_state)
  			`FSM_SPI_MISO_BIT7: spi_miso_state <= `FSM_SPI_MISO_BIT6;
  			`FSM_SPI_MISO_BIT6: spi_miso_state <= `FSM_SPI_MISO_BIT5;
  			`FSM_SPI_MISO_BIT5: spi_miso_state <= `FSM_SPI_MISO_BIT4;
  			`FSM_SPI_MISO_BIT4: spi_miso_state <= `FSM_SPI_MISO_BIT3;
  			`FSM_SPI_MISO_BIT3: spi_miso_state <= `FSM_SPI_MISO_BIT2;
  			`FSM_SPI_MISO_BIT2: spi_miso_state <= `FSM_SPI_MISO_BIT1;
  			`FSM_SPI_MISO_BIT1: spi_miso_state <= `FSM_SPI_MISO_BIT0;
  			`FSM_SPI_MISO_BIT0: spi_miso_state <= `FSM_SPI_MISO_BIT7;
//			default           : spi_miso_state <= `FSM_SPI_MISO_BIT7;
  		endcase
  end

  always@(posedge clk or negedge rst_n)
  begin
  	if (!rst_n)
  	  spi_miso <= 1'b0;
  	else if (spi_cs_n==1'b1)
  	  spi_miso <= 1'b0;
  	else// if (spi_clk_np0)
  		case(spi_miso_state)
  			`FSM_SPI_MISO_BIT7: spi_miso <= spi_miso_data[7];
  			`FSM_SPI_MISO_BIT6: spi_miso <= spi_miso_data[6];
  			`FSM_SPI_MISO_BIT5: spi_miso <= spi_miso_data[5];
  			`FSM_SPI_MISO_BIT4: spi_miso <= spi_miso_data[4];
  			`FSM_SPI_MISO_BIT3: spi_miso <= spi_miso_data[3];
  			`FSM_SPI_MISO_BIT2: spi_miso <= spi_miso_data[2];
  			`FSM_SPI_MISO_BIT1: spi_miso <= spi_miso_data[1];
  			`FSM_SPI_MISO_BIT0: spi_miso <= spi_miso_data[0];
//			default           : spi_miso <= 1'b0            ;
  		endcase
  end


//SPI protocol
//spi_wdata_done: 1-clk width
  always@(posedge clk or negedge rst_n)
  begin
    if (!rst_n)
      spi_wdata_done <= 1'b0;
    else if (spi_state==`FSM_SPI_WDATA_DONE)
      spi_wdata_done <= 1'b1;
    else
      spi_wdata_done <= 1'b0;
  end

//spi_wait: miso_en should be noted
  always@(posedge clk or negedge rst_n)
  begin
    if (!rst_n)
      spi_wait <= 1'b0;
    else if (spi_state==`FSM_SPI_WAIT)
      spi_wait <= 1'b1;
    else
      spi_wait <= 1'b0;
  end

//spi_buf_done
  assign spi_buf_done = buf_done;

  always@(posedge clk or negedge rst_n)
  begin
  	if (!rst_n)
  	  spi_buf_done_dly[1:0] <= 2'b0;
  	else if (spi_clk_np0)
  	  spi_buf_done_dly[1:0] <= {spi_buf_done_dly[0], spi_buf_done};
  end

  assign spi_buf_done_pp = (spi_buf_done_dly[1:0]==2'b01);

//SPI FSM
//When CS# asserted   , FSM starts from COMMAND to DONE, even if clk is not supplied.
//when CS# de-asserted, FSM would be back to IDLE whatever.
  always@(posedge clk or negedge rst_n)//spi_state[]
  begin
    if (!rst_n)
      spi_state <= `FSM_SPI_IDLE;
    else if (spi_cs_n==1'b1)
      spi_state <= `FSM_SPI_IDLE;
    else
      case(spi_state)
//    	`FSM_SPI_IDLE      : if (spi_clk_pp0) spi_state <= `FSM_SPI_COMMAND;
      	`FSM_SPI_IDLE      : if (spi_clk_pp0) spi_state <= `FSM_SPI_COMMAND;
        `FSM_SPI_COMMAND   : if (spi_clk_pp0 && (spi_mosi_state==`FSM_SPI_MOSI_BIT0)) spi_state <= `FSM_SPI_ADDRESS2;
        `FSM_SPI_ADDRESS2  : if (spi_clk_pp0 && (spi_mosi_state==`FSM_SPI_MOSI_BIT0)) spi_state <= `FSM_SPI_ADDRESS1;
        `FSM_SPI_ADDRESS1  : if (spi_clk_pp0 && (spi_mosi_state==`FSM_SPI_MOSI_BIT0)) spi_state <= `FSM_SPI_ADDRESS0;
        `FSM_SPI_ADDRESS0  : if (spi_clk_pp0 && (spi_mosi_state==`FSM_SPI_MOSI_BIT0)) begin
                               if (spi_cmd_dir==1'b0) spi_state <= `FSM_SPI_WDATA0;
                               else                   spi_state <= `FSM_SPI_WAIT;
                             end

        `FSM_SPI_WDATA0    : if (spi_clk_pp0 && (spi_mosi_state==`FSM_SPI_MOSI_BIT0)) begin
          	                   if (spi_cmd_size[5:0]==6'b00_0000) spi_state <= `FSM_SPI_WDATA_DONE;
          	                   else                          	    spi_state <= `FSM_SPI_WDATA1;
                             end
        `FSM_SPI_WDATA1    : if (spi_clk_pp0 && (spi_mosi_state==`FSM_SPI_MOSI_BIT0)) begin
          	                   if (spi_cmd_size[5:0]==6'b00_0001) spi_state <= `FSM_SPI_WDATA_DONE;
          	                   else                          	    spi_state <= `FSM_SPI_WDATA2;
                             end
        `FSM_SPI_WDATA2    : if (spi_clk_pp0 && (spi_mosi_state==`FSM_SPI_MOSI_BIT0)) begin
          	                   if (spi_cmd_size[5:0]==6'b00_0010) spi_state <= `FSM_SPI_WDATA_DONE;
          	                   else                          	    spi_state <= `FSM_SPI_WDATA3;
                             end
        `FSM_SPI_WDATA3    : if (spi_clk_pp0 && (spi_mosi_state==`FSM_SPI_MOSI_BIT0)) begin
          	                   if (spi_cmd_size[5:0]==6'b00_0011) spi_state <= `FSM_SPI_WDATA_DONE;
          	                   else                          	    spi_state <= `FSM_SPI_FAULT;
                             end
        `FSM_SPI_WDATA_DONE: spi_state <= `FSM_SPI_DONE;

        `FSM_SPI_WAIT      : if (spi_buf_done_pp) spi_state <= `FSM_SPI_WAIT_RDY;
        `FSM_SPI_WAIT_RDY  : if (spi_clk_np0 && (spi_miso_state==`FSM_SPI_MISO_BIT0)) spi_state <= `FSM_SPI_WAIT_END;
        `FSM_SPI_WAIT_END  : if (spi_clk_np0 && (spi_miso_state==`FSM_SPI_MISO_BIT0)) spi_state <= `FSM_SPI_WAIT_DONE;
        `FSM_SPI_WAIT_DONE : if (spi_clk_np0 && (spi_miso_state==`FSM_SPI_MISO_BIT0)) spi_state <= `FSM_SPI_RDATA0;
        `FSM_SPI_RDATA0    : if (spi_clk_np0 && (spi_miso_state==`FSM_SPI_MISO_BIT0)) begin
          	                   if (spi_cmd_size[5:0]==6'b00_0000) spi_state <= `FSM_SPI_RDATA_DONE;
                           	   else                           	  spi_state <= `FSM_SPI_RDATA1;
          	                 end
        `FSM_SPI_RDATA1    : if (spi_clk_np0 && (spi_miso_state==`FSM_SPI_MISO_BIT0)) begin
          	                   if (spi_cmd_size[5:0]==6'b00_0001) spi_state <= `FSM_SPI_RDATA_DONE;
          	                   else                           	  spi_state <= `FSM_SPI_RDATA2;
          	                 end
        `FSM_SPI_RDATA2    : if (spi_clk_np0 && (spi_miso_state==`FSM_SPI_MISO_BIT0)) begin
          	                   if (spi_cmd_size[5:0]==6'b00_0010) spi_state <= `FSM_SPI_RDATA_DONE;
          	                   else                           	  spi_state <= `FSM_SPI_RDATA3;
          	                 end
        `FSM_SPI_RDATA3    : if (spi_clk_np0 && (spi_miso_state==`FSM_SPI_MISO_BIT0)) begin
          	                   if (spi_cmd_size[5:0]==6'b00_0011) spi_state <= `FSM_SPI_RDATA_DONE;
          	                   else                           	  spi_state <= `FSM_SPI_FAULT;
          	                 end
        `FSM_SPI_RDATA_DONE: spi_state <= `FSM_SPI_DONE;

        `FSM_SPI_FAULT     : spi_state <= `FSM_SPI_DONE;
        `FSM_SPI_DONE      : spi_state <= `FSM_SPI_DONE;//wait for CS# releasing
        default            : spi_state <= `FSM_SPI_IDLE;
      endcase
  end

  always@(posedge clk or negedge rst_n) //spi_state_dly[]
  begin
    if (!rst_n)
      spi_state_dly[7:0] <= `FSM_SPI_IDLE;
    else
      spi_state_dly[7:0] <= spi_state[7:0];
  end

  always@(posedge clk or negedge rst_n) //spi_cmd[], spi_addr[], spi_wdata[]
  begin
    if (!rst_n) begin
      spi_cmd[7:0]    <=  8'b0;
      spi_addr[23:0]  <= 24'b0;
      spi_wdata[31:0] <= 32'b0;
    end
    else if (spi_clk_pp1 && (spi_mosi_state==`FSM_SPI_MOSI_BIT7) && (spi_state_dly==`FSM_SPI_COMMAND )) spi_cmd[7:0]     <= spi_mosi_data[7:0];
    else if (spi_clk_pp1 && (spi_mosi_state==`FSM_SPI_MOSI_BIT7) && (spi_state_dly==`FSM_SPI_ADDRESS2)) spi_addr[23:16]  <= spi_mosi_data[7:0];
    else if (spi_clk_pp1 && (spi_mosi_state==`FSM_SPI_MOSI_BIT7) && (spi_state_dly==`FSM_SPI_ADDRESS1)) spi_addr[15:8]   <= spi_mosi_data[7:0];
    else if (spi_clk_pp1 && (spi_mosi_state==`FSM_SPI_MOSI_BIT7) && (spi_state_dly==`FSM_SPI_ADDRESS0)) spi_addr[7:0]    <= spi_mosi_data[7:0];
    else if (spi_clk_pp1 && (spi_mosi_state==`FSM_SPI_MOSI_BIT7) && (spi_state_dly==`FSM_SPI_WDATA0  )) spi_wdata[7:0]   <= spi_mosi_data[7:0];
    else if (spi_clk_pp1 && (spi_mosi_state==`FSM_SPI_MOSI_BIT7) && (spi_state_dly==`FSM_SPI_WDATA1  )) spi_wdata[15:8]  <= spi_mosi_data[7:0];
    else if (spi_clk_pp1 && (spi_mosi_state==`FSM_SPI_MOSI_BIT7) && (spi_state_dly==`FSM_SPI_WDATA2  )) spi_wdata[23:16] <= spi_mosi_data[7:0];
    else if (spi_clk_pp1 && (spi_mosi_state==`FSM_SPI_MOSI_BIT7) && (spi_state_dly==`FSM_SPI_WDATA3  )) spi_wdata[31:24] <= spi_mosi_data[7:0];
  end

  assign spi_cmd_dir  = spi_cmd[7]  ;
  assign spi_cmd_rsvd = spi_cmd[6]  ;
  assign spi_cmd_size = spi_cmd[5:0];

  always@(posedge clk or negedge rst_n) //spi_miso_data[]
  begin
    if (!rst_n)
      spi_miso_data[7:0] <= 8'h00;
    else if (spi_cs_n==1'b1)
      spi_miso_data[7:0] <= 8'h00;
    else if (spi_state==`FSM_SPI_IDLE)
      spi_miso_data[7:0] <= 8'h00;
    else if (spi_clk_np0 && spi_miso_state==`FSM_SPI_MISO_BIT0) begin
    	     if (spi_state==`FSM_SPI_WAIT     ) spi_miso_data[7:0] <= 8'h00;
    	else if (spi_state==`FSM_SPI_WAIT_END ) spi_miso_data[7:0] <= 8'hFF;
    	else if (spi_state==`FSM_SPI_WAIT_DONE) spi_miso_data[7:0] <= spi_rdata[7:0]  ;
    	else if (spi_state==`FSM_SPI_RDATA0   ) spi_miso_data[7:0] <= spi_rdata[15:8] ;
    	else if (spi_state==`FSM_SPI_RDATA1   ) spi_miso_data[7:0] <= spi_rdata[23:16];
    	else if (spi_state==`FSM_SPI_RDATA2   ) spi_miso_data[7:0] <= spi_rdata[31:24];
//  	else if (spi_state==`FSM_SPI_RDATA3   ) spi_miso_data[7:0] <= 8'h00;
    end
  end

  always@(posedge clk or negedge rst_n) //spi_miso_en
  begin
    if (!rst_n)
      spi_miso_en <= 1'b0;
    else if (spi_cs_n==1'b1)
      spi_miso_en <= 1'b0;
    else if (spi_clk_np0 && (spi_mosi_state==`FSM_SPI_MOSI_BIT1) && (spi_state==`FSM_SPI_ADDRESS0) && (spi_cmd_dir==1'b1))
      spi_miso_en <= 1'b1;
    else if (spi_clk_np0 && spi_miso_state==`FSM_SPI_MISO_BIT0) begin
           if ((spi_state==`FSM_SPI_RDATA0) && (spi_cmd_size==6'b00_0000)) spi_miso_en <= 1'b0;
  		else if ((spi_state==`FSM_SPI_RDATA1) && (spi_cmd_size==6'b00_0001)) spi_miso_en <= 1'b0;
  		else if ((spi_state==`FSM_SPI_RDATA2) && (spi_cmd_size==6'b00_0010)) spi_miso_en <= 1'b0;
  		else if ((spi_state==`FSM_SPI_RDATA3) && (spi_cmd_size==6'b00_0011)) spi_miso_en <= 1'b0;
  	end
  end

//BUFFER
//buf_spi_wdata_done_pp
  assign buf_spi_wdata_done_pp = spi_wdata_done;


//buf_spi_wait_pp
  assign buf_spi_wait = spi_wait;

  always@(posedge clk or negedge rst_n)
  begin
  	if (!rst_n)
  	  buf_spi_wait_dly[1:0] <= 2'b00;
  	else
  	  buf_spi_wait_dly[1:0] <= {buf_spi_wait_dly[0], buf_spi_wait};
  end

  assign buf_spi_wait_pp = (buf_spi_wait_dly[1:0]==2'b01);

//buf_lpc_done
  assign buf_lpc_done = lpc_done;

  always@(posedge clk or negedge rst_n)
  begin
  	if (!rst_n)
  	  buf_lpc_done_dly[1:0] <= 2'b00;
  	else
  	  buf_lpc_done_dly[1:0] <= {buf_lpc_done_dly[0], buf_lpc_done};
  end

  assign buf_lpc_done_pp = (buf_lpc_done_dly[1:0]==2'b01);

//buf_lpc_tx
  always@(posedge clk or negedge rst_n)
  begin
    if (!rst_n)
      buf_lpc_tx <= 1'b0;
    else if (buf_state==`FSM_BUF_LPC_TX)
    	buf_lpc_tx <= 1'b1;
    else if (buf_state==`FSM_BUF_LPC_DONE_TX)
    	buf_lpc_tx <= 1'b0;
  end

//buf_lpc_rx
  always@(posedge clk or negedge rst_n)
  begin
    if (!rst_n)
      buf_lpc_rx <= 1'b0;
    else if (buf_state==`FSM_BUF_LPC_RX)
    	buf_lpc_rx <= 1'b1;
    else if (buf_state==`FSM_BUF_LPC_DONE_RX)
    	buf_lpc_rx <= 1'b0;
  end

//buf_done
  always@(posedge clk or negedge rst_n)
  begin
    if (!rst_n)
      buf_done <= 1'b0;
    else if (buf_state==`FSM_BUF_DONE)
    	buf_done <= 1'b1;
    else if ((buf_state==`FSM_BUF_SPI_WDATA_DONE) || (buf_state==`FSM_BUF_SPI_WAIT))
    	buf_done <= 1'b0;
  end

  always@(posedge clk or negedge rst_n)//buf_state[]
  begin
    if (!rst_n)
      buf_state <= `FSM_BUF_IDLE;
    else
      case(buf_state)
        `FSM_BUF_IDLE            : if (buf_spi_wdata_done_pp) buf_state <= `FSM_BUF_SPI_WDATA_DONE;
                                   else if (buf_spi_wait_pp)  buf_state <= `FSM_BUF_SPI_WAIT      ;

        `FSM_BUF_SPI_WDATA_DONE  : buf_state <= `FSM_BUF_SPI_TX_LPC_TX;
        `FSM_BUF_SPI_TX_LPC_TX   : buf_state <= `FSM_BUF_LPC_TX_BUFFER;
        `FSM_BUF_LPC_TX_BUFFER   : buf_state <= `FSM_BUF_LPC_TX;
        `FSM_BUF_LPC_TX          : if (buf_lpc_done_pp) buf_state <= `FSM_BUF_LPC_DONE_TX;
        `FSM_BUF_LPC_DONE_TX     : if (buf_cnt==buf_spi_cmd_size) buf_state <= `FSM_BUF_DONE;
                                   else buf_state <= `FSM_BUF_SPI_TX_LPC_TX;

        `FSM_BUF_SPI_WAIT        : buf_state <= `FSM_BUF_SPI_RX_LPC_RX;
        `FSM_BUF_SPI_RX_LPC_RX   : buf_state <= `FSM_BUF_LPC_RX_BUFFER;
        `FSM_BUF_LPC_RX_BUFFER   : buf_state <= `FSM_BUF_LPC_RX;
        `FSM_BUF_LPC_RX          : if (buf_lpc_done_pp) buf_state <= `FSM_BUF_LPC_DONE_RX;
        `FSM_BUF_LPC_DONE_RX     : buf_state <= `FSM_BUF_LPC_RX_SPI_RX;
        `FSM_BUF_LPC_RX_SPI_RX   : if (buf_cnt==buf_spi_cmd_size) buf_state <= `FSM_BUF_SPI_WAIT_DONE;
                                   else buf_state <= `FSM_BUF_SPI_RX_LPC_RX;
        `FSM_BUF_SPI_WAIT_DONE   : buf_state <= `FSM_BUF_DONE;

        `FSM_BUF_DONE            : buf_state <= `FSM_BUF_IDLE;
        default                  : buf_state <= `FSM_BUF_IDLE;
      endcase
  end

  always@(posedge clk or negedge rst_n)//buf_cnt[]
  begin
    if (!rst_n)
      buf_cnt <= 5'b0;
    else if (buf_state==`FSM_BUF_IDLE)
      buf_cnt <= 5'b0;
    else if ((buf_state==`FSM_BUF_LPC_DONE_TX) || (buf_state==`FSM_BUF_LPC_RX_SPI_RX)) begin
      if (buf_cnt==buf_spi_cmd_size)
        buf_cnt <= 5'b0;
      else
        buf_cnt <= buf_cnt + 1'b1;
    end
  end

  always@(posedge clk or negedge rst_n)//BUFFER: SPI to BUFFER SPI
  begin
    if (!rst_n) begin
      buf_spi_cmd[7:0]      <=  8'b0;
      buf_spi_addr[23:0]    <= 24'b0;
      buf_spi_wdata[31:0]   <= 32'b0;
    end
    else if (buf_state==`FSM_BUF_SPI_WDATA_DONE) begin
      buf_spi_cmd[7:0]    <= spi_cmd[7:0]   ;
      buf_spi_addr[23:0]  <= spi_addr[23:0] ;
      buf_spi_wdata[31:0] <= spi_wdata[31:0];
    end
    else if (buf_state==`FSM_BUF_SPI_WAIT) begin
      buf_spi_cmd[7:0]    <= spi_cmd[7:0]  ;
      buf_spi_addr[23:0]  <= spi_addr[23:0];
      buf_spi_wdata[31:0] <= 32'b0         ;
    end
  end

  assign buf_spi_cmd_dir  = buf_spi_cmd[7];
  assign buf_spi_cmd_rsvd = buf_spi_cmd[6];
  assign buf_spi_cmd_size = buf_spi_cmd[5:0];

  always@(posedge clk or negedge rst_n)//BUFFER: BUFFER SPI TO SPI
  begin
    if (!rst_n)
      spi_rdata[31:0] <= 32'b0;
    else if (buf_state==`FSM_BUF_SPI_WAIT_DONE)
      spi_rdata[31:0] <= buf_spi_rdata[31:0];
  end

  always@(posedge clk or negedge rst_n)//BUFFER: BUFFER SPI to BUFFER LPC
  begin
    if (!rst_n) begin
    	 buf_lpc_start[3:0] <=  4'b0;
       buf_lpc_ct[1:0]    <=  2'b0;
       buf_lpc_dir        <=  1'b0;
       buf_lpc_addr[15:0] <= 16'b0;
       buf_lpc_wdata[7:0] <=  8'b0;
    end
  	else if (buf_state==`FSM_BUF_SPI_TX_LPC_TX) begin
    	 buf_lpc_start[3:0] <=  4'b0101;
       buf_lpc_ct[1:0]    <=  2'b0;
       buf_lpc_dir        <=  1'b1;
       buf_lpc_addr[15:0] <= buf_spi_addr[15:0] + {10'b0, buf_cnt[5:0]};
       buf_lpc_wdata[7:0] <= (buf_cnt[5:0]==6'b00_0000) ? buf_spi_wdata[7:0]   :
                             (buf_cnt[5:0]==6'b00_0001) ? buf_spi_wdata[15:8]  :
                             (buf_cnt[5:0]==6'b00_0010) ? buf_spi_wdata[23:16] :
                             (buf_cnt[5:0]==6'b00_0011) ? buf_spi_wdata[31:24] : 8'b0;
    end
  	else if (buf_state==`FSM_BUF_SPI_RX_LPC_RX) begin
    	 buf_lpc_start[3:0] <=  4'b0101;
       buf_lpc_ct[1:0]    <=  2'b0;
       buf_lpc_dir        <=  1'b0;
       buf_lpc_addr[15:0] <= buf_spi_addr[15:0] + {10'b0, buf_cnt[5:0]};
       buf_lpc_wdata[7:0] <= 8'b0;
    end
  end

  always@(posedge clk or negedge rst_n)//BUFFER: BUFFER LPC TO BUFFER SPI
  begin
  	if (!rst_n)
  	  buf_spi_rdata[31:0] <= 32'b0;
  	else if (buf_state==`FSM_BUF_SPI_WAIT)
  	  buf_spi_rdata[31:0] <= 32'b0;
  	else if ((buf_state==`FSM_BUF_LPC_RX_SPI_RX) && (buf_cnt==6'b00_0000))
  	  buf_spi_rdata[7:0]   <= buf_lpc_rdata[7:0];
  	else if ((buf_state==`FSM_BUF_LPC_RX_SPI_RX) && (buf_cnt==6'b00_0001))
  	  buf_spi_rdata[15:8]  <= buf_lpc_rdata[7:0];
  	else if ((buf_state==`FSM_BUF_LPC_RX_SPI_RX) && (buf_cnt==6'b00_0010))
  	  buf_spi_rdata[23:16] <= buf_lpc_rdata[7:0];
  	else if ((buf_state==`FSM_BUF_LPC_RX_SPI_RX) && (buf_cnt==6'b00_0011))
  	  buf_spi_rdata[31:24] <= buf_lpc_rdata[7:0];
  end

  always@(posedge clk or negedge rst_n)//BUFFER: BUFFER LPC TO LPC
  begin
    if (!rst_n) begin
      lpc_start[3:0] <=  4'b0;
      lpc_ct[1:0]    <=  2'b0;
      lpc_dir        <=  1'b0;
      lpc_addr[15:0] <= 16'b0;
      lpc_wdata[7:0] <=  8'b0;
    end
    else if (buf_state==`FSM_BUF_LPC_TX_BUFFER) begin
      lpc_start[3:0] <= buf_lpc_start[3:0];
      lpc_ct[1:0]    <= buf_lpc_ct[1:0]   ;
      lpc_dir        <= buf_lpc_dir       ;
      lpc_addr[15:0] <= buf_lpc_addr[15:0];
      lpc_wdata[7:0] <= buf_lpc_wdata[7:0];
    end
    else if (buf_state==`FSM_BUF_LPC_RX_BUFFER) begin
      lpc_start[3:0] <= buf_lpc_start[3:0];
      lpc_ct[1:0]    <= buf_lpc_ct[1:0]   ;
      lpc_dir        <= buf_lpc_dir       ;
      lpc_addr[15:0] <= buf_lpc_addr[15:0];
      lpc_wdata[7:0] <= 8'b0              ;
    end
  end

  always@(posedge clk or negedge rst_n)//BUFFER: LPC TO BUFFER LPC
  begin
    if (!rst_n)
      buf_lpc_rdata[7:0] <= 8'b0;
    else if (buf_state==`FSM_BUF_LPC_DONE_RX)
      buf_lpc_rdata[7:0] <= lpc_rdata[7:0];
  end

////////////////////////////////////////////////////////////////////////LPC SIDE
//lpc_en_pp
  assign lpc_en = buf_lpc_tx | buf_lpc_rx;

  always@(posedge lpc_clk or negedge lpc_rst_n)
  begin
    if (!lpc_rst_n)
      lpc_en_dly[2:0] <= 3'b000;
    else
      lpc_en_dly[2:0] <= {lpc_en_dly[1:0], lpc_en};
  end

  assign lpc_en_pp = (lpc_en_dly[2:1]==2'b01);

//lpc_done
  always@(posedge lpc_clk or negedge lpc_rst_n)
  begin
    if (!lpc_rst_n)
      lpc_done <= 1'b0;
    else if (lpc_state==`FSM_LPC_DONE)
      lpc_done <= 1'b1;
    else
      lpc_done <= 1'b0;
  end

  always@(posedge lpc_clk or negedge lpc_rst_n)
  begin
    if (!lpc_rst_n)
      lpc_state <= `FSM_LPC_IDLE;
    else
      case(lpc_state)
        `FSM_LPC_IDLE      : if (lpc_en_pp==1'b1) lpc_state <= `FSM_LPC;
        `FSM_LPC           : if (lpc_ct[1:0]==`LPC_CYCTYPE_IO)
                               lpc_state <= `FSM_LPC_START0;
                             else
                               lpc_state <= `FSM_LPC_FAULT;
        `FSM_LPC_START0    : lpc_state <= `FSM_LPC_START ;
        `FSM_LPC_START     : lpc_state <= `FSM_LPC_CTDIR ;
        `FSM_LPC_CTDIR     : lpc_state <= `FSM_LPC_ADDR_3;
        `FSM_LPC_ADDR_3    : lpc_state <= `FSM_LPC_ADDR_2;
        `FSM_LPC_ADDR_2    : lpc_state <= `FSM_LPC_ADDR_1;
        `FSM_LPC_ADDR_1    : lpc_state <= `FSM_LPC_ADDR_0;
        `FSM_LPC_ADDR_0    : if (lpc_dir==`LPC_DIRECTION_RD)//Read
                               lpc_state <= `FSM_LPC_RTAR_0;
                             else//write
                               lpc_state <= `FSM_LPC_WDATA_0;
        `FSM_LPC_WDATA_0   : lpc_state <= `FSM_LPC_WDATA_1;
        `FSM_LPC_WDATA_1   : lpc_state <= `FSM_LPC_WTAR_0;
        `FSM_LPC_WTAR_0    : lpc_state <= `FSM_LPC_WTAR_1;
        `FSM_LPC_WTAR_1    : lpc_state <= `FSM_LPC_WSYNC;

        `FSM_LPC_WSYNC     : if (lpc_adi[3:0]==`LPC_SYNC_RDY)
                               lpc_state <= `FSM_LPC_TAR2_0;
                             else if (lpc_sync_timeout==1'b1)
                               lpc_state <= `FSM_LPC_FAULT;
        `FSM_LPC_RTAR_0    : lpc_state <= `FSM_LPC_RTAR_1;
        `FSM_LPC_RTAR_1    : lpc_state <= `FSM_LPC_RSYNC;
        `FSM_LPC_RSYNC     : if (lpc_adi[3:0]==`LPC_SYNC_RDY)
                               lpc_state <= `FSM_LPC_RDATA_0;
                             else if (lpc_sync_timeout==1'b1)
                               lpc_state <= `FSM_LPC_FAULT;
        `FSM_LPC_RDATA_0   : lpc_state <= `FSM_LPC_RDATA_1;
        `FSM_LPC_RDATA_1   : lpc_state <= `FSM_LPC_TAR2_0;
        `FSM_LPC_TAR2_0    : lpc_state <= `FSM_LPC_TAR2_1;
        `FSM_LPC_TAR2_1    : lpc_state <= `FSM_LPC_DONE;
        `FSM_LPC_FAULT     : lpc_state <= `FSM_LPC_DONE;
        `FSM_LPC_DONE      : lpc_state <= `FSM_LPC_IDLE;
        default            : lpc_state <= `FSM_LPC_IDLE;
      endcase
  end

  always@(posedge lpc_clk or negedge lpc_rst_n)
  begin
    if (!lpc_rst_n)
      lpc_sync_cnt <= 4'd0;
    else if ((lpc_state==`FSM_LPC_RSYNC) || (lpc_state==`FSM_LPC_WSYNC)) begin
      if (lpc_sync_cnt==4'd15)
        lpc_sync_cnt <= 4'd0;
      else
        lpc_sync_cnt <= lpc_sync_cnt + 1'b1;
    end
    else
      lpc_sync_cnt <= 4'b0000;
  end

  assign lpc_sync_timeout = (lpc_sync_cnt==4'd15);

  always@(posedge lpc_clk or negedge lpc_rst_n) //lpc_ado_en
  begin
    if (!lpc_rst_n)
      lpc_ado_en <= 1'b0;
    else if (lpc_state==`FSM_LPC_IDLE)
      lpc_ado_en <= 1'b0;
    else if (lpc_state==`FSM_LPC_START0)
      lpc_ado_en <= 1'b1;
    else if (lpc_state==`FSM_LPC_RTAR_1)
      lpc_ado_en <= 1'b0;
    else if (lpc_state==`FSM_LPC_WTAR_1)
      lpc_ado_en <= 1'b0;
    else if (lpc_state==`FSM_LPC_FAULT)
      lpc_ado_en <= 1'b0;
  end

  always@(posedge lpc_clk or negedge lpc_rst_n) //lpc_ado[]
  begin
    if (!lpc_rst_n)
      lpc_ado[3:0] <= 4'b0000;
    else if (lpc_state==`FSM_LPC_IDLE)
      lpc_ado[3:0] <= 4'b0000;
    else if (lpc_state==`FSM_LPC_START0)
      lpc_ado[3:0] <= lpc_start[3:0];
    else if (lpc_state==`FSM_LPC_START)
      lpc_ado[3:0] <= lpc_start[3:0];
    else if (lpc_state==`FSM_LPC_CTDIR)
      lpc_ado[3:0] <= {lpc_ct[1:0], lpc_dir, 1'b0};
    else if (lpc_state==`FSM_LPC_ADDR_3)
      lpc_ado[3:0] <= lpc_addr[15:12];
    else if (lpc_state==`FSM_LPC_ADDR_2)
      lpc_ado[3:0] <= lpc_addr[11:8];
    else if (lpc_state==`FSM_LPC_ADDR_1)
      lpc_ado[3:0] <= lpc_addr[7:4];
    else if (lpc_state==`FSM_LPC_ADDR_0)
      lpc_ado[3:0] <= lpc_addr[3:0];
    else if (lpc_state==`FSM_LPC_RTAR_0)
      lpc_ado[3:0] <= 4'b1111;
//  else if (lpc_state==`FSM_LPC_RTAR_1)//rd
//    lpc_ado[3:0] <= 4'b0000;
    else if (lpc_state==`FSM_LPC_WDATA_0)
      lpc_ado[3:0] <= lpc_wdata[3:0];
    else if (lpc_state==`FSM_LPC_WDATA_1)
      lpc_ado[3:0] <= lpc_wdata[7:4];
    else if (lpc_state==`FSM_LPC_WTAR_0)
      lpc_ado[3:0] <= 4'b1111;
//  else if (lpc_state==`FSM_LPC_WTAR_1)
//    lpc_ado[3:0] <= 4'b0000;
  end

  always@(posedge lpc_clk or negedge lpc_rst_n)//lpc_rdata[7:0]
  begin
    if (!lpc_rst_n)
      lpc_rdata[7:0] <= 8'hFF;
    else if (lpc_state==`FSM_LPC_RDATA_0)
      lpc_rdata[3:0] <= lpc_adi[3:0];
    else if (lpc_state==`FSM_LPC_RDATA_1)
      lpc_rdata[7:4] <= lpc_adi[3:0];
    else if (lpc_state==`FSM_LPC_FAULT)
      lpc_rdata[7:0] <= 8'hFF;
  end

  always@(posedge lpc_clk or negedge lpc_rst_n)//lpc_frame_n
  begin
    if (!lpc_rst_n)
      lpc_frame_n <= 1'b1;
    else if (lpc_state==`FSM_LPC_START0)
      lpc_frame_n <= 1'b0;
    else if (lpc_state==`FSM_LPC_CTDIR)
      lpc_frame_n <= 1'b1;
  end

endmodule

