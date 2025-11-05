/*********************************************************
                              
************************************************************************/


module LPC(
input         CLK_33M_CPLD,
input         LPC_rst_s,
input         PCH_LPC_FRAME_N,
input [7:0]   data_buf,

inout [3:0]   PCH_LPC_LAD,
inout [7:0]   L_AD,

output reg[31:0]    lpc_addr,
output reg          CS_BIOS_s,
output reg          CS_CPLD_s,
output reg          CS4_CPLD_CS_s,
output reg          CS5_CPLD_CS_s,
output reg          CS6_CPLD_CS_s,
output reg          CS7_CPLD_CS_s,  
output reg          MEM3V3_WE_s,
output reg          MEM3V3_OE_s,
output reg[7:0]     lpc_P80_data
          );

/***********LPC 模块 Start **********************************************************/ 
   `define IDLE              6'h00
   `define START             6'h01
   `define MEM_RD            6'h02
   `define MEM_RD_ADDR_LCLK1 6'h03
   `define MEM_RD_ADDR_LCLK2 6'h04
   `define MEM_RD_ADDR_LCLK3 6'h05
   `define MEM_RD_ADDR_LCLK4 6'h06
   `define MEM_RD_ADDR_LCLK5 6'h20
   `define MEM_RD_ADDR_LCLK6 6'h21
   `define MEM_RD_ADDR_LCLK7 6'h22
   `define MEM_RD_ADDR_LCLK8 6'h23
   `define MEM_RD_TAR_LCLK1  6'h07
   `define MEM_RD_TAR_LCLK2  6'h08
   `define MEM_RD_SYNC1      6'h09//增加sync时间，前4个sync送0101表示short wait，最后一个sync送0000表示ready
   `define MEM_RD_SYNC2      6'h0a
   `define MEM_RD_SYNC3      6'h0b
   `define MEM_RD_SYNC4      6'h0c
   `define MEM_RD_SYNC5      6'h0d
   `define MEM_RD_DATA_LCLK1 6'h0e
   `define MEM_RD_DATA_LCLK2 6'h0f
   `define MEM_WR            6'h10
   `define MEM_WR_ADDR_LCLK1 6'h11
   `define MEM_WR_ADDR_LCLK2 6'h12
   `define MEM_WR_ADDR_LCLK3 6'h13
   `define MEM_WR_ADDR_LCLK4 6'h14
   `define MEM_WR_ADDR_LCLK5 6'h24
   `define MEM_WR_ADDR_LCLK6 6'h25
   `define MEM_WR_ADDR_LCLK7 6'h26
   `define MEM_WR_ADDR_LCLK8 6'h27
   `define MEM_WR_DATA_LCLK1 6'h15
   `define MEM_WR_DATA_LCLK2 6'h16
   `define MEM_WR_TAR_LCLK1  6'h17
   `define MEM_WR_TAR_LCLK2  6'h18
   `define MEM_WR_SYNC1      6'h19//增加sync时间，前4个sync送0101表示short wait，最后一个sync送0000表示ready
   `define MEM_WR_SYNC2      6'h1a
   `define MEM_WR_SYNC3      6'h1b
   `define MEM_WR_SYNC4      6'h1c
   `define MEM_WR_SYNC5      6'h1d
   `define LAST_TAR_LCLK1    6'h1e
   `define LAST_TAR_LCLK2    6'h1f
   
   `define IO_WR             6'h28
   `define IO_WR_ADDR_LCLK1  6'h29
   `define IO_WR_ADDR_LCLK2  6'h2a
   `define IO_WR_ADDR_LCLK3  6'h2d
   `define IO_WR_ADDR_LCLK4  6'h2e
   `define IO_WR_DATA_LCLK1  6'h2f
   `define IO_WR_DATA_LCLK2  6'h30
   `define IO_WR_TAR_LCLK1   6'h31
   `define IO_WR_TAR_LCLK2   6'h32
   `define IO_WR_SYNC1       6'h33//增加sync时间，前4个sync送0101表示short wait，最后一个sync送0000表示ready
   `define IO_WR_SYNC2       6'h34
   `define IO_WR_SYNC3       6'h35
   `define IO_WR_SYNC4       6'h36
   `define IO_WR_SYNC5       6'h37
   
// signals--------------------------------------
reg[5:0]          current_state;
wire[5:0]         LPC_next_state;
wire[7:0]         rd_addr_en;
wire[1:0]         wr_data_en;
wire[1:0]         wr_P80_data_en;
wire[3:0]         wr_P80_addr_en;
reg               send_en;
reg[15:0]         lpc_P80_addr;
reg[3:0]          lad_in_data;
wire ADDR_hit_s;
reg CS_BIOS_hit_s;
reg CS_CPLD_hit_s;
reg CS4_CPLD_hit_s;
reg CS5_CPLD_hit_s;
reg CS6_CPLD_hit_s;
reg CS7_CPLD_hit_s;
reg L_data_en;
reg[7:0] lpc_data_in;
   
