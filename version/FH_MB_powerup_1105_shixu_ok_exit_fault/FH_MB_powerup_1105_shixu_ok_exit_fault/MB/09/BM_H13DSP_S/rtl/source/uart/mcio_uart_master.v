//*************************************************************************\
// Copyright (c) 2010, H3C Technologies Co.,Ltd, All rights reserved
//
//                   File Name  :  NVME_UART_OUT.v
//                Project Name  :  R6900 G5
//                      Author  :  
//                     NotesID  :  
//                       Email  :  
//                      Device  :
//                     Company  :  H3C Technologies Co.,Ltd
//==========================================================================
//   Description:
//
//   Called by  :
//==========================================================================
//   Revision History:
//  Date        By          Revision    Change Description
//--------------------------------------------------------------------------
//2019/06/18   fuxingyi       1.0       Original
//2019/12/13   fuquanlong	  1.5		To be bidirectional signal
//2020/2/11    fuquanlong	  1.61		Simulation optimization
//2020/3/04    fuquanlong	  1.7		Delete interface "ser_data_in","ser_data_out","read_flag"
//										Add interface "ser_data","send_enable"
//*************************************************************************/
module UART_MASTER
#(
parameter NBIT_IN = 10,
parameter NBIT_OUT = 10,
parameter BPS_COUNT_NUM =48, // BPS=1200 ,tick * BPS_COUNT_NUM 
parameter START_COUNT_NUM = 24 // Generally, START_COUNT_NUM = BPS_COUNT_NUM/2
)
(
	input clk,
	input rst,
	input tick, 
	input send_enable,
    input t128ms_tick, // Send uart a group of signal per 128ms 
	input [NBIT_OUT-1 : 0] par_data_in,
	output reg  [NBIT_IN-1 : 0] par_data_out,	
	inout	ser_data,
	input riser_en_out,  
	input mcio_cable_id0,
	input mcio_cable_id1,
	

	output reg  error_flag
);
reg	 read_flag;
reg	 ser_data_out; 

wire ser_data_in ;

assign ser_data = (mcio_cable_id1 == 1'b0 && mcio_cable_id0 == 1'b0) ? (read_flag ? 1'bz : ser_data_out) : riser_en_out; //mcio_cable_id = 00 --> X4 --> BP
//2023-12-15 modify ser_data to judge  mcio_cable_id

assign ser_data_in = ser_data;

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
localparam NBIT_IN6 = NBIT_IN + 6;
localparam NBIT_OUT6 = NBIT_OUT + 6;
localparam WCNT = (NBIT_IN > NBIT_OUT) ? clogb2(NBIT_IN6) : clogb2(NBIT_OUT6); 
localparam BPS_CNT = clogb2(BPS_COUNT_NUM);
localparam WAIT_T = 5'h03; 


reg [5:0] bps_count_bit;
reg [4:0] wait_time;
wire [NBIT_OUT6-1:0] reg_par_data_in;//
wire state_change;
reg [2:0] curr_state;
reg [2:0] next_state;
reg [2:0] last_state;
reg [WCNT-1:0] data_count;
reg [NBIT_IN6-1:0] reg_par_data_out;

//state
localparam IDLE = 3'b000;
localparam START = 3'b001;
localparam DATA_OUT = 3'b010;
localparam WAIT = 3'b011;
localparam RESTART = 3'b100;
localparam DATA_IN = 3'b101;
assign reg_par_data_in ={3'b010,par_data_in,3'b101};

always@(posedge clk or posedge rst)
begin
	if (rst)
	curr_state <= IDLE;
	else 
	curr_state <= next_state;
end

always@(posedge clk or posedge rst)
begin
    if (rst)
		wait_time <= 5'h00;
	else 
	begin
		if(wait_time == WAIT_T)
			wait_time <= 5'h00;
		else 
			if((curr_state == WAIT)&&(bps_count_bit == BPS_COUNT_NUM))
				wait_time <= wait_time + 1'b1;
	end
end

always@(*)
begin
	
	next_state = curr_state;
		
     case(curr_state)
	 IDLE:
	 begin
		if ((t128ms_tick) && send_enable)
		next_state = START;
		else 
		next_state = IDLE;
	 end
	 START:
	 begin
		if (bps_count_bit == BPS_COUNT_NUM)
		next_state = DATA_OUT;
		else 
		next_state = START;
	 end
	 DATA_OUT:
	 begin
		if (data_count == NBIT_OUT6)
			next_state = WAIT;
		else 
		next_state = DATA_OUT;
	 end
	WAIT:
	 begin
		if(wait_time == WAIT_T)
			next_state = RESTART;
		else 
			next_state = WAIT;
	 end
 
	 RESTART:
	 begin
		if ((~ser_data_in) && (bps_count_bit == BPS_COUNT_NUM))
			next_state = DATA_IN;
		else begin
				if(t128ms_tick)
					next_state = IDLE;
				else
					next_state = RESTART;
			end
	 end	 
	 
	 DATA_IN:
	 begin
		if ((data_count == NBIT_IN6)&& (bps_count_bit == BPS_COUNT_NUM))
		next_state = IDLE;
		else 
		next_state = DATA_IN;
	 end	 
	 default: 
	 begin
		next_state = IDLE;
	 end
	 endcase
end

always@(posedge clk or posedge rst)
begin
	if (rst)
	last_state <= IDLE;
	else 
	last_state <= curr_state;
end

assign state_change = (last_state != curr_state);

//bps count
always@(posedge clk or posedge rst)
begin
    if (rst)
	bps_count_bit <= {BPS_CNT{1'b0}};
	else if (state_change | (bps_count_bit == BPS_COUNT_NUM)) // bps = 9600
	bps_count_bit <= {BPS_CNT{1'b0}};
	else if (tick)
	bps_count_bit <= bps_count_bit + 1'b1;
	
end


always@(posedge clk or posedge rst)
begin
	if (rst)
	begin
		read_flag <= 1'b0;
		ser_data_out <= 1'b1;
		data_count <= {WCNT{1'b0}};
	end
	else 
	begin
		case (curr_state)
		IDLE :
		begin 
		ser_data_out <= 1'b1;
		read_flag <= 1'b0;
		data_count <= {WCNT{1'b0}};
		end 
		
		START:
		begin
			ser_data_out <= 1'b0;
		end
		
		DATA_OUT:
		begin
		ser_data_out <= reg_par_data_in[data_count];
		data_count <= (bps_count_bit == BPS_COUNT_NUM) ? data_count + 1'b1 : data_count;
		end 
		
		WAIT:
		begin
			ser_data_out <= 1'bz;
			read_flag <= 1'b1;
			data_count <= {WCNT{1'b0}};	
		end

		RESTART:
		begin

		end
		
		DATA_IN:
		if(bps_count_bit == BPS_COUNT_NUM)
		begin
			reg_par_data_out[data_count] <= ser_data_in;
			data_count <= data_count + 1'b1;
		end 
		endcase
    end 
end

always@(posedge clk or posedge rst)
begin
	if (rst)
	begin
		par_data_out <= {NBIT_IN {1'b0}};
		error_flag  <= 1'b0;
		//reg_par_data_out<= {(NBIT_IN6){1'b0}};
	end
	else if ((data_count == NBIT_IN6) && (curr_state == DATA_IN))
		begin
			if((reg_par_data_out[2:0] == 3'b101) && (reg_par_data_out[NBIT_IN6-1:NBIT_IN6-3] == 3'b010 ))
				par_data_out <= reg_par_data_out[NBIT_IN+2:3];
			else begin
					error_flag  <= 1'b1;
				end
		end
end


endmodule