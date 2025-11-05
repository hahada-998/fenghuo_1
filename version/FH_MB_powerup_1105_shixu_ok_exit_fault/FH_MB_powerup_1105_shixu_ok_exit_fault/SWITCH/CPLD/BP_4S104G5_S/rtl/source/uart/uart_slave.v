//*************************************************************************\
// Copyright (c) 2010, H3C Technologies Co.,Ltd, All rights reserved
//
//                   File Name  :  UART_SLAVE.v
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
//2019/12/14   fuquanlong	  1.5		To be bidirectional signal
//2020/2/11    fuquanlong	  1.61		Simulation optimization
//2020/3/04    fuquanlong	  1.7		Delete interface "ser_data_in","ser_data_out","write_flag"
//										Add interface "ser_data","send_enable"
//*************************************************************************/
module UART_SLAVE
#(
parameter NBIT_IN = 10,
parameter NBIT_OUT = 10,
parameter BPS_COUNT_NUM =48, // BPS=1200 ,tick * BPS_COUNT_NUM
parameter START_COUNT_NUM = 24 // Generally, START_COUNT_NUM = BPS_COUNT_NUM/2
)
(
	input clk,
	input rst,
	input tick,     // This tick period is 16us
	input t128ms_tick,
	input [NBIT_OUT-1 : 0] par_data_in,
	output reg [NBIT_IN-1 : 0] par_data_out,
	input send_enable,
	inout ser_data,
	output reg [2:0] curr_state,
	output reg  error_flag	
);

reg ser_data_out;
reg write_flag;
assign ser_data = (write_flag && send_enable) ? ser_data_out : 1'bz;
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
localparam WAIT_T = 5'h05; 

//20200521 w13298
localparam DETECT        = 3'b000;
localparam DETECT1       = 3'b001;
localparam IDLE          = 3'b010;
localparam START         = 3'b011;
localparam DATA_IN       = 3'b100;
localparam WAIT          = 3'b101;
localparam RESTART       = 3'b110;
localparam DATA_OUT      = 3'b111;

reg [BPS_CNT-1:0] bps_count_bit;
reg [NBIT_IN+5:0] reg_data_in;
wire state_change;
//reg [2:0] curr_state;
reg [2:0] next_state;
reg [2:0] last_state;
reg [WCNT-1:0] data_count;
reg [4:0] wait_time;
wire [NBIT_OUT6-1:0] reg_data_out;

assign reg_data_out ={3'b010,par_data_in,3'b101};

always@(posedge clk or posedge rst)
begin
	if (rst)
	curr_state <= DETECT;
	else 
	curr_state <= next_state;
end

always@(posedge clk or posedge rst)
begin
    if (rst)
		wait_time <= 5'h00;
	else if (wait_time == WAIT_T)
		wait_time <= 5'h00;
	else if((curr_state == WAIT)&&(bps_count_bit == BPS_COUNT_NUM))
		wait_time <= wait_time + 1'b1;
end

reg [1:0] det_cnt;
always@(posedge clk or posedge rst)
begin
    if (rst) 
	  det_cnt <= 2'b00;
	else
	  det_cnt <= t128ms_tick ? {det_cnt[0], 1'b1} : det_cnt;
end

reg [2:0] reg_ser_data_in;
always@(posedge clk or posedge rst)
begin
    if(rst) 
	  reg_ser_data_in <= 3'b0;
	else
	  reg_ser_data_in <= {reg_ser_data_in[1:0], ser_data_in};
end

wire ser_data_in_ne = (reg_ser_data_in == 3'b100);

always@(*)
begin
  next_state = curr_state;
  case(curr_state)
	 DETECT:
	 begin
		if (det_cnt[1])
		next_state = IDLE;
	 end
	 
	 IDLE:
	 begin
		if (ser_data_in_ne)
		next_state = START;
	 end
	 
	 START:
	 begin
		if (/*(~ser_data_in) &&*/ (bps_count_bit == START_COUNT_NUM))
		next_state = DATA_IN;

	 end
	 
	 DATA_IN:
	 begin
		if ((data_count == NBIT_IN6) && (bps_count_bit == BPS_COUNT_NUM))
		next_state = WAIT;
	 end
	 
	 WAIT:
 	 begin
		if (wait_time == WAIT_T)
			next_state = RESTART;
	 end
	
	 RESTART:
	 begin
		if (bps_count_bit == BPS_COUNT_NUM)
		next_state = DATA_OUT;
	 end	
	 
	 DATA_OUT:
	 begin
		if (data_count == NBIT_OUT6 )// & (bps_count_bit == BPS_COUNT_NUM))	
		next_state = IDLE;//DETECT1;
	 end
	 
	 default: next_state = DETECT;
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


always@(posedge clk or posedge rst)
begin
    if (rst)
	bps_count_bit <= {BPS_CNT{1'b0}};
	else if (state_change | (bps_count_bit == BPS_COUNT_NUM)) // bps = 9600
	bps_count_bit <= {BPS_CNT{1'b0}};
	else if (tick)
	bps_count_bit <= bps_count_bit + 1'b1;
	
end

/*****************************************************************/
always@(posedge clk or posedge rst)
begin
if (rst)
	begin
		write_flag   <= 1'b0;
		ser_data_out <= 1'b1;
		data_count   <= {WCNT{1'b0}};
        reg_data_in  <= {(NBIT_IN6){1'b0}};
	end
else 
begin
     case(curr_state)	
	 DETECT:
	 begin
		write_flag <= 1'b1;
		if(det_cnt==2'b01)//det_timeout[0]
		ser_data_out <= tick ? ~ser_data_out : ser_data_out;
		else
		ser_data_out <= 1'bz;	
	 end
 
	 DETECT1:
	 begin
		write_flag <= 1'b0;
		ser_data_out <= 1'bz;
	 end
	 
	 IDLE:
	 begin
		write_flag <= 1'b0;
		ser_data_out <= 1'bz;
		data_count <= {WCNT{1'b0}};
	 end
	 
	 START:
	 begin
		write_flag <= 1'b0;
		ser_data_out <= 1'bz;
		data_count <= {WCNT{1'b0}};
	 end
	 
	 DATA_IN:
	 begin
		write_flag <= 1'b0;
		ser_data_out <= 1'bz;
	 if (bps_count_bit == BPS_COUNT_NUM)
		begin
			data_count <= data_count + 1'b1;
			reg_data_in[data_count] <= ser_data_in;
		end 
	 end
	 
	 WAIT:
		begin
			write_flag <= 1'b1;
			ser_data_out <= 1'b1;
			data_count <= {WCNT{1'b0}};
		end

	 RESTART:
	 begin
		write_flag <= 1'b1;
		ser_data_out <= 1'b0;
	    data_count <= {WCNT{1'b0}};
	 end	 
	 
	 DATA_OUT:
	 begin			
		ser_data_out <= reg_data_out[data_count];
		data_count <= (bps_count_bit == BPS_COUNT_NUM) ? data_count + 1'b1 : data_count;
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
	end
else if ((data_count == NBIT_IN6 )&& (curr_state == DATA_IN))
		begin 
			if((reg_data_in[2:0] == 3'b101) && (reg_data_in[NBIT_IN+5:NBIT_IN+3] == 3'b010))
				par_data_out <= reg_data_in[NBIT_IN+2:3];
			else  
			begin
				error_flag  <= 1'b1;
			end
		end			
end
endmodule