// --------------------------------------------------------------------------
// FSM -- state machine supporting LPC I/O read & I/O write only
// --------------------------------------------------------------------------
always @ (posedge CLK_33M_CPLD or negedge LPC_rst_s) 
begin
   if (!LPC_rst_s)
	   current_state <= `IDLE ;
   else
	   current_state <= LPC_next_state;
end



assign LPC_next_state = ((current_state == `IDLE ) && (PCH_LPC_FRAME_N == 1'b0) && (PCH_LPC_LAD == 4'h0)) ? `START :
                     ((current_state == `START) && (PCH_LPC_FRAME_N == 1'b0) && (PCH_LPC_LAD == 4'h0)) ? `START :
                     ((current_state == `START) && (PCH_LPC_FRAME_N == 1'b1) && (PCH_LPC_LAD == 4'h2)) ? `IO_WR :
					           ((current_state == `START) && (PCH_LPC_FRAME_N == 1'b1) && (PCH_LPC_LAD == 4'h4)) ? `MEM_RD :
                     ((current_state == `START) && (PCH_LPC_FRAME_N == 1'b1) && (PCH_LPC_LAD == 4'h6)) ? `MEM_WR :
                    ((current_state == `LAST_TAR_LCLK2) &&(!PCH_LPC_FRAME_N )) ? `START :
					          (!PCH_LPC_FRAME_N ) ? `IDLE :
                    (current_state == `MEM_RD           ) ? `MEM_RD_ADDR_LCLK1 :
                    (current_state == `MEM_RD_ADDR_LCLK1) ? `MEM_RD_ADDR_LCLK2 :
                    (current_state == `MEM_RD_ADDR_LCLK2) ? `MEM_RD_ADDR_LCLK3 :
                    (current_state == `MEM_RD_ADDR_LCLK3) ? `MEM_RD_ADDR_LCLK4 :
                    (current_state == `MEM_RD_ADDR_LCLK4) ? `MEM_RD_ADDR_LCLK5 :
                    (current_state == `MEM_RD_ADDR_LCLK5) ? `MEM_RD_ADDR_LCLK6 :
                    (current_state == `MEM_RD_ADDR_LCLK6) ? `MEM_RD_ADDR_LCLK7 :
                    (current_state == `MEM_RD_ADDR_LCLK7) ? `MEM_RD_ADDR_LCLK8 :
                    (current_state == `MEM_RD_ADDR_LCLK8) ? `MEM_RD_TAR_LCLK1 :
                    (current_state == `MEM_RD_TAR_LCLK1 ) ? `MEM_RD_TAR_LCLK2  :
                  //  ((current_state == `MEM_RD_TAR_LCLK2 ) && (addr_hit == 1'b0))? `IDLE       :
                  //  ((current_state == `MEM_RD_TAR_LCLK2 ) && (addr_hit == 1'b1))? `MEM_RD_SYNC :
                    (current_state == `MEM_RD_TAR_LCLK2 ) ? `MEM_RD_SYNC1 :
                    (current_state == `MEM_RD_SYNC1     ) ? `MEM_RD_SYNC2 :
                    (current_state == `MEM_RD_SYNC2     ) ? `MEM_RD_SYNC3 :
                    (current_state == `MEM_RD_SYNC3     ) ? `MEM_RD_SYNC4 :
                    (current_state == `MEM_RD_SYNC4     ) ? `MEM_RD_SYNC5 :
                    (current_state == `MEM_RD_SYNC5     ) ? `MEM_RD_DATA_LCLK1 :
                    (current_state == `MEM_RD_DATA_LCLK1) ? `MEM_RD_DATA_LCLK2 :
                    (current_state == `MEM_RD_DATA_LCLK2) ? `LAST_TAR_LCLK1   :
                    (current_state == `MEM_WR           ) ? `MEM_WR_ADDR_LCLK1 :
                    (current_state == `MEM_WR_ADDR_LCLK1) ? `MEM_WR_ADDR_LCLK2 :
                    (current_state == `MEM_WR_ADDR_LCLK2) ? `MEM_WR_ADDR_LCLK3 :
                    (current_state == `MEM_WR_ADDR_LCLK3) ? `MEM_WR_ADDR_LCLK4 :
                    (current_state == `MEM_WR_ADDR_LCLK4) ? `MEM_WR_ADDR_LCLK5 :
                    (current_state == `MEM_WR_ADDR_LCLK5) ? `MEM_WR_ADDR_LCLK6 :
                    (current_state == `MEM_WR_ADDR_LCLK6) ? `MEM_WR_ADDR_LCLK7 :
                    (current_state == `MEM_WR_ADDR_LCLK7) ? `MEM_WR_ADDR_LCLK8 :
                    (current_state == `MEM_WR_ADDR_LCLK8) ? `MEM_WR_DATA_LCLK1 :
                    (current_state == `MEM_WR_DATA_LCLK1) ? `MEM_WR_DATA_LCLK2 :
                    (current_state == `MEM_WR_DATA_LCLK2) ? `MEM_WR_TAR_LCLK1  :
                    (current_state == `MEM_WR_TAR_LCLK1 ) ? `MEM_WR_TAR_LCLK2  :
                 // ((current_state == `MEM_WR_TAR_LCLK2 ) && (addr_hit == 1'b0))? `IDLE       :
                 // ((current_state == `MEM_WR_TAR_LCLK2 ) && (addr_hit == 1'b1))? `MEM_WR_SYNC :
                    (current_state == `MEM_WR_TAR_LCLK2 ) ? `MEM_WR_SYNC1 :
                    (current_state == `MEM_WR_SYNC1     ) ? `MEM_WR_SYNC2 :
                    (current_state == `MEM_WR_SYNC2     ) ? `MEM_WR_SYNC3 :
                    (current_state == `MEM_WR_SYNC3     ) ? `MEM_WR_SYNC4 :
                    (current_state == `MEM_WR_SYNC4     ) ? `MEM_WR_SYNC5 :
                    (current_state == `MEM_WR_SYNC5     ) ? `LAST_TAR_LCLK1   :
                    
                    (current_state == `IO_WR           ) ? `IO_WR_ADDR_LCLK1 :
                    (current_state == `IO_WR_ADDR_LCLK1) ? `IO_WR_ADDR_LCLK2 :
                    (current_state == `IO_WR_ADDR_LCLK2) ? `IO_WR_ADDR_LCLK3 :
                    (current_state == `IO_WR_ADDR_LCLK3) ? `IO_WR_ADDR_LCLK4 :
                    (current_state == `IO_WR_ADDR_LCLK4) ? `IO_WR_DATA_LCLK1 :
                    (current_state == `IO_WR_DATA_LCLK1) ? `IO_WR_DATA_LCLK2 :
                    (current_state == `IO_WR_DATA_LCLK2) ? `IO_WR_TAR_LCLK1  :
                    (current_state == `IO_WR_TAR_LCLK1 ) ? `IO_WR_TAR_LCLK2  :
                    (current_state == `IO_WR_TAR_LCLK2 ) ? `IO_WR_SYNC1 :
                    (current_state == `IO_WR_SYNC1     ) ? `IO_WR_SYNC2 :
                    (current_state == `IO_WR_SYNC2     ) ? `IO_WR_SYNC3 :
                    (current_state == `IO_WR_SYNC3     ) ? `IO_WR_SYNC4 :
                    (current_state == `IO_WR_SYNC4     ) ? `IO_WR_SYNC5 :
                    (current_state == `IO_WR_SYNC5     ) ? `LAST_TAR_LCLK1   :
                    (current_state == `LAST_TAR_LCLK1  ) ? `LAST_TAR_LCLK2   :
                    `IDLE;


// -------------------------------------------------------------------------
// FSM output logic - Control state machine - LPC I/O read & I/O write only
// -------------------------------------------------------------------------


assign rd_addr_en = (LPC_next_state == `MEM_RD_ADDR_LCLK1) ? 8'b10000000 :
                    (LPC_next_state == `MEM_RD_ADDR_LCLK2) ? 8'b01000000 :
                    (LPC_next_state == `MEM_RD_ADDR_LCLK3) ? 8'b00100000 :
                    (LPC_next_state == `MEM_RD_ADDR_LCLK4) ? 8'b00010000 :
                    (LPC_next_state == `MEM_RD_ADDR_LCLK5) ? 8'b00001000 :
                    (LPC_next_state == `MEM_RD_ADDR_LCLK6) ? 8'b00000100 :
                    (LPC_next_state == `MEM_RD_ADDR_LCLK7) ? 8'b00000010 :
                    (LPC_next_state == `MEM_RD_ADDR_LCLK8) ? 8'b00000001 :
                    (LPC_next_state == `MEM_WR_ADDR_LCLK1) ? 8'b10000000 :
                    (LPC_next_state == `MEM_WR_ADDR_LCLK2) ? 8'b01000000 :
                    (LPC_next_state == `MEM_WR_ADDR_LCLK3) ? 8'b00100000 :
                    (LPC_next_state == `MEM_WR_ADDR_LCLK4) ? 8'b00010000 : 
                    (LPC_next_state == `MEM_WR_ADDR_LCLK5) ? 8'b00001000 :
                    (LPC_next_state == `MEM_WR_ADDR_LCLK6) ? 8'b00000100 :
                    (LPC_next_state == `MEM_WR_ADDR_LCLK7) ? 8'b00000010 :
                    (LPC_next_state == `MEM_WR_ADDR_LCLK8) ? 8'b00000001 :
                    8'b00000000;

assign wr_data_en = (LPC_next_state == `MEM_WR_DATA_LCLK1) ? 2'b01 :
                    (LPC_next_state == `MEM_WR_DATA_LCLK2) ? 2'b10 :
                    2'b00;
                    
assign wr_P80_data_en =  (LPC_next_state == `IO_WR_DATA_LCLK1) ? 2'b01 :
                         (LPC_next_state == `IO_WR_DATA_LCLK2) ? 2'b10 :
                         2'b00;
                         
assign wr_P80_addr_en =  (LPC_next_state == `IO_WR_ADDR_LCLK1) ? 4'b1000 :
                         (LPC_next_state == `IO_WR_ADDR_LCLK2) ? 4'b0100 :
                         (LPC_next_state == `IO_WR_ADDR_LCLK3) ? 4'b0010 :
                         (LPC_next_state == `IO_WR_ADDR_LCLK4) ? 4'b0001 : 
                         4'b0000;                      

always @ (posedge CLK_33M_CPLD or negedge LPC_rst_s) begin
   if (!LPC_rst_s)
        send_en <= 1'b0;
   else if (!PCH_LPC_FRAME_N)  send_en <= 1'b0;  
   else if (LPC_next_state == `MEM_RD_TAR_LCLK2 ||LPC_next_state == `MEM_RD_SYNC1||
            LPC_next_state == `MEM_RD_SYNC2     ||LPC_next_state == `MEM_RD_SYNC3 ||
            LPC_next_state == `MEM_WR_TAR_LCLK2 ||LPC_next_state == `MEM_WR_SYNC1 ||
            LPC_next_state == `MEM_WR_SYNC2     ||LPC_next_state == `MEM_WR_SYNC3 ||//wait_en
            
            LPC_next_state == `MEM_RD_SYNC4     ||LPC_next_state == `MEM_WR_SYNC4||//sync_en
            
            LPC_next_state == `MEM_WR_SYNC5     ||LPC_next_state == `MEM_RD_DATA_LCLK2||//tar_F
            
            LPC_next_state == `MEM_RD_SYNC5     ||LPC_next_state == `MEM_RD_DATA_LCLK1||//rd_data_en
            
            LPC_next_state == `IO_WR_TAR_LCLK2  ||LPC_next_state == `IO_WR_SYNC1||
            LPC_next_state == `IO_WR_SYNC2      ||LPC_next_state == `IO_WR_SYNC3||
            LPC_next_state == `IO_WR_SYNC4      ||LPC_next_state == `IO_WR_SYNC5 
             )
    send_en <= 1'b1;
    
   else
    send_en <= 1'b0;
end


// Register LPC Address

always @ (posedge CLK_33M_CPLD )
begin
   if (rd_addr_en[7] == 1'b1)      lpc_addr[31:28]  <= PCH_LPC_LAD;
   if (rd_addr_en[6] == 1'b1)      lpc_addr[27:24]  <= PCH_LPC_LAD;
   if (rd_addr_en[5] == 1'b1)      lpc_addr[23:20]  <= PCH_LPC_LAD;
   if (rd_addr_en[4] == 1'b1)      lpc_addr[19:16]  <= PCH_LPC_LAD;
   if (rd_addr_en[3] == 1'b1)      lpc_addr[15:12]  <= PCH_LPC_LAD;
   if (rd_addr_en[2] == 1'b1)      lpc_addr[11: 8]  <= PCH_LPC_LAD;
   if (rd_addr_en[1] == 1'b1)      lpc_addr[ 7: 4]  <= PCH_LPC_LAD;
   if (rd_addr_en[0] == 1'b1)      lpc_addr[ 3: 0]  <= PCH_LPC_LAD;
end

always @ (posedge CLK_33M_CPLD ) 
begin	
   if (wr_P80_addr_en[3]) 	lpc_P80_addr[15:12] <= PCH_LPC_LAD;
   if (wr_P80_addr_en[2]) 	lpc_P80_addr[11: 8] <= PCH_LPC_LAD;
   if (wr_P80_addr_en[1]) 	lpc_P80_addr[7:  4] <= PCH_LPC_LAD;
   if (wr_P80_addr_en[0]) 	lpc_P80_addr[3:  0] <= PCH_LPC_LAD;
end


always @ (posedge CLK_33M_CPLD or negedge LPC_rst_s) begin
if (!LPC_rst_s) lad_in_data <= 4'b1111;
else
begin
 	 case(LPC_next_state)
 	   `MEM_RD_TAR_LCLK1:
   	     lad_in_data <=4'b0101;
   	   `MEM_RD_TAR_LCLK2:
   	     lad_in_data <=4'b0101;
   	   `MEM_RD_SYNC1:
   	     lad_in_data <=4'b0101;  
   	   `MEM_RD_SYNC2:
   	     lad_in_data <=4'b0101; 
   	   `MEM_RD_SYNC3:
   	     lad_in_data <=4'b0101; 

   	   `MEM_WR_TAR_LCLK1:
   	     lad_in_data <=4'b0101;
   	   `MEM_WR_TAR_LCLK2:
   	     lad_in_data <=4'b0101;
   	   `MEM_WR_SYNC1:
   	     lad_in_data <=4'b0101; 
   	   `MEM_WR_SYNC2:
   	     lad_in_data <=4'b0101; 
   	   `MEM_WR_SYNC3:
   	     lad_in_data <=4'b0101;
   	      
   	   `MEM_WR_SYNC4:
   	     lad_in_data <=4'b0000; //sync5数据   	     
   	   `MEM_RD_SYNC4:
   	     lad_in_data <=4'b0000;  
   	     
   	   `MEM_RD_SYNC5:
   	     lad_in_data <=data_buf[3:0] ;
   	   `MEM_RD_DATA_LCLK1:
   	     lad_in_data <=data_buf[7:4] ;
  	    
   	   `MEM_RD_DATA_LCLK2://last_tar_clk1
   	     lad_in_data <=4'b1111;//tar data
   	   `MEM_WR_SYNC5://last_tar_clk1
   	     lad_in_data <=4'b1111;//tar data
   	   
   	   `IO_WR_TAR_LCLK1:
   	     lad_in_data <=4'bzzzz; //4'b0101
   	   `IO_WR_TAR_LCLK2:
   	     lad_in_data <=4'bzzzz; //4'b0101
   	   `IO_WR_SYNC1:
   	     lad_in_data <=4'bzzzz; //4'b0101
   	   `IO_WR_SYNC2:
   	     lad_in_data <=4'bzzzz; //4'b0101
   	   `IO_WR_SYNC3:
   	     lad_in_data <=4'bzzzz; //4'b0101 	      
   	   `IO_WR_SYNC4:
   	     lad_in_data <=4'bzzzz; //sync5数据  4'b0000
   	   `IO_WR_SYNC5://last_tar_clk1
   	     lad_in_data <=4'bzzzz;//4'b1111//tar data
   	     
   	   default:    	   	  	
    	   lad_in_data <=4'b1111; 
     endcase   
 end
end

assign PCH_LPC_LAD = send_en ? lad_in_data: 4'bzzzz; 


always @ (posedge CLK_33M_CPLD or negedge LPC_rst_s) 
begin
   if (!LPC_rst_s) 
   begin
   	 MEM3V3_WE_s <=1'b1;
   end
   else
   begin
   	 case(LPC_next_state)
   	   `MEM_WR_SYNC1:
   	     MEM3V3_WE_s <=1'b0;
   	   `MEM_WR_SYNC2:
   	     MEM3V3_WE_s <=1'b0;
   	   `MEM_WR_SYNC3:
   	     MEM3V3_WE_s <=1'b0;
   	   `MEM_WR_SYNC4:
   	     MEM3V3_WE_s <=1'b0;
   	   `MEM_WR_SYNC5:
   	     MEM3V3_WE_s <=1'b1; 
   	   default: 	  	
    	   MEM3V3_WE_s <=1'b1; 
     endcase   
   end
end

always @ (posedge CLK_33M_CPLD or negedge LPC_rst_s) 
begin
   if (!LPC_rst_s) 
   begin
   	 MEM3V3_OE_s <=1'b1;
   end
   else
   begin
   	 case(LPC_next_state)
   	   `MEM_RD_SYNC1:
   	     MEM3V3_OE_s <=1'b0;
   	   `MEM_RD_SYNC2:
   	     MEM3V3_OE_s <=1'b0;
   	   `MEM_RD_SYNC3:
   	     MEM3V3_OE_s <=1'b0;
   	   `MEM_RD_SYNC4:
   	     MEM3V3_OE_s <=1'b0;
   	   `MEM_RD_SYNC5:
   	     MEM3V3_OE_s <=1'b0; 
	   `MEM_RD_DATA_LCLK1:
   	     MEM3V3_OE_s <=1'b0; 
	   `MEM_RD_DATA_LCLK2:
   	     MEM3V3_OE_s <=1'b0; 
	   `LAST_TAR_LCLK1:
   	     MEM3V3_OE_s <=MEM3V3_OE_s; 
   	   default: 	  	
    	   MEM3V3_OE_s <=1'b1; 
     endcase   
   end
end

assign L_ADD  =  lpc_addr[8:0];



parameter
   BASIC_ADDR     = 16'hFC00,     //w17260 20200617
   CS_BIOS_ADDR   = 16'h0000,   
   CS_BIOS_ROOM   = 16'd512,
   
   CS_CPLD_ADDR   = 16'h0000, 
   CS_CPLD_ROOM   = 16'd512,
   
   CS4_CPLD_ADDR  = 16'h2200,
   CS4_CPLD_ROOM   = 16'd512,
   
   CS5_CPLD_ADDR  = 16'h2400,
   CS5_CPLD_ROOM   = 16'd512,
   
   CS6_CPLD_ADDR  = 16'h2600,
   CS6_CPLD_ROOM   = 16'd512,
   
   CS7_CPLD_ADDR  = 16'h2800, 
   CS7_CPLD_ROOM   = 16'd512;   
   
assign ADDR_hit_s   = (lpc_addr[31:16]==BASIC_ADDR);    

always @(posedge CLK_33M_CPLD or negedge LPC_rst_s) 
begin    
  if (~LPC_rst_s) begin
  	CS_BIOS_hit_s <=1'b0;
  	CS_CPLD_hit_s <=1'b0;
  	CS4_CPLD_hit_s <=1'b0;
  	CS5_CPLD_hit_s <=1'b0; 
  	CS6_CPLD_hit_s <=1'b0;
    CS7_CPLD_hit_s <=1'b0; end 
  else  begin
  	if(ADDR_hit_s && (lpc_addr[15:0]>=CS_BIOS_ADDR) && (lpc_addr[15:0] <CS_BIOS_ADDR  + CS_BIOS_ROOM) )     CS_BIOS_hit_s <=1'b1; else CS_BIOS_hit_s <=1'b0;
    if(ADDR_hit_s && (lpc_addr[15:0]>=CS_CPLD_ADDR) && (lpc_addr[15:0] <CS_CPLD_ADDR  + CS_CPLD_ROOM) )     CS_CPLD_hit_s <=1'b1; else CS_CPLD_hit_s <=1'b0;
    if(ADDR_hit_s && (lpc_addr[15:0]>=CS4_CPLD_ADDR) && (lpc_addr[15:0]<CS4_CPLD_ADDR + CS4_CPLD_ROOM) )  CS4_CPLD_hit_s <=1'b1; else CS4_CPLD_hit_s <=1'b0;
    if(ADDR_hit_s && (lpc_addr[15:0]>=CS5_CPLD_ADDR) && (lpc_addr[15:0]<CS5_CPLD_ADDR + CS5_CPLD_ROOM) )  CS5_CPLD_hit_s <=1'b1; else CS5_CPLD_hit_s <=1'b0;
    if(ADDR_hit_s && (lpc_addr[15:0]>=CS6_CPLD_ADDR) && (lpc_addr[15:0]<CS6_CPLD_ADDR + CS6_CPLD_ROOM) )  CS6_CPLD_hit_s <=1'b1; else CS6_CPLD_hit_s <=1'b0;
    if(ADDR_hit_s && (lpc_addr[15:0]>=CS7_CPLD_ADDR) && (lpc_addr[15:0]<CS7_CPLD_ADDR + CS7_CPLD_ROOM) )  CS7_CPLD_hit_s <=1'b1; else CS7_CPLD_hit_s <=1'b0;
  end
  
end    
    
always @ (posedge CLK_33M_CPLD or negedge LPC_rst_s) 
begin
   if (!LPC_rst_s) 
   begin
   	 CS_BIOS_s <=1'b1;
   end
   else
   begin
   	 if(CS_BIOS_hit_s) 
   	 begin
    	 case(LPC_next_state)   	     
//    	   `MEM_RD_TAR_LCLK1:  CS_BIOS_s <=1'b0;   	     
    	   `MEM_RD_TAR_LCLK2:  CS_BIOS_s <=1'b0;   	     
    	   `MEM_RD_SYNC1:      CS_BIOS_s <=1'b0;    	     
    	   `MEM_RD_SYNC2:      CS_BIOS_s <=1'b0;    	     
    	   `MEM_RD_SYNC3:      CS_BIOS_s <=1'b0;    	     
    	   `MEM_RD_SYNC4:      CS_BIOS_s <=1'b0;   	     
    	   `MEM_RD_SYNC5:      CS_BIOS_s <=1'b0;   	     
    	   `MEM_RD_DATA_LCLK1: CS_BIOS_s <=1'b0;   	     
    	   `MEM_RD_DATA_LCLK2: CS_BIOS_s <=1'b0;    
 //   	   `MEM_WR_DATA_LCLK1: CS_BIOS_s <=1'b0;
    	   `MEM_WR_DATA_LCLK2: CS_BIOS_s <=1'b0;
    	   `MEM_WR_TAR_LCLK1:  CS_BIOS_s <=1'b0;
    	   `MEM_WR_TAR_LCLK2:  CS_BIOS_s <=1'b0;
    	   `MEM_WR_SYNC1:      CS_BIOS_s <=1'b0;
    	   `MEM_WR_SYNC2:      CS_BIOS_s <=1'b0;
    	   `MEM_WR_SYNC3:      CS_BIOS_s <=1'b0;
    	   `MEM_WR_SYNC4:      CS_BIOS_s <=1'b0;
    	   `MEM_WR_SYNC5:      CS_BIOS_s <=1'b0;    	   
    	   `LAST_TAR_LCLK1:    CS_BIOS_s <=1'b0;
    	   `LAST_TAR_LCLK2:    CS_BIOS_s <=1'b0;  	        	        	   
    	   default: 	  	     CS_BIOS_s <=1'b1; 
       endcase 
     end  
     else	 CS_BIOS_s <=1'b1;
   end
end 

always @ (posedge CLK_33M_CPLD or negedge LPC_rst_s) 
begin
   if (!LPC_rst_s) 
   begin
   	 CS_CPLD_s <=1'b1;
   end
   else
   begin
   	 if(CS_CPLD_hit_s) 
   	 begin
    	 case(LPC_next_state)   	     
//    	   `MEM_RD_TAR_LCLK1:  CS_CPLD_s <=1'b0;   	     
    	   `MEM_RD_TAR_LCLK2:  CS_CPLD_s <=1'b0;   	     
    	   `MEM_RD_SYNC1:      CS_CPLD_s <=1'b0;    	     
    	   `MEM_RD_SYNC2:      CS_CPLD_s <=1'b0;    	     
    	   `MEM_RD_SYNC3:      CS_CPLD_s <=1'b0;    	     
    	   `MEM_RD_SYNC4:      CS_CPLD_s <=1'b0;   	     
    	   `MEM_RD_SYNC5:      CS_CPLD_s <=1'b0;   	     
    	   `MEM_RD_DATA_LCLK1: CS_CPLD_s <=1'b0;   	     
    	   `MEM_RD_DATA_LCLK2: CS_CPLD_s <=1'b0;    
 //   	   `MEM_WR_DATA_LCLK1: CS_CPLD_s <=1'b0;
    	   `MEM_WR_DATA_LCLK2: CS_CPLD_s <=1'b0;
    	   `MEM_WR_TAR_LCLK1:  CS_CPLD_s <=1'b0;
    	   `MEM_WR_TAR_LCLK2:  CS_CPLD_s <=1'b0;
    	   `MEM_WR_SYNC1:      CS_CPLD_s <=1'b0;
    	   `MEM_WR_SYNC2:      CS_CPLD_s <=1'b0;
    	   `MEM_WR_SYNC3:      CS_CPLD_s <=1'b0;
    	   `MEM_WR_SYNC4:      CS_CPLD_s <=1'b0;
    	   `MEM_WR_SYNC5:      CS_CPLD_s <=1'b0;    	   
    	   `LAST_TAR_LCLK1:    CS_CPLD_s <=1'b0;
    	   `LAST_TAR_LCLK2:    CS_CPLD_s <=1'b0;  	        	        	   
    	   default: 	  	     CS_CPLD_s <=1'b1; 
       endcase 
     end  
     else	 CS_CPLD_s <=1'b1;
   end
end

always @ (posedge CLK_33M_CPLD or negedge LPC_rst_s) 
begin
   if (!LPC_rst_s) 
   begin
   	 CS4_CPLD_CS_s <=1'b1;
   end
   else
   begin
   	 if(CS4_CPLD_hit_s) 
   	 begin
    	 case(LPC_next_state)   	     
//    	   `MEM_RD_TAR_LCLK1:  CS4_CPLD_CS_s <=1'b0;   	     
    	   `MEM_RD_TAR_LCLK2:  CS4_CPLD_CS_s <=1'b0;   	     
    	   `MEM_RD_SYNC1:      CS4_CPLD_CS_s <=1'b0;    	     
    	   `MEM_RD_SYNC2:      CS4_CPLD_CS_s <=1'b0;    	     
    	   `MEM_RD_SYNC3:      CS4_CPLD_CS_s <=1'b0;    	     
    	   `MEM_RD_SYNC4:      CS4_CPLD_CS_s <=1'b0;   	     
    	   `MEM_RD_SYNC5:      CS4_CPLD_CS_s <=1'b0;   	     
    	   `MEM_RD_DATA_LCLK1: CS4_CPLD_CS_s <=1'b0;   	     
    	   `MEM_RD_DATA_LCLK2: CS4_CPLD_CS_s <=1'b0;    
 //   	   `MEM_WR_DATA_LCLK1: CS4_CPLD_CS_s <=1'b0;
    	   `MEM_WR_DATA_LCLK2: CS4_CPLD_CS_s <=1'b0;
    	   `MEM_WR_TAR_LCLK1:  CS4_CPLD_CS_s <=1'b0;
    	   `MEM_WR_TAR_LCLK2:  CS4_CPLD_CS_s <=1'b0;
    	   `MEM_WR_SYNC1:      CS4_CPLD_CS_s <=1'b0;
    	   `MEM_WR_SYNC2:      CS4_CPLD_CS_s <=1'b0;
    	   `MEM_WR_SYNC3:      CS4_CPLD_CS_s <=1'b0;
    	   `MEM_WR_SYNC4:      CS4_CPLD_CS_s <=1'b0;
    	   `MEM_WR_SYNC5:      CS4_CPLD_CS_s <=1'b0;    	   
    	   `LAST_TAR_LCLK1:    CS4_CPLD_CS_s <=1'b0;
    	   `LAST_TAR_LCLK2:    CS4_CPLD_CS_s <=1'b0;  	        	        	   
    	   default: 	  	     CS4_CPLD_CS_s <=1'b1; 
       endcase 
     end  
     else	 CS4_CPLD_CS_s <=1'b1;
   end
end 
    
always @ (posedge CLK_33M_CPLD or negedge LPC_rst_s) 
begin
   if (!LPC_rst_s) 
   begin
   	 CS5_CPLD_CS_s <=1'b1;
   end
   else
   begin
   	 if(CS5_CPLD_hit_s) 
   	 begin
    	 case(LPC_next_state)   	     
//    	   `MEM_RD_TAR_LCLK1:  CS5_CPLD_CS_s <=1'b0;   	     
    	   `MEM_RD_TAR_LCLK2:  CS5_CPLD_CS_s <=1'b0;   	     
    	   `MEM_RD_SYNC1:      CS5_CPLD_CS_s <=1'b0;    	     
    	   `MEM_RD_SYNC2:      CS5_CPLD_CS_s <=1'b0;    	     
    	   `MEM_RD_SYNC3:      CS5_CPLD_CS_s <=1'b0;    	     
    	   `MEM_RD_SYNC4:      CS5_CPLD_CS_s <=1'b0;   	     
    	   `MEM_RD_SYNC5:      CS5_CPLD_CS_s <=1'b0;   	     
    	   `MEM_RD_DATA_LCLK1: CS5_CPLD_CS_s <=1'b0;   	     
    	   `MEM_RD_DATA_LCLK2: CS5_CPLD_CS_s <=1'b0;    
 //   	   `MEM_WR_DATA_LCLK1: CS5_CPLD_CS_s <=1'b0;
    	   `MEM_WR_DATA_LCLK2: CS5_CPLD_CS_s <=1'b0;
    	   `MEM_WR_TAR_LCLK1:  CS5_CPLD_CS_s <=1'b0;
    	   `MEM_WR_TAR_LCLK2:  CS5_CPLD_CS_s <=1'b0;
    	   `MEM_WR_SYNC1:      CS5_CPLD_CS_s <=1'b0;
    	   `MEM_WR_SYNC2:      CS5_CPLD_CS_s <=1'b0;
    	   `MEM_WR_SYNC3:      CS5_CPLD_CS_s <=1'b0;
    	   `MEM_WR_SYNC4:      CS5_CPLD_CS_s <=1'b0;
    	   `MEM_WR_SYNC5:      CS5_CPLD_CS_s <=1'b0;    	   
    	   `LAST_TAR_LCLK1:    CS5_CPLD_CS_s <=1'b0;
    	   `LAST_TAR_LCLK2:    CS5_CPLD_CS_s <=1'b0;  	        	        	   
    	   default: 	  	     CS5_CPLD_CS_s <=1'b1; 
       endcase 
     end  
     else	 CS5_CPLD_CS_s <=1'b1;
   end
end 

always @ (posedge CLK_33M_CPLD or negedge LPC_rst_s) 
begin
   if (!LPC_rst_s) 
   begin
   	 CS6_CPLD_CS_s <=1'b1;
   end
   else
   begin
   	 if(CS6_CPLD_hit_s) 
   	 begin
    	 case(LPC_next_state)   	     
//    	   `MEM_RD_TAR_LCLK1:  CS6_CPLD_CS_s <=1'b0;   	     
    	   `MEM_RD_TAR_LCLK2:  CS6_CPLD_CS_s <=1'b0;   	     
    	   `MEM_RD_SYNC1:      CS6_CPLD_CS_s <=1'b0;    	     
    	   `MEM_RD_SYNC2:      CS6_CPLD_CS_s <=1'b0;    	     
    	   `MEM_RD_SYNC3:      CS6_CPLD_CS_s <=1'b0;    	     
    	   `MEM_RD_SYNC4:      CS6_CPLD_CS_s <=1'b0;   	     
    	   `MEM_RD_SYNC5:      CS6_CPLD_CS_s <=1'b0;   	     
    	   `MEM_RD_DATA_LCLK1: CS6_CPLD_CS_s <=1'b0;   	     
    	   `MEM_RD_DATA_LCLK2: CS6_CPLD_CS_s <=1'b0;    
 //   	   `MEM_WR_DATA_LCLK1: CS6_CPLD_CS_s <=1'b0;
    	   `MEM_WR_DATA_LCLK2: CS6_CPLD_CS_s <=1'b0;
    	   `MEM_WR_TAR_LCLK1:  CS6_CPLD_CS_s <=1'b0;
    	   `MEM_WR_TAR_LCLK2:  CS6_CPLD_CS_s <=1'b0;
    	   `MEM_WR_SYNC1:      CS6_CPLD_CS_s <=1'b0;
    	   `MEM_WR_SYNC2:      CS6_CPLD_CS_s <=1'b0;
    	   `MEM_WR_SYNC3:      CS6_CPLD_CS_s <=1'b0;
    	   `MEM_WR_SYNC4:      CS6_CPLD_CS_s <=1'b0;
    	   `MEM_WR_SYNC5:      CS6_CPLD_CS_s <=1'b0;    	   
    	   `LAST_TAR_LCLK1:    CS6_CPLD_CS_s <=1'b0;
    	   `LAST_TAR_LCLK2:    CS6_CPLD_CS_s <=1'b0;  	        	        	   
    	   default: 	  	     CS6_CPLD_CS_s <=1'b1; 
       endcase 
     end  
     else	 CS6_CPLD_CS_s <=1'b1;
   end
end 

always @ (posedge CLK_33M_CPLD or negedge LPC_rst_s) 
begin
   if (!LPC_rst_s) 
   begin
   	 CS7_CPLD_CS_s <=1'b1;
   end
   else
   begin
   	 if(CS7_CPLD_hit_s) 
   	 begin
    	 case(LPC_next_state)   	     
//    	   `MEM_RD_TAR_LCLK1:  CS7_CPLD_CS_s <=1'b0;   	     
    	   `MEM_RD_TAR_LCLK2:  CS7_CPLD_CS_s <=1'b0;   	     
    	   `MEM_RD_SYNC1:      CS7_CPLD_CS_s <=1'b0;    	     
    	   `MEM_RD_SYNC2:      CS7_CPLD_CS_s <=1'b0;    	     
    	   `MEM_RD_SYNC3:      CS7_CPLD_CS_s <=1'b0;    	     
    	   `MEM_RD_SYNC4:      CS7_CPLD_CS_s <=1'b0;   	     
    	   `MEM_RD_SYNC5:      CS7_CPLD_CS_s <=1'b0;   	     
    	   `MEM_RD_DATA_LCLK1: CS7_CPLD_CS_s <=1'b0;   	     
    	   `MEM_RD_DATA_LCLK2: CS7_CPLD_CS_s <=1'b0;    
 //   	   `MEM_WR_DATA_LCLK1: CS7_CPLD_CS_s <=1'b0;
    	   `MEM_WR_DATA_LCLK2: CS7_CPLD_CS_s <=1'b0;
    	   `MEM_WR_TAR_LCLK1:  CS7_CPLD_CS_s <=1'b0;
    	   `MEM_WR_TAR_LCLK2:  CS7_CPLD_CS_s <=1'b0;
    	   `MEM_WR_SYNC1:      CS7_CPLD_CS_s <=1'b0;
    	   `MEM_WR_SYNC2:      CS7_CPLD_CS_s <=1'b0;
    	   `MEM_WR_SYNC3:      CS7_CPLD_CS_s <=1'b0;
    	   `MEM_WR_SYNC4:      CS7_CPLD_CS_s <=1'b0;
    	   `MEM_WR_SYNC5:      CS7_CPLD_CS_s <=1'b0;    	   
    	   `LAST_TAR_LCLK1:    CS7_CPLD_CS_s <=1'b0;
    	   `LAST_TAR_LCLK2:    CS7_CPLD_CS_s <=1'b0;  	        	        	   
    	   default: 	  	     CS7_CPLD_CS_s <=1'b1; 
       endcase 
     end  
     else	 CS7_CPLD_CS_s <=1'b1;
   end
end 




always @ (posedge CLK_33M_CPLD or negedge LPC_rst_s) begin
   if (~LPC_rst_s) L_data_en <= 1'b0;
   else if (!PCH_LPC_FRAME_N)  L_data_en <= 1'b0;  
   else if ((LPC_next_state == `MEM_WR_TAR_LCLK1) || (LPC_next_state == `MEM_WR_TAR_LCLK2)||
            (LPC_next_state == `MEM_WR_SYNC1)     || (LPC_next_state == `MEM_WR_SYNC2)    ||
            (LPC_next_state == `MEM_WR_SYNC3)     || (LPC_next_state == `MEM_WR_SYNC4)    ||
            (LPC_next_state == `MEM_WR_SYNC5))
      L_data_en <= 1'b1;
   else if ((LPC_next_state == `LAST_TAR_LCLK1)  || (LPC_next_state == `LAST_TAR_LCLK2))
      L_data_en <= L_data_en;
   else
      L_data_en <=1'b0;
end

assign L_AD  = L_data_en ? lpc_data_in : 8'bzzzzzzzz;//访问主板逻辑写数据送出去

always @ (posedge CLK_33M_CPLD ) 
begin	
   if (wr_data_en[0]) 	lpc_data_in[3:0] <= PCH_LPC_LAD;
   if (wr_data_en[1]) 	lpc_data_in[7:4] <= PCH_LPC_LAD; 
end

always @ (posedge CLK_33M_CPLD ) 
begin	
   if (wr_P80_data_en[0] &&(lpc_P80_addr== 16'h0080)) 	lpc_P80_data[3:0] <= PCH_LPC_LAD;
   if (wr_P80_data_en[1] &&(lpc_P80_addr== 16'h0080)) 	lpc_P80_data[7:4] <= PCH_LPC_LAD; 
end


endmodule	
