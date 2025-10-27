//=================================================================================================--
// Copyright(c) 2021, CLOUDNINEINFO.CO, Ltd, All right reserved
// Filename   : AIS03MB03.v
// Project    : CLOUDNINEINFO common code
// Author     : dingxianhua
// Date       : 2020-09-24
// Email      : dingxianhua@cloudnineinfo.com
// Company    : CLOUDNINEINFO.CO., Ltd
//==========================================================================
//   Description:
//
//   Called by  :
//==========================================================================
//   Revision History:
//  Date        By          Revision    Change Description
//--------------------------------------------------------------------------
//*************************************************************************/
module UART_MASTER_LED
#(
  parameter NBIT_IN = 10,
  parameter NBIT_OUT = 10,
  parameter BPS_COUNT_NUM =48,   //BPS=1200 ,tick * BPS_COUNT_NUM 
  parameter NO_DETECT = 1'b0,    //Used to disable PASS THROUGH mode, when 1, no PASS THROUGH, when 0
  parameter START_COUNT_NUM = 24 //Used to adjust receive timing, generally, START_COUNT_NUM = BPS_COUNT_NUM/2
)(
  input                      clk,
  input                      rst,
  input                      tick,
  input                      send_enable,
  input                      pass_through,
  input                      wake_up,
  input                      t128ms_tick, // Send uart a group of signal per 128ms
  input       [NBIT_OUT-1:0] par_data_in,
  output reg  [NBIT_IN-1:0]  par_data_out,
  inout	                     ser_data,    //physical pin
  output reg                 error_flag
);
reg		read_flag;
reg		ser_data_out;
assign ser_data = wake_up ? 1'b1 : (read_flag ? 1'bz : ser_data_out);//wake_up_pluse;//wake_up_pluse;//read_flag ? 1'bz : ser_data_out;
//assign ser_data = send_enable ? (read_flag ? 1'bz : ser_data_out) : pass_through;
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
localparam DETECT        = 3'b000;
localparam IDLE          = 3'b001;
localparam START         = 3'b010;
localparam DATA_OUT      = 3'b011;
localparam WAIT          = 3'b100;
localparam RESTART       = 3'b101;
localparam DATA_IN       = 3'b110;
localparam PASS_THROUGH  = 3'b111;

assign reg_par_data_in ={3'b010,par_data_in,3'b101};

always@(posedge clk or posedge rst)
begin
	if (rst)
	curr_state <= DETECT;
	else 
	curr_state <= next_state;
end

always@(posedge clk or posedge rst)
begin
    if(rst)
		wait_time <= 5'h00;
	else if(wait_time == WAIT_T)
		wait_time <= 5'h00;
	else if((curr_state == WAIT)&&(bps_count_bit == BPS_COUNT_NUM))
		wait_time <= wait_time + 1'b1;
end

reg [1:0] det_cnt;
reg       det_timeout;
reg [1:0] det_pluse_reg;
reg [2:0] det_pluse_cnt;

always@(posedge clk or posedge rst)
begin
    if(rst) begin
	  det_cnt        <= 2'b00;
	  det_timeout    <= 1'b0;
	  det_pluse_reg  <= 2'b00;
	  det_pluse_cnt  <= 3'b000;
	end
	else begin
	  det_cnt       <= (t128ms_tick && (det_cnt !== 2'b11)) ? (det_cnt + 1) : det_cnt;
	  det_timeout   <= (det_cnt == 2'b11) ? 1'b1 : 1'b0;
	  det_pluse_reg <= {det_pluse_reg[0], ser_data_in};
	  det_pluse_cnt <= ((det_pluse_cnt !== 3'b101) && (det_pluse_reg == 2'b10)) ? det_pluse_cnt + 1: det_pluse_cnt;
	end
end

always@(*)
begin
  next_state = curr_state;		
  case(curr_state)
	 DETECT:
     begin
		if(~det_timeout)
		  next_state = DETECT;
		else if((det_pluse_cnt == 3'b101) | NO_DETECT)
		  next_state = IDLE;
		else 
		  next_state = PASS_THROUGH;
	 end
	 
	 IDLE:
	 begin
		if (t128ms_tick && send_enable)
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
		if((~ser_data_in) && (bps_count_bit == BPS_COUNT_NUM))
			next_state = DATA_IN;
		else if(t128ms_tick)
			next_state = IDLE;
		else
			next_state = RESTART;
	 end	 
	 
	 DATA_IN:
	 begin
		if((data_count == NBIT_IN6)&& (bps_count_bit == BPS_COUNT_NUM))
		  next_state = IDLE;
		else 
		  next_state = DATA_IN;
	 end
	 
	 PASS_THROUGH:
	 begin
		  next_state = PASS_THROUGH; 
	 end
	 
	 default: next_state = IDLE;
  endcase
end

always@(posedge clk or posedge rst)
begin
	if(rst)
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
		read_flag    <= 1'b1;
		ser_data_out <= 1'bz;
		data_count   <= {WCNT{1'b0}};
	end
	else 
	begin
		case (curr_state)
		DETECT :
		begin
		  read_flag    <= 1'b1;
		  ser_data_out <= 1'bz;
		  data_count   <= {WCNT{1'b0}};
		end 
		IDLE :
		begin 
		  read_flag    <= 1'b0;
		  ser_data_out <= 1'b1;
		  data_count   <= {WCNT{1'b0}};
		end 
		START:
		begin
		  read_flag    <= 1'b0;
		  ser_data_out <= 1'b0;
		  data_count   <= {WCNT{1'b0}};
		end		
		DATA_OUT:
		begin
		  read_flag    <= 1'b0;
		  ser_data_out <= reg_par_data_in[data_count];
		  data_count   <= (bps_count_bit == BPS_COUNT_NUM) ? data_count + 1'b1 : data_count;
		end 
		WAIT:
		begin
		 read_flag    <= 1'b1;
		 ser_data_out <= 1'bz;
		 data_count   <= {WCNT{1'b0}};	
		end
		RESTART:
		begin
      //reg_par_data_out<= {(NBIT_IN6){1'b0}};//add by 14162
		end
		DATA_IN:
		begin
		  read_flag    <= 1'b1;
		  if(bps_count_bit == BPS_COUNT_NUM) begin		
			reg_par_data_out[data_count] <= ser_data_in;
			data_count <= data_count + 1'b1;
			end 
		end
		PASS_THROUGH:
		begin
		  read_flag    <= 1'b0;
		  ser_data_out <= pass_through;
		  data_count   <= {WCNT{1'b0}};
		end 
		endcase		
    end 
end

always@(posedge clk or posedge rst)
begin
	if (rst)
	begin
		par_data_out <= {NBIT_IN{1'b0}};
		error_flag  <= 1'b0;
		//reg_par_data_out<= {(NBIT_IN6){1'b0}};
	end
	else if ((data_count == NBIT_IN6) && (curr_state == DATA_IN))
		begin
			if((reg_par_data_out[2:0] == 3'b101) && (reg_par_data_out[NBIT_IN6-1:NBIT_IN6-3] == 3'b010 ))begin
				par_data_out <= reg_par_data_out[NBIT_IN+2:3];
				error_flag  <= 1'b0;
			end
			else begin
			   par_data_out <= {NBIT_IN{1'b0}};//add by 14162
			   error_flag  <= 1'b1;
			end
		end
  else if ((curr_state == RESTART) && (next_state == IDLE))//add by 14162
	   begin 
		      par_data_out <= {NBIT_IN{1'b0}};
			   error_flag  <= 1'b1;
		end
end


endmodule