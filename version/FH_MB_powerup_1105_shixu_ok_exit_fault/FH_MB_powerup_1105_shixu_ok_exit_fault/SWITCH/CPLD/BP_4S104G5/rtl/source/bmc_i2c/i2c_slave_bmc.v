// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
// *                   C O P Y R I G H T     N O T I C E                       *
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
// *    2021-02-26: New Created


`timescale 1ns/1ps

module i2c_slave_bmc #(
parameter DLY_LEN  = 3   //24.18MHz,330ns
)(
input    i_rst_n, 
input    i_clk,
input    i_1ms_clk,

input	 i_rst_i2c_n,

input    i_scl,
inout    io_sda,
input    [6:0] i_i2c_address,
output   o_i2c_start,
output   o_WR,
output   o_data_vld_pos,
output   [15:0] o_i2c_command,
input    [7:0]  i_i2c_data_in,
output   [7:0]  o_i2c_data_out

); 
      

//////////////////////////////////////////////////////////////
wire w_start;
wire w_stop;
wire [7:0] w_i2c_data_out;
wire w_R_W; 
wire w_data_vld;
wire w_data_vld_pos;  
wire [6:0] w_i2c_addr_out;    
wire [15:0] w_i2c_command;
//////////////////////////////////////////////////////////////
reg [7:0] r_i2c_data_in;
reg	r_data_vld1;
reg	r_data_vld2;
reg r_addr_hit;
reg [15:0] r_i2c_command_temp; 
reg [15:0] r_i2c_command;  
reg [15:0] r_read_byte_cnt;
reg [15:0] r_write_byte_cnt;
/////////////////////////////////////////////////////////////
assign o_i2c_start    = w_start;  
assign o_WR           = w_R_W;
assign o_i2c_data_out = w_i2c_data_out;
assign o_data_vld_pos = w_data_vld_pos;
assign o_i2c_command  = r_i2c_command;

//-------------------addr hit------------------------------//

always @(posedge i_clk or negedge i_rst_n) begin
    if (~i_rst_n ) 
        r_addr_hit <= 'b0;    
    else if (w_i2c_addr_out == i_i2c_address)        
        r_addr_hit <= 1'b1;
    else
        r_addr_hit <= 1'b0;   
end  
 

//----------------i2c slave instant---------------------//

i2c_slave_basic0 #(
.TOTAL_STAGES       (3),
.DLY_LEN            (DLY_LEN)            //24.18MHz,330ns
)i2c_slave_basic0_u0(      
// generic ports
.i_rst_n            (i_rst_n & i_rst_i2c_n), 		
.i_clk              (i_clk),                    // System Reset
.i_1ms_clk          (i_1ms_clk),
.i_data_in          (r_i2c_data_in),              // parallel data in
.i_addr_hit         (r_addr_hit),                   // when address meet, turn to high
.o_I2C_ADDR_OUT     (w_i2c_addr_out),
.o_data_out         (w_i2c_data_out),         // parallel data out 
.o_R_W              (w_R_W),                        // read/write signal to the reg_map bloc
.o_data_vld         (w_data_vld),               // data valid from i2c 
.o_start            (w_start),                      // o_Start of the i2c cycle
.o_stop             (w_stop),                       // o_Stop the i2c cycle

.i_scl              (i_scl),
.io_sda             (io_sda)
);
  
 
//------------------------valid data detect-----------------//

always@(posedge i_clk) begin
  r_data_vld1 <= w_data_vld;
  r_data_vld2 <= r_data_vld1;
end
assign w_data_vld_pos    = ~r_data_vld2 & r_data_vld1;  

//---------------------read byte counter--------------------//

always@(posedge i_clk or posedge w_start) begin
	if(w_start) 
		r_read_byte_cnt	<= 16'h0000;
	else if(w_data_vld_pos & w_R_W & r_addr_hit)
		r_read_byte_cnt  <= r_read_byte_cnt + 1;
end

 
//------------------- -write byte counter--------------------//

always@(posedge i_clk or posedge w_start) begin
	if(w_start) 
		 r_write_byte_cnt	<= 16'h0000;
	else if(w_data_vld_pos & ~w_R_W & r_addr_hit)
		 r_write_byte_cnt  <= r_write_byte_cnt + 1;
end


//-----------------------command id-------------------------//


always@(posedge i_clk or negedge i_rst_n) begin
	if(~i_rst_n) 
		 r_i2c_command_temp		<= 16'hffff; 
	else if(w_data_vld_pos & (r_write_byte_cnt == 0) & (~w_R_W) & r_addr_hit)
		 r_i2c_command_temp[15:8]		<= w_i2c_data_out;
	else if(w_data_vld_pos & (r_write_byte_cnt == 1) & (~w_R_W) & r_addr_hit)
		 r_i2c_command_temp[7:0]		<= w_i2c_data_out;	 
end

assign w_i2c_command = ((r_write_byte_cnt == 2) & (~w_R_W) & r_addr_hit) ? r_i2c_command_temp : w_i2c_command;



always@(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
	     r_i2c_command  <= 16'hffff;
	 end
	 else begin
	     if(!w_R_W && (r_write_byte_cnt >=2) )
		      r_i2c_command  <= w_i2c_command + r_write_byte_cnt -2;
		  else if(w_R_W && (r_read_byte_cnt >= 0))
		      r_i2c_command  <= w_i2c_command + r_read_byte_cnt;
		  else
		      r_i2c_command  <= 16'hffff;
	 end
end 
 
  
 
//-------------------------------------------------------------------------



 


 
 
 
 

//-----------------------BMC READ---------------------------------------//

always@(posedge i_clk or negedge i_rst_n) begin
	if(~i_rst_n)
		 r_i2c_data_in	<= 8'h00;
	else if ( w_R_W) begin    
		 r_i2c_data_in	<= i_i2c_data_in;
	end 
	else begin
		 r_i2c_data_in	<= 8'h00;
	end
end
 
 
 

endmodule 