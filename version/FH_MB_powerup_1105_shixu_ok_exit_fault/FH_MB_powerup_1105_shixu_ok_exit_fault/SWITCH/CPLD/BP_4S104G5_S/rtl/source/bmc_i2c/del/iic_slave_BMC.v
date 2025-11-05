`timescale 1ns / 1ps

module iic_slave_BMC(
input wire reset_n,
input wire clk_25mhz,

input wire iic_scl,
input wire iic_sda_in,
output reg iic_sda_out,
input wire [6:0] DEVICE_ID,
input wire address_width, // 0:8bit  1:16bit
output reg [7:0] command,
output reg [7:0] address_h,
output reg [7:0] address_l,
output reg [7:0] wdata,
input wire [7:0] rdata,

output reg  write_en,
output reg read_en,
output reg busy
);

localparam STATE_IDLE = 4'd0;
localparam STATE_START = 4'd1;
localparam STATE_COMMEND = 4'd2;
localparam STATE_ACK1 = 4'd3;
localparam STATE_ADDRESS_H = 4'd4;
localparam STATE_ACK2 = 4'd5;
localparam STATE_ADDRESS_L = 4'd6;
localparam STATE_ACK3 = 4'd7;
localparam STATE_WDATA = 4'd8;
localparam STATE_ACK4 = 4'd9; //Repeat Write
localparam STATE_RESTART = 4'd10;
localparam STATE_RECOMMAND = 4'd11;
localparam STATE_ACK5 = 4'd12;
localparam STATE_RDATA = 4'd13;
localparam STATE_ACK6 = 4'd14; //Repeat Read
localparam STATE_STOP = 4'd15;

reg [2:0] bit_count = 3'd0;
reg [3:0] state = STATE_IDLE;
reg ack_flag = 1'b1;
reg [7:0] command_shift = 8'h0;
reg [7:0] address_h_shift = 8'h0;
reg [7:0] address_l_shift = 8'h0;
reg [7:0] wdata_shift = 8'h0;
reg [7:0] rdata_shift = 8'h0;
reg [3:0] iic_scl_dly = 4'hf;
reg [3:0] iic_sda_in_dly = 4'hf;

wire iic_scl_posedge;
wire iic_scl_negedge;
wire iic_scl_posedge_dly;
wire iic_scl_negedge_dly;
wire iic_scl_edge_dly;
wire start;
wire stop;

// debounce sda and scl
localparam DEB_I2C_LEN = 4'd4; //debounce length
reg [DEB_I2C_LEN-1:0] sdaPipe;
reg [DEB_I2C_LEN-1:0] sclPipe;
reg sdaDeb;
reg sclDeb;
always @(posedge clk_25mhz) begin
  if (reset_n == 1'b0) 
	  begin
		sdaPipe <= {DEB_I2C_LEN{1'b1}};
		sdaDeb <= 1'b1;
		sclPipe <= {DEB_I2C_LEN{1'b1}};
		sclDeb <= 1'b1;
	  end
  else 
	  begin
		sdaPipe <= {sdaPipe[DEB_I2C_LEN-2:0], iic_sda_in};
		sclPipe <= {sclPipe[DEB_I2C_LEN-2:0], iic_scl};
		if (&sclPipe[DEB_I2C_LEN-1:1] == 1'b1) //all bits=1,scl output 1,all bits=0,scl output 0. Otherwise keep the last data.
		  sclDeb <= 1'b1;
		else if (|sclPipe[DEB_I2C_LEN-1:1] == 1'b0)
		  sclDeb <= 1'b0;
		if (&sdaPipe[DEB_I2C_LEN-1:1] == 1'b1)//all bits=1,sda output 1,all bits=0,sda output 0. Otherwise keep the last data.
		  sdaDeb <= 1'b1;
		else if (|sdaPipe[DEB_I2C_LEN-1:1] == 1'b0)
		  sdaDeb <= 1'b0;
	  end
end

always@(posedge clk_25mhz or negedge reset_n)
begin
	if(reset_n == 1'b0)
		iic_sda_in_dly <= 4'hf;
	else
		iic_sda_in_dly <= {iic_sda_in_dly[2:0],sdaDeb};
end

assign start = sclDeb & iic_sda_in_dly[3] & (!iic_sda_in_dly[2]);
assign stop = sclDeb & (!iic_sda_in_dly[3]) & iic_sda_in_dly[2];

always@(posedge clk_25mhz or negedge reset_n)
begin
	if(reset_n == 1'b0)
		iic_scl_dly <= 4'hf;
	else
		iic_scl_dly <= {iic_scl_dly[2:0],sclDeb};
end

assign iic_scl_posedge = (!iic_scl_dly[2]) & iic_scl_dly[1];
assign iic_scl_negedge = iic_scl_dly[2] & (!iic_scl_dly[1]);
assign iic_scl_posedge_dly = (!iic_scl_dly[3]) & iic_scl_dly[2];
assign iic_scl_negedge_dly = iic_scl_dly[3] & (!iic_scl_dly[2]);

//state machine
always@(posedge clk_25mhz or negedge reset_n)
begin
	if(reset_n == 1'b0)
		begin
			state <= STATE_IDLE;
			bit_count <= 3'd0;
			busy <= 1'b0;
		end
	else if(stop == 1'b1)
		begin
			state <= STATE_STOP;
			bit_count <= 3'd0;
			busy <= 1'b0;
		end
	else
		case(state)
			STATE_IDLE:
				begin
					if(start == 1'b1)
						begin
							state <= STATE_START;
							busy <= 1'b1;
						end
					else
						state <= STATE_IDLE;
				end
			STATE_START:
				begin
					if(iic_scl_negedge == 1'b1)
						state <= STATE_COMMEND;
					else
						state <= STATE_START;
				end
			STATE_COMMEND:
				begin
					if(iic_scl_negedge == 1'b1)
						begin 
							bit_count <= bit_count + 1'd1;
							if(bit_count ==3'd7)
								state <= STATE_ACK1;
							else
								state <= STATE_COMMEND;
						end
					else;
				end
			STATE_ACK1:
				begin
					if(iic_scl_negedge == 1'b1)
						begin
							if(command[7:1] == DEVICE_ID)
								begin
									if(address_width == 1'b1)
										state <= STATE_ADDRESS_H;
									else
										state <= STATE_ADDRESS_L;
								end
							else
								state <= STATE_IDLE;
						end
					else
						state <= STATE_ACK1;
				end
			STATE_ADDRESS_H:
				begin
					if(iic_scl_negedge == 1'b1)
						begin
							bit_count <= bit_count + 1'd1;
							if(bit_count == 3'd7)
								state <= STATE_ACK2;
							else
								state <= STATE_ADDRESS_H;
						end
					else;
				end
			STATE_ACK2:
				begin
					if(iic_scl_negedge == 1'b1)
						state <= STATE_ADDRESS_L;
					else
						state <= STATE_ACK2;
				end
			STATE_ADDRESS_L:
				begin
					if(iic_scl_negedge == 1'b1)
						begin
							bit_count <= bit_count + 1'd1;
							if(bit_count == 3'd7)
								state <= STATE_ACK3;
							else 
								state <= STATE_ADDRESS_L;
						end
					else;
				end
			STATE_ACK3:
				begin
					if(iic_scl_negedge == 1'b1)
						state <= STATE_WDATA;
					else
						state <= STATE_ACK3;
				end
			STATE_WDATA:
				begin	
					if(start == 1'b1)
						state <= STATE_RESTART;
					else if(iic_scl_negedge == 1'b1)
						begin
							bit_count <= bit_count +1'd1;
							if(bit_count == 3'd7)
								state <= STATE_ACK4;
							else 
								state <= STATE_WDATA;
						end
					else;
				end
			STATE_ACK4:
				begin
					if(iic_scl_negedge == 1'b1)
						state <= STATE_WDATA;
					else
						state <= STATE_ACK4;
				end
			STATE_RESTART: //Read 
				begin
					if(iic_scl_negedge == 1'b1)
						state <= STATE_RECOMMAND;
					else
						state <= STATE_RESTART;
				end
			STATE_RECOMMAND:
				begin
					if(iic_scl_negedge == 1'b1)
						begin
							bit_count <= bit_count + 1'd1;
							if(bit_count == 3'd7)
								state <= STATE_ACK5;
							else
								state <= STATE_RECOMMAND;
						end
					else;
				end
			STATE_ACK5:
				begin
					if(iic_scl_negedge == 1'b1)
						state <= STATE_RDATA;
					else
						state <= STATE_ACK5;
				end
			STATE_RDATA:
				begin
					if(iic_scl_negedge == 1'b1)
						begin
							bit_count <= bit_count +1'd1;
							if(bit_count == 3'd7)
								state <= STATE_ACK6;
							else
								state <= STATE_RDATA;
						end
					else;
				end
			STATE_ACK6:
				begin 
					if(iic_scl_negedge == 1'b1)
						begin
							if(ack_flag == 1'b0)
								state <= STATE_RDATA;
							else 
								state <= STATE_STOP;
						end
					else
						state <= STATE_ACK6;
				end
			STATE_STOP:
				begin
					state <= STATE_IDLE;
					bit_count <= 3'd0;
					busy <= 1'b0;
				end
			default: state <= STATE_IDLE;
		endcase
end

//ack_flag
always@(posedge clk_25mhz or negedge reset_n)
begin
	if(reset_n == 1'b0)
		ack_flag <= 1'b1;
	else if(state == STATE_IDLE)
		ack_flag <= 1'b1;
	else if(state == STATE_ACK6)
		begin
			if(iic_scl_posedge == 1'b1)
				ack_flag <= iic_sda_in_dly[3];
			else;
		end
	else
		ack_flag <= 1'b1;
end

//command
always@(posedge clk_25mhz or negedge reset_n)
begin
	if(reset_n == 1'b0)
		command_shift <= 8'h0;
	else if(state == STATE_IDLE)
		command_shift <= 8'h0;
	else if(((state == STATE_COMMEND) || (state == STATE_RECOMMAND)) && (iic_scl_posedge == 1'b1))
		command_shift <= {command_shift[6:0],iic_sda_in_dly[3]};
	else;
end

always@(posedge clk_25mhz or negedge reset_n)
begin
	if(reset_n == 1'b0)
		command <= 8'h0;
	else if(state == STATE_IDLE)
		command <= 8'h0;
	else if(((state == STATE_COMMEND) || (state == STATE_RECOMMAND)) && (bit_count == 3'd7) && (iic_scl_posedge_dly == 1'b1))
		command<= command_shift;
	else;
end

//address_h
always@(posedge clk_25mhz or negedge reset_n)
begin
	if(reset_n == 1'b0)
		address_h_shift <= 8'h0;
	else if(state == STATE_IDLE)
		address_h_shift <= 8'h0;
	else if((state == STATE_ADDRESS_H) && (iic_scl_posedge == 1'b1))
		address_h_shift <= {address_h_shift[6:0],iic_sda_in_dly[3]};
	else;
end

always@(posedge clk_25mhz or negedge reset_n)
begin
	if(reset_n == 1'b0)
		address_h <= 8'h0;
	else if(state == STATE_IDLE)
		address_h <= 8'h0;
	else if((state == STATE_ACK2) && (iic_scl_posedge == 1'b1))
		address_h <= address_h_shift;
	else;
end

//address_l
always@(posedge clk_25mhz or negedge reset_n)
begin
	if(reset_n == 1'b0)
		address_l_shift <= 8'h0;
	else if(state == STATE_IDLE)
		address_l_shift <= 8'h0;
	else if((state == STATE_ADDRESS_L) && (iic_scl_posedge == 1'b1))
		address_l_shift <= {address_l_shift[6:0],iic_sda_in_dly[3]};
	else;
end

always@(posedge clk_25mhz or negedge reset_n)
begin
	if(reset_n == 1'b0)
		address_l <= 8'h0;
	else if(state == STATE_IDLE)
		address_l <= 8'h0;
	else if((state == STATE_ACK3) && (iic_scl_posedge == 1'b1))
		address_l <= address_l_shift;
	else if(((state == STATE_ACK4) || (state == STATE_ACK6)) && (iic_scl_posedge == 1'b1))
		address_l <= address_l +1'b1;
	else;
end

//write_en
always@(posedge clk_25mhz or negedge reset_n)
begin
	if(reset_n == 1'b0)
		write_en <= 1'b0;
	else if((state == STATE_WDATA) && (bit_count == 3'd7) && (iic_scl_negedge == 1'b1))
		write_en <= 1'b1;
	else
		write_en <= 1'b0;
end

//wdata
always@(posedge clk_25mhz or negedge reset_n)
begin
	if(reset_n == 1'b0)
		wdata_shift <= 8'h0;
	else if(state == STATE_IDLE)
		wdata_shift <= 8'h0;
	else if((state == STATE_WDATA) && (iic_scl_posedge == 1'b1))
		wdata_shift <= {wdata_shift[6:0],iic_sda_in_dly[3]};
	else;
end

always@(posedge clk_25mhz or negedge reset_n)
begin
	if(reset_n == 1'b0)
		wdata <= 8'h0;
	else if(state == STATE_IDLE)
		wdata <= 8'h0;
	else if((state == STATE_WDATA) && (bit_count == 3'd7) && (iic_scl_negedge == 1'b1))
		wdata <= wdata_shift;
	else;
end

//read_en
always@(posedge clk_25mhz or negedge reset_n)
begin
	if(reset_n == 1'b0)
		read_en <= 1'b0;
	else if(((state == STATE_ACK5) || (state == STATE_ACK6)) && (iic_scl_posedge == 1'b1))
		read_en <= 1'b1;
	else
		read_en <= 1'b0;
end

//rdata
always@(posedge clk_25mhz or negedge reset_n)
begin
	if(reset_n == 1'b0)
		rdata_shift <= 8'h0;
	else if(state == STATE_IDLE)
		rdata_shift <= 8'h0;
	else if(((state == STATE_ACK5) || (state == STATE_ACK6)) && (iic_scl_negedge == 1'b1))
		rdata_shift <= rdata;
	else if ((state == STATE_RDATA) && (iic_scl_negedge == 1'b1))
		rdata_shift <= {rdata_shift[6:0],1'b0};
	else;
end

//iic_sda_out
always@(posedge clk_25mhz or negedge reset_n)
begin 
	if(reset_n == 1'b0)
		iic_sda_out <= 1'b1;
	else
		case(state)
			STATE_IDLE,STATE_START,STATE_COMMEND,STATE_ADDRESS_H,STATE_ADDRESS_L,STATE_WDATA,STATE_STOP:
				begin
					iic_sda_out <= 1'b1;
				end
			STATE_ACK1:
				begin
					if(command[7:1] == DEVICE_ID)
						iic_sda_out <= 1'b0;
					else
						iic_sda_out <= 1'b1;
				end
			STATE_ACK2,STATE_ACK3,STATE_ACK4,STATE_ACK5:
				begin 
					iic_sda_out <= 1'b0;
				end
			STATE_ACK6:
				begin
					iic_sda_out <= 1'b1;
				end
			STATE_RDATA:
				begin
					if((state == STATE_RDATA) && (iic_scl_negedge_dly == 1'b1))
						iic_sda_out <= rdata_shift[7];
					else;
				end
			default : ;
		endcase
end
endmodule

